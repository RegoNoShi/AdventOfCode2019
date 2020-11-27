import Foundation

public extension String {
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

public func loadInputFile(_ fileName: String = "input.txt") -> String {
    let inputFilePath: String

    if Bundle.allBundles.contains(where: { ($0.bundleIdentifier ?? "").hasPrefix("com.apple.dt.") }) {
        // Running in Playground
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: nil) else {
            fatalError("Unable to locate input file")
        }
        inputFilePath = filePath
    } else {
        // Not running in Playground
        inputFilePath = "\(FileManager.default.currentDirectoryPath)/\(fileName)"
    }

    guard let escapedInputFilePath = inputFilePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
          let inputFileUrl = URL(string: "file://\(escapedInputFilePath)"),
          let inputFile = try? String(contentsOf: inputFileUrl) else {
        fatalError("Unable to load input file")
    }

    return inputFile
}
