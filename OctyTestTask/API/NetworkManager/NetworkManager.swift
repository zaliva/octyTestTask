import Foundation
import SwiftyJSON

class NetworkManager {
    
    typealias SuccessModel<M: Codable> = (M) -> Void
    
    class private func handleModel<M: Codable>(json: JSON, success: SuccessModel<M>? = nil, failure: FailureHandler? = nil) {
        guard let data = try? json.rawData() else {
            failure?(ApiError(propertyName: LocalizeStrings.networkError, message: LocalizeStrings.networkErrorMsg, errorCode: ErrorCode.errorParsing))
            return
        }
        
        do {
            let resultModel = try JSONDecoder().decode(M.self, from: data)
            success?(resultModel)
        } catch let error {
            debugPrint("\(error)")
            failure?(ApiError(propertyName: LocalizeStrings.networkError, message: error.localizedDescription, errorCode: ErrorCode.errorDecode))
        }
    }
    
    class private func handleArrayOfModels<M: Codable>(json: JSON, success: SuccessModel<[M]>? = nil, failure: FailureHandler? = nil) {
        guard let data = try? json.rawData() else {
            failure?(ApiError(propertyName: LocalizeStrings.networkError, message: LocalizeStrings.networkErrorMsg, errorCode: ErrorCode.errorParsing))
            return
        }
        do {
            let resultModel = try JSONDecoder().decode([M].self, from: data)
            success?(resultModel)
        } catch {
            debugPrint("\(error)")
            failure?(ApiError(propertyName: LocalizeStrings.networkError, message: error.localizedDescription, errorCode: ErrorCode.errorDecode))
        }
    }

    //MARK: -
    class func getRates(success: (([ResponceRatesModel]) -> Void)? = nil, failure: FailureHandler? = nil) {
        HTTPManager.get(url: .rates, params: nil) { result in
            handleArrayOfModels(json: result, success: success, failure: failure)
        } failureHandler: { error in
            failure?(error)
        }
    }
}

