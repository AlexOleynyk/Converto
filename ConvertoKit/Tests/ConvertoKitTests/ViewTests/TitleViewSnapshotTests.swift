@testable import ConvertoKit
import SnapshotTesting
import XCTest

final class TitleViewSnapshotTests: XCTestCase {

    private let titleView = setup(TitleView()) {
        $0.iconView.image = Asset.Icons.sellArrow.image
        $0.titleLabel.text = "Sell"
    }

    func testTitleView_defaultTitleStyle() {
        assertSnapshot(matching: ContainerView(titleView), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(titleView), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }

    func testTitleView_composedTitleStyle() {
        titleView.iconView.image = Asset.Icons.sellArrow.image
        titleView.setComposedTitle(bold: "0.70 EUR", regular: "commission fee")
        assertSnapshot(matching: ContainerView(titleView), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(titleView), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }
}
