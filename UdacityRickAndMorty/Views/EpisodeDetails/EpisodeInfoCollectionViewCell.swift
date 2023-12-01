import UIKit

final class EpisodeInfoCollectionViewCell: UICollectionViewCell {
    
    static let episodeInfoCollectionViewCellIdentifier = "EpisodeInfoCollectionViewCell"

    private let episodeInfoCollectionViewTitleLabel: UILabel = {
        let episodeInfoCollectionViewTitleLabel = UILabel()
        episodeInfoCollectionViewTitleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        episodeInfoCollectionViewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return episodeInfoCollectionViewTitleLabel
    }()

    private let episodeInfoCollectionViewValueLabel: UILabel = {
        let episodeInfoCollectionViewValueLabel = UILabel()
        episodeInfoCollectionViewValueLabel.font = .systemFont(ofSize: 20, weight: .regular)
        episodeInfoCollectionViewValueLabel.textAlignment = .right
        episodeInfoCollectionViewValueLabel.numberOfLines = 0
        episodeInfoCollectionViewValueLabel.translatesAutoresizingMaskIntoConstraints = false
        return episodeInfoCollectionViewValueLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addCharacterDetailLoadingIndicatorSubviews(episodeInfoCollectionViewTitleLabel, episodeInfoCollectionViewValueLabel)
        episodeInfoCollectionViewLayerSetup()
        addEpisodeInfoCollectionViewConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func episodeInfoCollectionViewLayerSetup() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.secondaryLabel.cgColor
    }

    private func addEpisodeInfoCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            episodeInfoCollectionViewTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            episodeInfoCollectionViewTitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            episodeInfoCollectionViewTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            episodeInfoCollectionViewValueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            episodeInfoCollectionViewValueLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            episodeInfoCollectionViewValueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            episodeInfoCollectionViewTitleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.47),
            episodeInfoCollectionViewValueLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.47)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        episodeInfoCollectionViewTitleLabel.text = nil
        episodeInfoCollectionViewValueLabel.text = nil
    }

    func episodeInfoCollectionViewConfiguration(with episodeInfoCollectionViewViewModel: EpisodeDetailCollectionViewCellViewModel) {
        episodeInfoCollectionViewTitleLabel.text = episodeInfoCollectionViewViewModel.episodeDetailCollectionViewCellTitle
        episodeInfoCollectionViewValueLabel.text = episodeInfoCollectionViewViewModel.episodeDetailCollectionViewCellValue
    }
}
