# How Efficient is Claude at Building a Real iOS App?

I spent the past weekend finding out. I built a minimal iOS todo app called Today. with one rule: tasks only exist for the current day. Every morning is a clean slate, no backlogs, no overdue items. It includes a time of day gradient background that shifts from morning to midday to evening, task expiry times, an archive tab for past days, and home screen widgets.

Here is a full breakdown of what I learned. For the code, screenshots, and demo see the [README](README.md).

---

## The Design

Claude Design was genuinely impressive. It produced a complete design system in about 30 minutes with a few prompts and some manual tweaking. Color palettes, typography scale, spacing grid, animation specs all done. I'd say it got 90% of the way there on its own. I imagine it gets harder with more complex UI but for a clean minimal app it was the most impressive part of the whole experiment.

---

## Context Management

Before writing any code I created a CONTEXT.md file, a persistent briefing document that Claude Code reads at the start of every session since it has zero memory between sessions. Think of it like onboarding a new developer every time you open the terminal. Without it Claude Code makes reasonable but wrong assumptions. With it the output is dramatically more consistent. This was the single highest leverage thing I did in the entire project.

---

## The UI

My workflow was: let Claude Code build the screen first, then fix it myself. AI gets about 90% done fast but lacks precision. Things like letter spacing, font weights, and subtle layout details always needed manual correction. A skilled Swift developer could probably nail the design in one shot.

What's interesting is Claude Code relies heavily on the design specs and tends to hide all its values in a separate constants file rather than using native iOS layout tools like Spacer(), which automatically distributes space without fixed numbers. A good Swift developer instinctively reaches for these adaptive primitives. However, Claude instinctively reaches for magic numbers and tries to tuck them away neatly. I imagine this could be fixed with better prompting, but this would catch someone with no expierence in Swift off guard.

---

## Touching the Build

This is where Claude Code struggles most. A human developer can import custom fonts into an Xcode project in 30 seconds. Claude Code without very precise instructions started hallucinating: duplicating configuration files, breaking Xcode previews, and creating broken file references. Anything that involves directly modifying the Xcode build system requires very deliberate prompting. Someone with no Swift knowledge would hit a wall here fast.

---

## The Backend

A solid CONTEXT.md reduces hallucinations significantly on the architecture side but there were still some decisions that needed catching and correcting. For example logic that belonged in a shared service ended up duplicated across multiple ViewModels, and some methods that should have been separated into their own layer were bundled together in ways that made the code harder to follow. Nothing that broke functionality but the kind of thing a senior developer would flag immediately in a code review. The full architecture is on GitHub if you want to explore further.

---

## Conclusion

AI is a genuine accelerator in software development, there is no question about that. But the more I used it the more I realized how much it matters to have someone who actually knows what they are doing behind the scenes. Vibecoding feels fast and productive until you zoom out and realize the technical debt quietly accumulating under the surface. Duplicated logic, magic numbers, architecture decisions that work but would not scale, build system changes that break things two steps later. Claude does not know what it does not know, and without an experienced engineer catching those moments early they compound fast. The sweet spot is using AI to move quickly on the foundation while staying close enough to the output to catch the 10% that needs a real judgment call.
