//
//  Note+CoreDataClass.swift
//  Notes
//
//  Created by Anton Vorozhischev on 19.02.2023.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    var title: String {
        return text.trimmingCharacters(in:
                .whitespacesAndNewlines)
                .components(separatedBy: .newlines).first ?? ""
    }

    var content: String {
        var lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        lines.removeFirst()
        return "\(lastUpdated.formatted()) \(lines.first ?? "")"
    }
}
