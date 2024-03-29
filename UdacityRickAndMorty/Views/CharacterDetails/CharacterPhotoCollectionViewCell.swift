import UIKit

final class CharacterPhotoCollectionViewCell: UICollectionViewCell {
    
    static let reuseCellIdentifier = "CharacterPhotoCollectionViewCell"
    
    private let characterPhotoCollectionImageView: UIImageView = {
        let characterPhotoCollectionImageView = UIImageView()
        characterPhotoCollectionImageView.contentMode = .scaleAspectFill
        characterPhotoCollectionImageView.clipsToBounds = true
        characterPhotoCollectionImageView.translatesAutoresizingMaskIntoConstraints = false
        return characterPhotoCollectionImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(characterPhotoCollectionImageView)
        characterPhotoCollectionConstraintsSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func characterPhotoCollectionConstraintsSetup() {
        NSLayoutConstraint.activate([
            characterPhotoCollectionImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            characterPhotoCollectionImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            characterPhotoCollectionImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            characterPhotoCollectionImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        characterPhotoCollectionImageView.image = nil
    }
    
    public func characterPhotoCollectionConfiguration(with characterPhotoCollectionViewModel: CharacterPhotoSectionViewModel) {
        characterPhotoCollectionViewModel.downloadCharacterPhoto { [weak self] characterPhotoCollectionResult in
            switch characterPhotoCollectionResult {
            case .success(let characterPhotoCollectionData):
                DispatchQueue.main.async {
                    self?.characterPhotoCollectionImageView.image = UIImage(data: characterPhotoCollectionData)
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.showFailureAlert()
                }
            }
        }
    }
    
    private func showFailureAlert() {
        let alertController = UIAlertController(title: "Error", message: "Failed to download character photo", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        if let viewController = self.window?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
