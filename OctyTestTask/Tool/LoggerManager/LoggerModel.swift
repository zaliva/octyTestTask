import Foundation

struct LogModel {
    var attributedText = NSMutableAttributedString()
    var isShowFull = false
    var logType: LoggerType
}

enum LoggerType: String {
    case rSuccess = "Request Success"
    case rWarning = "Request Warning"
    case rError = "Request Error"
    case websocket = "Websocket"
    case debugLog = "Debug Log"
    case allTypeWithoutDebug = "All Type Without Debug"
    case allType = "All Type"
}

let ArrayLoggerType: [LoggerType] = [.rSuccess, .rWarning, .rError, .websocket, .debugLog, .allTypeWithoutDebug, .allType]
