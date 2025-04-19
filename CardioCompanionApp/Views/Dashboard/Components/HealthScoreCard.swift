import SwiftUI

struct HealthScoreCard: View {
    let score: Int
    let streakDays: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.green, lineWidth: 10)
                        .frame(width: 80, height: 80)
                    
                    VStack {
                        Text("\(score)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Health Score")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streakDays) Day Streak!")
                            .foregroundColor(.blue)
                    }
                    
                    Text("Keep logging daily to maintain your streak and earn rewards!")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("5-Day Achievement Unlocked!")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
} 