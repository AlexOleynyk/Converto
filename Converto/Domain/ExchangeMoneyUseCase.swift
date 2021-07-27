import Foundation

protocol ExchangeMoneyUseCase {
    func exchange(command: ExchangeMoneyCommand, completion: @escaping (Bool) -> Void)
}

protocol WalletRepository {
    func fetchWallet(completion: @escaping (Wallet) -> Void)
    func updateWallet(_ wallet: Wallet, completion: @escaping (Bool) -> Void)
}

class ExchangeMoneyUseCaseImpl: ExchangeMoneyUseCase {
    
    private let userWalletRepository: WalletRepository
    private let bankWalletRepository: WalletRepository
    
    init(
        userWalletRepository: WalletRepository,
        bankWalletRepository: WalletRepository
    ) {
        self.userWalletRepository = userWalletRepository
        self.bankWalletRepository = bankWalletRepository
    }

    func exchange(command: ExchangeMoneyCommand, completion: @escaping (Bool) -> Void) {
        var result = true
        let group = DispatchGroup()

        group.enter()
        userWalletRepository.fetchWallet { [weak self] in
            var userWallet = $0
            userWallet.withdrow(from: command.sourceBalance, amount: command.amount + command.fee)
            userWallet.deposit(from: command.targetBalance, amount: command.convertedAmount)
            
            self?.userWalletRepository.updateWallet(userWallet) {
                result = result && $0
                group.leave()
                
            }
        }
        
        group.enter()
        bankWalletRepository.fetchWallet { [weak self] in
            var bankWallet = $0
            bankWallet.deposit(from: command.targetBalance, amount: command.fee)
            
            
            self?.bankWalletRepository.updateWallet(bankWallet) {
                result = result && $0
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(result)
        }
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
