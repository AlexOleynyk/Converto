import Foundation

final class WeakRef<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}
