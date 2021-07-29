import UIKit
import ConvertoKit

final class BalanceSelectionCell: UITableViewCell {

    let selectionView = MoneyCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(selectionView, constraints: [
            selectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            selectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionView.isSelected = selected
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
