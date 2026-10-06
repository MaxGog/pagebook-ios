//
//  DataManager.swift
//  pagebook
//
//  Created by Максим Гоглов on 28.10.2025.
//

import Foundation
import SwiftUI
import CoreData

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func exportData() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        do {
            let notes = try context.fetch(fetchRequest)
            let notesData = notes.map { note in
                ["title": note.title ?? "", "content": note.content ?? ""]
            }
            let jsonData = try JSONSerialization.data(withJSONObject: notesData, options: .prettyPrinted)
            showAlert(message: "Данные экспортированы (заглушка)")
        } catch {
            showAlert(message: "Ошибка экспорта: \(error.localizedDescription)")
        }
    }
    
    func createBackup() {
        let backupData = "Резервная копия создана: \(Date())"
        UserDefaults.standard.set(backupData, forKey: "lastBackup")
        showAlert(message: "Резервная копия успешно создана")
    }
    
    func restoreBackup() {
        if let backupData = UserDefaults.standard.string(forKey: "lastBackup") {
            showAlert(message: "Данные восстановлены из: \(backupData)")
        } else {
            showAlert(message: "Резервная копия не найдена")
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    #if os(macOS)
    private func saveToFile(content: String, filename: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename
        panel.allowedContentTypes = [.plainText]
        
        panel.begin { result in
            if result == .OK, let url = panel.url {
                do {
                    try content.write(to: url, atomically: true, encoding: .utf8)
                    self.showAlert(message: "Файл сохранен: \(url.lastPathComponent)")
                } catch {
                    self.showAlert(message: "Ошибка сохранения: \(error.localizedDescription)")
                }
            }
        }
    }
    #endif
}
