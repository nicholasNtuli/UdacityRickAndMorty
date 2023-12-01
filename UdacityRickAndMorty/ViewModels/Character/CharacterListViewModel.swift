import UIKit

protocol CharacterListViewModelDelegate: AnyObject {
    func updateCharacterLit()
    func downloaadAdditionalCharacterLit(with newIndexPaths: [IndexPath])
    func characterListViewSectionSetup(_ character: Character)
}

final class CharacterListViewModel: NSObject {
    
    weak var characterListDelegate: CharacterListViewModelDelegate?
    private var characterCollectionViewCellViewModels: [CharacterCollectionViewCellViewModel] = []
    private var characterListAPIInfo: CharactersResponse.Info?
    private var loadMoreToCharacterList = false
    
    private var charactersList: [Character] = [] {
        didSet {
            updateCharacterListCellViewModels()
        }
    }
    
    func fetchCharacterList() {
        APIService.shared.execute(
            .listCharactersRequests,
            expecting: CharactersResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let responseModel):
                self?.handleSuccessResponse(responseModel.results, info: responseModel.info)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func fetchMoreCharactersForList() {
        guard !loadMoreToCharacterList,
              let nextCharacterListURLString = characterListAPIInfo?.next,
              let characterListURL = URL(string: nextCharacterListURLString),
              let characterListRequest = APIRequest(url: characterListURL) else {
            return
        }
        
        loadMoreToCharacterList = true
        APIService.shared.execute(characterListRequest, expecting: CharactersResponse.self) { [weak self] characterListResult in
            guard let strongSelf = self else { return }
            
            switch characterListResult {
            case .success(let responseModel):
                strongSelf.handleSuccessResponse(responseModel.results, info: responseModel.info)
                strongSelf.loadMoreToCharacterList = false
            case .failure(let error):
                print("Error: \(error)")
                strongSelf.loadMoreToCharacterList = false
            }
        }
    }
    
    var shouldShowCharacterListLoadingIndicator: Bool {
        return characterListAPIInfo?.next != nil
    }
}

extension CharacterListViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characterCollectionViewCellViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? CharacterCollectionViewCell else {
            fatalError("Unsupported cell")
        }
        cell.characterCollectionViewConfigure(with: characterCollectionViewCellViewModels[indexPath.row])
        return cell
    }
}

extension CharacterListViewModel: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind characterListKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard characterListKind == UICollectionView.elementKindSectionFooter,
              let characterListFooter = collectionView.dequeueReusableSupplementaryView(
                ofKind: characterListKind,
                withReuseIdentifier: FooterLoadingCollectionReusableView.footerLoadingCollectionIdentifier,
                for: indexPath
              ) as? FooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        characterListFooter.footerLoadingCollectionAnimating()
        return characterListFooter
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowCharacterListLoadingIndicator else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let characterListBounds = collectionView.bounds
        let characterListWidth: CGFloat
        
        if UIDevice.checkIfItIsPhoneDevice {
            characterListWidth = (characterListBounds.width - 30) / 2
        } else {
            characterListWidth = (characterListBounds.width - 50) / 4
        }
        
        return CGSize(width: characterListWidth, height: characterListWidth * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let characterList = charactersList[indexPath.row]
        characterListDelegate?.characterListViewSectionSetup(characterList)
    }
}

extension CharacterListViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowCharacterListLoadingIndicator,
              !loadMoreToCharacterList,
              !characterCollectionViewCellViewModels.isEmpty,
              let nextcharacterListURLString = characterListAPIInfo?.next,
              let _ = URL(string: nextcharacterListURLString) else {
            return
        }
        
        let characterListOffset = scrollView.contentOffset.y
        let characterListTotalContentHeight = scrollView.contentSize.height
        let characterListTotalScrollViewFixedHeight = scrollView.frame.size.height
        
        if characterListOffset >= (characterListTotalContentHeight - characterListTotalScrollViewFixedHeight - 120) {
            fetchMoreCharactersForList()
        }
    }
}

private extension CharacterListViewModel {
    func handleSuccessResponse(_ results: [Character], info: CharactersResponse.Info) {
        charactersList = results
        characterListAPIInfo = info
        DispatchQueue.main.async { [self] in
            characterListDelegate?.updateCharacterLit()
        }
    }
    func updateCharacterListCellViewModels() {
        var updatedCharacterListViewModels: [CharacterCollectionViewCellViewModel] = []

        for characterInList in charactersList {
            let characterListViewModel = CharacterCollectionViewCellViewModel(
                characterCollectionViewCellCharacterName: characterInList.name,
                characterCollectionViewCellCharacterStatus: characterInList.status,
                characterCollectionViewCellCharacterImageUrl: URL(string: characterInList.image)
            )

            if let existingCharacterListViewModel = characterCollectionViewCellViewModels.first(where: { $0 == characterListViewModel }) {
                existingCharacterListViewModel.characterCollectionViewCellCharacterName = characterListViewModel.characterCollectionViewCellCharacterName
                existingCharacterListViewModel.characterCollectionViewCellCharacterStatus = characterListViewModel.characterCollectionViewCellCharacterStatus
                existingCharacterListViewModel.characterCollectionViewCellCharacterImageUrl = characterListViewModel.characterCollectionViewCellCharacterImageUrl
                updatedCharacterListViewModels.append(existingCharacterListViewModel)
            } else {
                updatedCharacterListViewModels.append(characterListViewModel)
            }
        }

        characterCollectionViewCellViewModels = updatedCharacterListViewModels
    }
}
