import UIKit

final class LocationViewController: UIViewController {

    private let locationView = LocationView()
    private let viewModel = LocationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureViewModel()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = "Locations"
        addSubviews()
        addConstraints()
        addSearchButton()
    }

    private func addSubviews() {
        locationView.delegate = self
        view.addSubview(locationView)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            locationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            locationView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            locationView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            locationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func addSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(tapSearch)
        )
    }

    private func configureViewModel() {
        viewModel.delegate = self
        viewModel.fetchLocations()
    }

    @objc private func tapSearch() {
        let searchConfig = SearchViewController.Config(type: .location)
        let searchVC = SearchViewController(config: searchConfig)
        searchVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

extension LocationViewController: LocationViewModelDelegate {
    func fetchInitialLocations() {
        locationView.configure(with: viewModel)
    }
}

extension LocationViewController: LocationViewDelegate {
    func locationView(_ locationView: LocationView, select location: Location) {
        let locationDetailVC = LocationDetailViewController(location: location)
        locationDetailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(locationDetailVC, animated: true)
    }
}
