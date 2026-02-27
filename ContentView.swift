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

            PredictionsView()
                .tabItem {
                    Label("Predictions", systemImage: "waveform.path.ecg")
                }
                .tag(1)

            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "briefcase")
                }
                .tag(2)

            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.badge")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(4)
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

#Preview {
    ContentView()
        .environment(AppState())
}
