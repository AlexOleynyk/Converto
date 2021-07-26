import UIKit

public class PrimaryButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .gray
        setImage(Asset.Icons.sellArrow.image, for: [])
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
