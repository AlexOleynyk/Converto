import UIKit
import ConvertoKit
import ConvertoDomain

final class BalanceSelectionViewContorller: UITableViewController {

    var shouldDimmZeroBalances: Bool = false {
        didSet { tableView.reloadData() }
    }

    var selectedBalance: Balance? = nil {
        didSet { updateSelectedBalance() }
    }

    var onBalanceSelected: ((Balance) -> Void)?

    private let getUserWalleUseCase: GetUserBalancesForSelectionUseCase
    private var balances: [Balance] = [] {
        didSet { tableView.reloadData() }
    }

    init(getUserWalleUseCase: GetUserBalancesForSelectionUseCase) {
        self.getUserWalleUseCase = getUserWalleUseCase
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select balance"
        tableView.registerReusableCell(BalanceSelectionCell.self)
        tableView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        tableView.separatorStyle = .none
        getUserWalleUseCase.get { [weak self] balances in
            self?.balances = balances
            self?.updateSelectedBalance()
        }
    }

    private func updateSelectedBalance() {
        guard let row = balances.firstIndex(where: { $0.id == selectedBalance?.id }) else { return }
        tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return balances.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BalanceSelectionCell = tableView.dequeueReusableCell(for: indexPath)
        let balance = balances[indexPath.row]
        cell.selectionView.amountLabel.text = "\(balance.money.amount)"
        cell.selectionView.currencyLabel.text = "\(balance.money.currency.code)"
        cell.selectionView.layer.opacity = shouldDimmZeroBalances && balance.money.amount == 0 ? 0.2 : 1
        cell.isUserInteractionEnabled = !(shouldDimmZeroBalances && balance.money.amount == 0)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let balance = balances[indexPath.row]
        onBalanceSelected?(balance)
        dismiss(animated: true)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
