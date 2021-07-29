import Foundation
import ConvertoDomain

final class RemoteRateFetcher: ExchangeRateFetcher {
    
    private let request: ApiRequest

    init(request: ApiRequest) {
        self.request = request
    }

    func get(sourceMoney: Money, targetMoney: Money, completion: @escaping (Decimal) -> Void) {
        let resource = ApiResource<RateResponseDTO>(
            path: "/currency/commercial/exchange/1-\(sourceMoney.currency.code)/\(targetMoney.currency.code)/latest"
        )
        request.get(resource: resource) { rates in
            DispatchQueue.main.async {
                completion(Decimal(string: rates.amount) ?? 1)
            }
        }
    }
}

private struct RateResponseDTO: Decodable {
    let amount: String
}
