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

extension APIRequest {
    static let listCharactersRequests = APIRequest(endpoint: .character)
    static let listEpisodesRequest = APIRequest(endpoint: .episode)
    static let listLocationsRequest = APIRequest(endpoint: .location)
}
