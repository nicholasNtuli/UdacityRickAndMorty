import UIKit
import RealmSwift

protocol EpisodeDataProtocol {
    var name: String { get }
    var air_date: String { get }
    var episode: String { get }
    var url: String { get }
    var created: String { get }
}

class EpisodeData: Object, EpisodeDataProtocol {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var air_date: String = ""
    @objc dynamic var episode: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var created: String = ""
    
    convenience init(name: String, air_date: String, episode: String, url: String, created: String) {
        self.init()
        self.name = name
        self.air_date = air_date
        self.episode = episode
        self.url = url
        self.created = created
    }
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
