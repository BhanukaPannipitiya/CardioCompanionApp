import Foundation
import HealthKit

class HealthScoreManager: ObservableObject {
    static let shared = HealthScoreManager()
    private let vitalsManager = VitalsManager.shared
    
    @Published var currentScore: Int = 0
    @Published var streakDays: Int = 0
    @Published var achievements: [String] = []
    
    private init() {}
    
    func calculateHealthScore() async {
        do {
            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)
            let pastWeek = calendar.date(byAdding: .day, value: -7, to: now)!
            
            // Fetch latest vitals
            let heartRateData = try await vitalsManager.fetchHeartRateData(from: startOfDay, to: now)
            let oxygenData = try await vitalsManager.fetchOxygenData(from: startOfDay, to: now)
            let bloodPressureData = try await vitalsManager.fetchBloodPressureData(from: startOfDay, to: now)
            
            // Calculate base score (70 points max)
            var score = 70
            
            // Heart Rate Analysis (0-25 points)
            if let latestHR = heartRateData.last?.value {
                if (60...100).contains(latestHR) {
                    score += 25 // Optimal range
                } else if (50...120).contains(latestHR) {
                    score += 15 // Acceptable range
                } else {
                    score += 5 // Out of range
                }
            }
            
            // Oxygen Level Analysis (0-25 points)
            if let latestO2 = oxygenData.last?.value {
                if latestO2 >= 95 {
                    score += 25 // Optimal
                } else if latestO2 >= 90 {
                    score += 15 // Acceptable
                } else {
                    score += 5 // Concerning
                }
            }
            
            // Blood Pressure Analysis (0-30 points)
            if let latestBP = bloodPressureData.last {
                let systolic = latestBP.systolic
                let diastolic = latestBP.diastolic
                
                if (90...120).contains(systolic) && (60...80).contains(diastolic) {
                    score += 30 // Optimal range
                } else if (85...130).contains(systolic) && (55...85).contains(diastolic) {
                    score += 20 // Normal range
                } else {
                    score += 10 // Out of range
                }
            }
            
            // Calculate streak
            var streak = 0
            var currentDate = startOfDay
            
            while currentDate >= pastWeek {
                let dayData = try await vitalsManager.fetchHeartRateData(
                    from: calendar.startOfDay(for: currentDate),
                    to: calendar.date(byAdding: .day, value: 1, to: currentDate)!
                )
                
                if dayData.isEmpty {
                    break
                }
                
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            }
            
            // Update achievements
            var newAchievements: [String] = []
            if streak >= 7 {
                newAchievements.append("7-Day Streak! 🏆")
            } else if streak >= 5 {
                newAchievements.append("5-Day Streak! 🌟")
            } else if streak >= 3 {
                newAchievements.append("3-Day Streak! ⭐️")
            }
            
            if score >= 90 {
                newAchievements.append("Excellent Health! 💪")
            }
            
            // Update published properties on main thread
            await MainActor.run {
                self.currentScore = score
                self.streakDays = streak
                self.achievements = newAchievements
            }
        } catch {
            print("Error calculating health score: \(error)")
        }
    }
} 