import Foundation
import ConvertoDomain

final class ObservingExchangeMoneyUseCaseDecorator: ExchangeMoneyUseCase {

    private let decoratee: ExchangeMoneyUseCase
    private let callback: (ExchangeMoneyCommand, Bool) -> Void
    
    init(
        decoratee: ExchangeMoneyUseCase,
        callback: @escaping (ExchangeMoneyCommand, Bool) -> Void
    ) {
        self.decoratee = decoratee
        self.callback = callback
    }
    
    func exchange(command: ExchangeMoneyCommand, completion: @escaping (Bool) -> Void) {
        decoratee.exchange(command: command) { [weak self] result in
            self?.callback(command, result)
            completion(result)
        }
    }
}
