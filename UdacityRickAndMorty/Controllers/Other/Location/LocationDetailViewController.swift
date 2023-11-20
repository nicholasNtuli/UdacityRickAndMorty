import UIKit

final class LocationDetailViewController: UIViewController {

    private let viewModel: LocationDetailViewModel
    private let detailView = LocationDetailView()

    init(location: Location) {
        let url = URL(string: location.url)
        self.viewModel = LocationDetailViewModel(endpointUrl: url)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupDetailView()
        setupNavigationBar()
        addConstraints()
    }

    private func setupDetailView() {
        view.addSubview(detailView)
        detailView.delegate = self
    }

    private func setupNavigationBar() {
        title = "Location"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tapShare))
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            detailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc
    private func tapShare() {}

    private func fetchData() {
        viewModel.delegate = self
        viewModel.fetchLocationData()
    }
}

extension LocationDetailViewController: LocationDetailViewDelegate {
    func episodeDetailView(_ detailView: LocationDetailView, select character: Character) {
        let vc = CharacterDetailViewController(viewModel: CharacterDetailViewModel(character: character))
        vc.title = character.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LocationDetailViewController: LocationDetailViewModelDelegate {
    func fetchLocationDetails() {
        detailView.configure(with: viewModel)
    }
}
