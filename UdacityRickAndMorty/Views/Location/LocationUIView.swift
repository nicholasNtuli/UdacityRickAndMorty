import UIKit

protocol LocationViewDelegate: AnyObject {
    func downloadLocationView(_ locationView: LocationUIView, select location: Location)
}

final class LocationUIView: UIView {

    public weak var locationViewDelegate: LocationViewDelegate?

    private var locationViewViewModel: LocationViewModel? {
        didSet {
            locationViewUIUpdate()
            locationViewConfigurationHandler()
        }
    }

    private let locationViewTableView: UITableView = {
        let locationViewTableView = UITableView(frame: .zero, style: .grouped)
        locationViewTableView.translatesAutoresizingMaskIntoConstraints = false
        locationViewTableView.alpha = 0
        locationViewTableView.isHidden = true
        locationViewTableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.reuseCellIdentifier)
        return locationViewTableView
    }()

    private let locationViewLoadingIndicator: UIActivityIndicatorView = {
        let locationViewLoadingIndicator = UIActivityIndicatorView(style: .large)
        locationViewLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        locationViewLoadingIndicator.hidesWhenStopped = true
        return locationViewLoadingIndicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addCharacterDetailLoadingIndicatorSubviews(locationViewTableView, locationViewLoadingIndicator)
        locationViewLoadingIndicator.startAnimating()
        addLocationViewConstraints()
        locationViewTableViewConfiguration()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    private func locationViewUIUpdate() {
        locationViewLoadingIndicator.stopAnimating()
        locationViewTableView.isHidden = false
        locationViewTableView.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.locationViewTableView.alpha = 1
        }
    }

    private func locationViewConfigurationHandler() {
        locationViewViewModel?.registerlocationViewModelFinishedBlock { [weak self] in
            DispatchQueue.main.async {
                self?.locationViewTableView.tableFooterView = nil
                self?.locationViewTableView.reloadData()
            }
        }
    }

    private func locationViewTableViewConfiguration() {
        locationViewTableView.delegate = self
        locationViewTableView.dataSource = self
    }

    private func addLocationViewConstraints() {
        NSLayoutConstraint.activate([
            locationViewLoadingIndicator.heightAnchor.constraint(equalToConstant: 100),
            locationViewLoadingIndicator.widthAnchor.constraint(equalToConstant: 100),
            locationViewLoadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            locationViewLoadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            locationViewTableView.topAnchor.constraint(equalTo: topAnchor),
            locationViewTableView.leftAnchor.constraint(equalTo: leftAnchor),
            locationViewTableView.rightAnchor.constraint(equalTo: rightAnchor),
            locationViewTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    public func locationViewConfiguration(with locationViewViewModel: LocationViewModel) {
        self.locationViewViewModel = locationViewViewModel
    }
}

extension LocationUIView: UITableViewDelegate {
    func tableView(_ locationViewTableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationViewTableView.deselectRow(at: indexPath, animated: true)
        guard let locationViewModel = locationViewViewModel?.location(at: indexPath.row) else {
            return
        }
        locationViewDelegate?.downloadLocationView(self, select: locationViewModel)
    }
}

extension LocationUIView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationViewViewModel?.locationViewModelCellViewModels.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let locationViewCellViewModels = locationViewViewModel?.locationViewModelCellViewModels else {
            assertionFailure("Cell view models not available")
            return UITableViewCell()
        }

        guard let locationViewCell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseCellIdentifier, for: indexPath) as? LocationTableViewCell else {
            assertionFailure("Failed to dequeue LocationTableViewCell")
            return UITableViewCell()
        }

        let locationViewCellViewModel = locationViewCellViewModels[indexPath.row]
        locationViewCell.locationTableViewConfiguration(with: locationViewCellViewModel)
        return locationViewCell
    }
}

extension LocationUIView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ locationViewScrollView: UIScrollView) {
        guard let locationViewViewModel = locationViewViewModel,
              !locationViewViewModel.locationViewModelCellViewModels.isEmpty,
              locationViewViewModel.shouldLocationLoadingIndicator,
              !locationViewViewModel.loadMoreLocations else {
            return
        }

        let locationViewOffset = locationViewScrollView.contentOffset.y
        let totalLocationViewContentHeight = locationViewScrollView.contentSize.height
        let totalLocationViewScrollViewFixedHeight = locationViewScrollView.frame.size.height

        if locationViewOffset >= (totalLocationViewContentHeight - totalLocationViewScrollViewFixedHeight - 120) {
            showLocationViewLoadingIndicator()
            locationViewViewModel.downloadLocations()
        }
    }

    private func showLocationViewLoadingIndicator() {
        let locationViewFooter = TableLoadingFooterView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 100))
        locationViewTableView.tableFooterView = locationViewFooter
    }
}
