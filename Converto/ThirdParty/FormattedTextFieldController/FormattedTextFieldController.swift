import UIKit

public protocol RangeReplacer {
    func replacingCharacters(string: String, in range: NSRange, with replacement: String) -> (formatted: String, cursorOffset: Int)
    func formattedString(_ string: String) -> String
}

public final class FormattedTextFieldController: NSObject, UITextFieldDelegate {

    private let twoWayFormatter: RangeReplacer
    public init(twoWayFormatter: RangeReplacer) {
        self.twoWayFormatter = twoWayFormatter
        super.init()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let (newText, cursorOffset) = twoWayFormatter.replacingCharacters(string: textField.textOrEmpty, in: range, with: string)
        textField.text = newText
        textField.setCursorOffset(cursorOffset)
        textField.sendActions(for: .editingChanged)
        return false
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = twoWayFormatter.formattedString(textField.textOrEmpty)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

public extension UITextField {

    var textOrEmpty: String {
        text ?? ""
    }

    func setCursorOffset(_ offset: Int) {
        if let newPosition = position(from: beginningOfDocument, offset: offset) {
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
    }
}
