import ConvertoDomain

extension Currency {
    static func makeUsd() -> Currency {
        Currency(id: 1, code: "USD")
    }
    
    static func makeEur() -> Currency {
        Currency(id: 2, code: "EUR")
    }
    
    static func makeJpy() -> Currency {
        Currency(id: 3, code: "JPY")
    }
}
