import Foundation

protocol LocationDetailViewModelDelegate: AnyObject {
    func fetchLocationDetails()
}

final class LocationDetailViewModel {
    private let endpointUrl: URL?
    weak var delegate: LocationDetailViewModelDelegate?
    private(set) var cellViewModels: [SectionType] = []

    private var dataTuple: (location: Location, characters: [Character])? {
        didSet {
            createCellViewModels()
            delegate?.fetchLocationDetails()
        }
    }

    enum SectionType {
        case information(viewModels: [EpisodeDetailCollectionViewCellViewModel])
        case characters(viewModel: [CharacterCollectionViewCellViewModel])
    }

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

        let location = dataTuple.location
        let characters = dataTuple.characters

        let createdString = formattedDateString(from: location.created)

        cellViewModels = [
            .information(viewModels: [
                .init(title: "Location Name", value: location.name),
                .init(title: "Type", value: location.type),
                .init(title: "Dimension", value: location.dimension),
                .init(title: "Created", value: createdString),
            ]),
            .characters(viewModel: characters.map(characterViewModel))
        ]
    }

    func fetchLocationData() {
        guard let url = endpointUrl, let request = APIRequest(url: url) else {
            return
        }

        APIService.shared.execute(request, expecting: Location.self) { [weak self] result in
            switch result {
            case .success(let model):
                self?.fetchRelatedCharacters(location: model)
            case .failure:
                break
            }
        }
    }

    private func fetchRelatedCharacters(location: Location) {
        let requests: [APIRequest] = location.residents.compactMap { URL(string: $0) }.compactMap { APIRequest(url: $0) }

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
                location: location,
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

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
