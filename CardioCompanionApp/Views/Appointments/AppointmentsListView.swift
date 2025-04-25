import SwiftUI

struct AppointmentsListView: View {
    @State private var showingAddNewAppointment = false
    // TODO: Replace with actual appointment data source/ViewModel
    @State private var appointments: [AppointmentDetails] = []

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

                    // TODO: List actual appointments here
                    if appointments.isEmpty {
                        Text("No upcoming appointments.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(appointments) { appointment in
                            // TODO: Create AppointmentRow view
                            Text(appointment.title)
                        }
                        .onDelete(perform: deleteAppointments) // Add swipe-to-delete if needed
                    }
                }
            }
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton() // Standard SwiftUI Edit button
                }
            }
            .sheet(isPresented: $showingAddNewAppointment) {
                // TODO: Present NewAppointmentView here
                NewAppointmentView()
            }
        }
    }

    // TODO: Implement actual deletion logic
    private func deleteAppointments(offsets: IndexSet) {
        appointments.remove(atOffsets: offsets)
    }
}

#Preview {
    AppointmentsListView()
} 