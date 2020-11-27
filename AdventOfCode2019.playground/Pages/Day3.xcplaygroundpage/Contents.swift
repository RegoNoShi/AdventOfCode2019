//: [Previous](@previous)

import Foundation

print("Day 3\n")

"""
--- Day 3: Crossed Wires ---
The gravity assist was successful, and you're well on your way to the Venus refuelling station. During the rush back on Earth, the fuel management system wasn't completely installed, so that's next on the priority list.

Opening the front panel reveals a jumble of wires. Specifically, two wires are connected to a central port and extend outward on a grid. You trace the path each wire takes as it leaves the central port, one wire per line of text (your puzzle input).

The wires twist and turn, but the two wires occasionally cross paths. To fix the circuit, you need to find the intersection point closest to the central port. Because the wires are on a grid, use the Manhattan distance for this measurement. While the wires do technically cross right at the central port where they both start, this point does not count, nor does a wire count as crossing with itself.

For example, if the first wire's path is R8,U5,L5,D3, then starting from the central port (o), it goes right 8, up 5, left 5, and finally down 3:

...........
...........
...........
....+----+.
....|....|.
....|....|.
....|....|.
.........|.
.o-------+.
...........
Then, if the second wire's path is U7,R6,D4,L4, it goes up 7, right 6, down 4, and left 4:

...........
.+-----+...
.|.....|...
.|..+--X-+.
.|..|..|.|.
.|.-X--+.|.
.|..|....|.
.|.......|.
.o-------+.
...........
These wires cross at two locations (marked X), but the lower-left one is closer to the central port: its distance is 3 + 3 = 6.

Here are a few more examples:

R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83 = distance 159
R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7 = distance 135
What is the Manhattan distance from the central port to the closest intersection?
"""

guard let filePath = Bundle.main.path(forResource:"input", ofType: "txt"),
      let fileData = FileManager.default.contents(atPath: filePath),
      let fileContent = String(data: fileData, encoding:String.Encoding.utf8) else {
    fatalError("Unable to load input file")
}

let challengeInput = Array(fileContent
    .components(separatedBy: "\n")
    .prefix(2)
)

print("Part 1\n")

struct Point: Hashable {
    let x, y: Int

    static let origin = Point(x: 0, y: 0)

    func manhattanDistance(from point: Point) -> Int {
        max(x, point.x) - min(x, point.x) + max(y, point.y) - min(y, point.y)
    }
}

extension String {
    var length: Int {
        count
    }

    subscript (i: Int) -> String {
        self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension Int {
    func range(to int: Int) -> [Int] {
        self <= int ?
            Array(self ... int) :
            Array(int ... self).reversed()
    }
}

struct ManhattanSegment: Hashable {
    let start, end: Point

    init?(start: Point, end: Point) {
        guard start.x == end.x || start.y == end.y else { return nil }
        self.start = start
        self.end = end
    }

    private var isVertical: Bool {
        start.x == end.x
    }

    var points: [Point] {
        isVertical ?
            start.y.range(to: end.y).map { y in Point(x: start.x, y: y) } :
            start.x.range(to: end.x).map { x in Point(x: x, y: start.y) }
    }

    func intersectionsWithSegment(_ segment: ManhattanSegment) -> Set<Point>? {
        guard min(start.x, end.x) <= max(segment.start.x, segment.end.x),
              max(start.x, end.x) >= min(segment.start.x, segment.end.x),
              min(start.y, end.y) <= max(segment.start.y, segment.end.y),
              max(start.y, end.y) >= min(segment.start.y, segment.end.y) else {
            return nil
        }

        if isVertical {
            if segment.isVertical {
                return start.x == segment.start.x ? Set(points).intersection(segment.points) : nil
            } else {
                return Set([Point(x: start.x, y: segment.start.y)])
            }
        } else {
            if segment.isVertical {
                return Set([Point(x: segment.start.x, y: start.y)])
            } else {
                return start.y == segment.start.y ? Set(points).intersection(segment.points) : nil
            }
        }
    }
}

func segmentsForWire(_ wire: String, startingFrom origin: Point) -> [ManhattanSegment] {
    var currentPosition = origin
    var segments = [ManhattanSegment]()
    wire.components(separatedBy: ",").forEach { direction in
        let diff: (x: Int, y: Int)
        switch direction[0] {
        case "R":
            diff = (x: 1, y: 0)
        case "L":
            diff = (x: -1, y: 0)
        case "U":
            diff = (x: 0, y: 1)
        case "D":
            diff = (x: 0, y: -1)
        default:
            fatalError("Invalid direction \(direction[0])")
        }

        guard let steps = Int(direction.substring(fromIndex: 1)) else {
            fatalError("Invalid steps \(direction.substring(fromIndex: 1))")
        }

        let nextPosition = Point(x: currentPosition.x + diff.x * steps, y: currentPosition.y + diff.y * steps)

        guard let segment = ManhattanSegment(start: currentPosition, end: nextPosition) else {
            fatalError("Invalid manhattan segment \(currentPosition) -> \(nextPosition)")
        }

        segments.append(segment)
        currentPosition = nextPosition
    }
    return segments
}

func minDistanceFromOriginToIntersection(_ wires: [String]) -> Int {
    guard wires.count == 2, let firstWire = wires.first, let secondWire = wires.last else {
        fatalError("Got bad wires")
    }

    let segmentsWire1 = segmentsForWire(firstWire, startingFrom: Point.origin)
    let segmentsWire2 = segmentsForWire(secondWire, startingFrom: Point.origin)

    var minDistance = Int.max
    segmentsWire1.forEach { segment1 in
        segmentsWire2.forEach { segment2 in
            segment1.intersectionsWithSegment(segment2)?.forEach { intersection in
                if intersection != Point.origin || segment2.start != Point.origin {
                    let distance = Point.origin.manhattanDistance(from: intersection)
                    if distance < minDistance {
                        minDistance = distance
                    }
                }
            }
        }
    }

    return minDistance
}

let testCasesPart1 = [
    ["R8,U5,L5,D3", "U7,R6,D4,L4"]: 6,
    ["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"]: 159,
    ["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"]: 135,
]

testCasesPart1.forEach { wires, expectedDistance in
    let distance = minDistanceFromOriginToIntersection(wires)
    if distance == expectedDistance {
        print("Passed: test case \(wires) -> \(expectedDistance)")
    } else {
        print("Error: expected \(expectedDistance) for input \(wires), got \(distance)")
    }
}

var start = Date()
let distancePart1 = minDistanceFromOriginToIntersection(challengeInput)
let expectedDistancePart1 = 308
print("Solution: \(distancePart1) -> \(distancePart1 == expectedDistancePart1 ? "correct" : "wrong")")
print("Time elapsed: \(start.distance(to: Date()))")

"""
--- Part Two ---
It turns out that this circuit is very timing-sensitive; you actually need to minimize the signal delay.

To do this, calculate the number of steps each wire takes to reach each intersection; choose the intersection where the sum of both wires' steps is lowest. If a wire visits a position on the grid multiple times, use the steps value from the first time it visits that position when calculating the total value of a specific intersection.

The number of steps a wire takes is the total number of grid squares the wire has entered to get to that location, including the intersection being considered. Again consider the example from above:

...........
.+-----+...
.|.....|...
.|..+--X-+.
.|..|..|.|.
.|.-X--+.|.
.|..|....|.
.|.......|.
.o-------+.
...........
In the above example, the intersection closest to the central port is reached after 8+5+5+2 = 20 steps by the first wire and 7+6+4+3 = 20 steps by the second wire for a total of 20+20 = 40 steps.

However, the top-right intersection is better: the first wire takes only 8+5+2 = 15 and the second wire takes only 7+6+2 = 15, a total of 15+15 = 30 steps.

Here are the best steps for the extra examples from above:

R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83 = 610 steps
R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7 = 410 steps
What is the fewest combined steps the wires must take to reach an intersection?
"""

print("\nPart 2\n")

extension ManhattanSegment {
    var length: Int {
        start.manhattanDistance(from: end)
    }

    func intersectsWith(_ point: Point) -> Bool {
        points.contains(point)
    }

    func lengthToPoint(_ point: Point) -> Int? {
        points.firstIndex(of: point)
    }
}

func minStepsFromOriginToIntersection(_ wires: [String]) -> Int {
    guard wires.count == 2, let firstWire = wires.first, let secondWire = wires.last else {
        fatalError("Got bad wires")
    }

    let segmentsWire1 = segmentsForWire(firstWire, startingFrom: Point.origin)
    let segmentsWire2 = segmentsForWire(secondWire, startingFrom: Point.origin)

    var minSteps = Int.max
    var wire1Steps = 0
    segmentsWire1.forEach { segment1 in
        var wire2Steps = 0
        segmentsWire2.forEach { segment2 in
            if var intersections = segment1.intersectionsWithSegment(segment2) {
                if segment1.start == Point.origin && segment2.start == Point.origin {
                    intersections.remove(Point.origin)
                }

                intersections.forEach { intersection in
                    guard let stepsToIntersectionWire1 = segment1.lengthToPoint(intersection),
                          let stepsToIntersectionWire2 = segment2.lengthToPoint(intersection) else {
                        fatalError("Got intersection not on the segments")
                    }
                    let currentSteps = wire1Steps + wire2Steps + stepsToIntersectionWire1 + stepsToIntersectionWire2
                    if currentSteps < minSteps {
                        minSteps = currentSteps
                    }
                }
            }
            wire2Steps += segment2.length
        }
        wire1Steps += segment1.length
    }

    return minSteps
}

let testCasesPart2 = [
    ["R8,U5,L5,D3", "U7,R6,D4,L4"]: 30,
    ["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"]: 610,
    ["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"]: 410,
]

testCasesPart2.forEach { wires, expectedDistance in
    let distance = minStepsFromOriginToIntersection(wires)
    if distance == expectedDistance {
        print("Passed: test case \(wires) -> \(expectedDistance)")
    } else {
        print("Error: expected \(expectedDistance) for input \(wires), got \(distance)")
    }
}

start = Date()
let stepsPart2 = minStepsFromOriginToIntersection(challengeInput)
let expectedStepsPart2 = 12934
print("Solution: \(stepsPart2) -> \(stepsPart2 == expectedStepsPart2 ? "correct" : "wrong")")
print("Time elapsed: \(start.distance(to: Date()))")

//: [Next](@next)
