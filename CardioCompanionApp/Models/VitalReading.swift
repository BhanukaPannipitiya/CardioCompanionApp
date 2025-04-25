import Foundation
import CoreData

@objc(VitalReading)
class VitalReading: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var heartRate: Int16
    @NSManaged var oxygenLevel: Int16
    @NSManaged var bloodPressureSystolic: Int16
    @NSManaged var bloodPressureDiastolic: Int16
    @NSManaged var symptoms: [String]?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
    }
}