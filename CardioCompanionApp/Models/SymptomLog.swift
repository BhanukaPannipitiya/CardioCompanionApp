import Foundation

struct SymptomLog: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    var symptoms: [Symptom]
    var severityRatings: [String: Double]
    let userId: String
    
    init(id: UUID = UUID(), timestamp: Date = Date(), symptoms: [Symptom] = [], severityRatings: [String: Double] = [:], userId: String) {
        self.id = id
        self.timestamp = timestamp
        self.symptoms = symptoms
        self.severityRatings = severityRatings
        self.userId = userId
    }
}

struct Symptom: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let isUrgent: Bool
    
    init(id: UUID = UUID(), name: String, isUrgent: Bool = false) {
        self.id = id
        self.name = name
        self.isUrgent = isUrgent
    }
    
    static let predefinedSymptoms: [Symptom] = [
        Symptom(name: "Fatigue", isUrgent: false),
        Symptom(name: "Breathlessness", isUrgent: true),
        Symptom(name: "Swelling", isUrgent: false),
        Symptom(name: "Chest Pain", isUrgent: true),
        Symptom(name: "Dizziness", isUrgent: true),
        Symptom(name: "Nausea", isUrgent: false)
    ]
} 