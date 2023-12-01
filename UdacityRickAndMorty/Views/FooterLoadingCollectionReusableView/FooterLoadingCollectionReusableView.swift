import UIKit

final class FooterLoadingCollectionReusableView: UICollectionReusableView {
    
    static let footerLoadingCollectionIdentifier = "FooterLoadingCollectionReusableView"

    private let footerLoadingCollectionLoadingIndicator: UIActivityIndicatorView = {
        let footerLoadingCollectionLoadingIndicator = UIActivityIndicatorView(style: .large)
        footerLoadingCollectionLoadingIndicator.hidesWhenStopped = true
        footerLoadingCollectionLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        return footerLoadingCollectionLoadingIndicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        footerLoadingCollectionConfigureView()
        footerLoadingCollectionSubviewsSetup()
        footerLoadingCollectionConstraintsSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func footerLoadingCollectionConfigureView() {
        backgroundColor = .systemBackground
    }

    private func footerLoadingCollectionSubviewsSetup() {
        addSubview(footerLoadingCollectionLoadingIndicator)
    }

    private func footerLoadingCollectionConstraintsSetup() {
        NSLayoutConstraint.activate([
            footerLoadingCollectionLoadingIndicator.widthAnchor.constraint(equalToConstant: 100),
            footerLoadingCollectionLoadingIndicator.heightAnchor.constraint(equalToConstant: 100),
            footerLoadingCollectionLoadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            footerLoadingCollectionLoadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    public func footerLoadingCollectionAnimating() {
        footerLoadingCollectionLoadingIndicator.startAnimating()
    }
}
