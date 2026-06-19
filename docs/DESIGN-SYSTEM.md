# Cleanroom macOS — Design System

> Reverse-engineered from the Nuclara genomic-data dashboard references.  
> Every token and every component derives directly from those images.

---

## 1. Visual Style Analysis

### What the References Show

| Image | Surface | Dominant Colour | Typography | Pattern |
|-------|---------|-----------------|------------|---------|
| 1 & 4 | Vivid purple/lavender page background; large pale-mint card floating on it | `#A78BFA`-ish purple BG, `#E8F5E8`-ish mint card | Large *light-weight serif* stat numbers; all-caps tiny sans labels | 4-column stat grid with horizontal rule under each number |
| 2 | Three fully-saturated solid-colour cards | Forest `#3D7A58`, Violet `#7C5CE8`, Amber `#D97706` | All-caps 10px tag label; 48–52px serif metric; 13px sans body | White pill "Learn More →" button at card bottom |
| 3 | Editorial multi-zone page | Salmon `#F59E6B`, Lavender `#C4A8E8`, Dark forest `#1A2B1A` | Serif headlines + sans body; editorial hierarchy | Inline progress bars, badge labels, "SCROLL DOWN" text |

### Recurring Principles Across All References

1. **Colour as content** — solid, saturated colours are the dominant surface treatment. No gradients.
2. **Flat cards, zero elevation** — depth is implied by colour contrast, not drop-shadows.
3. **Type scale polarisation** — extreme size gap between display numbers (~52px) and micro labels (~10px). Almost nothing lives in the middle.
4. **All-caps tracking** — every secondary label is uppercase with `letter-spacing: 0.5–0.8`.
5. **Orange as the single interactive signal** — the only orange on every page is an active state, a CTA pill, or a primary action. Nothing else is orange.
6. **Horizontal rule after stats** — a 1px line beneath each stat column grounds the floating serif number.
7. **White pill CTA on colour** — every primary action inside a coloured card is a fully-rounded white capsule, text coloured to match the card.
8. **Dark sidebar / light content** — the navigation panel is always the darkest element.
9. **Tinted near-whites** — background surfaces are never pure white; always slightly tinted (mint green tint for content areas, lavender tint for the canvas).

---

## 2. Design DNA Summary

```
CORE IDENTITY
  Tone: Scientific precision meets editorial warmth.
  Feel: Premium data tool — confident, legible, never cluttered.

PALETTE LOGIC
  Background canvas  = pale lavender (evokes the vivid purple page from refs)
  Content surface    = pale mint green (the large card from refs 1/4)
  Sidebar            = deep forest ink (#0F1A0F)
  CTA / active state = warm orange (#F59E0B) — used sparingly and consistently
  Category accents   = six distinct saturated colours (forest, violet, amber, slate, rose, teal)

TYPOGRAPHY LOGIC
  Display (stats)    = light-weight system serif, 44–52px
  Headlines          = semibold sans, 16–26px
  Body               = regular sans, 13px
  Labels             = all-caps, 10px, semibold, +0.6 letter-spacing
  Terminal           = monospaced, 11–12px

INTERACTION LOGIC
  Hover              = scale(1.012–1.04) on cards; subtle bg tint on rows
  Press              = scale(0.98) snap
  Selection (nav)    = orange 18% alpha bg + orange icon + semibold label
  Active filter chip = solid orange fill, white text (pill capsule)
```

---

## 3. Design Tokens

All tokens live in `macos/CleanroomApp/DesignSystem.swift` under the `DS` namespace.

### Color Tokens (`DS.C`)

| Token | Hex | Usage |
|-------|-----|-------|
| `canvas` | `#F4F0FE` | Outer window background — pale lavender |
| `surfaceMint` | `#E8F5E8` | Header stats + filter bar surface |
| `surfaceRaised` | `#F0FAF0` | Hover state on mint surface |
| `sidebarBg` | `#0F1A0F` | Sidebar background |
| `terminalBg` | `#0B160B` | Output panel background |
| `brandPurple` | `#7C3AED` | Brand anchor colour |
| `brandLavender` | `#A78BFA` | Interactive / icon on dark |
| `ctaOrange` | `#F59E0B` | Primary CTA, active filter chip |
| `ctaOrangeHov` | `#D97706` | CTA hover state |
| `cardForest` | `#3D7A58` | Caches card |
| `cardViolet` | `#7C5CE8` | Node Modules card |
| `cardAmber` | `#D97706` | Downloads card |
| `cardSlate` | `#2D5A8E` | Large Files card |
| `cardRose` | `#BE3A5A` | Archives card |
| `cardTeal` | `#0E7490` | Developer card |
| `cardBark` | `#7D5A3C` | Screenshots card |
| `cardCharcoal` | `#2E3A4A` | Trash card |
| `textPrimary` | `#0D1A0D` | Main text (green-tinted near-black) |
| `textSecondary` | `#475569` | Secondary / label text |
| `textMuted` | `#94A3B8` | Placeholder / disabled |
| `textOnDark` | `#E8F5E8` | Text on sidebar / terminal |
| `positive` | `#22C55E` | Up-trend indicator |
| `negative` | `#EF4444` | Down-trend indicator |
| `divider` | `rgba(0,0,0,0.07)` | Divider on light surfaces |
| `dividerOnDark` | `rgba(255,255,255,0.08)` | Divider on dark surfaces |

### Typography Tokens (`DS.T`)

| Token | Size | Weight | Design | Usage |
|-------|------|--------|--------|-------|
| `display(46)` | 46px | Light | Serif | Stat column numbers |
| `display(52)` | 52px | Light | Serif | Category card metrics |
| `h1` | 26px | Semibold | Default | Section headings |
| `h2` | 20px | Semibold | Default | Card headings |
| `h3` | 16px | Semibold | Default | Sub-headings |
| `body` | 13px | Regular | Default | Body text |
| `bodySm` | 12px | Regular | Default | Secondary body |
| `label` | 12px | Medium | Default | Labels |
| `tag` | 10px | Semibold | Default | All-caps micro labels; use with `.kerning(0.6)` |
| `mono` | 12px | Regular | Monospaced | Terminal output |
| `monoSm` | 11px | Regular | Monospaced | Status bar text |

### Spacing Tokens (`DS.Sp`)

| Token | Value |
|-------|-------|
| `xs` | 4px |
| `sm` | 8px |
| `md` | 12px |
| `lg` | 16px |
| `xl` | 24px |
| `xxl` | 32px |

### Radius Tokens (`DS.R`)

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 3px | Icon buttons |
| `sm` | 6px | Nav rows, inputs |
| `md` | 10px | Small cards |
| `card` | 16px | Category cards (matches reference) |
| `pill` | 999px | CTAs, filter chips (fully rounded) |

### Shadow Tokens (`DS.Sh`)

| Token | Color | Radius | Y |
|-------|-------|--------|---|
| `card` | `rgba(0,0,0,0.10)` | 18px | 5px |
| `subtle` | `rgba(0,0,0,0.05)` | 6px | 2px |

Category cards additionally use a **colour-matched glow** (`card.color.opacity(0.25), radius: 18, y: 6`) — this is how the reference gives cards physical presence without using generic grey shadows.

### Animation Tokens (`DS.Ani`)

| Token | Value | Usage |
|-------|-------|-------|
| `snap` | `easeOut(0.13s)` | Hover state changes, chip selection |
| `std` | `easeInOut(0.22s)` | Panel open/close, content transitions |
| `spring` | `spring(response: 0.32, damping: 0.72)` | Card hover scale, button press |

---

## 4. Theme Architecture

The design system is structured as a single Swift enum `DS` with nested enums for each token category. This provides:

- **Namespaced access**: `DS.C.ctaOrange`, `DS.T.display(46)`, `DS.Sp.xl`
- **Compiler-checked**: missing or misspelled tokens are compile errors
- **Zero runtime overhead**: all values are static constants

### Extending for Dark Mode

Add adaptive tokens alongside light-mode tokens:

```swift
// Future: add @Environment(\.colorScheme) checks
extension DS.C {
    static func adaptive(light: Color, dark: Color) -> Color {
        // Use NSApp.effectiveAppearance to branch
    }
    static var canvasAdaptive: Color { adaptive(light: canvas, dark: Color(hex: "#1A1230")) }
}
```

---

## 5. Component Library

### PillBtn
**Three styles**: `.primary` (orange fill), `.ghost` (outline), `.secondary` (mint fill).

All pill buttons:
- Use `Capsule()` shape (fully rounded — `DS.R.pill`)
- Scale `1.02×` on hover with `DS.Ani.snap`
- Foreground: white on primary, `textPrimary` on ghost/secondary

```
States:
  Default  → fill(ctaOrange)            text: white
  Hover    → fill(ctaOrangeHov)         scale: 1.02
  Pressed  → scale: 0.98 (AppKit default)
  Disabled → opacity(0.4)
```

### FilterChip
Replicates the OVERVIEW / PMSA / TOXICITY pill tabs from references 1 & 4.

```
Active   → fill(ctaOrange), text: white, capsule shape
Inactive → transparent bg, text: textSecondary
Hover    → fill(divider)
```

### NavRow (Sidebar item)
```
Default  → transparent bg, icon opacity 0.60, label opacity 0.72
Hover    → white(0.05) bg fill
Active   → ctaOrange(0.18) bg fill, orange icon, white label, semibold weight
```

### CategoryCardView
Full-height coloured card. Directly derived from the three cards in reference 2.

```
Structure (top → bottom):
  1. All-caps tag label        — white(0.65), 10px semibold, +0.8 tracking
  2. Large serif metric        — white, 52px light serif ("—" until populated)
  3. Tagline body              — white(0.72), 13px regular
  4. [flex spacer]
  5. White pill "Inspect →"    — white bg, card-colour text, fully rounded

Hover state: scale(1.012), spring animation
Card shadow: colour-matched glow (card.color × 0.25 at radius 18, y 6)
```

### StatCell
The most distinctively reference-faithful component. Four cells in a horizontal row.

```
Structure (top → bottom):
  1. Display number  — 46px light serif
  2. Trend badge     — green capsule (↑) or red capsule (↓), 9px semibold
  3. All-caps label  — 10px semibold, +0.6 tracking, textSecondary
  4. 1px rule        — divider colour (KEY visual — horizontal rule under each stat)
```

### OutputPanel
Dark-forest terminal panel, collapsible.

```
Chrome bar (always visible):
  • 7px status dot — orange (running) / green (idle)
  • Monospaced status text
  • Three icon buttons: Copy Apply, Clear, Collapse/Expand

Output area (collapsible, 240px):
  • Background: terminalBg (#0B160B)
  • Font: mono 12px, textOnDark × 0.88
  • Text selection enabled
  • Auto-scrolls to bottom on output change
```

### SidebarSection
Groups nav items with an all-caps 10px header label.

---

## 6. Interaction Guidelines

### Hover
- **Cards**: scale `1.012` → spring animation. Pill button inside scales `1.04`.
- **Nav rows**: subtle `white(0.05)` background fill.
- **Pill buttons**: scale `1.02` + slightly darker fill (`ctaOrangeHov`).
- **Icon buttons**: `white(0.08)` fill on dark surfaces, `divider` fill on light.

### Selection
- Nav items: `ctaOrange(0.18)` background + orange icon + semibold label text.
- Filter chips: solid `ctaOrange` fill + white text.

### Running state
- Status dot pulses between `ctaOrange` (running) and `positive` (done).
- Sidebar shows a small circular `ProgressView` tinted `brandLavender`.
- Output panel opens automatically when a command finishes.

### Keyboard / Trackpad
- All buttons respond to Enter/Space.
- `ScrollView` areas support two-finger trackpad scroll.
- The output panel is text-selectable for copy-paste.

---

## 7. Motion System

| Scenario | Animation |
|----------|-----------|
| Filter chip selection | `DS.Ani.snap` — instant-feeling, 0.13s |
| Nav row selection | `DS.Ani.snap` |
| Card hover scale | `DS.Ani.spring` (response 0.32, damping 0.72) |
| Output panel open/close | `DS.Ani.std` — 0.22s easeInOut |
| Category-filter transition | `DS.Ani.snap` (LazyVGrid reflows) |

**Principle**: Micro-interactions are instant (`snap`). Structural changes are smooth (`std`). Physical interactions are spring-based.

---

## 8. Accessibility Standards

- All interactive elements have `.plain` button style for proper focus ring support.
- Text is `.textSelection(.enabled)` in the output panel for keyboard copy.
- Colour is **never the only differentiator** — icons, labels, and shapes accompany every colour signal.
- Status dot uses shape (circle) + colour (orange vs green) together.
- Trend badges use directional arrows + colour together.
- All type sizes ≥ 10px (the smallest is the `tag` font at 10px semibold, used only for labels, never body text).
- `minimumScaleFactor(0.55–0.65)` on display numbers prevents clipping on narrow cards.

---

## 9. Screen-by-Screen Redesign

### Main Window

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ ██████ SIDEBAR (220px dark)  │  CANVAS (flex, pale lavender)                │
│ ██████                       │                                              │
│ ██████  sparkles  cleanroom  │  ┌──── MINT SURFACE ───────────────────────┐ │
│ ██████  ─────────────────── │  │  Browse all storage        [Refresh][→] │ │
│ ██████  OVERVIEW             │  │                                         │ │
│ ██████  ● Dashboard          │  │  156.2 GB │ 8.4 GB │ 12,847 │ Never   │ │
│ ██████  ○ Doctor             │  │  DISK USED  RECLAIMABLE  FILES  SCAN   │ │
│ ██████  ○ Storage Map        │  │  ─────────  ──────────  ──────  ─────  │ │
│ ██████  ○ Scan               │  └─────────────────────────────────────────┘ │
│ ██████  ○ Review             │                                              │
│ ██████  ○ Plan               │  [OVERVIEW] [CACHES] [DEVELOPER] [DOWNLOADS] │
│ ██████                       │                                              │
│ ██████  FIND                 │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│ ██████  ○ Large Files        │  │ CACHES   │  │NODE MODS │  │DOWNLOADS │  │
│ ██████  ○ Duplicates         │  │  —       │  │  —       │  │  —       │  │
│ ██████  ○ Broken Links       │  │ App &    │  │ Orphaned │  │ Old DMGs │  │
│ ██████  ○ Quarantine         │  │ system   │  │ npm      │  │ and inst │  │
│ ██████                       │  │ [Inspect→│  │ [Inspect→│  │ [Inspect→│  │
│ ██████  SYSTEM               │  └──────────┘  └──────────┘  └──────────┘  │
│ ██████  ○ Xcode              │                                              │
│ ██████  ○ Backups            │  ● Ready     [Copy Apply]  [Clear]  [∨]      │
│ ██████  ○ System Data        │  $ cleanroom overview                        │
│ ██████                       │  → /Library/Caches: 2.3 GB                  │
│ ██████  v0.65.0              │                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Filter States
- **OVERVIEW** active: all 8 category cards shown in a 3-column adaptive grid.
- **CACHES** active: only the Caches card shown.
- **DEVELOPER** active: Node Modules + Developer cards.
- etc.

---

## 10. Implementation Notes

### File Structure

```
macos/CleanroomApp/
├── DesignSystem.swift     ← All DS tokens (Color, Typography, Spacing, Radius,
│                             Shadow, Animation, Layout)
├── CleanroomViews.swift   ← AppState observable + all SwiftUI views
└── main.swift             ← 44-line AppKit entry point (NSHostingView wrapper)
```

### Build

```bash
make macos-app
# or directly:
swiftc -O \
  -framework AppKit -framework SwiftUI \
  macos/CleanroomApp/DesignSystem.swift \
  macos/CleanroomApp/CleanroomViews.swift \
  macos/CleanroomApp/main.swift \
  -o dist/Cleanroom.app/Contents/MacOS/Cleanroom
```

### Adding a New Category Card

1. Add a `CleanCategory(...)` entry to `AppState.categories` in `CleanroomViews.swift`.
2. Pick a card colour from `DS.C.card*` or add a new hex colour to `DS.C`.
3. No other changes needed — `LazyVGrid` adapts automatically.

### Populating Stats from CLI

After running `cleanroom overview`, parse the output and update `state.stats`:

```swift
// Example: update after overview runs
state.stats[0].value = "156.2 GB"
state.stats[1].value = "8.4 GB"
state.stats[1].trend = "+1.2 GB"
state.stats[1].trendUp = false
```

---

## Design Manifesto

> **cleanroom is a precision instrument, not a dashboard.**

The visual language communicates one thing above all else: **confidence**.  
Every number is large because it deserves to be read.  
Every colour is saturated because it earns its place.  
The orange is singular — it means *do something*.  
The dark sidebar means *this is a serious tool*.  
The pale mint surface means *your data is safe here*.

**Five laws for every future screen:**

1. **Colour first, border never.** Use a tinted surface or a solid card colour to create hierarchy. Never use a rounded border to create a card.
2. **One orange per screen.** The CTA colour must never compete. If everything is orange, nothing is orange.
3. **Serif for numbers, sans for everything else.** The light-weight serif display font is reserved exclusively for quantitative values.
4. **Dark panel, light content.** The sidebar is always the darkest element in the window. Never invert this.
5. **Labels are always uppercase, never decorative.** A label that names a category earns a different visual weight from a label that describes it.
