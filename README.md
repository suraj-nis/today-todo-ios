# Today.

*A daily task app with one rule — tasks only live for today.*

Today. is a minimal iOS todo app built around a single constraint: tasks belong to the current day and reset automatically at midnight. There are no backlogs, no overdue items, no future scheduling — just what matters right now. A separate Archive tab lets you look back at past days if you choose, but the default experience is always a clean slate. The app is fully offline, requires no account, and was built with SwiftUI and MVVM architecture.

---

## Demo

Demo - https://youtube.com/shorts/8rs9QgtQQ14

## Screenshots

### Today View — Morning · Midday · Evening

<img width="963" height="601" alt="Screenshot 2026-05-21 at 8 07 01 PM" src="https://github.com/user-attachments/assets/bc1d5028-db20-4067-be11-781641164bfd" />

The background shifts with the time of day — a warm apricot in the morning, a cool neutral at midday, and a deep terracotta at sunset. This is not just aesthetic: the color change gives the user a passive sense of urgency as the day progresses, reinforcing the app's core constraint that tasks only exist today. The header copy changes too — "A clean slate. Begin gently." in the morning becomes a live task count by midday and "The day softens. An hour remains until midnight." by evening.

### Archive View — Morning · Midday · Evening

<img width="905" height="589" alt="Screenshot 2026-05-21 at 8 07 11 PM" src="https://github.com/user-attachments/assets/4b60296c-f86d-4088-8a7e-7271aac905a2" />


The Archive tab inherits the same time-of-day background as the Today tab so the experience feels continuous rather than jarring when switching tabs. Past days are grouped by name with completed tasks shown with strikethrough and tasks that expired untouched labeled "— EXPIRED UNTOUCHED" so the record is honest about what got done and what didn't.

## Overall Approach

### Design → Code

Before writing any Swift I designed the entire app in Claude Design, producing a complete design system: full light and dark color palettes, a typography scale using Fraunces serif and Geist sans, a 4pt spacing grid, corner radii, shadow levels, and a full animation spec with named easing curves. This was exported as `Today.html` and `tokens.js` and placed in a `DesignExport/` folder at the project root.

Rather than jumping straight into code I then created a `CONTEXT.md` file at the project root — a persistent briefing document that every Claude Code session reads before touching any file. It contains the full MVVM architecture spec, folder structure, hard UI rules, animation choreography, the design system quick reference, and explicit agent behavior rules. This solved the core problem of Claude Code having no memory between sessions — it is the equivalent of onboarding a new engineer with full project context before they write a line of code.

The DesignSystem folder translates the web tokens from Claude Design into native SwiftUI: `Colors.swift` with all semantic tokens and time-of-day gradients, `Typography.swift` with a `.todayStyle()` ViewModifier that bundles font, tracking, and line spacing in one call, `Spacing.swift` with an 11-step 4pt scale, `Radii.swift`, `Shadows.swift`, and `Animation+Today.swift` with named sequences for task completion and sheet presentation. A separate `AppConstants.swift` holds layout-specific values. Component sizes use `@ScaledMetric` throughout so the UI adapts with Dynamic Type rather than using fixed values.

### Models

Models are plain Codable structs with no UI imports. `TodoItem` carries an id, title, completion state, creation date, day key (a `yyyy-MM-dd` string used to bucket tasks by day), optional expiry time, and optional completion timestamp. `ArchivedDay` carries a date, day name, date label, and the array of tasks from that day. Keeping models pure means they serialize cleanly to UserDefaults and can be read by both the main app and the widget target without any shared framework.

### ViewModels

ViewModels own all state and business logic. `TodayViewModel` handles task sorting (expiring soonest → non-expiring → completed → expired), the add/delete/toggle actions, time-of-day gradient selection, dynamic header copy, the midnight day reset, and exact expiry timers that fire a SwiftUI redraw at the precise moment a task expires. `ArchiveViewModel` is intentionally read-only — it loads and sorts archived days from the repository and exposes them to the view with no mutation methods. Both ViewModels inject their dependencies via protocol so any service or repository can be swapped for a mock in tests or previews.

All date logic lives exclusively in `DateService` behind a protocol. ViewModels and Views never call `Date()` directly. This means a `MockDateService` with a fixed date can be injected to test any time-of-day state, and a `TodayPreviews.swift` file in `Preview Content/` shows all six app states simultaneously (Morning Empty, Morning With Tasks, Midday Empty, Midday With Tasks, Evening Empty, Evening With Tasks) by injecting the mock at 8am, 1pm, and 7pm. Any UI change is immediately visible across all states without changing device time.

### Persistence — UserDefaults

I chose UserDefaults over SwiftData or CoreData deliberately. The data model is a simple array of small structs — there is no querying, no relationships, and no need for migrations. UserDefaults with JSON encoding is sufficient, simpler, and avoids the iOS 17 requirement of SwiftData. The repository pattern (`TodoRepositoryProtocol`, `ArchiveRepositoryProtocol`) means this is a one-file swap if persistence needs to change. Both repositories write to a shared App Group (`group.codemiracles.today-todo-ios`) so the widget target reads the same data as the main app.

### Day Reset

Rather than a midnight timer — which is unreliable if the app is killed or the device sleeps — the day reset is triggered by `ScenePhase.active` and a cold launch check in `TodayViewModel.init()`. Every time the app foregrounds it checks whether any tasks belong to a previous day and if so archives them and clears the active list. This covers every real-world case with zero timer complexity. `performDayReset()` is idempotent — a duplicate check in the archive repository prevents the same day being archived twice regardless of how many times the reset fires.

### Haptics

`HapticService` wraps UIKit's haptic generators as a single-responsibility service injected into ViewModels. Task completion fires a success notification haptic at the exact moment the circle fills, matching the animation spec. Adding a task fires a soft impact when the row enters the list. Deleting fires a warning impact.

### Widgets

The app includes both a small and medium home screen widget built with WidgetKit. The small widget shows the incomplete task count and progress. The medium widget shows the count on the left and up to four tasks on the right with completion state, strikethrough, and expiry times. The timeline refreshes at midnight for the day reset and instantly on any task mutation via `WidgetCenter.shared.reloadAllTimelines()` called after every save — no polling needed.

---

## Key Decisions and Tradeoffs

**UserDefaults over SwiftData** — appropriate for this data size and avoids the iOS 17 minimum deployment requirement. The repository abstraction makes it swappable.

**ScenePhase over timers for midnight reset** — `DispatchQueue.asyncAfter` at midnight is unreliable across app kills and device sleep. ScenePhase handles every real case with less code and no drift.

**Protocol-first everywhere** — every service and repository has a protocol. This is what enables MockDateService in previews, makes business logic unit-testable, and keeps the architecture honest about dependencies.

**Expired tasks stay visible** — rather than deleting tasks at expiry they move to the bottom of the list with an X circle and "Not finished in time" label. This preserves the record and avoids data loss from timing edge cases.

---

## Features

**Must-Have**
- Add, complete, and persist tasks for the current day
- Tasks from previous days never appear in the main list
- Automatic day reset at midnight with no manual cleanup

**Enhancements**
- Optional same-day expiry time per task with a wheel time picker
- Archive tab showing past days grouped by date with completed, expired, and incomplete task states
- Delete archived days you no longer want
- 5-layer task completion animation: circle fill → strikethrough draws across text → ink fade → row settles → haptic
- Time-of-day gradient backgrounds shifting from morning apricot through midday cool to evening terracotta sunset
- Thoughtful empty states with time-of-day specific copy
- Home screen widgets — small (count + progress) and medium (count + task list)
- Haptic feedback throughout

---

## What I Would Improve With More Time

**Full dark mode support** — the color system and semantic tokens are fully set up for dark mode in the DesignSystem layer but the time-of-day gradients and some view-level colors were not fully tuned for dark mode within the submission timeframe. The foundation is there for a complete dark mode pass.

**Local notifications** — `NotificationService` is stubbed and the architecture is in place but notifications were not fully wired up within the submission timeframe. The plan was to fire a notification 30 minutes before task expiry and an end-of-day reminder at 9pm for tasks with no expiry set.

**Persistence** — UserDefaults is appropriate here but for an App Store release I would migrate to CoreData for larger datasets, iCloud sync, and more robust querying.

**Lock screen widget** — a `.accessoryCircular` widget showing the incomplete task count would be a natural extension of the home screen widgets.

**Widget gallery preview** — when browsing widgets to add to the home screen iOS shows a placeholder snapshot rather than live data. I would implement a more representative `getSnapshot()` entry to make the gallery preview useful.

**Letter spacing** — some text elements could benefit from slightly increased tracking for improved readability, particularly the task title at smaller Dynamic Type sizes.

**Better task ordering** — currently tasks sort by expiry urgency then creation order. I would add the ability to manually reorder tasks within a day.

---

## What I Got Stuck On

**Custom fonts not loading** — the most time-consuming issue in the project. Claude Code switched from auto-generated `Info.plist` to a manual one to register fonts, which broke Xcode previews entirely. The fix was reverting to `GENERATE_INFOPLIST_FILE = YES` and registering fonts through Xcode's Info tab under "Fonts provided by application" — keeping everything auto-generated while still registering the fonts. Additionally font PostScript names had to match the binary exactly (`Fraunces144pt-Light` not `Fraunces-Light`) which required reading them from the font files directly.

**SwiftUI Spacer inside ScrollView** — centering the empty state vertically inside a ScrollView doesn't work with `Spacer()` because ScrollView doesn't give its content a fixed height to push against. The fix was wrapping the ScrollView content in a `GeometryReader` and setting `minHeight: geo.size.height` on the VStack, which forces the content to be at least as tall as the screen and gives Spacers something to push against.

**Widget target scope** — the widget is a separate binary and cannot import from the main app target even with App Groups configured. App Groups share data not code. The fix was creating a `Shared/` folder with `TodoItem.swift` and `SharedTodoStore.swift` having dual target membership across both the main app and widget targets.

**Expiry UI not auto-updating** — `isExpired` is a computed property reading `Date()` directly but SwiftUI has no way to know when that value changes. The fix was scheduling a `DispatchQueue.asyncAfter` per task that fires at the exact expiry moment and reassigns `items = items` on the ViewModel, which triggers `@Observable` to notify SwiftUI of the change.

---


## AI Tool Usage

This project was built using Claude as the primary development tool across design, architecture, and implementation. A full record of all Claude conversations — including Claude Design sessions and all six Claude Code sessions with complete prompt and response history — is included in the `claudechatsessions/` folder in this repository. The `CONTEXT.md` file at the project root documents the architectural rules and agent instructions used throughout.
