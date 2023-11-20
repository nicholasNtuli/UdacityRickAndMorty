import UIKit

protocol CharacterListViewModelDelegate: AnyObject {
    func loadInitialCharacters()
    func loadMoreCharacters(with newIndexPaths: [IndexPath])
    func selectCharacter(_ character: Character)
}

final class CharacterListViewModel: NSObject {
    
    weak var delegate: CharacterListViewModelDelegate?
    private var cellViewModels: [CharacterCollectionViewCellViewModel] = []
    private var apiInfo: CharactersResponse.Info?
    private var isLoadingMoreCharacters = false
    
    private var characters: [Character] = [] {
        didSet {
            updateCellViewModels()
        }
    }
    
    func fetchCharacters() {
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
    
    func fetchAdditionalCharacters() {
        guard !isLoadingMoreCharacters,
              let nextUrlString = apiInfo?.next,
              let url = URL(string: nextUrlString),
              let request = APIRequest(url: url) else {
            return
        }
        
        isLoadingMoreCharacters = true
        APIService.shared.execute(request, expecting: CharactersResponse.self) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let responseModel):
                strongSelf.handleSuccessResponse(responseModel.results, info: responseModel.info)
                strongSelf.isLoadingMoreCharacters = false
            case .failure(let error):
                print("Error: \(error)")
                strongSelf.isLoadingMoreCharacters = false
            }
        }
    }
    
    var shouldShowLoadMoreIndicator: Bool {
        return apiInfo?.next != nil
    }
}

extension CharacterListViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? CharacterCollectionViewCell else {
            fatalError("Unsupported cell")
        }
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
}

extension CharacterListViewModel: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: FooterLoadingCollectionReusableView.identifier,
                for: indexPath
              ) as? FooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        footer.startAnimating()
        return footer
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadMoreIndicator else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        let width: CGFloat
        if UIDevice.isiPhone {
            width = (bounds.width - 30) / 2
        } else {
            width = (bounds.width - 50) / 4
        }
        
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        delegate?.selectCharacter(character)
    }
}

extension CharacterListViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator,
              !isLoadingMoreCharacters,
              !cellViewModels.isEmpty,
              let nextUrlString = apiInfo?.next,
              let _ = URL(string: nextUrlString) else {
            return
        }
        
        let offset = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height
        
        if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
            fetchAdditionalCharacters()
        }
    }
}

private extension CharacterListViewModel {
    func handleSuccessResponse(_ results: [Character], info: CharactersResponse.Info) {
        characters = results
        apiInfo = info
        DispatchQueue.main.async { [self] in
            delegate?.loadInitialCharacters()
        }
    }

    func updateCellViewModels() {
        for character in characters {
            let viewModel = CharacterCollectionViewCellViewModel(
                characterName: character.name,
                characterStatus: character.status,
                characterImageUrl: URL(string: character.image)
            )
            if !cellViewModels.contains(viewModel) {
                cellViewModels.append(viewModel)
            }
        }
    }
}
