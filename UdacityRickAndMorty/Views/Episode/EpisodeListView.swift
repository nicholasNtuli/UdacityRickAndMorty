import UIKit

protocol EpisodeListViewDelegate: AnyObject {
    func episodeListViewController(
        _ characterListView: EpisodeListView,
        selectEpisode episode: Episode
    )
}

final class EpisodeListView: UIView {
    
    public weak var delegate: EpisodeListViewDelegate?
    private let viewModel = EpisodeListViewModel()
    var isFavourites = false
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        return loadingIndicator
    }()
    
    public let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.alpha = 0
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CharacterEpisodeCollectionViewCell.self,
                                forCellWithReuseIdentifier: CharacterEpisodeCollectionViewCell.resueCellIdentifier)
        collectionView.register(FooterLoadingCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: FooterLoadingCollectionReusableView.footerLoadingCollectionIdentifier)
        return collectionView
    }()
    
    init(isFavourites: Bool = false) {
        self.isFavourites = isFavourites
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addCharacterDetailLoadingIndicatorSubviews(collectionView, loadingIndicator)
        addConstraints()
        loadingIndicator.startAnimating()
        setUpCollectionView()
        viewModel.episodeListDelegate = self
        
        if isFavourites {
            callOnFavouritesList()
        } else {
            callOnDownloadList()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    public func callOnDownloadList() {
        viewModel.downloadEpisodeList()
    }
    
    public func callOnFavouritesList() {
        loadingIndicator.startAnimating()
        viewModel.fetchFavouriteEpisodes()
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            loadingIndicator.widthAnchor.constraint(equalToConstant: 100),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 100),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setUpCollectionView() {
        collectionView.dataSource = viewModel
        collectionView.delegate = viewModel
    }
}

extension EpisodeListView: EpisodeListViewModelDelegate {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let topViewController = windowScene.windows.first?.rootViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func fetchFavouriteEpisodes() {
        loadingIndicator.stopAnimating()
        collectionView.isHidden = false
        collectionView.reloadData()
        UIView.animate(withDuration: 0.4) {
            self.collectionView.alpha = 1
        }
    }
    
    func downloadEpisodeList() {
        loadingIndicator.stopAnimating()
        collectionView.isHidden = false
        collectionView.reloadData()
        UIView.animate(withDuration: 0.4) {
            self.collectionView.alpha = 1
        }
    }
    
    func downloadAddtitionalEpisodeToList(with newIndexPaths: [IndexPath]) {
        collectionView.performBatchUpdates {
            self.collectionView.insertItems(at: newIndexPaths)
        }
    }
    
    func episodeListSelection(_ episode: Episode) {
        delegate?.episodeListViewController(self, selectEpisode: episode)
    }
}
