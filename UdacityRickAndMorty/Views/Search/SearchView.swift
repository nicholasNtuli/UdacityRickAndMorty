import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchView(_ searchView: SearchView, selectOption option: SearchInputViewModel.DynamicOption)
    func searchView(_ searchView: SearchView, selectLocation location: Location)
    func searchView(_ searchView: SearchView, selectCharacter character: Character)
    func searchView(_ searchView: SearchView, selectEpisode episode: Episode)
}

final class SearchView: UIView {

    weak var delegate: SearchViewDelegate?
    private let viewModel: SearchViewModel
    private let searchInputView = SearchInputView()
    private let noResultsView = NoSearchResultsView()
    private let resultsView = SearchResultsView()
    
    init(frame: CGRect, viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(resultsView, noResultsView, searchInputView)
        addConstraints()

        searchInputView.configure(with: SearchInputViewModel(type: viewModel.config.type))
        searchInputView.delegate = self

        setUpHandlers(viewModel: viewModel)

        resultsView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setUpHandlers(viewModel: SearchViewModel) {
        viewModel.registerOptionChangeBlock { tuple in
            self.searchInputView.update(option: tuple.0, value: tuple.1)
        }

        viewModel.registerSearchResultHandler { [weak self] result in
            DispatchQueue.main.async {
                self?.resultsView.configure(with: result)
                self?.noResultsView.isHidden = true
                self?.resultsView.isHidden = false
            }
        }

        viewModel.registerNoResultsHandler { [weak self] in
            DispatchQueue.main.async {
                self?.noResultsView.isHidden = false
                self?.resultsView.isHidden = true
            }
        }
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            searchInputView.topAnchor.constraint(equalTo: topAnchor),
            searchInputView.leftAnchor.constraint(equalTo: leftAnchor),
            searchInputView.rightAnchor.constraint(equalTo: rightAnchor),
            searchInputView.heightAnchor.constraint(equalToConstant: viewModel.config.type == .episode ? 55 : 110),

            resultsView.topAnchor.constraint(equalTo: searchInputView.bottomAnchor),
            resultsView.leftAnchor.constraint(equalTo: leftAnchor),
            resultsView.rightAnchor.constraint(equalTo: rightAnchor),
            resultsView.bottomAnchor.constraint(equalTo: bottomAnchor),

            noResultsView.widthAnchor.constraint(equalToConstant: 150),
            noResultsView.heightAnchor.constraint(equalToConstant: 150),
            noResultsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultsView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    public func presentKeyboard() {
        searchInputView.presentKeyboard()
    }
}

extension SearchView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension SearchView: SearchInputViewDelegate {
    func searchInputView(_ inputView: SearchInputView, selectOption option: SearchInputViewModel.DynamicOption) {
        delegate?.searchView(self, selectOption: option)
    }

    func searchInputView(_ inputView: SearchInputView, changeSearchText text: String) {
        viewModel.set(query: text)
    }

    func searchInputViewDidTapSearchKeyboardButton(_ inputView: SearchInputView) {
        viewModel.executeSearch()
    }
}

extension SearchView: SearchResultsViewDelegate {
    func searchResultsView(_ resultsView: SearchResultsView, tapLocationAt index: Int) {
        guard let locationModel = viewModel.locationSearchResult(at: index) else {
            return
        }
        delegate?.searchView(self, selectLocation: locationModel)
    }

    func searchResultsView(_ resultsView: SearchResultsView, tapEpisodeAt index: Int) {
        guard let episodeModel = viewModel.episodeSearchResult(at: index) else {
            return
        }
        delegate?.searchView(self, selectEpisode: episodeModel)
    }

    func searchResultsView(_ resultsView: SearchResultsView, tapCharacterAt index: Int) {
        guard let characterModel = viewModel.characterSearchResult(at: index) else {
            return
        }
        delegate?.searchView(self, selectCharacter: characterModel)
    }
}
