import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
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
        .sheet(isPresented: Binding(
            get: { appState.showLogin },
            set: { appState.showLogin = $0 }
        )) {
            LoginSheet()
                .environment(appState)
        }
    }
}

// MARK: - Markets

struct MarketsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Group {
                if appState.stocks.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(appState.stocks) { stock in
                        StockRow(stock: stock)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .padding(2)
                            )
                    }
                }
            }
            .navigationTitle("Markets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AuthButton()
                        .environment(appState)
                }
            }
        }
        .task {
            await appState.loadStocks()
        }
    }
}

struct StockRow: View {
    let stock: Stock

    private var changeColor: Color {
        stock.change >= 0 ? Color(hex: "34c759") : Color(hex: "ff3b30")
    }

    private var changeSign: String {
        stock.change >= 0 ? "+" : ""
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(stock.symbol)
                    .font(.headline.monospaced())
                Text(stock.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", stock.price))
                    .font(.body.monospaced())
                Text(String(format: "%@%.2f%%", changeSign, stock.changePercent))
                    .font(.caption.monospaced())
                    .foregroundStyle(changeColor)
            }
        }
    }
}

// MARK: - Portfolio

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
                    VStack(spacing: 16) {
                        Text("Sign in to view your portfolio")
                            .foregroundStyle(.secondary)
                        Button("Sign In") {
                            appState.showLogin = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "0071e3"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let portfolio = appState.portfolio {
                    ScrollView {
                        VStack(spacing: 24) {
                            VStack(spacing: 8) {
                                Text("Total Value")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(String(format: "$%.2f", portfolio.totalValue))
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                HStack(spacing: 4) {
                                    Text(String(format: "%@$%.2f", portfolio.dayChange >= 0 ? "+" : "", portfolio.dayChange))
                                    Text(String(format: "(%.2f%%)", portfolio.dayChangePercent))
                                }
                                .font(.caption.monospaced())
                                .foregroundStyle(changeColor)
                            }
                            .padding(.top, 24)

                            if !portfolio.holdings.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Holdings")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal)
                                        .padding(.bottom, 8)

                                    ForEach(portfolio.holdings) { holding in
                                        HoldingRow(holding: holding)
                                            .padding(.horizontal)
                                            .padding(.vertical, 10)
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                            }

                            Spacer()
                        }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Portfolio")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AuthButton()
                        .environment(appState)
                }
            }
        }
        .task {
            await appState.loadPortfolio()
        }
    }
}

struct HoldingRow: View {
    let holding: Portfolio.Holding

    private var gainColor: Color {
        holding.gainLoss >= 0 ? Color(hex: "34c759") : Color(hex: "ff3b30")
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(holding.symbol)
                    .font(.headline.monospaced())
                Text(String(format: "%.4f shares", holding.shares))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", holding.marketValue))
                    .font(.body.monospaced())
                Text(String(format: "%@$%.2f", holding.gainLoss >= 0 ? "+" : "", holding.gainLoss))
                    .font(.caption.monospaced())
                    .foregroundStyle(gainColor)
            }
        }
    }
}

// MARK: - Alerts

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

// MARK: - Auth Button

struct AuthButton: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Button {
            if appState.isLoggedIn {
                Task { await appState.logout() }
            } else {
                appState.showLogin = true
            }
        } label: {
            Text(appState.isLoggedIn ? "Sign Out" : "Sign In")
                .font(.caption)
        }
    }
}

// MARK: - Login Sheet

struct LoginSheet: View {
    @Environment(AppState.self) private var appState
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }

                if let error = appState.error {
                    Section {
                        Text(error)
                            .foregroundStyle(Color(hex: "ff3b30"))
                            .font(.caption)
                    }
                }

                Section {
                    Button {
                        Task {
                            await appState.login(email: email, password: password)
                        }
                    } label: {
                        if appState.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || appState.isLoading)
                    .tint(Color(hex: "0071e3"))
                }
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        appState.showLogin = false
                    }
                }
            }
        }
    }
}

// MARK: - Helpers

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
        .environment(AppState())
}
