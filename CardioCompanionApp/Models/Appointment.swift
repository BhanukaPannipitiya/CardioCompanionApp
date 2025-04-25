import Foundation

// Model for Appointment Details shown/edited in the UI
struct AppointmentDetails: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var location: String
    var notes: String
} 
