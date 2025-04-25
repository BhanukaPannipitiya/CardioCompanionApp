import Intents
import CoreData

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        if intent is CreateAppointmentIntent {
            return CreateAppointmentIntentHandler()
        }
        return self
    }
}

class CreateAppointmentIntentHandler: NSObject, CreateAppointmentIntentHandling {
    func handle(intent: CreateAppointmentIntent, completion: @escaping (CreateAppointmentIntentResponse) -> Void) {
        let title = intent.title ?? "Untitled"
        let dateComponents = intent.date // DateComponents? as per intent definition
        let location = intent.location ?? ""
        let note = intent.note ?? ""
        
        // Convert DateComponents to Date, or use current date as fallback
        let calendar = Calendar.current
        let date = dateComponents.flatMap { calendar.date(from: $0) } ?? Date()
        
        if saveAppointment(title: title, date: date, location: location, note: note) {
            let response = CreateAppointmentIntentResponse(code: .success, userActivity: nil)
            response.title = "Appointment created: \(title)"
            completion(response)
        } else {
            let response = CreateAppointmentIntentResponse(code: .failure, userActivity: nil)
            response.title = "Failed to create appointment."
            completion(response)
        }
    }
    
    func resolveTitle(for intent: CreateAppointmentIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let title = intent.title, !title.isEmpty {
            completion(.success(with: title))
        } else {
            completion(.needsValue())
        }
    }

    func resolveDate(for intent: CreateAppointmentIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        if let date = intent.date {
            completion(.success(with: date))
        } else {
            completion(.needsValue())
        }
    }
    
    func resolveLocation(for intent: CreateAppointmentIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let location = intent.location, !location.isEmpty {
            completion(.success(with: location))
        } else {
            completion(.notRequired())
        }
    }
    
    func resolveNote(for intent: CreateAppointmentIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let note = intent.note, !note.isEmpty {
            completion(.success(with: note))
        } else {
            completion(.notRequired())
        }
    }
    
    private func saveAppointment(title: String, date: Date, location: String, note: String) -> Bool {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.appointment.temp") else {
            return false
        }
        
        let storeURL = containerURL.appendingPathComponent("CardioCompanionApp.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentContainer(name: "CardioCompanionApp")
        container.persistentStoreDescriptions = [description]
        
        var saveSuccess = false
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to load store: \(error)")
                saveSuccess = false
                return
            }
            
            let context = container.viewContext
            let appointment = MedicalAppointment(context: context)
            appointment.title = title
            appointment.date = date
            appointment.location = location
            appointment.notes = note
            
            do {
                try context.save()
                saveSuccess = true
                print("Successfully saved appointment")
            } catch {
                print("Core Data error: \(error)")
                saveSuccess = false
            }
        }
        
        return saveSuccess
    }
}
