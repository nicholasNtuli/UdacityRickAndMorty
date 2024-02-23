import Foundation
import UIKit

final class SearchViewModel {
    
    private var SearchVieMapping: [SearchInputViewModel.SearchInputConstants: String] = [:]
    private var searchText = ""
    private var updatedMapForSearchView: (((SearchInputViewModel.SearchInputConstants, String)) -> Void)?
    private var searchViewHandler: ((SearchResultViewModel) -> Void)?
    private var noSearchViewFoundHandler: (() -> Void)?
    private var searchViewResultModel: Codable?
    
    let searchViewConfiguration: SearchViewController.SearchViewControllerConfiguration
    
    init(searchViewConfiguration: SearchViewController.SearchViewControllerConfiguration) {
        self.searchViewConfiguration = searchViewConfiguration
    }
    
    public func searchViewHandlerRegister(_ block: @escaping (SearchResultViewModel) -> Void) {
        searchViewHandler = block
    }
    
    public func searchViewNoResultsHandlerRegister(_ block: @escaping () -> Void) {
        noSearchViewFoundHandler = block
    }
    
    public func executeSearchForSearchView() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let searchViewQueryParams = parametersForSearchViewbuildQuery()
        let searchViewRequest = APIRequest(endpoint: searchViewConfiguration.searchViewType.searchViewAPIndpoint, queryParameters: searchViewQueryParams)
        
        switch searchViewConfiguration.searchViewType.searchViewAPIndpoint {
        case .character:
            searchViewAPI(CharactersResponse.self, searchViewRequest: searchViewRequest)
        case .episode:
            searchViewAPI(EpisodesResponse.self, searchViewRequest: searchViewRequest)
        case .location:
            searchViewAPI(LocationsResponse.self, searchViewRequest: searchViewRequest)
        }
    }
    
    private func parametersForSearchViewbuildQuery() -> [URLQueryItem] {
        var searchViewQueryParams: [URLQueryItem] = [
            URLQueryItem(name: "name", value: searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        ]
        
        searchViewQueryParams.append(contentsOf: SearchVieMapping.compactMap { searchViewElement in
            let searchViewKey = searchViewElement.key
            let searchViewValue = searchViewElement.value
            return URLQueryItem(name: searchViewKey.searchInputQueryArgument, value: searchViewValue)
        })
        
        return searchViewQueryParams
    }
    
    private func searchViewAPI<T: Codable>(_ type: T.Type, searchViewRequest: APIRequest) {
        APIService.shared.execute(searchViewRequest, expecting: type) { [weak self] searchViewResult in
            switch searchViewResult {
            case .success(let searchViewModel):
                self?.searchViewResultProcesor(searchViewModel: searchViewModel)
            case .failure:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Failed to perform the search.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let topViewController = windowScene.windows.first?.rootViewController {
                        topViewController.present(alert, animated: true, completion: nil)
                    }
                    
                    self?.noSearchViewResultsFOunderHandler()
                }
            }
        }
    }
    
    private func searchViewResultProcesor(searchViewModel: Codable) {
        var searchViewResults: SearchResultType?
        var nextSearchViewURL: String?
        
        switch searchViewModel {
        case let searchViewCharacterResults as CharactersResponse:
            searchViewResults = .characters(searchViewCharacterResults.results.compactMap {
                CharacterCollectionViewCellViewModel(
                    characterCollectionViewCellCharacterName: $0.name,
                    characterCollectionViewCellCharacterStatus: $0.status,
                    characterCollectionViewCellCharacterImageUrl: URL(string: $0.image)
                )
            })
            nextSearchViewURL = searchViewCharacterResults.info.next
            
        case let searchViewEpisodesResults as EpisodesResponse:
            searchViewResults = .episodes(searchViewEpisodesResults.results.compactMap {
                CharacterEpisodeSectionViewModel(
                    characterEpisodeBaseURL: URL(string: $0.url)
                )
            })
            nextSearchViewURL = searchViewEpisodesResults.info.next
            
        case let searchViewLocationsResults as LocationsResponse:
            searchViewResults = .locations(searchViewLocationsResults.results.compactMap {
                LocationTableViewCellViewModel(locationTable: $0)
            })
            nextSearchViewURL = searchViewLocationsResults.info.next
        default:
            print("Unexpected response model type")
        }
        
        if let searchViewResults = searchViewResults {
            searchViewResultModel = searchViewModel
            let searchViewViewModel = SearchResultViewModel(searchResults: searchViewResults, next: nextSearchViewURL)
            searchViewHandler?(searchViewViewModel)
        } else {
            noSearchViewResultsFOunderHandler()
        }
    }
    
    private func noSearchViewResultsFOunderHandler() {
        noSearchViewFoundHandler?()
    }
    
    public func setSearchViewText(query text: String) {
        searchText = text
    }
    
    public func setSearchViewMapping(value: String, for option: SearchInputViewModel.SearchInputConstants) {
        SearchVieMapping[option] = value
        let searchViewData = (option, value)
        updatedMapForSearchView?(searchViewData)
    }
    
    public func searchViewOptionRegisterHander(
        _ block: @escaping ((SearchInputViewModel.SearchInputConstants, String)) -> Void
    ) {
        updatedMapForSearchView = block
    }
    
    public func searchViewLocationResults(at index: Int) -> Location? {
        (searchViewResultModel as? LocationsResponse)?.results[index]
    }
    
    public func searchViewCharacterResults(at index: Int) -> Character? {
        (searchViewResultModel as? CharactersResponse)?.results[index]
    }
    
    public func searchViewEpisodeResults(at index: Int) -> Episode? {
        (searchViewResultModel as? EpisodesResponse)?.results[index]
    }
}
