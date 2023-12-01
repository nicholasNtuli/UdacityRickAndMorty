import UIKit

final class CharacterCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CharacterCollectionViewCell"

    private let characterCollectionViewNameLabel: UILabel = {
        let lacharacterCollectionViewNameLabel = UILabel()
        lacharacterCollectionViewNameLabel.textColor = .label
        lacharacterCollectionViewNameLabel.font = .systemFont(ofSize: 18, weight: .medium)
        lacharacterCollectionViewNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return lacharacterCollectionViewNameLabel
    }()
    
    private let characterCollectionViewStatusLabel: UILabel = {
        let characterCollectionViewStatusLabel = UILabel()
        characterCollectionViewStatusLabel.textColor = .secondaryLabel
        characterCollectionViewStatusLabel.font = .systemFont(ofSize: 16, weight: .regular)
        characterCollectionViewStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        return characterCollectionViewStatusLabel
    }()

    private let characterCollectionViewImageView: UIImageView = {
        let characterCollectionViewImageView = UIImageView()
        characterCollectionViewImageView.contentMode = .scaleAspectFill
        characterCollectionViewImageView.clipsToBounds = true
        characterCollectionViewImageView.translatesAutoresizingMaskIntoConstraints = false
        return characterCollectionViewImageView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addCharacterDetailLoadingIndicatorSubviews(characterCollectionViewImageView, characterCollectionViewNameLabel, characterCollectionViewStatusLabel)
        addCharacterCollectionViewConstraints()
        characterCollectionViewLayerSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    private func characterCollectionViewLayerSetup() {
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor.label.cgColor
        contentView.layer.cornerRadius = 4
        contentView.layer.shadowOffset = CGSize(width: -4, height: 4)
        contentView.layer.shadowOpacity = 0.3
    }

    private func addCharacterCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            characterCollectionViewStatusLabel.heightAnchor.constraint(equalToConstant: 30),
            characterCollectionViewNameLabel.heightAnchor.constraint(equalToConstant: 30),

            characterCollectionViewStatusLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 7),
            characterCollectionViewStatusLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -7),
            characterCollectionViewNameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 7),
            characterCollectionViewNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -7),

            characterCollectionViewStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            characterCollectionViewNameLabel.bottomAnchor.constraint(equalTo: characterCollectionViewStatusLabel.topAnchor),

            characterCollectionViewImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            characterCollectionViewImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            characterCollectionViewImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            characterCollectionViewImageView.bottomAnchor.constraint(equalTo: characterCollectionViewNameLabel.topAnchor, constant: -3),
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
                characterCollectionViewLayerSetup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        characterCollectionViewImageView.image = nil
        characterCollectionViewNameLabel.text = nil
        characterCollectionViewStatusLabel.text = nil
    }

    public func characterCollectionViewConfigure(with characterCollectionViewViewModel: CharacterCollectionViewCellViewModel) {
        characterCollectionViewNameLabel.text = characterCollectionViewViewModel.characterCollectionViewCellCharacterName
        characterCollectionViewStatusLabel.text = characterCollectionViewViewModel.characterCollectionViewCellCharacterStatusText
        characterCollectionViewViewModel.fetchCharacterCollectionViewCellImage { [weak self] characterCollectionViewResult in
            switch characterCollectionViewResult {
            case .success(let characterCollectionViewData):
                DispatchQueue.main.async {
                    let characterCollectionViewImage = UIImage(data: characterCollectionViewData)
                    self?.characterCollectionViewImageView.image = characterCollectionViewImage
                }
            case .failure(let characterCollectionViewError):
                print(String(describing: characterCollectionViewError))
                break
            }
        }
    }
}
