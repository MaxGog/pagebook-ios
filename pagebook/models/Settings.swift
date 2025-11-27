//
//  Settinga.swift
//  pagebook
//
//  Created by Максим Гоглов on 28.10.2025.
//
import SwiftUI
import Combine

class Settings: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var isNotificationsEnabled: Bool = true
    @Published var defaultView: String = "notes"
    @Published var fontSize: Double = 16.0
    @Published var accentColor: String = "Синий"
    
    var accentColorValue: Color {
        switch accentColor {
        case "Синий":
            return .blue
        case "Зеленый":
            return .green
        case "Фиолетовый":
            return .purple
        case "Оранжевый":
            return .orange
        case "Красный":
            return .red
        default:
            return .blue
        }
    }
}
