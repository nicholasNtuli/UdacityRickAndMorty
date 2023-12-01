import UIKit

final class NoSearchResultsView: UIView {

    private let noSearchResultsViewModel = NoSearchViewBeingReturned()

    private let noSearchResultsIconView: UIImageView = {
        let noSearchResultsIconView = UIImageView()
        noSearchResultsIconView.contentMode = .scaleAspectFit
        noSearchResultsIconView.tintColor = .systemBlue
        noSearchResultsIconView.translatesAutoresizingMaskIntoConstraints = false
        return noSearchResultsIconView
    }()

    private let noSearchResultsLabel: UILabel = {
        let noSearchResultsLabel = UILabel()
        noSearchResultsLabel.textAlignment = .center
        noSearchResultsLabel.font = .systemFont(ofSize: 20, weight: .medium)
        noSearchResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        return noSearchResultsLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        noSearchResultsConfigurationView()
        setupNoSearchResultsSubviews()
        setupNoSearchResultsConstraints()
        noSearchResultsConfiguration()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func noSearchResultsConfigurationView() {
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupNoSearchResultsSubviews() {
        addCharacterDetailLoadingIndicatorSubviews(noSearchResultsIconView, noSearchResultsLabel)
    }

    private func setupNoSearchResultsConstraints() {
        NSLayoutConstraint.activate([
            noSearchResultsIconView.widthAnchor.constraint(equalToConstant: 90),
            noSearchResultsIconView.heightAnchor.constraint(equalToConstant: 90),
            noSearchResultsIconView.topAnchor.constraint(equalTo: topAnchor),
            noSearchResultsIconView.centerXAnchor.constraint(equalTo: centerXAnchor),

            noSearchResultsLabel.leftAnchor.constraint(equalTo: leftAnchor),
            noSearchResultsLabel.rightAnchor.constraint(equalTo: rightAnchor),
            noSearchResultsLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            noSearchResultsLabel.topAnchor.constraint(equalTo: noSearchResultsIconView.bottomAnchor, constant: 10),
        ])
    }

    private func noSearchResultsConfiguration() {
        noSearchResultsLabel.text = noSearchResultsViewModel.noSearchViewTitle
        noSearchResultsIconView.image = noSearchResultsViewModel.noSearchViewImage
    }
}
