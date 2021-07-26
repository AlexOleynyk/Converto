import UIKit

public final class PrimaryButton: UIButton {
    
    public var isLoading: Bool = false {
        didSet { updateAppearance() }
    }
    
    private let loadingIndicator = setup(UIActivityIndicatorView()) {
            $0.color = Asset.Colors.fixedBlue200
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Asset.Colors.blue500.color
        titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        setTitleColor(Asset.Colors.fixedBlue200, for: [])
        contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        layer.cornerRadius = 8

        addSubview(loadingIndicator, constraints: [
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        updateAppearance()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviews()
    }
    
    public override var isUserInteractionEnabled: Bool {
        get { super.isUserInteractionEnabled && isLoading == false }
        set { super.isUserInteractionEnabled = newValue }
    }
    
    private func updateAppearance() {
        isLoading
            ? loadingIndicator.startAnimating()
            : loadingIndicator.stopAnimating()
        updateSubviews()
    }
    
    private func updateSubviews() {
        titleLabel?.isHidden = isLoading
        imageView?.isHidden = isLoading
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Asset.Colors {
    static let fixedBlue200 = blue200.fixedToUserInterfaceStyle(.light)
}
