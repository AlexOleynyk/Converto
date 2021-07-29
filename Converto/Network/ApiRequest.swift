import Foundation

struct ApiResource<T: Decodable> {
    let path: String
}

final class ApiRequest {

    func get<T: Decodable>(resource: ApiResource<T>, completion: @escaping (T) -> Void) {
        guard let url = url(for: resource.path) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil,
                  let data = data,
                  let result = try? JSONDecoder().decode(T.self, from: data)
            else {
                return
            }
            completion(result)
        }
        task.resume()
    }

    private func url(for path: String) -> URL? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "api.evp.lt"
        components.path = path
        return components.url
    }
}
