import Foundation

final class APIRequest {

    private struct APIConstants {
        static let apiURL = "https://rickandmortyapi.com/api"
    }

    let apiEndpoint: APIEndpoint
    private let pathComponents: [String]
    private let queryParameters: [URLQueryItem]
    public var httpMethod = "GET"

    public init(
        endpoint: APIEndpoint,
        pathComponents: [String] = [],
        queryParameters: [URLQueryItem] = [],
        httpMethod: String = "GET"
    ) {
        self.apiEndpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
        self.httpMethod = httpMethod
    }

    private var urlString: String {
        var string = APIConstants.apiURL
        string += "/"
        string += apiEndpoint.rawValue

        if !pathComponents.isEmpty {
            pathComponents.forEach({
                string += "/\($0)"
            })
        }

        if !queryParameters.isEmpty {
            string += "?"
            let argumentString = queryParameters.compactMap({
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }).joined(separator: "&")

            string += argumentString
        }

        return string
    }

    public var url: URL? {
        return URL(string: urlString)
    }

    convenience init?(url: URL) {
        let urlString = url.absoluteString
        guard urlString.contains(APIConstants.apiURL) else { return nil }

        let trimmedURL = urlString.replacingOccurrences(of: APIConstants.apiURL + "/", with: "")

        if trimmedURL.contains("/") {
            let components = trimmedURL.components(separatedBy: "/")
            guard let endpointString = components.first else { return nil }

            let pathComponents = components.dropFirst()

            if let apiEndpoint = APIEndpoint(rawValue: endpointString) {
                self.init(endpoint: apiEndpoint, pathComponents: Array(pathComponents))
                return
            }
        } else if trimmedURL.contains("?") {
            let components = trimmedURL.components(separatedBy: "?")
            guard components.count >= 2,
                let endpointString = components.first,
                let queryItems = URLComponents(string: urlString)?.queryItems else {
                    return nil
            }

            let apiEndpoint = APIEndpoint(rawValue: endpointString)
            self.init(endpoint: apiEndpoint!, queryParameters: queryItems)
            return
        }

        return nil
    }
}
