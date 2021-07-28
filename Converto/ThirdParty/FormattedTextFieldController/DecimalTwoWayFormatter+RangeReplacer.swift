import Foundation

extension DecimalTwoWayFormatter: RangeReplacer {
    func formattedString(_ string: String) -> String {
        toString(fromString(string))
    }

    func replacingCharacters(string: String, in range: NSRange, with replacement: String) -> (formatted: String, cursorOffset: Int) {
        ReplacingAttempt(
            originalString: string,
            range: range,
            replacement: replacement,
            twoWayFormatter: self
        ).makeResult()
    }
}

private final class ReplacingAttempt {
    private let originalString: String
    private let range: NSRange
    private let replacement: String
    private let twoWayFormatter: DecimalTwoWayFormatter
    private lazy var replacedString: String = originalString
        .replacingCharacters(in: correctedRange, with: correctedReplacement)
        .replacingOccurrences(of: groupingSeparator, with: "")

    init(originalString: String, range: NSRange, replacement: String, twoWayFormatter: DecimalTwoWayFormatter) {
        self.originalString = originalString
        self.range = range
        self.replacement = replacement
        self.twoWayFormatter = twoWayFormatter
    }

    func makeResult() -> (formatted: String, cursorOffset: Int) {
        let formattedResult = self.formattedResult
        return (
            formatted: formattedResult,
            cursorOffset: cursorPositionOffset(formatted: formattedResult)
        )
    }

    private var formattedResult: String {
        resultIfEmpty
            ?? resultIfAddingSecondSeparator
            ?? resultForFractionalInput
            ?? valueFromString.map(twoWayFormatter.toString)
            ?? originalString
    }

    private var resultIfEmpty: String? {
        replacedString.isEmpty ? "" : nil
    }

    private var resultIfAddingSecondSeparator: String? {
        if originalString.contains(decimalSeparator),
           correctedReplacement == decimalSeparator {
            return originalString
        }
        return nil
    }

    private var resultForFractionalInput: String? {
        if replacedString.contains(decimalSeparator) {
            if let count = replacedString.components(separatedBy: decimalSeparator).last?.count,
               count > twoWayFormatter.formatter.maximumFractionDigits {
                return originalString
            }
            return resultForLastSymbol
        }
        return nil
    }

    private var resultForLastSymbol: String? {
        let lastSymbol = replacedString.last.map(String.init)
        if lastSymbol == decimalSeparator {
            return (valueFromString.map(twoWayFormatter.toString) ?? originalString) + decimalSeparator
        } else if lastSymbol == "0", let tail = replacedString.components(separatedBy: decimalSeparator).last {
            return ((valueFromString?.whole).map(twoWayFormatter.toString) ?? originalString) + decimalSeparator + tail
        }
        return nil
    }

    private func cursorPositionOffset(formatted: String) -> Int {
        if originalString == formatted { return correctedRange.location }
        if correctedRange.location == originalString.count { return formatted.count }

        var offset = max(0, correctedRange.upperBound + formatted.count - originalString.count)
        if let swiftRange = formatted.swiftRange(range: .init(location: max(0, offset - 1), length: 1)),
           formatted[swiftRange] == groupingSeparator {
            offset -= 1
        }
        return offset
    }

    private var valueFromString: Decimal? {
        twoWayFormatter.fromString(replacedString)
    }

    private var groupingSeparator: String {
        twoWayFormatter.formatter.groupingSeparator
    }

    private var decimalSeparator: String {
        twoWayFormatter.formatter.decimalSeparator
    }

    private var correctedRange: NSRange {
        var range = self.range
        if let swiftRange = originalString.swiftRange(range: range),
           originalString[swiftRange] == groupingSeparator,
           replacement == "" {
            range.location -= 1
        }
        return range
    }

    private var correctedReplacement: String {
        if replacement == "," || replacement == "." {
            return decimalSeparator
        }
        return replacement
    }
}
