@testable import ConvertoKit
import SnapshotTesting
import XCTest

final class PrimaryButtonSnapshotTests: XCTestCase {
    
    private let primaryButton = setup(PrimaryButton()) {
        $0.setTitle("Exchange", for: [])
    }

    func testPrimaryButton_default() {
        assertSnapshot(matching: ContainerView(primaryButton), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(primaryButton), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }
    
    func testPrimaryButton_loading() {
        primaryButton.isLoading = true
        assertSnapshot(matching: ContainerView(primaryButton), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(primaryButton), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }
}
