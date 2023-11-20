import Foundation

@frozen enum APIEndpoint: String, CaseIterable, Hashable {
    case character, location, episode
}
