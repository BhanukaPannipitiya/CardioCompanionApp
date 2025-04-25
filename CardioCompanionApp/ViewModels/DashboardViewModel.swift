import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var nextMedication: Medication?
    @Published var nextMedicationTime: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchMedications()
    }
    
    func refresh() {
        fetchMedications()
    }
    
    private func fetchMedications() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchMedications { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let medications):
                    self?.updateNextMedication(from: medications)
                    // Schedule notifications for all medications
                    NotificationManager.shared.scheduleNotificationsForMedications(medications)
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch medications: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func updateNextMedication(from medications: [Medication]) {
        let now = Date()
        var nextMedication: Medication?
        var nextTime: Date?
        
        for medication in medications {
            for scheduleTime in medication.schedule {
                // Normalize the schedule time to today
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: now)
                let normalizedScheduleTime = calendar.date(bySettingHour: calendar.component(.hour, from: scheduleTime),
                                                         minute: calendar.component(.minute, from: scheduleTime),
                                                         second: 0,
                                                         of: today)!
                
                // Only consider future times
                if normalizedScheduleTime > now {
                    if nextTime == nil || normalizedScheduleTime < nextTime! {
                        nextTime = normalizedScheduleTime
                        nextMedication = medication
                    }
                }
            }
        }
        
        self.nextMedication = nextMedication
        self.nextMedicationTime = nextTime
    }
} 