import UIKit

public extension ColorAsset {
    func fixedToUserInterfaceStyle(_ style: UIUserInterfaceStyle) -> ColorAsset.Color {
        if #available(iOS 13.0, *) {
            return color
                .resolvedColor(with: .init(userInterfaceStyle: .light))
        }
        return color
    }
}
