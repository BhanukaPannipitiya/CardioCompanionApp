import SwiftUI

struct LogSymptomsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Log Symptoms")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            
            // Progress indicator
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == 0 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            Text("Step 1 of 3")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Question
            VStack(alignment: .leading, spacing: 16) {
                Text("When did you experience these symptoms?")
                    .font(.headline)
                    .padding(.horizontal)
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Next button
            Button(action: {}) {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding()
        }
    }
} 