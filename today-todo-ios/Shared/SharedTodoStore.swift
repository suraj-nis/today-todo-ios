import Foundation
import WidgetKit

// MARK: - SharedTodoStore
//
// Cross-target persistence layer.
// Reads and writes to an App Group UserDefaults suite so both the main app
// and the widget extension see the same data.
//
// WIDGET TARGET SETUP (do once in Xcode):
//   File Inspector → Target Membership:
//     • today-todo-ios/Shared/SharedTodoStore.swift  → ✓ TaskWidgetExtension
//     • today-todo-ios/Models/TodoItem.swift         → ✓ TaskWidgetExtension
//     • today-todo-ios/Services/DateService.swift    → ✓ TaskWidgetExtension
//   Signing & Capabilities → App Groups:
//     • Add "group.codemiracles.today-todo-ios" to both targets
//   Font files in Resources/Fonts/ used by the widget:
//     • Fraunces144pt-Light.ttf, Fraunces144pt-LightItalic.ttf
//     • Geist-Regular.otf, GeistMono-Regular.otf
//     → add to TaskWidgetExtension target + widget Info.plist UIAppFonts

enum SharedTodoStore {

    static let suiteName = "group.codemiracles.today-todo-ios"
    static let storeKey  = "com.today.todos"

    /// Decode all stored todo items from the shared app group.
    /// Returns an empty array on any read or decode failure — never throws.
    static func loadAll() -> [TodoItem] {
        guard
            let defaults = UserDefaults(suiteName: suiteName),
            let data     = defaults.data(forKey: storeKey)
        else { return [] }
        return (try? JSONDecoder().decode([TodoItem].self, from: data)) ?? []
    }

    /// Encode and persist items to the shared app group, then reload all
    /// widget timelines so the widget reflects changes immediately.
    static func save(_ items: [TodoItem]) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: storeKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
