//
//  CoreDataAdvanced.swift
//  CoreDataAdvanced
//
//  Created by Jérôme Danthinne on 5 août 2019.
//  Copyright © 2019 Grincheux. All rights reserved.
//

// Include Foundation
@_exported import CoreData
@_exported import Foundation
#if os(OSX)
import AppKit
#elseif !os(watchOS)
import UIKit
#endif

open class ManagedObject: NSManagedObject {}

public protocol ManagedObjectType: class {
    associatedtype Entity: ManagedObject
    
    static var entityName: String { get }
    static var defaultPredicate: NSPredicate? { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension ManagedObjectType {
    public static var defaultPredicate: NSPredicate? {
        return nil
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    public static var defaultFetchRequest: NSFetchRequest<Entity> {
        let request = NSFetchRequest<Entity>(entityName: entityName)
        request.predicate = defaultPredicate
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}

public protocol ManagedObjectContextSettable: AnyObject {
    var managedObjectContext: NSManagedObjectContext! { get set }
}

extension ManagedObjectContextSettable {
    /// Pass the current object context to the destination view controller of the segue.
    ///
    /// - Parameter segue: the invoked segue
    #if os(OSX)
    public func injectManagedObjectContext(in segue: NSStoryboardSegue) {
        managedObjectContext.inject(in: segue.destinationController as? NSViewController)
    }
    #elseif !os(watchOS)
    public func injectManagedObjectContext(in segue: UIStoryboardSegue) {
        managedObjectContext.inject(in: segue.destination)
    }
    #endif
}

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
                forSecurityApplicationGroupIdentifier: groupIdentifier) {
            url = newURL
        }
        
        return url
    }
}

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
    
    /// Pass the current object context to a view controller.
    ///
    /// - Parameter viewController: the view controller that will receive the context
    #if os(OSX)
    public func inject(in viewController: NSViewController?) {
        guard let viewController = viewController
            else { return }
        
        if let viewControllerToInject = viewController as? ManagedObjectContextSettable {
            viewControllerToInject.managedObjectContext = self
        }
    }
    #elseif !os(watchOS)
    public func inject(in viewController: UIViewController?) {
        guard let viewController = viewController
            else { return }
        
        if let viewControllerToInject = viewController as? ManagedObjectContextSettable {
            viewControllerToInject.managedObjectContext = self
        }
        
        if let navigationController = viewController as? UINavigationController,
            let viewControllerToInject = navigationController.viewControllers.first as? ManagedObjectContextSettable {
            viewControllerToInject.managedObjectContext = self
        }
    }
    #endif
}
