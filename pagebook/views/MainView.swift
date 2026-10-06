//
//  MainView.swift
//  pagebook
//
//  Created by Максим Гоглов on 13.07.2025.
//
import SwiftUI

struct MainView: View {
    @State private var selectedSection: Section? = .notes
    @EnvironmentObject var settings: Settings
    
    enum Section: String, CaseIterable, Identifiable {
        case notes = "Заметки"
        case tasks = "Задачи"
        case calendar = "Календарь"
        case settings = "Настройки"
        
        var id: String { self.rawValue }
        
        var iconName: String {
            switch self {
            case .notes: return "note.text"
            case .tasks: return "checklist"
            case .calendar: return "calendar"
            case .settings: return "gear"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(Section.allCases, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.iconName)
                    .tag(section)
            }
            .navigationTitle("Pagebook")
        } detail: {
            if let section = selectedSection {
                detailView(for: section)
                    .navigationTitle(section.rawValue)
            } else {
                Text("Выберите раздел")
                    .foregroundColor(.secondary)
            }
        }
        .accentColor(settings.accentColorValue)
    }
    
    @ViewBuilder
    private func detailView(for section: Section) -> some View {
        switch section {
        case .notes:
            NotesView()
        case .tasks:
            TasksView()
        case .calendar:
            CalendarView()
        case .settings:
            SettingsView()
        }
    }
}
