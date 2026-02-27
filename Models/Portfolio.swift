import Foundation

struct Portfolio: Codable {
    let totalValue: Double
    let dayChange: Double
    let dayChangePercent: Double
    let holdings: [Holding]

    struct Holding: Codable, Identifiable {
        let symbol: String
        let shares: Double
        let avgCost: Double
        let currentPrice: Double

        var id: String { symbol }
        var marketValue: Double { shares * currentPrice }
        var gainLoss: Double { (currentPrice - avgCost) * shares }
    }
}
