// CleanroomViews.swift — Cleanroom macOS
// Complete SwiftUI redesign derived from the Nuclara genomic-data design system.

import SwiftUI
import AppKit

// ═══════════════════════════════════════════════════════════════
// MARK: – Domain Types
// ═══════════════════════════════════════════════════════════════

struct StorageStat: Identifiable {
    let id = UUID()
    var label: String
    var value: String
    var trend:  String? = nil
    var trendUp: Bool?  = nil
}

struct CleanCategory: Identifiable {
    let id = UUID()
    var title:   String
    var tagline: String
    var icon:    String
    var color:   Color
    var args:    String
    var result:  String? = nil
}

enum NavDest: Hashable {
    case dashboard
    case run(title: String, args: String)
}

// ═══════════════════════════════════════════════════════════════
// MARK: – App State
// ═══════════════════════════════════════════════════════════════

@MainActor
final class AppState: ObservableObject {

    @Published var dest:             NavDest = .dashboard
    @Published var filter:           String  = "all"
    @Published var output:           String  = "cleanroom ready.\n"
    @Published var running:          Bool    = false
    @Published var status:           String  = "Ready"
    @Published var outputOpen:       Bool    = false
    @Published var showLeftovers:    Bool    = false
    @Published var showApplyConfirm: Bool    = false
    @Published var cardOffset:       Int     = 0

    @Published var stats: [StorageStat] = [
        StorageStat(label: "Disk Used",   value: "—"),
        StorageStat(label: "Reclaimable", value: "—"),
        StorageStat(label: "Files Found", value: "—"),
        StorageStat(label: "Last Scan",   value: "Never"),
    ]

    let categories: [CleanCategory] = [
        CleanCategory(title: "Caches",       tagline: "App & system caches accumulating silently",      icon: "xmark.bin.fill",        color: DS.C.cardForest,   args: "caches"),
        CleanCategory(title: "Node Modules", tagline: "Orphaned node_modules, stale npm/pnpm caches",   icon: "shippingbox.fill",      color: DS.C.cardViolet,   args: "nodes --limit 30 --days 30"),
        CleanCategory(title: "Downloads",    tagline: "Old downloads, DMGs, and forgotten installers",  icon: "arrow.down.to.line",    color: DS.C.cardAmber,    args: "downloads --limit 30 --days 30"),
        CleanCategory(title: "Large Files",  tagline: "Files over 500 MB that may no longer be needed", icon: "doc.fill",              color: DS.C.cardSlate,    args: "large --limit 30 --min-mb 500"),
        CleanCategory(title: "Archives",     tagline: "Old zip archives, tar files, and disk images",   icon: "archivebox.fill",       color: DS.C.cardRose,     args: "archives --limit 30 --days 7"),
        CleanCategory(title: "Developer",    tagline: "Build artifacts, virtualenvs, and toolchains",   icon: "hammer.fill",           color: DS.C.cardTeal,     args: "clean --preset dev --preflight"),
        CleanCategory(title: "Screenshots",  tagline: "Old screenshots accumulating on Desktop",        icon: "camera.viewfinder",     color: DS.C.cardBark,     args: "screenshots --limit 30 --days 7"),
        CleanCategory(title: "Trash",        tagline: "Files waiting in macOS Trash",                   icon: "trash.fill",            color: DS.C.cardCharcoal, args: "trash"),
    ]

    let filters: [(id: String, label: String)] = [
        ("all",       "OVERVIEW"),
        ("caches",    "CACHES"),
        ("dev",       "DEVELOPER"),
        ("downloads", "DOWNLOADS"),
        ("files",     "LARGE FILES"),
        ("archives",  "ARCHIVES"),
    ]

    var cliPath = ""

    func resolveCLI() {
        if let r = Bundle.main.resourceURL {
            let b = r.appendingPathComponent("bin/cleanroom").path
            if FileManager.default.isExecutableFile(atPath: b) { cliPath = b; return }
        }
        let home = FileManager.default.homeDirectoryForCurrentUser
        for c in [
            "/opt/homebrew/bin/cleanroom",
            "/usr/local/bin/cleanroom",
            home.appendingPathComponent(".local/bin/cleanroom").path,
        ] where FileManager.default.isExecutableFile(atPath: c) {
            cliPath = c; return
        }
        cliPath = "cleanroom"
    }

    // Silently fetch overview JSON to populate stats row
    func refreshStats() {
        guard !running else { return }
        let exe = quotedCLI()
        Task.detached(priority: .background) {
            let raw = await Self.execShell("\(exe) overview --json 2>/dev/null || \(exe) overview 2>/dev/null")
            await MainActor.run { self.parseStats(raw) }
        }
    }

    private func parseStats(_ raw: String) {
        // Best-effort: scan for recognisable patterns in text/JSON output
        func grab(_ key: String) -> String? {
            let patterns = ["\"\(key)\"\\s*:\\s*\"([^\"]+)\"",
                            "\"\(key)\"\\s*:\\s*([0-9.]+[KMGT]?B?)"]
            for p in patterns {
                if let r = raw.range(of: p, options: .regularExpression),
                   let inner = raw[r].components(separatedBy: ":").last {
                    return inner.trimmingCharacters(in: .init(charactersIn: " \t\n\r\""))
                }
            }
            return nil
        }
        // Update Last Scan timestamp regardless
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        stats[3].value = formatter.string(from: Date())

        if let used = grab("disk_used") ?? grab("total_used") { stats[0].value = used }
        if let rec  = grab("reclaimable") ?? grab("recoverable") { stats[1].value = rec }
        if let fc   = grab("file_count") ?? grab("files") { stats[2].value = fc }
    }

    func run(_ args: String, title: String) {
        guard !running else { return }
        running    = true
        status     = "Running \(title)…"
        output    += "\n$ cleanroom \(args)\n"
        let cmd    = "\(quotedCLI()) \(args)"
        Task.detached(priority: .userInitiated) {
            let result = await Self.execShell(cmd)
            await MainActor.run {
                self.output    += result
                self.status     = "Done · \(title)"
                self.running    = false
                self.outputOpen = true
            }
        }
    }

    func runLeftovers(_ query: String) {
        let safe = query.replacingOccurrences(of: "'", with: "'\\''")
        run("appreview '\(safe)' --limit 40", title: "App Review: \(query)")
    }

    func copyCmd(_ cmd: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(cmd, forType: .string)
        status = "Copied to clipboard"
    }

    func quotedCLI() -> String {
        cliPath.isEmpty ? "cleanroom"
                        : "'\(cliPath.replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    func filteredCategories() -> [CleanCategory] {
        switch filter {
        case "caches":    return categories.filter { $0.title == "Caches" }
        case "dev":       return categories.filter { ["Node Modules", "Developer"].contains($0.title) }
        case "downloads": return categories.filter { ["Downloads", "Archives"].contains($0.title) }
        case "files":     return categories.filter { $0.title == "Large Files" }
        case "archives":  return categories.filter { $0.title == "Archives" }
        default:          return categories
        }
    }

    private static func execShell(_ cmd: String) async -> String {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/zsh")
        p.arguments = ["-lc", cmd]
        let pipe = Pipe()
        p.standardOutput = pipe; p.standardError = pipe
        do {
            try p.run(); p.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return (String(data: data, encoding: .utf8) ?? "") + "(exit \(p.terminationStatus))\n"
        } catch { return "Error: \(error.localizedDescription)\n" }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Root View
// ═══════════════════════════════════════════════════════════════

struct RootView: View {
    @StateObject var state = AppState()

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(state: state)
                .frame(width: DS.Layout.sidebarW)
            Rectangle()
                .fill(DS.C.dividerOnDark)
                .frame(width: 1)
                .ignoresSafeArea()
            MainPanelView(state: state)
        }
        .frame(minWidth: DS.Layout.minWidth, minHeight: DS.Layout.minHeight)
        .background(DS.C.canvas)
        .sheet(isPresented: $state.showLeftovers) {
            LeftoversSheet(state: state)
        }
        .sheet(isPresented: $state.showApplyConfirm) {
            ApplyConfirmSheet(state: state)
        }
        .onAppear {
            state.resolveCLI()
            state.refreshStats()
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Sidebar
// ═══════════════════════════════════════════════════════════════

struct SidebarView: View {
    @ObservedObject var state: AppState

    var body: some View {
        ZStack {
            DS.C.sidebarBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Brand
                HStack(spacing: DS.Sp.sm) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(DS.C.brandLavender)
                    Text("cleanroom")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DS.C.textOnDark)
                    Spacer()
                }
                .padding(.horizontal, DS.Sp.lg)
                .padding(.top, 22)
                .padding(.bottom, DS.Sp.md)

                Rectangle().fill(DS.C.dividerOnDark).frame(height: 1)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        SidebarSection("OVERVIEW") {
                            NavRow("square.grid.2x2.fill",    "Dashboard",   .dashboard, state)
                            NavRow("heart.text.square.fill",  "Doctor",      .run(title: "Doctor",      args: "doctor"), state)
                            NavRow("chart.bar.fill",          "Storage Map", .run(title: "Map",         args: "map"), state)
                            NavRow("magnifyingglass",         "Scan",        .run(title: "Scan",        args: "scan"), state)
                            NavRow("text.badge.checkmark",    "Review",      .run(title: "Review",      args: "review"), state)
                            NavRow("list.clipboard.fill",     "Plan",        .run(title: "Plan",        args: "plan"), state)
                        }
                        SidebarSection("FIND") {
                            NavRow("doc.fill",                "Large Files", .run(title: "Large Files",  args: "large --limit 30 --min-mb 500"), state)
                            NavRow("doc.on.doc.fill",         "Duplicates",  .run(title: "Duplicates",   args: "duplicates --limit 20 --min-mb 100"), state)
                            NavRow("link.badge.plus",         "Broken Links",.run(title: "Broken Links", args: "brokenlinks --limit 40"), state)
                            NavRow("lock.shield.fill",        "Quarantine",  .run(title: "Quarantine",   args: "quarantine --limit 40"), state)
                            NavRow("sparkle.magnifyingglass", "Metadata",    .run(title: "Metadata",     args: "metadata --limit 40"), state)
                            NavRow("magnifyingglass.circle.fill","Leftovers", .dashboard, state, onTap: { state.showLeftovers = true })
                        }
                        SidebarSection("CATEGORIES") {
                            NavRow("arrow.down.to.line",      "Downloads",   .run(title: "Downloads",   args: "downloads --limit 30 --days 30"), state)
                            NavRow("archivebox.fill",         "Archives",    .run(title: "Archives",    args: "archives --limit 30 --days 7"), state)
                            NavRow("camera.viewfinder",       "Screenshots", .run(title: "Screenshots", args: "screenshots --limit 30 --days 7"), state)
                            NavRow("xmark.bin.fill",          "Caches",      .run(title: "Caches",      args: "caches"), state)
                            NavRow("eye.fill",                "Quick Look",  .run(title: "Quick Look",  args: "quicklook"), state)
                            NavRow("textformat",              "Font Caches", .run(title: "Font Caches", args: "fontcaches"), state)
                            NavRow("safari.fill",             "Web Caches",  .run(title: "Web Caches",  args: "webcaches"), state)
                            NavRow("rectangle.stack.fill",    "Saved State", .run(title: "Saved State", args: "savedstate"), state)
                            NavRow("chevron.left.forwardslash.chevron.right", "Project Caches", .run(title: "Project Caches", args: "projectcaches --limit 40"), state)
                            NavRow("arrow.clockwise.circle.fill", "Updater Caches", .run(title: "Updater Caches", args: "updaters"), state)
                            NavRow("globe", "Browser Caches", .run(title: "Browser Caches", args: "browsercaches"), state)
                            NavRow("shippingbox.fill",        "Node Modules",.run(title: "Node Modules",args: "nodes --limit 30 --days 30"), state)
                            NavRow("terminal.fill",           "Virtualenvs", .run(title: "Virtualenvs", args: "venvs --limit 30 --days 30"), state)
                            NavRow("apps.iphone",             "Apps",        .run(title: "Apps",        args: "apps --limit 30"), state)
                            NavRow("app.badge.checkmark.fill","App Review",  .dashboard, state, onTap: { state.showLeftovers = true })
                            NavRow("trash.fill",              "Trash",       .run(title: "Trash",       args: "trash"), state)
                            NavRow("icloud.fill",             "Cloud Files", .run(title: "Cloud Files", args: "cloudfiles --min-mb 250 --limit 40"), state)
                        }
                        SidebarSection("SYSTEM") {
                            NavRow("hammer.fill",             "Xcode",       .run(title: "Xcode",       args: "xcode"), state)
                            NavRow("clock.arrow.circlepath",  "Backups",     .run(title: "Backups",     args: "backups"), state)
                            NavRow("externaldrive.fill",      "System Data", .run(title: "System Data", args: "system-data"), state)
                            NavRow("shippingbox.fill",        "Containers",  .run(title: "Containers",  args: "containers"), state)
                            NavRow("wrench.and.screwdriver",  "Toolchains",  .run(title: "Toolchains",  args: "toolchains"), state)
                            NavRow("person.crop.circle",      "Login Items", .run(title: "Login Items", args: "loginitems"), state)
                            NavRow("bolt.fill",               "Startup",     .run(title: "Startup",     args: "startup"), state)
                        }
                        SidebarSection("REPORT") {
                            NavRow("camera.fill",             "Snapshot",    .run(title: "Snapshot",  args: "snapshot"), state)
                            NavRow("clock.badge.checkmark.fill", "State",    .run(title: "State",     args: "state"), state)
                            NavRow("checkmark.shield.fill",   "Preflight",   .run(title: "Clean Preflight", args: "clean --preset dev --preflight"), state)
                            NavRow("doc.text.fill",           "Report",      .run(title: "Redacted Report", args: "report --redact"), state)
                            NavRow("clock.fill",              "History",     .run(title: "History",   args: "history"), state)
                            NavRow("shield.fill",             "Protected",   .run(title: "Protected", args: "protect"), state)
                            NavRow("flag.fill",               "Rules",       .run(title: "Rules",     args: "rules"), state)
                        }
                    }
                    .padding(.bottom, DS.Sp.xxl)
                }

                Rectangle().fill(DS.C.dividerOnDark).frame(height: 1)
                HStack {
                    Text(state.cliPath.isEmpty ? "CLI not found" : "v0.72.0")
                        .font(DS.T.tag)
                        .foregroundColor(DS.C.textOnDark.opacity(0.35))
                    Spacer()
                    if state.running {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.55)
                            .tint(DS.C.brandLavender)
                    }
                }
                .padding(.horizontal, DS.Sp.lg)
                .padding(.vertical, DS.Sp.md)
            }
        }
    }
}

struct SidebarSection<Content: View>: View {
    let title:   String
    let content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(DS.T.tag).kerning(0.7)
                .foregroundColor(DS.C.textOnDark.opacity(0.32))
                .padding(.horizontal, DS.Sp.lg)
                .padding(.top, DS.Sp.lg)
                .padding(.bottom, 4)
            content
        }
    }
}

struct NavRow: View {
    let icon: String; let label: String; let nav: NavDest
    @ObservedObject var state: AppState
    var onTap: (() -> Void)? = nil
    @State private var hovered = false

    init(_ icon: String, _ label: String, _ nav: NavDest, _ state: AppState,
         onTap: (() -> Void)? = nil) {
        self.icon = icon; self.label = label; self.nav = nav
        self.state = state; self.onTap = onTap
    }

    var isActive: Bool { state.dest == nav && onTap == nil }

    var body: some View {
        Button {
            if let tap = onTap { tap(); return }
            withAnimation(DS.Ani.snap) { state.dest = nav }
            if case .run(let t, let a) = nav { state.run(a, title: t) }
        } label: {
            HStack(spacing: DS.Sp.sm) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .frame(width: 18, alignment: .center)
                    .foregroundColor(isActive ? DS.C.ctaOrange : DS.C.textOnDark.opacity(0.58))
                Text(label)
                    .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? DS.C.textOnDark : DS.C.textOnDark.opacity(0.72))
                Spacer()
            }
            .padding(.horizontal, DS.Sp.md)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: DS.R.sm).fill(
                    isActive ? DS.C.ctaOrange.opacity(0.18)
                             : (hovered ? Color.white.opacity(0.05) : Color.clear)
                )
            )
            .padding(.horizontal, DS.Sp.sm)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .animation(DS.Ani.snap, value: hovered)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Main Panel
// ═══════════════════════════════════════════════════════════════

struct MainPanelView: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            HeaderStats(state: state)
            FilterBar(state: state)
            let cats = state.filteredCategories()
            if cats.isEmpty {
                EmptyFilterState(filter: state.filter) {
                    withAnimation(DS.Ani.snap) { state.filter = "all" }
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: DS.Layout.cardMinW, maximum: 420),
                                           spacing: DS.Sp.lg)],
                        spacing: DS.Sp.lg
                    ) {
                        ForEach(cats) { cat in
                            CategoryCardView(category: cat, state: state)
                        }
                    }
                    .padding(DS.Sp.xl)
                }
            }
            OutputPanel(state: state)
        }
        .background(DS.C.canvas)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Header Stats
// Large light-serif numbers + all-caps labels + horizontal rules.
// Navigation arrows ← → at top-right (from reference image 1/4).
// ═══════════════════════════════════════════════════════════════

struct HeaderStats: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Browse all storage")
                        .font(DS.T.h1)
                        .foregroundColor(DS.C.textPrimary)
                    Text("Safe-by-default macOS storage cleaner")
                        .font(DS.T.bodySm)
                        .foregroundColor(DS.C.textSecondary)
                }
                Spacer()
                // Navigation arrows — key visual from reference images 1 & 4
                HStack(spacing: DS.Sp.sm) {
                    NavArrow(icon: "arrow.left") { state.run("history", title: "History") }
                    NavArrow(icon: "arrow.right") { state.run("plan", title: "Plan") }
                }
            }
            .padding(.horizontal, DS.Sp.xl)
            .padding(.top, DS.Sp.xl)
            .padding(.bottom, DS.Sp.lg)

            // Four stat columns
            HStack(alignment: .top, spacing: 0) {
                ForEach(state.stats) { stat in StatCell(stat: stat) }
            }
            .padding(.horizontal, DS.Sp.xl)
            .padding(.bottom, DS.Sp.lg)

            // Action strip below stats
            HStack(spacing: DS.Sp.sm) {
                PillBtn("Refresh Stats", style: .ghost) { state.refreshStats() }
                PillBtn("Scan →", style: .ghost) { state.run("scan", title: "Scan") }
                Spacer()
                PillBtn("Apply Safely →", style: .primary) {
                    state.showApplyConfirm = true
                }
            }
            .padding(.horizontal, DS.Sp.xl)
            .padding(.bottom, DS.Sp.lg)

            Rectangle().fill(DS.C.divider).frame(height: 1)
        }
        .background(DS.C.surfaceMint)
    }
}

// Dark circular arrow button — ref image 1/4 top-right navigation
struct NavArrow: View {
    let icon:   String
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(
                    Circle().fill(
                        hovered ? DS.C.textPrimary.opacity(0.75) : DS.C.textPrimary
                    )
                )
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .animation(DS.Ani.snap, value: hovered)
    }
}

// ── Stat Cell ────────────────────────────────────────────────

struct StatCell: View {
    let stat: StorageStat
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Sp.xs) {
            Text(stat.value)
                .font(DS.T.display(46))
                .foregroundColor(DS.C.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            if let trend = stat.trend, let up = stat.trendUp {
                HStack(spacing: 3) {
                    Image(systemName: up ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 8, weight: .bold))
                    Text(trend).font(.system(size: 9, weight: .semibold))
                }
                .foregroundColor(up ? DS.C.positive : DS.C.negative)
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Capsule().fill(
                    up ? DS.C.positive.opacity(0.12) : DS.C.negative.opacity(0.12)
                ))
            } else {
                Color.clear.frame(height: 18)
            }

            Text(stat.label.uppercased())
                .font(DS.T.tag).kerning(0.6)
                .foregroundColor(DS.C.textSecondary)
                .padding(.top, 2)

            // Horizontal rule — the defining visual of the stats grid (ref images 1 & 4)
            Rectangle().fill(DS.C.divider).frame(height: 1).padding(.top, DS.Sp.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, DS.Sp.xl)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Filter Bar
// ═══════════════════════════════════════════════════════════════

struct FilterBar: View {
    @ObservedObject var state: AppState

    var body: some View {
        HStack(spacing: DS.Sp.xs) {
            ForEach(state.filters, id: \.id) { f in
                FilterChip(label: f.label, active: state.filter == f.id) {
                    withAnimation(DS.Ani.snap) { state.filter = f.id }
                }
            }
            Spacer()
            Button { state.run("review", title: "Full Review") } label: {
                HStack(spacing: 4) {
                    Text("Full Review").font(DS.T.body)
                    Image(systemName: "arrow.right").font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(DS.C.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DS.Sp.xl)
        .padding(.vertical, DS.Sp.md)
        .background(DS.C.surfaceMint)
    }
}

struct FilterChip: View {
    let label: String; let active: Bool; let action: () -> Void
    @State private var hovered = false
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(DS.T.tag).kerning(0.5)
                .foregroundColor(active ? .white : DS.C.textSecondary)
                .padding(.horizontal, DS.Sp.md).padding(.vertical, 6)
                .background(Capsule().fill(
                    active ? DS.C.ctaOrange : (hovered ? DS.C.divider : Color.clear)
                ))
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .animation(DS.Ani.snap, value: hovered)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Category Card
// Solid colour card with white pill CTA — direct ref from image 2.
// ═══════════════════════════════════════════════════════════════

struct CategoryCardView: View {
    let category: CleanCategory
    @ObservedObject var state: AppState
    @State private var hovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // All-caps micro tag (PSMA-TARGETED LU-177 equivalent)
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.55))
                Text(category.title.uppercased())
                    .font(DS.T.tag).kerning(0.8)
                    .foregroundColor(.white.opacity(0.65))
            }
            .padding(.horizontal, DS.Sp.lg)
            .padding(.top, DS.Sp.lg)
            .padding(.bottom, DS.Sp.sm)

            // Large display number — "45.71%" style from ref
            Text(category.result ?? "—")
                .font(DS.T.display(52))
                .foregroundColor(.white)
                .lineLimit(1).minimumScaleFactor(0.55)
                .padding(.horizontal, DS.Sp.lg)
                .padding(.bottom, DS.Sp.sm)

            Text(category.tagline)
                .font(DS.T.body)
                .foregroundColor(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, DS.Sp.lg)

            Spacer(minLength: DS.Sp.xl)

            // White pill button — "Learn More →" from ref image 2
            HStack {
                Spacer()
                Button {
                    state.dest = .run(title: category.title, args: category.args)
                    state.run(category.args, title: category.title)
                } label: {
                    HStack(spacing: 5) {
                        Text("Inspect")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(category.color)
                    .padding(.horizontal, DS.Sp.lg)
                    .padding(.vertical, DS.Sp.sm)
                    .background(Capsule().fill(Color.white))
                }
                .buttonStyle(.plain)
                .scaleEffect(hovered ? 1.04 : 1.0)
                .animation(DS.Ani.spring, value: hovered)
                Spacer()
            }
            .padding(.bottom, DS.Sp.lg)
        }
        .frame(minHeight: 230)
        .background(category.color)
        .clipShape(RoundedRectangle(cornerRadius: DS.R.card))
        .shadow(color: category.color.opacity(0.28), radius: 18, x: 0, y: 6)
        .scaleEffect(hovered ? 1.012 : 1.0)
        .animation(DS.Ani.spring, value: hovered)
        .onHover { hovered = $0 }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Empty Filter State
// ═══════════════════════════════════════════════════════════════

struct EmptyFilterState: View {
    let filter: String
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: DS.Sp.lg) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(DS.C.textMuted)
            Text("No categories for \"\(filter)\"")
                .font(DS.T.h3)
                .foregroundColor(DS.C.textSecondary)
            Button("Show all categories", action: onReset)
                .buttonStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DS.C.ctaOrange)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Output / Terminal Panel
// ═══════════════════════════════════════════════════════════════

struct OutputPanel: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            // Chrome bar — always visible
            HStack(spacing: DS.Sp.sm) {
                Circle()
                    .fill(state.running ? DS.C.ctaOrange : DS.C.positive)
                    .frame(width: 7, height: 7)
                    .animation(DS.Ani.std, value: state.running)
                Text(state.status)
                    .font(DS.T.monoSm)
                    .foregroundColor(DS.C.textOnDark.opacity(0.72))
                Spacer()
                IconBtn(icon: "doc.on.clipboard", dark: true) {
                    state.copyCmd("cleanroom clean --apply --trash")
                }
                IconBtn(icon: "trash", dark: true) { state.output = "" }
                IconBtn(icon: state.outputOpen ? "chevron.down" : "chevron.up", dark: true) {
                    withAnimation(DS.Ani.std) { state.outputOpen.toggle() }
                }
            }
            .padding(.horizontal, DS.Sp.lg)
            .padding(.vertical, DS.Sp.sm)
            .background(DS.C.sidebarBg.opacity(0.96))

            if state.outputOpen {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: true) {
                        Text(state.output)
                            .font(DS.T.mono)
                            .foregroundColor(DS.C.textOnDark.opacity(0.88))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(DS.Sp.lg)
                            .id("bottom")
                    }
                    .frame(height: DS.Layout.outputH)
                    .background(DS.C.terminalBg)
                    .onReceive(state.$output) { _ in
                        withAnimation(DS.Ani.snap) { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Leftovers Search Sheet
// ═══════════════════════════════════════════════════════════════

struct LeftoversSheet: View {
    @ObservedObject var state: AppState
    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Sp.xl) {
            // Header
            VStack(alignment: .leading, spacing: DS.Sp.sm) {
                Text("Find App Leftovers")
                    .font(DS.T.h2)
                    .foregroundColor(DS.C.textPrimary)
                Text("Enter an app or vendor name to preview matching files and copy the cleanup command.")
                    .font(DS.T.body)
                    .foregroundColor(DS.C.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Input
            HStack(spacing: DS.Sp.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(DS.C.textMuted)
                TextField("adobe, zoom, slack…", text: $query)
                    .font(DS.T.body)
                    .textFieldStyle(.plain)
                    .onSubmit { submit() }
            }
            .padding(DS.Sp.md)
            .background(
                RoundedRectangle(cornerRadius: DS.R.md)
                    .fill(DS.C.surfaceMint)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.R.md)
                    .strokeBorder(DS.C.divider, lineWidth: 1)
            )

            // Common suggestions
            VStack(alignment: .leading, spacing: DS.Sp.sm) {
                Text("COMMON SEARCHES")
                    .font(DS.T.tag).kerning(0.6)
                    .foregroundColor(DS.C.textMuted)
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 100, maximum: 160), spacing: DS.Sp.sm)],
                    spacing: DS.Sp.sm
                ) {
                    ForEach(["adobe", "zoom", "slack", "notion", "figma", "docker", "spotify", "discord"], id: \.self) { s in
                        Button { query = s } label: {
                            Text(s)
                                .font(DS.T.label)
                                .foregroundColor(DS.C.textSecondary)
                                .padding(.horizontal, DS.Sp.md)
                                .padding(.vertical, DS.Sp.xs)
                                .background(Capsule().fill(DS.C.divider))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Spacer()

            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundColor(DS.C.textSecondary)
                Spacer()
                PillBtn("Search →", style: .primary) { submit() }
                    .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(DS.Sp.xxl)
        .frame(width: 480, height: 380)
        .background(DS.C.canvas)
    }

    private func submit() {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }
        state.runLeftovers(q)
        dismiss()
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Apply Confirm Sheet
// ═══════════════════════════════════════════════════════════════

struct ApplyConfirmSheet: View {
    @ObservedObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Sp.xl) {
            // Warning header
            HStack(spacing: DS.Sp.md) {
                ZStack {
                    Circle().fill(DS.C.ctaOrangeSoft).frame(width: 48, height: 48)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(DS.C.ctaOrange)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Apply safely?")
                        .font(DS.T.h2)
                        .foregroundColor(DS.C.textPrimary)
                    Text("Files are moved to Trash, not permanently deleted.")
                        .font(DS.T.bodySm)
                        .foregroundColor(DS.C.textSecondary)
                }
            }

            Rectangle().fill(DS.C.divider).frame(height: 1)

            // Command preview
            VStack(alignment: .leading, spacing: DS.Sp.sm) {
                Text("COMMAND TO RUN")
                    .font(DS.T.tag).kerning(0.6)
                    .foregroundColor(DS.C.textMuted)
                Text("cleanroom clean --apply --trash")
                    .font(DS.T.mono)
                    .foregroundColor(DS.C.textOnDark)
                    .padding(DS.Sp.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: DS.R.sm).fill(DS.C.terminalBg)
                    )
            }

            VStack(alignment: .leading, spacing: DS.Sp.sm) {
                Text("WHAT THIS DOES")
                    .font(DS.T.tag).kerning(0.6)
                    .foregroundColor(DS.C.textMuted)
                ForEach([
                    "Cleans using the default rule set",
                    "Sends removed files to Trash (recoverable)",
                    "Skips all protected paths",
                ], id: \.self) { item in
                    HStack(spacing: DS.Sp.sm) {
                        Circle().fill(DS.C.positive).frame(width: 5, height: 5)
                        Text(item).font(DS.T.body).foregroundColor(DS.C.textSecondary)
                    }
                }
            }

            Spacer()

            HStack(spacing: DS.Sp.sm) {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundColor(DS.C.textSecondary)
                Spacer()
                PillBtn("Copy Command", style: .ghost) {
                    state.copyCmd("cleanroom clean --apply --trash")
                    dismiss()
                }
                PillBtn("Run Now →", style: .primary) {
                    state.run("clean --apply --trash", title: "Apply")
                    dismiss()
                }
            }
        }
        .padding(DS.Sp.xxl)
        .frame(width: 480, height: 380)
        .background(DS.C.canvas)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Pill Button
// ═══════════════════════════════════════════════════════════════

enum PillStyle { case primary, ghost, secondary }

struct PillBtn: View {
    let label:  String
    let style:  PillStyle
    let action: () -> Void
    @State private var hovered = false

    init(_ label: String, style: PillStyle = .primary, _ action: @escaping () -> Void) {
        self.label = label; self.style = style; self.action = action
    }

    private var bg: Color {
        switch style {
        case .primary:   return hovered ? DS.C.ctaOrangeHov : DS.C.ctaOrange
        case .ghost:     return hovered ? DS.C.divider : Color.clear
        case .secondary: return hovered ? DS.C.surfaceRaised : DS.C.surfaceMint.opacity(0.7)
        }
    }
    private var fg: Color { style == .primary ? .white : DS.C.textPrimary }
    private var stroke: Color { style == .ghost ? DS.C.divider : .clear }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(fg)
                .padding(.horizontal, DS.Sp.lg)
                .padding(.vertical, DS.Sp.sm - 1)
                .background(Capsule().fill(bg))
                .overlay(Capsule().strokeBorder(stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .scaleEffect(hovered ? 1.02 : 1.0)
        .animation(DS.Ani.snap, value: hovered)
        .onHover { hovered = $0 }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Icon Button
// ═══════════════════════════════════════════════════════════════

struct IconBtn: View {
    let icon:   String
    let dark:   Bool
    let action: () -> Void
    @State private var hovered = false

    init(icon: String, dark: Bool = false, _ action: @escaping () -> Void) {
        self.icon = icon; self.dark = dark; self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(dark ? DS.C.textOnDark.opacity(0.55) : DS.C.textSecondary)
                .padding(DS.Sp.sm)
                .background(
                    RoundedRectangle(cornerRadius: DS.R.xs).fill(
                        hovered ? (dark ? Color.white.opacity(0.08) : DS.C.divider) : Color.clear
                    )
                )
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .animation(DS.Ani.snap, value: hovered)
    }
}
