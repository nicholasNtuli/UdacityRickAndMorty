import Foundation

protocol LocationViewModelDelegate: AnyObject {
    func downloadLocations()
}

final class LocationViewModel {

    weak var locationViewModelDelegate: LocationViewModelDelegate?
    private var locationViewModelAPIInfo: LocationsResponse.Info?
    private(set) var locationViewModelCellViewModels: [LocationTableViewCellViewModel] = []
    var loadMoreLocations = false
    private var locationViewModelLoadingFinished: (() -> Void)?

    private var locationsArray: [Location] = [] {
        didSet {
            updateLocationCellViewModels()
        }
    }

    var shouldLocationLoadingIndicator: Bool {
        return locationViewModelAPIInfo?.next != nil
    }

    func registerlocationViewModelFinishedBlock(_ block: @escaping () -> Void) {
        locationViewModelLoadingFinished = block
    }

    func downloadLocations() {
        guard !loadMoreLocations, let nextUrlString = locationViewModelAPIInfo?.next, let url = URL(string: nextUrlString), let request = APIRequest(url: url) else {
            return
        }

        loadMoreLocations = true

        APIService.shared.execute(request, expecting: LocationsResponse.self) { [weak self] locationResult in
            guard let strongSelf = self else { return }

            switch locationResult {
            case .success(let locationResponseModel):
                let additionalLocationResults = locationResponseModel.results
                let locationInfo = locationResponseModel.info
                strongSelf.locationViewModelAPIInfo = locationInfo
                strongSelf.locationViewModelCellViewModels.append(contentsOf: additionalLocationResults.map { LocationTableViewCellViewModel(locationTable: $0) })

                DispatchQueue.main.async {
                    strongSelf.loadMoreLocations = false
                    strongSelf.locationViewModelLoadingFinished?()
                }
            case .failure(let failure):
                print(String(describing: failure))
                self?.loadMoreLocations = false
            }
        }
    }

    func location(at locationIndex: Int) -> Location? {
        guard locationIndex < locationsArray.count, locationIndex >= 0 else {
            return nil
        }
        return locationsArray[locationIndex]
    }

    func fetchLocations() {
        APIService.shared.execute(
            .listLocationsRequest,
            expecting: LocationsResponse.self
        ) { [weak self] locationResult in
            switch locationResult {
            case .success(let locationModel):
                self?.locationViewModelAPIInfo = locationModel.info
                self?.locationsArray = locationModel.results
                DispatchQueue.main.async {
                    self?.locationViewModelDelegate?.downloadLocations()
                }
            case .failure(_):
                break
            }
        }
    }

    private func updateLocationCellViewModels() {
        locationsArray.forEach { updateLocation in
            let locationCellViewModel = LocationTableViewCellViewModel(locationTable: updateLocation)
            if !locationViewModelCellViewModels.contains(locationCellViewModel) {
                locationViewModelCellViewModels.append(locationCellViewModel)
            }
        }
    }
}
