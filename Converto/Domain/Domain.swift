import Foundation

var mockWallet = UserWallet(balances: [
    Balance(id: 1, money: Money(amount: 1000, currency: Currency(id: 1, code: "USD"))),
    Balance(id: 2, money: Money(amount: 100, currency: Currency(id: 2, code: "EUR")))
])

var bankWallet = UserWallet(balances: [
    Balance(id: 1, money: Money(amount: 0, currency: Currency(id: 1, code: "USD"))),
    Balance(id: 2, money: Money(amount: 0, currency: Currency(id: 2, code: "EUR")))
])

struct UserWallet {
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
        balances[index] = Balance(id: balance.id, money: balance.money.adding(amount: +amount))
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


class GetUserBalancesUseCase {
    
    func get(currency: Currency, completion: @escaping (Balance?) -> Void) {
        completion(mockWallet.balances.first(where: { $0.money.currency == currency }))
    }
}

class GetExchangeFeeUseCase {
    
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        var initialValue = amount * 0.007
        var result: Decimal = 0
        NSDecimalRound(&result, &initialValue, 2, .plain)
        completion(.init(amount: result, currency: sourceBalance.money.currency))
    }
}

class GetExchangedAmountUseCase {
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        let rate: Decimal = sourceBalance.money.amount >= 500 ? 2 : 4
        var initialValue = amount * rate
        var result: Decimal = 0
        NSDecimalRound(&result, &initialValue, 2, .plain)
        completion(.init(amount: result, currency: sourceBalance.money.currency))
    }
}


class ExchangeMoneyUseCase {
    func exchange(command: ExchangeMoneyCommand, completion: @escaping (Bool) -> Void) {
        mockWallet.withdrow(from: command.sourceBalance, amount: command.amount + command.fee)
        mockWallet.deposit(from: command.targetBalance, amount: command.convertedAmount)
        bankWallet.deposit(from: command.targetBalance, amount: command.fee)
        completion(true)
    }
}

struct ExchangeMoneyCommand {
    
    enum Error: Swift.Error {
        case notEnoughBalance
        case notEnoughBalanceIncludingBalance
        case zeroAmount
    }
 
    let sourceBalance: Balance
    let targetBalance: Balance
    let amount: Decimal
    let convertedAmount: Decimal
    let fee: Decimal
    
    private init(
        sourceBalance: Balance,
        targetBalance: Balance,
        amount: Decimal,
        convertedAmount: Decimal,
        fee: Decimal
    ) {
        self.sourceBalance = sourceBalance
        self.targetBalance = targetBalance
        self.amount = amount
        self.convertedAmount = convertedAmount
        self.fee = fee
    }
    
    static func make(
        sourceBalance: Balance,
        targetBalance: Balance,
        amount: Decimal,
        convertedAmount: Decimal,
        fee: Decimal
    ) -> Result<ExchangeMoneyCommand, Error> {
        guard amount > 0 else {
            return .failure(.zeroAmount)
        }
        guard sourceBalance.money.amount >= amount else {
            return .failure(.notEnoughBalance)
        }
        
        guard sourceBalance.money.amount >= amount + fee else {
            return .failure(.notEnoughBalanceIncludingBalance)
        }
        
        return .success(ExchangeMoneyCommand(
            sourceBalance: sourceBalance,
            targetBalance: targetBalance,
            amount: amount,
            convertedAmount: convertedAmount,
            fee: fee
        ))
    }
}
