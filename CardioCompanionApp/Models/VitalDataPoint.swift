import Foundation

struct VitalDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
} 