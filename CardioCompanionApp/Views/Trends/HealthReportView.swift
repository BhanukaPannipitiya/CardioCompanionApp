import SwiftUI
import Charts

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

struct HealthReportView: View {
    let healthScore: Int
    let currentStreak: Int
    let improvement: Int
    let heartRate: Double
    let oxygenLevel: Double
    let bloodPressure: String
    let symptomData: [SymptomOccurrence]
    let startDate: Date
    let endDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var pdfData: Data?
    
    private let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.97)
    private let cardBackgroundColor = Color.white
    private let healthScoreColor = Color.green
    private let primaryColor = Color.blue
    
    private var heartRateChartData: [ChartDataPoint] {
        (0..<5).map { i in
            ChartDataPoint(
                day: "Day \(i + 1)",
                value: Double.random(in: 60...100)
            )
        }
    }
    
    private var bloodPressureChartData: [ChartDataPoint] {
        (0..<5).map { i in
            ChartDataPoint(
                day: "Day \(i + 1)",
                value: Double.random(in: 80...120)
            )
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                timeRangeSelector
                reportPeriodCard
                healthScoreCard
                vitalSignsSummary
                vitalSignsTrends
                symptomsSummary
                recommendationsSection
            }
            .padding(.vertical)
        }
        .background(backgroundColor)
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text("Close")
                    .foregroundColor(primaryColor)
            }
            Spacer()
            Text("Health Report")
                .font(.headline)
            Spacer()
            Button(action: generateAndSharePDF) {
                Text("Download")
                    .foregroundColor(primaryColor)
            }
        }
        .padding()
    }
    
    private var timeRangeSelector: some View {
        HStack {
            Button(action: {}) {
                Text("7 Days")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Button(action: {}) {
                Text("1 Month")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .foregroundColor(primaryColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(primaryColor, lineWidth: 1)
                    )
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var reportPeriodCard: some View {
        VStack(alignment: .leading) {
            Text("Health Report")
                .font(.headline)
            Text("Period: \(startDate.formatted(.dateTime.month().day().year())) to \(endDate.formatted(.dateTime.month().day().year()))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var healthScoreCard: some View {
        VStack(spacing: 16) {
            Text("Overall Health Score")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(healthScoreColor.opacity(0.2), lineWidth: 15)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(healthScore) / 100)
                    .stroke(healthScoreColor, lineWidth: 15)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                Text("\(healthScore)")
                    .font(.system(size: 36, weight: .bold))
            }
            
            healthScoreMetrics
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var healthScoreMetrics: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
                Text("Current Streak: \(currentStreak) days")
            }
            HStack {
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.green)
                Text("\(improvement)% Improvement this month")
            }
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text("Room for improvement: Blood Pressure")
            }
        }
    }
    
    private var vitalSignsSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vital Signs Summary")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                VitalStatCard(
                    icon: "waveform.path.ecg",
                    title: "Heart Rate",
                    value: String(format: "%.0f", heartRate),
                    unit: "BPM",
                    color: .red
                )
                
                VitalStatCard(
                    icon: "lungs.fill",
                    title: "Oxygen Level",
                    value: String(format: "%.1f", oxygenLevel),
                    unit: "%",
                    color: .blue
                )
                
                VitalStatCard(
                    icon: "heart.fill",
                    title: "Blood Pressure",
                    value: bloodPressure,
                    unit: "mmHg",
                    color: .purple
                )
                
                VitalStatCard(
                    icon: "chart.bar.fill",
                    title: "Health Score",
                    value: String(healthScore),
                    unit: "/100",
                    color: .green
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var vitalSignsTrends: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vital Signs Trends")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                trendChart(data: heartRateChartData, color: .red)
                trendChart(data: bloodPressureChartData, color: .blue)
            }
            .padding()
        }
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func trendChart(data: [ChartDataPoint], color: Color) -> some View {
        Chart(data) { point in
            LineMark(
                x: .value("Day", point.day),
                y: .value("Value", point.value)
            )
            .foregroundStyle(color)
        }
        .frame(height: 100)
    }
    
    private var symptomsSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Symptoms Summary")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(symptomData) { symptom in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(symptom.name)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(symptom.count) occurrences")
                                .foregroundColor(.gray)
                        }
                        Rectangle()
                            .fill(primaryColor)
                            .frame(width: CGFloat(symptom.count) * 50, height: 8)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
        }
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommendations")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 20) {
                RecommendationRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Continue Regular Monitoring",
                    description: "Keep monitoring your vital signs daily for optimal health tracking"
                )
                
                RecommendationRow(
                    icon: "person.fill",
                    title: "Consult with Doctor",
                    description: "Schedule a follow-up appointment to discuss your blood pressure readings"
                )
                
                RecommendationRow(
                    icon: "drop.fill",
                    title: "Stay Hydrated",
                    description: "Increase water intake to help with your occasional headaches"
                )
            }
            .padding()
        }
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func generateAndSharePDF() {
        if let data = PDFGenerator.generateHealthReport(
            healthScore: healthScore,
            currentStreak: currentStreak,
            improvement: improvement,
            heartRate: heartRate,
            oxygenLevel: oxygenLevel,
            bloodPressure: bloodPressure,
            symptomData: symptomData,
            startDate: startDate,
            endDate: endDate
        ) {
            self.pdfData = data
            self.showShareSheet = true
        }
    }
}

struct RecommendationRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

// Add ShareSheet view for iOS sharing functionality
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 