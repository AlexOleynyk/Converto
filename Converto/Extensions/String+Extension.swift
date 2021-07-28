import Foundation

public extension String {
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
}
