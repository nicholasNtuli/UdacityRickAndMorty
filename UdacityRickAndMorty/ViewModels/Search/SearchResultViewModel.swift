import Foundation

final class SearchResultViewModel {
    
    public private(set) var searchResults: SearchResultType
    private var nextSearchResult: String?
    public private(set) var searchResultsLoading = false

    init(searchResults: SearchResultType, next: String?) {
        self.searchResults = searchResults
        self.nextSearchResult = next
    }

    public var searchResultLoadingIndicator: Bool {
        return nextSearchResult != nil
    }

    public func downloadAdditionalSearchResults(completion: @escaping ([LocationTableViewCellViewModel]) -> Void) {
        guard !searchResultsLoading else {
            return
        }

        guard let nextSearchResultsURLString = nextSearchResult,
              let searchResultsURL = URL(string: nextSearchResultsURLString) else {
            return
        }

        searchResultsLoading = true

        guard let searchResultsRequest = APIRequest(url: searchResultsURL) else {
            searchResultsLoading = false
            return
        }

        APIService.shared.execute(searchResultsRequest, expecting: LocationsResponse.self) { [weak self] searchResultsResult in
            guard let strongSelf = self else {
                return
            }
            switch searchResultsResult {
            case .success(let searchResultsResponseModel):
                let additionalSearchResults = searchResultsResponseModel.results
                let searchResultsInfo = searchResultsResponseModel.info
                strongSelf.nextSearchResult = searchResultsInfo.next

                let additionalSearchResultsLocations = additionalSearchResults.compactMap({
                    return LocationTableViewCellViewModel(locationTable: $0)
                })
                
                var newSearchResults: [LocationTableViewCellViewModel] = []

                switch strongSelf.searchResults {
                case .locations(let existingResults):
                    newSearchResults = existingResults + additionalSearchResultsLocations
                    strongSelf.searchResults = .locations(newSearchResults)
                    break
                case .characters, .episodes:
                    break
                }

                DispatchQueue.main.async {
                    strongSelf.searchResultsLoading = false
                    completion(newSearchResults)
                }
            case .failure(let failure):
                print(String(describing: failure))
                self?.searchResultsLoading = false
            }
        }
    }

    public func downloadAdditionalSearchResults(completion: @escaping ([any Hashable]) -> Void) {
        guard !searchResultsLoading else {
            return
        }

        guard let nextSearchResultsString = nextSearchResult,
              let searchResultURL = URL(string: nextSearchResultsString) else {
            return
        }

        searchResultsLoading = true

        guard let searchRequest = APIRequest(url: searchResultURL) else {
            searchResultsLoading = false
            return
        }

        switch searchResults {
        case .characters(let existingSearchResults):
            APIService.shared.execute(searchRequest, expecting: CharactersResponse.self) { [weak self] searchResult in
                guard let strongSelf = self else {
                    return
                }
                switch searchResult {
                case .success(let searchReaserchResponseModel):
                    let additionalSearchResults = searchReaserchResponseModel.results
                    let searchResultsInfo = searchReaserchResponseModel.info
                    strongSelf.nextSearchResult = searchResultsInfo.next

                    let additionalResults = additionalSearchResults.compactMap({
                        return CharacterCollectionViewCellViewModel(characterCollectionViewCellCharacterName: $0.name,
                                                                    characterCollectionViewCellCharacterStatus: $0.status,
                                                                    characterCollectionViewCellCharacterImageUrl: URL(string: $0.image))
                    })
                    var newSearchResults: [CharacterCollectionViewCellViewModel] = []
                    newSearchResults = existingSearchResults + additionalResults
                    strongSelf.searchResults = .characters(newSearchResults)

                    DispatchQueue.main.async {
                        strongSelf.searchResultsLoading = false
                        completion(newSearchResults)
                    }
                case .failure(let searchResuktsFailure):
                    print(String(describing: searchResuktsFailure))
                    self?.searchResultsLoading = false
                }
            }
        case .episodes(let existingSearchResults):
            APIService.shared.execute(searchRequest, expecting: EpisodesResponse.self) { [weak self] searchRequestResults in
                guard let strongSelf = self else {
                    return
                }
                switch searchRequestResults {
                case .success(let searchRequestResponseModel):
                    let additionalSearchResults = searchRequestResponseModel.results
                    let searchResultsInfo = searchRequestResponseModel.info
                    strongSelf.nextSearchResult = searchResultsInfo.next

                    let additionalResultForSearch = additionalSearchResults.compactMap({
                        return CharacterEpisodeSectionViewModel(characterEpisodeBaseURL: URL(string: $0.url))
                    })
                    
                    var newSearchResults: [CharacterEpisodeSectionViewModel] = []
                    newSearchResults = existingSearchResults + additionalResultForSearch
                    strongSelf.searchResults = .episodes(newSearchResults)

                    DispatchQueue.main.async {
                        strongSelf.searchResultsLoading = false
                        completion(newSearchResults)
                    }
                case .failure(let seachResultsFailure):
                    print(String(describing: seachResultsFailure))
                    self?.searchResultsLoading = false
                }
            }
        case .locations:
            break
        }
    }
}

enum SearchResultType {
    case characters([CharacterCollectionViewCellViewModel])
    case episodes([CharacterEpisodeSectionViewModel])
    case locations([LocationTableViewCellViewModel])
}
