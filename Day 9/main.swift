import Foundation

let inputFile = loadInputFile()

print("Day 9\n")

_ = """
--- Day 9: Sensor Boost ---
You've just said goodbye to the rebooted rover and left Mars when you receive a faint distress signal coming from the asteroid belt. It must be the Ceres monitoring station!

In order to lock on to the signal, you'll need to boost your sensors. The Elves send up the latest BOOST program - Basic Operation Of System Test.

While BOOST (your puzzle input) is capable of boosting your sensors, for tenuous safety reasons, it refuses to do so until the computer it runs on passes some checks to demonstrate it is a complete Intcode computer.

Your existing Intcode computer is missing one key feature: it needs support for parameters in relative mode.

Parameters in mode 2, relative mode, behave very similarly to parameters in position mode: the parameter is interpreted as a position. Like position mode, parameters in relative mode can be read from or written to.

The important difference is that relative mode parameters don't count from address 0. Instead, they count from a value called the relative base. The relative base starts at 0.

The address a relative mode parameter refers to is itself plus the current relative base. When the relative base is 0, relative mode parameters and position mode parameters with the same value refer to the same address.

For example, given a relative base of 50, a relative mode parameter of -7 refers to memory address 50 + -7 = 43.

The relative base is modified with the relative base offset instruction:

Opcode 9 adjusts the relative base by the value of its only parameter. The relative base increases (or decreases, if the value is negative) by the value of the parameter.
For example, if the relative base is 2000, then after the instruction 109,19, the relative base would be 2019. If the next instruction were 204,-34, then the value at address 1985 would be output.

Your Intcode computer will also need a few other capabilities:

The computer's available memory should be much larger than the initial program. Memory beyond the initial program starts with the value 0 and can be read or written like any other memory. (It is invalid to try to access memory at a negative address, though.)
The computer should have support for large numbers. Some instructions near the beginning of the BOOST program will verify this capability.
Here are some example programs that use these features:

109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99 takes no input and produces a copy of itself as output.
1102,34915192,34915192,7,4,7,99,0 should output a 16-digit number.
104,1125899906842624,99 should output the large number in the middle.
The BOOST program will ask for a single input; run it in test mode by providing it the value 1. It will perform a series of checks on each opcode, output any opcodes (and the associated parameter modes) that seem to be functioning incorrectly, and finally output a BOOST keycode.

Once your Intcode computer is fully functional, the BOOST program should report no malfunctioning opcodes when run in test mode; it should only output a single value, the BOOST keycode. What BOOST keycode does it produce?
"""

let challengeInput = inputFile
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: ",")
    .compactMap { Int($0) }

print("Part 1\n")

enum ParameterMode: Int {
    case position = 0
    case immediate = 1
    case relative = 2
}

extension Int {
    var operationCode: Int {
        self % 100
    }

    func parameterMode(at offset: Int) -> ParameterMode {
        let str = String(self)

        if str.count < offset {
            return .position
        }

        guard let firstParameterCode = Int(str[str.count - offset]),
              let parameterMode = ParameterMode(rawValue: firstParameterCode) else {
            fatalError("Unknown parameter mode \(self)")
        }
        return parameterMode
    }
}

class IntCodeProgram {
    private var state: [Int]
    private var inputs: [Int]
    private var outputs = [Int]()
    private var nextInput = 0
    private var pc = 0
    private var relativeBase = 0

    init(program: [Int], input: Int) {
        state = program
        inputs = [input]
    }

    private func currentParameterAt(offset: Int) -> Int {
        switch state[pc].parameterMode(at: offset + 2) {
        case .immediate:
            ensureEnoughMemory(for: pc + offset)
            return state[pc + offset]
        case .position:
            ensureEnoughMemory(for: pc + offset)
            ensureEnoughMemory(for: state[pc + offset])
            return state[state[pc + offset]]
        case .relative:
            ensureEnoughMemory(for: pc + offset)
            ensureEnoughMemory(for: state[pc + offset] + relativeBase)
            return state[state[pc + offset] + relativeBase]
        }
    }

    private func ensureEnoughMemory(for position: Int) {
        if position >= state.count {
            state.append(contentsOf: Array(repeating: 0, count: position - state.count + 1))
        }
    }

    private func write(_ value: Int, at offset: Int) {
        switch state[pc].parameterMode(at: offset + 2) {
        case .immediate:
            fatalError("Cannot write in immediate mode")
        case .position:
            ensureEnoughMemory(for: pc + offset)
            ensureEnoughMemory(for: state[pc + offset])
            state[state[pc + offset]] = value
        case .relative:
            ensureEnoughMemory(for: pc + offset)
            ensureEnoughMemory(for: state[pc + offset] + relativeBase)
            state[state[pc + offset] + relativeBase] = value
        }
    }

    private var firstParameter: Int {
        get {
            currentParameterAt(offset: 1)
        }
        set {
            write(newValue, at: 1)
        }
    }

    private var secondParameter: Int {
        get {
            currentParameterAt(offset: 2)
        }
        set {
            write(newValue, at: 2)
        }
    }

    private var thirdParameter: Int {
        get {
            currentParameterAt(offset: 3)
        }
        set {
            write(newValue, at: 3)
        }
    }

    func execute() -> [Int] {
        while state[pc].operationCode != 99 {
            switch state[pc].operationCode {
            case 1:
                thirdParameter = firstParameter + secondParameter
                pc += 4
            case 2:
                thirdParameter = firstParameter * secondParameter
                pc += 4
            case 3:
                guard inputs.count > nextInput else {
                    fatalError("Missing input value")
                }
                firstParameter = inputs[nextInput]
                nextInput += 1
                pc += 2
            case 4:
                outputs.append(firstParameter)
                pc += 2
            case 5:
                pc = firstParameter != 0 ? secondParameter : pc + 3
            case 6:
                pc = firstParameter == 0 ? secondParameter : pc + 3
            case 7:
                thirdParameter = firstParameter < secondParameter ? 1 : 0
                pc += 4
            case 8:
                thirdParameter = firstParameter == secondParameter ? 1 : 0
                pc += 4
            case 9:
                relativeBase += firstParameter
                pc += 2
            default:
                fatalError("Found unknown opcode \(state[pc])")
            }
        }
        return outputs
    }
}

let testCasesPart1 = [
    [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]: [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99],
    [104, 1125899906842624, 99]: [1125899906842624],
    [1102, 34915192, 34915192, 7, 4, 7, 99, 0]: [1219070632396864],
]

testCasesPart1.forEach { program, expectedOutput in
    let output = IntCodeProgram(program: program, input: 1).execute()
    if output == expectedOutput {
        print("Passed: test case \(program) -> \(expectedOutput)")
    } else {
        print("Error: expected \(expectedOutput) for input \(program), got \(output)")
    }
}

measuringExecutionTime {
    let outputPart1 = IntCodeProgram(program: challengeInput, input: 1).execute()
    let expectedOutputPart1 = [3280416268]
    print("Solution: \(outputPart1) -> \(outputPart1 == expectedOutputPart1 ? "correct" : "wrong")")
}

_ = """
--- Part Two ---
You now have a complete Intcode computer.

Finally, you can lock on to the Ceres distress signal! You just need to boost your sensors using the BOOST program.

The program runs in sensor boost mode by providing the input instruction the value 2. Once run, it will boost the sensors automatically, but it might take a few seconds to complete the operation on slower hardware. In sensor boost mode, the program will output a single value: the coordinates of the distress signal.

Run the BOOST program in sensor boost mode. What are the coordinates of the distress signal?
"""

print("\nPart 2\n")

measuringExecutionTime {
    let outputPart1 = IntCodeProgram(program: challengeInput, input: 2).execute()
    let expectedOutputPart1 = [80210]
    print("Solution: \(outputPart1) -> \(outputPart1 == expectedOutputPart1 ? "correct" : "wrong")")
}
