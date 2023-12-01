import UIKit

final class CharacterDetailView: UIView {

    public var characterDetailCollectionView: UICollectionView?
    private let characterDetailViewModel: CharacterDetailViewModel

    private let characterDetailLoadingIndicator: UIActivityIndicatorView = {
        let characterDetailLoadingIndicator = UIActivityIndicatorView(style: .large)
        characterDetailLoadingIndicator.hidesWhenStopped = true
        characterDetailLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        return characterDetailLoadingIndicator
    }()

    init(frame: CGRect, viewModel: CharacterDetailViewModel) {
        self.characterDetailViewModel = viewModel
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        characterDetailLoadingIndicatorUISetup()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    private func characterDetailLoadingIndicatorUISetup() {
        let characterDetailLoadingIndicatorCollectionView = characterDetailLoadingIndicatorCreateCollectionView()
        self.characterDetailCollectionView = characterDetailLoadingIndicatorCollectionView
        addCharacterDetailLoadingIndicatorSubviews(characterDetailLoadingIndicatorCollectionView, characterDetailLoadingIndicator)
        addCharacterDetailLoadingIndicatorConstraints()
    }

    private func addCharacterDetailLoadingIndicatorConstraints() {
        guard let characterDetailLoadingIndicatorCollectionView = characterDetailCollectionView else {
            return
        }

        NSLayoutConstraint.activate([
            characterDetailLoadingIndicator.widthAnchor.constraint(equalToConstant: 100),
            characterDetailLoadingIndicator.heightAnchor.constraint(equalToConstant: 100),
            characterDetailLoadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            characterDetailLoadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            characterDetailLoadingIndicatorCollectionView.topAnchor.constraint(equalTo: topAnchor),
            characterDetailLoadingIndicatorCollectionView.leftAnchor.constraint(equalTo: leftAnchor),
            characterDetailLoadingIndicatorCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
            characterDetailLoadingIndicatorCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func characterDetailLoadingIndicatorCreateCollectionView() -> UICollectionView {
        let characterDetailLoadingIndicatorLayout = UICollectionViewCompositionalLayout { characterDetailLoadingIndicatorSectionIndex, _ in
            return self.createCharacterDetailLoadingIndicatorSection(for: characterDetailLoadingIndicatorSectionIndex)
        }
        
        let characterDetailLoadingIndicatorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: characterDetailLoadingIndicatorLayout)
        characterDetailLoadingIndicatorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        characterDetailLoadingIndicatorCollectionView
            .register(CharacterPhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: CharacterPhotoCollectionViewCell.reuseCellIdentifier)
        characterDetailLoadingIndicatorCollectionView
            .register(CharacterInfoCollectionViewCell.self,
            forCellWithReuseIdentifier: CharacterInfoCollectionViewCell.reuseCellIdentifier)
        characterDetailLoadingIndicatorCollectionView
            .register(CharacterEpisodeCollectionViewCell.self,
            forCellWithReuseIdentifier: CharacterEpisodeCollectionViewCell.resueCellIdentifier)
        characterDetailLoadingIndicatorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return characterDetailLoadingIndicatorCollectionView
    }

    private func createCharacterDetailLoadingIndicatorSection(for sectionIndex: Int) -> NSCollectionLayoutSection {
        let characterDetailLoadingIndicatorSectionTypes = characterDetailViewModel.characterSections
        
        switch characterDetailLoadingIndicatorSectionTypes[sectionIndex]  {
        case .characterPhotoSection:
            return characterDetailViewModel.setupcCharacterDetailPhotoSection()
        case .characterInformationSection:
            return characterDetailViewModel.setupCharacterDetailInfoSection()
        case .characterEpisodeSection:
            return characterDetailViewModel.setupCharacterDetailEpisodeSection()
        }
    }
}
