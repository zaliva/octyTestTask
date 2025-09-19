import Foundation

enum UrlRequest: String {

    case getList = "/"
    
    var fullUrl: String { "\(baseUrl)\(rawValue)" }
}
