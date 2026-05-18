import Foundation

protocol TodoRepositoryProtocol {
    func loadAll() -> [TodoItem]
    func save(_ items: [TodoItem])
}
