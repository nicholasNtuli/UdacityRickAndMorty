import UIKit

final class SearchViewController: UIViewController {
    
    private let viewModel: SearchViewModel
    private lazy var searchView: SearchView = {
        return SearchView(frame: .zero, viewModel: viewModel)
    }()
    
    struct Config {
        enum `Type` {
            case character
            case episode
            case location

            var endpoint: APIEndpoint {
                switch self {
                case .character: return .character
                case .episode: return .episode
                case .location: return .location
                }
            }

            var title: String {
                switch self {
                case .character: return "Search Characters"
                case .location: return "Search Location"
                case .episode: return "Search Episode"
                }
            }
        }

        let type: `Type`
    }
    
    init(config: Config) {
        let viewModel = SearchViewModel(config: config)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = viewModel.config.type.title
        view.backgroundColor = .systemBackground
        setupSearchView()
        addConstraints()
        setupNavigationBar()
    }

    private func setupSearchView() {
        view.addSubview(searchView)
        searchView.delegate = self
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Search",
            style: .done,
            target: self,
            action: #selector(didTapExecuteSearch)
        )
    }

    @objc private func didTapExecuteSearch() {
        viewModel.executeSearch()
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            searchView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            searchView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension SearchViewController: SearchViewDelegate {
    func searchView(_ searchView: SearchView, selectOption option: SearchInputViewModel.DynamicOption) {
        let vc = SearchOptionPickerViewController(option: option) { [weak self] selection in
            DispatchQueue.main.async {
                self?.viewModel.set(value: selection, for: option)
            }
        }
        vc.sheetPresentationController?.detents = [.medium()]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        present(vc, animated: true)
    }

    func searchView(_ searchView: SearchView, selectLocation location: Location) {
        let vc = LocationDetailViewController(location: location)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func searchView(_ searchView: SearchView, selectCharacter character: Character) {
        let vc = CharacterDetailViewController(viewModel: .init(character: character))
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func searchView(_ searchView: SearchView, selectEpisode episode: Episode) {
        let vc = EpisodeDetailViewController(url: URL(string: episode.url))
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
