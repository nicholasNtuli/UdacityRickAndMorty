import Foundation

protocol LocationViewModelDelegate: AnyObject {
    func fetchInitialLocations()
}

final class LocationViewModel {

    weak var delegate: LocationViewModelDelegate?
    private var apiInfo: LocationsResponse.Info?
    private(set) var cellViewModels: [LocationTableViewCellViewModel] = []
    var isLoadingMoreLocations = false
    private var finishPagination: (() -> Void)?

    private var locations: [Location] = [] {
        didSet {
            updateCellViewModels()
        }
    }

    var shouldShowLoadMoreIndicator: Bool {
        return apiInfo?.next != nil
    }

    func registerFinishPaginationBlock(_ block: @escaping () -> Void) {
        finishPagination = block
    }

    func fetchAdditionalLocations() {
        guard !isLoadingMoreLocations, let nextUrlString = apiInfo?.next, let url = URL(string: nextUrlString), let request = APIRequest(url: url) else {
            return
        }

        isLoadingMoreLocations = true

        APIService.shared.execute(request, expecting: LocationsResponse.self) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let responseModel):
                let moreResults = responseModel.results
                let info = responseModel.info
                strongSelf.apiInfo = info
                strongSelf.cellViewModels.append(contentsOf: moreResults.map { LocationTableViewCellViewModel(location: $0) })

                DispatchQueue.main.async {
                    strongSelf.isLoadingMoreLocations = false
                    strongSelf.finishPagination?()
                }
            case .failure(let failure):
                print(String(describing: failure))
                self?.isLoadingMoreLocations = false
            }
        }
    }

    func location(at index: Int) -> Location? {
        guard index < locations.count, index >= 0 else {
            return nil
        }
        return locations[index]
    }

    func fetchLocations() {
        APIService.shared.execute(
            .listLocationsRequest,
            expecting: LocationsResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let model):
                self?.apiInfo = model.info
                self?.locations = model.results
                DispatchQueue.main.async {
                    self?.delegate?.fetchInitialLocations()
                }
            case .failure(_):
                break
            }
        }
    }

    private func updateCellViewModels() {
        locations.forEach { location in
            let cellViewModel = LocationTableViewCellViewModel(location: location)
            if !cellViewModels.contains(cellViewModel) {
                cellViewModels.append(cellViewModel)
            }
        }
    }
}
