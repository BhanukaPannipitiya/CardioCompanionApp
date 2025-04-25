import SwiftUI
import HealthKit

struct VitalReadingCard: View {
    let iconName: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct VitalReadingsView: View {
    @StateObject private var vitalsManager = VitalsManager.shared
    @State private var heartRate: Double = 0
    @State private var oxygenLevel: Double = 0
    @State private var systolic: Double = 0
    @State private var diastolic: Double = 0
    @State private var isLoading = true
    
    // Color constants
    private let heartRateColor = Color.red
    private let oxygenColor = Color.blue
    private let bloodPressureColor = Color.purple
    
    var bloodPressureString: String {
        if systolic == 0 || diastolic == 0 {
            return "---/---"
        }
        return "\(Int(systolic))/\(Int(diastolic))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Readings")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: TrendsView()) {
                    Text("View Trends")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                VitalReadingCard(
                    iconName: "heart.fill",
                    value: isLoading ? "..." : "\(Int(heartRate))",
                    label: "Heart Rate",
                    color: heartRateColor
                )
                
                VitalReadingCard(
                    iconName: "lungs.fill",
                    value: isLoading ? "..." : "\(Int(oxygenLevel))%",
                    label: "Oxygen",
                    color: oxygenColor
                )
                
                VitalReadingCard(
                    iconName: "waveform.path.ecg",
                    value: isLoading ? "..." : bloodPressureString,
                    label: "Blood Pressure",
                    color: bloodPressureColor
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .task {
            await loadLatestVitals()
        }
    }
    
    private func loadLatestVitals() async {
        isLoading = true
        defer { isLoading = false }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        do {
            // Fetch heart rate
            let heartRateData = try await vitalsManager.fetchHeartRateData(from: startOfDay, to: now)
            if let latestHeartRate = heartRateData.last?.value {
                heartRate = latestHeartRate
            }
            
            // Fetch oxygen level
            let oxygenData = try await vitalsManager.fetchOxygenData(from: startOfDay, to: now)
            if let latestOxygen = oxygenData.last?.value {
                oxygenLevel = latestOxygen
            }
            
            // Fetch blood pressure
            let bloodPressureData = try await vitalsManager.fetchBloodPressureData(from: startOfDay, to: now)
            if let latestBP = bloodPressureData.last {
                systolic = latestBP.systolic
                diastolic = latestBP.diastolic
            }
        } catch {
            print("Error loading vitals: \(error)")
        }
    }
} 
