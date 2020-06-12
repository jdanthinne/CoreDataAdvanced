//
//  File.swift
//
//
//  Created by Jérôme Danthinne on 02/06/2020.
//

@_exported import CoreData

extension NSManagedObjectContext {
    /// Only performs a save if there are changes to commit.
    /// - Returns: `true` if a save was needed. Otherwise, `false`.
    @discardableResult public func saveIfNeeded() throws -> Bool {
        guard hasChanges else { return false }
        try save()
        return true
    }
}
