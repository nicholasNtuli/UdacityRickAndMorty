import Foundation

final class SearchInputViewModel {
    
    private let searchInputType: SearchViewController.SearchViewControllerConfiguration.`Type`
    
    enum SearchInputConstants: String {
        case status = "Status"
        case gender = "Gender"
        case locationType = "Location Type"
        
        var searchInputQueryArgument: String {
            switch self {
            case .status: return "status"
            case .gender: return "gender"
            case .locationType: return "type"
            }
        }
        
        var searchInputChoices: [String] {
            switch self {
            case .status:
                return ["alive", "dead", "unknown"]
            case .gender:
                return ["male", "female", "genderless", "unknown"]
            case .locationType:
                return ["cluster", "planet", "microverse"]
            }
        }
    }
    
    init(SearchInputType: SearchViewController.SearchViewControllerConfiguration.`Type`) {
        self.searchInputType = SearchInputType
    }
    
    var searchInputConstant: Bool {
        switch searchInputType {
        case .character, .location:
            return true
        case .episode:
            return false
        }
    }
    
    var searchInputOptions: [SearchInputConstants] {
        switch searchInputType {
        case .character:
            return [.status, .gender]
        case .location:
            return [.locationType]
        case .episode:
            return []
        }
    }
    
    var searchInputPlaceholderTexts: String {
        switch searchInputType {
        case .character:
            return "Character Name"
        case .location:
            return "Location Name"
        case .episode:
            return "Episode Title"
        }
    }
}
