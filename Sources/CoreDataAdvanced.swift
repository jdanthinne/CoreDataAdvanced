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
import UIKit

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
    public func injectManagedObjectContext(in segue: UIStoryboardSegue) {
        if let viewController = segue.destination as? ManagedObjectContextSettable {
            viewController.managedObjectContext = managedObjectContext
        }
    }
}

extension NSManagedObjectContext {
    /// Create the app main context.
    ///
    /// - Parameters:
    ///   - models: list of model classes
    ///   - filename: filename of the file written to disk
    ///   - directory: where the file will be written
    /// - Returns: the created NSManagedObjectContext
    public static func createMainContext(with models: [AnyClass],
                                  filename: String,
                                  in directory: FileManager.SearchPathDirectory = .documentDirectory)
        -> NSManagedObjectContext {
            let bundles = models.map { Bundle(for: $0) }
            
            guard let model = NSManagedObjectModel.mergedModel(from: bundles)
                else { fatalError("model not found") }
            
            let storeURL = FileManager.default
                .urls(for: directory, in: .userDomainMask)
                .first?
                .appendingPathComponent(filename)
            
            let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
            
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                           configurationName: nil,
                                           at: storeURL,
                                           options: nil)
                let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                context.persistentStoreCoordinator = psc
                
                return context
            } catch {
                fatalError("Unable to add Persistent Store: \(error)")
            }
    }
    
    /// Pass the current object context to a view controller.
    ///
    /// - Parameter viewController: the view controller that will receive the context
    public func inject(in viewController: UIViewController?) {
        guard let viewController = viewController
            else { return }
        
        guard let viewControllerToInject = viewController as? ManagedObjectContextSettable
            else { fatalError("Unable to set \(viewController) as ManagedObjectContextSettable") }
        
        viewControllerToInject.managedObjectContext = self
    }
}
