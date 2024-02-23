import Foundation
import UIKit

protocol LocationDetailViewModelDelegate: AnyObject {
    func downloadLocationDetails()
    func downloadLocationDetailsFailed(error: Error)
}

final class LocationDetailViewModel {
    
    private let locationDetailEndpointURL: URL?
    weak var locationDetailDelegate: LocationDetailViewModelDelegate?
    private(set) var locationDetailCellViewModels: [LocationDetailSectionType] = []
    
    private var locationDetailDataArray: (location: Location, characters: [Character])? {
        didSet {
            locationDetailCreateCellViewModels()
            locationDetailDelegate?.downloadLocationDetails()
        }
    }
    
    enum LocationDetailSectionType {
        case locationDetailInformation(viewModels: [EpisodeDetailCollectionViewCellViewModel])
        case locationDetailCharacters(viewModel: [CharacterCollectionViewCellViewModel])
    }
    
    init(locationDetailEndpointURL: URL?) {
        self.locationDetailEndpointURL = locationDetailEndpointURL
    }
    func locationDetailCharacter(at index: Int) -> Character? {
        locationDetailDataArray?.characters[safe: index]
    }
    
    private func locationDetailCreateCellViewModels() {
        guard let locationDetailDataArray = locationDetailDataArray else {
            return
        }
        
        let locationDetailData = locationDetailDataArray.location
        let locationDetailCharacters = locationDetailDataArray.characters
        let locationDetailString = formattedlocationDetailString(from: locationDetailData.created)
        
        locationDetailCellViewModels = [
            .locationDetailInformation(viewModels: [
                .init(episodeDetailCollectionViewCellTitle: "Location Name", episodeDetailCollectionViewCellValue: locationDetailData.name),
                .init(episodeDetailCollectionViewCellTitle: "`CharInfoType`", episodeDetailCollectionViewCellValue: locationDetailData.type),
                .init(episodeDetailCollectionViewCellTitle: "Dimension", episodeDetailCollectionViewCellValue: locationDetailData.dimension),
                .init(episodeDetailCollectionViewCellTitle: "Created", episodeDetailCollectionViewCellValue: locationDetailString),
            ]),
            .locationDetailCharacters(viewModel: locationDetailCharacters.map(characterViewModel))
        ]
    }
    
    func downloadLocationData() {
        guard let locationDetailURL = locationDetailEndpointURL, let locationDetailRequest = APIRequest(url: locationDetailURL) else {
            return
        }
        
        APIService.shared.execute(locationDetailRequest, expecting: Location.self) { [weak self] locationDetailResult in
            switch locationDetailResult {
            case .success(let locationDetailModel):
                self?.fetchRelatedCharacters(locationDetail: locationDetailModel)
            case .failure(let error):
                self?.locationDetailDelegate?.downloadLocationDetailsFailed(error: error)
            }
        }
    }
    
    private func fetchRelatedCharacters(locationDetail: Location) {
        let locationDetailRequests: [APIRequest] = locationDetail.residents.compactMap { URL(string: $0) }.compactMap { APIRequest(url: $0) }
        let locationDetailGroup = DispatchGroup()
        var locationDetailCharacters: [Character] = []
        
        for locationDetailRequest in locationDetailRequests {
            locationDetailGroup.enter()
            APIService.shared.execute(locationDetailRequest, expecting: Character.self) { locationDetailResult in
                defer {
                    locationDetailGroup.leave()
                }
                
                switch locationDetailResult {
                case .success(let locationDetailModel):
                    locationDetailCharacters.append(locationDetailModel)
                case .failure(let error):
                    self.locationDetailDelegate?.downloadLocationDetailsFailed(error: error)
                }
            }
        }
        
        locationDetailGroup.notify(queue: .main) {
            self.locationDetailDataArray = (
                location: locationDetail,
                characters: locationDetailCharacters
            )
        }
    }
    
    private func formattedlocationDetailString(from locationDetailDateString: String) -> String {
        guard let locationDetailDate = CharacterInformationSectionViewModel.longFromattedDate.date(from: locationDetailDateString) else {
            return locationDetailDateString
        }
        return CharacterInformationSectionViewModel.shortFormattedDate.string(from: locationDetailDate)
    }
    
    private func characterViewModel(from locationDetailCharacter: Character) -> CharacterCollectionViewCellViewModel {
        CharacterCollectionViewCellViewModel(
            characterCollectionViewCellCharacterName: locationDetailCharacter.name,
            characterCollectionViewCellCharacterStatus: locationDetailCharacter.status,
            characterCollectionViewCellCharacterImageUrl: URL(string: locationDetailCharacter.image)
        )
    }
    
    func downloadLocationDetailsFailed(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let topViewController = windowScene.windows.first?.rootViewController {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
}

