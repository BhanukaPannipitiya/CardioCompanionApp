import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        print(" Requesting notification authorization...")
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print(" Notification authorization granted")
            } else if let error = error {
                print(" Notification authorization error: \(error.localizedDescription)")
            } else {
                print("Notification authorization denied by user")
            }
        }
    }
    
    func scheduleMedicationNotification(for medication: Medication, at time: Date) {
        print(" Attempting to schedule notification for \(medication.name) at \(time)")
        
        let content = UNMutableNotificationContent()
        content.title = "Time to take your medication"
        content.body = "It's time to take \(medication.name)"
        if let dosage = medication.dosage {
            content.body += " (\(dosage))"
        }
        content.sound = UNNotificationSound.default
        
        // Create a trigger for 5 minutes before the medication time
        let calendar = Calendar.current
        let notificationTime = calendar.date(byAdding: .minute, value: -5, to: time) ?? time
        
        print(" Notification will be delivered at: \(notificationTime)")
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create a unique identifier for this notification
        let identifier = "medication-\(medication.id)-\(time.timeIntervalSince1970)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(" Error scheduling notification: \(error.localizedDescription)")
            } else {
                print(" Successfully scheduled notification for \(medication.name) at \(time)")
            }
        }
    }
    
    func cancelAllMedicationNotifications() {
        print(" Canceling all medication notifications")
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    func scheduleNotificationsForMedications(_ medications: [Medication]) {
        print(" Scheduling notifications for \(medications.count) medications")
        
        // Cancel existing notifications
        cancelAllMedicationNotifications()
        
        let now = Date()
        let calendar = Calendar.current
        
        for medication in medications {
            for scheduleTime in medication.schedule {
                // Normalize the schedule time to today
                let today = calendar.startOfDay(for: now)
                let normalizedScheduleTime = calendar.date(bySettingHour: calendar.component(.hour, from: scheduleTime),
                                                         minute: calendar.component(.minute, from: scheduleTime),
                                                         second: 0,
                                                         of: today)!
                
                // Only schedule notifications for future times
                if normalizedScheduleTime > now {
                    print("🔔 Scheduling notification for \(medication.name) at \(normalizedScheduleTime)")
                    scheduleMedicationNotification(for: medication, at: normalizedScheduleTime)
                } else {
                    print("⚠️ Skipping past time \(normalizedScheduleTime) for \(medication.name)")
                }
            }
        }
    }
    
    func checkNotificationSettings() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            print("🔔 Current notification settings:")
            print("  - Authorization status: \(settings.authorizationStatus.rawValue)")
            print("  - Alert style: \(settings.alertStyle.rawValue)")
            print("  - Badge enabled: \(settings.badgeSetting == .enabled)")
            print("  - Sound enabled: \(settings.soundSetting == .enabled)")
            print("  - Lock screen enabled: \(settings.lockScreenSetting == .enabled)")
            print("  - Notification center enabled: \(settings.notificationCenterSetting == .enabled)")
        }
    }
} 
