import UIKit

protocol EpisodeListViewModelDelegate: AnyObject {
    func downloadEpisodeList()
    func downloadAddtitionalEpisodeToList(with newIndexPaths: [IndexPath])
    func episodeListSelection(_ episode: Episode)
    func fetchFavouriteEpisodes()
}

final class EpisodeListViewModel: NSObject, FavourtiesDelegate {
    public weak var episodeListDelegate: EpisodeListViewModelDelegate?
    let realmManager = ConcreteRealmManager()
    private var episodeListAPIInfo: EpisodesResponse.Info? = nil
    private var episodeListCharactersLoading = false
    private var episodeListCellViewModels: [CharacterEpisodeSectionViewModel] = []
    private var episodeData = [EpisodeData]()
 
    private let episodeListBorderColors: [UIColor] = [.systemGreen, .systemBlue, .systemOrange, .systemPink, .systemPurple, .systemRed, .systemYellow, .systemIndigo, .systemMint]
    
    private var episodeListArray: [Episode] = [] {
        didSet {
            for episodeList in episodeListArray {
                let episodeListViewModel = CharacterEpisodeSectionViewModel(
                    characterEpisodeBaseURL: URL(string: episodeList.url),
                    characterEpisodeBorderColor: episodeListBorderColors.randomElement() ?? .systemBlue
                )
                if !episodeListCellViewModels.contains(episodeListViewModel) {
                    episodeListCellViewModels.append(episodeListViewModel)
                }
            }
        }
    }
    
    func addToFavourites(cell: UICollectionViewCell, indexPath: IndexPath) {
        let episodeToAddToFavourite = episodeListArray[indexPath.row]
        let newEpisodeData = EpisodeData(name: episodeToAddToFavourite.name, air_date: episodeToAddToFavourite.air_date, episode: episodeToAddToFavourite.episode, url: episodeToAddToFavourite.url, created: episodeToAddToFavourite.created)
        if !episodeData.isEmpty {
            let selectedEpisodeData = episodeData[indexPath.row]
            if realmManager.objectExistsInRealm(object: selectedEpisodeData) {
                realmManager.removeFromRealm(object: selectedEpisodeData)
                self.episodeListCellViewModels.remove(at: indexPath.row)
                self.episodeListDelegate?.fetchFavouriteEpisodes()
            }
        } else {
            realmManager.addToRealm(object: newEpisodeData)
        }
    }
    
    public func downloadEpisodeList() {
        APIService.shared.execute(
            .listEpisodesRequest,
            expecting: EpisodesResponse.self
        ) { [weak self] episodeListResult in
            switch episodeListResult {
            case .success(let episodeListResponseModel):
                let episodeListResults = episodeListResponseModel.results
                let episodeListInfo = episodeListResponseModel.info
                self?.episodeListArray = episodeListResults
                self?.episodeListAPIInfo = episodeListInfo
                DispatchQueue.main.async {
                    self?.episodeListDelegate?.downloadEpisodeList()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    func fetchFavouriteEpisodes() {
        let favouriteEpisodes = realmManager.fetchDataFromRealm(object: EpisodeData.self)
        episodeData.append(contentsOf: favouriteEpisodes)
        for favouriteEpisode in favouriteEpisodes {
            let episode = Episode(id: 1, name: favouriteEpisode.name, air_date: favouriteEpisode.air_date, episode: favouriteEpisode.episode, characters: [], url: favouriteEpisode.url, created: favouriteEpisode.created)
            episodeListArray.append(episode)
        }
        
        self.episodeListDelegate?.fetchFavouriteEpisodes()
    }
    
    public func downloadAdditionalEpisodeList(url: URL) {
        guard !episodeListCharactersLoading else {
            return
        }
        episodeListCharactersLoading = true
        guard let episodeListRequest = APIRequest(url: url) else {
            episodeListCharactersLoading = false
            return
        }
        
        APIService.shared.execute(episodeListRequest, expecting: EpisodesResponse.self) { [weak self] episodeListResult in
            guard let strongSelf = self else {
                return
            }
            switch episodeListResult {
            case .success(let episodeListResponseModel):
                let episodeListAdditionalResults = episodeListResponseModel.results
                let episodeListInfo = episodeListResponseModel.info
                strongSelf.episodeListAPIInfo = episodeListInfo
                
                let episodeListCount = strongSelf.episodeListArray.count
                let newEpisodeListCount = episodeListAdditionalResults.count
                let episodeListTotal = episodeListCount+newEpisodeListCount
                let episodeListStartingIndex = episodeListTotal - newEpisodeListCount
                let episodeListIndexPathsToAdd: [IndexPath] = Array(episodeListStartingIndex..<(episodeListStartingIndex+newEpisodeListCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
                strongSelf.episodeListArray.append(contentsOf: episodeListAdditionalResults)
                
                DispatchQueue.main.async {
                    strongSelf.episodeListDelegate?.downloadAddtitionalEpisodeToList(
                        with: episodeListIndexPathsToAdd
                    )
                    
                    strongSelf.episodeListCharactersLoading = false
                }
            case .failure(let episodeListFailure):
                print(String(describing: episodeListFailure))
                self?.episodeListCharactersLoading = false
            }
        }
    }
    
    public var episodeListLoadingIndicator: Bool {
        return episodeListAPIInfo?.next != nil
    }
}

extension EpisodeListViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodeListCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CharacterEpisodeCollectionViewCell.resueCellIdentifier,
            for: indexPath
        ) as? CharacterEpisodeCollectionViewCell else {
            fatalError("Unsupported cell")
        }
        cell.indexPath = indexPath
        cell.favouritesDelegate = self
        cell.characterEpisodeCollectionViewConfiguration(with: episodeListCellViewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind episodeListKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard episodeListKind == UICollectionView.elementKindSectionFooter,
              let episodeListFooter = collectionView.dequeueReusableSupplementaryView(
                ofKind: episodeListKind,
                withReuseIdentifier: FooterLoadingCollectionReusableView.footerLoadingCollectionIdentifier,
                for: indexPath
              ) as? FooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        episodeListFooter.footerLoadingCollectionAnimating()
        return episodeListFooter
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard episodeListLoadingIndicator else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width,
                      height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let episodeListBounds = collectionView.bounds
        let episodeListWidth = episodeListBounds.width-20
        return CGSize(
            width: episodeListWidth,
            height: 100
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let episodeListSelection = episodeListArray[indexPath.row]
        episodeListDelegate?.episodeListSelection(episodeListSelection)
    }
}

extension EpisodeListViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard episodeListLoadingIndicator,
              !episodeListCharactersLoading,
              !episodeListCellViewModels.isEmpty,
              let nextEpisodeListURLString = episodeListAPIInfo?.next,
              let episodeListURL = URL(string: nextEpisodeListURLString) else {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let episodeListOffset = scrollView.contentOffset.y
            let episodeListTotalContentHeight = scrollView.contentSize.height
            let episodeListTotalScrollViewFixedHeight = scrollView.frame.size.height
            
            if episodeListOffset >= (episodeListTotalContentHeight - episodeListTotalScrollViewFixedHeight - 120) {
                self?.downloadAdditionalEpisodeList(url: episodeListURL)
            }
            t.invalidate()
        }
    }
}
