import Foundation

struct Wallet {
    private(set) var balances: [Balance]
    
    mutating func withdrow(from balance: Balance, amount: Decimal) {
        guard let index = balances.firstIndex(where: { $0.id == balance.id }) else {
            return
        }
        balances[index] = Balance(id: balance.id, money: balance.money.adding(amount: -amount))
    }
    
    mutating func deposit(from balance: Balance, amount: Decimal) {
        guard let index = balances.firstIndex(where: { $0.id == balance.id }) else {
            return
        }
        balances[index] = Balance(id: balance.id, money: balance.money.adding(amount: amount))
    }
}

struct Balance {
    let id: Int
    let money: Money
}

struct Money {
    let amount: Decimal
    let currency: Currency
    
    func adding(amount: Decimal) -> Money {
        Money(amount: self.amount + amount, currency: currency)
    }
}

struct Currency: Equatable {
    let id: Int
    let code: String
}
