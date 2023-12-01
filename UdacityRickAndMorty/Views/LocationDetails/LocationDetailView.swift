import UIKit

protocol LocationDetailViewDelegate: AnyObject {
    func loadLocationDetaiEepisodeDetailView(_ locationDetailView: LocationDetailView, locationDetailSelection character: Character)
}

final class LocationDetailView: UIView {

    public weak var locationDetailDelegate: LocationDetailViewDelegate?
    private var locationDetailCollectionView: UICollectionView?
    
    private var locationDetailViewModel: LocationDetailViewModel? {
        didSet {
            locationDetailLoadingIndicator.stopAnimating()
            self.locationDetailCollectionView?.reloadData()
            self.locationDetailCollectionView?.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.locationDetailCollectionView?.alpha = 1
            }
        }
    }

    private let locationDetailLoadingIndicator: UIActivityIndicatorView = {
        let locationDetailLoadingIndicator = UIActivityIndicatorView()
        locationDetailLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        locationDetailLoadingIndicator.hidesWhenStopped = true
        return locationDetailLoadingIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        let locationDetailCollectionView = locationDetailCreateColectionView()
        addCharacterDetailLoadingIndicatorSubviews(locationDetailCollectionView, locationDetailLoadingIndicator)
        self.locationDetailCollectionView = locationDetailCollectionView
        addLocationDetailConstraints()
        locationDetailLoadingIndicator.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    private func addLocationDetailConstraints() {
        guard let locationDetailCollectionView = locationDetailCollectionView else {
            return
        }

        NSLayoutConstraint.activate([
            locationDetailLoadingIndicator.heightAnchor.constraint(equalToConstant: 100),
            locationDetailLoadingIndicator.widthAnchor.constraint(equalToConstant: 100),
            locationDetailLoadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            locationDetailLoadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            locationDetailCollectionView.topAnchor.constraint(equalTo: topAnchor),
            locationDetailCollectionView.leftAnchor.constraint(equalTo: leftAnchor),
            locationDetailCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
            locationDetailCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func locationDetailCreateColectionView() -> UICollectionView {
        let locationDetailLayout = UICollectionViewCompositionalLayout { section, _ in
            return self.locationDetailLayout(for: section)
        }
        
        let locationDetailCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: locationDetailLayout
        )
        
        locationDetailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        locationDetailCollectionView.isHidden = true
        locationDetailCollectionView.alpha = 0
        locationDetailCollectionView.delegate = self
        locationDetailCollectionView.dataSource = self
        locationDetailCollectionView.register(EpisodeInfoCollectionViewCell.self,
                                forCellWithReuseIdentifier: EpisodeInfoCollectionViewCell.episodeInfoCollectionViewCellIdentifier)
        locationDetailCollectionView.register(CharacterCollectionViewCell.self,
                                forCellWithReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier)
        
        return locationDetailCollectionView
    }
    
    public func locationDetailConfiguration(with locationDetailViewModel: LocationDetailViewModel) {
        self.locationDetailViewModel = locationDetailViewModel
    }
}

extension LocationDetailView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return locationDetailViewModel?.locationDetailCellViewModels.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let locationDetailSections = locationDetailViewModel?.locationDetailCellViewModels else {
            return 0
        }
        
        let locationDetailSectionType = locationDetailSections[section]

        switch locationDetailSectionType {
        case .locationDetailInformation(let viewModels):
            return viewModels.count
        case .locationDetailCharacters(let viewModels):
            return viewModels.count
        }
    }

    func collectionView(_ locationDetailCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let locationDetailSections = locationDetailViewModel?.locationDetailCellViewModels else {
            fatalError("No viewModel")
        }
        
        let locationDetailSectionType = locationDetailSections[indexPath.section]

        switch locationDetailSectionType {
        case .locationDetailInformation(let locationDetailViewModels):
            let locationDetailCellViewModel = locationDetailViewModels[indexPath.row]
            
            guard let locationDetailCell = locationDetailCollectionView.dequeueReusableCell(
                withReuseIdentifier: EpisodeInfoCollectionViewCell.episodeInfoCollectionViewCellIdentifier,
                for: indexPath
            ) as? EpisodeInfoCollectionViewCell else {
                fatalError()
            }
            
            locationDetailCell.episodeInfoCollectionViewConfiguration(with: locationDetailCellViewModel)
            
            return locationDetailCell
            
        case .locationDetailCharacters(let locationDetailViewModels):
            let locationDetailCellViewModel = locationDetailViewModels[indexPath.row]
            
            guard let locationDetailCell = locationDetailCollectionView.dequeueReusableCell(
                withReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? CharacterCollectionViewCell else {
                fatalError()
            }
            
            locationDetailCell.characterCollectionViewConfigure(with: locationDetailCellViewModel)
            
            return locationDetailCell
        }
    }

    func collectionView(_ locationDetailCollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        locationDetailCollectionView.deselectItem(at: indexPath, animated: true)
        
        guard let locationDetailViewModel = locationDetailViewModel else {
            return
        }
        
        let locationDetailSections = locationDetailViewModel.locationDetailCellViewModels
        let locationDetailSectionType = locationDetailSections[indexPath.section]

        switch locationDetailSectionType {
        case .locationDetailInformation:
            break
        
        case .locationDetailCharacters:
            guard let locationDetailCharacters = locationDetailViewModel.locationDetailCharacter(at: indexPath.row) else {
                return
            }
            locationDetailDelegate?.loadLocationDetaiEepisodeDetailView(self, locationDetailSelection: locationDetailCharacters)
        }
    }
}

extension LocationDetailView {
    func locationDetailLayout(for section: Int) -> NSCollectionLayoutSection {
        guard let locationDetailSections = locationDetailViewModel?.locationDetailCellViewModels else {
            return createLocationDetailInfoLayout()
        }

        switch locationDetailSections[section] {
        case .locationDetailInformation:
            return createLocationDetailInfoLayout()
        case .locationDetailCharacters:
            return createLocationDetailCharacterLayout()
        }
    }

    func createLocationDetailInfoLayout() -> NSCollectionLayoutSection {

        let locationDetailItem = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        )

        locationDetailItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let locationDetailGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .absolute(80)),
            subitems: [locationDetailItem]
        )

        let locationDetailSection = NSCollectionLayoutSection(group: locationDetailGroup)

        return locationDetailSection
    }

    func createLocationDetailCharacterLayout() -> NSCollectionLayoutSection {
        let locationDetailItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(UIDevice.checkIfItIsPhoneDevice ? 0.5 : 0.25),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        locationDetailItem.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: 10,
            bottom: 5,
            trailing: 10
        )

        let locationDetailGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize:  NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(UIDevice.checkIfItIsPhoneDevice ? 260 : 320)
            ),
            subitems: UIDevice.checkIfItIsPhoneDevice ? [locationDetailItem, locationDetailItem] : [locationDetailItem, locationDetailItem, locationDetailItem, locationDetailItem]
        )
        
        let locationDetailSection = NSCollectionLayoutSection(group: locationDetailGroup)
        
        return locationDetailSection
    }
}
