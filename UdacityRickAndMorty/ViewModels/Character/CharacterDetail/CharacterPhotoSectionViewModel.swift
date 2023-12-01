import Foundation

final class CharacterPhotoSectionViewModel {
    private let characterPhotoURL: URL?

    init(characterPhotoURL: URL?) {
        self.characterPhotoURL = characterPhotoURL
    }

    func downloadCharacterPhoto(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let imageUrl = characterPhotoURL else {
            completion(.failure(URLError(.badURL)))
            return
        }

        APIImageLoader.shared.downloadImage(from: imageUrl, completion: completion)
    }
}
