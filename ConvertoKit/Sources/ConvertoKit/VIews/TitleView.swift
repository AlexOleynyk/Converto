import UIKit

public final class TitleView: UIView {
    
    public let iconView = setup(UIImageView()) {
        $0.contentMode = .scaleAspectFit
    }
    
    public let titleLabel = setup(UILabel()) {
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.textColor = Asset.Colors.gray900.color
        $0.numberOfLines = 0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView, constraints: [
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 12)
        ])
        addSubview(titleLabel, constraints: [
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 2)
        ])
    }
    
    public func setComposedTitle(bold: String, regular: String) {
        guard bold.isEmpty == false, regular.isEmpty == false else {
            titleLabel.text = bold
            return
        }
        
        let boldString = NSMutableAttributedString(string: bold, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: Asset.Colors.gray900.color
        ])
        
        let spaceBetween = NSAttributedString(string: " ")
        
        let regularString = NSAttributedString(string: regular, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: Asset.Colors.gray900.color
        ])
        
        let resultString = NSMutableAttributedString()
        resultString.append(boldString)
        resultString.append(spaceBetween)
        resultString.append(regularString)
        
        titleLabel.attributedText = resultString
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
