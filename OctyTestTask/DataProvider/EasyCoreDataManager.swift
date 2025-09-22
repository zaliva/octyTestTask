import Foundation
import CoreData

let ECDManager = EasyCoreDataManager.shared

final class EasyCoreDataManager {
    
    static fileprivate let shared = EasyCoreDataManager()
        
    private init() { 
        let bundle = Bundle(for: type(of: self))
        guard let modelURL = bundle.url(forResource: "RatesData", withExtension: "momd") else {
            fatalError("Failed to find model URL")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load model")
        }
        persistentContainer = NSPersistentContainer(name: "RatesData", managedObjectModel: model)
    }
        
    var context: NSManagedObjectContext { persistentContainer.viewContext }

    var backgroundContext: NSManagedObjectContext { persistentContainer.newBackgroundContext() }
    
    private var persistentContainer: NSPersistentContainer
    
    private var isLoadedPersistentStores = false
    
    func loadPersistentStores(completion: ((LoadPersistentStatus) -> Void)? = nil ) {
        guard !isLoadedPersistentStores else {
            completion?(.tryingRepeatLoading)
            return
        }
        // Configure store description before loading
        for desc in persistentContainer.persistentStoreDescriptions {
            desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            desc.shouldMigrateStoreAutomatically = true
            desc.shouldInferMappingModelAutomatically = true
        }
        persistentContainer.loadPersistentStores { [weak self] description, error in
            debugPrint(description)
            guard let error = error else {
                self?.isLoadedPersistentStores = true
                self?.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                self?.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                self?.persistentContainer.viewContext.undoManager = nil
                self?.persistentContainer.viewContext.name = "viewContext"
                completion?(.persistentLoaded)
                return
            }
            completion?(.error)
            debugPrint("Core Data. Error loading: \(error)")
        }
    }
    
    func saveContextAndWait() {
        guard isLoadedPersistentStores else {
            debugPrint("Core Data. Error isLoadedPersistentStores = false")
            return
        }
        guard context.hasChanges else { return }

        context.performAndWait { [unowned self] in
            self.saveContext()
        }
    }
    
    func asyncSaveContext(completion: @escaping (() -> Void)) {
        guard isLoadedPersistentStores else {
            completion()
            debugPrint("Core Data. Error isLoadedPersistentStores = false")
            return
        }
        
        guard context.hasChanges else {
            completion()
            return
        }
        
        context.perform { [unowned self] in
            self.saveContext()
            completion()
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        guard isLoadedPersistentStores else {
            debugPrint("Core Data. Error isLoadedPersistentStores = false")
            return
        }
        persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            context.name = "backgroundContext"
            block(context)
        }
    }
    
    private func saveContext() {
        do {
            try self.context.save()
            debugPrint("Core Data. Save context")
        } catch {
            debugPrint("Core Data. Error saving main context: \(error)")
        }
    }
    
    func fetchFirstObject<T: NSManagedObject>(type: T.Type, predicate: NSPredicate) -> T? {
        guard isLoadedPersistentStores else {
            debugPrint("Core Data. Error isLoadedPersistentStores = false")
            return nil
        }
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: type))
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
    
        var results: T?
        context.performAndWait {
            do {
                results = try context.fetch(fetchRequest).first
            } catch {
                debugPrint("Core Data. Error fetching object: \(error)")
            }
        }
        return results
    }
    
    func fetchObjects<T: NSManagedObject>(type: T.Type, predicate: NSPredicate? = nil) -> [T]? {
        guard isLoadedPersistentStores else {
            debugPrint("Core Data. Error isLoadedPersistentStores = false")
            return nil
        }
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: type))
        fetchRequest.predicate = predicate
        
        var results: [T]?
        context.performAndWait {
            do {
                results = try context.fetch(fetchRequest)
            } catch {
                debugPrint("Core Data. Error fetching object: \(error)")
            }
        }
        return results
    }
    
    func createObject<T: NSManagedObject>(type: T.Type) -> T? {
        guard isLoadedPersistentStores else {
            debugPrint("Core Data. Error isLoadedPersistentStores = false")
            return nil
        }
        let entityName = String(describing: type)
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            debugPrint("Core Data. Failed at creating entity")
            return nil
        }
        let object = NSManagedObject(entity: entity, insertInto: context) as? T
        return object
    }
    
    func deleteObjects<T: NSManagedObject>(type: T.Type, predicate: NSPredicate? = nil) {
        let fetchRequest = type.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                if let objectDelete = object as? NSManagedObject {
                    context.performAndWait {
                        context.delete(objectDelete)
                    }
                }
            }
        }
        catch {
            debugPrint("Core Data. Error deleting objects: \(error)")
        }
    }
    
    func reset() {
        let storeContainer = persistentContainer.persistentStoreCoordinator
        for store in storeContainer.persistentStores {
            do {
                if let url = store.url {
                    try storeContainer.destroyPersistentStore(at: url, ofType: store.type)
                }
            } catch {
                debugPrint("Core Data. Error destroyPersistentStore")
            }
        }
        isLoadedPersistentStores = false
        
        let bundle = Bundle(for: type(of: self))
        guard let modelURL = bundle.url(forResource: "RatesData", withExtension: "momd") else {
            fatalError("Failed to find model URL")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load model")
        }
        persistentContainer = NSPersistentContainer(name: "RatesData", managedObjectModel: model)
        loadPersistentStores { status in
            debugPrint("Core Data. Reloaded new persistent stores with status \(status)")
        }
    }
}

enum LoadPersistentStatus {
    case error
    case persistentLoaded
    case tryingRepeatLoading
}
