//
//  SettingsView.swift
//  pagebook
//
//  Created by Максим Гоглов on 28.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    @StateObject private var dataManager = DataManager.shared
    @State private var showingResetAlert = false

    let accentColors = ["Синий", "Зеленый", "Фиолетовый", "Оранжевый", "Красный"]
    
    var body: some View {
        List {
            Section {
                Toggle("Темная тема", isOn: $settings.isDarkMode)
                
                NavigationLink {
                    AccentColorPickerView(selectedColor: $settings.accentColor, colors: accentColors)
                } label: {
                    HStack {
                        Text("Акцентный цвет")
                        Spacer()
                        Text(settings.accentColor)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Размер шрифта")
                        Spacer()
                        Text("\(Int(settings.fontSize))")
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Внешний вид")
            } footer: {
                Text("Изменения повлияют на все элементы интерфейса")
            }

            Section {
                Toggle("Уведомления", isOn: $settings.isNotificationsEnabled)
                
                if settings.isNotificationsEnabled {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        HStack {
                            Text("Настройки уведомлений")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                }
            } header: {
                Text("Уведомления")
            } footer: {
                Text("Получайте напоминания о задачах и событиях")
            }

            Section {
                Button {
                    dataManager.exportData()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("Экспорт данных")
                        Spacer()
                    }
                }
                .foregroundColor(.primary)
                
                Button {
                    dataManager.createBackup()
                } label: {
                    HStack {
                        Image(systemName: "externaldrive.badge.plus")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        Text("Резервное копирование")
                        Spacer()
                    }
                }
                .foregroundColor(.primary)
                
                Button {
                    dataManager.restoreBackup()
                } label: {
                    HStack {
                        Image(systemName: "externaldrive.badge.arrow.down")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        Text("Восстановить из резервной копии")
                        Spacer()
                    }
                }
                .foregroundColor(.primary)
            } header: {
                Text("Данные")
            } footer: {
                Text("Управляйте вашими данными и создавайте резервные копии")
            }

            Section {
                HStack {
                    Text("Версия")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundColor(.secondary)
                }
                
                NavigationLink {
                    LicensesView()
                } label: {
                    HStack {
                        Text("Лицензии")
                        Spacer()
                    }
                }
                
                Link(destination: URL(string: "https://apple.com")!) {
                    HStack {
                        Text("Политика конфиденциальности")
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
                
                Link(destination: URL(string: "https://apple.com")!) {
                    HStack {
                        Text("Условия использования")
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
            } header: {
                Text("О приложении")
            }

            Section {
                Button(role: .destructive) {
                    showingResetAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Сбросить настройки")
                        Spacer()
                    }
                }
            } footer: {
                Text("Все настройки будут возвращены к значениям по умолчанию. Это действие нельзя отменить.")
            }
        }
        .navigationTitle("Настройки")
        .accentColor(settings.accentColorValue)
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        .font(.system(size: settings.fontSize))
        .alert("Сбросить настройки?", isPresented: $showingResetAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Сбросить", role: .destructive) {
                resetSettings()
            }
        } message: {
            Text("Все настройки будут возвращены к значениям по умолчанию. Это действие нельзя отменить.")
        }
        .alert("Уведомление", isPresented: $dataManager.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(dataManager.alertMessage)
        }
        .accentColor(settings.accentColorValue)
    }
    
    private func resetSettings() {
        settings.isDarkMode = false
        settings.isNotificationsEnabled = true
        settings.defaultView = "notes"
        settings.fontSize = 16.0
        settings.accentColor = "Синий"
    }
}

struct AccentColorPickerView: View {
    @Binding var selectedColor: String
    let colors: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                ForEach(colors, id: \.self) { color in
                    HStack {
                        Text(color)
                        Spacer()
                        if selectedColor == color {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                                .fontWeight(.medium)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedColor = color
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("Акцентный цвет")
    }
}


