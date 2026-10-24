# Merge notes for main (Codex)

The `design-system` branch adds `WeaveApp/DesignSystem/`. It changes no file under `Features/`, `Services/`, `Models/`, `Debug/`, `Supabase/`, `Tests/`, `Scripts/`, or `.agents/`. Outside this folder it changes only `Weave.xcodeproj/project.pbxproj` (add-only) and `.gitignore` (one line: `build-design/`). It also adds the app icon in `WeaveApp/DesignSystem/DesignAssets.xcassets` (see **App icon** below).

Nothing here is wired into a screen yet. When a screen adopts a component, that change is under `WeaveApp/Features/`, so run the kane-verify-loop before you commit it.

## project.pbxproj

Every ID I added uses the prefix `D516`, so it can't collide with the sequential `A000…` IDs on main. No existing line was removed. Five existing lines were extended.

### Existing lines extended

| Line | Change |
| --- | --- |
| `A00000000000000000000003` (main group) | `children` gains `D51600000000000000000001`, between `…0009` and `…0004` |
| `A00000000000000000000005` (Sources build phase) | `files` gains `D51600000000000000000021` … `D51600000000000000000027` at the end |
| `A00000000000000000000007` (Resources build phase) | `files` was empty, now `(D51600000000000000000028)` |
| `A00000000000000000000041` (project Debug config) | adds `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;` after `ALWAYS_SEARCH_USER_PATHS = NO;` |
| `A00000000000000000000042` (project Release config) | same setting, same place |

**Likely conflicts:** if main also added files or resources, the `A00000000000000000000005` Sources line or the `A00000000000000000000007` Resources line conflicts. To resolve it, keep the union of both `files` lists. The order doesn't matter. If main edited `A00000000000000000000041` or `…0042`, keep main's settings and re-add `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;`.

### New lines

All new lines sit together, right after the `A00000000000000000000010` (XCConfigurationList) line.

| ID | isa | What |
| --- | --- | --- |
| `D51600000000000000000001` | PBXGroup | `DesignSystem`, path `WeaveApp/DesignSystem` |
| `D51600000000000000000011` | PBXFileReference | `WeaveTheme.swift` |
| `D51600000000000000000012` | PBXFileReference | `WeaveButtons.swift` |
| `D51600000000000000000013` | PBXFileReference | `BalanceCard.swift` |
| `D51600000000000000000014` | PBXFileReference | `ConfirmSheetStyle.swift` |
| `D51600000000000000000015` | PBXFileReference | `PrivacyChoice.swift` |
| `D51600000000000000000016` | PBXFileReference | `FeedCard.swift` |
| `D51600000000000000000017` | PBXFileReference | `StatusBanner.swift` |
| `D51600000000000000000018` | PBXFileReference | `DesignAssets.xcassets` (folder.assetcatalog), child of group `…0001` |
| `D51600000000000000000021` … `28` | PBXBuildFile | one per file reference above, same order (`…21` → `…11`, … `…28` → `…18`). `…28` is in the Resources phase. |

`README.md`, this file, and `IconSource/` aren't in the project.

### Checking the merge

```sh
grep -c D5160000 Weave.xcodeproj/project.pbxproj    # 20 lines (17 new + 3 extended)
grep -c 'ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon' Weave.xcodeproj/project.pbxproj   # 2
plutil -lint Weave.xcodeproj/project.pbxproj
xcodebuild -scheme Weave -sdk iphonesimulator -configuration Debug -derivedDataPath build build
```

## Component → screen mapping

The strings below come from `Requirements/acceptance-criteria.md` and the current screens. Screens keep passing their own text, and component identifiers keep the existing IDs.

| Screen | Component | Replaces / used for | Text the screen passes | Identifiers to forward |
| --- | --- | --- | --- | --- |
| Group (`GroupView`) | `BalanceCard` | the "GROUP BALANCE" VStack | `label`, `amount: "\(group.balance) credits"` (GROUP-01 "40 credits", EXT-02 "30 credits") | `amountIdentifier: "group.balance"` |
| Group | `.buttonStyle(.weavePrimary)` | the Retry button in the error state | "Retry" | keep `.accessibilityIdentifier("group.retry")` on the Button |
| Group | `PrimaryButton(showsArrow: true)` | the new "request 10 minutes" entry (M2) | screen's own copy | e.g. `extension.request` |
| Sign in (`SignInView`) | `PrimaryButton` | the Sign in button | "Sign in", `loadingTitle: "Signing in…"`, `isLoading: store.isBusy` | `identifier: "auth.signIn"` |
| Confirm sheet (M2) | `ConfirmSheetStyle` + `.weaveSheetPresentation()` | EXT-01 confirmation | `summary: "10 minutes · 10 credits"`, confirm and cancel titles | `summaryIdentifier`, `confirmIdentifier`, `cancelIdentifier` |
| Confirm sheet | `isConfirming` | EXT-03 double tap | none | Confirm is disabled while loading. This is UI-level only; the server must still stay idempotent. |
| Extension banner (M2/M3) | `StatusBanner(kind: .active)` | EXT-02 | `title: "Extension active, ends at HH:MM"`, optional `chip` | `identifier` (title text) |
| Extension banner | `StatusBanner(kind: .caution)` | CREDIT-02 | "Not enough group credits" | `identifier` |
| Extension banner | `StatusBanner(kind: .critical)` | RECOV-01 | "Couldn't start extension", optional `detail` | `identifier`, `detailIdentifier` |
| Privacy choice (M4) | `PrivacyChoice` | PRIV-01, SHARE-01 | "Keep Private", "Share with Group", details, `defaultBadge` | `privateIdentifier`, `shareIdentifier`. Start the binding at `.keepPrivate`. |
| Privacy choice | `PrimaryButton` / `SecondaryButton` | Continue, Post, Cancel | screen's own copy | `identifier` |
| Feed (M4) | `FeedCard` | SHARE-02 | `memberName`, `text` (the edited card), `timestamp`, `tags` | `identifier` (card), `textIdentifier` (body) |
| Screen backgrounds | `WeaveTheme.Colors.background` | `WeaveStyle.cream` | none | none |

### Things to know when adopting

- **`WeaveStyle` vs `WeaveTheme`.** `WeaveStyle` (in `WeaveApp.swift`) still exists, and both compile side by side. Switch a screen to `WeaveTheme` when you touch it. The new palette is darker and bolder, so expect Kane screenshots to change, though not the text.
- **Exact text.** No component adds, changes, or combines text. `BalanceCard` draws "40 credits" as one `Text` (two runs joined with `+`), so a text query still finds "40 credits".
- **PrivacyChoice labels.** Each card's accessibility label is exactly its title, and the detail is its value. Tap "Keep Private" or "Share with Group" by text or by identifier.
- **Containers.** `BalanceCard`, `FeedCard`, and `StatusBanner` use `.accessibilityElement(children: .contain)`, so their inner texts stay separate elements.
- **`LocalConfiguration.swift`.** This worktree has a gitignored placeholder with empty values, for compile checks only. It is not committed, and `Scripts/build-sim.sh` overwrites it.

## App icon

`WeaveApp/DesignSystem/DesignAssets.xcassets/AppIcon.appiconset` holds three 1024×1024 opaque PNGs: three pastel rings (mint, periwinkle, peach) woven over and under each other, one ring per study-group member.

| File | Appearance | Background |
| --- | --- | --- |
| `AppIcon.png` | default | brand green `#2D6A4F` |
| `AppIcon-Dark.png` | dark | `#0B0B0C` |
| `AppIcon-Tinted.png` | tinted (iOS 18+) | black, grayscale rings |

**Before merging:** if main has added its own asset catalog with an `AppIcon` set, keep only one `AppIcon`, or the build fails with a duplicate-name error. Either delete main's `AppIcon.appiconset`, or move this one into main's catalog and drop `D51600000000000000000018` / `…0028`. Other images (colors, symbols) can live in either catalog.

The PNGs are generated by `IconSource/make_app_icon.swift`, a CoreGraphics script that isn't in the app target. To regenerate them, run `swift WeaveApp/DesignSystem/IconSource/make_app_icon.swift WeaveApp/DesignSystem/DesignAssets.xcassets/AppIcon.appiconset`.

## Verification done on this branch

- `xcodebuild -scheme Weave -sdk iphonesimulator -configuration Debug -derivedDataPath build-design build`: succeeded, no warnings.
- All 9 preview samples rendered in light and dark mode on a throwaway simulator that was deleted afterwards. The harness was outside the repo.
- App icon: the build produces `Assets.car` with AppIcon (default, dark, tinted), and `Info.plist` has `CFBundleIconName = AppIcon`.
- No Kane runs. Nothing user-facing on a screen changed.
