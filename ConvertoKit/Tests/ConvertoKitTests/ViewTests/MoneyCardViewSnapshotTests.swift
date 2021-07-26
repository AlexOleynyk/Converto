@testable import ConvertoKit
import SnapshotTesting
import XCTest

final class MoneyCardViewSnapshotTests: XCTestCase {

    private let cardView = setup(MoneyCardView()) {
        $0.amountLabel.text = "100.00"
        $0.currencyLabel.text = "USD"
    }

    func testMoneyCardView_default() {
        assertSnapshot(matching: ContainerView(cardView), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(cardView), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }
    
    func testMoneyCardView_selected() {
        cardView.isSelected = true
        assertSnapshot(matching: ContainerView(cardView), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(cardView), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }
}
