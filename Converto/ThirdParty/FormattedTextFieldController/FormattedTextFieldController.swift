import UIKit

protocol RangeReplacer {
    func replacingCharacters(string: String, in range: NSRange, with replacement: String) -> (formatted: String, cursorOffset: Int)
    func formattedString(_ string: String) -> String
}

final class FormattedTextFieldController: NSObject, UITextFieldDelegate {

    private let twoWayFormatter: RangeReplacer
    init(twoWayFormatter: RangeReplacer) {
        self.twoWayFormatter = twoWayFormatter
        super.init()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let (newText, cursorOffset) = twoWayFormatter.replacingCharacters(string: textField.text.orEmpty, in: range, with: string)
        textField.text = newText
        textField.setCursorOffset(cursorOffset)
        textField.sendActions(for: .editingChanged)
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = twoWayFormatter.formattedString(textField.text.orEmpty)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
