import SwiftUI
import HealthKit

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
    @StateObject private var vitalsManager = VitalsManager.shared
    @State private var heartRate: Double = 0
    @State private var oxygenLevel: Double = 0
    @State private var systolic: Double = 0
    @State private var diastolic: Double = 0
    @State private var isLoading = true
    
    var bloodPressureString: String {
        if systolic == 0 || diastolic == 0 {
            return "---/---"
        }
        return "\(Int(systolic))/\(Int(diastolic))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Readings")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                VitalReadingCard(
                    iconName: "heart.fill",
                    value: isLoading ? "..." : "\(Int(heartRate)) BPM",
                    label: "Heart rate"
                )
                
                VitalReadingCard(
                    iconName: "lungs.fill",
                    value: isLoading ? "..." : "\(Int(oxygenLevel))%",
                    label: "Oxygen"
                )
                
                VitalReadingCard(
                    iconName: "waveform.path.ecg",
                    value: isLoading ? "..." : bloodPressureString,
                    label: "Blood Pressure"
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            NavigationLink(destination: TrendsView()) {
                Text("View more trends")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
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
