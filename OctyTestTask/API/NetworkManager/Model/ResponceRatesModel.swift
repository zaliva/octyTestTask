import Foundation

struct ResponceRatesModel: Codable {
    let baseCurrency: String
    var quoteCurrency: String
    var quote: Double
    var date: String
    
    enum CodingKeys: String, CodingKey {
        case baseCurrency = "base_currency", quoteCurrency = "quote_currency", quote, date
    }
}
