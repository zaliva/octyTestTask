import Foundation
import Alamofire

class NetworkSessionManager {

    static let shared = NetworkSessionManager()
    var sessionManager: Session

    private init() {
        let configuration = URLSessionConfiguration.default
        var headers = HTTPHeaders.default
        headers["Content-Type"] = "application/json"
        configuration.headers = headers
        configuration.timeoutIntervalForRequest = 60.0
        self.sessionManager = Session(configuration: configuration, interceptor: JWTAccessTokenInterceptor())
    }
}

class API {
    static func authorizedHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "content-type": "application/json"
        ]
        return headers
    }
}

struct ErrorResponse: Codable {
    let success: Bool
    let errors: [ApiError]
}

struct ApiError: Codable {
    let propertyName: String
    let displayMessage: String
    let errorCode: Int
    
    init(propertyName: String, displayMessage: String, errorCode: Int) {
        self.propertyName = propertyName
        self.displayMessage = displayMessage
        self.errorCode = errorCode
    }
}

enum ErrorCode {
    static let unauthorized = 401
    
    static let errorParsing = 5001
    static let errorEncoding = 5002
    static let errorDecode = 5003
    static let errorGuard = 5004
    static let errorDecrypt = 5005
    static let errorParsingWebSocket = 5006
    static let errorDecodeWebSocket = 5007
    static let errorUpload = 5008
    static let unknownСodeFromServer = 5009
}
