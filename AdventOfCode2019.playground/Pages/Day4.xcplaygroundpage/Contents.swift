//: [Previous](@previous)

import Foundation

print("Day 4\n")

"""
--- Day 4: Secure Container ---
You arrive at the Venus fuel depot only to discover it's protected by a password. The Elves had written the password on a sticky note, but someone threw it out.

However, they do remember a few key facts about the password:

It is a six-digit number.
The value is within the range given in your puzzle input.
Two adjacent digits are the same (like 22 in 122345).
Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).
Other than the range rule, the following are true:

111111 meets these criteria (double 11, never decreases).
223450 does not meet these criteria (decreasing pair of digits 50).
123789 does not meet these criteria (no double).
How many different passwords within the range given in your puzzle input meet these criteria?
"""

guard let filePath = Bundle.main.path(forResource:"input", ofType: "txt"),
      let fileData = FileManager.default.contents(atPath: filePath),
      let fileContent = String(data: fileData, encoding:String.Encoding.utf8) else {
    fatalError("Unable to load input file")
}

let challengeInput = fileContent
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "-")
    .compactMap { Int($0) }

print("Part 1\n")

func isValidCode(_ code: String) -> Bool {
    var previousChar: Character = "#"
    var double = false
    for char in code {
        if char < previousChar {
            return false
        } else if char == previousChar {
            double = true
        }
        previousChar = char
    }
    return double
}

let testCasesPart1 = [
    "122345": true,
    "111123": true,
    "135679": false,
    "111111": true,
    "223450": false,
    "123789": false,
]

testCasesPart1.forEach { code, expectedIsValid in
    let isValid = isValidCode(code)
    if isValid == expectedIsValid {
        print("Passed: test case \(code) -> \(expectedIsValid)")
    } else {
        print("Error: expected \(expectedIsValid) for input \(code), got \(isValid)")
    }
}

func validCodesInRange(_ input: [Int]) -> Int {
    guard input.count == 2, let minCode = input.first, let maxCode = input.last else {
        fatalError("Got bad range")
    }

    var validCodes = 0
    for code in minCode ... maxCode {
        if isValidCode(String(code)) {
            validCodes += 1
        }
    }

    return validCodes
}

let startPart1 = Date()
let outputPart1 = validCodesInRange(challengeInput)
let expectedOutputPart1 = 1610
print("Solution: \(outputPart1) -> \(outputPart1 == expectedOutputPart1 ? "correct" : "wrong")")
print("Time elapsed: \(startPart1.distance(to: Date()))")

"""
--- Part Two ---
An Elf just remembered one more important detail: the two adjacent matching digits are not part of a larger group of matching digits.

Given this additional criterion, but still ignoring the range rule, the following are now true:

112233 meets these criteria because the digits never decrease and all repeated digits are exactly two digits long.
123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444).
111122 meets the criteria (even though 1 is repeated more than twice, it still contains a double 22).
How many different passwords within the range given in your puzzle input meet all of the criteria?
"""

print("\nPart 2\n")

func isValidCodePart2(_ code: String) -> Bool {
    var previousChar: Character = "#"
    var sequence = 0
    var double = false
    for char in code {
        if char < previousChar {
            return false
        } else if char == previousChar {
            sequence += 1
        } else {
            if sequence == 2 {
                double = true
            }
            sequence = 1
        }
        previousChar = char
    }
    return double || sequence == 2
}

let testCasesPart2 = [
    "122345": true,
    "111123": false,
    "135679": false,
    "111111": false,
    "223450": false,
    "123789": false,
    "112233": true,
    "123444": false,
    "111122": true,
]

testCasesPart2.forEach { code, expectedIsValid in
    let isValid = isValidCodePart2(code)
    if isValid == expectedIsValid {
        print("Passed: test case \(code) -> \(expectedIsValid)")
    } else {
        print("Error: expected \(expectedIsValid) for input \(code), got \(isValid)")
    }
}

func validCodesInRangePart2(_ input: [Int]) -> Int {
    guard input.count == 2, let minCode = input.first, let maxCode = input.last else {
        fatalError("Got bad range")
    }

    var validCodes = 0
    for code in minCode ... maxCode {
        if isValidCodePart2(String(code)) {
            validCodes += 1
        }
    }

    return validCodes
}

let startPart2 = Date()
let outputPart2 = validCodesInRangePart2(challengeInput)
let expectedOutputPart2 = 1104
print("Solution: \(outputPart2) -> \(outputPart2 == expectedOutputPart2 ? "correct" : "wrong")")
print("Time elapsed: \(startPart2.distance(to: Date()))")

//: [Next](@next)
