import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let tableBarViewController = TabBarController()
        let uiWindow = UIWindow(windowScene: windowScene)
        
        uiWindow.rootViewController = tableBarViewController
        uiWindow.makeKeyAndVisible()
        
        self.window = uiWindow
    }
}
