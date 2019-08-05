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

public class ManagedObject: NSManagedObject {}

protocol ManagedObjectContextSettable: AnyObject {
    var managedObjectContext: NSManagedObjectContext! { get set }
}
