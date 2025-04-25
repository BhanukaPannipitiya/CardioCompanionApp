import SwiftUI
import HealthKit
import Charts

struct TrendsView: View {
    @StateObject private var vitalsManager = VitalsManager.shared
    @EnvironmentObject private var authManager: AuthManager
    @State private var selectedTimeRange: TimeRange = .week
    @State private var heartRateData: [VitalDataPoint] = []
    @State private var oxygenData: [VitalDataPoint] = []
    @State private var bloodPressureData: [BloodPressureDataPoint] = []
    @State private var symptomData: [SymptomOccurrence] = []
    @State private var isLoading = true
    @State private var selectedVitalType: VitalType = .heartRate
    
    enum TimeRange: String, CaseIterable {
        case week = "7 Days"
        case month = "1 Month"
    }
    
    enum VitalType: String {
        case heartRate = "Heart Rate"
        case oxygenLevel = "Oxygen Level"
        case bloodPressure = "Blood Pressure"
    }
    
    // Latest vital readings
    private var latestHeartRate: Double {
        heartRateData.last?.value ?? 0
    }
    
    private var latestOxygenLevel: Double {
        oxygenData.last?.value ?? 0
    }
    
    private var latestBloodPressure: String {
        if let latest = bloodPressureData.last {
            return "\(Int(latest.systolic))/\(Int(latest.diastolic))"
        }
        return "---/---"
    }
    
    // Calculate health score based on vitals
    private var healthScore: Int {
        var score = 85 // Base score
        // Add your health score calculation logic here
        return score
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time range selector
                HStack {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button(action: { selectedTimeRange = range }) {
                            Text(range.rawValue)
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
                    VitalStatCard(icon: "waveform.path.ecg",
                                title: "Heart Rate",
                                value: String(format: "%.0f", latestHeartRate),
                                unit: "BPM")
                    
                    VitalStatCard(icon: "lungs.fill",
                                title: "Oxygen Level",
                                value: String(format: "%.1f", latestOxygenLevel),
                                unit: "%")
                    
                    VitalStatCard(icon: "heart.fill",
                                title: "Blood Pressure",
                                value: latestBloodPressure,
                                unit: "mmHg")
                    
                    VitalStatCard(icon: "chart.bar.fill",
                                title: "Health Score",
                                value: String(healthScore),
                                unit: "/100")
                }
                .padding(.horizontal)
                
                // Vital type selector
                HStack {
                    ForEach([VitalType.heartRate, .oxygenLevel, .bloodPressure], id: \.self) { type in
                        Button(action: { selectedVitalType = type }) {
                            Text(type.rawValue)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(selectedVitalType == type ? Color.blue : Color.clear)
                                .foregroundColor(selectedVitalType == type ? .white : .primary)
                                .cornerRadius(6)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Selected vital trend chart
                VStack(alignment: .leading) {
                    Text("\(selectedVitalType.rawValue) Trends")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView()
                            .frame(height: 200)
                    } else {
                        switch selectedVitalType {
                        case .heartRate:
                            TrendLineChart(data: heartRateData)
                        case .oxygenLevel:
                            TrendLineChart(data: oxygenData)
                        case .bloodPressure:
                            BloodPressureChart(data: bloodPressureData)
                        }
                    }
                }
                
                // Symptom Occurrence
                VStack(alignment: .leading, spacing: 12) {
                    Text("Symptom Occurrence")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if symptomData.isEmpty {
                        Text("No symptoms reported")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Chart {
                            ForEach(symptomData) { symptom in
                                BarMark(
                                    x: .value("Symptom", symptom.name),
                                    y: .value("Count", symptom.count)
                                )
                                .foregroundStyle(Color.blue)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                    }
                }
                
                // Generate Report Button
                Button(action: generateHealthReport) {
                    Text("Generate Health Report")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Health Trends")
        .task {
            await loadData()
        }
        .onChange(of: selectedTimeRange) { _ in
            Task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        }
        
        // Load health data
        do {
            async let heartRate = vitalsManager.fetchHeartRateData(from: startDate, to: now)
            async let oxygen = vitalsManager.fetchOxygenData(from: startDate, to: now)
            async let bloodPressure = vitalsManager.fetchBloodPressureData(from: startDate, to: now)
            
            let (hr, o2, bp) = try await (heartRate, oxygen, bloodPressure)
            heartRateData = hr
            oxygenData = o2
            bloodPressureData = bp
        } catch {
            print("Error loading health data: \(error)")
        }
        
        // Load symptom data
        do {
            let symptoms = try await APIService.shared.getSymptomReports(
                userId: authManager.currentUserId ?? "",
                startDate: startDate,
                endDate: now
            )
            
            // Process symptoms into occurrence counts
            var symptomCounts: [String: Int] = [:]
            for symptomLog in symptoms {
                for symptom in symptomLog.symptoms {
                    symptomCounts[symptom.name, default: 0] += 1
                }
            }
            
            symptomData = symptomCounts.map { SymptomOccurrence(name: $0.key, count: $0.value) }
            symptomData.sort { $0.count > $1.count }
        } catch {
            print("Error loading symptom data: \(error)")
        }
    }
    
    private func generateHealthReport() {
        // Implement health report generation
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
        .shadow(radius: 2)
    }
}

struct TrendLineChart: View {
    let data: [VitalDataPoint]
    
    var body: some View {
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
            }
        }
        .frame(height: 200)
        .padding()
    }
}

struct BloodPressureChart: View {
    let data: [BloodPressureDataPoint]
    
    var body: some View {
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Systolic", point.systolic)
                )
                .foregroundStyle(.red)
                
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Diastolic", point.diastolic)
                )
                .foregroundStyle(.blue)
            }
        }
        .frame(height: 200)
        .padding()
    }
}

struct SymptomOccurrence: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
} 