//
//  Note+CoreDataProperties.swift
//  Notes
//
//  Created by Anton Vorozhischev on 19.02.2023.
//
//

import Foundation
import CoreData

extension Note {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: UUID!
    @NSManaged public var lastUpdated: Date!
    @NSManaged public var text: String!
}
