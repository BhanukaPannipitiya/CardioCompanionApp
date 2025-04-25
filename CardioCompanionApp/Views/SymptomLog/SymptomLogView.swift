import SwiftUI

struct SymptomLogView: View {
    @StateObject private var viewModel: SymptomLogViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 1
    @State private var showHistory = false
    
    // Color constants
    private let primaryColor = Color.blue
    private let backgroundColor = Color(.systemGroupedBackground)
    private let progressColor = Color.blue
    private let progressBackgroundColor = Color.gray.opacity(0.3)
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: SymptomLogViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Log Symptoms")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Progress indicator
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            ForEach(1...3, id: \.self) { step in
                                Circle()
                                    .fill(step <= currentStep ? progressColor : progressBackgroundColor)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Circle()
                                            .stroke(step <= currentStep ? progressColor : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.top, 8)
                        
                        Text("Step \(currentStep) of 3")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
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
                    HStack(spacing: 16) {
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
                .padding(.vertical)
            }
            .background(backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showHistory = true
                        }) {
                            Image(systemName: "clock.fill")
                                .font(.title3)
                                .foregroundColor(primaryColor)
                                .frame(width: 40, height: 40)
                                .background(primaryColor.opacity(0.1))
                                .clipShape(Circle())
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
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .foregroundColor(.blue)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    SymptomLogView(userId: "1")
} 