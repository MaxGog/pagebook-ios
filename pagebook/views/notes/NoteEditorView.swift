//
//  NoteEditView.swift
//  pagebook
//
//  Created by Максим Гоглов on 21.07.2025.
//

import SwiftUI

struct NoteEditorView: View {
    let note: Note?
    let mode: EditorMode
    let onSave: (Note) -> Void
    let onCancel: () -> Void
    
    @State private var editedTitle: String
    @State private var editedContent: String
    @FocusState private var focusedField: Field?
    @Environment(\.colorScheme) private var colorScheme
    
    enum EditorMode {
        case create, edit
    }
    
    private enum Field {
        case title, content
    }
    
    init(note: Note? = nil, mode: EditorMode, onSave: @escaping (Note) -> Void, onCancel: @escaping () -> Void) {
        self.note = note
        self.mode = mode
        self.onSave = onSave
        self.onCancel = onCancel
        self._editedTitle = State(initialValue: note?.title ?? "")
        self._editedContent = State(initialValue: note?.content ?? "")
    }
    
    private var isSaveDisabled: Bool {
        editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var currentNote: Note {
        if let existingNote = note {
            return Note(
                id: existingNote.id,
                title: editedTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                content: editedContent,
                createdAt: existingNote.createdAt,
                updatedAt: Date()
            )
        } else {
            return Note(
                id: UUID(),
                title: editedTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                content: editedContent,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
    }

    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
    }
    
    private var textFieldGlassBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Заголовок")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                        
                        TextField("Название заметки", text: $editedTitle)
                            .focused($focusedField, equals: .title)
                            .submitLabel(.next)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .padding(16)
                            .background(textFieldGlassBackground)
                            .onSubmit {
                                focusedField = .content
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Содержимое")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $editedContent)
                                .focused($focusedField, equals: .content)
                                .frame(minHeight: 300)
                                .font(.body)
                                .padding(16)
                                .background(textFieldGlassBackground)
                                .scrollContentBackground(.hidden)
                            
                            if editedContent.isEmpty {
                                Text("Начните писать здесь...")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 24)
                                    .padding(.leading, 20)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if mode == .edit, let note = note {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Информация")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label {
                                    Text("Создано: \(note.createdAt, style: .date) в \(note.createdAt, style: .time)")
                                        .font(.caption)
                                } icon: {
                                    Image(systemName: "calendar.badge.plus")
                                        .foregroundColor(.blue)
                                }
                                
                                if note.updatedAt != note.createdAt {
                                    Label {
                                        Text("Изменено: \(note.updatedAt, style: .date) в \(note.updatedAt, style: .time)")
                                            .font(.caption)
                                    } icon: {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 24)
            }
        }
        .navigationTitle(mode == .create ? "Новая заметка" : "Редактирование")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена", role: .cancel, action: onCancel)
                    .foregroundColor(.secondary)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    onSave(currentNote)
                }
                .disabled(isSaveDisabled)
                .fontWeight(.semibold)
                .foregroundColor(isSaveDisabled ? .secondary : .accentColor)
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Готово") {
                    focusedField = nil
                }
                .fontWeight(.medium)
            }
        }
        .onAppear {
            if mode == .create {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .title
                }
            }
        }
    }
}
