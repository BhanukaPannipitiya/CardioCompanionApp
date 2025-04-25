import XCTest
import CoreLocation
@testable import CardioCompanionApp

final class CardioCompanionTests: XCTestCase {
    
    // MARK: - User Profile Tests
    
    func testUserProfileCreation() {
        let userProfile = UserProfile(
            id: "123",
            name: "John Doe",
            email: "john@example.com",
            username: "johndoe",
            firstName: "John",
            lastName: "Doe",
            address: "123 Main St",
            dateOfBirth: "1990-01-01",
            postOpDay: 5,
            streak: 10,
            points: 100,
            subscriptionStatus: "active",
            adherenceRate: 95,
            recentSymptoms: nil,
            createdAt: "2024-04-15",
            lastLogin: "2024-04-15"
        )
        
        XCTAssertEqual(userProfile.id, "123")
        XCTAssertEqual(userProfile.name, "John Doe")
        XCTAssertEqual(userProfile.email, "john@example.com")
        XCTAssertEqual(userProfile.postOpDay, 5)
        XCTAssertEqual(userProfile.streak, 10)
        XCTAssertEqual(userProfile.points, 100)
        XCTAssertEqual(userProfile.adherenceRate, 95)
    }
    
    func testUserProfileEquality() {
        let profile1 = UserProfile(
            id: "123",
            name: "John Doe",
            email: "john@example.com",
            username: nil,
            firstName: nil,
            lastName: nil,
            address: nil,
            dateOfBirth: nil,
            postOpDay: nil,
            streak: nil,
            points: nil,
            subscriptionStatus: nil,
            adherenceRate: nil,
            recentSymptoms: nil,
            createdAt: nil,
            lastLogin: nil
        )
        
        let profile2 = UserProfile(
            id: "123",
            name: "John Doe",
            email: "john@example.com",
            username: nil,
            firstName: nil,
            lastName: nil,
            address: nil,
            dateOfBirth: nil,
            postOpDay: nil,
            streak: nil,
            points: nil,
            subscriptionStatus: nil,
            adherenceRate: nil,
            recentSymptoms: nil,
            createdAt: nil,
            lastLogin: nil
        )
        
        XCTAssertEqual(profile1, profile2)
    }
    
    // MARK: - Symptom Log Tests
    
    func testSymptomLogCreation() {
        let symptom = ProfileSymptom(name: "Chest Pain", isUrgent: true, id: "1")
        let symptomLog = ProfileSymptomLog(
            id: "log1",
            userId: "user1",
            timestamp: "2024-04-15T10:00:00Z",
            symptoms: [symptom],
            severityRatings: ["Chest Pain": 8],
            createdAt: "2024-04-15T10:00:00Z"
        )
        
        XCTAssertEqual(symptomLog.id, "log1")
        XCTAssertEqual(symptomLog.userId, "user1")
        XCTAssertEqual(symptomLog.symptoms.count, 1)
        XCTAssertEqual(symptomLog.symptoms[0].name, "Chest Pain")
        XCTAssertEqual(symptomLog.symptoms[0].isUrgent, true)
        XCTAssertEqual(symptomLog.severityRatings["Chest Pain"], 8)
    }
    
    // MARK: - Health Data Tests
    
    func testHealthDataPointCreation() {
        let vitalDataPoint = VitalDataPoint(
            date: Date(),
            value: 75.0
        )
        
        XCTAssertEqual(vitalDataPoint.value, 75.0)
    }
    
    // MARK: - Appointment Tests
    
    func testAppointmentCreation() {
        let appointment = Appointment(
            date: Date()
        )
        
        XCTAssertNotNil(appointment.date)
    }
    
    // MARK: - Cardiac Center Tests
    
    func testCardiacCenterCreation() {
        let center = CardiacCenter(
            name: "Heart Care Center",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            address: "456 Health St",
            phoneNumber: "123-456-7890",
            rating: 4.5,
            waitTime: "15 min"
        )
        
        XCTAssertEqual(center.name, "Heart Care Center")
        XCTAssertEqual(center.address, "456 Health St")
        XCTAssertEqual(center.phoneNumber, "123-456-7890")
        XCTAssertEqual(center.rating, 4.5)
        XCTAssertEqual(center.waitTime, "15 min")
    }
}
