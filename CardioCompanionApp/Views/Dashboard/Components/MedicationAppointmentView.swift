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
    @StateObject private var viewModel = AppointmentViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Appointments")
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
                            viewModel.fetchAppointments()
                        }
                        .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else if let nextAppointment = viewModel.appointments.first {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Upcoming")
                                .font(.subheadline)
                            Text(nextAppointment.title ?? "")
                                .font(.headline)
                            HStack {
                                Text("\(nextAppointment.date ?? Date(), formatter: dayFormatter)")
                                    .foregroundColor(.red)
                                Text(nextAppointment.date ?? Date(), formatter: monthFormatter)
                                Text(nextAppointment.date ?? Date(), formatter: timeFormatter)
                            }
                            .font(.subheadline)
                            
                            if let location = nextAppointment.location, !location.isEmpty {
                                HStack {
                                    Image(systemName: "location")
                                    Text(location)
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("No upcoming appointments")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .contentShape(Rectangle())
        .onAppear {
            viewModel.fetchAppointments()
        }
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
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
}

struct MedicationAppointmentRow: View {
    var body: some View {
        HStack(spacing: 16) {
            MedicationView()
            NavigationLink(destination: AppointmentsListView()) {
                AppointmentView()
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
    }
} 