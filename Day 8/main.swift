import Foundation

let inputFile = loadInputFile()

print("Day 8\n")

_ = """
--- Day 8: Space Image Format ---
The Elves' spirits are lifted when they realize you have an opportunity to reboot one of their Mars rovers, and so they are curious if you would spend a brief sojourn on Mars. You land your ship near the rover.

When you reach the rover, you discover that it's already in the process of rebooting! It's just waiting for someone to enter a BIOS password. The Elf responsible for the rover takes a picture of the password (your puzzle input) and sends it to you via the Digital Sending Network.

Unfortunately, images sent via the Digital Sending Network aren't encoded with any normal encoding; instead, they're encoded in a special Space Image Format. None of the Elves seem to remember why this is the case. They send you the instructions to decode it.

Images are sent as a series of digits that each represent the color of a single pixel. The digits fill each row of the image left-to-right, then move downward to the next row, filling rows top-to-bottom until every pixel of the image is filled.

Each image actually consists of a series of identically-sized layers that are filled in this way. So, the first digit corresponds to the top-left pixel of the first layer, the second digit corresponds to the pixel to the right of that on the same layer, and so on until the last digit, which corresponds to the bottom-right pixel of the last layer.

For example, given an image 3 pixels wide and 2 pixels tall, the image data 123456789012 corresponds to the following image layers:

Layer 1: 123
         456

Layer 2: 789
         012
The image you received is 25 pixels wide and 6 pixels tall.

To make sure the image wasn't corrupted during transmission, the Elves would like you to find the layer that contains the fewest 0 digits. On that layer, what is the number of 1 digits multiplied by the number of 2 digits?
"""

let challengeInput = inputFile
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .compactMap { Int(String($0)) }
let imageSize = [25, 6]

print("Part 1\n")

func solvePart1(_ image: [Int], _ size: [Int]) -> Int {
    let layerPixels = size[0] * size[1]
    let layersCount = image.count / layerPixels
    var minZeros = layerPixels
    var output = 0
    var layers: [[Int]] = Array(repeating: Array(repeating: 0, count: 10), count: layersCount)
    for (pos, pixel) in image.enumerated() {
        layers[pos / layerPixels][pixel] += 1
        if (pos + 1) % layerPixels == 0 {
            if layers[pos / layerPixels][0] < minZeros {
                minZeros = layers[pos / layerPixels][0]
                output = layers[pos / layerPixels][1] * layers[pos / layerPixels][2]
            }
        }
    }
    return output
}

let testCasesPart1 = [
    ([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2], [3, 2], 1),
    ([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [3, 2], 0),
    ([1, 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0], [3, 2], 4),
    ([0, 0, 0, 0, 0, 0, 9, 9, 9, 9, 9, 9], [3, 2], 0),
]

testCasesPart1.forEach { (image, size, expectedOutput) in
    let output = solvePart1(image, size)
    if output == expectedOutput {
        print("Passed: test case \(image) -> \(expectedOutput)")
    } else {
        print("Error: expected \(expectedOutput) for input \(image), got \(output)")
    }
}

measuringExecutionTime {
    let outputPart1 = solvePart1(challengeInput, imageSize)
    let expectedOutputPart1 = 1820
    print("Solution: \(outputPart1) -> \(outputPart1 == expectedOutputPart1 ? "correct" : "wrong")")
}

_ = """
--- Part Two ---
Now you're ready to decode the image. The image is rendered by stacking the layers and aligning the pixels with the same positions in each layer. The digits indicate the color of the corresponding pixel: 0 is black, 1 is white, and 2 is transparent.

The layers are rendered with the first layer in front and the last layer in back. So, if a given position has a transparent pixel in the first and second layers, a black pixel in the third layer, and a white pixel in the fourth layer, the final image would have a black pixel at that position.

For example, given an image 2 pixels wide and 2 pixels tall, the image data 0222112222120000 corresponds to the following image layers:

Layer 1: 02
         22

Layer 2: 11
         22

Layer 3: 22
         12

Layer 4: 00
         00
Then, the full image can be found by determining the top visible pixel in each position:

The top-left pixel is black because the top layer is 0.
The top-right pixel is white because the top layer is 2 (transparent), but the second layer is 1.
The bottom-left pixel is white because the top two layers are 2, but the third layer is 1.
The bottom-right pixel is black because the only visible pixel in that position is 0 (from layer 4).
So, the final image looks like this:

01
10
What message is produced after decoding your image?
"""

print("\nPart 2\n")

func solvePart2(_ image: [Int], _ size: [Int]) -> [Int] {
    let layerPixels = size[0] * size[1]
    var finalImage = Array(repeating: 2, count: layerPixels)
    for (pos, pixel) in image.enumerated() {
        let posInLayer = pos % layerPixels
        if finalImage[posInLayer] == 2 {
            finalImage[posInLayer] = pixel
        }
    }
    return finalImage
}

func printOutput(_ image: [Int], _ size: [Int]) {
    for r in 0 ..< size[1] {
        var row = ""
        for c in 0 ..< size[0] {
            row += image[r * size[0] + c] == 0 ? " " : "#"
        }
        print(row)
    }
}

let testCasesPart2 = [
    ([0, 2, 2, 2, 1, 1, 2, 2, 2, 2, 1, 2, 0, 0, 0, 0], [2, 2], [0, 1, 1, 0]),
]

testCasesPart2.forEach { (image, size, expectedOutput) in
    let output = solvePart2(image, size)
    if output == expectedOutput {
        print("Passed: test case \(image) -> \(expectedOutput)")
    } else {
        print("Error: expected \(expectedOutput) for input \(image), got \(output)")
    }
}

measuringExecutionTime {
    let outputPart2 = solvePart2(challengeInput, imageSize)
    let expectedOutputPart2 = [1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0]
    print("Expected solution: ZUKCJ -> \(outputPart2 == expectedOutputPart2 ? "correct" : "wrong")")
    printOutput(outputPart2, imageSize)
}
