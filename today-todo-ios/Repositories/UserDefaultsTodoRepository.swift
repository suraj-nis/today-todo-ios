import Foundation

struct UserDefaultsTodoRepository: TodoRepositoryProtocol {

    private let key = "com.today.todos"
    private let store: UserDefaults

    init(store: UserDefaults = .standard) {
        self.store = store
    }

    // MARK: - TodoRepositoryProtocol

    func loadAll() -> [TodoItem] {
        guard let data = store.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ items: [TodoItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            store.set(data, forKey: key)
        } catch {
            // Encoding failure is non-fatal; in-memory state remains valid.
        }
    }
}
