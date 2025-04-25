import SwiftUI

struct MedicationListView: View {
    @StateObject private var viewModel = MedicationListViewModel()
    @State private var showingAddMedicationSheet = false
    
    private static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 24-hour format, e.g., "14:30"
        return formatter
    }
    
    var body: some View {
        List { // Use List for scrollability and swipe-to-delete
            // Section for Adherence Score
            Section {
                VStack {
                    Text("Adherence Score")
                        .font(.headline)
                    AdherenceRingView(score: viewModel.adherenceScore)
                        .frame(height: 150) // Give the ring some size
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity) // Center the content
            }
            
            // Section for Medications
            Section("MEDICATIONS") {
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
                            viewModel.fetchMedications()
                        }
                        .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else {
                    ForEach(viewModel.medications) { medication in
                        // Group each medication and its schedules
                        VStack(alignment: .leading) {
                            Text(medication.name).font(.title3).bold()
                            if let dosage = medication.dosage {
                                Text(dosage).font(.subheadline).foregroundColor(.gray)
                            }
                            ForEach(medication.schedule, id: \.self) { scheduleTime in
                                HStack {
                                    // Use Self.timeFormatter to access the static property
                                    Text("Schedule: \(scheduleTime, formatter: Self.timeFormatter)")
                                    Spacer()
                                    Image(systemName: viewModel.isTaken(medication: medication, scheduleTime: scheduleTime) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.isTaken(medication: medication, scheduleTime: scheduleTime) ? .green : .gray)
                                        .onTapGesture {
                                            viewModel.toggleTakenStatus(for: medication, scheduleTime: scheduleTime)
                                        }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.vertical, 4) // Add padding around each medication group
                    }
                    .onDelete(perform: viewModel.deleteMedication) // Enable swipe to delete
                    
                    Button {
                        showingAddMedicationSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Medication")
                        }
                    }
                    .foregroundColor(.blue) // Standard button color
                }
            }
        }
        .navigationTitle("Medication")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton() // Add standard Edit button to manage list (e.g., delete)
            }
        }
        .sheet(isPresented: $showingAddMedicationSheet) {
            // Pass the same viewModel instance to the sheet
            AddMedicationView(viewModel: viewModel)
        }
    }
}

// Placeholder for the Adherence Ring View (requires a separate implementation)
struct AdherenceRingView: View {
    let score: Double // 0.0 to 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.orange)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.score, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.orange)
                .rotationEffect(Angle(degrees: 270.0)) // Start from the top
            
            Text(String(format: "%.0f%%", min(self.score, 1.0) * 100))
                .font(.largeTitle)
                .bold()
        }
    }
}

struct MedicationListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for preview
            MedicationListView()
        }
        
    }
}
