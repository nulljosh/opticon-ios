import SwiftUI

@Observable
final class AppState {
    var user: User?
    var isLoggedIn: Bool { user != nil }
    var showLogin = false
    var stocks: [Stock] = []
    var portfolio: Portfolio?
    var watchlist: [WatchlistItem] = []
    var alerts: [PriceAlert] = []
    var markets: [PredictionMarket] = []
    var isLoading = false
    var error: String?

    var watchlistSymbols: Set<String> {
        Set(watchlist.map(\.symbol))
    }

    var watchlistStocks: [Stock] {
        stocks.filter { watchlistSymbols.contains($0.symbol) }
    }

    var nonWatchlistStocks: [Stock] {
        stocks.filter { !watchlistSymbols.contains($0.symbol) }
    }

    var priceHistory: [PriceHistory.DataPoint] = []

    var activeAlerts: [PriceAlert] {
        alerts.filter { !$0.triggered }
    }

    var triggeredAlerts: [PriceAlert] {
        alerts.filter(\.triggered)
    }

    // MARK: - Auth

    func checkSession() async {
        do {
            user = try await OpticonAPI.shared.me()
        } catch {
            user = nil
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            user = try await OpticonAPI.shared.login(email: email, password: password)
            showLogin = false
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func register(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            user = try await OpticonAPI.shared.register(email: email, password: password)
            showLogin = false
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func logout() async {
        try? await OpticonAPI.shared.logout()
        user = nil
        portfolio = nil
        watchlist = []
        alerts = []
    }

    // MARK: - Stocks

    func loadStocks() async {
        do {
            stocks = try await OpticonAPI.shared.fetchStocks()
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Portfolio

    func loadPortfolio() async {
        guard isLoggedIn else { return }
        do {
            portfolio = try await OpticonAPI.shared.fetchPortfolio()
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Watchlist

    func loadWatchlist() async {
        guard isLoggedIn else { return }
        do {
            watchlist = try await OpticonAPI.shared.fetchWatchlist()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func addWatchlistSymbol(_ symbol: String) async {
        guard isLoggedIn else { return }
        do {
            let item = try await OpticonAPI.shared.addToWatchlist(symbol: symbol)
            watchlist.append(item)
        } catch let apiError as APIError {
            if case .httpError(409, _) = apiError {
                return // already in watchlist
            }
            self.error = apiError.localizedDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func removeWatchlistSymbol(_ symbol: String) async {
        guard isLoggedIn else { return }
        do {
            try await OpticonAPI.shared.removeFromWatchlist(symbol: symbol)
            watchlist.removeAll { $0.symbol == symbol }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func isInWatchlist(_ symbol: String) -> Bool {
        watchlistSymbols.contains(symbol)
    }

    // MARK: - Alerts

    func loadAlerts() async {
        guard isLoggedIn else { return }
        do {
            alerts = try await OpticonAPI.shared.fetchAlerts()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func createAlert(symbol: String, targetPrice: Double, direction: PriceAlert.Direction) async {
        guard isLoggedIn else { return }
        do {
            let alert = try await OpticonAPI.shared.createAlert(
                symbol: symbol,
                targetPrice: targetPrice,
                direction: direction
            )
            alerts.append(alert)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteAlert(_ id: String) async {
        guard isLoggedIn else { return }
        do {
            try await OpticonAPI.shared.deleteAlert(id: id)
            alerts.removeAll { $0.id == id }
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Price History

    func fetchPriceHistory(symbol: String, range: String) async {
        do {
            let result = try await OpticonAPI.shared.fetchPriceHistory(symbol: symbol, range: range)
            priceHistory = result.history
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Prediction Markets

    func loadMarkets() async {
        do {
            markets = try await OpticonAPI.shared.fetchMarkets()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
