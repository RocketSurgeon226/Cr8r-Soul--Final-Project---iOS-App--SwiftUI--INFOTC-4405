//
//  Cr8rSoulApp.swift
//  Final_Cra8r_Soul
//
//  Created by user287268 on 4/28/26.
//

import SwiftUI
import CoreData

// MARK: - App Front Page

@main
struct Cr8rSoulApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}

// MARK: - Persistence Controller

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Final_Cr8r_Soul2")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    @MainActor static var preview: PersistenceController = {
        let c = PersistenceController(inMemory: true)
        let ctx = c.container.viewContext
        let r = RecordEntity(context: ctx)
        r.id = UUID()
        r.title = "Illmatic"
        r.artist = "Nas"
        r.year = 1994
        r.genre = "Hip-Hop"
        r.subgenre = "Boom Bap"
        r.format = "Vinyl"
        r.label = "Columbia"
        r.elements = ["Water", "Earth"]
        r.isOwned = true
        r.isFavorite = true
        r.rating = 5
        r.linerNotes = "A cornerstone. Every track essential."
        r.dateAdded = Date()
        try? ctx.save()
        return c
    }()
}
