import Foundation

struct BloodPressureDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let systolic: Double
    let diastolic: Double
} 