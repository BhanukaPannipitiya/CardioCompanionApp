// CardioCompanionApp/Views/Dashboard/DashboardView.swift
import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Welcome to CardioCompanion")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Your health journey starts here!")
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()
        }
        .navigationTitle("Dashboard")
        .navigationBarHidden(false)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView()
        }
    }
}
