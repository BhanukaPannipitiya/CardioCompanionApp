import SwiftUI

struct NewAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    
    // TODO: Add callback/binding to pass saved appointment back

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var addToCalendar: Bool = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Location", text: $location)
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100) // Adjust height as needed
                }
                Toggle("Add to Calendar", isOn: $addToCalendar)
            }
            .navigationTitle("New Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Implement save logic
                        saveAppointment()
                        dismiss()
                    }
                    .disabled(title.isEmpty) // Disable save if title is empty
                }
            }
        }
    }
    
    private func saveAppointment() {
        // TODO: Implement actual saving (e.g., to ViewModel, CoreData)
        // let newAppointment = AppointmentDetails(title: title, date: date, location: location, notes: notes)
        // Pass newAppointment back or save through ViewModel
        print("Saving appointment:")
        print("Title: \(title)")
        print("Date: \(date)")
        print("Location: \(location)")
        print("Notes: \(notes)")
        print("Add to Calendar: \(addToCalendar)")
        
        // TODO: Implement calendar adding logic if addToCalendar is true
    }
}

#Preview {
    NewAppointmentView()
} 