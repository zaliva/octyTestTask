import Foundation
import Alamofire

class NetworkSessionManager {

    static let shared = NetworkSessionManager()
    var sessionManager: Session

    private init() {
        let configuration = URLSessionConfiguration.default
        let headers = HTTPHeaders.default
        configuration.headers = headers
        configuration.timeoutIntervalForRequest = 60.0
        self.sessionManager = Session(configuration: configuration, interceptor: JWTAccessTokenInterceptor())
    }
}

class API {
    static func authorizedHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = ["content-type": "application/json"]
        
        if !SWOPApiKey.isEmpty {
            headers["Authorization"] = "ApiKey \(SWOPApiKey)"
        } else if let encryptApiKeyData = Data(base64Encoded: encryptApiKey), let dataDecrypt = EncryptionTools.tiger2_aesDecrypt(encryptApiKeyData), let decryptApiKeyStr = String(data: dataDecrypt, encoding: .utf8) {
            headers["Authorization"] = "ApiKey \(decryptApiKeyStr)"
        }
        
        return headers
    }
}

struct ErrorResponse: Codable {
    let error: ApiError
}

struct ApiError: Codable {
    let propertyName: String
    let message: String
    let errorCode: Int?
    
    init(propertyName: String, message: String, errorCode: Int) {
        self.propertyName = propertyName
        self.message = message
        self.errorCode = errorCode
    }
    
    enum CodingKeys: String, CodingKey {
        case message, propertyName = "type", errorCode
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
