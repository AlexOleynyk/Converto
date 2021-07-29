import Foundation
import ConvertoDomain

final class RemoteRateFetcher: ExchangeRateFetcher {

    private let request: ApiRequest
    private let errorHandler: (ApiRequest.Error) -> Void

    init(
        request: ApiRequest,
        errorHandler: @escaping (ApiRequest.Error) -> Void
    ) {
        self.request = request
        self.errorHandler = errorHandler
    }

    func get(sourceMoney: Money, targetMoney: Money, completion: @escaping (Decimal) -> Void) {
        let resource = ApiResource<RateResponseDTO>(
            path: "/currency/commercial/exchange/1-\(sourceMoney.currency.code)/\(targetMoney.currency.code)/latest"
        )

        request.get(resource: resource) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(rates):
                    completion(Decimal(string: rates.amount) ?? 1)
                case let .failure(error):
                    self?.errorHandler(error)
                }
            }
        }
    }
}

private struct RateResponseDTO: Decodable {
    let amount: String
}
