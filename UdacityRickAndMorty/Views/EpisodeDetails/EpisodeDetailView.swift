import UIKit

protocol EpisodeDetailViewDelegate: AnyObject {
    func loadEpisodeDetailView(_ episodeDetailView: EpisodeDetailView, select character: Character)
}

final class EpisodeDetailView: UIView {

    public weak var episodeDetailDelegate: EpisodeDetailViewDelegate?
    private var episodeDetailCollectionView: UICollectionView?

    private var episodeDetailViewModel: EpisodeDetailViewModel? {
        didSet {
            episodeDetailLoadingIndicator.stopAnimating()
            self.episodeDetailCollectionView?.reloadData()
            self.episodeDetailCollectionView?.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.episodeDetailCollectionView?.alpha = 1
            }
        }
    }

    private let episodeDetailLoadingIndicator: UIActivityIndicatorView = {
        let episodeDetailLoadingIndicator = UIActivityIndicatorView()
        episodeDetailLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        episodeDetailLoadingIndicator.hidesWhenStopped = true
        return episodeDetailLoadingIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        let episodeDetailCollectionView = createEpisodeDetailColectionView()
        addCharacterDetailLoadingIndicatorSubviews(episodeDetailCollectionView, episodeDetailLoadingIndicator)
        self.episodeDetailCollectionView = episodeDetailCollectionView
        episodeDetailConstraintsSetup()

        episodeDetailLoadingIndicator.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    private func episodeDetailConstraintsSetup() {
        guard let episodeDetailCollectionView = episodeDetailCollectionView else {
            return
        }

        NSLayoutConstraint.activate([
            episodeDetailLoadingIndicator.heightAnchor.constraint(equalToConstant: 100),
            episodeDetailLoadingIndicator.widthAnchor.constraint(equalToConstant: 100),
            episodeDetailLoadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            episodeDetailLoadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            episodeDetailCollectionView.topAnchor.constraint(equalTo: topAnchor),
            episodeDetailCollectionView.leftAnchor.constraint(equalTo: leftAnchor),
            episodeDetailCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
            episodeDetailCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func createEpisodeDetailColectionView() -> UICollectionView {
        let episodeDetailLayout = UICollectionViewCompositionalLayout { section, _ in
            return self.episodeDetailLayout(for: section)
        }
        
        let episodeDetailCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: episodeDetailLayout
        )
        
        episodeDetailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        episodeDetailCollectionView.isHidden = true
        episodeDetailCollectionView.alpha = 0
        episodeDetailCollectionView.delegate = self
        episodeDetailCollectionView.dataSource = self
        episodeDetailCollectionView.register(EpisodeInfoCollectionViewCell.self,
                                forCellWithReuseIdentifier: EpisodeInfoCollectionViewCell.episodeInfoCollectionViewCellIdentifier)
        episodeDetailCollectionView.register(CharacterCollectionViewCell.self,
                                forCellWithReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier)
        
        return episodeDetailCollectionView
    }
    
    public func episodeDetailConfiguration(with episodeDetailViewModel: EpisodeDetailViewModel) {
        self.episodeDetailViewModel = episodeDetailViewModel
    }
}

extension EpisodeDetailView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return episodeDetailViewModel?.episodeDetailCellViewModels.count ?? 0
    }

    func collectionView(_ episodeDetailCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let episodeDetailSections = episodeDetailViewModel?.episodeDetailCellViewModels else {
            return 0
        }
        
        let episodeDetailSectionType = episodeDetailSections[section]

        switch episodeDetailSectionType {
        case .episodeDetailInformation(let episodeDetailInformationViewModels):
            return episodeDetailInformationViewModels.count
        case .episodeDetailCharacters(let episodeDetailCharactersViewModels):
            return episodeDetailCharactersViewModels.count
        }
    }

    func collectionView(_ episodeDetailCollectionView: UICollectionView, cellForItemAt episodeDetailIndexPath: IndexPath) -> UICollectionViewCell {
        guard let episodeDetailCollectionViewSections = episodeDetailViewModel?.episodeDetailCellViewModels else {
            fatalError("No viewModel")
        }
        
        let episodeDetailCollectionViewSsectionType = episodeDetailCollectionViewSections[episodeDetailIndexPath.section]

        switch episodeDetailCollectionViewSsectionType {
        case .episodeDetailInformation(let episodeDetailInformationViewModel):
            let episodeDetailCellViewModel = episodeDetailInformationViewModel[episodeDetailIndexPath.row]
            
            guard let episodeDetailCell = episodeDetailCollectionView.dequeueReusableCell(
                withReuseIdentifier: EpisodeInfoCollectionViewCell.episodeInfoCollectionViewCellIdentifier,
                for: episodeDetailIndexPath
            ) as? EpisodeInfoCollectionViewCell else {
                fatalError()
            }
            
            episodeDetailCell.episodeInfoCollectionViewConfiguration(with: episodeDetailCellViewModel)
            
            return episodeDetailCell
        
        case .episodeDetailCharacters(let episodeDetailViewModels):
            let episodeDetailCellViewModel = episodeDetailViewModels[episodeDetailIndexPath.row]
            
            guard let episodeDetailCell = episodeDetailCollectionView.dequeueReusableCell(
                withReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier,
                for: episodeDetailIndexPath
            ) as? CharacterCollectionViewCell else {
                fatalError()
            }
            
            episodeDetailCell.characterCollectionViewConfigure(with: episodeDetailCellViewModel)
            
            return episodeDetailCell
        }
    }

    func collectionView(_ episodeDetailCollectionView: UICollectionView, didSelectItemAt episodeDetailIndexPath: IndexPath) {
        episodeDetailCollectionView.deselectItem(at: episodeDetailIndexPath, animated: true)
        
        guard let episodeDetailViewModel = episodeDetailViewModel else {
            return
        }
        
        let episodeDetailSections = episodeDetailViewModel.episodeDetailCellViewModels
        let episodeDetailSectionType = episodeDetailSections[episodeDetailIndexPath.section]

        switch episodeDetailSectionType {
        case .episodeDetailInformation:
            break
        case .episodeDetailCharacters:
            guard let episodeDetailCharacter = episodeDetailViewModel.episodeDetailCharacter(at: episodeDetailIndexPath.row) else {
                return
            }
            episodeDetailDelegate?.loadEpisodeDetailView(self, select: episodeDetailCharacter)
        }
    }
}

extension EpisodeDetailView {
    func episodeDetailLayout(for sectionForEpisodeDetail: Int) -> NSCollectionLayoutSection {
        guard let episodeDetailSections = episodeDetailViewModel?.episodeDetailCellViewModels else {
            return createEpisodeDetailInfoLayout()
        }

        switch episodeDetailSections[sectionForEpisodeDetail] {
        case .episodeDetailInformation:
            return createEpisodeDetailInfoLayout()
        case .episodeDetailCharacters:
            return createEpisodeDetailCharacterLayout()
        }
    }

    func createEpisodeDetailInfoLayout() -> NSCollectionLayoutSection {
        let episodeDetailItem = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        )

        episodeDetailItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let episodeDetailGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .absolute(80)),
            subitems: [episodeDetailItem]
        )

        let sectionForEpisodeDetail = NSCollectionLayoutSection(group: episodeDetailGroup)

        return sectionForEpisodeDetail
    }

    func createEpisodeDetailCharacterLayout() -> NSCollectionLayoutSection {
        let episodeDetailItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(UIDevice.checkIfItIsPhoneDevice ? 0.5 : 0.25),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        episodeDetailItem.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: 10,
            bottom: 5,
            trailing: 10
        )

        let episodeDetailGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize:  NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(UIDevice.checkIfItIsPhoneDevice ? 260 : 320)
            ),
            subitems: UIDevice.checkIfItIsPhoneDevice ? [episodeDetailItem, episodeDetailItem] : [episodeDetailItem, episodeDetailItem, episodeDetailItem, episodeDetailItem]
        )
        
        let episodeDetailSection = NSCollectionLayoutSection(group: episodeDetailGroup)
        
        return episodeDetailSection
    }
}
