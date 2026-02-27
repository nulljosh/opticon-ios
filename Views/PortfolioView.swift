import SwiftUI

struct PortfolioView: View {
    @Environment(AppState.self) private var appState

    private var changeColor: Color {
        guard let p = appState.portfolio else { return .secondary }
        return p.dayChange >= 0 ? Color(hex: "34c759") : Color(hex: "ff3b30")
    }

    var body: some View {
        NavigationStack {
            Group {
                if !appState.isLoggedIn {
                    signInPrompt
                } else if let portfolio = appState.portfolio {
                    portfolioContent(portfolio)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Portfolio")
        }
        .task {
            await appState.loadPortfolio()
        }
    }

    private var signInPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "briefcase")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Sign in to view your portfolio")
                .foregroundStyle(.secondary)
            Button("Sign In") {
                appState.showLogin = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "0071e3"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func portfolioContent(_ portfolio: Portfolio) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary header
                VStack(spacing: 8) {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "$%.2f", portfolio.totalValue))
                        .font(.system(size: 44, weight: .bold, design: .monospaced))
                    HStack(spacing: 4) {
                        Text(String(format: "%@$%.2f", portfolio.dayChange >= 0 ? "+" : "", portfolio.dayChange))
                        Text(String(format: "(%.2f%%)", portfolio.dayChangePercent))
                    }
                    .font(.caption.monospaced())
                    .foregroundStyle(changeColor)
                }
                .padding(.top, 24)

                // Holdings
                if !portfolio.holdings.isEmpty {
                    sectionCard("Holdings") {
                        ForEach(portfolio.holdings) { holding in
                            HoldingRow(holding: holding)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                            if holding.id != portfolio.holdings.last?.id {
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                }

                Spacer()
            }
        }
    }

    private func sectionCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)
            content()
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
