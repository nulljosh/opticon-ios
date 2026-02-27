import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Group {
                if !appState.isLoggedIn {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Sign in to view settings")
                            .foregroundStyle(.secondary)
                        Button("Sign In") {
                            appState.showLogin = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "0071e3"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    settingsList
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var settingsList: some View {
        List {
            Section("Account") {
                HStack {
                    Text("Email")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(appState.user?.email ?? "")
                        .font(.body.monospaced())
                }

                HStack {
                    Text("Tier")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(tierLabel)
                        .font(.body.weight(.medium))
                        .foregroundStyle(tierColor)
                }
            }

            Section("Watchlist") {
                if appState.watchlist.isEmpty {
                    Text("No symbols in watchlist")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(appState.watchlist) { item in
                        HStack {
                            Text(item.symbol)
                                .font(.body.monospaced())
                            Spacer()
                            if let date = item.addedAt {
                                Text(date.prefix(10))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let symbol = appState.watchlist[index].symbol
                            Task { await appState.removeWatchlistSymbol(symbol) }
                        }
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    Task { await appState.logout() }
                } label: {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }

    private var tierLabel: String {
        switch appState.user?.tier {
        case "starter": return "Starter"
        case "pro": return "Pro"
        default: return "Free"
        }
    }

    private var tierColor: Color {
        switch appState.user?.tier {
        case "starter": return Color(hex: "0071e3")
        case "pro": return Color(hex: "f5a623")
        default: return .secondary
        }
    }
}
