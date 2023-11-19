import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach({
            addSubview($0)
        })
    }
}

extension UIDevice {
    static let isiPhone = UIDevice.current.userInterfaceIdiom == .phone
}

extension Request {
    static let listCharactersRequests = Request(endpoint: .character)
    static let listEpisodesRequest = Request(endpoint: .episode)
    static let listLocationsRequest = Request(endpoint: .location)
}
