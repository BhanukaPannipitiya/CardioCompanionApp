import SwiftUI

struct ARExerciseButton: View {
    var body: some View {
        HStack {
            Image(systemName: "vission.pro.fill")
                .font(.title2)
            Text("AR breathing exercise")
                .font(.headline)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct EducationResourcesView: View {
    @StateObject private var viewModel = EducationResourcesViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Education & Resources")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: EducationResourcesListView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if let featuredResource = viewModel.featuredResource {
                NavigationLink(destination: ResourceDetailView(resource: featuredResource)) {
                    VStack(alignment: .leading, spacing: 12) {
                        if let imageURL = featuredResource.imageURL {
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
                        
                        Text("FEATURED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(4)
                        
                        Text(featuredResource.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(featuredResource.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
                }
            }
            
            ARExerciseButton()
        }
        .padding(.horizontal)
    }
} 
