# Weave design system

Shared SwiftUI tokens and components for Weave. Big rounded tiles, heavy SF Pro type, pastel color blocks, and a near-black dark mode. It borrows the look of bold consumer apps but leaves out points, ranks, and streaks.

**Rule for every component:** it never contains user-visible text. Feature screens pass every string in, because Kane tests check the exact text on screen. Components that show a string Kane checks also take an optional accessibility identifier.

Each file has `#Preview`s for light and dark mode with sample data.

## Tokens: `WeaveTheme.swift`

| Token | Values |
| --- | --- |
| `WeaveTheme.Colors` | `background`, `surface`, `surfaceMuted`, `ink`, `inkSecondary`, `inkInverse`, `separator`, `brand` (deep green), `onBrand`, `liveCapsule`, `onPastel`. Each one switches between light and dark. |
| `WeaveTheme.Pastel` | `mint` (private, active), `periwinkle` (share, confirm), `peach` / `pink` / `lime` (feed), `butter` (caution), `coral` (critical). The same in both modes, always with `onPastel` text. `Pastel.forMember(_:)` gives a stable color for a name. |
| `WeaveTheme.TextStyle` | `hero` 64, `display` 34, `title` 24 (heavy); `headline` 17, `label` 13, `chip` 12 (semibold); `body` 16 (medium). Apply with `.weaveFont(_:)`. Each scales with Dynamic Type and uses tabular figures. |
| `WeaveTheme.Spacing` | `xxs` 4, `xs` 8, `tileGap` 10, `sm` 12, `md` 16, `lg` 20, `xl` 28, `xxl` 44 |
| `WeaveTheme.Radius` | `field` 16, `banner` 22, `tile` 28, `sheet` 36. Always `.continuous`. |

View helpers: `.weaveFont(_:)`, `.weaveTile(_ fill:padding:)`, `.weaveIdentifier(_:)` (sets an ID only when one is given), and `.weaveSheetPresentation()`.

`WeaveChip(_ text:systemImage:style:identifier:)` is a small capsule tag such as "10 min". Styles: `.dark`, `.light` (for use on pastels), `.muted`, `.mint`. `identifier` is set on the chip text.

The older `WeaveStyle` (`ink`, `cream`) in `WeaveApp.swift` still exists. Screens can move to `WeaveTheme` one at a time.

## Components

### BalanceCard (Group screen)

The group's shared credits, with the number as the main element.

| Parameter | Type | Notes |
| --- | --- | --- |
| `label` | `String` | e.g. "Group balance" |
| `amount` | `String` | e.g. "40 credits". Drawn as a large "40" and a smaller " credits", but still **one** text element, so tests read exactly "40 credits". |
| `caption` | `String?` | optional line under the number |
| `fraction` | `Double?` | 0...1, shown as a five-segment meter. `nil` hides it. |
| `memberNames` | `[String]` | optional initials row |
| `style` | `.standard` / `.brand` | white or charcoal tile, or deep green |
| `amountIdentifier` | `String?` | e.g. `"group.balance"`, set on the amount text |
| `identifier` | `String?` | set on the card container |

### PrimaryButton and SecondaryButton (every screen)

Capsule buttons, 58pt tall. Primary is solid ink. Secondary is a muted grey.

| Parameter | Type | Notes |
| --- | --- | --- |
| `_ title` | `String` | |
| `isLoading` | `Bool` | Primary only. Shows a spinner, keeps the size, ignores taps. |
| `loadingTitle` | `String?` | Primary only, e.g. "Confirming…" |
| `showsArrow` | `Bool` | Primary only. Adds a round ↗ accessory at the end. |
| `identifier` | `String?` | |
| `action` | `() -> Void` | |

For existing `Button` calls, use `.buttonStyle(.weavePrimary)` or `.buttonStyle(.weaveSecondary)`.

### ConfirmSheetStyle (Confirm sheet)

Sheet content for "10 minutes · 10 credits" confirmations. Present it with `.weaveSheetPresentation()`.

| Parameter | Type | Notes |
| --- | --- | --- |
| `title` | `String` | |
| `message` | `String?` | |
| `summary` | `String` | e.g. "10 minutes · 10 credits", shown in a periwinkle block |
| `confirmTitle`, `cancelTitle` | `String` | |
| `isConfirming` | `Bool` | Puts Confirm into its loading state and disables Cancel |
| `confirmingTitle` | `String?` | |
| `titleIdentifier`, `summaryIdentifier`, `confirmIdentifier`, `cancelIdentifier` | `String?` | |
| `onConfirm`, `onCancel` | `() -> Void` | |

### PrivacyChoice (Privacy choice)

Keep Private vs Share with Group as two overlapping cards. Keep Private is the mint card with the default badge. The screen should start with `.keepPrivate` selected. The selected card moves to the front. Each card's accessibility label is exactly its title.

| Parameter | Type | Notes |
| --- | --- | --- |
| `selection` | `Binding<PrivacyChoice.Option>` | `.keepPrivate` or `.shareWithGroup` |
| `privateTitle`, `privateDetail` | `String` | |
| `shareTitle`, `shareDetail` | `String` | |
| `defaultBadge` | `String?` | e.g. "Default", shown on the private card |
| `privateIdentifier`, `shareIdentifier` | `String?` | |

### FeedCard (Feed)

One posted activity card. The tile color and initials come from the member name. No likes or reactions.

| Parameter | Type | Notes |
| --- | --- | --- |
| `memberName` | `String` | |
| `text` | `String` | the card body |
| `timestamp` | `String?` | already formatted by the screen |
| `tags` | `[String]` | optional chips, e.g. `["10 min"]` |
| `identifier` | `String?` | set on the card container |
| `textIdentifier` | `String?` | set on the body text |

### StatusBanner (Extension banner)

| Parameter | Type | Notes |
| --- | --- | --- |
| `kind` | `.active` / `.info` / `.caution` / `.critical` | `.active` is a dark live-activity capsule, for "Extension active, ends at HH:MM". The others are periwinkle, butter, and coral blocks, e.g. "Not enough group credits" (caution), "Couldn't start extension" (critical). |
| `title` | `String` | |
| `detail` | `String?` | optional second line |
| `chip` | `String?` | `.active` only, e.g. "10 min" |
| `identifier` | `String?` | set on the title text |
| `detailIdentifier` | `String?` | set on the detail text |

## Example

```swift
BalanceCard(
    label: "Group balance",
    amount: "\(group.balance) credits",
    caption: "Shared by \(group.groupName)",
    fraction: Double(group.balance) / 50,
    memberNames: group.members.map(\.name),
    amountIdentifier: "group.balance"
)
```

See [MERGE_NOTES.md](MERGE_NOTES.md) for merging with main. The logo, app icon source, and brand usage rules are in [Brand/BRAND.md](Brand/BRAND.md).

## Xcode project

`Weave.xcodeproj` lists every file by hand, with no synchronized folders. The design system files are registered with their own ID prefix, `D516…`, so they don't collide with other branches' IDs. When you add a file here, add a `PBXFileReference` and a `PBXBuildFile`, add the reference to group `D51600000000000000000001`, and add the build file to Sources phase `A00000000000000000000005`.
