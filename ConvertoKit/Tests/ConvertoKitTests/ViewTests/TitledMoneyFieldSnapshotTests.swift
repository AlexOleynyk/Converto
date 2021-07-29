@testable import ConvertoKit
import SnapshotTesting
import XCTest

final class TitledMoneyFieldSnapshotTests: XCTestCase {

    private let moneyField = setup(TitledMoneyField()) {
        $0.moneyField.inputField.text = "100.00"
        $0.moneyField.currencyLabel.text = "USD"
        $0.titleView.titleLabel.text = "Sell"
        $0.titleView.iconView.image = Asset.Icons.sellArrow.image
        $0.balanceLabel.text = "Available: 1000.00"
    }

    func testTitledMoneyField_default() {
        assertSnapshot(matching: ContainerView(moneyField), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(moneyField), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }

    func testTitledMoneyField_longAmounttext() {
        moneyField.moneyField.inputField.text = "Very long text here, really long. It is not a joke"
        assertSnapshot(matching: ContainerView(moneyField), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(moneyField), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }
}
