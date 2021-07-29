import Foundation

public struct Wallet {

    public private(set) var balances: [Balance]

    public init(balances: [Balance]) {
        self.balances = balances
    }

    mutating func withdrow(from balance: Balance, amount: Decimal) {
        update(balance: balance, with: -amount)
    }

    mutating func deposit(from balance: Balance, amount: Decimal) {
        update(balance: balance, with: amount)
    }

    private mutating func update(balance: Balance, with amount: Decimal) {
        guard let index = balances.firstIndex(where: { $0.id == balance.id }) else {
            return
        }
        balances[index] = Balance(id: balance.id, money: balance.money.adding(amount: amount))
    }
}

public struct Balance {
    public let id: Int
    public let money: Money

    public  init(id: Int, money: Money) {
        self.id = id
        self.money = money
    }
}

public struct Money {
    public let amount: Decimal
    public let currency: Currency

    public  init(amount: Decimal, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }

    func adding(amount: Decimal) -> Money {
        Money(amount: self.amount + amount, currency: currency)
    }
}

public struct Currency: Equatable {
    public let id: Int
    public let code: String

    public init(id: Int, code: String) {
        self.id = id
        self.code = code
    }
}
