import Foundation

extension DecimalTwoWayFormatter: RangeReplacer {
    public func formattedString(_ string: String) -> String {
        toString(fromString(string))
    }

    public func replacingCharacters(string: String, in range: NSRange, with replacement: String) -> (formatted: String, cursorOffset: Int) {
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

private extension Decimal {
    var whole: Decimal { self < 0 ? rounded(roundingMode: .up) : rounded(roundingMode: .down) }
}

public extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    func rounded(scale: Int = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var amountBefore = self
        var result: Decimal = self
        NSDecimalRound(&result, &amountBefore, scale, roundingMode)
        return result
    }
}


public extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return regularСheck(emailRegEx)
    }

    var isValidGiftCard: Bool { regularСheck("^[a-zA-Z0-9-]+$") }

    var isContainNumder: Bool { regularСheck(".*[0-9]+.*") }

    var isContainSpecialCharacter: Bool { regularСheck(".*[!&^%$#@()/]+.*") }

    var isContainUppercase: Bool { regularСheck(".*[A-Z]+.*") }

    var isContainLowercase: Bool { regularСheck(".*[a-z]+.*") }

    var isNotEmpty: Bool { !isEmpty }

    private func regularСheck(_ regEx: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: regEx) else {
            return false
        }
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }

    func swiftRange(range: NSRange) -> Range<String.Index>? {
        guard range.location <= count else { return nil }
        let maxLength = count
        var limitedRange = NSRange(location: range.location, length: range.length)
        if range.location + range.length > maxLength {
            limitedRange.length = count - range.location
        }
        return Range(limitedRange, in: self)
    }

    func replacingCharacters(in range: NSRange, with replacement: String) -> String {
        guard let swiftRange = swiftRange(range: range) else { return self }
        return replacingCharacters(in: swiftRange, with: replacement)
    }

    func withPrefix(_ prefix: String, separator: String = " ") -> String {
        [prefix, self].joined(separator: separator)
    }
}
