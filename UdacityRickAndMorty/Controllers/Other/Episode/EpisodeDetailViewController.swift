import UIKit

final class EpisodeDetailViewController: UIViewController, EpisodeDetailViewModelDelegate, EpisodeDetailViewDelegate {

    private let episodeDetailViewModel: EpisodeDetailViewModel
    private lazy var episodeDetailView = EpisodeDetailView()

    init(url: URL?) {
        self.episodeDetailViewModel = EpisodeDetailViewModel(episodeDetailEndpointURL: url)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        episodeDetailUISetup()
        episodeDetailViewModel.episodeDetailDelegate = self
        episodeDetailViewModel.downloadepisodeDetail()
    }

    private func episodeDetailUISetup() {
        view.backgroundColor = .systemBackground
        setupEpisodeDetailView()
        title = "Episode"
        episodeDetailNavigationBarSetup()
        addEpisodeDetailConstraints()
    }

    private func setupEpisodeDetailView() {
        view.addSubview(episodeDetailView)
        episodeDetailView.episodeDetailDelegate = self
    }

    private func episodeDetailNavigationBarSetup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tapEpisodeDetailShareButton))
    }

    private func addEpisodeDetailConstraints() {
        NSLayoutConstraint.activate([
            episodeDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            episodeDetailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            episodeDetailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            episodeDetailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc private func tapEpisodeDetailShareButton() {}

    @objc private func didTapEpisodeDetailShareButton() {}

    func loadEpisodeDetailView(_ detailView: EpisodeDetailView, select character: Character) {
        let episodeDetailCharacterViewModel = CharacterDetailViewModel(characterDetail: character)
        let episodeDetailCharacterDetailViewController = CharacterDetailViewController(viewModel: episodeDetailCharacterViewModel)
        episodeDetailCharacterDetailViewController.title = character.name
        episodeDetailCharacterDetailViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(episodeDetailCharacterDetailViewController, animated: true)
    }

    func downloadEpisodeDetails() {
        episodeDetailView.episodeDetailConfiguration(with: episodeDetailViewModel)
    }
}
