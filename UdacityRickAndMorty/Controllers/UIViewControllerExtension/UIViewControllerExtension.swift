import Foundation
import UIKit

extension UIViewController {
    func showNoInternetAlert() {
        let alert = UIAlertController(title: "No Internet Connection",
                                      message: "Please check your internet connection and try again.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
