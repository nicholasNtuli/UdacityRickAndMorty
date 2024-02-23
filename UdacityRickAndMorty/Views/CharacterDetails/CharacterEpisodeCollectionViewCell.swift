import UIKit

protocol FavourtiesDelegate {
    func addToFavourites(cell: UICollectionViewCell, indexPath: IndexPath)
}

class CharacterEpisodeCollectionViewCell: UICollectionViewCell {
    
    static let resueCellIdentifier = "CharacterEpisodeCollectionViewCell"
    
    var indexPath: IndexPath?
    var favouritesDelegate: FavourtiesDelegate?
    
    private let characterEpisodeCollectionViewSeasonLabel: UILabel = {
        let characterEpisodeCollectionViewSeasonLabel = UILabel()
        characterEpisodeCollectionViewSeasonLabel.translatesAutoresizingMaskIntoConstraints = false
        characterEpisodeCollectionViewSeasonLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        return characterEpisodeCollectionViewSeasonLabel
    }()
    
    private let characterEpisodeCollectionViewNameLabel: UILabel = {
        let characterEpisodeCollectionViewNameLabel = UILabel()
        characterEpisodeCollectionViewNameLabel.translatesAutoresizingMaskIntoConstraints = false
        characterEpisodeCollectionViewNameLabel.font = .systemFont(ofSize: 22, weight: .regular)
        return characterEpisodeCollectionViewNameLabel
    }()
    
    private let characterEpisodeCollectionViewAirDateLabel: UILabel = {
        let characterEpisodeCollectionViewAirDateLabel = UILabel()
        characterEpisodeCollectionViewAirDateLabel.translatesAutoresizingMaskIntoConstraints = false
        characterEpisodeCollectionViewAirDateLabel.font = .systemFont(ofSize: 18, weight: .light)
        return characterEpisodeCollectionViewAirDateLabel
    }()
    
    lazy var addToFavouriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.addTarget(self, action: #selector(addEpisodeToFavourite), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .tertiarySystemBackground
        characterEpisodeCollectionViewLayerSetup()
        contentView.addCharacterDetailLoadingIndicatorSubviews(characterEpisodeCollectionViewSeasonLabel, addToFavouriteButton, characterEpisodeCollectionViewNameLabel, characterEpisodeCollectionViewAirDateLabel)
        setUcharacterEpisodeCollectionViewConstraintsSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func addEpisodeToFavourite() {
        favouritesDelegate?.addToFavourites(cell: self, indexPath: indexPath ?? IndexPath(row: 0, section: 0))
    }
    
    private func characterEpisodeCollectionViewLayerSetup() {
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 2
    }
    
    private func setUcharacterEpisodeCollectionViewConstraintsSetup() {
        NSLayoutConstraint.activate([
            characterEpisodeCollectionViewSeasonLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            characterEpisodeCollectionViewSeasonLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            characterEpisodeCollectionViewSeasonLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            characterEpisodeCollectionViewSeasonLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3),
            
            addToFavouriteButton.topAnchor.constraint(equalTo: characterEpisodeCollectionViewSeasonLabel.bottomAnchor),
            addToFavouriteButton.widthAnchor.constraint(equalToConstant: 30),
            addToFavouriteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            addToFavouriteButton.heightAnchor.constraint(equalToConstant: 30),
            
            characterEpisodeCollectionViewNameLabel.topAnchor.constraint(equalTo: characterEpisodeCollectionViewSeasonLabel.bottomAnchor),
            characterEpisodeCollectionViewNameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            characterEpisodeCollectionViewNameLabel.rightAnchor.constraint(equalTo: addToFavouriteButton.leftAnchor, constant: -10),
            characterEpisodeCollectionViewNameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3),
            
            characterEpisodeCollectionViewAirDateLabel.topAnchor.constraint(equalTo: characterEpisodeCollectionViewNameLabel.bottomAnchor),
            characterEpisodeCollectionViewAirDateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            characterEpisodeCollectionViewAirDateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            characterEpisodeCollectionViewAirDateLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        characterEpisodeCollectionViewSeasonLabel.text = nil
        characterEpisodeCollectionViewNameLabel.text = nil
        characterEpisodeCollectionViewAirDateLabel.text = nil
    }
    
    public func characterEpisodeCollectionViewConfiguration(with characterEpisodeCollectionViewViewModel: CharacterEpisodeSectionViewModel) {
        characterEpisodeCollectionViewViewModel.characterEpisodeRegisterData { [weak self] characterEpisodeCollectionViewData in
            self?.characterEpisodeCollectionViewNameLabel.text = characterEpisodeCollectionViewData.name
            self?.characterEpisodeCollectionViewSeasonLabel.text = "Episode "+characterEpisodeCollectionViewData.episode
            self?.characterEpisodeCollectionViewAirDateLabel.text = "Aired on "+characterEpisodeCollectionViewData.air_date
        }
        
        characterEpisodeCollectionViewViewModel.fetchCharacterEpisode()
        contentView.layer.borderColor = characterEpisodeCollectionViewViewModel.characterEpisodeBorderColor.cgColor
    }
}
