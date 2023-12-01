import UIKit

extension UIView {
    func addCharacterDetailLoadingIndicatorSubviews(_ uiView: UIView...) {
        uiView.forEach({
            addSubview($0)
        })
    }
}

extension UIDevice {
    static let checkIfItIsPhoneDevice = UIDevice.current.userInterfaceIdiom == .phone
}

extension APIRequest {
    static let listCharactersRequests = APIRequest(endpoint: .character)
    static let listEpisodesRequest = APIRequest(endpoint: .episode)
    static let listLocationsRequest = APIRequest(endpoint: .location)
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

