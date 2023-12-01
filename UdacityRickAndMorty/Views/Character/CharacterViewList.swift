import UIKit

protocol CharacterListViewDelegate: AnyObject {
    func downloadFullCharacterViewList(_ characterListView: CharacterViewList, selectCharacter character: Character)
}

final class CharacterViewList: UIView {
    
    weak var characterListDelegate: CharacterListViewDelegate?
    private let characterListViewModel = CharacterListViewModel()
    
    private let characterListViewLoadingIndicator: UIActivityIndicatorView = {
        let characterListViewLoadingIndicator = UIActivityIndicatorView(style: .large)
        characterListViewLoadingIndicator.hidesWhenStopped = true
        characterListViewLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        return characterListViewLoadingIndicator
    }()
    
    private let characterListViewCollectionView: UICollectionView = {
        let characterListViewLayout = UICollectionViewFlowLayout()
        characterListViewLayout.scrollDirection = .vertical
        characterListViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        
        let characterListViewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: characterListViewLayout)
        characterListViewCollectionView.isHidden = true
        characterListViewCollectionView.alpha = 0
        characterListViewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        characterListViewCollectionView.register(CharacterCollectionViewCell.self,
                                                 forCellWithReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier)
        characterListViewCollectionView.register(FooterLoadingCollectionReusableView.self,
                                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                                 withReuseIdentifier: FooterLoadingCollectionReusableView.footerLoadingCollectionIdentifier)
        return characterListViewCollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        characterListViewUISetup()
        characterListViewModelSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    private func characterListViewUISetup() {
        translatesAutoresizingMaskIntoConstraints = false
        addCharacterDetailLoadingIndicatorSubviews(characterListViewCollectionView, characterListViewLoadingIndicator)
        addCharacterListViewConstraints()
        characterListViewLoadingIndicator.startAnimating()
        characterListCollectionViewSetup()
    }
    
    private func addCharacterListViewConstraints() {
        NSLayoutConstraint.activate([
            characterListViewLoadingIndicator.widthAnchor.constraint(equalToConstant: 100),
            characterListViewLoadingIndicator.heightAnchor.constraint(equalToConstant: 100),
            characterListViewLoadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            characterListViewLoadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            characterListViewCollectionView.topAnchor.constraint(equalTo: topAnchor),
            characterListViewCollectionView.leftAnchor.constraint(equalTo: leftAnchor),
            characterListViewCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
            characterListViewCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func characterListCollectionViewSetup() {
        characterListViewCollectionView.dataSource = characterListViewModel
        characterListViewCollectionView.delegate = characterListViewModel
    }
    
    private func characterListViewModelSetup() {
        characterListViewModel.characterListDelegate = self
        characterListViewModel.fetchCharacterList()
    }
}

extension CharacterViewList: CharacterListViewModelDelegate {
    func characterListViewSectionSetup(_ character: Character) {
        characterListDelegate?.downloadFullCharacterViewList(self, selectCharacter: character)
    }
    
    func updateCharacterLit() {
        characterListViewLoadingIndicator.stopAnimating()
        characterListViewCollectionView.isHidden = false
        characterListViewCollectionView.reloadData()
        UIView.animate(withDuration: 0.4) {
            self.characterListViewCollectionView.alpha = 1
        }
    }
    
    func downloaadAdditionalCharacterLit(with newIndexPaths: [IndexPath]) {
        characterListViewCollectionView.performBatchUpdates {
            self.characterListViewCollectionView.insertItems(at: newIndexPaths)
        }
    }
}
