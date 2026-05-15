# Today. — Project Context for Claude Code
> Read this file in full before writing a single line of code.
> This is your source of truth for every decision in this project.

---

## 0 · What This App Is

**Today.** is a minimal iOS todo app with one rule: tasks only exist today.

- Tasks belong to the current calendar day
- At midnight, old tasks are gone — no migration, no backlog
- Every morning is a clean slate
- There are no future dates, no overdue states, no scheduling ahead

This constraint is intentional. Every product and technical decision should reinforce it.

---

## 1 · Tech Stack

| Concern | Decision |
|---|---|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Minimum Deployment | iOS 16.0 |
| Persistence | UserDefaults (via a clean abstraction — see Section 5) |
| Architecture | MVVM |
| Unit Tests | Swift Testing framework |
| Network | None. Fully offline. No URLSession, no imports of network frameworks. |
| Third-Party Dependencies | None. Zero SPM packages. Zero CocoaPods. |

---

## 2 · Architecture — MVVM Rules

### Layers
```
View  →  ViewModel  →  Model  →  Repository  →  Storage
```

- **Views** — SwiftUI only. No business logic. No direct UserDefaults access. No date math. Views observe ViewModels and render state.
- **ViewModels** — `@Observable` (iOS 17) or `ObservableObject` (iOS 16 fallback). Own the state. Call repositories. Fire haptics. Schedule notifications. Never import UIKit except for haptics.
- **Models** — Plain Swift structs. Codable. No SwiftUI imports.
- **Repositories** — Protocols with concrete implementations. This is where UserDefaults is touched. Swappable for testing.
- **Services** — `DateService`, `NotificationService`, `HapticService`. Each is a single-responsibility class or struct. Never inline these concerns into a ViewModel.

### Rules
- A View must never own a `Date()` call. Always ask `DateService`.
- A View must never call `UserDefaults` directly.
- A ViewModel must never own a `URLSession`.
- If a function is longer than 30 lines, it should be broken up.
- If a file is longer than 200 lines, it should be broken up.

---

## 3 · Folder Structure

Create this exact structure inside the main app target. Do not deviate.

```
Today/
├── App/
│   ├── TodayApp.swift
│   └── AppConstants.swift          ← All magic numbers live here as named constants
│
├── Models/
│   └── TodoItem.swift
│
├── Repositories/
│   ├── TodoRepositoryProtocol.swift
│   └── UserDefaultsTodoRepository.swift
│
├── Services/
│   ├── DateService.swift           ← All date logic. Never call Date() outside here.
│   ├── NotificationService.swift
│   └── HapticService.swift
│
├── ViewModels/
│   ├── TodayViewModel.swift
│   └── ArchiveViewModel.swift
│
├── Views/
│   ├── Today/
│   │   ├── TodayView.swift         ← Main list, time-of-day background
│   │   ├── TaskRowView.swift       ← Single task row with completion animation
│   │   └── EmptyStateView.swift    ← Empty state for today
│   ├── Archive/
│   │   ├── ArchiveView.swift       ← Grouped past days
│   │   └── ArchiveDaySection.swift ← One day's section in the archive
│   ├── AddTask/
│   │   ├── AddTaskSheet.swift      ← Bottom sheet for adding a task
│   │   └── ExpiryTimePicker.swift  ← Optional same-day expiry picker
│   └── Components/
│       ├── TodayTabBar.swift       ← Custom tab bar (TODAY / ARCHIVE)
│       └── CheckCircleView.swift   ← Animated check circle component
│
├── DesignSystem/
│   ├── Colors.swift                ← All Color extensions from design spec
│   ├── Typography.swift            ← All Font extensions from design spec
│   ├── Spacing.swift               ← All spacing constants
│   ├── Radii.swift                 ← All corner radius constants
│   ├── Shadows.swift               ← All shadow styles
│   └── Animation+Today.swift      ← All named animations and durations
│
└── Resources/
    ├── Assets.xcassets
    └── Fonts/                      ← Fraunces, Geist, Geist Mono font files
```

---

## 4 · Model

```swift
// Models/TodoItem.swift
struct TodoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    let createdAt: Date
    let dayKey: String          // "yyyy-MM-dd" — used to bucket tasks by day
    var expiresAt: Date?        // Optional same-day expiry, always < end of createdAt day
}
```

### Rules for TodoItem
- `dayKey` is always set at creation from `DateService.todayKey`
- `expiresAt` must always be on the same calendar day as `createdAt` — enforce this in the ViewModel, not the model
- Never add UI-related properties to the model (no `isAnimating`, no `Color`)

---

## 5 · Persistence — UserDefaults Abstraction

```swift
// Repositories/TodoRepositoryProtocol.swift
protocol TodoRepositoryProtocol {
    func loadAll() -> [TodoItem]
    func save(_ items: [TodoItem])
}
```

```swift
// Repositories/UserDefaultsTodoRepository.swift
// Stores one JSON-encoded [TodoItem] array under a single key.
// Key: "com.today.todos"
// On load: decode and return all items. Filtering by day is done in the ViewModel.
```

### Why this abstraction matters
The ViewModel never touches UserDefaults directly. This means:
- Unit tests can inject a mock repository
- Swapping to SwiftData later is a one-file change
- The storage concern is isolated and auditable

---

## 6 · Date & Day Reset Logic

All date logic lives in `DateService`. No exceptions.

```swift
// Services/DateService.swift
struct DateService {
    var today: Date { ... }
    var todayKey: String { ... }      // "yyyy-MM-dd"
    var startOfToday: Date { ... }
    var endOfToday: Date { ... }
    func dayKey(for date: Date) -> String { ... }
    func isToday(_ item: TodoItem) -> Bool { ... }
    func isExpired(_ item: TodoItem) -> Bool { ... }
    func minutesUntilEndOfDay() -> Int { ... }
}
```

### Day Reset
- `TodayViewModel` filters tasks using `DateService.isToday()` on every load
- Tasks from previous days are never deleted — they remain in UserDefaults for the archive
- "Reset" means the Today view shows only items where `dayKey == todayKey`
- A `ScenePhase` observer in `TodayApp.swift` triggers a ViewModel refresh when the app foregrounds — this handles waking up after midnight

---

## 7 · Features Checklist

### Must-Have
- [x] Add a task (title only, or title + optional expiry time)
- [x] Mark task complete (with animation)
- [x] Tasks persist locally via UserDefaults
- [x] Today view only shows today's tasks
- [x] Automatic day reset — no manual cleanup needed

### Enhancements — ALL to be implemented
- [x] Optional same-day expiry time per task
- [x] Archive view — past days, read-only, grouped by date
- [x] Task completion animation (5-layer choreography — see Section 10)
- [x] Haptic feedback (completion = `.success`, add = `.soft`, expiry warning = `.warning`)
- [x] Empty states — thoughtful, matches time of day
- [x] Light/Dark mode — full design system coverage
- [x] Local notifications — fires before task expiry or end of day (never after)

### Out of Scope — Do NOT implement
- User accounts or authentication
- Scheduling tasks for future days
- Widgets (deferred — leave clean extension points in the ViewModel)
- App Intents / Siri (deferred — leave clean extension points)
- Complex settings screens
- Any network requests

---

## 8 · UI Rules — Non-Negotiable

These rules apply to every single View file. Claude Code must follow them without exception.

### 1 · No Magic Numbers
Every numeric value in the UI must be a named constant. Never write a raw number in a View.

```swift
// ❌ WRONG
.padding(16)
.cornerRadius(12)
.frame(height: 56)

// ✅ CORRECT
.padding(Spacing.md)
.cornerRadius(Radii.md)
.frame(height: Layout.taskRowHeight)
```

All spacing, radii, font sizes, animation durations, and layout values live in `DesignSystem/`.
`AppConstants.swift` holds any layout-specific values (e.g. `taskRowHeight`, `addButtonSize`, `tabBarHeight`).

### 2 · Use Apple's Navigation Primitives
- Use `NavigationStack` (iOS 16+), never `NavigationView`
- Use `.sheet()` modifier for the add task sheet, not custom overlays
- Use `.tabItem` or a custom tab bar component — not manually placed HStacks pretending to be tabs
- Use `List` or `ScrollView + LazyVStack` for task lists — not manually spaced VStacks
- Use `.swipeActions` for row actions, not custom gesture recognizers
- Use `.sensoryFeedback` (iOS 17+) or `UIImpactFeedbackGenerator` for haptics — not custom implementations

### 3 · View Composition
- Every View should do ONE thing
- If a View body exceeds ~40 lines, extract subviews
- Use `@ViewBuilder` computed properties for conditional UI within a View
- Prefer named subviews over inline closures for anything non-trivial

### 4 · State Ownership
- `@State` — local, ephemeral UI state only (e.g. `isSheetPresented`, `textFieldValue`)
- `@StateObject` / `@Bindable` — ViewModel owned by a View
- `@EnvironmentObject` — shared services (HapticService, DateService) injected at root
- Never pass a ViewModel down more than one level — use environment or child VMs

### 5 · Accessibility
- Every interactive element must have `.accessibilityLabel()`
- Checkboxes must have `.accessibilityValue("checked" / "unchecked")`
- Use semantic colors from the design system, never hardcoded hex in Views
- Support Dynamic Type — never use `.fixedSize()` on text without a fallback

### 6 · One Page at a Time
Claude Code must build and verify one screen before moving to the next.

**Build order:**
1. DesignSystem files (Colors, Typography, Spacing, Radii, Animation)
2. TodayView (main list, all states)
3. TaskRowView + CheckCircleView (with completion animation)
4. EmptyStateView
5. AddTaskSheet + ExpiryTimePicker
6. ArchiveView + ArchiveDaySection
7. TodayTabBar

Do not start the next screen until the current one passes the screenshot verification loop (Section 9).

---

## 9 · Screenshot Verification Loop

After implementing each screen, Claude Code must run the following loop before moving on.

```
LOOP for each completed screen:

1. BUILD
   Confirm the file compiles with no errors or warnings.
   
2. SCREENSHOT
   Take a simulator screenshot of the current screen.
   
3. COMPARE
   Side-by-side compare the screenshot against the design spec.
   Check the following explicitly:
   - [ ] Background color matches time-of-day spec
   - [ ] Typography: correct font family, weight, size, tracking
   - [ ] Spacing: padding and gaps match the 4pt scale
   - [ ] Corner radii match spec
   - [ ] Colors match design system (light AND dark mode)
   - [ ] Empty state renders correctly
   - [ ] Interactive states (pressed, completed) look correct
   
4. IDENTIFY GAPS
   List every visual discrepancy found.
   
5. FIX
   Address each gap. Re-screenshot.
   
6. SIGN OFF
   Only mark a screen complete when the screenshot matches the design with no outstanding gaps.
   
THEN move to the next screen.
```

This loop is mandatory. Do not skip it. Do not move to the next screen without sign-off.

---

## 10 · Animation Spec

### Task Completion (5 layers, fire simultaneously)
| Layer | What | Property | Duration | Easing |
|---|---|---|---|---|
| 01 | Circle fills (terracotta disc + check) | background, border-color, transform | 220ms | standard |
| 02 | Hand-drawn strikethrough draws across title | stroke-dashoffset 220→0 | 480ms | paper | delay 60ms |
| 03 | Ink fades (title color softens) | color: inkPrimary → inkTertiary | 360ms | paper |
| 04 | Row settles to bottom of incomplete group | transform: translateY | 520ms | paper | delay 200ms |
| 05 | Haptic fires at moment circle fills | UINotificationFeedbackGenerator(.success) | 0ms | — |

### Add Task Sheet (5 layers)
| Layer | What | Property | Duration | Easing |
|---|---|---|---|---|
| 01 | Sheet rises from below | transform: translateY(110%→0) | 420ms | decelerate |
| 02 | Scrim fades in | opacity: 0→0.32 | 360ms | standard |
| 03 | Sheet dismisses on Add tap | inverse of 01 | 320ms | accelerate |
| 04 | New task row enters list | opacity + translateY(6px→0) | 360ms | decelerate |
| 05 | Haptic fires when row appears | UIImpactFeedbackGenerator(.soft) | 0ms | — |

### Easing Curves (map to SwiftUI Animation)
| Name | Bezier | SwiftUI mapping |
|---|---|---|
| standard | bezier(0.32, 0.72, 0.18, 1) | `.timingCurve(0.32, 0.72, 0.18, 1)` |
| decelerate | bezier(0.16, 1, 0.30, 1) | `.timingCurve(0.16, 1, 0.30, 1)` |
| accelerate | bezier(0.50, 0, 0.75, 0) | `.timingCurve(0.50, 0, 0.75, 0)` |
| spring | bezier(0.34, 1.40, 0.50, 1) | `.spring(response:0.4, dampingFraction:0.7)` |
| paper | bezier(0.22, 0.61, 0.36, 1) | `.timingCurve(0.22, 0.61, 0.36, 1)` |

---

## 11 · Design System Quick Reference

### Colors — Light Mode
| Token | Hex | Usage |
|---|---|---|
| bgBase | #F2EEE6 | App background |
| bgCanvas | #F7F3EB | Card/list background |
| surface | #FBF8F2 | Row surfaces |
| surfaceRaised | #FFFFFF | Elevated sheets |
| inkPrimary | #1C1714 | Primary text |
| inkSecondary | #5C544D | Secondary text |
| inkTertiary | #9A9087 | Placeholder, expired labels |
| inkQuaternary | #C5BCB1 | Dividers as text |
| accent | #C0532E | Terracotta — FAB, active states |
| accentPressed | #A8431F | FAB pressed |
| accentSoft | #F5DCCB | Accent backgrounds |
| destructive | #A8312A | Delete actions |
| success | #5B7553 | — |
| warning | #B8893A | Expiry warnings |
| divider | #E8E0D2 | Row separators |
| dividerStrong | #D8CFC0 | Section separators |
| morningGlow | #FBDFC4 | Time-of-day bg: morning |
| middayCool | #E9EEF1 | Time-of-day bg: midday |
| sunsetTop | #DC7A72 | Time-of-day bg: sunset gradient top |
| sunsetMid | #EFA689 | Time-of-day bg: sunset gradient mid |
| sunsetBot | #F2DCC4 | Time-of-day bg: sunset gradient bottom |

### Colors — Dark Mode
| Token | Hex |
|---|---|
| bgBase | #14110E |
| bgCanvas | #1A1612 |
| surface | #221D18 |
| surfaceRaised | #2C2620 |
| inkPrimary | #F0EBE2 |
| inkSecondary | #B0A89E |
| inkTertiary | #7A7268 |
| inkQuaternary | #4A443E |
| accent | #D86A47 |
| accentPressed | #B85633 |
| accentSoft | #3A2218 |
| morningGlow | #3E2A1E |
| middayCool | #1F2528 |
| sunsetTop | #5A2620 |
| sunsetMid | #6E3A2C |
| sunsetBot | #3A2A20 |

### Typography
| Style | Font | Size | Line Height | Weight | Tracking |
|---|---|---|---|---|---|
| display | Fraunces | 44 | 48 | 300 | -0.8 |
| title | Fraunces | 32 | 38 | 400 | -0.6 |
| headline | Fraunces | 22 | 28 | 500 | -0.3 |
| body | Geist | 17 | 24 | 400 | -0.2 |
| callout | Geist | 16 | 22 | 500 | -0.2 |
| subhead | Geist | 14 | 20 | 500 | 0 |
| footnote | Geist | 13 | 18 | 400 | 0 |
| caption | Geist Mono | 11 | 14 | 400 | +0.6 |

### Spacing (4pt scale)
```swift
// DesignSystem/Spacing.swift
enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 20
    static let xxl: CGFloat = 24
    static let s3:  CGFloat = 32
    static let s4:  CGFloat = 40
    static let s5:  CGFloat = 48
    static let s6:  CGFloat = 64
    static let s7:  CGFloat = 80
}
```

### Corner Radii
```swift
// DesignSystem/Radii.swift
enum Radii {
    static let xs:   CGFloat = 4
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 24
    static let pill: CGFloat = .infinity
}
```

### Shadows
```swift
// DesignSystem/Shadows.swift
// hairline: 0 0 0 0.5px rgba(28,23,20,0.08)
// raised:   0 1px 2px rgba(28,23,20,0.04), 0 0 0 1px rgba(28,23,20,0.04)
// floating: 0 2px 6px rgba(28,23,20,0.06), 0 4px 24px rgba(28,23,20,0.06)
// sheet:    0 -2px 12px rgba(28,23,20,0.04), 0 -8px 40px rgba(28,23,20,0.08)
```

### Icons (SF Symbols)
| Name | SF Symbol |
|---|---|
| plus | `plus` |
| check | `checkmark` |
| calendar | `calendar` |
| clock | `clock` |
| archive | `archivebox` |
| bell | `bell` |

Always use `.symbolRenderingMode(.hierarchical)` and `foregroundStyle(Color.inkSecondary)`.
Accent color only on active/selected states.

---

## 12 · Notification Rules

- Notifications are local only — no server, no push
- Only schedule if the user has granted permission (always request permission on first add)
- If a task has an `expiresAt`: notify 30 minutes before expiry
- If a task has no `expiresAt`: notify at 9:00 PM as an end-of-day reminder
- Never schedule a notification in the past
- Cancel all notifications for a task when it is marked complete
- All notification logic lives in `NotificationService` — never in a ViewModel or View

---

## 13 · Empty States

Empty states must be thoughtful and match the time of day.

| Time | Title | Subtitle |
|---|---|---|
| Morning (6am–12pm) | "A clean slate." | "Begin gently." |
| Midday (12pm–5pm) | "What matters today?" | "Tap below to write your first thing. Tasks only live for today." |
| Evening (5pm–9pm) | "The day softens." | "An hour remains until midnight." (dynamic) |
| Night (9pm–12am) | "Almost there." | "Whatever's left, tomorrow is a clean start." |

---

## 14 · What Good Code Looks Like in This Project

- Named constants everywhere — if you're typing a raw number in a View, stop and add it to DesignSystem or AppConstants
- Protocol-first — every service and repository has a protocol, concrete type is injected
- No force unwraps (`!`) anywhere in production code
- No `// TODO` left in submitted code — either implement it or leave a structured comment explaining the deferral
- `// MARK: -` sections in every file longer than 50 lines
- Every public function has a one-line doc comment (`///`)
- Tests cover: day key logic, expiry filtering, today filtering, notification scheduling rules
- Git commit after every screen sign-off

---

## 15 · Claude Code Behavior Rules

- Read this entire file before starting
- Ask a clarifying question if any requirement is ambiguous — don't guess
- Build one screen at a time per Section 8, Rule 6
- Run the screenshot verification loop (Section 9) after each screen
- Never skip the DesignSystem files — they must exist before any View is written
- If you find yourself writing a magic number, stop and add a named constant instead
- If a View file is getting long, extract a subview — don't keep appending to body
- Prefer `@Observable` for ViewModels if targeting iOS 17+, with an `ObservableObject` fallback note
- When in doubt about a UI detail, refer to Section 11 (Design System) and the fetched design file
- Do not add features not listed in Section 7
- Do not install any packages or dependencies without permission - most likley will not because there shouldnt be any reason to.
