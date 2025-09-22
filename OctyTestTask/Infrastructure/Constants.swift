import UIKit

private let USE_TEST_SERVER = true

var baseUrl: String { "https://\(baseHostString)" }
private var baseHostString: String { USE_TEST_SERVER ? testHostName : hostName }

let SWOPApiKey = ""
let encryptApiKey = "32lLC0G2N4H2iGwDWCCFyysBIwNcLlCIF4BTbkQ7npvD/Ns+T6kmFU1+iWTvVmzIucgG3ImAI3ZaR3YQJiQEXe+zP/KELIKSrC9gy2h4X4A="
let testHostName = "swop.cx"
private var hostName = ""

var ScreenWidth: CGFloat { UIScreen.main.bounds.size.width }
var ScreenHeight: CGFloat { UIScreen.main.bounds.size.height }
