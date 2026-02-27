import SwiftUI

struct MarketsView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""

    private var filteredStocks: [Stock] {
        let allStocks = searchText.isEmpty ? appState.stocks : appState.stocks.filter {
            $0.symbol.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        return allStocks
    }

    var body: some View {
        NavigationStack {
            Group {
                if appState.stocks.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        if !appState.watchlistStocks.isEmpty && searchText.isEmpty {
                            Section("Watchlist") {
                                ForEach(appState.watchlistStocks) { stock in
                                    NavigationLink(value: stock) {
                                        StockRow(
                                            stock: stock,
                                            isWatchlisted: true,
                                            onToggleWatchlist: {
                                                Task { await appState.removeWatchlistSymbol(stock.symbol) }
                                            }
                                        )
                                    }
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.ultraThinMaterial)
                                            .padding(2)
                                    )
                                }
                            }
                        }

                        Section(appState.watchlistStocks.isEmpty || !searchText.isEmpty ? "All Stocks" : "Other") {
                            let stocks = searchText.isEmpty ? appState.nonWatchlistStocks : filteredStocks
                            ForEach(stocks) { stock in
                                NavigationLink(value: stock) {
                                    StockRow(
                                        stock: stock,
                                        isWatchlisted: appState.isInWatchlist(stock.symbol),
                                        onToggleWatchlist: appState.isLoggedIn ? {
                                            Task {
                                                if appState.isInWatchlist(stock.symbol) {
                                                    await appState.removeWatchlistSymbol(stock.symbol)
                                                } else {
                                                    await appState.addWatchlistSymbol(stock.symbol)
                                                }
                                            }
                                        } : nil
                                    )
                                }
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                        .padding(2)
                                )
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search stocks")
                }
            }
            .navigationTitle("Markets")
            .navigationDestination(for: Stock.self) { stock in
                StockDetailView(stock: stock)
                    .environment(appState)
            }
        }
        .task {
            await appState.loadStocks()
            await appState.loadWatchlist()
        }
    }
}
