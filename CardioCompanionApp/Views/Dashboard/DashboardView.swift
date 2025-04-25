// CardioCompanionApp/Views/Dashboard/DashboardView.swift
import SwiftUI

struct DashboardView: View {
    // Sample data - in a real app, this would come from your data model
    private let healthScore = HealthScore(score: 95, streakDays: 5, achievements: ["5-Day Achievement"])
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Health Tracking")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HealthScoreCard()
                
                VitalReadingsView()
                
                MedicationAppointmentRow()
                
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
