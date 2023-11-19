import Foundation


protocol LocationDetailViewModelDelegate: AnyObject {
    func fetchLocationDetails()
}

final class LocationDetailViewModel {
    private let endpointUrl: URL?
    public weak var delegate: LocationDetailViewModelDelegate?
    public private(set) var cellViewModels: [SectionType] = []
    
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
    
    public func character(at index: Int) -> Character? {
        guard let dataTuple = dataTuple else {
            return nil
        }
        return dataTuple.characters[index]
    }
    
    private func createCellViewModels() {
        guard let dataTuple = dataTuple else {
            return
        }
        
        let location = dataTuple.location
        let characters = dataTuple.characters
        
        var createdString = location.created
        if let date = CharacterDetailCollectionViewCellViewModel.dateFormatter.date(from: location.created) {
            createdString = CharacterDetailCollectionViewCellViewModel.shortDateFormatter.string(from: date)
        }
        
        cellViewModels = [
            .information(viewModels: [
                .init(title: "Location Name", value: location.name),
                .init(title: "Type", value: location.type),
                .init(title: "Dimension", value: location.dimension),
                .init(title: "Created", value: createdString),
            ]),
            .characters(viewModel: characters.compactMap({ character in
                return CharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageUrl: URL(string: character.image)
                )
            }))
        ]
    }
    
    public func fetchLocationData() {
        guard let url = endpointUrl,
              let request = Request(url: url) else {
            return
        }
        
        Service.shared.execute(request,
                                 expecting: Location.self) { [weak self] result in
            switch result {
            case .success(let model):
                self?.fetchRelatedCharacters(location: model)
            case .failure:
                break
            }
        }
    }
    
    private func fetchRelatedCharacters(location: Location) {
        let requests: [Request] = location.residents.compactMap({
            return URL(string: $0)
        }).compactMap({
            return Request(url: $0)
        })
        
        let group = DispatchGroup()
        var characters: [Character] = []
        for request in requests {
            group.enter()
            Service.shared.execute(request, expecting: Character.self) { result in
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
}
