import Foundation

struct HealthScore {
    var score: Int
    var streakDays: Int
    var achievements: [String]
}

struct VitalReading {
    var heartRate: Int
    var oxygenLevel: Int
    var bloodPressure: String
}

struct Appointment {
    var date: Date
} 
