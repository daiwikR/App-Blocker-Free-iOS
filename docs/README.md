# Blocker — Xcode Setup Guide

## 1. Create the Xcode project

1. Open Xcode → **File › New › Project**
2. Choose **iOS › App**
3. Product name: `Blocker`
4. Bundle ID: `com.yourname.Blocker`
5. Language: **Swift**, Interface: **SwiftUI**
6. **Uncheck** "Include Tests" for now (add a test target later)
7. Save inside `Preferred Dir`

## 2. Add source files

All Swift files in this repo are pre-organised. In Xcode:

1. Right-click the `Blocker` group → **Add Files to "Blocker"**
2. Select the folders: `App/`, `Models/`, `Managers/`, `Views/`, `Extensions/`
3. Tick **"Create groups"** and **"Copy items if needed"**

## 3. Enable required capabilities

In **Targets › Blocker › Signing & Capabilities**:

| Capability | Notes |
|---|---|
| **Family Controls** | Click `+`, search "Family Controls", add it. Requires Apple approval for TestFlight / App Store distribution. Works on device in development without approval. |
| **Background Modes** | Tick "Background fetch" — needed for the background timer task. |

## 4. Add entitlements file

Xcode creates `Blocker.entitlements` automatically when you add capabilities.
Verify it contains:

```xml
<key>com.apple.developer.family-controls</key>
<true/>
```

## 5. Link frameworks

In **Targets › Blocker › General › Frameworks, Libraries, and Embedded Content**, add:

- `FamilyControls.framework`
- `ManagedSettings.framework`
- `DeviceActivity.framework` *(needed for future scheduled blocking)*

These are system frameworks — select **"Do Not Embed"**.

## 6. Set deployment target

**iOS 16.0** minimum (FamilyControls `.individual` authorisation requires iOS 16+).

## 7. Test on device (not Simulator)

Screen Time / FamilyControls **does not work in the Simulator**.
Connect a real iPhone, select it as the run destination, build & run.

---

## 8. Future: Content Filter Extension (website blocking)

Domain-level blocking (the `blockedDomains` list in `BlockList`) requires a
**Network Extension** with a **Content Filter** provider.

Steps when you're ready:
1. **File › New › Target › Network Extension**
2. Choose **"Content Filter"** subtype
3. Implement `NEFilterDataProvider`
4. In `ShieldManager.startBlocking(selection:)`, activate the filter provider
   with the domain list via `NEFilterManager.shared()`

This is intentionally deferred from the MVP because it requires an additional
provisioning profile and entitlement (`com.apple.developer.network-extension`).

---

## 9. AccentColor

In `Assets.xcassets`, create a color set named **`AccentColor`** and set it to
`#FF6B35` (the orange used throughout the app).

## 10. App icons

Add your icon set to `Assets.xcassets › AppIcon`.
Minimum required sizes: 1024×1024 (App Store) + 60pt @2x / @3x for the home screen.
