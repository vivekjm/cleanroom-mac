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
    var action:  AppAction
    var result:  String? = nil
}

struct CommandResult {
    var output: String
    var status: Int32
}

private enum AppRunLimit {
    static let quickSummary = 15.0
    static let review = 45.0
    static let cleanup = 300.0
}

private final class TimeoutFlag {
    private let lock = NSLock()
    private var value = false

    func mark() {
        lock.lock()
        value = true
        lock.unlock()
    }

    var isMarked: Bool {
        lock.lock()
        let current = value
        lock.unlock()
        return current
    }
}

struct ReviewItem: Identifiable {
    let id = UUID()
    var title: String
    var detail: String
    var size: String
    var badge: String
    var path: String?
}

struct CleanupPlanItem: Identifiable {
    let id = UUID()
    var title: String
    var estimate: String
    var safety: String
    var recovery: String
}

private struct CachedReview {
    var title: String
    var summary: String
    var items: [ReviewItem]
    var createdAt: Date
}

private struct CachedCleanupPlan {
    var items: [CleanupPlanItem]
    var notes: [String]
    var createdAt: Date
    var ttl: TimeInterval
}

private struct DashboardUpdate {
    var diskUsed: String?
    var reclaimable: String?
    var protected: String?
    var categoryResults: [String: String]
}

private struct PresentableReview {
    var summary: String
    var items: [ReviewItem]
}

struct AppAction: Hashable {
    let title: String
    let args: [String]

    static let healthCheck = AppAction(title: "App Checkup", args: ["doctor-fast"])
    static let storageOverview = AppAction(title: "Storage Overview", args: ["map-fast"])
    static let largeFiles = AppAction(title: "Large Files", args: ["large-fast", "--limit", "30", "--min-mb", "500"])
    static let duplicates = AppAction(title: "Duplicates", args: ["duplicates-fast", "--limit", "20", "--min-mb", "100"])
    static let missingFiles = AppAction(title: "Missing Files", args: ["brokenlinks-fast", "~/Downloads", "--limit", "40"])
    static let downloadWarnings = AppAction(title: "Download Warnings", args: ["quarantine-fast", "--limit", "40"])
    static let finderClutter = AppAction(title: "Finder Clutter", args: ["metadata-fast", "--limit", "40"])
    static let documents = AppAction(title: "Documents", args: ["documents-fast", "--limit", "40"])
    static let desktop = AppAction(title: "Desktop", args: ["desktop-fast", "--limit", "40"])
    static let downloads = AppAction(title: "Downloads", args: ["downloads-fast", "--limit", "30", "--days", "30"])
    static let archives = AppAction(title: "Archives", args: ["archives-fast", "--limit", "30", "--days", "7"])
    static let screenshots = AppAction(title: "Screenshots", args: ["screenshots-fast", "--limit", "30", "--days", "7"])
    static let caches = AppAction(title: "Caches", args: ["caches-instant"])
    static let developerFiles = AppAction(title: "Developer Files", args: ["developer-fast", "--limit", "30", "--days", "30"])
    static let previewCache = AppAction(title: "Quick Look Cache", args: ["quicklook-fast"])
    static let fontCache = AppAction(title: "Font Cache", args: ["fontcaches-fast"])
    static let webCache = AppAction(title: "Web Cache", args: ["webcaches-fast"])
    static let windowState = AppAction(title: "Window State", args: ["savedstate-fast"])
    static let projectCache = AppAction(title: "Project Cache", args: ["projectcaches-fast", "--limit", "40"])
    static let updateCache = AppAction(title: "Update Cache", args: ["updaters-fast"])
    static let browserCache = AppAction(title: "Browser Cache", args: ["browsercaches-fast"])
    static let aiTools = AppAction(title: "AI Tools", args: ["aitools-fast"])
    static let appData = AppAction(title: "App Data", args: ["appdata-fast", "--limit", "40"])
    static let mediaLibraries = AppAction(title: "Media Libraries", args: ["libraries-fast"])
    static let javascriptPackages = AppAction(title: "Project Dependencies", args: ["nodes-fast", "--limit", "30", "--days", "30"])
    static let pythonEnvironments = AppAction(title: "Python Project Data", args: ["venvs-fast", "--limit", "30", "--days", "30"])
    static let apps = AppAction(title: "Apps", args: ["apps-fast", "--limit", "30"])
    static let trash = AppAction(title: "Trash", args: ["trash-fast"])
    static let cloudFiles = AppAction(title: "Cloud Files", args: ["cloudfiles-fast", "--min-mb", "250", "--limit", "40"])
    static let xcode = AppAction(title: "Apple Developer Storage", args: ["xcode-fast"])
    static let backups = AppAction(title: "Backups", args: ["backups-fast"])
    static let systemData = AppAction(title: "System Data", args: ["system-data-fast"])
    static let containers = AppAction(title: "Container Storage", args: ["containers-fast"])
    static let developerTools = AppAction(title: "Developer Caches", args: ["toolchains-fast"])
    static let loginItems = AppAction(title: "Login Items", args: ["loginitems-fast"])
    static let startup = AppAction(title: "Startup Items", args: ["startup-fast"])
    static let storageRecord = AppAction(title: "Storage Snapshot", args: ["snapshot-fast"])
    static let restoreHistory = AppAction(title: "Restore History", args: ["state-fast"])
    static let safetyCheck = AppAction(title: "Cleanup Plan", args: ["clean", "--preset", "dev", "--preflight"])
    static let privacyReport = AppAction(title: "Privacy Summary", args: ["report-fast", "--redact"])
    static let pastCleanups = AppAction(title: "Recent Cleanups", args: ["history-fast"])
    static let protectedItems = AppAction(title: "Protected Data", args: ["protect-fast"])
    static let safetyPolicy = AppAction(title: "Safety Rules", args: ["rules-fast"])
    static let safetyPlan = AppAction(title: "Cleaning Plan", args: ["clean", "--preflight"])
    static let safeCleanup = AppAction(title: "Safe Cleanup", args: ["clean", "--apply", "--trash", "--yes"])

    static func appReview(query: String) -> AppAction {
        AppAction(title: "App Review: \(query)", args: ["appreview-fast", query, "--limit", "40"])
    }
}

enum NavDest: Hashable {
    case dashboard
    case run(AppAction)
}

// ═══════════════════════════════════════════════════════════════
// MARK: – App State
// ═══════════════════════════════════════════════════════════════

@MainActor
final class AppState: ObservableObject {

    @Published var dest:             NavDest = .dashboard
    @Published var filter:           String  = "all"
    @Published var reviewSummary:    String  = "Choose a review to see the report here.\n"
    @Published var running:          Bool    = false
    @Published var statsLoading:     Bool    = false
    @Published var status:           String  = "Ready"
    @Published var activityMessage:  String  = "Choose a review or cleanup to begin."
    @Published var summaryOpen:      Bool    = false
    @Published var showLeftovers:    Bool    = false
    @Published var showApplyConfirm: Bool    = false
    @Published var cardOffset:       Int     = 0
    @Published var reviewTitle:      String  = "Review Report"
    @Published var reviewItems:      [ReviewItem] = []
    @Published var cleanupPlanItems: [CleanupPlanItem] = []
    @Published var cleanupPlanNotes: [String] = []
    @Published var cleanupPlanLoading: Bool = false

    @Published var stats: [StorageStat] = [
        StorageStat(label: "Disk Used",   value: "—"),
        StorageStat(label: "Reclaimable", value: "Analyze"),
        StorageStat(label: "Protected",   value: "On"),
        StorageStat(label: "Last Scan",   value: "Not yet"),
    ]

    @Published var categories: [CleanCategory] = [
        CleanCategory(title: "Caches",       tagline: "App & system caches accumulating silently",      icon: "xmark.bin.fill",        color: DS.C.cardForest,   action: .caches),
        CleanCategory(title: "Documents",    tagline: "Large documents and folders to review first",    icon: "folder.fill",           color: DS.C.cardSlate,    action: .documents),
        CleanCategory(title: "App Data",     tagline: "Large app support folders and local state",      icon: "internaldrive.fill",    color: DS.C.cardTeal,     action: .appData),
        CleanCategory(title: "Media Libraries", tagline: "Photos, music, and creative libraries stay protected", icon: "photo.fill", color: DS.C.cardRose, action: .mediaLibraries),
        CleanCategory(title: "Project Dependencies", tagline: "Old project packages and rebuildable caches", icon: "shippingbox.fill",      color: DS.C.cardViolet,   action: .javascriptPackages),
        CleanCategory(title: "Downloads",    tagline: "Old downloads, DMGs, and forgotten installers",  icon: "arrow.down.to.line",    color: DS.C.cardAmber,    action: .downloads),
        CleanCategory(title: "Large Files",  tagline: "Files over 500 MB that may no longer be needed", icon: "doc.fill",              color: DS.C.cardSlate,    action: .largeFiles),
        CleanCategory(title: "Cloud Files",  tagline: "Large local files inside synced cloud folders",  icon: "icloud.fill",           color: DS.C.cardForest,   action: .cloudFiles),
        CleanCategory(title: "Archives",     tagline: "Old zip archives, tar files, and disk images",   icon: "archivebox.fill",       color: DS.C.cardRose,     action: .archives),
        CleanCategory(title: "Apps",         tagline: "Installed apps to review before removal",        icon: "apps.iphone",           color: DS.C.cardCharcoal, action: .apps),
        CleanCategory(title: "Developer Files", tagline: "Build artifacts and SDK caches", icon: "hammer.fill",           color: DS.C.cardTeal,     action: .developerFiles),
        CleanCategory(title: "System Data",  tagline: "System storage buckets explained safely",        icon: "externaldrive.fill",    color: DS.C.cardBark,     action: .systemData),
        CleanCategory(title: "Screenshots",  tagline: "Old screenshots accumulating on Desktop",        icon: "camera.viewfinder",     color: DS.C.cardBark,     action: .screenshots),
        CleanCategory(title: "Trash",        tagline: "Files waiting in macOS Trash",                   icon: "trash.fill",            color: DS.C.cardCharcoal, action: .trash),
    ]

    let filters: [(id: String, label: String)] = [
        ("all",       "OVERVIEW"),
        ("caches",    "CACHES"),
        ("dev",       "DEVELOPER"),
        ("downloads", "DOWNLOADS"),
        ("files",     "LARGE FILES"),
        ("apps",      "APPS"),
        ("system",    "SYSTEM"),
        ("archives",  "ARCHIVES"),
    ]

    var enginePath = ""
    private var didPrepare = false
    private var lastStatsRefresh: Date? = nil
    private var statsGeneration = UUID()
    private var currentProcess: Process? = nil
    private var currentRunID = UUID()
    private var reviewCache: [String: CachedReview] = [:]
    private var cleanupPlanCache: CachedCleanupPlan? = nil
    private var cleanupPlanGeneration = UUID()
    private let reviewCacheTTL: TimeInterval = 300
    private let fallbackCacheTTL: TimeInterval = 30
    private let scanTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    var hasReportContent: Bool {
        !reviewItems.isEmpty ||
            reviewTitle != "Review Report" ||
            !reviewSummary.localizedCaseInsensitiveContains("Choose a review to see the report here")
    }

    func resolveEngine() {
        if let r = Bundle.main.resourceURL {
            let b = r.appendingPathComponent("bin/cleanroom").path
            if FileManager.default.isExecutableFile(atPath: b) { enginePath = b; return }
        }
        let home = FileManager.default.homeDirectoryForCurrentUser
        for c in [
            "/opt/homebrew/bin/cleanroom",
            "/usr/local/bin/cleanroom",
            home.appendingPathComponent(".local/bin/cleanroom").path,
        ] where FileManager.default.isExecutableFile(atPath: c) {
            enginePath = c; return
        }
        enginePath = "cleanroom"
    }

    func prepareForUse() {
        guard !didPrepare else { return }
        didPrepare = true
        resolveEngine()
        status = "Ready"
        activityMessage = "Choose an area to review, or analyze storage when you want updated numbers."
        Task.detached(priority: .background) {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                if !self.running && !self.cleanupPlanLoading && self.cleanupPlanCache == nil {
                    self.refreshCleanupPlan()
                }
            }
        }
    }

    // Expensive storage measurement; run only when the user asks or after cleanup.
    func refreshStats(force: Bool = false) {
        guard !running else { return }
        guard !statsLoading else {
            status = "Storage analysis is updating"
            activityMessage = "Storage analysis is already updating."
            return
        }
        if !force,
           let lastStatsRefresh,
           Date().timeIntervalSince(lastStatsRefresh) < 30 {
            status = "Storage analysis is up to date"
            activityMessage = "Your storage analysis was refreshed recently."
            return
        }
        status = "Measuring storage..."
        activityMessage = "Checking disk usage without starting a cleanup."
        statsLoading = true
        lastStatsRefresh = Date()
        let generation = statsGeneration
        let command = resolvedCommand(["dashboard", "--json"])
        Task.detached(priority: .background) {
            let result = await Self.exec(command.executable, command.arguments, timeoutSeconds: AppRunLimit.quickSummary)
            let update = Self.dashboardUpdate(from: result.output)
            await MainActor.run {
                guard self.statsGeneration == generation else { return }
                if result.status == 0 {
                    self.applyDashboardUpdate(update)
                    if !self.running {
                        self.status = "Storage analysis updated"
                        self.activityMessage = "Storage analysis updated. Nothing was cleaned."
                    }
                } else {
                    if !self.running {
                        self.status = "Storage analysis needs attention"
                        self.activityMessage = "Storage analysis could not be updated. Try again or run App Checkup."
                    }
                }
                self.statsLoading = false
            }
        }
    }

    func refreshCleanupPlan() {
        guard !cleanupPlanLoading else { return }
        if let cached = cleanupPlanCache,
           Date().timeIntervalSince(cached.createdAt) < cached.ttl {
            cleanupPlanItems = cached.items
            cleanupPlanNotes = cached.notes
            return
        }
        cleanupPlanCache = nil
        cleanupPlanLoading = true
        cleanupPlanItems = []
        cleanupPlanNotes = []
        let generation = cleanupPlanGeneration
        let command = resolvedCommand(["plan-fast", "--json"])
        Task.detached(priority: .background) {
            let result = await Self.exec(command.executable, command.arguments, timeoutSeconds: AppRunLimit.quickSummary)
            let parsed = Self.parseCleanupPlan(result.output)
            await MainActor.run {
                guard self.cleanupPlanGeneration == generation else { return }
                self.cleanupPlanItems = parsed.items
                self.cleanupPlanNotes = parsed.notes
                if result.status == 0 || !parsed.items.isEmpty || !parsed.notes.isEmpty {
                    self.cleanupPlanCache = CachedCleanupPlan(
                        items: parsed.items,
                        notes: parsed.notes,
                        createdAt: Date(),
                        ttl: result.status == 0 ? self.reviewCacheTTL : self.fallbackCacheTTL
                    )
                }
                self.cleanupPlanLoading = false
            }
        }
    }

    private func applyDashboardUpdate(_ update: DashboardUpdate) {
        stats[3].value = scanTimeFormatter.string(from: Date())
        if let diskUsed = update.diskUsed {
            stats[0].value = diskUsed
        }
        if let reclaimable = update.reclaimable {
            stats[1].value = reclaimable
        }
        if let protected = update.protected {
            stats[2].value = protected
        }
        guard !update.categoryResults.isEmpty else { return }
        categories = categories.map { category in
            var updated = category
            if let value = update.categoryResults[category.title] {
                updated.result = value
            }
            return updated
        }
    }

    nonisolated private static func dashboardUpdate(from raw: String) -> DashboardUpdate {
        if let update = Self.dashboardUpdateFromJSON(raw) {
            return update
        }
        var update = DashboardUpdate(diskUsed: nil, reclaimable: nil, protected: nil, categoryResults: [:])
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

        if let used = grab("used_kb") ?? grab("disk_used") ?? grab("total_used") {
            update.diskUsed = Self.formatKBString(used)
        }
        if let rec = grab("estimate") ?? grab("reclaimable") ?? grab("recoverable") {
            update.reclaimable = rec
        }
        if let protected = grab("protected_present") {
            update.protected = protected
        }
        return update
    }

    nonisolated private static func dashboardUpdateFromJSON(_ raw: String) -> DashboardUpdate? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        var update = DashboardUpdate(diskUsed: nil, reclaimable: nil, protected: nil, categoryResults: [:])
        if let usedKB = Self.numberValue(object["used_kb"]) {
            update.diskUsed = Self.formatKBString(String(usedKB))
        } else if let used = Self.stringValue(object["used"]) ?? Self.stringValue(object["disk_used"]) {
            update.diskUsed = used
        }

        if let summary = object["summary"] as? [String: Any] {
            if let reclaimable = Self.stringValue(summary["reclaimable"]) {
                update.reclaimable = reclaimable
            }
            if let protected = Self.numberValue(summary["protected_present"]) {
                update.protected = "\(protected) guarded"
            } else if let protected = Self.stringValue(summary["protected_present"]) {
                update.protected = protected
            }
        }

        if let cards = object["cards"] as? [[String: Any]] {
            update.categoryResults = Self.dashboardCategoryResults(from: cards)
        }
        return update
    }

    nonisolated private static func dashboardCategoryResults(from cards: [[String: Any]]) -> [String: String] {
        var results: [String: String] = [:]
        for card in cards {
            guard let title = Self.stringValue(card["title"]),
                  let value = Self.stringValue(card["value"]) else { continue }
            results[title] = value
        }
        return results
    }

    nonisolated private static func numberValue(_ value: Any?) -> Int? {
        switch value {
        case let number as NSNumber:
            return number.intValue
        case let text as String:
            return Int(text)
        default:
            return nil
        }
    }

    nonisolated private static func formatKBString(_ raw: String) -> String {
        guard let kb = Double(raw.trimmingCharacters(in: .whitespacesAndNewlines)) else { return raw }
        let units = ["KB", "MB", "GB", "TB"]
        var value = kb
        var index = 0
        while value >= 1024 && index < units.count - 1 {
            value /= 1024
            index += 1
        }
        return value >= 10 ? String(format: "%.0f%@", value, units[index]) : String(format: "%.1f%@", value, units[index])
    }

    func openReview(_ action: AppAction) {
        if running { return }
        dest = .run(action)
        run(action)
    }

    func run(_ action: AppAction) {
        guard !running else { return }
        if statsLoading && action == .safeCleanup { return }
        if let cached = cachedReview(for: action) {
            dest = .run(action)
            reviewTitle = cached.title
            reviewSummary = cached.summary
            reviewItems = cached.items
            status = "\(action.title) ready"
            activityMessage = "Showing a recent \(action.title) review."
            summaryOpen = false
            return
        }
        let runID = UUID()
        currentRunID = runID
        currentProcess = nil
        running    = true
        status     = "Reviewing \(action.title)..."
        activityMessage = "Reviewing \(action.title). You can stop it anytime."
        reviewSummary = "Reviewing \(action.title).\n"
        reviewTitle = action.title
        reviewItems = []
        let commandArgs = appFacingArgs(action.args)
        let command = resolvedCommand(commandArgs)
        Task.detached(priority: .userInitiated) {
            let result = await Self.exec(command.executable, command.arguments, timeoutSeconds: self.timeoutSeconds(for: action)) { process in
                Task { @MainActor in
                    if self.currentRunID == runID && self.running && process.isRunning {
                        self.currentProcess = process
                    }
                }
            }
            let presented = Self.presentableReview(title: action.title, action: action, details: result.output)
            await MainActor.run {
                guard self.currentRunID == runID else { return }
                self.currentProcess = nil
                self.reviewTitle = action.title
                self.reviewItems = presented.items
                self.reviewSummary = presented.summary
                if result.status == 15 {
                    self.status = "\(action.title) stopped"
                    self.activityMessage = "\(action.title) stopped. Open the report to see where it paused."
                    self.reviewSummary += "Review stopped.\n"
                    self.summaryOpen = true
                } else if result.status == 124 {
                    self.status = "\(action.title) paused"
                    self.activityMessage = "\(action.title) took too long. Try a narrower review or run App Checkup."
                    self.summaryOpen = true
                } else if result.status == 0 {
                    self.status = "\(action.title) complete"
                    self.activityMessage = self.summarizeAction(action: action, details: presented.summary, items: presented.items)
                    self.summaryOpen = false
                    self.storeCachedReview(title: action.title, summary: presented.summary, items: self.reviewItems, for: action)
                } else {
                    self.status = "\(action.title) needs attention"
                    self.activityMessage = "\(action.title) needs attention. Open the report for what happened."
                    self.summaryOpen = true
                }
                if action == .safeCleanup {
                    self.clearRecentResults()
                    self.running = false
                    self.refreshStats(force: true)
                } else {
                    self.running = false
                }
            }
        }
    }

    func cancelRun() {
        guard let process = currentProcess, process.isRunning else { return }
        status = "Stopping..."
        activityMessage = "Stopping the current action..."
        reviewSummary = "Stopping the current review...\n"
        summaryOpen = true
        currentProcess = nil
        reviewItems = []
        process.terminate()
    }

    private func timeoutSeconds(for action: AppAction) -> Double {
        if action == .safeCleanup {
            return AppRunLimit.cleanup
        }
        if isQuickAction(action) {
            return AppRunLimit.quickSummary
        }
        return AppRunLimit.review
    }

    private func isQuickAction(_ action: AppAction) -> Bool {
        guard let first = action.args.first else { return false }
        return first.hasSuffix("-fast") ||
            first == "caches-instant" ||
            first == "dashboard" ||
            first == "map-fast" ||
            first == "snapshot-fast" ||
            first == "state-fast" ||
            first == "report-fast" ||
            first == "doctor-fast" ||
            (first == "clean" && action.args.contains("--preflight"))
    }

    private func cacheKey(for action: AppAction) -> String {
        ([action.title] + action.args).joined(separator: "\u{1F}")
    }

    private func cachedReview(for action: AppAction) -> CachedReview? {
        guard isQuickAction(action), action != .safeCleanup else { return nil }
        let key = cacheKey(for: action)
        guard let cached = reviewCache[key],
              Date().timeIntervalSince(cached.createdAt) < reviewCacheTTL else {
            reviewCache.removeValue(forKey: key)
            return nil
        }
        return cached
    }

    private func storeCachedReview(title: String, summary: String, items: [ReviewItem], for action: AppAction) {
        guard isQuickAction(action), action != .safeCleanup else { return }
        reviewCache[cacheKey(for: action)] = CachedReview(
            title: title,
            summary: summary,
            items: items,
            createdAt: Date()
        )
    }

    private func clearReviewCache() {
        reviewCache.removeAll()
    }

    private func clearRecentResults() {
        clearReviewCache()
        statsGeneration = UUID()
        statsLoading = false
        lastStatsRefresh = nil
        cleanupPlanCache = nil
        cleanupPlanGeneration = UUID()
        cleanupPlanLoading = false
        cleanupPlanItems = []
        cleanupPlanNotes = []
    }

    func runLeftovers(_ query: String) {
        openReview(.appReview(query: query))
    }

    func copyDetails() {
        guard hasReportContent else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(appFacingSummaryText(), forType: .string)
        status = "Report copied"
        activityMessage = "Review report copied."
    }

    func clearSummary() {
        guard hasReportContent else { return }
        reviewSummary = "Choose a review to see the report here.\n"
        reviewTitle = "Review Report"
        reviewItems = []
        status = "Ready"
        activityMessage = "Report cleared. Choose a review when you are ready."
        summaryOpen = false
    }

    private func appFacingSummaryText() -> String {
        guard !reviewItems.isEmpty else {
            return [
                reviewTitle == "Review Report" ? "Cleanroom" : reviewTitle,
                activityMessage,
                status
            ]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n") + "\n"
        }
        var lines = ["\(reviewTitle) — \(reviewItems.count) \(reviewItems.count == 1 ? "item" : "items")"]
        for item in reviewItems {
            lines.append("\(item.size)  \(item.title)  \(item.badge)")
            if !item.detail.isEmpty {
                lines.append("  \(item.detail)")
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private func resolvedCommand(_ args: [String]) -> (executable: String, arguments: [String]) {
        if enginePath.isEmpty || enginePath == "cleanroom" {
            return ("/usr/bin/env", ["cleanroom"] + args)
        }
        return (enginePath, args)
    }

    private func appFacingArgs(_ args: [String]) -> [String] {
        guard let action = args.first else { return args }
        let jsonActions: Set<String> = [
            "large-fast", "duplicates-fast", "brokenlinks", "brokenlinks-fast", "quarantine-fast", "metadata-fast",
            "developer-fast", "nodes-fast", "venvs-fast", "apps-fast",
            "documents", "documents-fast", "desktop", "desktop-fast", "downloads", "downloads-fast", "archives", "archives-fast", "screenshots", "screenshots-fast", "trash", "trash-fast", "cloudfiles", "cloudfiles-fast", "caches-instant", "caches-fast",
            "quicklook", "quicklook-fast", "fontcaches", "fontcaches-fast", "webcaches", "webcaches-fast", "savedstate", "savedstate-fast",
            "projectcaches", "projectcaches-fast", "updaters", "updaters-fast", "browsercaches", "browsercaches-fast",
            "aitools", "aitools-fast", "ai-tools", "ai", "appdata", "appdata-fast", "libraries", "libraries-fast",
            "xcode", "xcode-fast", "backups", "backups-fast", "system-data", "system-data-fast", "containers", "containers-fast", "toolchains", "toolchains-fast",
            "loginitems", "loginitems-fast", "startup", "startup-fast", "snapshot", "snapshot-fast", "state", "state-fast", "protect", "protect-fast", "rules", "rules-fast",
            "map", "map-fast", "plan-fast", "doctor", "doctor-fast", "leftovers", "appreview", "appreview-fast", "history", "history-fast", "report-fast"
        ]
        if jsonActions.contains(action), !args.contains("--json") {
            return args + ["--json"]
        }
        if action == "clean", args.contains("--preflight"), !args.contains("--json") {
            return args + ["--json"]
        }
        if action == "clean", args.contains("--apply"), !args.contains("--json") {
            return args + ["--json"]
        }
        return args
    }

    private func summarizeAction(action: AppAction, details: String, items: [ReviewItem]) -> String {
        let changedFiles = action.args.contains("--apply")
        let title = action.title
        let reviewOnlyText = changedFiles ? "" : " Nothing was cleaned."
        let lowerDetails = details.lowercased()

        if lowerDetails.contains("trash is empty") {
            return "Trash is empty. Nothing was cleaned."
        }
        if lowerDetails.contains("nothing to clean") || lowerDetails.contains("no matches") || lowerDetails.contains("no files found") {
            return "\(title) found nothing that needs attention.\(reviewOnlyText)"
        }
        if changedFiles {
            return "\(title) finished. Items were moved to Trash where possible."
        }

        if items.count == 1 {
            let size = items[0].size
            return "\(title) found 1 item to review, starting at \(size). Nothing was cleaned."
        }
        if items.count > 1 {
            let size = items[0].size
            return "\(title) found \(items.count) items to review; largest starts at \(size). Nothing was cleaned."
        }
        return "\(title) finished. Open the report if you need more context."
    }

    nonisolated private static func presentableReview(title: String, action: AppAction, details: String) -> PresentableReview {
        let trimmed = details.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: data),
              let items = Self.jsonItems(from: parsed) else {
            let items = Self.textReviewItems(title: title, details: details)
            let reviewOnlySuffix = action.args.contains("--apply") ? "" : " Nothing was cleaned."
            if items.isEmpty {
                return PresentableReview(summary: "\(title) finished.\(reviewOnlySuffix)\n", items: [])
            }
            return PresentableReview(
                summary: "\(title) finished with \(items.count) \(items.count == 1 ? "note" : "notes").\(reviewOnlySuffix)\n",
                items: items
            )
        }

        if items.isEmpty {
            return PresentableReview(summary: "\(title) found nothing that needs attention.\n", items: [])
        }

        var lines = ["\(title) found \(items.count) review \(items.count == 1 ? "item" : "items")."]
        for item in items.prefix(40) {
            lines.append(Self.summaryLine(for: item))
        }
        return PresentableReview(
            summary: lines.joined(separator: "\n") + "\n",
            items: items.prefix(80).map { Self.reviewItem(from: $0) }
        )
    }

    nonisolated private static func textReviewItems(title: String, details: String) -> [ReviewItem] {
        let cleaned = Self.sanitizeForApp(details)
        let lines = cleaned
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let items = lines.prefix(40).compactMap { line -> ReviewItem? in
            guard let sentence = Self.friendlySentence(line) else { return nil }
            let badge = Self.fallbackBadge(for: sentence)
            if let size = Self.leadingSize(in: sentence) {
                let titleText = sentence
                    .replacingOccurrences(of: "^[0-9]+(\\.[0-9]+)?\\s?(B|KB|MB|GB|TB)\\b\\s*", with: "", options: [.regularExpression, .caseInsensitive])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return ReviewItem(
                    title: titleText.isEmpty ? title : Self.friendlyLabel(titleText),
                    detail: Self.fallbackDetail(for: sentence),
                    size: size,
                    badge: badge,
                    path: nil
                )
            }
            return ReviewItem(
                title: Self.fallbackTitle(for: sentence, defaultTitle: title),
                detail: Self.fallbackDetail(for: sentence),
                size: Self.fallbackSize(for: sentence),
                badge: badge,
                path: nil
            )
        }

        if !items.isEmpty {
            return items
        }
        let clean = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return [] }
        return [
            ReviewItem(
                title: title,
                detail: "Review finished. No extra report notes need your attention.",
                size: "Done",
                badge: "Ready",
                path: nil
            )
        ]
    }

    nonisolated private static func fallbackTitle(for sentence: String, defaultTitle: String) -> String {
        let lower = sentence.lowercased()
        if lower.contains("could not") || lower.contains("try again") || lower.contains("unavailable") {
            return "Needs Attention"
        }
        if lower.contains("paused") || lower.contains("took too long") {
            return "Review Paused"
        }
        if lower.contains("protected") || lower.contains("password") || lower.contains("profile") {
            return "Protected Data"
        }
        if lower.contains("no files") || lower.contains("nothing") || lower.contains("empty") {
            return "Nothing To Clean"
        }
        if lower.contains("trash") {
            return "Trash Recovery"
        }
        return defaultTitle
    }

    nonisolated private static func fallbackDetail(for sentence: String) -> String {
        let lower = sentence.lowercased()
        if lower.contains("could not") || lower.contains("try again") || lower.contains("unavailable") {
            return "The review could not finish. Try again, or run App Checkup."
        }
        if lower.contains("paused") || lower.contains("took too long") {
            return "The review paused to keep the app responsive. Try a narrower area."
        }
        if lower.contains("protected") || lower.contains("password") || lower.contains("profile") {
            return "Passwords, browser profiles, and personal app data stay protected."
        }
        if lower.contains("no files") || lower.contains("nothing") || lower.contains("empty") {
            return "Nothing was cleaned."
        }
        return sentence
    }

    nonisolated private static func fallbackSize(for sentence: String) -> String {
        let lower = sentence.lowercased()
        if lower.contains("could not") || lower.contains("try again") || lower.contains("unavailable") {
            return "Check"
        }
        if lower.contains("paused") || lower.contains("took too long") {
            return "Paused"
        }
        if lower.contains("no files") || lower.contains("nothing") || lower.contains("empty") {
            return "0"
        }
        return "Info"
    }

    nonisolated private static func fallbackBadge(for sentence: String) -> String {
        let lower = sentence.lowercased()
        if lower.contains("could not") || lower.contains("try again") || lower.contains("unavailable") {
            return "Needs Attention"
        }
        if lower.contains("protected") || lower.contains("password") || lower.contains("profile") {
            return "Protected"
        }
        if lower.contains("paused") || lower.contains("took too long") {
            return "Review"
        }
        return "Ready"
    }

    nonisolated private static func jsonItems(from parsed: Any) -> [[String: Any]]? {
        if let array = parsed as? [[String: Any]] {
            return Self.appFacingItems(array)
        }
        if let object = parsed as? [String: Any] {
            if let available = object["available"] as? Bool, !available {
                return []
            }
            if let preflightItems = Self.preflightReviewItems(from: object) {
                return Self.appFacingItems(preflightItems)
            }
            if let array = object["items"] as? [[String: Any]] {
                return Self.appFacingItems(array)
            }
            if let array = object["categories"] as? [[String: Any]] {
                return Self.appFacingItems(array)
            }
            if let array = object["buckets"] as? [[String: Any]] {
                return Self.appFacingItems(array)
            }
            if let array = object["cards"] as? [[String: Any]] {
                return Self.appFacingItems(array)
            }
            if let doctorItems = Self.doctorReviewItems(from: object) {
                return Self.appFacingItems(doctorItems)
            }
            var grouped: [[String: Any]] = []
            for key in ["apps", "uninstallers", "receipts", "leftovers"] {
                if let array = object[key] as? [[String: Any]] {
                    grouped.append(contentsOf: array)
                }
            }
            if !grouped.isEmpty {
                return Self.appFacingItems(grouped)
            }
        }
        return nil
    }

    nonisolated private static func preflightReviewItems(from object: [String: Any]) -> [[String: Any]]? {
        guard Self.stringValue(object["action"]) == "clean",
              let categories = object["categories"] as? [[String: Any]] else {
            return nil
        }

        var items: [[String: Any]] = categories.map { item in
            let title = Self.stringValue(item["title"]) ?? Self.stringValue(item["id"]) ?? "Cleanup Area"
            let safety = Self.friendlySafety(Self.stringValue(item["safety"]))
            let recovery = Self.friendlyRecovery(Self.stringValue(item["recoverability"]))
            return [
                "title": title,
                "size": "Selected",
                "status": safety,
                "summary": recovery
            ]
        }

        let warnings = object["warnings"] as? [String] ?? []
        for warning in warnings {
            let note = Self.friendlyCleanupNote(warning)
            let status = note.localizedCaseInsensitiveContains("cannot be restored") ||
                note.localizedCaseInsensitiveContains("can remove")
                ? "Review"
                : "Protected"
            items.append([
                "title": "Safety Note",
                "size": status,
                "status": status,
                "summary": note
            ])
        }

        let apply = (object["apply"] as? Bool) == true
        items.insert([
            "title": apply ? "Ready to Clean" : "Review Plan",
            "size": apply ? "Ready" : "Plan",
            "status": apply ? "Review" : "Protected",
            "summary": apply
                ? "Cleaning will only start after confirmation."
                : "This plan does not change files."
        ], at: 0)

        return items
    }

    nonisolated private static func doctorReviewItems(from object: [String: Any]) -> [[String: Any]]? {
        guard object["platform"] is [String: Any] ||
              object["tools"] is [[String: Any]] ||
              object["safety"] is [String: Any] else {
            return nil
        }

        var items: [[String: Any]] = []

        if let disk = object["disk"] as? [String: Any] {
            let capacity = Self.stringValue(disk["capacity"]) ?? "Review"
            let available = Self.numberValue(disk["available_kb"]).map { Self.formatKBString(String($0)) } ?? "available space"
            let used = Self.numberValue(disk["used_kb"]).map { Self.formatKBString(String($0)) } ?? "current usage"
            items.append([
                "title": "Disk Space",
                "size": capacity,
                "status": "Review",
                "summary": "\(available) available, \(used) used."
            ])
        }

        if let safety = object["safety"] as? [String: Any] {
            let protected = Self.numberValue(safety["protected_present"]) ?? 0
            let rulesReady = (safety["rules_catalog"] as? Bool) == true
            let protectedReady = (safety["protected_catalog"] as? Bool) == true
            let status = rulesReady && protectedReady ? "Protected" : "Needs Attention"
            items.append([
                "title": "Safety Catalogs",
                "size": "\(protected) protected",
                "status": status,
                "summary": rulesReady && protectedReady
                    ? "Cleanup rules and protected personal-data catalogs are available."
                    : "One or more safety catalogs could not be loaded."
            ])
        }

        if let tools = object["tools"] as? [[String: Any]] {
            let required = tools.filter { ($0["required"] as? Bool) == true }
            let missingRequired = required.filter { Self.stringValue($0["status"]) != "ok" }
            items.append([
                "title": "Required Tools",
                "size": missingRequired.isEmpty ? "Ready" : "\(missingRequired.count) missing",
                "status": missingRequired.isEmpty ? "Ready" : "Needs Attention",
                "summary": missingRequired.isEmpty
                    ? "All required system tools are available."
                    : "Some required system tools are missing or unavailable."
            ])

            for tool in tools.prefix(12) {
                let name = Self.stringValue(tool["name"]) ?? "Tool"
                let requiredFlag = (tool["required"] as? Bool) == true
                let status = Self.stringValue(tool["status"]) ?? "review"
                items.append([
                    "title": name,
                    "size": status == "ok" ? "Ready" : "Check",
                    "status": status == "ok" ? "Ready" : "Needs Attention",
                    "summary": requiredFlag ? "Required system capability." : "Optional capability for deeper reviews."
                ])
            }
        }

        if let platform = object["platform"] as? [String: Any] {
            let macOS = Self.stringValue(platform["macos"]) ?? "macOS"
            let architecture = Self.stringValue(platform["architecture"]) ?? "Mac"
            items.append([
                "title": "Mac Compatibility",
                "size": "Ready",
                "status": "Ready",
                "summary": "Running on macOS \(macOS) for \(architecture)."
            ])
        }

        return items.isEmpty ? nil : items
    }

    nonisolated private static func appFacingItems(_ items: [[String: Any]]) -> [[String: Any]] {
        items.map { item in
            var cleaned = item
            if let location = Self.friendlyLocationHint(from: cleaned) {
                cleaned["location"] = location
            }
            for key in cleaned.keys where shouldHideAppField(key) {
                cleaned.removeValue(forKey: key)
            }
            for key in Array(cleaned.keys) {
                guard let text = Self.stringValue(cleaned[key]) else { continue }
                if Self.shouldHideAppValue(text) {
                    cleaned.removeValue(forKey: key)
                } else if Self.shouldNormalizeAppTextField(key) {
                    cleaned[key] = Self.normalizeAppText(text)
                }
            }
            return cleaned
        }
    }

    nonisolated private static func shouldHideAppField(_ key: String) -> Bool {
        let lower = key.lowercased()
        let pathFields: Set<String> = [
            "path",
            "paths",
            "record_path",
            "log_path",
            "plist",
            "target",
            "source",
            "file"
        ]
        return lower.contains("command") ||
            pathFields.contains(lower) ||
            lower == "mode" ||
            lower == "raw" ||
            lower == "hash" ||
            lower == "quarantine" ||
            lower == "executable"
    }

    nonisolated private static func shouldNormalizeAppTextField(_ key: String) -> Bool {
        let lower = key.lowercased()
        return lower == "summary" ||
            lower == "guidance" ||
            lower == "description" ||
            lower == "detail" ||
            lower == "reason" ||
            lower == "recoverability" ||
            lower == "status" ||
            lower == "safety" ||
            lower == "category" ||
            lower == "kind" ||
            lower == "type" ||
            lower == "size" ||
            lower == "value"
    }

    nonisolated private static func shouldHideAppValue(_ text: String) -> Bool {
        let lower = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return lower.hasPrefix("cleanroom ") ||
            lower.hasPrefix("open -r") ||
            lower.hasPrefix("--") ||
            lower.contains(" --apply") ||
            lower.contains(" --trash") ||
            lower.contains(" --json") ||
            lower.contains(" --include") ||
            lower.contains(" --preflight") ||
            Self.isSensitivePathText(text)
    }

    nonisolated private static func normalizeAppText(_ text: String) -> String {
        Self.friendlyLabelIfBackendToken(
            text.replacingOccurrences(of: "dry-run", with: "review", options: .caseInsensitive)
                .replacingOccurrences(of: "opt-in", with: "optional", options: .caseInsensitive)
                .replacingOccurrences(of: "--apply", with: "Clean Now", options: .caseInsensitive)
                .replacingOccurrences(of: "--trash", with: "Trash recovery", options: .caseInsensitive)
        )
    }

    nonisolated private static func summaryLine(for item: [String: Any]) -> String {
        let size = Self.stringValue(item["size"]) ?? Self.stringValue(item["value"]) ?? Self.stringValue(item["potential_reclaim"]) ?? "Review"
        let title = Self.friendlyTitle(from: item)
        if let location = Self.friendlyLocationHint(from: item) {
            return "\(size)  \(title)  \(location)"
        }
        return "\(size)  \(title)"
    }

    nonisolated private static func reviewItem(from item: [String: Any]) -> ReviewItem {
        let size = Self.stringValue(item["size"]) ?? Self.stringValue(item["value"]) ?? Self.stringValue(item["potential_reclaim"]) ?? Self.stringValue(item["total"]) ?? "Review"
        let title = Self.friendlyTitle(from: item)
        let badge = Self.friendlyBadge(from: item)
        let path = Self.displayPath(from: item)
        let detail = Self.friendlyDetail(from: item) ??
            Self.friendlyLocationHint(from: item) ??
            "Review before cleaning."
        return ReviewItem(title: title, detail: detail, size: size, badge: badge, path: path)
    }

    nonisolated private static func friendlyTitle(from item: [String: Any]) -> String {
        let raw = Self.stringValue(item["title"]) ??
            Self.stringValue(item["name"]) ??
            Self.stringValue(item["kind"]) ??
            Self.stringValue(item["runtime"]) ??
            Self.stringValue(item["id"]) ??
            Self.stringValue(item["type"]) ??
            "Review item"
        return Self.friendlyLabel(raw)
    }

    nonisolated private static func friendlyDetail(from item: [String: Any]) -> String? {
        let candidates = [
            Self.stringValue(item["summary"]),
            Self.stringValue(item["guidance"]),
            Self.stringValue(item["description"]),
            Self.stringValue(item["detail"]),
            Self.stringValue(item["reason"]),
            Self.stringValue(item["recoverability"]),
            Self.stringValue(item["modified"]),
            Self.stringValue(item["last_modified"])
        ]
        for candidate in candidates {
            guard let candidate,
                  let cleaned = Self.friendlySentence(candidate) else { continue }
            return cleaned
        }
        return nil
    }

    nonisolated private static func friendlyBadge(from item: [String: Any]) -> String {
        let raw = Self.stringValue(item["safety"]) ??
            Self.stringValue(item["category"]) ??
            Self.stringValue(item["kind"]) ??
            Self.stringValue(item["type"]) ??
            Self.stringValue(item["status"]) ??
            "Review"
        return Self.friendlyLabel(raw)
    }

    nonisolated private static func displayPath(from item: [String: Any]) -> String? {
        if let path = Self.stringValue(item["path"]) { return path }
        if let paths = item["paths"] as? [String], let first = paths.first { return first }
        if let paths = Self.stringValue(item["paths"]) {
            return paths
                .components(separatedBy: CharacterSet(charactersIn: ";\n"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { !$0.isEmpty }
        }
        return nil
    }

    nonisolated private static func friendlySentence(_ raw: String) -> String? {
        let note = Self.friendlyCleanupNote(raw)
        if note != raw {
            return note
        }
        let recovery = Self.friendlyRecovery(raw)
        if recovery != raw {
            return recovery
        }
        let sanitized = Self.sanitizeForApp(raw)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let text = (sanitized.isEmpty ? raw : sanitized)
            .replacingOccurrences(of: "`", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        let lower = text.lowercased()
        if lower.contains("cleanroom ") ||
            lower.contains(" --") ||
            lower.hasPrefix("--") ||
            lower.contains("preview command") ||
            lower.contains("apply command") ||
            Self.isSensitivePathText(text) {
            return nil
        }
        return Self.friendlyLabelIfBackendToken(text)
    }

    nonisolated private static func friendlyLabelIfBackendToken(_ text: String) -> String {
        let exact = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let exactLabels: [String: String] = [
            "downloaded-models": "Downloaded models",
            "generated-workspace": "Generated AI data",
            "review-only": "Review only",
            "review": "Review",
            "allowed": "Ready",
            "refused-protected": "Protected",
            "refused-dangerous": "Protected",
            "large-opt-in": "Large optional cleanup",
            "destructive-opt-in": "Optional cleanup",
            "system-tool": "System managed",
            "app-cache": "App cache",
            "cli": "Developer tools",
            "json": "Data file",
            "low-risk": "Low risk",
            "high-impact": "High impact",
            "rebuildable": "Rebuildable",
            "not found": "Not found"
        ]
        if let label = exactLabels[exact] {
            return label
        }
        if text.range(of: "^[a-z0-9_.-]+$", options: .regularExpression) != nil {
            return Self.friendlyLabel(text)
        }
        return text
            .replacingOccurrences(of: "dry-run", with: "review", options: .caseInsensitive)
            .replacingOccurrences(of: "opt-in", with: "optional", options: .caseInsensitive)
    }

    nonisolated private static func friendlyLabel(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Review item" }
        if trimmed.contains("/") {
            let last = URL(fileURLWithPath: trimmed).lastPathComponent
            if !last.isEmpty { return Self.friendlyLabel(last) }
        }
        let expanded = trimmed
            .replacingOccurrences(of: "cleanroom ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: ".", with: " ")
        let known: [String: String] = [
            "ai": "AI",
            "api": "App connection",
            "cc": "CC",
            "cli": "Developer tools",
            "db": "Database",
            "gpu": "GPU",
            "ios": "iOS",
            "json": "Data file",
            "lm": "LM",
            "ndk": "NDK",
            "npm": "NPM",
            "pnpm": "PNPM",
            "sdk": "SDK",
            "sql": "SQL",
            "ui": "Interface",
            "xcode": "Xcode"
        ]
        let words = expanded
            .split(whereSeparator: { $0.isWhitespace })
            .map { word -> String in
                let lower = word.lowercased()
                if let replacement = known[lower] { return replacement }
                if lower == "nodejs" { return "Node.js" }
                return lower.prefix(1).uppercased() + lower.dropFirst()
            }
        let label = words.joined(separator: " ")
        return label.isEmpty ? "Review item" : label
    }

    nonisolated private static func friendlyLocationHint(from item: [String: Any]) -> String? {
        if let location = Self.stringValue(item["location"]) { return location }
        guard let path = Self.displayPath(from: item) else { return nil }
        return Self.friendlyLocation(Self.shortPath(path))
    }

    nonisolated private static func friendlyLocation(_ path: String) -> String {
        let lower = path.lowercased()
        if lower.contains("/downloads") || lower.hasPrefix("~/downloads") { return "In Downloads" }
        if lower.contains("/desktop") || lower.hasPrefix("~/desktop") { return "On Desktop" }
        if lower.contains("/documents") || lower.hasPrefix("~/documents") { return "In Documents" }
        if lower.contains("/library/caches") || lower.contains("/.cache") { return "In app caches" }
        if lower.contains("/library/developer") || lower.contains("/.gradle") || lower.contains("/node_modules") { return "In developer storage" }
        if lower.contains("/library/cloudstorage") || lower.contains("/mobile documents") { return "In cloud storage" }
        if lower.contains("/library/containers") || lower.contains("/library/group containers") { return "In app containers" }
        if lower.contains("/library/application support") { return "In app support data" }
        if lower.contains("/.trash") { return "In Trash" }
        if lower.hasPrefix("/applications") || lower.hasPrefix("~/applications") { return "In Applications" }
        if lower.contains("/library/logs") || lower.contains("/diagnosticreports") { return "In logs and reports" }
        return "Local storage item"
    }

    nonisolated private static func shortPath(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path == home { return "~" }
        if path.hasPrefix(home + "/") {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    nonisolated private static func isSensitivePathText(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        return lower.hasPrefix("/users/") ||
            lower.hasPrefix("~/") ||
            lower.hasPrefix("/private/") ||
            lower.hasPrefix("/var/") ||
            lower.hasPrefix("/tmp/") ||
            lower.contains("/library/application support/") ||
            lower.contains("/library/containers/") ||
            lower.contains("/library/group containers/") ||
            lower.contains("/library/caches/") ||
            lower.contains("/node_modules/")
    }

    nonisolated private static func stringValue(_ value: Any?) -> String? {
        switch value {
        case let text as String where !text.isEmpty:
            return text
        case let number as NSNumber:
            return number.stringValue
        default:
            return nil
        }
    }

    nonisolated private static func leadingSize(in line: String) -> String? {
        guard let range = line.range(of: "^[0-9]+(\\.[0-9]+)?\\s?(B|KB|MB|GB|TB)\\b", options: [.regularExpression, .caseInsensitive]) else {
            return nil
        }
        return String(line[range])
    }

    func filteredCategories() -> [CleanCategory] {
        switch filter {
        case "caches":    return categories.filter { $0.title == "Caches" }
        case "dev":       return categories.filter { ["Project Dependencies", "Developer Files"].contains($0.title) }
        case "downloads": return categories.filter { ["Downloads", "Archives"].contains($0.title) }
        case "files":     return categories.filter { $0.title == "Large Files" }
        case "apps":      return categories.filter { ["Apps", "App Data"].contains($0.title) }
        case "system":    return categories.filter { ["System Data", "Media Libraries", "Cloud Files"].contains($0.title) }
        case "archives":  return categories.filter { $0.title == "Archives" }
        default:          return categories
        }
    }

    private static func exec(_ executable: String, _ arguments: [String], timeoutSeconds: Double? = AppRunLimit.review, onStart: ((Process) -> Void)? = nil) async -> CommandResult {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: executable)
        p.arguments = arguments
        let pipe = Pipe()
        p.standardOutput = pipe; p.standardError = pipe
        let timedOut = TimeoutFlag()
        let timeoutWork = timeoutSeconds.map { seconds in
            DispatchWorkItem {
                if p.isRunning {
                    timedOut.mark()
                    p.terminate()
                }
            }
        }
        do {
            try p.run()
            onStart?(p)
            if let timeoutWork, let timeoutSeconds {
                DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + timeoutSeconds, execute: timeoutWork)
            }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            p.waitUntilExit()
            timeoutWork?.cancel()
            let text = String(data: data, encoding: .utf8) ?? ""
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let isStructured = trimmed.hasPrefix("{") || trimmed.hasPrefix("[")
            let visibleText = isStructured && p.terminationStatus == 0 ? text : sanitizeForApp(text)
            if timedOut.isMarked {
                let fallback = visibleText.isEmpty ? "" : visibleText + "\n"
                return CommandResult(output: fallback + "This review took too long and was paused. Try a narrower review or run App Checkup.\n", status: 124)
            }
            if p.terminationStatus == 0 {
                return CommandResult(output: visibleText.isEmpty ? "Completed.\n" : visibleText, status: p.terminationStatus)
            }
            if p.terminationStatus == 15 {
                return CommandResult(output: visibleText, status: p.terminationStatus)
            }
            let fallback = visibleText.isEmpty ? "" : visibleText + "\n"
            return CommandResult(output: fallback + "This review could not finish. Please try again or run App Checkup.\n", status: p.terminationStatus)
        } catch {
            return CommandResult(output: "This review could not start. Reopen the app and try again, or run App Checkup.\n", status: -1)
        }
    }

    nonisolated private static func parseCleanupPlan(_ raw: String) -> (items: [CleanupPlanItem], notes: [String]) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: data) else {
            return ([], ["The safety plan could not be loaded. You can still review before cleaning."])
        }

        if let array = parsed as? [[String: Any]] {
            let items = array.map { item -> CleanupPlanItem in
                let title = cleanupPlanTitle(
                    title: stringField("title", in: item),
                    id: stringField("id", in: item)
                )
                let estimate = stringField("estimate", in: item) ?? "Review"
                let safety = friendlySafety(stringField("safety", in: item))
                let recovery = friendlyRecovery(
                    stringField("description", in: item) ??
                    stringField("summary", in: item) ??
                    stringField("recoverability", in: item)
                )
                return CleanupPlanItem(title: title, estimate: estimate, safety: safety, recovery: recovery)
            }
            return (items, [
                "This plan opens instantly; focused reviews show sizes for each area.",
                "Passwords, browser profiles, Photos, Mail, Messages, and cloud folders stay protected.",
                "Clean Now still requires confirmation and moves eligible files to Trash where possible."
            ])
        }

        guard let object = parsed as? [String: Any] else {
            return ([], ["The safety plan could not be loaded. You can still review before cleaning."])
        }

        let categories = object["categories"] as? [[String: Any]] ?? []
        let items = categories.map { item -> CleanupPlanItem in
            let title = cleanupPlanTitle(
                title: stringField("title", in: item),
                id: stringField("id", in: item)
            )
            let safety = friendlySafety(stringField("safety", in: item))
            let recovery = friendlyRecovery(stringField("recoverability", in: item))
            return CleanupPlanItem(title: title, estimate: "Selected", safety: safety, recovery: recovery)
        }
        let rawWarnings = object["warnings"] as? [String] ?? []
        let notes = rawWarnings.map(friendlyCleanupNote)
        return (items, notes)
    }

    nonisolated private static func cleanupPlanTitle(title: String?, id: String?) -> String {
        let raw = (title?.isEmpty == false ? title : id) ?? "Cleanup area"
        let key = (id ?? raw).lowercased()
        let labels: [String: String] = [
            "user-cache-children": "App caches",
            "npm-cache": "NPM cache",
            "yarn-cache": "Yarn cache",
            "gradle-cache": "Gradle cache",
            "pnpm-store": "PNPM store",
            "xcode-derived-data": "Xcode build cache",
            "simulator-caches": "Simulator caches",
            "homebrew-cache": "Homebrew cache",
            "old-logs": "Old logs",
            "safe": "Safe cleanup",
            "app-caches": "App caches",
            "browser-caches": "Browser caches",
            "old-installers": "Old installers",
            "download-artifacts": "Old downloads",
            "screenshots": "Old screenshots",
            "metadata": "Finder clutter",
            "quicklook": "Quick Look cache",
            "font-caches": "Font cache",
            "web-caches": "Web cache",
            "saved-state": "Window state",
            "project-caches": "Project caches",
            "updater-caches": "Update cache",
            "package-stores": "Package stores",
            "toolchains": "Developer tool caches",
            "node-stale": "Old JavaScript packages",
            "venv-stale": "Old Python environments",
            "diagnostics": "Old diagnostics",
            "ai-workspaces": "Generated AI data",
            "ai-models": "Downloaded AI models",
            "containers": "Container storage",
            "user-trash": "Current Trash"
        ]
        if let label = labels[key] {
            return label
        }
        return raw
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(whereSeparator: { $0.isWhitespace })
            .map { word in
                let lower = word.lowercased()
                if lower == "npm" { return "NPM" }
                if lower == "pnpm" { return "PNPM" }
                if lower == "xcode" { return "Xcode" }
                if lower == "ai" { return "AI" }
                return lower.prefix(1).uppercased() + lower.dropFirst()
            }
            .joined(separator: " ")
    }

    nonisolated private static func stringField(_ key: String, in object: [String: Any]) -> String? {
        guard let value = object[key] as? String, !value.isEmpty else { return nil }
        return value
    }

    nonisolated private static func friendlySafety(_ raw: String?) -> String {
        switch raw?.lowercased() {
        case "rebuildable":
            return "Rebuildable"
        case "low-risk":
            return "Low risk"
        case "opt-in":
            return "Optional"
        case "optional":
            return "Optional"
        case "high-impact":
            return "High impact"
        case "high impact":
            return "High impact"
        case "irreversible":
            return "Irreversible"
        case "large-opt-in", "large optional cleanup":
            return "Large optional cleanup"
        case "review":
            return "Review"
        default:
            return "Protected"
        }
    }

    nonisolated private static func friendlyRecovery(_ raw: String?) -> String {
        guard let raw else { return "Moved to Trash where possible." }
        if raw.localizedCaseInsensitiveContains("--apply") ||
            raw.localizedCaseInsensitiveContains("--trash") ||
            raw.localizedCaseInsensitiveContains("dry-run") {
            return "Review first; cleaning only happens after confirmation."
        }
        if raw.localizedCaseInsensitiveContains("Trash mode can recover") {
            return "Moved to Trash where possible."
        }
        if raw.localizedCaseInsensitiveContains("direct removals") {
            return "Moved to Trash where possible."
        }
        if raw.localizedCaseInsensitiveContains("downloaded again") {
            return "Can be downloaded again if needed."
        }
        if raw.localizedCaseInsensitiveContains("rebuilt") {
            return "Can be rebuilt by the related app or developer tool."
        }
        if raw.localizedCaseInsensitiveContains("Virtualenvs may need") {
            return "Can be recreated from the project setup."
        }
        if raw.localizedCaseInsensitiveContains("Dependencies may need") {
            return "Can be reinstalled from the project manifest."
        }
        return raw
            .replacingOccurrences(of: "dry-run", with: "review", options: .caseInsensitive)
    }

    nonisolated private static func friendlyCleanupNote(_ raw: String) -> String {
        if raw.localizedCaseInsensitiveContains("Dry-run mode") {
            return "This is only a review until you choose Clean Now."
        }
        if raw.localizedCaseInsensitiveContains("Apply mode is enabled") {
            return "Cleaning will only start after you confirm."
        }
        if raw.localizedCaseInsensitiveContains("Trash mode is enabled") {
            return "Eligible files move to Trash for easier recovery."
        }
        if raw.localizedCaseInsensitiveContains("Trash mode is not enabled") {
            return "Use safe cleanup to keep eligible files recoverable from Trash."
        }
        if raw.localizedCaseInsensitiveContains("Protected browser profiles") {
            return "Passwords, browser profiles, Photos, Mail, Messages, and cloud folders stay protected."
        }
        if raw.localizedCaseInsensitiveContains("User Trash cleanup is irreversible") {
            return "Emptying the current Trash cannot be restored."
        }
        if raw.localizedCaseInsensitiveContains("Container cleanup") {
            return "Container cleanup can remove local containers, images, and volumes."
        }
        return raw
    }

    nonisolated private static func sanitizeForApp(_ text: String) -> String {
        let plainText = text.replacingOccurrences(
            of: "\u{001B}\\[[0-9;]*[A-Za-z]",
            with: "",
            options: .regularExpression
        )
        let hiddenFragments = [
            "Preview cleanup with:",
            "Apply cleanup with:",
            "Preview emptying Trash with:",
            "Empty Trash with:",
            "Opt-in cleanup preview:",
            "Opt-in cleanup apply:",
            "Opt-in artifact preview:",
            "Opt-in artifact apply:",
            "Apply with:",
            "Preview with:",
            "Dry-run mode.",
            "Pass --apply",
            "Running:",
            "Useful next commands",
            "Review-only inventory",
            "Cleanup commands are dry-runs",
            "Commands shown are",
            "Use the deeper",
            "Use Apps when",
            "Fast review.",
            "Limit:",
            "Path:",
        ]
        let hiddenPrefixes = [
            "reveal:",
            "inspect:",
            "apply:",
            "preview:",
            "hash:",
            "paths:",
            "quarantine:",
            "restore with:",
            "running:",
            "manage:",
            "launch:",
        ]
        let lines = plainText.split(separator: "\n", omittingEmptySubsequences: false)
        let cleaned = lines
            .compactMap { rawLine -> String? in
                var line = String(rawLine)
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                let lowerTrimmed = trimmed.lowercased()
                if hiddenPrefixes.contains(where: { lowerTrimmed.hasPrefix($0) }) {
                    return nil
                }
                if lowerTrimmed.contains("next command") ||
                    lowerTrimmed.contains("preview command") ||
                    lowerTrimmed.contains("apply command") ||
                    lowerTrimmed.contains("review command") ||
                    lowerTrimmed.contains("copyable commands") ||
                    lowerTrimmed.contains("next steps") {
                    return nil
                }
                if hiddenFragments.contains(where: { line.localizedCaseInsensitiveContains($0) }) {
                    return nil
                }
                if Self.isSensitivePathText(trimmed) ||
                    lowerTrimmed.contains(" --apply") ||
                    lowerTrimmed.contains(" --json") ||
                    lowerTrimmed.contains(" --trash") ||
                    lowerTrimmed.contains(" --preflight") ||
                    lowerTrimmed.contains(" --include") ||
                    lowerTrimmed.hasPrefix("--") {
                    return nil
                }
                line = line.replacingOccurrences(of: "^\\s*cleanroom\\s+", with: "", options: [.regularExpression, .caseInsensitive])
                if let commandRange = line.range(of: "\\s+cleanroom\\b.*$", options: [.regularExpression, .caseInsensitive]) {
                    line.removeSubrange(commandRange)
                }
                if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return nil
                }
                return line
            }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? "" : cleaned + "\n"
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
            state.prepareForUse()
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
                    Text("Cleanroom")
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
                            NavRow("heart.text.square.fill",  "App Checkup", .run(.healthCheck), state)
                            NavRow("chart.bar.fill",          "Storage Overview", .run(.storageOverview), state)
                            NavRow("magnifyingglass",         "Analyze Storage", .dashboard, state, onTap: { state.refreshStats(force: true) })
                            NavRow("text.badge.checkmark",    "Review",      .dashboard, state, onTap: { state.filter = "all"; state.refreshStats() })
                            NavRow("list.clipboard.fill",     "Clean Safely", .dashboard, state, onTap: { state.showApplyConfirm = true })
                        }
                        SidebarSection("FIND") {
                            NavRow("doc.fill",                "Large Files", .run(.largeFiles), state)
                            NavRow("doc.on.doc.fill",         "Duplicates",  .run(.duplicates), state)
                            NavRow("link.badge.plus",         "Missing Files",.run(.missingFiles), state)
                            NavRow("lock.shield.fill",        "Download Warnings", .run(.downloadWarnings), state)
                            NavRow("sparkle.magnifyingglass", "Finder Clutter", .run(.finderClutter), state)
                            NavRow("magnifyingglass.circle.fill","Leftovers", .dashboard, state, onTap: { state.showLeftovers = true })
                        }
                        SidebarSection("CATEGORIES") {
                            NavRow("folder.fill",             "Documents",   .run(.documents), state)
                            NavRow("menubar.rectangle",       "Desktop",     .run(.desktop), state)
                            NavRow("arrow.down.to.line",      "Downloads",   .run(.downloads), state)
                            NavRow("archivebox.fill",         "Archives",    .run(.archives), state)
                            NavRow("camera.viewfinder",       "Screenshots", .run(.screenshots), state)
                            NavRow("xmark.bin.fill",          "Caches",      .run(.caches), state)
                            NavRow("eye.fill",                "Quick Look Cache", .run(.previewCache), state)
                            NavRow("textformat",              "Font Cache", .run(.fontCache), state)
                            NavRow("safari.fill",             "Web Cache",  .run(.webCache), state)
                            NavRow("rectangle.stack.fill",    "Window State", .run(.windowState), state)
                            NavRow("chevron.left.forwardslash.chevron.right", "Project Cache", .run(.projectCache), state)
                            NavRow("arrow.clockwise.circle.fill", "Update Cache", .run(.updateCache), state)
                            NavRow("globe", "Browser Cache", .run(.browserCache), state)
                            NavRow("sparkles", "AI Tools", .run(.aiTools), state)
                            NavRow("internaldrive.fill",      "App Data",    .run(.appData), state)
                            NavRow("photo.fill",              "Media Libraries", .run(.mediaLibraries), state)
                            NavRow("shippingbox.fill",        "Project Dependencies",.run(.javascriptPackages), state)
                            NavRow("square.stack.3d.up.fill", "Python Project Data", .run(.pythonEnvironments), state)
                            NavRow("apps.iphone",             "Apps",        .run(.apps), state)
                            NavRow("app.badge.checkmark.fill","App Review",  .dashboard, state, onTap: { state.showLeftovers = true })
                            NavRow("trash.fill",              "Trash",       .run(.trash), state)
                            NavRow("icloud.fill",             "Cloud Files", .run(.cloudFiles), state)
                        }
                        SidebarSection("SYSTEM") {
                            NavRow("hammer.fill",             "Apple Developer Storage", .run(.xcode), state)
                            NavRow("clock.arrow.circlepath",  "Backups",     .run(.backups), state)
                            NavRow("externaldrive.fill",      "System Data", .run(.systemData), state)
                            NavRow("shippingbox.fill",        "Container Storage", .run(.containers), state)
                            NavRow("wrench.and.screwdriver",  "Developer Caches", .run(.developerTools), state)
                            NavRow("person.crop.circle",      "Login Items", .run(.loginItems), state)
                            NavRow("bolt.fill",               "Startup Items", .run(.startup), state)
                        }
                        SidebarSection("SAFETY") {
                            NavRow("camera.fill",             "Storage Snapshot", .run(.storageRecord), state)
                            NavRow("clock.badge.checkmark.fill", "Restore History", .run(.restoreHistory), state)
                            NavRow("checkmark.shield.fill",   "Cleanup Plan", .run(.safetyCheck), state)
                            NavRow("doc.text.fill",           "Privacy Summary", .run(.privacyReport), state)
                            NavRow("clock.fill",              "Recent Cleanups", .run(.pastCleanups), state)
                            NavRow("shield.fill",             "Protected Data", .run(.protectedItems), state)
                            NavRow("flag.fill",               "Safety Rules", .run(.safetyPolicy), state)
                        }
                    }
                    .padding(.bottom, DS.Sp.xxl)
                }

                Rectangle().fill(DS.C.dividerOnDark).frame(height: 1)
                HStack {
                    Text("Protected mode")
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
    var isDisabled: Bool {
        if state.running || (state.statsLoading && onTap != nil) {
            if onTap != nil { return true }
            if case .run = nav { return true }
        }
        return false
    }

    var body: some View {
        Button {
            if let tap = onTap { tap(); return }
            if case .run(let action) = nav {
                withAnimation(DS.Ani.snap) { state.openReview(action) }
            } else {
                withAnimation(DS.Ani.snap) { state.dest = nav }
            }
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
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.42 : 1)
        .onHover { hovered = $0 }
        .animation(DS.Ani.snap, value: hovered)
        .animation(DS.Ani.snap, value: isDisabled)
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
            ReviewSummaryPanel(state: state)
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
                    NavArrow(icon: "arrow.left", disabled: state.running) { state.openReview(.pastCleanups) }
                    NavArrow(icon: "arrow.right", disabled: state.running || state.statsLoading) { state.showApplyConfirm = true }
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
                PillBtn("Analyze Storage", style: .ghost) { state.refreshStats(force: true) }
                    .disabled(state.running || state.statsLoading)
                    .opacity((state.running || state.statsLoading) ? 0.42 : 1)
                Spacer()
                PillBtn("Clean Safely", style: .primary) {
                    state.showApplyConfirm = true
                }
                .disabled(state.running || state.statsLoading)
                .opacity((state.running || state.statsLoading) ? 0.42 : 1)
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
    var disabled: Bool = false
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
        .disabled(disabled)
        .opacity(disabled ? 0.42 : 1)
        .onHover { hovered = $0 }
        .animation(DS.Ani.snap, value: hovered)
        .animation(DS.Ani.snap, value: disabled)
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Sp.xs) {
                    ForEach(state.filters, id: \.id) { f in
                        FilterChip(label: f.label, active: state.filter == f.id) {
                            withAnimation(DS.Ani.snap) { state.filter = f.id }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Button { state.refreshStats(force: true) } label: {
                HStack(spacing: 4) {
                    Text("Analyze Storage").font(DS.T.body)
                    Image(systemName: "arrow.right").font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(DS.C.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(state.running || state.statsLoading)
            .opacity((state.running || state.statsLoading) ? 0.42 : 1)
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
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
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
                    state.openReview(category.action)
                } label: {
                    HStack(spacing: 5) {
                        Text("Review")
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
                .disabled(state.running)
                .opacity(state.running ? 0.42 : 1)
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
// MARK: – Review Summary Panel
// ═══════════════════════════════════════════════════════════════

struct ReviewSummaryPanel: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: DS.Sp.sm) {
                Circle()
                    .fill((state.running || state.statsLoading) ? DS.C.ctaOrange : DS.C.positive)
                    .frame(width: 7, height: 7)
                    .animation(DS.Ani.std, value: state.running)
                    .animation(DS.Ani.std, value: state.statsLoading)
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.activityMessage)
                        .font(DS.T.bodySm)
                        .foregroundColor(DS.C.textOnDark.opacity(0.82))
                        .lineLimit(1)
                    Text(state.status)
                        .font(DS.T.tag)
                        .foregroundColor(DS.C.textOnDark.opacity(0.48))
                        .lineLimit(1)
                }
                Spacer()
                if state.running {
                    IconBtn(icon: "xmark.circle.fill", dark: true) {
                        state.cancelRun()
                    }
                    .help("Stop current review")
                } else if state.hasReportContent {
                    IconBtn(icon: "doc.on.clipboard", dark: true) {
                        state.copyDetails()
                    }
                    .help("Copy report")
                    IconBtn(icon: "xmark", dark: true) {
                        state.clearSummary()
                    }
                    .help("Clear report")
                }
                IconBtn(icon: state.summaryOpen ? "chevron.down" : "chevron.up", dark: true) {
                    withAnimation(DS.Ani.std) { state.summaryOpen.toggle() }
                }
                .help(state.summaryOpen ? "Hide report" : "Show report")
            }
            .padding(.horizontal, DS.Sp.lg)
            .padding(.vertical, DS.Sp.sm)
            .background(DS.C.sidebarBg.opacity(0.96))

            if state.summaryOpen {
                ScrollView(showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: DS.Sp.md) {
                        if state.reviewItems.isEmpty {
                            EmptyReportPanel(state: state)
                        } else {
                            HStack(alignment: .firstTextBaseline) {
                                Text(state.reviewTitle)
                                    .font(DS.T.h3)
                                    .foregroundColor(DS.C.textOnDark)
                                Spacer()
                                Text("\(state.reviewItems.count) items")
                                    .font(DS.T.tag)
                                    .foregroundColor(DS.C.textOnDark.opacity(0.52))
                            }
                            ForEach(state.reviewItems) { item in
                                ReviewResultRow(item: item)
                            }
                        }
                    }
                    .padding(DS.Sp.lg)
                }
                .frame(height: DS.Layout.summaryH)
                .background(DS.C.summaryBg.opacity(0.98))
            }
        }
    }
}

struct EmptyReportPanel: View {
    @ObservedObject var state: AppState

    var body: some View {
        HStack(alignment: .top, spacing: DS.Sp.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(DS.T.h3)
                    .foregroundColor(DS.C.textOnDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(detail)
                    .font(DS.T.bodySm)
                    .foregroundColor(DS.C.textOnDark.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
                Text(state.status)
                    .font(DS.T.tag)
                    .foregroundColor(DS.C.textOnDark.opacity(0.46))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(DS.Sp.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DS.R.sm)
                .fill(Color.white.opacity(0.055))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.R.sm)
                .stroke(DS.C.dividerOnDark, lineWidth: 1)
        )
    }

    private var title: String {
        if state.running { return "Review In Progress" }
        if state.statsLoading { return "Storage Analysis In Progress" }
        if state.status.localizedCaseInsensitiveContains("attention") { return "Needs Attention" }
        if state.status.localizedCaseInsensitiveContains("copied") { return "Report Copied" }
        if state.reviewTitle != "Review Report" { return state.reviewTitle }
        return "Ready When You Are"
    }

    private var detail: String {
        if state.running {
            return "Cleanroom is checking this area and will show clear review rows when it finishes."
        }
        if state.statsLoading {
            return "Cleanroom is measuring storage without changing files."
        }
        let clean = state.activityMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.isEmpty ? "Choose a review area to see what can be safely cleaned." : clean
    }

    private var icon: String {
        if state.running || state.statsLoading { return "clock.arrow.circlepath" }
        if state.status.localizedCaseInsensitiveContains("attention") { return "exclamationmark.triangle.fill" }
        if state.status.localizedCaseInsensitiveContains("copied") { return "doc.on.clipboard.fill" }
        return "checkmark.shield.fill"
    }

    private var iconColor: Color {
        if state.status.localizedCaseInsensitiveContains("attention") { return DS.C.ctaOrange }
        if state.running || state.statsLoading { return DS.C.ctaOrange }
        return DS.C.positive
    }
}

struct ReviewResultRow: View {
    let item: ReviewItem

    var body: some View {
        HStack(alignment: .top, spacing: DS.Sp.md) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.size)
                    .font(DS.T.h3)
                    .foregroundColor(DS.C.textOnDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(item.badge)
                    .font(DS.T.tag)
                    .foregroundColor(DS.C.ctaOrangeSoft.opacity(0.88))
                    .lineLimit(1)
            }
            .frame(width: 86, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(DS.T.bodySm.weight(.semibold))
                    .foregroundColor(DS.C.textOnDark.opacity(0.92))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(item.detail)
                    .font(DS.T.bodySm)
                    .foregroundColor(DS.C.textOnDark.opacity(0.66))
                    .lineLimit(2)
                    .truncationMode(.middle)
                if let hint = locationHint(for: item) {
                    Text(hint)
                        .font(DS.T.bodySm)
                        .foregroundColor(DS.C.textOnDark.opacity(0.46))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(DS.Sp.md)
        .background(
            RoundedRectangle(cornerRadius: DS.R.sm)
                .fill(Color.white.opacity(0.055))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.R.sm)
                .stroke(DS.C.dividerOnDark, lineWidth: 1)
        )
    }

    private func locationHint(for item: ReviewItem) -> String? {
        if item.badge.localizedCaseInsensitiveContains("protected") {
            return "Protected by default"
        }
        guard let path = item.path, path != item.detail else { return nil }
        return friendlyLocation(shortPath(path))
    }

    private func friendlyLocation(_ path: String) -> String {
        let lower = path.lowercased()
        if lower.contains("/downloads") || lower.hasPrefix("~/downloads") { return "In Downloads" }
        if lower.contains("/desktop") || lower.hasPrefix("~/desktop") { return "On Desktop" }
        if lower.contains("/documents") || lower.hasPrefix("~/documents") { return "In Documents" }
        if lower.contains("/library/caches") || lower.contains("/.cache") { return "In app caches" }
        if lower.contains("/library/developer") || lower.contains("/.gradle") || lower.contains("/node_modules") { return "In developer storage" }
        if lower.contains("/library/cloudstorage") || lower.contains("/mobile documents") { return "In cloud storage" }
        if lower.contains("/library/containers") || lower.contains("/library/group containers") { return "In app containers" }
        if lower.contains("/library/application support") { return "In app support data" }
        if lower.contains("/.trash") { return "In Trash" }
        if lower.hasPrefix("/applications") || lower.hasPrefix("~/applications") { return "In Applications" }
        if lower.contains("/library/logs") || lower.contains("/diagnosticreports") { return "In logs and reports" }
        return "Local storage item"
    }

    private func shortPath(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path == home { return "~" }
        if path.hasPrefix(home + "/") {
            return "~" + path.dropFirst(home.count)
        }
        return path
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
                Text("Enter an app or vendor name to review matching files before cleaning anything.")
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
                    Text("Clean safely?")
                        .font(DS.T.h2)
                        .foregroundColor(DS.C.textPrimary)
                    Text("Cleanroom only touches selected safe areas. Personal data stays protected.")
                        .font(DS.T.bodySm)
                        .foregroundColor(DS.C.textSecondary)
                }
            }

            Rectangle().fill(DS.C.divider).frame(height: 1)

            VStack(alignment: .leading, spacing: DS.Sp.sm) {
                HStack {
                    Text("SELECTED AREAS")
                        .font(DS.T.tag).kerning(0.6)
                        .foregroundColor(DS.C.textMuted)
                    Spacer()
                    if state.cleanupPlanLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.55)
                    }
                }
                if state.cleanupPlanItems.isEmpty && !state.cleanupPlanLoading {
                    HStack(spacing: DS.Sp.sm) {
                        Circle().fill(DS.C.positive).frame(width: 5, height: 5)
                        Text("Rebuildable clutter and old logs are selected by default.")
                            .font(DS.T.body)
                            .foregroundColor(DS.C.textSecondary)
                    }
                } else {
                    ForEach(state.cleanupPlanItems) { item in
                        CleanupPlanRow(item: item)
                    }
                }
            }

            VStack(alignment: .leading, spacing: DS.Sp.sm) {
                Text("PROTECTED")
                    .font(DS.T.tag).kerning(0.6)
                    .foregroundColor(DS.C.textMuted)
                ForEach(cleanupNotes, id: \.self) { item in
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
                PillBtn("Review Plan", style: .ghost) {
                    if !state.running {
                        state.openReview(.safetyPlan)
                        dismiss()
                    }
                }
                .disabled(state.running)
                .opacity(state.running ? 0.42 : 1)
                PillBtn("Clean Now", style: .primary) {
                    if !state.running && !state.statsLoading {
                        state.run(.safeCleanup)
                        dismiss()
                    }
                }
                .disabled(state.running || state.statsLoading)
                .opacity((state.running || state.statsLoading) ? 0.42 : 1)
            }
        }
        .padding(DS.Sp.xxl)
        .frame(width: 540, height: 460)
        .background(DS.C.canvas)
        .onAppear {
            if state.cleanupPlanItems.isEmpty {
                state.refreshCleanupPlan()
            }
        }
    }

    private var cleanupNotes: [String] {
        if state.cleanupPlanNotes.isEmpty {
            return [
                "Items are moved to Trash where possible.",
                "Passwords, browser profiles, Photos, Mail, Messages, and cloud folders stay protected.",
                "Cleanroom keeps a recovery trail for files it moves.",
            ]
        }
        return state.cleanupPlanNotes
    }
}

struct CleanupPlanRow: View {
    let item: CleanupPlanItem

    var body: some View {
        HStack(alignment: .top, spacing: DS.Sp.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
                .background(Circle().fill(color.opacity(0.12)))
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .font(DS.T.body.weight(.semibold))
                        .foregroundColor(DS.C.textPrimary)
                    Spacer()
                    Text(item.estimate)
                        .font(DS.T.tag)
                        .foregroundColor(DS.C.textMuted)
                    Text(item.safety)
                        .font(DS.T.tag)
                        .foregroundColor(color)
                }
                Text(item.recovery)
                    .font(DS.T.bodySm)
                    .foregroundColor(DS.C.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(DS.Sp.md)
        .background(RoundedRectangle(cornerRadius: DS.R.sm).fill(Color.white.opacity(0.55)))
        .overlay(RoundedRectangle(cornerRadius: DS.R.sm).stroke(DS.C.divider, lineWidth: 1))
    }

    private var color: Color {
        switch item.safety {
        case "High impact", "Irreversible":
            return DS.C.negative
        case "Optional", "Large optional cleanup", "Review":
            return DS.C.caution
        default:
            return DS.C.positive
        }
    }

    private var icon: String {
        switch item.safety {
        case "High impact", "Irreversible":
            return "exclamationmark.triangle.fill"
        case "Optional", "Large optional cleanup", "Review":
            return "questionmark.circle.fill"
        default:
            return "checkmark.circle.fill"
        }
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
