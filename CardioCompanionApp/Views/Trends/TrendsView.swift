import SwiftUI
import Charts

struct TrendsView: View {
    @State private var selectedTimeRange = "7 Days"
    let timeRanges = ["7 Days", "1 Month"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Health Trends")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Time range selector
                HStack {
                    ForEach(timeRanges, id: \.self) { range in
                        Button(action: { selectedTimeRange = range }) {
                            Text(range)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(selectedTimeRange == range ? Color.blue : Color.clear)
                                .foregroundColor(selectedTimeRange == range ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Vital stats grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    VitalStatCard(icon: "waveform.path.ecg", title: "Heart Rate", value: "75", unit: "BPM")
                    VitalStatCard(icon: "lungs.fill", title: "Oxygen Level", value: "97.1", unit: "%")
                    VitalStatCard(icon: "heart.fill", title: "Blood Pressure", value: "125/78", unit: "mmHg")
                    VitalStatCard(icon: "chart.bar.fill", title: "Health Score", value: "85", unit: "/100")
                }
                .padding(.horizontal)
                
                // Heart Rate Chart
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Heart Rate")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Sample chart (you'll need to implement actual Charts)
                    Rectangle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 200)
                        .overlay(
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 100))
                                path.addCurve(
                                    to: CGPoint(x: 350, y: 100),
                                    control1: CGPoint(x: 100, y: 80),
                                    control2: CGPoint(x: 250, y: 120)
                                )
                            }
                            .stroke(Color.blue, lineWidth: 2)
                        )
                        .padding(.horizontal)
                }
                
                // Symptom Occurrence
                VStack(alignment: .leading, spacing: 12) {
                    Text("Symptom Occurrence")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        SymptomBar(symptom: "Dizziness", count: 1)
                        SymptomBar(symptom: "Fatigue", count: 1)
                        SymptomBar(symptom: "Headache", count: 1)
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {}) {
                    Text("Generate Health Report")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding()
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGray6))
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
        }
    }
}

struct VitalStatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct SymptomBar: View {
    let symptom: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(symptom)
                .frame(width: 100, alignment: .leading)
            
            Rectangle()
                .fill(Color.blue)
                .frame(width: CGFloat(count) * 50, height: 20)
                .cornerRadius(4)
            
            Spacer()
        }
    }
} 