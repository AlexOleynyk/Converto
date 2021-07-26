@testable import ConvertoKit
import SnapshotTesting
import XCTest

class ButtonSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        isRecording = true
    }
    let primary = setup(PrimaryButton()) {
        $0.setTitle("Bar", for: [])
    }

    func testPrimaryButton_default() {
        assertSnapshot(matching: ContainerView(primary), as: .image(size: ContainerView.defaultSize, traits: .lightMode))
        assertSnapshot(matching: ContainerView(primary), as: .image(size: ContainerView.defaultSize, traits: .darkMode))
    }
}
