import SwiftUI

struct HealthScoreCard: View {
    @StateObject private var healthScoreManager = HealthScoreManager.shared
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
            
            if isLoading {
                ProgressView()
            } else {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(scoreColor, lineWidth: 8)
                            .frame(width: 90, height: 90)
                        
                        VStack {
                            Text("\(healthScoreManager.currentScore)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(scoreColor)
                            Text("Health Score")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if healthScoreManager.streakDays > 0 {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("\(healthScoreManager.streakDays) Day Streak!")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text("Keep logging daily to maintain your streak and earn rewards!")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if let latestAchievement = healthScoreManager.achievements.first {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                Text(latestAchievement)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .task {
            isLoading = true
            await healthScoreManager.calculateHealthScore()
            isLoading = false
        }
    }
    
    private var scoreColor: Color {
        switch healthScoreManager.currentScore {
        case 90...150:
            return .green
        case 70...89:
            return .yellow
        default:
            return .orange
        }
    }
} 
