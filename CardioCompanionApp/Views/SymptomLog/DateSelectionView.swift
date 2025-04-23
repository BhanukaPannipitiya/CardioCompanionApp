import SwiftUI

struct DateSelectionView: View {
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("When did you experience these symptoms?")
                .font(.headline)
                .padding(.top)
            
            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .labelsHidden()
        }
        .padding()
    }
}

#Preview {
    DateSelectionView(date: .constant(Date()))
} 