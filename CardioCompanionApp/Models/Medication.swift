import Foundation

struct Medication: Codable, Identifiable {
    let id: UUID
    let name: String
    let dosage: String?
    let schedule: [Date]
    var takenToday: [Date: Bool]

    // Memberwise initializer
    init(id: UUID = UUID(), name: String, dosage: String?, schedule: [Date], takenToday: [Date: Bool] = [:]) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.schedule = schedule
        self.takenToday = takenToday
    }

   
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, dosage, schedule, takenToday
    }

  
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
      
        if let idString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: idString) {
            id = uuid
        } else {
            id = UUID()
        }
        
        name = try container.decode(String.self, forKey: .name)
        dosage = try container.decodeIfPresent(String.self, forKey: .dosage)
        schedule = try container.decode([Date].self, forKey: .schedule)

       
        let takenTodayData = try container.decode([TakenTodayEntry].self, forKey: .takenToday)
        takenToday = Dictionary(uniqueKeysWithValues: takenTodayData.map { ($0.date, $0.taken) })
    }

    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(dosage, forKey: .dosage)
        try container.encode(schedule, forKey: .schedule)
        
       
        let takenTodayData = takenToday.map { TakenTodayEntry(date: $0.key, taken: $0.value) }
        try container.encode(takenTodayData, forKey: .takenToday)
    }
}


struct TakenTodayEntry: Codable {
    let date: Date
    let taken: Bool
}
