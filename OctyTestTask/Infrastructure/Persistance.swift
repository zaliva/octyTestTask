import UIKit

let Persistance = PersistanceEntity.shared

class PersistanceEntity {
    
    static let shared = PersistanceEntity()
    private let defaults = UserDefaults.standard
    
    //MARK: Keys
    
    //General
    private let kIsLogin = "Persistance.kIsLogin"
    private let KLanguageCode = "Persistance.KLanguageCode"
    
    //MARK: Values
    
    var isLogin: Bool {
        get { defaults.bool(forKey: kIsLogin) }
        set { setValue(newValue, withKey: kIsLogin) }
    }

    var languageCode: String? {
        get { defaults.string(forKey: KLanguageCode) }
        set { setValue(newValue, withKey: KLanguageCode) }
    }
}

extension PersistanceEntity {
    private func setValue<T>(_ value: T, withKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    func clearAllUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    func removeForKey(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
