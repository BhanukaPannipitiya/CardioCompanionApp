import SwiftUI
import Combine

class MedicationListViewModel: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var adherenceScore: Double = 0.0

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Check notification settings
        NotificationManager.shared.checkNotificationSettings()
        
        fetchMedications()
        $medications
            .sink { [weak self] medications in
                self?.calculateAdherence()
                // Schedule notifications for all medications
                NotificationManager.shared.scheduleNotificationsForMedications(medications)
            }
            .store(in: &cancellables)
        
        calculateAdherence()
    }

    func fetchMedications() {
        APIService.shared.fetchMedications { result in
            switch result {
            case .success(let medications):
                self.medications = medications
            case .failure(let error):
                print("Failed to fetch medications: \(error)")
            }
        }
    }

    func toggleTakenStatus(for medication: Medication, scheduleTime: Date) {
        guard let index = medications.firstIndex(where: { $0.id == medication.id }) else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let normalizedScheduleTime = calendar.date(bySettingHour: calendar.component(.hour, from: scheduleTime),
                                                 minute: calendar.component(.minute, from: scheduleTime),
                                                 second: 0,
                                                 of: today)!
        
        let currentStatus = medications[index].takenToday[normalizedScheduleTime] ?? false
        let newStatus = !currentStatus
        
        medications[index].takenToday[normalizedScheduleTime] = newStatus
        
        APIService.shared.toggleMedicationTaken(id: medication.id.uuidString, scheduleTime: normalizedScheduleTime, isTaken: newStatus) { result in
            switch result {
            case .success(let updatedMedication):
                self.medications[index] = updatedMedication
            case .failure(let error):
                print("Failed to toggle taken status: \(error)")
                self.medications[index].takenToday[normalizedScheduleTime] = currentStatus
            }
        }
    }

    func addMedication(_ medication: Medication) {
        APIService.shared.addMedication(medication) { result in
            switch result {
            case .success(let addedMedication):
                self.medications.append(addedMedication)
            case .failure(let error):
                print("Failed to add medication: \(error)")
            }
        }
    }
    
    func deleteMedication(at offsets: IndexSet) {
        for index in offsets {
            let medication = medications[index]
            APIService.shared.deleteMedication(id: medication.id.uuidString) { result in
                switch result {
                case .success:
                    self.medications.remove(at: index)
                case .failure(let error):
                    print("Failed to delete medication: \(error)")
                }
            }
        }
    }

    private func calculateAdherence() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var totalDoses = 0
        var takenDoses = 0

        for med in medications {
            for scheduleTime in med.schedule {
                totalDoses += 1
                let normalizedScheduleTime = calendar.date(bySettingHour: calendar.component(.hour, from: scheduleTime),
                                                      minute: calendar.component(.minute, from: scheduleTime),
                                                      second: 0,
                                                      of: today)!
                if med.takenToday[normalizedScheduleTime] == true {
                    takenDoses += 1
                }
            }
        }

        adherenceScore = totalDoses > 0 ? Double(takenDoses) / Double(totalDoses) : 1.0
    }
    
    func isTaken(medication: Medication, scheduleTime: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let normalizedScheduleTime = calendar.date(bySettingHour: calendar.component(.hour, from: scheduleTime),
                                                 minute: calendar.component(.minute, from: scheduleTime),
                                                 second: 0,
                                                 of: today)!
        return medication.takenToday[normalizedScheduleTime] ?? false
    }
}
