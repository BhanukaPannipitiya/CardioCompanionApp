import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func fetchProfile() {
        apiService.fetchUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.profile = profile
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Failed to fetch profile: \(error.localizedDescription)")
                }
            }
        }
    }
} 