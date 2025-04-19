import SwiftUI

struct VitalReadingCard: View {
    let iconName: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct VitalReadingsView: View {
    let heartRate: Int
    let oxygenLevel: Int
    let bloodPressure: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Readings")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                VitalReadingCard(
                    iconName: "heart.fill",
                    value: "\(heartRate) BPM",
                    label: "Heart rate"
                )
                
                VitalReadingCard(
                    iconName: "lungs.fill",
                    value: "\(oxygenLevel)%",
                    label: "Oxygen"
                )
                
                VitalReadingCard(
                    iconName: "waveform.path.ecg",
                    value: bloodPressure,
                    label: "Blood Pressure"
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button(action: {}) {
                Text("View more trends")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
    }
} 