import Foundation
import CoreData
import SwiftUI

class AppointmentViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var appointments: [MedicalAppointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchAppointments()
    }
    
    func fetchAppointments() {
        isLoading = true
        errorMessage = nil
        
        let request: NSFetchRequest<MedicalAppointment> = MedicalAppointment.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicalAppointment.date, ascending: true)]
        
        do {
            appointments = try viewContext.fetch(request)
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch appointments: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func addAppointment(title: String, date: Date, location: String, notes: String) {
        let appointment = MedicalAppointment(context: viewContext)
        appointment.id = UUID()
        appointment.title = title
        appointment.date = date
        appointment.location = location
        appointment.notes = notes
        
        saveContext()
        fetchAppointments()
    }
    
    func updateAppointment(_ appointment: MedicalAppointment, title: String, date: Date, location: String, notes: String) {
        appointment.title = title
        appointment.date = date
        appointment.location = location
        appointment.notes = notes
        
        saveContext()
        fetchAppointments()
    }
    
    func deleteAppointment(_ appointment: MedicalAppointment) {
        viewContext.delete(appointment)
        saveContext()
        fetchAppointments()
    }
    
    func deleteAppointments(at offsets: IndexSet) {
        offsets.forEach { index in
            let appointment = appointments[index]
            viewContext.delete(appointment)
        }
        saveContext()
        fetchAppointments()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            errorMessage = "Failed to save context: \(error.localizedDescription)"
        }
    }
} 