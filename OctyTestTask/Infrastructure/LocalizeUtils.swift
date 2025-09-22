import Foundation
import UIKit

class LocalizeUtils: NSObject {

    enum LanguageValue: String {
        case english = "en"
    }
    
    static let defaultLocalizer = LocalizeUtils()
    var appbundle = Bundle.main
    
    func setSelectedLanguage(lang: LanguageValue) {
        guard let langPath = Bundle.main.path(forResource: lang.rawValue, ofType: "lproj") else { return }
        Persistance.languageCode = lang.rawValue
        appbundle = Bundle(path: langPath) ?? Bundle()
    }
    
    func stringForKey(_ key: String) -> String {
        return appbundle.localizedString(forKey: key, value: "", table: nil)
    }
}
