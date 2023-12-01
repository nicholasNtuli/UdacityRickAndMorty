import Foundation

final class CharacterCollectionViewCellViewModel: Hashable, Equatable {
    
    var characterCollectionViewCellCharacterName: String
    var characterCollectionViewCellCharacterStatus: CharacterStatus
    var characterCollectionViewCellCharacterImageUrl: URL?
    
    init(characterCollectionViewCellCharacterName: String, characterCollectionViewCellCharacterStatus: CharacterStatus, characterCollectionViewCellCharacterImageUrl: URL? = nil) {
        self.characterCollectionViewCellCharacterName = characterCollectionViewCellCharacterName
        self.characterCollectionViewCellCharacterStatus = characterCollectionViewCellCharacterStatus
        self.characterCollectionViewCellCharacterImageUrl = characterCollectionViewCellCharacterImageUrl
    }
    
    var characterCollectionViewCellCharacterStatusText: String {
        return "Status: \(characterCollectionViewCellCharacterStatus.status)"
    }
    
    func fetchCharacterCollectionViewCellImage(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = characterCollectionViewCellCharacterImageUrl else {
            completion(.failure(URLError(.badURL)))
            return
        }
        APIImageLoader.shared.downloadImage(from: url, completion: completion)
    }
    
    static func == (lhs: CharacterCollectionViewCellViewModel, rhs: CharacterCollectionViewCellViewModel) -> Bool {
        return lhs.characterCollectionViewCellCharacterName == rhs.characterCollectionViewCellCharacterName &&
               lhs.characterCollectionViewCellCharacterStatus == rhs.characterCollectionViewCellCharacterStatus &&
               lhs.characterCollectionViewCellCharacterImageUrl == rhs.characterCollectionViewCellCharacterImageUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(characterCollectionViewCellCharacterName)
        hasher.combine(characterCollectionViewCellCharacterStatus)
        hasher.combine(characterCollectionViewCellCharacterImageUrl)
    }
}
