import XCTest
@testable import OctyTestTask

final class ResponceRatesModelTests: XCTestCase {

    func test_decodingSingleModel_fromJSON() throws {
        let json = """
        {"base_currency":"BTC","quote_currency":"USD","quote":65000.5,"date":"2024-05-10"}
        """.data(using: .utf8)!

        let model = try JSONDecoder().decode(ResponceRatesModel.self, from: json)
        XCTAssertEqual(model.baseCurrency, "BTC")
        XCTAssertEqual(model.quoteCurrency, "USD")
        XCTAssertEqual(model.quote, 65000.5, accuracy: 0.0001)
        XCTAssertEqual(model.date, "2024-05-10")
    }

    func test_decodingArrayOfModels_fromJSON() throws {
        let json = """
        [
          {"base_currency":"ETH","quote_currency":"USD","quote":3000.0,"date":"2024-05-11"},
          {"base_currency":"SOL","quote_currency":"USD","quote":150.25,"date":"2024-05-11"}
        ]
        """.data(using: .utf8)!

        let models = try JSONDecoder().decode([ResponceRatesModel].self, from: json)
        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models[0].baseCurrency, "ETH")
        XCTAssertEqual(models[1].baseCurrency, "SOL")
    }
}


