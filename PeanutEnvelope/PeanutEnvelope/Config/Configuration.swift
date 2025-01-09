import Foundation

enum Configuration {
    private static let configDict: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("Failed to load Config.plist")
            return [:]
        }
        return dict
    }()
    
static var baseURL: String {
        return "http://localhost:3000"
    }

    static var web3AuthClientId: String {
        return configDict["WEB3_AUTH_CLIENT_ID"] as? String ?? ""
    }
    
    static var infuraKey: String {
        return configDict["INFURA_KEY"] as? String ?? ""
    }
    
    static var appRedirectUrl: String {
        return configDict["APP_REDIRECT_URL"] as? String ?? ""
    }
}

