import SwiftUI

struct SymptomSelectionView: View {
    @Binding var selectedSymptoms: Set<Symptom>
    @Binding var customSymptom: String
    let onAddCustomSymptom: () -> Void
    let onToggleSymptom: (Symptom) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Symptoms")
                .font(.headline)
            
            ScrollView {
                VStack(spacing: 12) {
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
                    
                    VStack(alignment: .leading) {
                        Text("Other (please specify)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            TextField("Enter symptom", text: $customSymptom)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: onAddCustomSymptom) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .disabled(customSymptom.isEmpty)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .padding()
    }
}

struct SymptomButton: View {
    let symptom: Symptom
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(symptom.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if symptom.isUrgent {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .imageScale(.small)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
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