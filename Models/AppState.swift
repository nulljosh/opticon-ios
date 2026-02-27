import SwiftUI

@Observable
final class AppState {
    var user: User?
    var isLoggedIn: Bool { user != nil }
    var showLogin = false
    var stocks: [Stock] = []
    var portfolio: Portfolio?
    var isLoading = false
    var error: String?

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

    func logout() async {
        try? await OpticonAPI.shared.logout()
        user = nil
        portfolio = nil
    }

    func loadStocks() async {
        do {
            stocks = try await OpticonAPI.shared.fetchStocks()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadPortfolio() async {
        guard isLoggedIn else { return }
        do {
            portfolio = try await OpticonAPI.shared.fetchPortfolio()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
