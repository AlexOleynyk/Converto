import Foundation

public struct DecimalTwoWayFormatter: TwoWayFormatter {

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    public init(
        groupingSeparator: String? = nil,
        decimalSeparator: String? = nil,
        localeId: String? = nil
    ) {
        groupingSeparator.map { formatter.groupingSeparator = $0 }
        decimalSeparator.map { formatter.decimalSeparator = $0 }
        localeId.map { formatter.locale = Locale(identifier: $0) }
    }

    public func toString(_ decimal: Decimal?) -> String {
        formatter.string(for: decimal) ?? ""
    }

    public func fromString(_ string: String) -> Decimal? {
        let rawString = string.replacingOccurrences(of: formatter.groupingSeparator, with: "")
            .replacingOccurrences(of: formatter.decimalSeparator, with: ".")
        return Decimal(string: rawString)
    }
}
