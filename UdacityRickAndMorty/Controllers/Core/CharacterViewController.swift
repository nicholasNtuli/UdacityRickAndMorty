import UIKit

final class CharacterViewController: UIViewController {

    private let characterListView = CharacterListView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = "Characters"
        setUpView()
        addSearchButton()
    }

    private func setUpView() {
        characterListView.delegate = self
        view.addSubview(characterListView)
        NSLayoutConstraint.activate([
            characterListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            characterListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            characterListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            characterListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
        let searchConfig = SearchViewController.Config(type: .character)
        let searchVC = SearchViewController(config: searchConfig)
        searchVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

extension CharacterViewController: CharacterListViewDelegate {
    func characterListView(_ characterListView: CharacterListView, selectCharacter character: Character) {
        let viewModel = CharacterDetailViewModel(character: character)
        let detailVC = CharacterDetailViewController(viewModel: viewModel)
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

