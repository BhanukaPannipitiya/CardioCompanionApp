import Foundation
import EventKit
import SwiftUI

class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()
    
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestAccess() async throws -> Bool {
        let status = try await eventStore.requestAccess(to: .event)
        await MainActor.run {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        }
        return status
    }
    
    func addAppointmentToCalendar(title: String, date: Date, location: String?, notes: String?) async throws {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        if status == .notDetermined {
            _ = try await requestAccess()
        }
        
        guard status == .authorized else {
            throw CalendarError.notAuthorized
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = date
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
        event.location = location
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        try eventStore.save(event, span: .thisEvent)
    }
}

enum CalendarError: LocalizedError {
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Calendar access is required to add appointments to your calendar. Please enable calendar access in Settings."
        }
    }
} 