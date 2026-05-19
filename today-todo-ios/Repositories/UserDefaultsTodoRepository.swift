import Foundation

struct UserDefaultsTodoRepository: TodoRepositoryProtocol {

    // MARK: - TodoRepositoryProtocol

    func loadAll() -> [TodoItem] {
        SharedTodoStore.loadAll()
    }

    func save(_ items: [TodoItem]) {
        SharedTodoStore.save(items)
    }
}
