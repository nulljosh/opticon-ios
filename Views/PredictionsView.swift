import SwiftUI

struct PredictionsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Group {
                if appState.markets.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(appState.markets) { market in
                        MarketCard(market: market)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .padding(2)
                            )
                    }
                }
            }
            .navigationTitle("Predictions")
        }
        .task {
            await appState.loadMarkets()
        }
    }
}
