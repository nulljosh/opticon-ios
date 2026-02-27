import SwiftUI
import Charts

struct StockDetailView: View {
    @Environment(AppState.self) private var appState
    let stock: Stock

    @State private var selectedRange = "1y"
    @State private var isLoading = true
    @State private var error: String?

    private let ranges = ["1d", "1w", "1mo", "3mo", "1y"]

    private var changeColor: Color {
        stock.change >= 0 ? Color(hex: "34c759") : Color(hex: "ff3b30")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Price header
                VStack(spacing: 4) {
                    Text(String(format: "$%.2f", stock.price))
                        .font(.system(size: 44, weight: .bold, design: .monospaced))
                    HStack(spacing: 6) {
                        Text(String(format: "%@%.2f", stock.change >= 0 ? "+" : "", stock.change))
                        Text(String(format: "(%.2f%%)", stock.changePercent))
                    }
                    .font(.callout.monospaced())
                    .foregroundStyle(changeColor)
                }
                .padding(.top, 8)

                // Chart
                if isLoading {
                    ProgressView()
                        .frame(height: 220)
                } else if let error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(height: 220)
                } else if !appState.priceHistory.isEmpty {
                    chartView
                }

                // Range picker
                Picker("Range", selection: $selectedRange) {
                    ForEach(ranges, id: \.self) { range in
                        Text(range.uppercased()).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Info section
                VStack(spacing: 12) {
                    if stock.volume > 0 {
                        infoRow("Volume", value: formatVolume(stock.volume))
                    }
                    if stock.high52 > 0 {
                        infoRow("52W High", value: String(format: "$%.2f", stock.high52))
                    }
                    if stock.low52 > 0 {
                        infoRow("52W Low", value: String(format: "$%.2f", stock.low52))
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationTitle(stock.symbol)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if appState.isLoggedIn {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            if appState.isInWatchlist(stock.symbol) {
                                await appState.removeWatchlistSymbol(stock.symbol)
                            } else {
                                await appState.addWatchlistSymbol(stock.symbol)
                            }
                        }
                    } label: {
                        Image(systemName: appState.isInWatchlist(stock.symbol) ? "star.fill" : "star")
                            .foregroundStyle(appState.isInWatchlist(stock.symbol) ? Color(hex: "f5a623") : .secondary)
                    }
                }
            }
        }
        .task(id: selectedRange) {
            await loadHistory()
        }
    }

    @ViewBuilder
    private var chartView: some View {
        let points = appState.priceHistory.compactMap { point -> (Date, Double)? in
            guard let date = point.parsedDate else { return nil }
            return (date, point.close)
        }
        let minPrice = points.map(\.1).min() ?? 0
        let maxPrice = points.map(\.1).max() ?? 0
        let padding = (maxPrice - minPrice) * 0.1

        Chart {
            ForEach(points, id: \.0) { date, close in
                LineMark(
                    x: .value("Date", date),
                    y: .value("Price", close)
                )
                .foregroundStyle(Color(hex: "0071e3"))

                AreaMark(
                    x: .value("Date", date),
                    y: .value("Price", close)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [Color(hex: "0071e3").opacity(0.3), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartYScale(domain: (minPrice - padding)...(maxPrice + padding))
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) {
                AxisValueLabel(format: .dateTime.month(.abbreviated))
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) {
                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 220)
        .padding(.horizontal)
    }

    private func loadHistory() async {
        isLoading = true
        error = nil
        await appState.fetchPriceHistory(symbol: stock.symbol, range: selectedRange)
        if let appError = appState.error {
            error = appError
            appState.error = nil
        }
        isLoading = false
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.monospaced())
        }
    }

    private func formatVolume(_ vol: Double) -> String {
        if vol >= 1_000_000_000 {
            return String(format: "%.1fB", vol / 1_000_000_000)
        } else if vol >= 1_000_000 {
            return String(format: "%.1fM", vol / 1_000_000)
        } else if vol >= 1_000 {
            return String(format: "%.0fK", vol / 1_000)
        }
        return String(format: "%.0f", vol)
    }
}
