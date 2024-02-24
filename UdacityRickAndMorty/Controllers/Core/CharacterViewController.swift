import UIKit
import Reachability

final class CharacterViewController: UIViewController {

    private let characterListView = CharacterViewList()
    private let reachability = try! Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkInternetConnection()
        characterViewListConfigurationUI()
    }

    private func characterViewListConfigurationUI() {
        view.backgroundColor = .systemBackground
        title = "Characters"
        characterViewListViewSetup()
        addCharacterViewListSearchButton()
    }

    private func characterViewListViewSetup() {
        characterListView.characterListDelegate = self
        view.addSubview(characterListView)
        NSLayoutConstraint.activate([
            characterListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            characterListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            characterListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            characterListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func addCharacterViewListSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(tapCharacterViewListSearch)
        )
    }

    @objc private func tapCharacterViewListSearch() {
        let characterViewListConfigurationSearch = SearchViewController.SearchViewControllerConfiguration(searchViewType: .character)
        let searchCharacterViewListViewController = SearchViewController(config: characterViewListConfigurationSearch)
        searchCharacterViewListViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(searchCharacterViewListViewController, animated: true)
    }
    
    private func checkInternetConnection() {
        if reachability.connection == .unavailable {
            showNoInternetAlert()
        }
    }
}

extension CharacterViewController: CharacterListViewDelegate {
    func downloadFullCharacterViewList(_ characterViewList: CharacterViewList, selectCharacter character: Character) {
        let characterViewListViewModel = CharacterDetailViewModel(characterDetail: character)
        let characterViewListDetailViewController = CharacterDetailViewController(viewModel: characterViewListViewModel)
        characterViewListDetailViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(characterViewListDetailViewController, animated: true)
    }
}

