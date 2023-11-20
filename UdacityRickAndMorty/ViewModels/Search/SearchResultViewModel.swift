import Foundation

final class SearchResultViewModel {
    
    public private(set) var results: SearchResultType
    private var next: String?
    public private(set) var isLoadingMoreResults = false

    init(results: SearchResultType, next: String?) {
        self.results = results
        self.next = next
    }

    public var shouldShowLoadMoreIndicator: Bool {
        return next != nil
    }

    public func fetchAdditionalLocations(completion: @escaping ([LocationTableViewCellViewModel]) -> Void) {
        guard !isLoadingMoreResults else {
            return
        }

        guard let nextUrlString = next,
              let url = URL(string: nextUrlString) else {
            return
        }

        isLoadingMoreResults = true

        guard let request = APIRequest(url: url) else {
            isLoadingMoreResults = false
            return
        }

        APIService.shared.execute(request, expecting: LocationsResponse.self) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let responseModel):
                let moreResults = responseModel.results
                let info = responseModel.info
                strongSelf.next = info.next

                let additionalLocations = moreResults.compactMap({
                    return LocationTableViewCellViewModel(location: $0)
                })
                var newResults: [LocationTableViewCellViewModel] = []

                switch strongSelf.results {
                case .locations(let existingResults):
                    newResults = existingResults + additionalLocations
                    strongSelf.results = .locations(newResults)
                    break
                case .characters, .episodes:
                    break
                }

                DispatchQueue.main.async {
                    strongSelf.isLoadingMoreResults = false
                    completion(newResults)
                }
            case .failure(let failure):
                print(String(describing: failure))
                self?.isLoadingMoreResults = false
            }
        }
    }

    public func fetchAdditionalResults(completion: @escaping ([any Hashable]) -> Void) {
        guard !isLoadingMoreResults else {
            return
        }

        guard let nextUrlString = next,
              let url = URL(string: nextUrlString) else {
            return
        }

        isLoadingMoreResults = true

        guard let request = APIRequest(url: url) else {
            isLoadingMoreResults = false
            return
        }

        switch results {
        case .characters(let existingResults):
            APIService.shared.execute(request, expecting: CharactersResponse.self) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let responseModel):
                    let moreResults = responseModel.results
                    let info = responseModel.info
                    strongSelf.next = info.next

                    let additionalResults = moreResults.compactMap({
                        return CharacterCollectionViewCellViewModel(characterName: $0.name,
                                                                      characterStatus: $0.status,
                                                                      characterImageUrl: URL(string: $0.image))
                    })
                    var newResults: [CharacterCollectionViewCellViewModel] = []
                    newResults = existingResults + additionalResults
                    strongSelf.results = .characters(newResults)

                    DispatchQueue.main.async {
                        strongSelf.isLoadingMoreResults = false
                        completion(newResults)
                    }
                case .failure(let failure):
                    print(String(describing: failure))
                    self?.isLoadingMoreResults = false
                }
            }
        case .episodes(let existingResults):
            APIService.shared.execute(request, expecting: EpisodesResponse.self) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let responseModel):
                    let moreResults = responseModel.results
                    let info = responseModel.info
                    strongSelf.next = info.next

                    let additionalResults = moreResults.compactMap({
                        return CharacterEpisodeCollectionViewCellViewModel(episodeDataUrl: URL(string: $0.url))
                    })
                    var newResults: [CharacterEpisodeCollectionViewCellViewModel] = []
                    newResults = existingResults + additionalResults
                    strongSelf.results = .episodes(newResults)

                    DispatchQueue.main.async {
                        strongSelf.isLoadingMoreResults = false
                        completion(newResults)
                    }
                case .failure(let failure):
                    print(String(describing: failure))
                    self?.isLoadingMoreResults = false
                }
            }
        case .locations:
            break
        }
    }
}

enum SearchResultType {
    case characters([CharacterCollectionViewCellViewModel])
    case episodes([CharacterEpisodeCollectionViewCellViewModel])
    case locations([LocationTableViewCellViewModel])
}
