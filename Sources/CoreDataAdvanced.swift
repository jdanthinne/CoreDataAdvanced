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
#else
import UIKit
#endif

open class ManagedObject: NSManagedObject {}

public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension ManagedObjectType {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    public static var defaultFetchRequest: NSFetchRequest<ManagedObject> {
        let request = NSFetchRequest<ManagedObject>(entityName: entityName)
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
        if let viewController = segue.destinationController as? ManagedObjectContextSettable {
            viewController.managedObjectContext = managedObjectContext
        }
    }
    #else
    public func injectManagedObjectContext(in segue: UIStoryboardSegue) {
        if let viewController = segue.destination as? ManagedObjectContextSettable {
            viewController.managedObjectContext = managedObjectContext
        }
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
    /// - Returns: the created NSManagedObjectContext
    public static func createMainContext(with models: [AnyClass],
                                         modelName: String,
                                         applicationGroupIdentifier: String?)
        -> NSManagedObjectContext {
            let container = PersistentContainer(models: models,
                                                name: modelName,
                                                applicationGroupIdentifier: applicationGroupIdentifier)
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error {
                    NSLog("CoreData initialization error: \(error)")
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
        
        guard let viewControllerToInject = viewController as? ManagedObjectContextSettable
            else { fatalError("Unable to set \(viewController) as ManagedObjectContextSettable") }
        
        viewControllerToInject.managedObjectContext = self
    }
    #else
    public func inject(in viewController: UIViewController?) {
        guard let viewController = viewController
            else { return }
        
        guard let viewControllerToInject = viewController as? ManagedObjectContextSettable
            else { fatalError("Unable to set \(viewController) as ManagedObjectContextSettable") }
        
        viewControllerToInject.managedObjectContext = self
    }
    #endif
}
