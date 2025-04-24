import Foundation
import Combine

@MainActor
class SymptomLogViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var selectedSymptoms: Set<Symptom> = []
    @Published var severityRatings: [String: Double] = [:]
    @Published var customSymptom: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func toggleSymptom(_ symptom: Symptom) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
            severityRatings.removeValue(forKey: symptom.name)
        } else {
            selectedSymptoms.insert(symptom)
            severityRatings[symptom.name] = 0.0
        }
    }
    
    func updateSeverity(for symptom: String, value: Double) {
        severityRatings[symptom] = value
    }
    
    func addCustomSymptom() {
        guard !customSymptom.isEmpty else { return }
        let newSymptom = Symptom(name: customSymptom)
        selectedSymptoms.insert(newSymptom)
        severityRatings[newSymptom.name] = 0.0
        customSymptom = ""
    }
    
    func saveSymptomLog() async {
        isLoading = true
        errorMessage = nil
        
        let symptomLog = SymptomLog(
            id: UUID().uuidString,
            timestamp: selectedDate,
            symptoms: Array(selectedSymptoms),
            severityRatings: severityRatings,
            userId: userId
        )
        
        do {
            try await withCheckedThrowingContinuation { continuation in
                apiService.saveSymptomLog(symptomLog: symptomLog) { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            // Reset form after successful save
            selectedSymptoms.removeAll()
            severityRatings.removeAll()
            selectedDate = Date()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 