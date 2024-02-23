import Foundation
import RealmSwift

protocol RealmManager {
    var sharedRealm: Realm? { get }
    func addToRealm(object: EpisodeData)
    func removeFromRealm(object: EpisodeData)
    func fetchDataFromRealm(object: EpisodeData.Type) -> [EpisodeData]
    func objectExistsInRealm(object: EpisodeData) -> Bool
}

class ConcreteRealmManager: RealmManager {
    var sharedRealm: RealmSwift.Realm?
    
    init() {
        setupRealm()
    }
    
    func setupRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 1)
            
            Realm.Configuration.defaultConfiguration = config
            
            sharedRealm = try Realm()
        } catch {
            debugPrint("Error opening realm: \(error)")
        }
    }
    
    func addToRealm(object: EpisodeData) {
        do {
            try sharedRealm?.write {
                sharedRealm?.add(object)
            }
        } catch {
            debugPrint("Error adding to realm: \(error)")
        }
    }
    
    func removeFromRealm(object: EpisodeData) {
        do {
            try sharedRealm?.write {
                sharedRealm?.delete(object)
            }
        } catch {
            debugPrint("Error removing from realm: \(error)")
        }
    }
    
    func fetchDataFromRealm(object: EpisodeData.Type) -> [EpisodeData] {
        var fetchedEpisodeData = [EpisodeData]()
        if let sharedRealm = sharedRealm {
            let fetchedData = sharedRealm.objects(object)
            fetchedData.forEach { returedEpisode in
                fetchedEpisodeData.append(returedEpisode)
            }
        }
        return fetchedEpisodeData
    }

    func objectExistsInRealm(object: EpisodeData) -> Bool {
        if let realm = sharedRealm {
            return realm.objects(EpisodeData.self).filter("id == %@", object.id).count > 0
        } else {
            return false
        }
    }
}
