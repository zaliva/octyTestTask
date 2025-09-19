import UIKit

private let USE_TEST_SERVER = true

var baseUrl: String { "https://\(baseHostString)" }
private var baseHostString: String { USE_TEST_SERVER ? testHostName : hostName }

let testHostName = ""
private var hostName = ""

var ScreenWidth: CGFloat { UIScreen.main.bounds.size.width }
var ScreenHeight: CGFloat { UIScreen.main.bounds.size.height }
