import Foundation
import Observation

extension Notification.Name {
    static let archiveDidUpdate = Notification.Name("archiveDidUpdate")
}

@Observable
final class ArchiveViewModel {

    @ObservationIgnored private let archiveRepository: ArchiveRepositoryProtocol

    private(set) var archivedDays: [ArchivedDay] = []

    init(archiveRepository: ArchiveRepositoryProtocol = UserDefaultsArchiveRepository()) {
        self.archiveRepository = archiveRepository
        refresh()
        NotificationCenter.default.addObserver(
            forName: .archiveDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
    }

    func refresh() {
        archivedDays = archiveRepository.loadAll()
            .sorted { $0.date > $1.date }
    }
}
