// CardioCompanionApp/Views/Dashboard/DashboardView.swift
import SwiftUI

struct DashboardView: View {
    // Sample data - in a real app, this would come from your data model
    private let healthScore = HealthScore(score: 95, streakDays: 5, achievements: ["5-Day Achievement"])
    private let vitalReading = VitalReading(heartRate: 70, oxygenLevel: 95, bloodPressure: "111/78")
    private let nextDose = Calendar.current.date(from: DateComponents(hour: 16, minute: 0)) ?? Date()
    private let nextAppointment = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Health Tracking")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HealthScoreCard(score: healthScore.score, streakDays: healthScore.streakDays)
                
                VitalReadingsView(
                    heartRate: vitalReading.heartRate,
                    oxygenLevel: vitalReading.oxygenLevel,
                    bloodPressure: vitalReading.bloodPressure
                )
                
                MedicationAppointmentRow(
                    nextDoseTime: nextDose,
                    nextAppointment: nextAppointment
                )
                
                EducationResourcesView()
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView()
        }
    }
}
