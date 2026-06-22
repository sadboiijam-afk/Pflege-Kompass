import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var profile: Pflegeprofil?
    @Published private(set) var todos: [PflegeTodo]

    private let store: CareProfileStoring
    private let engine: EntitlementEvaluating

    init(store: CareProfileStoring = LocalCareStore(), engine: EntitlementEvaluating = EntitlementEngine()) {
        self.store = store
        self.engine = engine
        self.profile = store.loadProfile()
        self.todos = store.loadTodos()
    }

    var benefits: [BenefitResult] { profile.map { engine.evaluate(profile: $0) } ?? [] }

    func save(profile: Pflegeprofil) {
        self.profile = profile
        store.saveProfile(profile)
        let generatedTodos = makeStarterTodos(for: profile)
        todos = generatedTodos
        store.saveTodos(generatedTodos)
    }

    func startDemo() { save(profile: .demo) }

    func toggle(todo: PflegeTodo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].isDone.toggle()
        store.saveTodos(todos)
    }

    func addDocumentTodo(title: String, detail: String) {
        let todo = PflegeTodo(id: UUID(), title: title, detail: detail, dueDate: nil, isDone: false, origin: .document)
        todos.insert(todo, at: 0)
        store.saveTodos(todos)
    }

    func resetAllData() {
        profile = nil
        todos = []
        store.saveProfile(nil)
        store.saveTodos([])
    }

    private func makeStarterTodos(for profile: Pflegeprofil) -> [PflegeTodo] {
        var items = [
            todo("Bescheid sicher ablegen", "Pflegegrad, Datum und Hinweise im Original prüfen."),
            todo("Pflegekasse kontaktieren", "Offene Fragen und mögliche nächste Schritte für diese Situation klären."),
            todo("Alltagssituation notieren", "Beispiele für benötigte Hilfe im Alltag festhalten."),
            todo("Unterlagen-Ordner anlegen", "Bescheid, Briefe, Rechnungen und Gesprächsnotizen an einem Ort sammeln."),
            todo("Pflegeberatung anfragen", "Eine Beratung kann helfen, die nächsten Schritte verständlich zu sortieren.")
        ]

        if profile.pflegeort == .zuhause {
            items.append(todo("Entlastung im Alltag prüfen", "Anerkannte Angebote und den Ablauf mit der Pflegekasse prüfen."))
            if profile.versorgungssetup == .angehoerige || profile.versorgungssetup == .gemischt {
                items.append(todo("Vertretung mitdenken", "Für Ausfälle oder Pausen frühzeitig mögliche Unterstützung prüfen."))
            }
        } else if profile.pflegeort == .krankenhausEntlassung {
            items.append(todo("Entlassung abstimmen", "Sozialdienst, Pflegekasse und Angehörige zu den nächsten Versorgungsschritten zusammenbringen."))
        }
        return items
    }

    private func todo(_ title: String, _ detail: String) -> PflegeTodo {
        PflegeTodo(id: UUID(), title: title, detail: detail, dueDate: nil, isDone: false, origin: .starter)
    }
}

final class PreviewCareStore: CareProfileStoring {
    private var profile: Pflegeprofil?
    private var todos = [PflegeTodo]()
    func loadProfile() -> Pflegeprofil? { profile }
    func saveProfile(_ profile: Pflegeprofil?) { self.profile = profile }
    func loadTodos() -> [PflegeTodo] { todos }
    func saveTodos(_ todos: [PflegeTodo]) { self.todos = todos }
}

extension AppState {
    static var preview: AppState {
        let state = AppState(store: PreviewCareStore())
        state.startDemo()
        return state
    }
}
