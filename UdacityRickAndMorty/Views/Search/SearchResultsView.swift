import UIKit

protocol SearchResultsViewDelegate: AnyObject {
    func searchViewResults(_ resultsView: SearchResultsView, tapLocationAt index: Int)
    func searchLocationResultsView(_ resultsView: SearchResultsView, tapCharacterAt index: Int)
    func searchEpisodeResultsView(_ resultsView: SearchResultsView, tapEpisodeAt index: Int)
}

final class SearchResultsView: UIView {
    weak var searchResultDelegate: SearchResultsViewDelegate?
    private var searchResultLocationCellViewModels: [LocationTableViewCellViewModel] = []
    private var searchResultCollectionViewCellViewModels: [any Hashable] = []
    
    private var searchResultViewModel: SearchResultViewModel? {
        didSet {
            self.processSearchResultViewModel()
        }
    }
    
    private let searchResultTableView: UITableView = {
        let searchResultTableView = UITableView()
        
        searchResultTableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.reuseCellIdentifier)
        searchResultTableView.isHidden = true
        searchResultTableView.translatesAutoresizingMaskIntoConstraints = false
        
        return searchResultTableView
    }()
    
    private let searchResultCollectionView: UICollectionView = {
        let searchResultLayout = UICollectionViewFlowLayout()
        
        searchResultLayout.scrollDirection = .vertical
        searchResultLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let searchResultCollectionView = UICollectionView(frame: .zero, collectionViewLayout: searchResultLayout)
        
        searchResultCollectionView.isHidden = true
        searchResultCollectionView.translatesAutoresizingMaskIntoConstraints = false
        searchResultCollectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier)
        searchResultCollectionView.register(CharacterEpisodeCollectionViewCell.self, forCellWithReuseIdentifier: CharacterEpisodeCollectionViewCell.resueCellIdentifier)
        searchResultCollectionView.register(FooterLoadingCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterLoadingCollectionReusableView.footerLoadingCollectionIdentifier)
        
        return searchResultCollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        addCharacterDetailLoadingIndicatorSubviews(searchResultTableView, searchResultCollectionView)
        addSearchResultConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func processSearchResultViewModel() {
        guard let searchResultViewModel = searchResultViewModel else {
            return
        }
        
        switch searchResultViewModel.searchResults {
        case .characters(let searchResultCharctersViewModels):
            self.searchResultCollectionViewCellViewModels = searchResultCharctersViewModels
            searchResultCollectionViewSetup()
        
        case .locations(let searchResultlocationViewModels):
            searchResultTableViewSetup(viewModels: searchResultlocationViewModels)
        
        case .episodes(let searchResultEpisodeViewModels):
            self.searchResultCollectionViewCellViewModels = searchResultEpisodeViewModels
            searchResultCollectionViewSetup()
        }
    }
    
    private func searchResultCollectionViewSetup() {
        self.searchResultTableView.isHidden = true
        self.searchResultCollectionView.isHidden = false
        searchResultCollectionView.delegate = self
        searchResultCollectionView.dataSource = self
        searchResultCollectionView.reloadData()
    }
    
    private func searchResultTableViewSetup(viewModels: [LocationTableViewCellViewModel]) {
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        searchResultTableView.isHidden = false
        searchResultCollectionView.isHidden = true
        self.searchResultLocationCellViewModels = viewModels
        searchResultTableView.reloadData()
    }
    
    private func addSearchResultConstraints() {
        NSLayoutConstraint.activate([
            searchResultTableView.topAnchor.constraint(equalTo: topAnchor),
            searchResultTableView.leftAnchor.constraint(equalTo: leftAnchor),
            searchResultTableView.rightAnchor.constraint(equalTo: rightAnchor),
            searchResultTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            searchResultCollectionView.topAnchor.constraint(equalTo: topAnchor),
            searchResultCollectionView.leftAnchor.constraint(equalTo: leftAnchor),
            searchResultCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
            searchResultCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    public func searchResultConfiguration(with viewModel: SearchResultViewModel) {
        self.searchResultViewModel = viewModel
    }
}

extension SearchResultsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ searchResultTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultLocationCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt searchResultIndexPath: IndexPath) -> UITableViewCell {
        guard let searchResultCell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseCellIdentifier, for: searchResultIndexPath) as? LocationTableViewCell else {
            fatalError("Failed to dequeue LocationTableViewCell")
        }
        
        searchResultCell.locationTableViewConfiguration(with: searchResultLocationCellViewModels[searchResultIndexPath.row])
        
        return searchResultCell
    }
    
    func tableView(_ searchResultTableView: UITableView, didSelectRowAt searchResultIndexPath: IndexPath) {
        searchResultTableView.deselectRow(at: searchResultIndexPath, animated: true)
        searchResultDelegate?.searchViewResults(self, tapLocationAt: searchResultIndexPath.row)
    }
}

extension SearchResultsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResultCollectionViewCellViewModels.count
    }
    
    func collectionView(_ searchResultCollectionView: UICollectionView, cellForItemAt searchResultIndexPath: IndexPath) -> UICollectionViewCell {
        let searchResultCollectionViewCellViewModel = searchResultCollectionViewCellViewModels[searchResultIndexPath.row]
        
        if let searchResultCharacterViewModel = searchResultCollectionViewCellViewModel as? CharacterCollectionViewCellViewModel {
            guard let searchResultCell = searchResultCollectionView.dequeueReusableCell(
                withReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier,
                for: searchResultIndexPath
            ) as? CharacterCollectionViewCell else {
                fatalError()
            }
            
            searchResultCell.characterCollectionViewConfigure(with: searchResultCharacterViewModel)
        
            return searchResultCell
        }
        
        guard let searchResultCell = searchResultCollectionView.dequeueReusableCell(
            withReuseIdentifier: CharacterEpisodeCollectionViewCell.resueCellIdentifier,
            for: searchResultIndexPath
        ) as? CharacterEpisodeCollectionViewCell else {
            fatalError()
        }
        
        if let searchResultEpisodeViewModel = searchResultCollectionViewCellViewModel as? CharacterEpisodeSectionViewModel {
            searchResultCell.characterEpisodeCollectionViewConfiguration(with: searchResultEpisodeViewModel)
        }
        
        return searchResultCell
    }
    
    func collectionView(_ searchResultCollectionView: UICollectionView, didSelectItemAt searchResultIndexPath: IndexPath) {
        searchResultCollectionView.deselectItem(at: searchResultIndexPath, animated: true)
        
        guard let searchResultViewModel = searchResultViewModel else {
            return
        }
        
        switch searchResultViewModel.searchResults {
        case .characters:
            searchResultDelegate?.searchLocationResultsView(self, tapCharacterAt: searchResultIndexPath.row)
        case .episodes:
            searchResultDelegate?.searchEpisodeResultsView(self, tapEpisodeAt: searchResultIndexPath.row)
        case .locations:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentSearchResultViewModel = searchResultCollectionViewCellViewModels[indexPath.row]
        let searchResultCollectionViewBounds = collectionView.bounds
        
        if currentSearchResultViewModel is CharacterCollectionViewCellViewModel {
            
            let searchResultWidth = UIDevice.checkIfItIsPhoneDevice ? (searchResultCollectionViewBounds.width-30)/2 : (searchResultCollectionViewBounds.width-50)/4
            
            return CGSize(width: searchResultWidth, height: searchResultWidth * 1.5)
        }
        
        let searchResultWidth = UIDevice.checkIfItIsPhoneDevice ? searchResultCollectionViewBounds.width-20 : (searchResultCollectionViewBounds.width-50) / 4
        
        return CGSize(width: searchResultWidth, height: 100)
    }
    
    func collectionView(_ searchResultCollectionView: UICollectionView, viewForSupplementaryElementOfKind searchResultElementKindSectionFooter: String, at searchResultIndexPath: IndexPath) -> UICollectionReusableView {
        guard searchResultElementKindSectionFooter == UICollectionView.elementKindSectionFooter,
              let searchResultFooter = searchResultCollectionView.dequeueReusableSupplementaryView(
                ofKind: searchResultElementKindSectionFooter,
                withReuseIdentifier: FooterLoadingCollectionReusableView.footerLoadingCollectionIdentifier,
                for: searchResultIndexPath
              ) as? FooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        
        if let searchResultViewModel = searchResultViewModel, searchResultViewModel.searchResultLoadingIndicator {
            searchResultFooter.footerLoadingCollectionAnimating()
        }
        
        return searchResultFooter
    }
    
    func collectionView(_ searchResultCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let searchResultViewModel = searchResultViewModel,
              searchResultViewModel.searchResultLoadingIndicator else {
            return .zero
        }
        
        return CGSize(width: searchResultCollectionView.frame.width,
                      height: 100)
    }
}

extension SearchResultsView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ searchResultScrollView: UIScrollView) {
        if !searchResultLocationCellViewModels.isEmpty {
            searchResultlocationHandler(searchResultScrollView: searchResultScrollView)
        } else {
            searchResultHandlerForCharactersAndEpisodes(searchResultScrollView: searchResultScrollView)
        }
    }
    
    private func searchResultHandlerForCharactersAndEpisodes(searchResultScrollView: UIScrollView) {
        guard let searchResultViewModel = searchResultViewModel,
              !searchResultCollectionViewCellViewModels.isEmpty,
              searchResultViewModel.searchResultLoadingIndicator,
              !searchResultViewModel.searchResultsLoading else {
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let searchResultOffset = searchResultScrollView.contentOffset.y
            let searchResultTotalContentHeight = searchResultScrollView.contentSize.height
            let searchResultTotalScrollViewFixedHeight = searchResultScrollView.frame.size.height
            
            if searchResultOffset >= (searchResultTotalContentHeight - searchResultTotalScrollViewFixedHeight - 120) {
                searchResultViewModel.downloadAdditionalSearchResults { [weak self] newSearchResults in
                    guard let searchResultStrongSelf = self else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        searchResultStrongSelf.searchResultTableView.tableFooterView = nil
                        
                        let searchResultOriginalCount = searchResultStrongSelf.searchResultCollectionViewCellViewModels.count
                        let searchResultNewCount = (newSearchResults.count - searchResultOriginalCount)
                        let totalSearchResult = searchResultOriginalCount + searchResultNewCount
                        let startingIndexSearchResult = totalSearchResult - searchResultNewCount
                        let searchResultIndexPathsToAdd: [IndexPath] = Array(startingIndexSearchResult..<(startingIndexSearchResult+searchResultNewCount)).compactMap({
                            return IndexPath(row: $0, section: 0)
                        })
                        searchResultStrongSelf.searchResultCollectionViewCellViewModels = newSearchResults
                        searchResultStrongSelf.searchResultCollectionView.insertItems(at: searchResultIndexPathsToAdd)
                    }
                }
            }
            t.invalidate()
        }
    }
    
    private func searchResultlocationHandler(searchResultScrollView: UIScrollView) {
        guard let searchResultViewModel = searchResultViewModel,
              !searchResultLocationCellViewModels.isEmpty,
              searchResultViewModel.searchResultLoadingIndicator,
              !searchResultViewModel.searchResultsLoading else {
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let searchResultOffset = searchResultScrollView.contentOffset.y
            let searchResultTotalContentHeight = searchResultScrollView.contentSize.height
            let searchResultTotalScrollViewFixedHeight = searchResultScrollView.frame.size.height
            
            if searchResultOffset >= (searchResultTotalContentHeight - searchResultTotalScrollViewFixedHeight - 120) {
                DispatchQueue.main.async {
                    self?.showSearchResultTableLoadingIndicator()
                }
                
                searchResultViewModel.downloadAdditionalSearchResults { [weak self] newSearchResults in
                    self?.searchResultTableView.tableFooterView = nil
                    self?.searchResultLocationCellViewModels = newSearchResults
                    self?.searchResultTableView.reloadData()
                }
            }
            t.invalidate()
        }
    }
    
    private func showSearchResultTableLoadingIndicator() {
        let searchResultFooter = TableLoadingFooterView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 100))
        searchResultTableView.tableFooterView = searchResultFooter
    }
}
