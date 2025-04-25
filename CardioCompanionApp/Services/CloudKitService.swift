import Foundation
import CloudKit

class CloudKitService {
    static let shared = CloudKitService()
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    private init() {
        container = CKContainer.default()
        publicDatabase = container.publicCloudDatabase
    }
    
    func fetchEducationResources(completion: @escaping (Result<[EducationResource], Error>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "EducationResource", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let records = records else {
                completion(.success([]))
                return
            }
            
            let resources = records.compactMap { record -> EducationResource? in
                guard let title = record["title"] as? String,
                      let description = record["description"] as? String,
                      let categoryRaw = record["category"] as? String,
                      let typeRaw = record["type"] as? String,
                      let isFeatured = record["isFeatured"] as? Bool,
                      let content = record["content"] as? String,
                      let category = ResourceCategory(rawValue: categoryRaw),
                      let type = ResourceType(rawValue: typeRaw) else {
                    return nil
                }
                
                let imageURL = record["imageURL"] as? String
                let videoURL = record["videoURL"] as? String
                
                return EducationResource(
                    id: record.recordID.recordName.isEmpty ? UUID() : UUID(uuidString: record.recordID.recordName) ?? UUID(),
                    title: title,
                    description: description,
                    category: category,
                    type: type,
                    isFeatured: isFeatured,
                    imageURL: imageURL != nil ? URL(string: imageURL!) : nil,
                    videoURL: videoURL != nil ? URL(string: videoURL!) : nil,
                    content: content
                )
            }
            
            completion(.success(resources))
        }
    }
    
    func saveEducationResource(_ resource: EducationResource, completion: @escaping (Result<Void, Error>) -> Void) {
        let record = CKRecord(recordType: "EducationResource", recordID: CKRecord.ID(recordName: resource.id.uuidString))
        record["title"] = resource.title
        record["description"] = resource.description
        record["category"] = resource.category.rawValue
        record["type"] = resource.type.rawValue
        record["isFeatured"] = resource.isFeatured
        record["content"] = resource.content
        record["imageURL"] = resource.imageURL?.absoluteString
        record["videoURL"] = resource.videoURL?.absoluteString
        
        publicDatabase.save(record) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
} 