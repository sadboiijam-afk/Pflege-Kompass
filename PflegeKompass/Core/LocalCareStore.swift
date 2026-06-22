import Foundation

protocol CareProfileStoring {
    func loadProfile() -> Pflegeprofil?
    func saveProfile(_ profile: Pflegeprofil?)
    func loadTodos() -> [PflegeTodo]
    func saveTodos(_ todos: [PflegeTodo])
}

final class LocalCareStore: CareProfileStoring {
    private let defaults = UserDefaults.standard
    private enum Key { static let profile = "pflegeprofil"; static let todos = "pflegetodos" }

    func loadProfile() -> Pflegeprofil? { decode(Pflegeprofil.self, key: Key.profile) }
    func saveProfile(_ profile: Pflegeprofil?) { save(profile, key: Key.profile) }
    func loadTodos() -> [PflegeTodo] { decode([PflegeTodo].self, key: Key.todos) ?? [] }
    func saveTodos(_ todos: [PflegeTodo]) { save(todos, key: Key.todos) }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    private func save<T: Encodable>(_ value: T?, key: String) {
        guard let value else { defaults.removeObject(forKey: key); return }
        defaults.set(try? JSONEncoder().encode(value), forKey: key)
    }
}

/// Future seam only. Do not place Supabase keys or service-role credentials in the app target.
struct SupabaseSyncConfiguration {
    let projectURL: URL
    let publishableKey: String
    // TODO(Supabase): Implement opt-in sync only after authentication, private storage and owner-based RLS policies are reviewed.
}
