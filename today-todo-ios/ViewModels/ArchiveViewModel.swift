import Foundation
import Observation

@Observable
final class ArchiveViewModel {
    /// Past tasks grouped by dayKey ("yyyy-MM-dd"), sorted newest first.
    var groupedDays: [(key: String, tasks: [TodoItem])] = []
}
