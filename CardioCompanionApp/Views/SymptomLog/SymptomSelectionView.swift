import SwiftUI

struct SymptomSelectionView: View {
    @Binding var selectedSymptoms: Set<Symptom>
    @Binding var customSymptom: String
    let onAddCustomSymptom: () -> Void
    let onToggleSymptom: (Symptom) -> Void
    
    // Color constants
    private let primaryColor = Color.blue
    private let urgentColor = Color.red
    private let backgroundColor = Color(.systemBackground)
    private let selectedBackgroundColor = Color.blue.opacity(0.1)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title2)
                    .foregroundColor(primaryColor)
                    .frame(width: 40, height: 40)
                    .background(primaryColor.opacity(0.1))
                    .clipShape(Circle())
                
                Text("Select Symptoms")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(Symptom.predefinedSymptoms) { symptom in
                            SymptomButton(
                                symptom: symptom,
                                isSelected: selectedSymptoms.contains(symptom),
                                action: { onToggleSymptom(symptom) }
                            )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(primaryColor)
                            Text("Other (please specify)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            TextField("Enter symptom", text: $customSymptom)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 8)
                                .background(backgroundColor)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(primaryColor.opacity(0.3), lineWidth: 1)
                                )
                            
                            Button(action: onAddCustomSymptom) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(primaryColor)
                                    .frame(width: 40, height: 40)
                                    .background(primaryColor.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .disabled(customSymptom.isEmpty)
                        }
                    }
                    .padding()
                    .background(backgroundColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct SymptomButton: View {
    let symptom: Symptom
    let isSelected: Bool
    let action: () -> Void
    
    // Color constants
    private let primaryColor = Color.blue
    private let urgentColor = Color.red
    private let selectedBackgroundColor = Color.blue.opacity(0.1)
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(symptom.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if symptom.isUrgent {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(urgentColor)
                        .imageScale(.small)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? selectedBackgroundColor : Color(.systemBackground))
            .foregroundColor(isSelected ? primaryColor : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? primaryColor : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}

#Preview {
    SymptomSelectionView(
        selectedSymptoms: .constant([]),
        customSymptom: .constant(""),
        onAddCustomSymptom: {},
        onToggleSymptom: { _ in }
    )
} 