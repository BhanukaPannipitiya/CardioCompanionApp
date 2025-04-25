import SwiftUI

struct SeverityRatingView: View {
    let selectedSymptoms: [Symptom]
    @Binding var severityRatings: [String: Double]
    
    // Color constants
    private let primaryColor = Color.blue
    private let urgentColor = Color.red
    private let backgroundColor = Color(.systemBackground)
    private let sliderColors = [Color.green, Color.yellow, Color.orange, Color.red]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(primaryColor)
                    .frame(width: 40, height: 40)
                    .background(primaryColor.opacity(0.1))
                    .clipShape(Circle())
                
                Text("Rate Severity")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(selectedSymptoms) { symptom in
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(symptom.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if symptom.isUrgent {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(urgentColor)
                                        .imageScale(.small)
                                }
                            }
                            
                            VStack(spacing: 8) {
                                Slider(
                                    value: Binding(
                                        get: { severityRatings[symptom.name] ?? 0 },
                                        set: { severityRatings[symptom.name] = $0 }
                                    ),
                                    in: 0...4,
                                    step: 1
                                )
                                .accentColor(sliderColors[Int(severityRatings[symptom.name] ?? 0)])
                                
                                HStack {
                                    Text("Mild")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text("Severe")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    SeverityRatingView(
        selectedSymptoms: Symptom.predefinedSymptoms,
        severityRatings: .constant([:])
    )
} 