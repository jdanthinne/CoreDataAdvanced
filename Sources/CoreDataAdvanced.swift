//
//  CoreDataAdvanced.swift
//  CoreDataAdvanced
//
//  Created by Jérôme Danthinne on 5 août 2019.
//  Copyright © 2019 Grincheux. All rights reserved.
//

// Include Foundation
@_exported import Foundation
import CoreData
import UIKit

open class ManagedObject: NSManagedObject {}

public protocol ManagedObjectContextSettable: AnyObject {
    var managedObjectContext: NSManagedObjectContext! { get set }
}

public extension ManagedObjectContextSettable {
    func injectManagedObjectContext(in segue: UIStoryboardSegue) {
        if let vc = segue.destination as? ManagedObjectContextSettable {
            vc.managedObjectContext = managedObjectContext
        }
    }
}

public extension NSManagedObjectContext {
    static func createMainContext(with models: [AnyClass],
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
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                    configurationName: nil,
                                    at: storeURL,
                                    options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        return context
    }
    
    func inject(in viewController: UIViewController) {
        guard let vc = viewController as? ManagedObjectContextSettable
            else { fatalError("Unable to set \(viewController) as ManagedObjectContextSettable") }
        vc.managedObjectContext = self
    }
}
