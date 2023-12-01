import UIKit

final class TableLoadingFooterView: UIView {

    private let tableLoadingFooterViewLoadingIndicator: UIActivityIndicatorView = {
        let tableLoadingFooterViewLoadingIndicator = UIActivityIndicatorView()
        tableLoadingFooterViewLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        tableLoadingFooterViewLoadingIndicator.hidesWhenStopped = true
        return tableLoadingFooterViewLoadingIndicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        tableLoadingFooterViewUIConfiguration()
        addTableLoadingFooterViewConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func tableLoadingFooterViewUIConfiguration() {
        addSubview(tableLoadingFooterViewLoadingIndicator)
        tableLoadingFooterViewLoadingIndicator.startAnimating()
    }

    private func addTableLoadingFooterViewConstraints() {
        NSLayoutConstraint.activate([
            tableLoadingFooterViewLoadingIndicator.widthAnchor.constraint(equalToConstant: 55),
            tableLoadingFooterViewLoadingIndicator.heightAnchor.constraint(equalToConstant: 55),
            tableLoadingFooterViewLoadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            tableLoadingFooterViewLoadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
