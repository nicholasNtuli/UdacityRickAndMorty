import UIKit

final class LocationDetailViewController: UIViewController {

    private let locationDetailViewModel: LocationDetailViewModel
    private let locationDetailView = LocationDetailView()

    init(location: Location) {
        let locationDetailURL = URL(string: location.url)
        self.locationDetailViewModel = LocationDetailViewModel(locationDetailEndpointURL: locationDetailURL)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationDetailUISetup()
        fetchLocationDetailData()
    }

    private func locationDetailUISetup() {
        view.backgroundColor = .systemBackground
        setupLocationDetaillView()
        locationDetailNavigationBarSetup()
        addLocationDetailConstraints()
    }

    private func setupLocationDetaillView() {
        view.addSubview(locationDetailView)
        locationDetailView.locationDetailDelegate = self
    }

    private func locationDetailNavigationBarSetup() {
        title = "Location"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tapLocationDetailShareButton))
    }

    private func addLocationDetailConstraints() {
        NSLayoutConstraint.activate([
            locationDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            locationDetailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            locationDetailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            locationDetailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc
    private func tapLocationDetailShareButton() {}

    private func fetchLocationDetailData() {
        locationDetailViewModel.locationDetailDelegate = self
        locationDetailViewModel.downloadLocationData()
    }
}

extension LocationDetailViewController: LocationDetailViewDelegate {
    func loadLocationDetaiEepisodeDetailView(_ detailView: LocationDetailView, locationDetailSelection character: Character) {
        let locationDetailCharacterController = CharacterDetailViewController(viewModel: CharacterDetailViewModel(characterDetail: character))
        locationDetailCharacterController.title = character.name
        locationDetailCharacterController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(locationDetailCharacterController, animated: true)
    }
}

extension LocationDetailViewController: LocationDetailViewModelDelegate {
    func downloadLocationDetails() {
        locationDetailView.locationDetailConfiguration(with: locationDetailViewModel)
    }
}
