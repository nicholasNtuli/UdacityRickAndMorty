import UIKit
import Reachability

final class SearchViewController: UIViewController {
    
    private let serachViewModel: SearchViewModel
    private lazy var searchingView: SearchingView = {
        return SearchingView(frame: .zero, viewModel: serachViewModel)
    }()
    private let reachability = try! Reachability()
    
    struct SearchViewControllerConfiguration {
        enum `SearchType` {
            case character
            case episode
            case location

            var searchViewAPIndpoint: APIEndpoint {
                switch self {
                case .character: return .character
                case .episode: return .episode
                case .location: return .location
                }
            }

            var searchViewTitle: String {
                switch self {
                case .character: return "Search Characters"
                case .location: return "Search Location"
                case .episode: return "Search Episode"
                }
            }
        }

        let searchViewType: `SearchType`
    }
    
    init(config: SearchViewControllerConfiguration) {
        let searchViewModel = SearchViewModel(searchViewConfiguration: config)
        self.serachViewModel = searchViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkInternetConnection()
        searchViewUISetup()
    }

    private func searchViewUISetup() {
        title = serachViewModel.searchViewConfiguration.searchViewType.searchViewTitle
        view.backgroundColor = .systemBackground
        searchViewSetup()
        addSearchViewConstraints()
        searchViewNavigationBarSetup()
    }

    private func searchViewSetup() {
        view.addSubview(searchingView)
        searchingView.searchViewDelegate = self
    }

    private func searchViewNavigationBarSetup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Start typing to search",
            style: .done,
            target: self,
            action: #selector(searchExecuted)
        )
    }

    @objc private func searchExecuted() {
        serachViewModel.executeSearchForSearchView()
    }

    private func addSearchViewConstraints() {
        NSLayoutConstraint.activate([
            searchingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            searchingView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            searchingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func checkInternetConnection() {
        if reachability.connection == .unavailable {
            showNoInternetAlert()
        }
    }
}

extension SearchViewController: SearchViewDelegate {
    func searchViewSectiOption(_ searchView: SearchingView, selectOption searchViewOption: SearchInputViewModel.SearchInputConstants) {
        let searchViewController = SearchOptionPickerViewController(option: searchViewOption) { [weak self] searchViewSelection in
            DispatchQueue.main.async {
                self?.serachViewModel.setSearchViewMapping(value: searchViewSelection, for: searchViewOption)
            }
        }
        
        searchViewController.sheetPresentationController?.detents = [.medium()]
        searchViewController.sheetPresentationController?.prefersGrabberVisible = true
        
        present(searchViewController, animated: true)
    }

    func searchViewSelctLocation(_ searchView: SearchingView, selectLocation searchViewLocation: Location) {
        let searchViewController = LocationDetailViewController(location: searchViewLocation)
        
        searchViewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(searchViewController, animated: true)
    }

    func searchViewSelectCharacter(_ searchView: SearchingView, selectCharacter searchViewCharacter: Character) {
        let searchViewController = CharacterDetailViewController(viewModel: .init(characterDetail: searchViewCharacter))
        
        searchViewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(searchViewController, animated: true)
    }

    func searchViewSelectEpisode(_ searchView: SearchingView, selectEpisode searchViewEpisode: Episode) {
        let searchViewController = EpisodeDetailViewController(url: URL(string: searchViewEpisode.url))
        
        searchViewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}
