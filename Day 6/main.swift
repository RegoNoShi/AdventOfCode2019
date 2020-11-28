import Foundation

let inputFile = loadInputFile()

print("Day 6\n")

_ = """
--- Day 6: Universal Orbit Map ---
You've landed at the Universal Orbit Map facility on Mercury. Because navigation in space often involves transferring between orbits, the orbit maps here are useful for finding efficient routes between, for example, you and Santa. You download a map of the local orbits (your puzzle input).

Except for the universal Center of Mass (COM), every object in space is in orbit around exactly one other object. An orbit looks roughly like this:

                  \
                   \
                    |
                    |
AAA--> o            o <--BBB
                    |
                    |
                   /
                  /
In this diagram, the object BBB is in orbit around AAA. The path that BBB takes around AAA (drawn with lines) is only partly shown. In the map data, this orbital relationship is written AAA)BBB, which means "BBB is in orbit around AAA".

Before you use your map data to plot a course, you need to make sure it wasn't corrupted during the download. To verify maps, the Universal Orbit Map facility uses orbit count checksums - the total number of direct orbits (like the one shown above) and indirect orbits.

Whenever A orbits B and B orbits C, then A indirectly orbits C. This chain can be any number of objects long: if A orbits B, B orbits C, and C orbits D, then A indirectly orbits D.

For example, suppose you have the following map:

COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
Visually, the above map of orbits looks like this:

        G - H       J - K - L
       /           /
COM - B - C - D - E - F
               \
                I
In this visual representation, when two objects are connected by a line, the one on the right directly orbits the one on the left.

Here, we can count the total number of orbits as follows:

D directly orbits C and indirectly orbits B and COM, a total of 3 orbits.
L directly orbits K and indirectly orbits J, E, D, C, B, and COM, a total of 7 orbits.
COM orbits nothing.
The total number of direct and indirect orbits in this example is 42.

What is the total number of direct and indirect orbits in your map data?
"""

let challengeInput = inputFile
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "\n")

print("Part 1\n")

func numberOfIndirectOrbits(from orbits: [String]) -> Int {
    var orbitingAround: [String: [String]] = [:]
    orbits.forEach { orbit in
        let objects = orbit.components(separatedBy: ")")
        guard objects.count == 2, let center = objects.first, let orbiting = objects.last else {
            fatalError("Invalid input \(orbit)")
        }

        if var orbitingObjects = orbitingAround[center] {
            orbitingObjects.append(orbiting)
            orbitingAround[center] = orbitingObjects
        } else {
            orbitingAround[center] = [orbiting]
        }
    }

    var indirectOrbitsCount = 0
    var objectsToVisit = [("COM", 0)]
    while objectsToVisit.count > 0 {
        if let (object, depth) = objectsToVisit.popLast() {
            indirectOrbitsCount += depth
            if let orbitingObjects = orbitingAround[object] {
                objectsToVisit.append(contentsOf: orbitingObjects.map { ($0, depth + 1) })
            }
        }
    }
    return indirectOrbitsCount
}

let testCasesPart1 = [
    ["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L"]: 42
]

testCasesPart1.forEach { orbitsMap, expectedIndirectOrbits in
    let indirectOrbits = numberOfIndirectOrbits(from: orbitsMap)
    if indirectOrbits == expectedIndirectOrbits {
        print("Passed: test case \(orbitsMap) -> \(expectedIndirectOrbits)")
    } else {
        print("Error: expected \(expectedIndirectOrbits) for input \(orbitsMap), got \(indirectOrbits)")
    }
}

measuringExecutionTime {
    let indirectOrbits = numberOfIndirectOrbits(from: challengeInput)
    let expectedIndirectOrbits = 162439
    print("Solution: \(indirectOrbits) -> \(indirectOrbits == expectedIndirectOrbits ? "correct" : "wrong")")
}

_ = """
--- Part Two ---
Now, you just need to figure out how many orbital transfers you (YOU) need to take to get to Santa (SAN).

You start at the object YOU are orbiting; your destination is the object SAN is orbiting. An orbital transfer lets you move from any object to an object orbiting or orbited by that object.

For example, suppose you have the following map:

COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN
Visually, the above map of orbits looks like this:

                          YOU
                         /
        G - H       J - K - L
       /           /
COM - B - C - D - E - F
               \
                I - SAN
In this example, YOU are in orbit around K, and SAN is in orbit around I. To move from K to I, a minimum of 4 orbital transfers are required:

K to J
J to E
E to D
D to I
Afterward, the map of orbits looks like this:

        G - H       J - K - L
       /           /
COM - B - C - D - E - F
               \
                I - SAN
                 \
                  YOU
What is the minimum number of orbital transfers required to move from the object YOU are orbiting to the object SAN is orbiting? (Between the objects they are orbiting - not between YOU and SAN.)
"""

print("\nPart 2\n")

func numberOfOrbitalTransfers(from orbits: [String]) -> Int? {
    var orbitingAround: [String: String] = [:]
    orbits.forEach { orbit in
        let objects = orbit.components(separatedBy: ")")
        guard objects.count == 2, let center = objects.first, let orbiting = objects.last else {
            fatalError("Invalid input \(orbit)")
        }

        orbitingAround[orbiting] = center
    }

    var pathFromYouToCom = ["YOU"]
    var currentObject = "YOU"
    while let nextObject = orbitingAround[currentObject] {
        pathFromYouToCom.append(nextObject)
        currentObject = nextObject
    }

    currentObject = "SAN"
    var orbitalTransfersFromSan = 0
    while let nextObject = orbitingAround[currentObject] {
        orbitalTransfersFromSan += 1
        currentObject = nextObject
        if let orbitalTransfersFromYou = pathFromYouToCom.firstIndex(of: currentObject) {
            return orbitalTransfersFromYou + orbitalTransfersFromSan - 2
        }
    }

    return nil
}

let testCasesPart2 = [
    ["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L", "K)YOU", "I)SAN"]: 4
]

testCasesPart2.forEach { orbitsMap, expectedOrbitalTransfers in
    if let orbitalTransfers = numberOfOrbitalTransfers(from: orbitsMap) {
        if orbitalTransfers == expectedOrbitalTransfers {
            print("Passed: test case \(orbitsMap) -> \(expectedOrbitalTransfers)")
        } else {
            print("Error: expected \(expectedOrbitalTransfers) for input \(orbitsMap), got \(orbitalTransfers)")
        }
    } else {
        print("Error: expected \(expectedOrbitalTransfers) for input \(orbitsMap), got nil")
    }
}

measuringExecutionTime {
    if let orbitalTransfers = numberOfOrbitalTransfers(from: challengeInput) {
        let expectedOrbitalTransfers = 367
        print("Solution: \(orbitalTransfers) -> \(orbitalTransfers == expectedOrbitalTransfers ? "correct" : "wrong")")
    } else {
        print("Solution: nil -> wrong")
    }
}
