//
//  CoreDataAdvanced.swift
//  CoreDataAdvanced
//
//  Created by Jérôme Danthinne on 5 août 2019.
//  Copyright © 2019 Grincheux. All rights reserved.
//

import CloudKit
@_exported import CoreData

@available(iOS 10.0, *)
extension NSPersistentContainer {
    /// Create the app main context.
    ///
    /// - Parameters:
    ///   - modelName: name of the CoreData model
    ///   - applicationGroupIdentifier: optional application group identifier
    ///   - cloudKitContainerIdentifier: If provided, uses NSPersistentCloudKitContainer
    ///   - isInMemory: if true, creates an in-memory context
    /// - Returns: the created NSPersistentContainer
    public static func create(modelName: String,
                              applicationGroupIdentifier: String? = nil,
                              cloudKitContainerIdentifier: String? = nil,
                              isInMemory: Bool = false)
        -> NSPersistentContainer {
        let container: NSPersistentContainer
        if #available(iOS 13.0, *), cloudKitContainerIdentifier != nil {
            let cloudKitContainer = NSPersistentCloudKitContainer(name: modelName)
            container = cloudKitContainer
        } else {
            container = NSPersistentContainer(name: modelName)
        }

        let storeDescription: NSPersistentStoreDescription
        if isInMemory {
            storeDescription = NSPersistentStoreDescription()
            storeDescription.type = NSInMemoryStoreType
            storeDescription.shouldAddStoreAsynchronously = false
        } else {
            let storeDirectory: URL
            if let groupIdentifier = applicationGroupIdentifier {
                guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
                    fatalError("Shared file container could not be created.")
                }
                storeDirectory = fileContainer
            } else {
                guard let documentsFolder = FileManager.default.urls(for: .applicationSupportDirectory,
                                                                     in: .userDomainMask).first
                else {
                    fatalError("Unable to get documents directory")
                }
                storeDirectory = documentsFolder
            }
            let storeURL = storeDirectory.appendingPathComponent("\(modelName).sqlite")
            storeDescription = NSPersistentStoreDescription(url: storeURL)
        }

        if #available(iOS 13.0, *),
            let cloudKitContainerIdentifier = cloudKitContainerIdentifier {
            storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitContainerIdentifier)
        }

        if #available(iOS 11.0, *) {
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }

        container.persistentStoreDescriptions = [storeDescription]

        container.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                NSLog("CoreData initialization error: \(error)")
            } else {
                print("CoreData initialized with description: \(description)")
            }
        })

        if #available(iOS 13.0, *) {
            #if DEBUG
                if let cloudKitContainer = container as? NSPersistentCloudKitContainer {
                    CKContainer.default().accountStatus { status, _ in
                        print("iCloud status", status)
                        if status == .available {
                            try! cloudKitContainer.initializeCloudKitSchema()
                        }
                    }
                }

            #endif
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }
}
