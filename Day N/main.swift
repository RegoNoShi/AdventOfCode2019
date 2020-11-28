import Foundation

let inputFile = loadInputFile()

print("Day N\n")

_ = """
"""

let challengeInput = inputFile
    .components(separatedBy: ",")
    .compactMap { Int($0) }

print("Part 1\n")

func solvePart1(_ input: [Int]) -> Int {
    return input[0]
}

let testCasesPart1 = [
    [1]: 1
]

testCasesPart1.forEach { input, expectedOutput in
    let output = solvePart1(input)
    if output == expectedOutput {
        print("Passed: test case \(input) -> \(expectedOutput)")
    } else {
        print("Error: expected \(expectedOutput) for input \(input), got \(output)")
    }
}

measuringExecutionTime {
    let outputPart1 = solvePart1(challengeInput)
    let expectedOutputPart1 = 42
    print("Solution: \(outputPart1) -> \(outputPart1 == expectedOutputPart1 ? "correct" : "wrong")")
}

_ = """
"""

print("\nPart 2\n")

func solvePart2(_ input: [Int]) -> Int {
    return input[0]
}

let testCasesPart2 = [
    [1]: 1
]

testCasesPart2.forEach { input, expectedOutput in
    let output = solvePart2(input)
    if output == expectedOutput {
        print("Passed: test case \(input) -> \(expectedOutput)")
    } else {
        print("Error: expected \(expectedOutput) for input \(input), got \(output)")
    }
}

measuringExecutionTime {
    let outputPart2 = solvePart2(challengeInput)
    let expectedOutputPart2 = 42
    print("Solution: \(outputPart2) -> \(outputPart2 == expectedOutputPart2 ? "correct" : "wrong")")
}
