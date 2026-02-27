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
        let vol = volume24hr ?? volume ?? 0
        if vol >= 1_000_000 {
            return String(format: "$%.1fM", vol / 1_000_000)
        } else if vol >= 1_000 {
            return String(format: "$%.0fK", vol / 1_000)
        }
        return String(format: "$%.0f", vol)
    }
}
