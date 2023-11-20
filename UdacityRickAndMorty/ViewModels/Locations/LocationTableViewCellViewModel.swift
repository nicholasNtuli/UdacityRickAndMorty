import Foundation

struct LocationTableViewCellViewModel: Hashable, Equatable {

    let location: Location

    var name: String {
        location.name
    }

    var type: String {
        "Type: \(location.type)"
    }

    var dimension: String {
        location.dimension
    }

    static func == (lhs: LocationTableViewCellViewModel, rhs: LocationTableViewCellViewModel) -> Bool {
        lhs.location.id == rhs.location.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(location.id)
        hasher.combine(dimension)
        hasher.combine(type)
    }
}
