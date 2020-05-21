//
//  CoreDataAdvanced.swift
//  CoreDataAdvanced
//
//  Created by Jérôme Danthinne on 5 août 2019.
//  Copyright © 2019 Grincheux. All rights reserved.
//

@_exported import CoreData

open class ManagedObject: NSManagedObject {}

public protocol ManagedObjectType: AnyObject {
    associatedtype Entity: ManagedObject

    static var entityName: String { get }
    static var defaultPredicate: NSPredicate? { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension ManagedObjectType {
    public static var defaultPredicate: NSPredicate? {
        nil
    }

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        []
    }

    public static var defaultFetchRequest: NSFetchRequest<Entity> {
        let request = NSFetchRequest<Entity>(entityName: entityName)
        request.predicate = defaultPredicate
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}
