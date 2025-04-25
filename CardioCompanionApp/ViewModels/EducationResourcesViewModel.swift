import Foundation
import Combine

class EducationResourcesViewModel: ObservableObject {
    @Published var resources: [EducationResource] = []
    @Published var filteredResources: [EducationResource] = []
    @Published var selectedCategory: ResourceCategory = .recovery
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Setup search and category filtering
        Publishers.CombineLatest($searchText, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText, category in
                self?.filterResources(searchText: searchText, category: category)
            }
            .store(in: &cancellables)
        
        fetchResources()
    }
    
    private func filterResources(searchText: String, category: ResourceCategory) {
        let filtered = resources.filter { resource in
            let matchesCategory = resource.category == category
            
            if searchText.isEmpty {
                return matchesCategory
            }
            
            return matchesCategory && (
                resource.title.localizedCaseInsensitiveContains(searchText) ||
                resource.description.localizedCaseInsensitiveContains(searchText)
            )
        }
        
        filteredResources = filtered
    }
    
    func fetchResources() {
        isLoading = true
        errorMessage = nil
        
        // Simulating API call with sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.resources = EducationResource.sampleResources
            self?.filterResources(searchText: self?.searchText ?? "", category: self?.selectedCategory ?? .recovery)
            self?.isLoading = false
        }
    }
    
    func saveResource(_ resource: EducationResource) {
        // Implementation needed
    }
    
    var featuredResource: EducationResource? {
        resources.first { $0.isFeatured }
    }
} 