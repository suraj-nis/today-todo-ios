import SwiftUI

// MARK: - Motion durations (seconds)

enum MotionDuration {
    static let micro:  Double = 0.120  // taps, hover highlights
    static let short:  Double = 0.220  // most UI transitions
    static let medium: Double = 0.360  // sheets, modals
    static let long:   Double = 0.520  // completion strike, day reset
    static let breath: Double = 0.800  // sunset gradient, ambient pulses
}

// MARK: - Easing curve factories

extension Animation {
    /// bezier(0.32, 0.72, 0.18, 1) — crisp, most UI interactions.
    static func standard(duration: Double) -> Animation {
        .timingCurve(0.32, 0.72, 0.18, 1, duration: duration)
    }

    /// bezier(0.16, 1, 0.30, 1) — elements entering the screen.
    static func decelerate(duration: Double) -> Animation {
        .timingCurve(0.16, 1.00, 0.30, 1, duration: duration)
    }

    /// bezier(0.50, 0, 0.75, 0) — elements leaving the screen.
    static func accelerate(duration: Double) -> Animation {
        .timingCurve(0.50, 0.00, 0.75, 0, duration: duration)
    }

    /// bezier(0.22, 0.61, 0.36, 1) — calm, considered; page-turn quality.
    static func paper(duration: Double) -> Animation {
        .timingCurve(0.22, 0.61, 0.36, 1, duration: duration)
    }

    /// spring(response: 0.4, dampingFraction: 0.7) — tactile snap.
    static let todaySpring = Animation.spring(response: 0.4, dampingFraction: 0.7)
}

// MARK: - Named sequence animations

extension Animation {

    // ── Task completion (5 simultaneous layers) ─────────────────────────────
    /// Layer 01 — circle fills terracotta + check appears (220ms standard).
    static let circleComplete = standard(duration: MotionDuration.short)

    /// Layer 02 — hand-drawn strikethrough draws across title (480ms paper, 60ms delay).
    static let strikethrough  = paper(duration: 0.480).delay(0.060)

    /// Layer 03 — title color softens ink primary → tertiary (360ms paper).
    static let inkFade        = paper(duration: MotionDuration.medium)

    /// Layer 04 — completed row settles to bottom of group (520ms paper, 200ms delay).
    static let rowSettle      = paper(duration: MotionDuration.long).delay(0.200)

    // ── Add task sheet (5 layers) ────────────────────────────────────────────
    /// Layer 01 — sheet rises from below: translateY(110% → 0) (420ms decelerate).
    static let sheetPresent   = decelerate(duration: 0.420)

    /// Layer 02 — scrim fades in: opacity(0 → 0.32) (360ms standard).
    static let scrimIn        = standard(duration: MotionDuration.medium)

    /// Layer 03 — sheet drops on dismiss (320ms accelerate).
    static let sheetDismiss   = accelerate(duration: 0.320)

    /// Layer 04 — new task row enters list from 6pt below (360ms decelerate).
    static let rowEnter       = decelerate(duration: MotionDuration.medium)

    // ── Day reset (midnight) ─────────────────────────────────────────────────
    /// Each task row evaporates upward (520ms accelerate, stagger externally by 40ms).
    static let taskEvaporate  = accelerate(duration: MotionDuration.long)

    /// Background eases from canvas to bgBase after reset (800ms paper).
    static let bgReset        = paper(duration: MotionDuration.breath)

    // ── Sunset transition (11 pm) ────────────────────────────────────────────
    /// Canvas background eases to sunset gradient (800ms paper).
    static let sunsetBgShift  = paper(duration: MotionDuration.breath)

    /// Date stamp color shifts to accent (520ms paper).
    static let sunsetAccent   = paper(duration: MotionDuration.long)

    // ── Swipe to delete ──────────────────────────────────────────────────────
    /// Row snaps to rest position at −80pt threshold.
    static let swipeSnap      = todaySpring

    /// Row height collapses after delete commit (360ms accelerate).
    static let rowDelete      = accelerate(duration: MotionDuration.medium)
}
