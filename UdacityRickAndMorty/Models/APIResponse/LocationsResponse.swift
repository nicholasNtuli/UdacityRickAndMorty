import Foundation

struct LocationsResponse: Codable {
    struct Info: Codable {
        let count: Int
        let pages: Int
        let next: String?
        let previous: String?
    }

    let info: Info
    let results: [Location]
}
