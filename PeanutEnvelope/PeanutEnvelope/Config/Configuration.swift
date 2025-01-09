import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

enum API {
    static var baseURL: String {
        #if DEBUG
        return "http://localhost:3000"
        #else
        return "https://your-production-url.com"
        #endif
    }
    
    static var web3AuthClientId: String {
        return try! Configuration.value(for: "WEB3_AUTH_CLIENT_ID")
    }
    
    static var web3RedirectURL: String {
        return try! Configuration.value(for: "APP_REDIRECT_URL")
    }
    
    static var infuraKey: String {
        return try! Configuration.value(for: "INFURA_KEY")
    }

}
