import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarViewSetup()
    }

    private struct TabBarViewInfo {
        let tabBarTitle: String
        let tabBarImage: UIImage?
        let tabBarViewController: UIViewController
    }

    private func tabBarViewSetup() {
        let tabBarCharactersViewController = CharacterViewController()
        let tabBarLocationsViewController = LocationViewController()
        let tabBarEpisodesViewController = EpisodeViewController()

        let tabBarViewInfo: [TabBarViewInfo] = [
            TabBarViewInfo(tabBarTitle: "Characters", tabBarImage: UIImage(systemName: "person"), tabBarViewController: tabBarCharactersViewController),
            TabBarViewInfo(tabBarTitle: "Locations", tabBarImage: UIImage(systemName: "globe"), tabBarViewController: tabBarLocationsViewController),
            TabBarViewInfo(tabBarTitle: "Episodes", tabBarImage: UIImage(systemName: "tv"), tabBarViewController: tabBarEpisodesViewController)
        ]

        tabBarViewInfo.forEach { tabBarInfo in
            setUpTab(with: tabBarInfo)
        }
    }

    private func setUpTab(with tabBarViewInfo: TabBarViewInfo) {
        let tabBarNavigationController = UINavigationController(rootViewController: tabBarViewInfo.tabBarViewController)
        tabBarNavigationController.tabBarItem = UITabBarItem(title: tabBarViewInfo.tabBarTitle, image: tabBarViewInfo.tabBarImage, tag: viewControllers?.count ?? 0 + 1)
        tabBarNavigationController.navigationBar.prefersLargeTitles = true
        setViewControllers((viewControllers ?? []) + [tabBarNavigationController], animated: true)
    }
}
