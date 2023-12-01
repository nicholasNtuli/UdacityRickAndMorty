import UIKit

protocol EpisodeDataProtocol {
    var name: String { get }
    var air_date: String { get }
    var episode: String { get }
}

final class CharacterEpisodeSectionViewModel: Hashable, Equatable {

    private let characterEpisodeBaseURL: URL?
    private var characterEpisodeDataFetcher = false
    private var characterEpisodeDataBlock: ((EpisodeDataProtocol) -> Void)?
    public let characterEpisodeBorderColor: UIColor

    private var characterEpisode: Episode? {
        didSet {
            guard let model = characterEpisode else {
                return
            }
            characterEpisodeDataBlock?(model)
        }
    }
    
    init(characterEpisodeBaseURL: URL?, characterEpisodeBorderColor: UIColor = .systemBlue) {
        self.characterEpisodeBaseURL = characterEpisodeBaseURL
        self.characterEpisodeBorderColor = characterEpisodeBorderColor
    }

    public func characterEpisodeRegisterData(_ block: @escaping (EpisodeDataProtocol) -> Void) {
        self.characterEpisodeDataBlock = block
    }

    public func fetchCharacterEpisode() {
        guard !characterEpisodeDataFetcher else {
            if let model = characterEpisode {
                characterEpisodeDataBlock?(model)
            }
            return
        }

        guard let url = characterEpisodeBaseURL,
              let request = APIRequest(url: url) else {
            return
        }

        characterEpisodeDataFetcher = true

        APIService.shared.execute(request, expecting: Episode.self) { [weak self] result in
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    self?.characterEpisode = model
                }
            case .failure(let failure):
                print(String(describing: failure))
            }
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.characterEpisodeBaseURL?.absoluteString ?? "")
    }

    static func == (lhs: CharacterEpisodeSectionViewModel, rhs: CharacterEpisodeSectionViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
