import Foundation

struct SymptomLog: Identifiable, Codable {
    let id: String
    let timestamp: Date
    var symptoms: [Symptom]
    var severityRatings: [String: Double]
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case timestamp
        case symptoms
        case severityRatings
        case userId
    }
    
    init(id: String, timestamp: Date = Date(), symptoms: [Symptom] = [], severityRatings: [String: Double] = [:], userId: String) {
        self.id = id
        self.timestamp = timestamp
        self.symptoms = symptoms
        self.severityRatings = severityRatings
        self.userId = userId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        // Decode timestamp as ISO 8601 string
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = dateFormatter.date(from: timestampString) else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
        timestamp = date
        
        symptoms = try container.decode([Symptom].self, forKey: .symptoms)
        severityRatings = try container.decode([String: Double].self, forKey: .severityRatings)
        userId = try container.decode(String.self, forKey: .userId)
    }
}

struct Symptom: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let isUrgent: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case isUrgent
    }
    
    init(id: String = UUID().uuidString, name: String, isUrgent: Bool = false) {
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