import Foundation

struct Stock: Codable, Identifiable {
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double

    var id: String { symbol }

    enum CodingKeys: String, CodingKey {
        case symbol, name, price, change
        case changePercent = "changesPercentage"
    }
}
