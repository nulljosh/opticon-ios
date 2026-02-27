import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MarketsView()
                .tabItem {
                    Label("Markets", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)

            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "briefcase")
                }
                .tag(1)

            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.badge")
                }
                .tag(2)
        }
        .tint(Color(hex: "0071e3"))
    }
}

struct MarketsView: View {
    let tickers = ["AAPL", "MSFT", "GOOGL", "AMZN", "NVDA"]

    var body: some View {
        NavigationStack {
            List(tickers, id: \.self) { ticker in
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticker)
                            .font(.headline.monospaced())
                        Text("--")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("$0.00")
                            .font(.body.monospaced())
                        Text("+0.00%")
                            .font(.caption.monospaced())
                            .foregroundStyle(.green)
                    }
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .padding(2)
                )
            }
            .navigationTitle("Markets")
        }
    }
}

struct PortfolioView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$0.00")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                    Text("+0.00% today")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                .padding(.top, 40)

                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(height: 200)
                    .overlay(
                        Text("Chart")
                            .foregroundStyle(.secondary)
                    )
                    .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Portfolio")
        }
    }
}

struct AlertsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Active") {
                    Text("No active alerts")
                        .foregroundStyle(.secondary)
                }
                Section {
                    Button("Create Alert") {}
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
            }
            .navigationTitle("Alerts")
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

#Preview {
    ContentView()
}
