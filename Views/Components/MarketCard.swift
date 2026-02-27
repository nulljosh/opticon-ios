import SwiftUI

struct MarketCard: View {
    let market: PredictionMarket

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(market.question)
                .font(.subheadline.weight(.medium))
                .lineLimit(3)

            HStack(spacing: 12) {
                Label(market.formattedVolume, systemImage: "chart.bar")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)

                if let liquidity = market.liquidity, liquidity > 0 {
                    Label(formatCurrency(liquidity), systemImage: "drop")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }

            if let url = market.polymarketURL {
                Link(destination: url) {
                    Text("View on Polymarket")
                        .font(.caption2)
                        .foregroundStyle(Color(hex: "0071e3"))
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", value / 1_000)
        }
        return String(format: "$%.0f", value)
    }
}
