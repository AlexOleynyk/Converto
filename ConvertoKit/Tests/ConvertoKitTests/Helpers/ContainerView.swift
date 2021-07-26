import Foundation
import UIKit

public class ContainerView: UIView {
    public static var highSize = CGSize(width: 400, height: 600)
    public static var defaultSize = CGSize(width: 400, height: 200)
    public static var smallSize = CGSize(width: 100, height: 100)

    init(_ wrapped: UIView) {
        super.init(frame: .zero)
        backgroundColor = .lightGray//Asset.Colors.grey100.color
        addSubview(wrapped, constraints: [
            wrapped.centerYAnchor.constraint(equalTo: centerYAnchor),
            wrapped.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            wrapped.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
