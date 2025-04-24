import Foundation
import Combine

@MainActor
class SymptomLogHistoryViewModel: ObservableObject {
    @Published var symptomLogs: [SymptomLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func fetchSymptomLogs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await withCheckedThrowingContinuation { continuation in
                apiService.fetchSymptomLogs { result in
                    switch result {
                    case .success(let logs):
                        continuation.resume()
                        self.symptomLogs = logs
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 