import Foundation

final class APICacheManager {
    
    private var cacheDictionary: [APIEndpoint: NSCache<NSString, NSData>] = [:]

    init() {
        setUpCache()
    }
    
    func cachedResponse(for endpoint: APIEndpoint, url: URL?) -> Data? {
        guard let targetCache = cacheDictionary[endpoint], let url = url else {
            return nil
        }
        
        let key = url.absoluteString as NSString
        
        return targetCache.object(forKey: key) as Data?
    }
    
    func setCache(for endpoint: APIEndpoint, url: URL?, data: Data) {
        guard let targetCache = cacheDictionary[endpoint], let url = url else {
            return
        }
        
        let key = url.absoluteString as NSString
        
        targetCache.setObject(data as NSData, forKey: key)
    }
    
    private func setUpCache() {
        APIEndpoint.allCases.forEach { endpoint in
            cacheDictionary[endpoint] = NSCache<NSString, NSData>()
        }
    }
}
