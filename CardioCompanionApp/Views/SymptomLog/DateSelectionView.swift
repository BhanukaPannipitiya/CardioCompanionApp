import SwiftUI

struct DateSelectionView: View {
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When did you experience these symptoms?")
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
            
            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    DateSelectionView(date: .constant(Date()))
} 