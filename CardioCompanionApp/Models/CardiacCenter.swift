import Foundation
import CoreLocation

struct CardiacCenter: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let phoneNumber: String
    let rating: Double
    let waitTime: String
    var distance: Double?
    
    var formattedRating: String {
        return String(format: "%.1f/5.0", rating)
    }
} 