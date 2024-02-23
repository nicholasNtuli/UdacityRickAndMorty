import UIKit

protocol EpisodeDetailViewModelDelegate: AnyObject {
    func downloadEpisodeDetails()
    func showAlert(title: String, message: String)
}

final class EpisodeDetailViewModel {
    private let episodeDetailEndpointURL: URL?
    private var episodeDetailDataSetup: (episode: Episode, characters: [Character])? {
        didSet {
            createEpisodeDetailCellViewModels()
            episodeDetailDelegate?.downloadEpisodeDetails()
        }
    }

    enum EpisodeDetailSectionType {
        case episodeDetailInformation(viewModels: [EpisodeDetailCollectionViewCellViewModel])
        case episodeDetailCharacters(viewModel: [CharacterCollectionViewCellViewModel])
    }

    weak var episodeDetailDelegate: EpisodeDetailViewModelDelegate?
    private(set) var episodeDetailCellViewModels: [EpisodeDetailSectionType] = []

    init(episodeDetailEndpointURL: URL?) {
        self.episodeDetailEndpointURL = episodeDetailEndpointURL
    }

    func episodeDetailCharacter(at index: Int) -> Character? {
        episodeDetailDataSetup?.characters[safe: index]
    }

    private func createEpisodeDetailCellViewModels() {
        guard let episodeDetailDataSetup = episodeDetailDataSetup else {
            return
        }

        let episodeDetail = episodeDetailDataSetup.episode
        let episodeDetailCharacters = episodeDetailDataSetup.characters
        let episodeDetailString = formattedDateString(from: episodeDetail.created)

        episodeDetailCellViewModels = [
            .episodeDetailInformation(viewModels: [
                .init(episodeDetailCollectionViewCellTitle: "Episode Name", episodeDetailCollectionViewCellValue: episodeDetail.name),
                .init(episodeDetailCollectionViewCellTitle: "Air Date", episodeDetailCollectionViewCellValue: episodeDetail.air_date),
                .init(episodeDetailCollectionViewCellTitle: "Episode", episodeDetailCollectionViewCellValue: episodeDetail.episode),
                .init(episodeDetailCollectionViewCellTitle: "Created", episodeDetailCollectionViewCellValue: episodeDetailString),
            ]),
            .episodeDetailCharacters(viewModel: episodeDetailCharacters.map(characterViewModel))
        ]
    }

    func downloadepisodeDetail() {
        guard let url = episodeDetailEndpointURL, let request = APIRequest(url: url) else {
            return
        }

        APIService.shared.execute(request, expecting: Episode.self) { [weak self] episodeDetailResult in
            switch episodeDetailResult {
            case .success(let episodeDetailModel):
                self?.downloadEpisodeDetailCharacters(episodeDetail: episodeDetailModel)
            case .failure(let error):
                self?.episodeDetailDelegate?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    private func downloadEpisodeDetailCharacters(episodeDetail: Episode) {
        let episodeDetailRequests: [APIRequest] = episodeDetail.characters.compactMap { URL(string: $0) }.compactMap { APIRequest(url: $0) }
        let episodeDetailGroup = DispatchGroup()
        var episodeDetailCharacters: [Character] = []

        for episodeDetailRequest in episodeDetailRequests {
            episodeDetailGroup.enter()
            APIService.shared.execute(episodeDetailRequest, expecting: Character.self) { episodeDetailResult in
                defer {
                    episodeDetailGroup.leave()
                }

                switch episodeDetailResult {
                case .success(let episodeDetailModel):
                    episodeDetailCharacters.append(episodeDetailModel)
                case .failure(let error):
                    self.episodeDetailDelegate?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        episodeDetailGroup.notify(queue: .main) {
            self.episodeDetailDataSetup = (
                episode: episodeDetail,
                characters: episodeDetailCharacters
            )
        }
    }

    private func formattedDateString(from episodeDetailDateString: String) -> String {
        guard let episodeDetailDate = CharacterInformationSectionViewModel.longFromattedDate.date(from: episodeDetailDateString) else {
            return episodeDetailDateString
        }
        return CharacterInformationSectionViewModel.shortFormattedDate.string(from: episodeDetailDate)
    }

    private func characterViewModel(from characterForEpisodeDetail: Character) -> CharacterCollectionViewCellViewModel {
        CharacterCollectionViewCellViewModel(
            characterCollectionViewCellCharacterName: characterForEpisodeDetail.name,
            characterCollectionViewCellCharacterStatus: characterForEpisodeDetail.status,
            characterCollectionViewCellCharacterImageUrl: URL(string: characterForEpisodeDetail.image)
        )
    }
}
