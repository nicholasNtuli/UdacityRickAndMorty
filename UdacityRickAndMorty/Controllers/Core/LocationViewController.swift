import UIKit
import Reachability

final class LocationViewController: UIViewController {

    private let locationUIView = LocationUIView()
    private let locationViewModel = LocationViewModel()
    private let reachability = try! Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkInternetConnection()
        locationViewCUICnfiguration()
        locationViewViewModelConfiguration()
    }

    private func locationViewCUICnfiguration() {
        view.backgroundColor = .systemBackground
        title = "Locations"
        addLocationViewSubviews()
        addLocationViewConstraints()
        addLocationViewSearchButton()
    }

    private func addLocationViewSubviews() {
        locationUIView.locationViewDelegate = self
        view.addSubview(locationUIView)
    }

    private func addLocationViewConstraints() {
        NSLayoutConstraint.activate([
            locationUIView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            locationUIView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            locationUIView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            locationUIView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func addLocationViewSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(tapLocationViewSearch)
        )
    }

    private func locationViewViewModelConfiguration() {
        locationViewModel.locationViewModelDelegate = self
        locationViewModel.fetchLocations()
    }

    @objc private func tapLocationViewSearch() {
        let locationViewSearchConfiguration = SearchViewController.SearchViewControllerConfiguration(searchViewType: .location)
        let locationViewSearchViewController = SearchViewController(config: locationViewSearchConfiguration)
        
        locationViewSearchViewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(locationViewSearchViewController, animated: true)
    }
    
    private func checkInternetConnection() {
        if reachability.connection == .unavailable {
            showNoInternetAlert()
        }
    }
}

extension LocationViewController: LocationViewModelDelegate {    
    func downloadLocationsFailed(with error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func downloadLocations() {
        locationUIView.locationViewConfiguration(with: locationViewModel)
    }
}

extension LocationViewController: LocationViewDelegate {
    func downloadLocationView(_ locationView: LocationUIView, select location: Location) {
        let locationViewDetailViewController = LocationDetailViewController(location: location)
        
        locationViewDetailViewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(locationViewDetailViewController, animated: true)
    }
}
