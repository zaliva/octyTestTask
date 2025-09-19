import UIKit

extension String {
    var localize: String {
        get {
            return LocalizeUtils.defaultLocalizer.stringForKey(self)
        }
    }
}
