import SwiftUI

struct TodoListView: View {
    @EnvironmentObject private var state: AppState
    var body: some View {
        NavigationStack {
            List {
                Section("Offen") { ForEach(state.todos.filter { !$0.isDone }) { todo in TodoRow(todo: todo, onToggle: { state.toggle(todo: todo) }) } }
                if state.todos.contains(where: \.isDone) { Section("Erledigt") { ForEach(state.todos.filter(\.isDone)) { todo in TodoRow(todo: todo, onToggle: { state.toggle(todo: todo) }) } } }
            }.scrollContentBackground(.hidden).background(PKTheme.background).navigationTitle("To-dos")
        }
    }
}

struct TodoRow: View {
    let todo: PflegeTodo
    var onToggle: (() -> Void)? = nil
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button { onToggle?() } label: { Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle").font(.title3).foregroundStyle(todo.isDone ? PKTheme.sage : PKTheme.ink) }.buttonStyle(.plain).accessibilityLabel(todo.isDone ? "Als offen markieren" : "Als erledigt markieren")
            VStack(alignment: .leading, spacing: 4) { Text(todo.title).strikethrough(todo.isDone).font(.headline); Text(todo.detail).font(.subheadline).foregroundStyle(.secondary) }
        }.padding(.vertical, 5)
    }
}
