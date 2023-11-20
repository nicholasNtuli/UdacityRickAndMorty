import UIKit

final class CharacterDetailCollectionViewCellViewModel {
    
    private let type: Type
    private let value: String
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
        formatter.timeZone = .current
        return formatter
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()
    
    var title: String {
        return type.displayTitle
    }
    
    var displayValue: String {
        guard !value.isEmpty else { return "None" }
        
        if let date = Self.dateFormatter.date(from: value), type == .created {
            return Self.shortDateFormatter.string(from: date)
        }
        
        return value
    }
    
    var iconImage: UIImage? {
        return type.iconImage
    }
    
    var tintColor: UIColor {
        return type.tintColor
    }
    
    enum `Type`: String {
        case status, gender, type, species, origin, created, location, episodeCount
        
        var tintColor: UIColor {
            switch self {
            case .status: return .systemBlue
            case .gender: return .systemRed
            case .type: return .systemPurple
            case .species: return .systemGreen
            case .origin: return .systemOrange
            case .created: return .systemPink
            case .location: return .systemYellow
            case .episodeCount: return .systemMint
            }
        }
        
        var iconImage: UIImage? {
            return UIImage(systemName: "bell")
        }
        
        var displayTitle: String {
            switch self {
            case .status, .gender, .type, .species, .origin, .created, .location:
                return rawValue.uppercased()
            case .episodeCount:
                return "EPISODE COUNT"
            }
        }
    }
    
    init(type: Type, value: String) {
        self.value = value
        self.type = type
    }
}
