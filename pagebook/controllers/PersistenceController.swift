//
//  PersistenceController.swift
//  pagebook
//
//  Created by Максим Гоглов on 06.10.2026.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "PagebookModel")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

extension PersistenceController {
    func migrateDataFromUserDefaultsIfNeeded() {
        let migrationKey = "didMigrateToCoreData_v2"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        let context = container.viewContext

        if let data = UserDefaults.standard.data(forKey: "notes"),
           let notes = try? JSONDecoder().decode([Note].self, from: data) {
            for note in notes {
                let newNote = NoteEntity(context: context)
                newNote.id = note.id
                newNote.title = note.title
                newNote.content = note.content
                newNote.createdAt = note.createdAt
                newNote.updatedAt = note.updatedAt
            }
        }

        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let tasks = try? JSONDecoder().decode([TaskItem].self, from: data) {
            for task in tasks {
                let newTask = TaskItemEntity(context: context)
                newTask.id = task.id
                newTask.title = task.title
                newTask.isCompleted = task.isCompleted
                newTask.dueDate = task.dueDate
                newTask.priority = Int16(task.priority.rawValue)
            }
        }

        if let data = UserDefaults.standard.data(forKey: "events"),
           let events = try? JSONDecoder().decode([CalendarEvent].self, from: data) {
            for event in events {
                let newEvent = CalendarEventEntity(context: context)
                newEvent.id = event.id
                newEvent.title = event.title
                newEvent.descriptionText = event.description
                newEvent.date = event.date
                newEvent.duration = event.duration
            }
        }

        try? context.save()
        UserDefaults.standard.set(true, forKey: migrationKey)
    }
}

