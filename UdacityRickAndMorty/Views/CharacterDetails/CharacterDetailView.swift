import UIKit

final class CharacterDetailView: UIView {

    public var collectionView: UICollectionView?
    private let viewModel: CharacterDetailViewModel

    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    init(frame: CGRect, viewModel: CharacterDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    private func setUpUI() {
        let collectionView = createCollectionView()
        self.collectionView = collectionView
        addSubviews(collectionView, loadingIndicator)
        addConstraints()
    }

    private func addConstraints() {
        guard let collectionView = collectionView else {
            return
        }

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

    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.createSection(for: sectionIndex)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CharacterPhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: CharacterPhotoCollectionViewCell.cellIdentifier)
        collectionView.register(CharacterInfoCollectionViewCell.self,
                                forCellWithReuseIdentifier: CharacterInfoCollectionViewCell.cellIdentifier)
        collectionView.register(CharacterEpisodeCollectionViewCell.self,
                                forCellWithReuseIdentifier: CharacterEpisodeCollectionViewCell.cellIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }

    private func createSection(for sectionIndex: Int) -> NSCollectionLayoutSection {
        let sectionTypes = viewModel.sections
        
        switch sectionTypes[sectionIndex]  {
        case .photo:
            return viewModel.createPhotoSectionLayout()
        case .information:
            return viewModel.createInfoSectionLayout()
        case .episodes:
            return viewModel.createEpisodeSectionLayout()
        }
    }
}
