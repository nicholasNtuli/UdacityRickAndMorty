import Foundation

final class APIImageLoader {
    
    static let shared = APIImageLoader()
    private let imageDataCache = NSCache<NSString, NSData>()

    private init() {}
    
    func downloadImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let key = url.absoluteString as NSString

        if let cachedData = imageDataCache.object(forKey: key) {
            completion(.success(cachedData as Data))
            return
        }

        guard let request = createURLRequest(url: url) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        performImageDownload(with: request, key: key, completion: completion)
    }

    private func createURLRequest(url: URL) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    private func performImageDownload(with request: URLRequest, key: NSString, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }

            let cachedData = data as NSData
            self?.imageDataCache.setObject(cachedData, forKey: key)
            completion(.success(data))
        }
        task.resume()
    }
}
