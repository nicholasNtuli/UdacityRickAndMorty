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
    
    public weak var delegate: EpisodeDetailViewModelDelegate?
    
    public private(set) var cellViewModels: [SectionType] = []
    
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
        
        let episode = dataTuple.episode
        let characters = dataTuple.characters
        
        var createdString = episode.created
        if let date = CharacterDetailCollectionViewCellViewModel.dateFormatter.date(from: episode.created) {
            createdString = CharacterDetailCollectionViewCellViewModel.shortDateFormatter.string(from: date)
        }
        
        cellViewModels = [
            .information(viewModels: [
                .init(title: "Episode Name", value: episode.name),
                .init(title: "Air Date", value: episode.air_date),
                .init(title: "Episode", value: episode.episode),
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
    
    public func fetchEpisodeData() {
        guard let url = endpointUrl,
              let request = Request(url: url) else {
            return
        }
        
        Service.shared.execute(request,
                                 expecting: Episode.self) { [weak self] result in
            switch result {
            case .success(let model):
                self?.fetchRelatedCharacters(episode: model)
            case .failure:
                break
            }
        }
    }
    
    private func fetchRelatedCharacters(episode: Episode) {
        let requests: [Request] = episode.characters.compactMap({
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
                episode: episode,
                characters: characters
            )
        }
    }
}
