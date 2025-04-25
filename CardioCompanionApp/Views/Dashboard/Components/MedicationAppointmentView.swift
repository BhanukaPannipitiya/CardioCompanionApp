import SwiftUI

struct MedicationView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    // Color constants
    private let primaryColor = Color.blue
    private let medicationColor = Color.green
    private let errorColor = Color.red
    private let backgroundColor = Color(.systemBackground)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Medications")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: MedicationListView()) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(primaryColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(primaryColor.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(errorColor)
                            .font(.title2)
                        
                        Text(errorMessage)
                            .foregroundColor(errorColor)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { viewModel.refresh() }) {
                            Text("Retry")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(errorColor)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else if let nextMedication = viewModel.nextMedication,
                          let nextTime = viewModel.nextMedicationTime {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "pills.fill")
                            .font(.title2)
                            .foregroundColor(medicationColor)
                            .frame(width: 40, height: 40)
                            .background(medicationColor.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next dose")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(nextMedication.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(errorColor)
                                Text("at \(nextTime, formatter: timeFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(errorColor)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(backgroundColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                } else {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "pills.fill")
                            .font(.title2)
                            .foregroundColor(medicationColor)
                            .frame(width: 40, height: 40)
                            .background(medicationColor.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No upcoming medications")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(backgroundColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
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
    
    // Color constants
    private let primaryColor = Color.blue
    private let appointmentColor = Color.orange
    private let errorColor = Color.red
    private let backgroundColor = Color(.systemBackground)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Appointments")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: AppointmentsListView()) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(primaryColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(primaryColor.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(errorColor)
                            .font(.title2)
                        
                        Text(errorMessage)
                            .foregroundColor(errorColor)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { viewModel.fetchAppointments() }) {
                            Text("Retry")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(errorColor)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else if let nextAppointment = viewModel.appointments.first {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(appointmentColor)
                            .frame(width: 40, height: 40)
                            .background(appointmentColor.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Upcoming")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(nextAppointment.title ?? "")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .foregroundColor(appointmentColor)
                                Text("\(nextAppointment.date ?? Date(), formatter: dayFormatter)")
                                    .foregroundColor(appointmentColor)
                                Text(nextAppointment.date ?? Date(), formatter: monthFormatter)
                                Text(nextAppointment.date ?? Date(), formatter: timeFormatter)
                            }
                            .font(.subheadline)
                            
                            if let location = nextAppointment.location, !location.isEmpty {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(appointmentColor)
                                    Text(location)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(backgroundColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                } else {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(appointmentColor)
                            .frame(width: 40, height: 40)
                            .background(appointmentColor.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No upcoming appointments")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(backgroundColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
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
        VStack(spacing: 16) {
            MedicationView()
            AppointmentView()
        }
        .padding(.horizontal)
    }
} 