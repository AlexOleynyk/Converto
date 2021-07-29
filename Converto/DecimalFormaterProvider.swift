import Foundation
import ConvertoDomain

final class DecimalFormaterProvider {
    private let defaultFormatter = DecimalTwoWayFormatter()
    private let noFractionFormatter: DecimalTwoWayFormatter = {
        let decimalFormatter = DecimalTwoWayFormatter()
        decimalFormatter.formatter.maximumFractionDigits = 0
        return decimalFormatter
    }()
    
    func makeDecimalFormatter(for currency: Currency) -> DecimalTwoWayFormatter {
        currency == .makeJpy() ? noFractionFormatter : defaultFormatter
    }
}
