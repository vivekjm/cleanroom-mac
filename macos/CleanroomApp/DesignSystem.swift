// DesignSystem.swift — Cleanroom macOS
// Visual DNA reverse-engineered from the Nuclara genomic-data dashboard references.
//
// Reference image palette summary:
//   Image 1/4 — Vivid lavender/purple page background (#A78BFA-ish) with a pale
//               mint card (#E8F5E8-ish) holding large light-serif stat numbers.
//               Active filter pill is warm orange (#F59E0B). Trend badges are
//               green/red dots. Navigation arrows are dark filled circles.
//
//   Image 2   — Three full-color category cards:
//               Forest green #3D7A58, Medium violet #7C5CE8, Warm amber #D97706.
//               Each card: all-caps small tag, large serif metric, body text,
//               white pill "Learn More →" CTA at bottom.
//
//   Image 3   — Editorial sections: peach salmon #F59E6B, lavender #C4A8E8,
//               dark forest #1A2B1A. Mix of serif headlines + sans body.
//
// These observations drive every token below.

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: – Hex Color Initializer
// ─────────────────────────────────────────────────────────────

extension Color {
    /// Create a SwiftUI Color from a hex string, e.g. "#F4F0FE" or "F4F0FE".
    init(hex: String) {
        var s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() }
        guard s.count == 6, let v = UInt64(s, radix: 16) else { self = .gray; return }
        self.init(
            .sRGB,
            red:   Double((v >> 16) & 0xFF) / 255,
            green: Double((v >>  8) & 0xFF) / 255,
            blue:  Double( v        & 0xFF) / 255
        )
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: – Shadow View Modifier Helper
// ─────────────────────────────────────────────────────────────

extension View {
    func cardShadow(_ cfg: DS.ShadowCfg) -> some View {
        shadow(color: cfg.color, radius: cfg.radius, x: 0, y: cfg.y)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: – DS (Design System namespace)
// ─────────────────────────────────────────────────────────────

enum DS {

    // ─── Colors ─────────────────────────────────────────────────────────────
    enum C {
        // ── Canvas & surfaces ──────────────────────────────────────────────
        /// Pale lavender outer window canvas (echoes the purple-page from ref 1/4)
        static let canvas        = Color(hex: "#F4F0FE")
        /// Light mint green — primary content surface (the large card from ref 1/4)
        static let surfaceMint   = Color(hex: "#E8F5E8")
        /// Slightly-lighter raised surface for hover states on the mint surface
        static let surfaceRaised = Color(hex: "#F0FAF0")
        /// Dark-forest ink — sidebar background (ref image 3 dark section)
        static let sidebarBg     = Color(hex: "#0F1A0F")
        /// Even deeper forest — review summary panel background
        static let summaryBg     = Color(hex: "#0B160B")

        // ── Brand ──────────────────────────────────────────────────────────
        /// Dominant brand purple (the vivid background colour in ref images 1 & 4)
        static let brandPurple   = Color(hex: "#7C3AED")
        /// Softer lavender — interactive purple, icons on dark backgrounds
        static let brandLavender = Color(hex: "#A78BFA")
        /// Bright mint spark — positive indicators
        static let brandMint     = Color(hex: "#34D399")

        // ── CTA Orange — the OVERVIEW active-pill colour (ref images 1 & 4) ─
        static let ctaOrange     = Color(hex: "#F59E0B")
        static let ctaOrangeHov  = Color(hex: "#D97706")
        static let ctaOrangeSoft = Color(hex: "#FEF3C7")

        // ── Category card backgrounds (extracted from ref image 2) ─────────
        /// Forest green — PSMA-Targeted card
        static let cardForest   = Color(hex: "#3D7A58")
        /// Medium violet — Somatostatin Analogue card
        static let cardViolet   = Color(hex: "#7C5CE8")
        /// Warm amber — Cytotoxicity card
        static let cardAmber    = Color(hex: "#D97706")
        /// Additional palette slots for extra cleanroom categories
        static let cardSlate    = Color(hex: "#2D5A8E")
        static let cardRose     = Color(hex: "#BE3A5A")
        static let cardTeal     = Color(hex: "#0E7490")
        static let cardBark     = Color(hex: "#7D5A3C")
        static let cardCharcoal = Color(hex: "#2E3A4A")

        // ── Text ───────────────────────────────────────────────────────────
        /// Near-black with a subtle green tint — primary text on light surfaces
        static let textPrimary   = Color(hex: "#0D1A0D")
        /// Medium slate — secondary text, labels
        static let textSecondary = Color(hex: "#475569")
        /// Muted — placeholder, disabled text
        static let textMuted     = Color(hex: "#94A3B8")
        /// On-dark text — used on sidebarBg / report panel background
        static let textOnDark    = Color(hex: "#E8F5E8")
        static let textWhite     = Color.white

        // ── Semantic ───────────────────────────────────────────────────────
        static let positive      = Color(hex: "#22C55E")
        static let negative      = Color(hex: "#EF4444")
        static let caution       = Color(hex: "#F59E0B")

        // ── Structural ─────────────────────────────────────────────────────
        static let divider       = Color.black.opacity(0.07)
        static let dividerOnDark = Color.white.opacity(0.08)
    }

    // ─── Typography ──────────────────────────────────────────────────────────
    enum T {
        // Display — light-weight serif, the large stat numerals in the reference
        static func display(_ size: CGFloat = 52) -> Font {
            .system(size: size, weight: .light, design: .serif)
        }

        // Headings (sans-serif)
        static let h1 = Font.system(size: 26, weight: .semibold)
        static let h2 = Font.system(size: 20, weight: .semibold)
        static let h3 = Font.system(size: 16, weight: .semibold)

        // Body
        static let body   = Font.system(size: 13)
        static let bodySm = Font.system(size: 12)

        // Labels
        static let label = Font.system(size: 12, weight: .medium)
        /// All-caps micro label — used with .kerning(0.6+); the small category
        /// labels sitting above numbers in the reference cards
        static let tag   = Font.system(size: 10, weight: .semibold)

        // Monospaced — compact path snippets when needed
        static let mono   = Font.system(size: 12, design: .monospaced)
        static let monoSm = Font.system(size: 11, design: .monospaced)
    }

    // ─── Spacing ────────────────────────────────────────────────────────────
    enum Sp {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 12
        static let lg:  CGFloat = 16
        static let xl:  CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // ─── Corner Radius ───────────────────────────────────────────────────────
    enum R {
        static let xs:   CGFloat = 3
        static let sm:   CGFloat = 6
        static let md:   CGFloat = 10
        /// Card radius — matches the ~16px radius visible on ref-image-2 cards
        static let card: CGFloat = 16
        /// Pill — fully rounded, used for CTA buttons and filter chips
        static let pill: CGFloat = 999
    }

    // ─── Shadows ─────────────────────────────────────────────────────────────
    /// Shadow configuration value-type for use with `View.cardShadow(_:)`
    struct ShadowCfg {
        let color: Color; let radius: CGFloat; let y: CGFloat
    }
    enum Sh {
        /// Default card shadow — coloured glow matching the card's accent
        static let card   = ShadowCfg(color: .black.opacity(0.10), radius: 18, y: 5)
        /// Subtle — hover states, inputs
        static let subtle = ShadowCfg(color: .black.opacity(0.05), radius: 6,  y: 2)
    }

    // ─── Animation ───────────────────────────────────────────────────────────
    enum Ani {
        /// Instant feedback snap — hover state changes, chip selection
        static let snap:   Animation = .easeOut(duration: 0.13)
        /// Standard transition — panel opens, content swaps
        static let std:    Animation = .easeInOut(duration: 0.22)
        /// Spring — card hover scale, button presses
        static let spring: Animation = .spring(response: 0.32, dampingFraction: 0.72)
    }

    // ─── Layout ──────────────────────────────────────────────────────────────
    enum Layout {
        static let sidebarW:  CGFloat = 220
        static let minWidth:  CGFloat = 1080
        static let minHeight: CGFloat = 700
        static let cardMinW:  CGFloat = 240
        static let summaryH:  CGFloat = 240
    }
}
