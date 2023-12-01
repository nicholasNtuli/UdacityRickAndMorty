import UIKit

final class LocationTableViewCell: UITableViewCell {
    
    static let reuseCellIdentifier = "LocationTableViewCell"

    private let locationTableViewNameLabel: UILabel = {
        let locationTableViewNameLabel = UILabel()
        locationTableViewNameLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTableViewNameLabel.font = .systemFont(ofSize: 20, weight: .medium)
        return locationTableViewNameLabel
    }()

    private let locationTableViewTypeLabel: UILabel = {
        let locationTableViewTypeLabel = UILabel()
        locationTableViewTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTableViewTypeLabel.font = .systemFont(ofSize: 15, weight: .regular)
        locationTableViewTypeLabel.textColor = .secondaryLabel
        return locationTableViewTypeLabel
    }()

    private let locationTableViewDimensionLabel: UILabel = {
        let locationTableViewDimensionLabel = UILabel()
        locationTableViewDimensionLabel.textColor = .secondaryLabel
        locationTableViewDimensionLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTableViewDimensionLabel.font = .systemFont(ofSize: 15, weight: .light)
        return locationTableViewDimensionLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        locationTableViewUIConfiguration()
        locationTableViewConstraintsConfiguration()
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func locationTableViewUIConfiguration() {
        contentView.addCharacterDetailLoadingIndicatorSubviews(locationTableViewNameLabel, locationTableViewTypeLabel, locationTableViewDimensionLabel)
    }

    private func locationTableViewConstraintsConfiguration() {
        NSLayoutConstraint.activate([
            locationTableViewNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            locationTableViewNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            locationTableViewNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            locationTableViewTypeLabel.topAnchor.constraint(equalTo: locationTableViewNameLabel.bottomAnchor, constant: 10),
            locationTableViewTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            locationTableViewTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            locationTableViewDimensionLabel.topAnchor.constraint(equalTo: locationTableViewTypeLabel.bottomAnchor, constant: 10),
            locationTableViewDimensionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            locationTableViewDimensionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            locationTableViewDimensionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        locationTableViewNameLabel.text = nil
        locationTableViewTypeLabel.text = nil
        locationTableViewDimensionLabel.text = nil
    }

    func locationTableViewConfiguration(with locationTableViewViewModel: LocationTableViewCellViewModel) {
        locationTableViewNameLabel.text = locationTableViewViewModel.locationName
        locationTableViewTypeLabel.text = locationTableViewViewModel.locationType
        locationTableViewDimensionLabel.text = locationTableViewViewModel.locationDimension
    }
}
