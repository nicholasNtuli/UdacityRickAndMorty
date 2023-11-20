import Foundation

final class CharacterCollectionViewCellViewModel: Hashable, Equatable {
    
    let characterName: String
    private let characterStatus: CharacterStatus
    private let characterImageUrl: URL?
    
    init(
        characterName: String,
        characterStatus: CharacterStatus,
        characterImageUrl: URL?
    ) {
        self.characterName = characterName
        self.characterStatus = characterStatus
        self.characterImageUrl = characterImageUrl
    }
    
    var characterStatusText: String {
        return "Status: \(characterStatus.status)"
    }
    
    func fetchImage(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = characterImageUrl else {
            completion(.failure(URLError(.badURL)))
            return
        }
        APIImageLoader.shared.downloadImage(from: url, completion: completion)
    }
    
    static func == (lhs: CharacterCollectionViewCellViewModel, rhs: CharacterCollectionViewCellViewModel) -> Bool {
        return lhs.characterName == rhs.characterName &&
               lhs.characterStatus == rhs.characterStatus &&
               lhs.characterImageUrl == rhs.characterImageUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(characterName)
        hasher.combine(characterStatus)
        hasher.combine(characterImageUrl)
    }
}
