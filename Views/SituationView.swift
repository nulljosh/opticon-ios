import MapKit
import SwiftUI

struct SituationView: View {
    private enum City: String, CaseIterable, Identifiable {
        case vancouver = "Vancouver"
        case nyc = "NYC"
        case london = "London"
        case tokyo = "Tokyo"

        var id: String { rawValue }

        var apiValue: String {
            switch self {
            case .vancouver: return "vancouver"
            case .nyc: return "nyc"
            case .london: return "london"
            case .tokyo: return "tokyo"
            }
        }

        var region: MKCoordinateRegion {
            switch self {
            case .vancouver:
                return MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207),
                    span: MKCoordinateSpan(latitudeDelta: 2.2, longitudeDelta: 2.2)
                )
            case .nyc:
                return MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                    span: MKCoordinateSpan(latitudeDelta: 2.2, longitudeDelta: 2.2)
                )
            case .london:
                return MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 51.5072, longitude: -0.1276),
                    span: MKCoordinateSpan(latitudeDelta: 2.2, longitudeDelta: 2.2)
                )
            case .tokyo:
                return MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 35.6764, longitude: 139.6500),
                    span: MKCoordinateSpan(latitudeDelta: 2.2, longitudeDelta: 2.2)
                )
            }
        }
    }

    @State private var selectedCity: City = .vancouver
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207),
            span: MKCoordinateSpan(latitudeDelta: 2.2, longitudeDelta: 2.2)
        )
    )

    @State private var earthquakes: [Earthquake] = []
    @State private var flights: [Flight] = []
    @State private var incidents: [Incident] = []
    @State private var weatherAlerts: [WeatherAlert] = []

    @State private var showEarthquakes = true
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                citySelector

                ZStack {
                    mapView

                    if isLoading {
                        ProgressView()
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                ScrollView {
                    VStack(spacing: 14) {
                        DisclosureGroup(isExpanded: $showEarthquakes) {
                            if earthquakes.isEmpty {
                                Text("No earthquakes for \(selectedCity.rawValue)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 8)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(earthquakes) { quake in
                                        earthquakeRow(quake)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        } label: {
                            Text("Earthquakes (\(earthquakes.count))")
                                .font(.headline)
                        }
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Weather Alerts")
                                .font(.headline)

                            if weatherAlerts.isEmpty {
                                Text("No weather alerts for \(selectedCity.rawValue)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(weatherAlerts) { alert in
                                    weatherAlertRow(alert)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }

                if let error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color(hex: "ff3b30"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .navigationTitle("Situation Monitor")
        }
        .tint(Color(hex: "0071e3"))
        .preferredColorScheme(.dark)
        .task {
            await loadData(for: selectedCity)
        }
        .onChange(of: selectedCity) { _, newValue in
            mapPosition = .region(newValue.region)
            Task {
                await loadData(for: newValue)
            }
        }
    }

    private var citySelector: some View {
        HStack(spacing: 8) {
            ForEach(City.allCases) { city in
                Button(city.rawValue) {
                    selectedCity = city
                }
                .buttonStyle(.plain)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(city == selectedCity ? Color(hex: "0071e3") : .white.opacity(0.08))
                )
                .foregroundStyle(city == selectedCity ? .white : .primary)
            }
        }
    }

    private var mapView: some View {
        Map(position: $mapPosition) {
            ForEach(earthquakes) { quake in
                Marker(quake.title, coordinate: quake.coordinate)
                    .tint(.red)
            }

            ForEach(flights) { flight in
                Marker(flight.callsign, coordinate: flight.coordinate)
                    .tint(.cyan)
            }

            ForEach(incidents) { incident in
                Marker(incident.title, coordinate: incident.coordinate)
                    .tint(Color(hex: "ffbf00"))
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }

    private func earthquakeRow(_ quake: Earthquake) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(quake.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer()
                Text(String(format: "M %.1f", quake.magnitude))
                    .font(.caption.monospaced())
                    .foregroundStyle(.red)
            }

            HStack(spacing: 8) {
                if let depthKm = quake.depthKm {
                    Text(String(format: "Depth %.1f km", depthKm))
                }
                if let place = quake.place, !place.isEmpty {
                    Text(place)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    private func weatherAlertRow(_ alert: WeatherAlert) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(alert.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(alert.severity.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(hex: "ffbf00"))
            }

            if let summary = alert.summary, !summary.isEmpty {
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    private func loadData(for city: City) async {
        isLoading = true
        error = nil

        do {
            async let earthquakesResponse = OpticonAPI.shared.fetchEarthquakes(city: city.apiValue)
            async let flightsResponse = OpticonAPI.shared.fetchFlights(city: city.apiValue)
            async let incidentsResponse = OpticonAPI.shared.fetchIncidents(city: city.apiValue)
            async let weatherResponse = OpticonAPI.shared.fetchWeatherAlerts(city: city.apiValue)

            earthquakes = try await earthquakesResponse
            flights = try await flightsResponse
            incidents = try await incidentsResponse
            weatherAlerts = try await weatherResponse
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
