import UIKit

final class CharacterInformationSectionViewModel {
    
    private let charcterInformationType: `CharInfoType`
    private let charcterInformationValue: String
    
    static let longFromattedDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
        formatter.timeZone = .current
        return formatter
    }()
    
    static let shortFormattedDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()
    
    var charcterInformationTitle: String {
        return charcterInformationType.charcterInformationDisplayTitle
    }
    
    var charcterInformationDisplayValue: String {
        guard !charcterInformationValue.isEmpty else { return "None" }
        
        if let date = Self.longFromattedDate.date(from: charcterInformationValue), charcterInformationType == .created {
            return Self.shortFormattedDate.string(from: date)
        }
        
        return charcterInformationValue
    }
    
    var charcterInformationIconImage: UIImage? {
        return charcterInformationType.charcterInformationIconImage
    }
    
    var charcterInformationTintColor: UIColor {
        return charcterInformationType.charcterInformationTintColor
    }
    
    enum `CharInfoType`: String {
        case status, gender, type, species, origin, created, location, episodeCount
        
        var charcterInformationTintColor: UIColor {
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
        
        var charcterInformationIconImage: UIImage? {
            return UIImage(systemName: "bell")
        }
        
        var charcterInformationDisplayTitle: String {
            switch self {
            case .status, .gender, .type, .species, .origin, .created, .location:
                return rawValue.uppercased()
            case .episodeCount:
                return "EPISODE COUNT"
            }
        }
    }
    
    init(charcterInformationType: `CharInfoType`, charcterInformationValue: String) {
        self.charcterInformationType = charcterInformationType
        self.charcterInformationValue = charcterInformationValue
    }
}
