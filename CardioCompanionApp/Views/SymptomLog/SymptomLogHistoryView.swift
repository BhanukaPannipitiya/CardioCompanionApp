import SwiftUI

struct SymptomLogHistoryView: View {
    @StateObject private var viewModel: SymptomLogHistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: SymptomLogHistoryViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchSymptomLogs()
                            }
                        }
                    }
                } else if viewModel.symptomLogs.isEmpty {
                    VStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No symptom logs found")
                            .foregroundColor(.gray)
                    }
                } else {
                    List(viewModel.symptomLogs) { log in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(log.timestamp.formatted(date: .long, time: .shortened))
                                .font(.headline)
                            
                            ForEach(log.symptoms) { symptom in
                                HStack {
                                    Text(symptom.name)
                                    if symptom.isUrgent {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                    }
                                    Spacer()
                                    if let severity = log.severityRatings[symptom.name] {
                                        Text("Severity: \(Int(severity))/4")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Symptom History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.fetchSymptomLogs()
        }
    }
}

#Preview {
    SymptomLogHistoryView(userId: "1")
} 