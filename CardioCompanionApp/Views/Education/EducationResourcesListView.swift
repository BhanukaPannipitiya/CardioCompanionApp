import SwiftUI
import AVKit

struct EducationResourcesListView: View {
    @StateObject private var viewModel = EducationResourcesViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(ResourceCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    title: category.rawValue,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $viewModel.searchText)
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                            Button("Retry") {
                                viewModel.fetchResources()
                            }
                            .font(.caption)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredResources) { resource in
                                NavigationLink(destination: ResourceDetailView(resource: resource)) {
                                    ResourceCard(resource: resource)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Education & Resources")
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ResourceCard: View {
    let resource: EducationResource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if resource.isFeatured {
                Text("FEATURED")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            }
            
            if let imageURL = resource.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 150)
                .cornerRadius(12)
            }
            
            HStack {
                Text(resource.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: resource.type == .video ? "play.circle.fill" : "doc.text.fill")
                    .foregroundColor(.blue)
            }
            
            Text(resource.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(resource.type.rawValue)
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ResourceDetailView: View {
    let resource: EducationResource
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageURL = resource.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 200)
                }
                
                if let videoURL = resource.videoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 200)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    if resource.isFeatured {
                        Text("FEATURED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(4)
                    }
                    
                    Text(resource.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(resource.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text(resource.content)
                        .font(.body)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 