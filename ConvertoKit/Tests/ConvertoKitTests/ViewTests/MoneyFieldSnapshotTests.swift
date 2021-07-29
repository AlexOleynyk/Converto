@testable import ConvertoKit
import SnapshotTesting
import XCTest

final class MoneyFieldSnapshotTests: XCTestCase {

    private let moneyField = setup(MoneyField()) {
        $0.inputField.text = "100.00"
        $0.currencyLabel.text = "USD"
    }

    func testMoneyField_default() {
        assertSnapshot(matching: ContainerView(moneyField), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(moneyField), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }

    func testMoneyField_longAmounttext() {
        moneyField.inputField.text = "Very long text here, really long. It is not a joke"
        assertSnapshot(matching: ContainerView(moneyField), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(moneyField), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }
}
