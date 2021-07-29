import UIKit

extension UITextField {

   func setCursorOffset(_ offset: Int) {
       if let newPosition = position(from: beginningOfDocument, offset: offset) {
           selectedTextRange = textRange(from: newPosition, to: newPosition)
       }
   }
}
