# Blocker

**A Pomodoro-driven focus app for iPhone that uses Screen Time to block distracting apps and websites during work sessions.**

---

## What it does

Blocker combines the Pomodoro Technique with iOS Screen Time to create a distraction-free work environment. Start a focus session and your selected apps are blocked at the system level — no willpower required. An optional Strict Mode makes it nearly impossible to give up mid-session.

---

## Features

### Pomodoro Timer
- Configurable work, short break, and long break durations
- Session cycle tracking with visual progress dots
- Optional auto-start for breaks and work sessions
- Daily focus minutes tracked and displayed

### App & Website Blocking
- Native Screen Time picker to select specific apps to block
- Category presets: Social Media, Video & Streaming, Games, Adult Content
- Manual domain entry for website blocking *(requires Network Extension — see [`docs/SETUP.md`](docs/SETUP.md))*
- Shields applied automatically when a session starts; removed when it ends

### Strict Mode
- Prevents pausing or stopping the timer mid-session
- To disable mid-session, the user must type a randomly generated 40-character challenge string exactly
- 30-second cooldown enforced after each failed attempt
- Challenge string regenerates on every failure

### Motivational Block Screen
- Full-screen cover displayed when a blocked app is opened
- Curated quotes from productivity and deep-work thinkers
- Live stats: time remaining in session, total minutes focused today

### Onboarding
- 3-slide introduction to core features
- Inline Screen Time permission request with clear privacy messaging

---

## Requirements

| | Minimum |
|---|---|
| iOS | 16.0 |
| Xcode | 15.0 |
| Swift | 5.9 |
| Device | Physical iPhone required for Screen Time features |
| Apple Developer Account | Required for the Family Controls entitlement |

---

## Project Structure

```
Blocker/
├── App/
│   ├── BlockerApp.swift          Entry point and onboarding gate
│   └── AppState.swift            Owns all managers; handles FamilyControls auth
│
├── Models/
│   ├── PomodoroSession.swift     Phase enum, configurable settings, session records
│   └── BlockList.swift           FamilyActivitySelection, domain list, category presets
│
├── Managers/
│   ├── PomodoroManager.swift     Combine-based timer, phase transitions, shield lifecycle
│   ├── ShieldManager.swift       ManagedSettingsStore wrapper (Simulator-safe guards)
│   └── StrictModeManager.swift   Challenge string generation, unlock logic, cooldown timer
│
├── Views/
│   ├── Home/                     Main timer screen, circular ring, settings sheet
│   ├── Onboarding/               3-slide intro and permissions request
│   ├── BlockList/                App picker, category toggles, domain entry
│   ├── StrictMode/               Challenge input with shake animation and cooldown
│   └── Motivational/             Full-screen motivational cover with live session stats
│
├── Extensions/
│   └── Color+Theme.swift         Design tokens, hex Color initialiser, button style
│
└── docs/
    ├── README.md                 This file
    └── SETUP.md                  Xcode project setup and capability configuration guide
```

---

## Architecture

| Concern | Approach |
|---|---|
| State management | `ObservableObject` + `@EnvironmentObject` — zero third-party dependencies |
| Timer | Combine `Timer.publisher` with `UIBackgroundTaskIdentifier` for background continuity |
| Screen Time | `AuthorizationCenter` → `FamilyActivityPicker` → `ManagedSettingsStore` |
| Persistence | `UserDefaults` + `JSONEncoder/Decoder` for `FamilyActivitySelection` (Codable, iOS 16+) |
| Simulator support | `#if targetEnvironment(simulator)` guards around all Screen Time API calls |

---

## Getting Started

See [`docs/SETUP.md`](docs/SETUP.md) for the full step-by-step guide.

**Quick start:**
1. Open `Blocker/Blocker.xcodeproj` in Xcode
2. Set your Development Team under *Targets → Signing & Capabilities*
3. Add the **Family Controls** capability
4. Connect a physical iPhone and run (`⌘R`)
5. Accept the Screen Time permission prompt on first launch

---

## Simulator

The app launches and all UI is fully testable in the Simulator. Screen Time blocking is skipped gracefully — the timer, strict mode challenge, and motivational screen all work as expected without a device.

---

## Roadmap

- [ ] DeviceActivity extension — scheduled blocking windows
- [ ] Network Extension — domain-level website blocking
- [ ] Mac app — menu-bar timer with system-level app blocking
- [ ] Push notifications — session end alerts when backgrounded
- [ ] iCloud sync — block lists and history across devices
- [ ] WidgetKit — home screen timer ring widget

---

## Tech Stack

- **SwiftUI** — declarative UI
- **Combine** — reactive timer loop and state propagation
- **FamilyControls** — Screen Time authorization and app selection UI
- **ManagedSettings** — applying and removing system-level app shields
- **UIKit** — background task management for timer continuity

---

## License

MIT License. See `LICENSE` for details.
