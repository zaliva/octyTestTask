import Alamofire
import UIKit

let LoggerManager = LoggerManagerEntity.shared

class LoggerManagerEntity {

    static let shared = LoggerManagerEntity()
    private var splitMark: Character = "±"

    private init() {
        guard enableLogger else { return }
        let log = "\(splitMark)\n-------------- New session \(currentTimeString) ----------------------"
        writeLogToFile(logString: log)
    }

    func log(debugLog: String) {
        guard enableLogger else { return }
        var log = String(splitMark)
        log += "\(LoggerType.debugLog.rawValue)\n"
        log += "LOG: \(debugLog)\n"
        log += "TIME: \(currentTimeString)\n"
        writeLogToFile(logString: log)
    }

    func log(webSocketText: String) {
        guard enableLogger else { return }
        var log = String(splitMark)
        log += "\(LoggerType.websocket.rawValue)\n"
        log += "RESPONSE: \(webSocketText)\n"
        log += "TIME: \(currentTimeString)\n"
        writeLogToFile(logString: log)
    }

    func log(response: AFDataResponse<Data>) {
        guard enableLogger, let url = response.request?.url?.absoluteString else { return }

        var log = String(splitMark)
        let statusCode = response.response?.statusCode ?? 0
        switch statusCode {
        case 200:
            log += "\(LoggerType.rSuccess.rawValue)\n"
        case 201...307:
            log += "\(LoggerType.rWarning.rawValue)\n"
        default :
            log += "\(LoggerType.rError.rawValue)\n"
        }
        if Int(response.metrics?.taskInterval.duration ?? 0) > 1 { log += "⏰" }
        log += "URL: \(url)\n"
        if let metrics = response.metrics {
            log += "SENT_TIME: \(convertDateToString(date: metrics.taskInterval.start))\n"
            log += "DURATION_TIME: \(String(metrics.taskInterval.duration))\n"
        }
        log += "METHOD: \(response.request?.httpMethod ?? "")\n"
        log += "HEADERS: \(response.request?.allHTTPHeaderFields ?? [:])\n"
        let parameters = String(data: response.request?.httpBody ?? Data(), encoding: .utf8) ?? ""
        log += "PARAMS: \(parameters)\n"
        log += "STATUS CODE: \(statusCode)\n"
        log += "RESPONSE: \(getAndDecryptResponse(response))\n"
        writeLogToFile(logString: log)
    }

    func getAndDecryptResponse(_ response: AFDataResponse<Data>) -> String {
        let responseData = response.data ?? Data()
        return String(data: responseData, encoding: .utf8) ?? ""
    }

    func getLogs() -> [LogModel] {
        var logsArray = [LogModel]()
        guard enableLogger, let filePath = filePath else { return logsArray }
        do {
            let text = try String(contentsOfFile: filePath, encoding: .utf8)
            text.split(separator: splitMark).forEach {
                let log = String($0)
                let logAttributed = NSMutableAttributedString(string: log)
                logAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .regular), range: NSRange(location: 0, length: $0.count))

                if log.contains(LoggerType.rSuccess.rawValue) {
                    logsArray.append(LogModel(attributedText: logAttributed, logType: .rSuccess))
                } else if log.contains(LoggerType.rWarning.rawValue) {
                    logAttributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.yellow, range: NSRange(location: 0, length: $0.count))
                    logsArray.append(LogModel(attributedText: logAttributed, logType: .rWarning))
                } else if log.contains(LoggerType.rError.rawValue) {
                    logAttributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: $0.count))
                    logsArray.append(LogModel(attributedText: logAttributed, logType: .rError))
                } else if log.contains(LoggerType.websocket.rawValue) {
                    logsArray.append(LogModel(attributedText: logAttributed, logType: .websocket))
                } else if log.contains(LoggerType.debugLog.rawValue) {
                    logsArray.append(LogModel(attributedText: logAttributed, logType: .debugLog))
                } else {
                    logAttributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: NSRange(location: 0, length: $0.count))
                    logsArray.append(LogModel(attributedText: logAttributed, logType: .allType))
                }
            }
        } catch {
            debugPrint("Error get Logs: \(error)")
        }
        return logsArray
    }

    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss.SSS"
        return formatter.string(from: date)
    }

    // MARK: - Save and Remove
    func removeLogsFile() {
        guard enableLogger, let filePath = filePath else { return }
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch {
            debugPrint("Error remove Logs: \(error)")
        }
    }

    private func writeLogToFile(logString: String) {
#if DEBUG
        print(logString)
#endif
        guard enableLogger, let filePath = filePath, let data = logString.data(using: .utf8) else { return }

        var fileHandle = FileHandle(forWritingAtPath: filePath)
        if fileHandle == nil {
            FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
            fileHandle = FileHandle(forWritingAtPath: filePath)
        } else {
            fileHandle?.seekToEndOfFile()
        }
        fileHandle?.write(data)
        fileHandle?.closeFile()
    }

    // MARK: - Getters

    private var filePath: String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).sorted().first else { return nil }
        return path.appending("/fileLog.txt")
    }

    private var currentTimeString: String {
        return convertDateToString(date: Date())
    }

    var enableLogger: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
}
