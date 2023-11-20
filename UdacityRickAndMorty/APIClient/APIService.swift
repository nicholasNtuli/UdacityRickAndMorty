import Foundation

final class APIService {
    
    static let shared = APIService()
    private let cacheManager = APICacheManager()
    
    enum ServiceError: Error {
        case failedToCreateRequest
        case failedToGetData
    }

    func execute<T: Codable>(
        _ request: APIRequest,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let cachedResult = getCachedResult(for: request, expecting: type) {
            completion(cachedResult)
            return
        }
        
        guard let urlRequest = buildURLRequest(from: request) else {
            completion(.failure(ServiceError.failedToCreateRequest))
            return
        }
        
        performRequest(urlRequest, for: request, expecting: type, completion: completion)
    }

    private func getCachedResult<T: Codable>(for request: APIRequest, expecting type: T.Type) -> Result<T, Error>? {
        if let cachedData = cacheManager.cachedResponse(for: request.apiEndpoint, url: request.url) {
            do {
                let result = try JSONDecoder().decode(type.self, from: cachedData)
                return .success(result)
            } catch {
                return .failure(error)
            }
        }
        return nil
    }
    
    private func buildURLRequest(from request: APIRequest) -> URLRequest? {
        guard let url = request.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod
        return urlRequest
    }
    
    private func performRequest<T: Codable>(
        _ urlRequest: URLRequest,
        for request: APIRequest,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? ServiceError.failedToGetData))
                return
            }
            do {
                let result = try JSONDecoder().decode(type.self, from: data)
                self?.cacheManager.setCache(for: request.apiEndpoint, url: request.url, data: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
