import SwiftUI

struct DateSelectionView: View {
    @Binding var date: Date
    
    // Color constants
    private let primaryColor = Color.blue
    private let backgroundColor = Color(.systemBackground)
    private let accentColor = Color.blue.opacity(0.1)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(primaryColor)
                    .frame(width: 40, height: 40)
                    .background(accentColor)
                    .clipShape(Circle())
                
                Text("When did you experience these symptoms?")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
            
            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(primaryColor)
                .padding()
                .background(backgroundColor)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    DateSelectionView(date: .constant(Date()))
} 