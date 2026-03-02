import Foundation

struct PredictionMarket: Codable, Identifiable {
    let id: String
    let slug: String?
    let question: String
    let description: String?
    let volume24hr: Double?
    let volume: Double?
    let liquidity: Double?
    let events: [MarketEvent]?
    let eventSlug: String?

    struct MarketEvent: Codable {
        let slug: String?
    }

    var polymarketURL: URL? {
        guard let slug = eventSlug ?? events?.first?.slug else { return nil }
        return URL(string: "https://polymarket.com/event/\(slug)")
    }

    var formattedVolume: String {
        Self.formatCurrency(volume24hr ?? volume ?? 0)
    }

    var formattedLiquidity: String? {
        guard let liquidity, liquidity > 0 else { return nil }
        return Self.formatCurrency(liquidity)
    }

    static func formatCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", value / 1_000)
        }
        return String(format: "$%.0f", value)
    }
}
