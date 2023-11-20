import UIKit

final class EpisodeViewController: UIViewController {

    private let episodeListView = EpisodeListView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = "Episodes"
        setUpView()
        addSearchButton()
    }

    private func setUpView() {
        episodeListView.delegate = self
        view.addSubview(episodeListView)
        NSLayoutConstraint.activate([
            episodeListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            episodeListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            episodeListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            episodeListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func addSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(tapSearch)
        )
    }

    @objc private func tapSearch() {
        let searchConfig = SearchViewController.Config(type: .episode)
        let searchVC = SearchViewController(config: searchConfig)
        searchVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

extension EpisodeViewController: EpisodeListViewDelegate {
    func episodeListView(_ episodeListView: EpisodeListView, selectEpisode episode: Episode) {
        let detailVC = EpisodeDetailViewController(url: URL(string: episode.url))
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
