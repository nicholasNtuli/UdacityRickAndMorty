import UIKit

final class CharacterInfoCollectionViewCell: UICollectionViewCell {
   
    static let reuseCellIdentifier = "CharacterInfoCollectionViewCell"

    private let characterInformationCollectionTitleContainerView: UIView = {
        let characterInformationCollectionTileView = UIView()
        characterInformationCollectionTileView.translatesAutoresizingMaskIntoConstraints = false
        characterInformationCollectionTileView.backgroundColor = .secondarySystemBackground
        return characterInformationCollectionTileView
    }()
    
    private let characterInformationCollectionTitleLabel: UILabel = {
        let characterInformationCollectionTitleLabel = UILabel()
        characterInformationCollectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        characterInformationCollectionTitleLabel.textAlignment = .center
        characterInformationCollectionTitleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        return characterInformationCollectionTitleLabel
    }()
   
    private let characterInformationCollectionValueLabel: UILabel = {
        let characterInformationCollectionValueLabel = UILabel()
        characterInformationCollectionValueLabel.numberOfLines = 0
        characterInformationCollectionValueLabel.translatesAutoresizingMaskIntoConstraints = false
        characterInformationCollectionValueLabel.font = .systemFont(ofSize: 22, weight: .light)
        return characterInformationCollectionValueLabel
    }()

    private let characterInformationCollectionIconImageView: UIImageView = {
        let characterInformationCollectionIconImageView = UIImageView()
        characterInformationCollectionIconImageView.translatesAutoresizingMaskIntoConstraints = false
        characterInformationCollectionIconImageView.contentMode = .scaleAspectFit
        return characterInformationCollectionIconImageView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .tertiarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addCharacterDetailLoadingIndicatorSubviews(characterInformationCollectionTitleContainerView, characterInformationCollectionValueLabel, characterInformationCollectionIconImageView)
        characterInformationCollectionTitleContainerView.addSubview(characterInformationCollectionTitleLabel)
        characterInformationCollectionConstraintsSetup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func characterInformationCollectionConstraintsSetup() {
        NSLayoutConstraint.activate([
            characterInformationCollectionTitleContainerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            characterInformationCollectionTitleContainerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            characterInformationCollectionTitleContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            characterInformationCollectionTitleContainerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.33),

            characterInformationCollectionTitleLabel.leftAnchor.constraint(equalTo: characterInformationCollectionTitleContainerView.leftAnchor),
            characterInformationCollectionTitleLabel.rightAnchor.constraint(equalTo: characterInformationCollectionTitleContainerView.rightAnchor),
            characterInformationCollectionTitleLabel.topAnchor.constraint(equalTo: characterInformationCollectionTitleContainerView.topAnchor),
            characterInformationCollectionTitleLabel.bottomAnchor.constraint(equalTo: characterInformationCollectionTitleContainerView.bottomAnchor),

            characterInformationCollectionIconImageView.heightAnchor.constraint(equalToConstant: 30),
            characterInformationCollectionIconImageView.widthAnchor.constraint(equalToConstant: 30),
            characterInformationCollectionIconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 35),
            characterInformationCollectionIconImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),

            characterInformationCollectionValueLabel.leftAnchor.constraint(equalTo: characterInformationCollectionIconImageView.rightAnchor, constant: 10),
            characterInformationCollectionValueLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            characterInformationCollectionValueLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            characterInformationCollectionValueLabel.bottomAnchor.constraint(equalTo: characterInformationCollectionTitleContainerView.topAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        characterInformationCollectionValueLabel.text = nil
        characterInformationCollectionTitleLabel.text = nil
        characterInformationCollectionIconImageView.image = nil
        characterInformationCollectionIconImageView.tintColor = .label
        characterInformationCollectionTitleLabel.textColor = .label
    }

    public func characterInformationCollectionConfiguration(with characterInformationCollectionViewModel: CharacterInformationSectionViewModel) {
        characterInformationCollectionTitleLabel.text = characterInformationCollectionViewModel.charcterInformationTitle
        characterInformationCollectionValueLabel.text = characterInformationCollectionViewModel.charcterInformationDisplayValue
        characterInformationCollectionIconImageView.image = characterInformationCollectionViewModel.charcterInformationIconImage
        characterInformationCollectionIconImageView.tintColor = characterInformationCollectionViewModel.charcterInformationTintColor
        characterInformationCollectionTitleLabel.textColor = characterInformationCollectionViewModel.charcterInformationTintColor
    }
}
