import SwiftUI

struct SymptomLogHistoryView: View {
    @StateObject private var viewModel: SymptomLogHistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Color constants
    private let primaryColor = Color.blue
    private let urgentColor = Color.red
    private let backgroundColor = Color(.systemBackground)
    private let severityColors: [Color] = [
        .green,      // Level 0 - None/Mild
        .green.opacity(0.8),  // Level 1
        .yellow,     // Level 2
        .orange,     // Level 3
        .red        // Level 4 - Severe
    ]
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: SymptomLogHistoryViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(primaryColor)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(urgentColor)
                            
                            Text(error)
                                .foregroundColor(urgentColor)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                Task {
                                    await viewModel.fetchSymptomLogs()
                                }
                            }) {
                                Text("Retry")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(primaryColor)
                                    .cornerRadius(12)
                            }
                        }
                    } else if viewModel.symptomLogs.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                            
                            Text("No symptom logs found")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.symptomLogs) { log in
                                    SymptomLogCard(log: log, severityColors: severityColors)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Symptom History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .fontWeight(.semibold)
                            .foregroundColor(primaryColor)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchSymptomLogs()
        }
    }
}

struct SymptomLogCard: View {
    let log: SymptomLog
    let severityColors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text(log.timestamp.formatted(date: .long, time: .shortened))
                    .font(.headline)
            }
            .padding(.bottom, 4)
            
            ForEach(log.symptoms) { symptom in
                HStack(spacing: 12) {
                    // Symptom icon and name
                    HStack(spacing: 8) {
                        Image(systemName: symptom.isUrgent ? "exclamationmark.circle.fill" : "circle.fill")
                            .foregroundColor(symptom.isUrgent ? .red : .blue)
                            .imageScale(.small)
                        
                        Text(symptom.name)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    // Severity indicator
                    if let severity = log.severityRatings[symptom.name] {
                        let severityIndex = min(Int(severity), severityColors.count - 1)
                        HStack(spacing: 4) {
                            Text("Severity")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("\(Int(severity))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(severityColors[severityIndex])
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SymptomLogHistoryView(userId: "1")
} 