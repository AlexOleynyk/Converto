// swiftlint:disable identifier_name
public func setup<A>(_ a: A, _ fs: ((inout A) -> Void)...) -> A {
    var a = a
    fs.forEach { f in f(&a) }
    return a
}
