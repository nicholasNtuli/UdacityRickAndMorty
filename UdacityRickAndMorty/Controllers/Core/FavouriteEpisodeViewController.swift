import UIKit

final class FavouriteEpisodeViewController: UIViewController {

    private let episodeListViewController = EpisodeListView(isFavourites: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        episodeListViewUIConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        episodeListViewController.callOnFavouritesList()
    }

    private func episodeListViewUIConfiguration() {
        view.backgroundColor = .systemBackground
        title = "Favourites"
        episodeListViewViewSetup()
        addEpisodeListViewSearchButton()
    }

    private func episodeListViewViewSetup() {
        episodeListViewController.delegate = self
        view.addSubview(episodeListViewController)
        NSLayoutConstraint.activate([
            episodeListViewController.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            episodeListViewController.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            episodeListViewController.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            episodeListViewController.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func addEpisodeListViewSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(tapEpisodeListViewSearch)
        )
    }

    @objc private func tapEpisodeListViewSearch() {
        let episodeListViewSearchConfiguration = SearchViewController.SearchViewControllerConfiguration(searchViewType: .episode)
        let episodeListViewSearchViewController = SearchViewController(config: episodeListViewSearchConfiguration)
        
        episodeListViewSearchViewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(episodeListViewSearchViewController, animated: true)
    }
}

extension FavouriteEpisodeViewController: EpisodeListViewDelegate {
    func episodeListViewController(_ episodeListView: EpisodeListView, selectEpisode episodeListViewEpisode: Episode) {
        let episodeListViewDetailViewController = EpisodeDetailViewController(url: URL(string: episodeListViewEpisode.url))
        
        episodeListViewDetailViewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(episodeListViewDetailViewController, animated: true)
    }
}
