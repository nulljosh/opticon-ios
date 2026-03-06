import CoreLocation
import Foundation

struct Earthquake: Codable, Identifiable {
    let id: String
    let title: String
    let magnitude: Double
    let latitude: Double
    let longitude: Double
    let depthKm: Double?
    let place: String?
    let occurredAt: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, magnitude, latitude, longitude, place
        case depthKm = "depth_km"
        case occurredAt = "occurred_at"
    }
}

struct Flight: Codable, Identifiable {
    let id: String
    let callsign: String
    let origin: String?
    let destination: String?
    let latitude: Double
    let longitude: Double
    let altitudeFeet: Int?
    let status: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id, callsign, origin, destination, latitude, longitude, status
        case altitudeFeet = "altitude_feet"
    }
}

struct Incident: Codable, Identifiable {
    let id: String
    let title: String
    let severity: String
    let latitude: Double
    let longitude: Double
    let summary: String?
    let reportedAt: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, severity, latitude, longitude, summary
        case reportedAt = "reported_at"
    }
}

struct WeatherAlert: Codable, Identifiable {
    let id: String
    let title: String
    let severity: String
    let summary: String?
    let effectiveAt: String?
    let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, severity, summary
        case effectiveAt = "effective_at"
        case expiresAt = "expires_at"
    }
}
