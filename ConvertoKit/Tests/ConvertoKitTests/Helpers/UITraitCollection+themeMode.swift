import UIKit

public extension UITraitCollection {
    static var darkMode: UITraitCollection {
        if #available(iOS 12.0, *) {
            return .init(userInterfaceStyle: .dark)
        } else {
            return .init()
        }
    }

    static var lightMode: UITraitCollection {
        if #available(iOS 12.0, *) {
            return .init(userInterfaceStyle: .light)
        } else {
            return .init()
        }
    }
}
