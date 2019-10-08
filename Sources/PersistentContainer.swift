//
//  CoreDataAdvanced.swift
//  CoreDataAdvanced
//
//  Created by Jérôme Danthinne on 5 août 2019.
//  Copyright © 2019 Grincheux. All rights reserved.
//

@_exported import CoreData

@available(iOS 10.0, *)
final class PersistentContainer: NSPersistentContainer {
    static var applicationGroupIdentifier: String?

    init(models: [AnyClass], name: String, applicationGroupIdentifier: String?) {
        PersistentContainer.applicationGroupIdentifier = applicationGroupIdentifier
        guard let model = NSManagedObjectModel.mergedModel(from: models.map { Bundle(for: $0) })
        else { fatalError("Unable to create CoreData models") }

        super.init(name: name, managedObjectModel: model)
    }

    override class func defaultDirectoryURL() -> URL {
        var url = super.defaultDirectoryURL()
        if let groupIdentifier = applicationGroupIdentifier,
            let newURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: groupIdentifier
            ) {
            url = newURL
        }

        return url
    }
}

@available(iOS 10.0, *)
extension NSManagedObjectContext {
    /// Create the app main context.
    ///
    /// - Parameters:
    ///   - models: list of model classes
    ///   - modelName: name of the CoreData model
    ///   - applicationGroupIdentifier: optional application group identifier
    ///   - isInMemory: if true, creates an in-memory context
    /// - Returns: the created NSManagedObjectContext
    public static func createMainContext(with models: [AnyClass],
                                         modelName: String,
                                         applicationGroupIdentifier: String? = nil,
                                         isInMemory: Bool = false)
        -> NSManagedObjectContext {
        let container = PersistentContainer(models: models,
                                            name: modelName,
                                            applicationGroupIdentifier: applicationGroupIdentifier)

        if isInMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                NSLog("CoreData initialization error: \(error)")
            } else {
                print("CoreData initialized with description: \(description)")
            }
        })

        return container.viewContext
    }
}
