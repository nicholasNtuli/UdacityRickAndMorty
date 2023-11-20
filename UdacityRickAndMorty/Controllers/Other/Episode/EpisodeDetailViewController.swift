import UIKit

final class EpisodeDetailViewController: UIViewController, EpisodeDetailViewModelDelegate, EpisodeDetailViewDelegate {

    private let viewModel: EpisodeDetailViewModel
    private lazy var detailView = EpisodeDetailView()

    init(url: URL?) {
        self.viewModel = EpisodeDetailViewModel(endpointUrl: url)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
        viewModel.fetchEpisodeData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupDetailView()
        title = "Episode"
        setupNavigationBar()
        addConstraints()
    }

    private func setupDetailView() {
        view.addSubview(detailView)
        detailView.delegate = self
    }

    private func setupNavigationBar() {
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

    @objc private func tapShare() {}

    @objc private func didTapShare() {}

    func episodeDetailView(_ detailView: EpisodeDetailView, select character: Character) {
        let characterViewModel = CharacterDetailViewModel(character: character)
        let characterDetailVC = CharacterDetailViewController(viewModel: characterViewModel)
        characterDetailVC.title = character.name
        characterDetailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(characterDetailVC, animated: true)
    }

    func fetchEpisodeDetails() {
        detailView.configure(with: viewModel)
    }
}
