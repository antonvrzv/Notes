//
//  CoreDataManager.swift
//  Notes
//
//  Created by Anton Vorozhischev on 19.02.2023.
//

import Foundation
import CoreData


class CoreDataManager {
    static let shared = CoreDataManager(modelName: "Notes")
    
    let persistantContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    func loadPersistantStores(completion: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores {
            (descripton, err) in
            guard err == nil else {
                fatalError(err!.localizedDescription)
            }

            completion?()
        }
    }
    
    func saveContextToStore() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Saving view context failed")
            }
        }
    }
}

//MARK - Helper Methods
extension CoreDataManager {
    func createNoteInViewContext() -> Note {
        let note = Note(context: CoreDataManager.shared.viewContext)
        note.id = UUID()
        note.text = ""
        note.lastUpdated = Date()

        return note
    }
    
    func fetchNotes(filter: String? = nil) -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let desc = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [desc]
        
        if let filter = filter {
            let predicate = NSPredicate(format: "text contains[cd] %@", filter)
            request.predicate = predicate
        }
        
        return (try? viewContext.fetch(request)) ?? []
    }
    
    func deleteNoteFromStorage(_ note: Note) {
        viewContext.delete(note)
        saveContextToStore()
    }

}
