import SwiftUI
import CoreData

struct NewAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AppointmentViewModel
    @StateObject private var calendarManager = CalendarManager.shared
    @State private var appointment: MedicalAppointment?
    
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var addToCalendar: Bool = false
    @State private var showingCalendarError = false
    @State private var calendarError: String = ""

    init(viewModel: AppointmentViewModel, appointment: MedicalAppointment? = nil) {
        self.viewModel = viewModel
        self._appointment = State(initialValue: appointment)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Location", text: $location)
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                Section {
                    Toggle("Add to Calendar", isOn: $addToCalendar)
                } footer: {
                    if calendarManager.authorizationStatus == .denied {
                        Text("Calendar access is required. Please enable it in Settings.")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(appointment == nil ? "New Appointment" : "Edit Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAppointment()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Calendar Error", isPresented: $showingCalendarError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(calendarError)
            }
        }
        .onAppear {
            if let appointment = appointment {
                title = appointment.title ?? ""
                date = appointment.date ?? Date()
                location = appointment.location ?? ""
                notes = appointment.notes ?? ""
            }
        }
    }
    
    private func saveAppointment() {
        if let appointment = appointment {
            viewModel.updateAppointment(appointment, title: title, date: date, location: location, notes: notes)
        } else {
            viewModel.addAppointment(title: title, date: date, location: location, notes: notes)
        }
        
        if addToCalendar {
            Task {
                do {
                    try await calendarManager.addAppointmentToCalendar(
                        title: title,
                        date: date,
                        location: location.isEmpty ? nil : location,
                        notes: notes.isEmpty ? nil : notes
                    )
                    await MainActor.run {
                        dismiss()
                    }
                } catch {
                    await MainActor.run {
                        calendarError = error.localizedDescription
                        showingCalendarError = true
                    }
                }
            }
        } else {
            dismiss()
        }
    }
}

#Preview {
    NewAppointmentView(viewModel: AppointmentViewModel())
} 