//: [Previous](@previous)

import Foundation

print("Day N\n")

"""
"""

guard let filePath = Bundle.main.path(forResource:"input", ofType: "txt"),
      let fileData = FileManager.default.contents(atPath: filePath),
      let fileContent = String(data: fileData, encoding:String.Encoding.utf8) else {
    fatalError("Unable to load input file")
}

let challengeInput = fileContent
    .components(separatedBy: ",")
    .compactMap { Int($0) }

print("Part 1\n")

let testCasesPart1 = [
    [1]: 1
]

func solve(_ input: [Int]) -> Int {
    return input[0]
}

testCasesPart1.forEach { input, expectedOutput in
    let output = solve(input)
    if output == expectedOutput {
        print("Passed: test case \(input) -> \(expectedOutput)")
    } else {
        print("Error: expected \(expectedOutput) for program \(input), got \(output)")
    }
}

let outputPart1 = solve(challengeInput)
let expectedOutputPart1 = 42
print("Solution: \(outputPart1) -> \(outputPart1 == expectedOutputPart1 ? "correct" : "wrong")")

"""
"""

print("\nPart 2\n")

let testCasesPart2 = [
    [1]: 1
]

func solve2(_ input: [Int]) -> Int {
    return input[0]
}

testCasesPart2.forEach { input, expectedOutput in
    let output = solve2(input)
    if output == expectedOutput {
        print("Passed: test case \(input) -> \(expectedOutput)")
    } else {
        print("Error: expected \(expectedOutput) for program \(input), got \(output)")
    }
}

let outputPart2 = solve2(challengeInput)
let expectedOutputPart2 = 42
print("Solution: \(outputPart2) -> \(outputPart2 == expectedOutputPart2 ? "correct" : "wrong")")

//: [Next](@next)
