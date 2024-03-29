import UIKit
import Reachability

final class EpisodeViewController: UIViewController {

    private let episodeListViewController = EpisodeListView()
    private let reachability = try! Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkInternetConnection()
        episodeListViewUIConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        episodeListViewController.callOnDownloadList()
    }

    private func episodeListViewUIConfiguration() {
        view.backgroundColor = .systemBackground
        title = "Episodes"
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
    
    private func checkInternetConnection() {
        if reachability.connection == .unavailable {
            showNoInternetAlert()
        }
    }
}

extension EpisodeViewController: EpisodeListViewDelegate {
    func episodeListViewController(_ episodeListView: EpisodeListView, selectEpisode episodeListViewEpisode: Episode) {
        let episodeListViewDetailViewController = EpisodeDetailViewController(url: URL(string: episodeListViewEpisode.url))
        
        episodeListViewDetailViewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(episodeListViewDetailViewController, animated: true)
    }
}
