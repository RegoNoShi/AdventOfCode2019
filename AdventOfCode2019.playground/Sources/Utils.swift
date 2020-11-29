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

public func measuringExecutionTime(of block: () -> Void) {
  let start = Date()
  block()
  print("Time elapsed: \(String(format: "%.5f", start.distance(to: Date()))) seconds")
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

// Permutations https://www.objc.io/blog/2014/12/08/functional-snippet-10-permutations/
public extension Array {
    func chopped() -> (Element, [Element])? {
        guard let x = first else { return nil }
        return (x, Array(suffix(from: 1)))
    }

    func interleaving(_ element: Element) -> [[Element]] {
        guard let (head, rest) = chopped() else { return [[element]] }
        return [[element] + self] + rest.interleaving(element).map { [head] + $0 }
    }

    var permutations: [[Element]] {
        guard let (head, rest) = chopped() else { return [[]] }
        return rest.permutations.flatMap { $0.interleaving(head) }
    }
}
