import SwiftUI

struct AddMedicationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MedicationListViewModel // Use the list VM to add directly

    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var scheduleTimes: [Date] = [Date()] // Start with one time picker set to now
    
    private static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    var body: some View {
        NavigationView { // Embed in NavigationView for title and buttons
            Form {
                Section("MEDICATION DETAILS") {
                    TextField("Name", text: $name)
                    TextField("Dosage (e.g., 50mg)", text: $dosage)
                }

                Section("SCHEDULE") {
                    ForEach($scheduleTimes.indices, id: \.self) { index in
                        DatePicker("Add Time", selection: $scheduleTimes[index], displayedComponents: .hourAndMinute)
                    }
                    .onDelete(perform: removeTime)
                    
                    Button("Add to Schedule") {
                        scheduleTimes.append(Date()) // Add another time picker
                    }
                }
            }
            .navigationTitle("New Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMedication()
                        dismiss()
                    }
                    .disabled(name.isEmpty || scheduleTimes.isEmpty) // Disable save if no name or schedule
                }
            }
        }
    }

    private func removeTime(at offsets: IndexSet) {
        scheduleTimes.remove(atOffsets: offsets)
        // Ensure at least one time remains if needed, or handle empty state
        if scheduleTimes.isEmpty {
           // scheduleTimes.append(Date()) // Option: re-add one if all are deleted
        }
    }

    private func saveMedication() {
        let newMedication = Medication(
            id: UUID(),
            name: name,
            dosage: dosage.isEmpty ? nil : dosage,
            schedule: scheduleTimes,
            takenToday: [:]
        )
        viewModel.addMedication(newMedication)
    }
}

struct AddMedicationView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicationView(viewModel: MedicationListViewModel()) // Provide a dummy VM for preview
    }
} 