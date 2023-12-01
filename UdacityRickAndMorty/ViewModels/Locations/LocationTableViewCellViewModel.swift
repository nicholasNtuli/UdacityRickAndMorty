import Foundation

struct LocationTableViewCellViewModel: Hashable, Equatable {

    let locationTable: Location

    var locationName: String {
        locationTable.name
    }

    var locationType: String {
        "Type: \(locationTable.type)"
    }

    var locationDimension: String {
        locationTable.dimension
    }

    static func == (lhs: LocationTableViewCellViewModel, rhs: LocationTableViewCellViewModel) -> Bool {
        lhs.locationTable.id == rhs.locationTable.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(locationName)
        hasher.combine(locationTable.id)
        hasher.combine(locationDimension)
        hasher.combine(locationType)
    }
}
