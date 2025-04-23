import SwiftUI

struct SeverityRatingView: View {
    let selectedSymptoms: [Symptom]
    @Binding var severityRatings: [String: Double]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Rate Severity and Time")
                    .font(.headline)
                
                ForEach(selectedSymptoms) { symptom in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(symptom.name)
                                .font(.subheadline)
                            
                            if symptom.isUrgent {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Slider(
                                value: Binding(
                                    get: { severityRatings[symptom.name] ?? 0 },
                                    set: { severityRatings[symptom.name] = $0 }
                                ),
                                in: 0...4,
                                step: 1
                            )
                            .accentColor(.red)
                            
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
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    SeverityRatingView(
        selectedSymptoms: Symptom.predefinedSymptoms,
        severityRatings: .constant([:])
    )
} 