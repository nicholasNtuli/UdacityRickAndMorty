import UIKit

final class CharacterDetailViewController: UIViewController {
    
    private let charachterDetailViewModel: CharacterDetailViewModel
    private let charachterDetailView: CharacterDetailView
    
    init(viewModel: CharacterDetailViewModel) {
        self.charachterDetailViewModel = viewModel
        self.charachterDetailView = CharacterDetailView(frame: .zero, viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = charachterDetailViewModel.characterDetailName
        view.addSubview(charachterDetailView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(tapCharacterDetailShareButton)
        )
        
        addCharachterDetailConstraints()
        charachterDetailView.characterDetailCollectionView?.delegate = self
        charachterDetailView.characterDetailCollectionView?.dataSource = self
    }

    @objc
    private func tapCharacterDetailShareButton() {}

    private func addCharachterDetailConstraints() {
        NSLayoutConstraint.activate([
            charachterDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            charachterDetailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            charachterDetailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            charachterDetailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension CharacterDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return charachterDetailViewModel.characterSections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let charachterDetailSectionType = charachterDetailViewModel.characterSections[section]
        
        switch charachterDetailSectionType {
        case .characterPhotoSection:
            return 1
        case .characterInformationSection(let characterInformationViewModels):
            return characterInformationViewModels.count
        case .characterEpisodeSection(let characterEpisodeViewModels):
            return characterEpisodeViewModels.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let charachterDetailSectionType = charachterDetailViewModel.characterSections[indexPath.section]
        
        switch charachterDetailSectionType {
        case .characterPhotoSection(let characterPhotoSectionViewModel):
            guard let charachterDetailCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CharacterPhotoCollectionViewCell.reuseCellIdentifier,
                for: indexPath
            ) as? CharacterPhotoCollectionViewCell else {
                fatalError()
            }
            
            charachterDetailCell.characterPhotoCollectionConfiguration(with: characterPhotoSectionViewModel)
            
            return charachterDetailCell
        
        case .characterInformationSection(let charachterInformationViewModels):
            guard let charachterDetailCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CharacterInfoCollectionViewCell.reuseCellIdentifier,
                for: indexPath
            ) as? CharacterInfoCollectionViewCell else {
                fatalError()
            }
            
            charachterDetailCell.characterInformationCollectionConfiguration(with: charachterInformationViewModels[indexPath.row])
            
            return charachterDetailCell
        
        case .characterEpisodeSection(let characterEpisodeViewModels):
            guard let charachterEpisodeCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CharacterEpisodeCollectionViewCell.resueCellIdentifier,
                for: indexPath
            ) as? CharacterEpisodeCollectionViewCell else {
                fatalError()
            }
            
            let charachterEpisodeViewModels = characterEpisodeViewModels[indexPath.row]
            
            charachterEpisodeCell.characterEpisodeCollectionViewConfiguration(with: charachterEpisodeViewModels)
            
            return charachterEpisodeCell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let charachterDetailSectionType = charachterDetailViewModel.characterSections[indexPath.section]
        
        switch charachterDetailSectionType {
        case .characterPhotoSection, .characterInformationSection:
            break
        case .characterEpisodeSection:
            let charachterDetailEpisodes = self.charachterDetailViewModel.characterDetailEpisodes
            let charachterDetailSelection = charachterDetailEpisodes[indexPath.row]
            let charachterDetailViewController = EpisodeDetailViewController(url: URL(string: charachterDetailSelection))
            navigationController?.pushViewController(charachterDetailViewController, animated: true)
        }
    }
}
