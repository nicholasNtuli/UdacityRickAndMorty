import UIKit

final class CharacterDetailViewModel {
    
    private let characterDetail: Character
    public var characterSections: [CharacterSections] = []
    
    public var characterDetailEpisodes: [String] {
        characterDetail.episode
    }
    
    enum CharacterSections {
        case characterPhotoSection(viewModel: CharacterPhotoSectionViewModel)
        case characterInformationSection(viewModels: [CharacterInformationSectionViewModel])
        case characterEpisodeSection(viewModels: [CharacterEpisodeSectionViewModel])
    }

    init(characterDetail: Character) {
        self.characterDetail = characterDetail
        characterDetailSectionUISetup()
    }
    private func characterDetailSectionUISetup() {
        characterSections = [
            .characterPhotoSection(viewModel: .init(characterPhotoURL: URL(string: characterDetail.image))),
            .characterInformationSection(viewModels: [
                .init(charcterInformationType: .status , charcterInformationValue: characterDetail.status.status),
                .init(charcterInformationType: .gender , charcterInformationValue: characterDetail.gender.rawValue),
                .init(charcterInformationType: .type , charcterInformationValue: characterDetail.type),
                .init(charcterInformationType: .species , charcterInformationValue: characterDetail.species),
                .init(charcterInformationType: .origin , charcterInformationValue: characterDetail.origin.name),
                .init(charcterInformationType: .location , charcterInformationValue: characterDetail.location.name),
                .init(charcterInformationType: .created , charcterInformationValue: characterDetail.created),
                .init(charcterInformationType: .episodeCount , charcterInformationValue: "\(characterDetail.episode.count)"),
            ]),
            .characterEpisodeSection(viewModels: characterDetail.episode.compactMap ({
                return CharacterEpisodeSectionViewModel(characterEpisodeBaseURL: URL(string: $0))
            }))
        ]
    }
    
    private var characterDetailURL: URL? {
        return URL(string: characterDetail.url)
    }
    
    public var characterDetailName: String {
        characterDetail.name.uppercased()
    }
    
    public func setupcCharacterDetailPhotoSection() -> NSCollectionLayoutSection {
        let photoItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        photoItem.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 10,
                                                     trailing: 0)
        
        let photoGroup = NSCollectionLayoutGroup.vertical(
            layoutSize:  NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.5)
            ),
            subitems: [photoItem]
        )
        
        let photoSection = NSCollectionLayoutSection(group: photoGroup)
        
        return photoSection
    }
    
    public func setupCharacterDetailInfoSection() -> NSCollectionLayoutSection {
        let infoItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(UIDevice.checkIfItIsPhoneDevice ? 0.5 : 0.25),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        infoItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2
        )
        
        let infoGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize:  NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(150)
            ),
            subitems: UIDevice.checkIfItIsPhoneDevice ? [infoItem, infoItem] : [infoItem, infoItem, infoItem, infoItem]
        )
        
        let infoSection = NSCollectionLayoutSection(group: infoGroup)
        
        return infoSection
    }
    
    public func setupCharacterDetailEpisodeSection() -> NSCollectionLayoutSection {
        let episodeItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        episodeItem.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 5,
            bottom: 10,
            trailing: 8
        )
        
        let episodeGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize:  NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(UIDevice.checkIfItIsPhoneDevice ? 0.8 : 0.4),
                heightDimension: .absolute(150)
            ),
            subitems: [episodeItem]
        )
        
        let episodeSection = NSCollectionLayoutSection(group: episodeGroup)
        episodeSection.orthogonalScrollingBehavior = .groupPaging
        
        return episodeSection
    }
}
