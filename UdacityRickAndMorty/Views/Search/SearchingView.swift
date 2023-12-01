import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchViewSectiOption(_ searchViewSelectOption: SearchingView, selectOption option: SearchInputViewModel.SearchInputConstants)
    func searchViewSelctLocation(_ searchViewSelctLocation: SearchingView, selectLocation location: Location)
    func searchViewSelectCharacter(_ searchViewSelectCharacter: SearchingView, selectCharacter character: Character)
    func searchViewSelectEpisode(_ searchViewSelectEpisode: SearchingView, selectEpisode episode: Episode)
}

final class SearchingView: UIView {
    weak var searchViewDelegate: SearchViewDelegate?
    private let searchViewViewModel: SearchViewModel
    private let inputViewForSearchView = SearchInputView()
    private let noResultFoundInSearchView = NoSearchResultsView()
    private let resultsFoundSearchView = SearchResultsView()
    
    init(frame: CGRect, viewModel: SearchViewModel) {
        self.searchViewViewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addCharacterDetailLoadingIndicatorSubviews(resultsFoundSearchView, noResultFoundInSearchView, inputViewForSearchView)
        addSearchViewConstraints()

        inputViewForSearchView.searchInputconfiguration(with: SearchInputViewModel(SearchInputType: viewModel.searchViewConfiguration.searchViewType))
        inputViewForSearchView.searchInputDelegate = self

        searchViewHandlerSetup(searchViewViewModel: viewModel)

        resultsFoundSearchView.searchResultDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func searchViewHandlerSetup(searchViewViewModel: SearchViewModel) {
        searchViewViewModel.searchViewOptionRegisterHander { data in
            self.inputViewForSearchView.updatesearchInput(searchInputOption: data.0, searchInputValue: data.1)
        }

        searchViewViewModel.searchViewHandlerRegister { [weak self] searchViewResult in
            DispatchQueue.main.async {
                self?.resultsFoundSearchView.searchResultConfiguration(with: searchViewResult)
                self?.noResultFoundInSearchView.isHidden = true
                self?.resultsFoundSearchView.isHidden = false
            }
        }

        searchViewViewModel.searchViewNoResultsHandlerRegister { [weak self] in
            DispatchQueue.main.async {
                self?.noResultFoundInSearchView.isHidden = false
                self?.resultsFoundSearchView.isHidden = true
            }
        }
    }

    private func addSearchViewConstraints() {
        NSLayoutConstraint.activate([
            inputViewForSearchView.topAnchor.constraint(equalTo: topAnchor),
            inputViewForSearchView.leftAnchor.constraint(equalTo: leftAnchor),
            inputViewForSearchView.rightAnchor.constraint(equalTo: rightAnchor),
            inputViewForSearchView.heightAnchor.constraint(equalToConstant: searchViewViewModel.searchViewConfiguration.searchViewType == .episode ? 55 : 110),

            resultsFoundSearchView.topAnchor.constraint(equalTo: inputViewForSearchView.bottomAnchor),
            resultsFoundSearchView.leftAnchor.constraint(equalTo: leftAnchor),
            resultsFoundSearchView.rightAnchor.constraint(equalTo: rightAnchor),
            resultsFoundSearchView.bottomAnchor.constraint(equalTo: bottomAnchor),

            noResultFoundInSearchView.widthAnchor.constraint(equalToConstant: 150),
            noResultFoundInSearchView.heightAnchor.constraint(equalToConstant: 150),
            noResultFoundInSearchView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultFoundInSearchView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    public func presentSearchViewKeyboard() {
        inputViewForSearchView.presentSearchInputKeyboard()
    }
}

extension SearchingView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ searchViewCollectionView: UICollectionView, numberOfItemsInSection searchViewSection: Int) -> Int {
        return 0
    }

    func collectionView(_ searchViewCollectionView: UICollectionView, cellForItemAt searchViewIndexPath: IndexPath) -> UICollectionViewCell {
        let searchViewCell = searchViewCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: searchViewIndexPath)
        return searchViewCell
    }

    func collectionView(_ searchViewCollectionView: UICollectionView, didSelectItemAt searchViewIndexPath: IndexPath) {
        searchViewCollectionView.deselectItem(at: searchViewIndexPath, animated: true)
    }
}

extension SearchingView: SearchInputViewDelegate {
    func searchInputSelectionView(_ searchViewInputView: SearchInputView, selectOption searchViewOption: SearchInputViewModel.SearchInputConstants) {
        searchViewDelegate?.searchViewSectiOption(self, selectOption: searchViewOption)
    }

    func searchInputField(_ searchViewInputView: SearchInputView, changeSearchText searchViewText: String) {
        searchViewViewModel.setSearchViewText(query: searchViewText)
    }

    func searchInputTapped(_ searchViewInputView: SearchInputView) {
        searchViewViewModel.executeSearchForSearchView()
    }
}

extension SearchingView: SearchResultsViewDelegate {
    func searchViewResults(_ resultsView: SearchResultsView, tapLocationAt index: Int) {
        guard let searchViewLocationModel = searchViewViewModel.searchViewLocationResults(at: index) else {
            return
        }
        searchViewDelegate?.searchViewSelctLocation(self, selectLocation: searchViewLocationModel)
    }

    func searchEpisodeResultsView(_ resultsView: SearchResultsView, tapEpisodeAt index: Int) {
        guard let searchViewEpisodeModel = searchViewViewModel.searchViewEpisodeResults(at: index) else {
            return
        }
        searchViewDelegate?.searchViewSelectEpisode(self, selectEpisode: searchViewEpisodeModel)
    }

    func searchLocationResultsView(_ resultsView: SearchResultsView, tapCharacterAt index: Int) {
        guard let searchViewCharacterModel = searchViewViewModel.searchViewCharacterResults(at: index) else {
            return
        }
        searchViewDelegate?.searchViewSelectCharacter(self, selectCharacter: searchViewCharacterModel)
    }
}
