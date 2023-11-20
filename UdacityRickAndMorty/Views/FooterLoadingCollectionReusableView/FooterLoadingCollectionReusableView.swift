import UIKit

final class FooterLoadingCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "FooterLoadingCollectionReusableView"

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        backgroundColor = .systemBackground
    }

    private func setupSubviews() {
        addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            loadingIndicator.widthAnchor.constraint(equalToConstant: 100),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 100),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    public func startAnimating() {
        loadingIndicator.startAnimating()
    }
}
