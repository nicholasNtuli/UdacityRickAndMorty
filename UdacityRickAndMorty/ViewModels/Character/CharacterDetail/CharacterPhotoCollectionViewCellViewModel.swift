import Foundation

final class CharacterPhotoCollectionViewCellViewModel {
    private let imageUrl: URL?

    init(imageUrl: URL?) {
        self.imageUrl = imageUrl
    }

    func fetchImage(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let imageUrl = imageUrl else {
            completion(.failure(URLError(.badURL)))
            return
        }

        APIImageLoader.shared.downloadImage(from: imageUrl, completion: completion)
    }
}
