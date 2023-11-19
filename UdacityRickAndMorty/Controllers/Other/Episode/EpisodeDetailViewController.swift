import UIKit

final class EpisodeDetailViewController: UIViewController, EpisodeDetailViewModelDelegate, EpisodeDetailViewDelegate {

    private let viewModel: EpisodeDetailViewModel
    private let detailView = EpisodeDetailView()
    
    init(url: URL?) {
        self.viewModel = EpisodeDetailViewModel(endpointUrl: url)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc
    private func tapShare() {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(detailView)
        addConstraints()
        detailView.delegate = self
        title = "Episode"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tapShare))

        viewModel.delegate = self
        viewModel.fetchEpisodeData()
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
    private func didTapShare() {}

    func episodeDetailView(
        _ detailView: EpisodeDetailView,
        select character: Character
    ) {
        let vc = CharacterDetailViewController(viewModel: .init(character: character))
        vc.title = character.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchEpisodeDetails() {
        detailView.configure(with: viewModel)
    }
}
