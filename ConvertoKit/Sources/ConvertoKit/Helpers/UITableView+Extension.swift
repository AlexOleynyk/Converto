import UIKit

public extension UITableView {
    func registerReusableCell<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: T.self))
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T
    }

    func registerReusableHeaderFooter<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }

    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T? {
        dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T
    }
}
