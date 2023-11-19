import Foundation

@frozen enum Endpoint: String, CaseIterable, Hashable {
    case character, location, episode
}
