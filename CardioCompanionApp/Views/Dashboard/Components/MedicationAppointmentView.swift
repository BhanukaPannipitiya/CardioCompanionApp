import SwiftUI

struct MedicationView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Medications")
                .font(.headline)
            
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                        Button("Retry") {
                            viewModel.refresh()
                        }
                        .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else if let nextMedication = viewModel.nextMedication,
                          let nextTime = viewModel.nextMedicationTime {
                    HStack(alignment: .top) {
                        Image(systemName: "pills.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .padding(.top, 2)
                        
                        VStack(alignment: .leading) {
                            Text("Next dose")
                                .font(.subheadline)
                            Text("\(nextMedication.name)")
                                .font(.headline)
                            Text("at \(nextTime, formatter: timeFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: MedicationListView()) {
                            Text("View all")
                                .font(.caption)
                        }
                    }
                    .padding(.top, 4)
                    
                } else {
                    HStack(alignment: .top) {
                        Image(systemName: "pills.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .padding(.top, 2)
                        
                        VStack(alignment: .leading) {
                            Text("No upcoming medications")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: MedicationListView()) {
                            Text("View all")
                                .font(.caption)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .onAppear {
            viewModel.refresh()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.refresh()
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
}

struct AppointmentView: View {
    let nextAppointment: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Appointments")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Upcoming")
                        .font(.subheadline)
                    HStack {
                        Text("\(nextAppointment, formatter: dayFormatter)")
                            .foregroundColor(.red)
                        Text(nextAppointment, formatter: monthFormatter)
                    }
                    .font(.headline)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .contentShape(Rectangle())
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
}

struct MedicationAppointmentRow: View {
    let nextAppointment: Date
    
    var body: some View {
        HStack(spacing: 16) {
            MedicationView()
            NavigationLink(destination: AppointmentsListView()) {
                AppointmentView(nextAppointment: nextAppointment)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
    }
} 