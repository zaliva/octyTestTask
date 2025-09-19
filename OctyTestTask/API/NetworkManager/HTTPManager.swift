import Foundation
import SwiftyJSON
import Alamofire

typealias SuccessHandler = (JSON) -> Void
typealias FailureHandler = (ApiError) -> Void

class HTTPManager {

    //MARK: - GET
    class func get(url: UrlRequest, params: [String: Any]?, successHandler: SuccessHandler? = nil, failureHandler: FailureHandler? = nil) {
        
        var requestUrl = url.fullUrl
        
        if let params = params {
            requestUrl += convertDictParamsToStringUrl(params)
        }

        NetworkSessionManager.shared
            .sessionManager
            .request(requestUrl,
                     method: .get,
                     encoding: JSONEncoding.default,
                     headers: API.authorizedHeaders())
            .validate()
            .responseData { response in
                LoggerManager.log(response: response)
                switch response.result {
                case .success(let data):
                    handleSuccessResponse(url: requestUrl, data: data, successHandler: successHandler, failureHandler: failureHandler)
                case .failure(let error):
                    handleFailureResponse(response: response, responseError: error, failureHandler: failureHandler)
                }
            }
    }

    //MARK: - POST
    class func post(url: UrlRequest, params: [String: Any]?, successHandler: SuccessHandler? = nil, failureHandler: FailureHandler? = nil) {
        NetworkSessionManager.shared
            .sessionManager
            .request(url.fullUrl,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.default,
                     headers: API.authorizedHeaders())
            .validate()
            .responseData { response in
                LoggerManager.log(response: response)
                switch response.result {
                case .success(let data):
                    handleSuccessResponse(url: url.fullUrl, data: data, successHandler: successHandler, failureHandler: failureHandler)
                case .failure(let error):
                    handleFailureResponse(response: response, responseError: error, failureHandler: failureHandler)
                }
            }
    }
    
    //MARK: - Failure
    private class func handleFailureData(data: Data, failureHandler: FailureHandler?, defaultError: ApiError? = nil) {
        let defaultError: ApiError = defaultError != nil ? defaultError! : ApiError(propertyName: LocalizeStrings.networkError, displayMessage: LocalizeStrings.networkErrorMsg, errorCode: ErrorCode.unknownСodeFromServer)
        do {
            let resultModel = try JSONDecoder().decode(ErrorResponse.self, from: data)
            if let firstError = resultModel.errors.first {
                failureHandler?(firstError)
            } else {
                failureHandler?(defaultError)
            }
        } catch {
            failureHandler?(defaultError)
        }
    }

    private class func handleFailureResponse(response: AFDataResponse<Data>, responseError: AFError, failureHandler: FailureHandler?) {
        let defaultError = ApiError(propertyName: LocalizeStrings.networkError, displayMessage: responseError.localizedDescription, errorCode: responseError.responseCode ?? ErrorCode.unknownСodeFromServer)
        guard let data = response.data else {
            failureHandler?(defaultError)
            return
        }
        handleFailureData(data: data, failureHandler: failureHandler, defaultError: defaultError)
    }
    
    //MARK: - Success
    private class func handleSuccessResponse(url: String, data: Data, successHandler: SuccessHandler? = nil, failureHandler: FailureHandler? = nil) {
        do {
            let json = try JSON(data: data, options: [])
                successHandler?(json)
        } catch let error {
            failureHandler?(ApiError(propertyName: LocalizeStrings.networkError, displayMessage: error.localizedDescription, errorCode: ErrorCode.errorParsing))
        }
    }

    private class func convertDictParamsToStringUrl(_ params: [String: Any]) -> String {
        var stringUrl = String()
        for (key, value) in params {
            if stringUrl.contains("?") {
                stringUrl += "&\(key)=\(value)"
            } else {
                stringUrl += "?\(key)=\(value)"
            }
        }
        return stringUrl
    }
}
