//
//  ClimbBuddyApp.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 1/23/24.
//

import SwiftUI
import CoreData

@main
struct ClimbBuddyApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "APPDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                //                fatalError("Unresolved error \(error), \(error.userInfo)")
                print(error.localizedDescription)
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
