import Foundation
import ConvertoDomain

final class RemoteRateFetcher: ExchangeRateFetcher {
    func get(sourceMoney: Money, targetMoney: Money, completion: @escaping (Decimal) -> Void) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "api.evp.lt"
        components.path = "/currency/commercial/exchange/1-\(sourceMoney.currency.code)/\(targetMoney.currency.code)/latest"
        guard let url = components.url else { return completion(1) }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  let data = data,
                  let result = try? JSONDecoder().decode(RateResponseDTO.self, from: data) else {
                return DispatchQueue.main.async {
                    completion(1)
                }
            }
            DispatchQueue.main.async {
                completion(Decimal(string: result.amount) ?? 1)
            }
                
        }
        task.resume()
    }
    
    private struct RateResponseDTO: Decodable {
        let amount: String
    }
}
