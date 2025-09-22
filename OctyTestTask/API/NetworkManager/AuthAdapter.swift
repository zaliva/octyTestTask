import Alamofire
import Foundation

final class JWTAccessTokenInterceptor: RequestInterceptor {
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == ErrorCode.unauthorized else {
            if let response = request.task?.response as? HTTPURLResponse {
                debugPrint("response.statusCode", response.statusCode)
            }
            completion(.doNotRetry)
            return
        }

//        Coordinator.logout()
        completion(.doNotRetry)
    }
}
