import SwiftUI
import CoreData

struct AppointmentsListView: View {
    @StateObject private var viewModel = AppointmentViewModel()
    @State private var showingAddNewAppointment = false
    @State private var appointmentToEdit: MedicalAppointment?

    var body: some View {
        NavigationView {
            List {
                Section("UPCOMING APPOINTMENTS") {
                    Button {
                        showingAddNewAppointment = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Add Appointment")
                        }
                    }

                    if viewModel.appointments.isEmpty {
                        Text("No upcoming appointments.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.appointments, id: \.id) { appointment in
                            AppointmentRow(appointment: appointment)
                                .onTapGesture {
                                    appointmentToEdit = appointment
                                }
                        }
                        .onDelete(perform: viewModel.deleteAppointments)
                    }
                }
            }
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddNewAppointment) {
                NewAppointmentView(viewModel: viewModel)
            }
            .sheet(item: $appointmentToEdit) { appointment in
                NewAppointmentView(viewModel: viewModel, appointment: appointment)
            }
        }
    }
}

struct AppointmentRow: View {
    let appointment: MedicalAppointment
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(appointment.title ?? "")
                .font(.headline)
            
            HStack {
                Image(systemName: "calendar")
                Text(dateFormatter.string(from: appointment.date ?? Date()))
                    .font(.subheadline)
            }
            
            if let location = appointment.location, !location.isEmpty {
                HStack {
                    Image(systemName: "location")
                    Text(location)
                        .font(.subheadline)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AppointmentsListView()
} 