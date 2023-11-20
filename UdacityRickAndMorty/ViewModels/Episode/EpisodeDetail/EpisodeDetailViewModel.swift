import UIKit

protocol EpisodeDetailViewModelDelegate: AnyObject {
    func fetchEpisodeDetails()
}

final class EpisodeDetailViewModel {
    private let endpointUrl: URL?
    private var dataTuple: (episode: Episode, characters: [Character])? {
        didSet {
            createCellViewModels()
            delegate?.fetchEpisodeDetails()
        }
    }

    enum SectionType {
        case information(viewModels: [EpisodeDetailCollectionViewCellViewModel])
        case characters(viewModel: [CharacterCollectionViewCellViewModel])
    }

    weak var delegate: EpisodeDetailViewModelDelegate?
    private(set) var cellViewModels: [SectionType] = []

    init(endpointUrl: URL?) {
        self.endpointUrl = endpointUrl
    }

    func character(at index: Int) -> Character? {
        dataTuple?.characters[safe: index]
    }

    private func createCellViewModels() {
        guard let dataTuple = dataTuple else {
            return
        }

        let episode = dataTuple.episode
        let characters = dataTuple.characters

        let createdString = formattedDateString(from: episode.created)

        cellViewModels = [
            .information(viewModels: [
                .init(title: "Episode Name", value: episode.name),
                .init(title: "Air Date", value: episode.air_date),
                .init(title: "Episode", value: episode.episode),
                .init(title: "Created", value: createdString),
            ]),
            .characters(viewModel: characters.map(characterViewModel))
        ]
    }

    func fetchEpisodeData() {
        guard let url = endpointUrl, let request = APIRequest(url: url) else {
            return
        }

        APIService.shared.execute(request, expecting: Episode.self) { [weak self] result in
            switch result {
            case .success(let model):
                self?.fetchRelatedCharacters(episode: model)
            case .failure:
                break
            }
        }
    }

    private func fetchRelatedCharacters(episode: Episode) {
        let requests: [APIRequest] = episode.characters.compactMap { URL(string: $0) }.compactMap { APIRequest(url: $0) }

        let group = DispatchGroup()
        var characters: [Character] = []

        for request in requests {
            group.enter()
            APIService.shared.execute(request, expecting: Character.self) { result in
                defer {
                    group.leave()
                }

                switch result {
                case .success(let model):
                    characters.append(model)
                case .failure:
                    break
                }
            }
        }

        group.notify(queue: .main) {
            self.dataTuple = (
                episode: episode,
                characters: characters
            )
        }
    }

    private func formattedDateString(from dateString: String) -> String {
        guard let date = CharacterDetailCollectionViewCellViewModel.dateFormatter.date(from: dateString) else {
            return dateString
        }
        return CharacterDetailCollectionViewCellViewModel.shortDateFormatter.string(from: date)
    }

    private func characterViewModel(from character: Character) -> CharacterCollectionViewCellViewModel {
        CharacterCollectionViewCellViewModel(
            characterName: character.name,
            characterStatus: character.status,
            characterImageUrl: URL(string: character.image)
        )
    }
}
