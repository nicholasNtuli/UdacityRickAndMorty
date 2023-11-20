import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
    }

    private struct TabInfo {
        let title: String
        let image: UIImage?
        let viewController: UIViewController
    }

    private func setUpTabs() {
        let charactersVC = CharacterViewController()
        let locationsVC = LocationViewController()
        let episodesVC = EpisodeViewController()

        let tabs: [TabInfo] = [
            TabInfo(title: "Characters", image: UIImage(systemName: "person"), viewController: charactersVC),
            TabInfo(title: "Locations", image: UIImage(systemName: "globe"), viewController: locationsVC),
            TabInfo(title: "Episodes", image: UIImage(systemName: "tv"), viewController: episodesVC)
        ]

        tabs.forEach { tabInfo in
            setUpTab(with: tabInfo)
        }
    }

    private func setUpTab(with tabInfo: TabInfo) {
        let navController = UINavigationController(rootViewController: tabInfo.viewController)
        navController.tabBarItem = UITabBarItem(title: tabInfo.title, image: tabInfo.image, tag: viewControllers?.count ?? 0 + 1)
        navController.navigationBar.prefersLargeTitles = true
        setViewControllers((viewControllers ?? []) + [navController], animated: true)
    }
}
