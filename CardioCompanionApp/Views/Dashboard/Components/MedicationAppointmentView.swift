import SwiftUI

struct MedicationView: View {
    let nextDoseTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Medications")
                .font(.headline)
            
            HStack {
                Image(systemName: "pills.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading) {
                    Text("Next dose")
                        .font(.subheadline)
                    Text("at \(nextDoseTime, formatter: timeFormatter)")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button("View all") {
                    // Action
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
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
                
                Button("View all") {
                    // Action
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
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
}

struct MedicationAppointmentRow: View {
    let nextDoseTime: Date
    let nextAppointment: Date
    
    var body: some View {
        HStack(spacing: 16) {
            MedicationView(nextDoseTime: nextDoseTime)
            AppointmentView(nextAppointment: nextAppointment)
        }
        .padding(.horizontal)
    }
} 