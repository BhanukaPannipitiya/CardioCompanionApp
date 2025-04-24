import SwiftUI

struct SymptomLogView: View {
    @StateObject private var viewModel: SymptomLogViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 1
    @State private var showHistory = false
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: SymptomLogViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress indicator
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            ForEach(1...3, id: \.self) { step in
                                Circle()
                                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        .padding(.top, 16)
                        
                        Text("Step \(currentStep) of 3")
                            .foregroundColor(.gray)
                    }
                    
                    // Step content
                    switch currentStep {
                    case 1:
                        DateSelectionView(date: $viewModel.selectedDate)
                    case 2:
                        SymptomSelectionView(
                            selectedSymptoms: $viewModel.selectedSymptoms,
                            customSymptom: $viewModel.customSymptom,
                            onAddCustomSymptom: viewModel.addCustomSymptom,
                            onToggleSymptom: viewModel.toggleSymptom
                        )
                    case 3:
                        SeverityRatingView(
                            selectedSymptoms: Array(viewModel.selectedSymptoms),
                            severityRatings: $viewModel.severityRatings
                        )
                    default:
                        EmptyView()
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Navigation buttons
                    HStack {
                        if currentStep > 1 {
                            Button("Back") {
                                withAnimation {
                                    currentStep -= 1
                                }
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        
                        if currentStep < 3 {
                            Button("Next") {
                                withAnimation {
                                    currentStep += 1
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        } else {
                            Button("Save") {
                                Task {
                                    await viewModel.saveSymptomLog()
                                    dismiss()
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first {
                                        window.rootViewController?.present(
                                            UIHostingController(rootView: SymptomLogHistoryView(userId: viewModel.userId)),
                                            animated: true
                                        )
                                    }
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(viewModel.isLoading)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Log Symptoms")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            showHistory = true
                        }) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showHistory) {
                SymptomLogHistoryView(userId: viewModel.userId)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .foregroundColor(.blue)
            .background(Color.clear)
            .cornerRadius(8)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
    }
}

#Preview {
    SymptomLogView(userId: "1")
} 