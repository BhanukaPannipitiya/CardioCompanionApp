import SwiftUI

struct EducationResourceCard: View {
    let title: String
    let description: String
    let isFeatured: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isFeatured {
                Text("FEATURED")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            }
            
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.white)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
    }
}

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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Education & Resources")
                .font(.headline)
            
            EducationResourceCard(
                title: "First Week After Cardiac Surgery",
                description: "What to expect and how to manage your recovery in the first critical week.",
                isFeatured: true
            )
            
            ARExerciseButton()
        }
        .padding(.horizontal)
    }
} 
