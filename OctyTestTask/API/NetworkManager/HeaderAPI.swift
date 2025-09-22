import Foundation

enum UrlRequest: String {

    case rates = "/rest/rates"
    
    var fullUrl: String { "\(baseUrl)\(rawValue)" }
}
