import Foundation

final class SearchViewModel {
    
    private var optionMap: [SearchInputViewModel.DynamicOption: String] = [:]
    private var searchText = ""
    private var optionMapUpdateBlock: (((SearchInputViewModel.DynamicOption, String)) -> Void)?
    private var searchResultHandler: ((SearchResultViewModel) -> Void)?
    private var noResultsHandler: (() -> Void)?
    private var searchResultModel: Codable?
    
    let config: SearchViewController.Config
    
    init(config: SearchViewController.Config) {
        self.config = config
    }
    
    public func registerSearchResultHandler(_ block: @escaping (SearchResultViewModel) -> Void) {
        searchResultHandler = block
    }
    
    public func registerNoResultsHandler(_ block: @escaping () -> Void) {
        noResultsHandler = block
    }
    
    public func executeSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let queryParams = buildQueryParameters()
        let request = APIRequest(endpoint: config.type.endpoint, queryParameters: queryParams)
        
        switch config.type.endpoint {
        case .character:
            makeSearchAPICall(CharactersResponse.self, request: request)
        case .episode:
            makeSearchAPICall(EpisodesResponse.self, request: request)
        case .location:
            makeSearchAPICall(LocationsResponse.self, request: request)
        }
    }
    
    private func buildQueryParameters() -> [URLQueryItem] {
        var queryParams: [URLQueryItem] = [
            URLQueryItem(name: "name", value: searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        ]
        
        queryParams.append(contentsOf: optionMap.compactMap { element in
            let key = element.key
            let value = element.value
            return URLQueryItem(name: key.queryArgument, value: value)
        })
        
        return queryParams
    }
    
    private func makeSearchAPICall<T: Codable>(_ type: T.Type, request: APIRequest) {
        APIService.shared.execute(request, expecting: type) { [weak self] result in
            switch result {
            case .success(let model):
                self?.processSearchResults(model: model)
            case .failure:
                self?.handleNoResults()
            }
        }
    }
    
    private func processSearchResults(model: Codable) {
        var resultsVM: SearchResultType?
        var nextUrl: String?
        
        switch model {
        case let characterResults as CharactersResponse:
            resultsVM = .characters(characterResults.results.compactMap {
                CharacterCollectionViewCellViewModel(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    characterImageUrl: URL(string: $0.image)
                )
            })
            nextUrl = characterResults.info.next
            
        case let episodesResults as EpisodesResponse:
            resultsVM = .episodes(episodesResults.results.compactMap {
                CharacterEpisodeCollectionViewCellViewModel(
                    episodeDataUrl: URL(string: $0.url)
                )
            })
            nextUrl = episodesResults.info.next
            
        case let locationsResults as LocationsResponse:
            resultsVM = .locations(locationsResults.results.compactMap {
                LocationTableViewCellViewModel(location: $0)
            })
            nextUrl = locationsResults.info.next
        default:
            print("Unexpected response model type")
        }
        
        if let results = resultsVM {
            searchResultModel = model
            let vm = SearchResultViewModel(results: results, next: nextUrl)
            searchResultHandler?(vm)
        } else {
            handleNoResults()
        }
    }
    
    private func handleNoResults() {
        noResultsHandler?()
    }
    
    public func set(query text: String) {
        searchText = text
    }
    
    public func set(value: String, for option: SearchInputViewModel.DynamicOption) {
        optionMap[option] = value
        let tuple = (option, value)
        optionMapUpdateBlock?(tuple)
    }
    
    public func registerOptionChangeBlock(
        _ block: @escaping ((SearchInputViewModel.DynamicOption, String)) -> Void
    ) {
        optionMapUpdateBlock = block
    }
    
    public func locationSearchResult(at index: Int) -> Location? {
        (searchResultModel as? LocationsResponse)?.results[index]
    }
    
    public func characterSearchResult(at index: Int) -> Character? {
        (searchResultModel as? CharactersResponse)?.results[index]
    }
    
    public func episodeSearchResult(at index: Int) -> Episode? {
        (searchResultModel as? EpisodesResponse)?.results[index]
    }
}
