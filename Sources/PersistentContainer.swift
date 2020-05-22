//
//  CoreDataAdvanced.swift
//  CoreDataAdvanced
//
//  Created by Jérôme Danthinne on 5 août 2019.
//  Copyright © 2019 Grincheux. All rights reserved.
//

@_exported import CoreData

@available(iOS 10.0, *)
extension NSPersistentStore {
    /// Create the app main context.
    ///
    /// - Parameters:
    ///   - modelName: name of the CoreData model
    ///   - applicationGroupIdentifier: optional application group identifier
    ///   - usingCloudKit: If true, uses NSPersistentCloudKitContainer
    ///   - isInMemory: if true, creates an in-memory context
    /// - Returns: the created NSPersistentStore
    public static func create(modelName: String,
                              applicationGroupIdentifier: String? = nil,
                              usingCloudKit: Bool = false,
                              isInMemory: Bool = false)
        -> NSManagedObjectContext {
        let container: NSPersistentContainer
        if usingCloudKit, #available(iOS 13.0, *) {
            let cloudKitContainer = NSPersistentCloudKitContainer(name: modelName)
            #if DEBUG
                try! cloudKitContainer.initializeCloudKitSchema()
            #endif
            container = cloudKitContainer
        } else {
            container = NSPersistentContainer(name: modelName)
        }

        var storeDescription: NSPersistentStoreDescription?
        if isInMemory {
            storeDescription = NSPersistentStoreDescription()
            storeDescription?.type = NSInMemoryStoreType
            storeDescription?.shouldAddStoreAsynchronously = false
        } else if let groupIdentifier = applicationGroupIdentifier {
            guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
                fatalError("Shared file container could not be created.")
            }
            let storeURL = fileContainer.appendingPathComponent("\(modelName).sqlite")
            storeDescription = NSPersistentStoreDescription(url: storeURL)
        }
        if let description = storeDescription {
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                NSLog("CoreData initialization error: \(error)")
            } else {
                print("CoreData initialized with description: \(description)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }
}
