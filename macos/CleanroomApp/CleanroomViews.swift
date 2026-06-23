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
    var safety: String
    var recovery: String
}

struct AppAction: Hashable {
    let title: String
    let args: [String]

    static let healthCheck = AppAction(title: "Health Check", args: ["doctor"])
    static let storageOverview = AppAction(title: "Storage Overview", args: ["map-fast"])
    static let largeFiles = AppAction(title: "Large Files", args: ["large-fast", "--limit", "30", "--min-mb", "500"])
    static let duplicates = AppAction(title: "Duplicates", args: ["duplicates-fast", "--limit", "20", "--min-mb", "100"])
    static let missingFiles = AppAction(title: "Missing Files", args: ["brokenlinks-fast", "~/Downloads", "--limit", "40"])
    static let downloadWarnings = AppAction(title: "Download Warnings", args: ["quarantine-fast", "--limit", "40"])
    static let finderClutter = AppAction(title: "Finder Clutter", args: ["metadata-fast", "--limit", "40"])
    static let downloads = AppAction(title: "Downloads", args: ["downloads-fast", "--limit", "30", "--days", "30"])
    static let archives = AppAction(title: "Archives", args: ["archives-fast", "--limit", "30", "--days", "7"])
    static let screenshots = AppAction(title: "Screenshots", args: ["screenshots-fast", "--limit", "30", "--days", "7"])
    static let caches = AppAction(title: "Caches", args: ["caches-fast"])
    static let developerFiles = AppAction(title: "Developer Files", args: ["developer-fast", "--limit", "30", "--days", "30"])
    static let previewCache = AppAction(title: "Preview Cache", args: ["quicklook-fast"])
    static let fontCache = AppAction(title: "Font Cache", args: ["fontcaches-fast"])
    static let webCache = AppAction(title: "Web Cache", args: ["webcaches-fast"])
    static let windowState = AppAction(title: "Window State", args: ["savedstate-fast"])
    static let projectCache = AppAction(title: "Project Cache", args: ["projectcaches-fast", "--limit", "40"])
    static let updateCache = AppAction(title: "Update Cache", args: ["updaters-fast"])
    static let browserCache = AppAction(title: "Browser Cache", args: ["browsercaches-fast"])
    static let aiTools = AppAction(title: "AI Tools", args: ["aitools"])
    static let javascriptPackages = AppAction(title: "JavaScript Packages", args: ["nodes-fast", "--limit", "30", "--days", "30"])
    static let pythonEnvironments = AppAction(title: "Python Environments", args: ["venvs-fast", "--limit", "30", "--days", "30"])
    static let apps = AppAction(title: "Apps", args: ["apps-fast", "--limit", "30"])
    static let trash = AppAction(title: "Trash", args: ["trash"])
    static let cloudFiles = AppAction(title: "Cloud Files", args: ["cloudfiles-fast", "--min-mb", "250", "--limit", "40"])
    static let xcode = AppAction(title: "Xcode", args: ["xcode-fast"])
    static let backups = AppAction(title: "Backups", args: ["backups-fast"])
    static let systemData = AppAction(title: "System Data", args: ["system-data-fast"])
    static let containers = AppAction(title: "Containers", args: ["containers-fast"])
    static let developerTools = AppAction(title: "Developer Tools", args: ["toolchains-fast"])
    static let loginItems = AppAction(title: "Login Items", args: ["loginitems"])
    static let startup = AppAction(title: "Startup", args: ["startup"])
    static let storageRecord = AppAction(title: "Storage Record", args: ["snapshot-fast"])
    static let restoreHistory = AppAction(title: "Restore History", args: ["state"])
    static let safetyCheck = AppAction(title: "Safety Check", args: ["clean", "--preset", "dev", "--preflight"])
    static let privacyReport = AppAction(title: "Privacy Report", args: ["report-fast", "--redact"])
    static let pastCleanups = AppAction(title: "Past Cleanups", args: ["history"])
    static let protectedItems = AppAction(title: "Protected Items", args: ["protect"])
    static let safetyPolicy = AppAction(title: "Safety Policy", args: ["rules"])
    static let safetyPlan = AppAction(title: "Safety Plan", args: ["clean", "--preflight"])
    static let safeCleanup = AppAction(title: "Safe Cleanup", args: ["clean", "--apply", "--trash", "--yes"])

    static func appReview(query: String) -> AppAction {
        AppAction(title: "App Review: \(query)", args: ["appreview", query, "--limit", "40"])
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
    @Published var output:           String  = "No activity yet.\n"
    @Published var running:          Bool    = false
    @Published var status:           String  = "Ready"
    @Published var activityMessage:  String  = "Choose a review or cleanup to begin."
    @Published var outputOpen:       Bool    = false
    @Published var showLeftovers:    Bool    = false
    @Published var showApplyConfirm: Bool    = false
    @Published var cardOffset:       Int     = 0
    @Published var reviewTitle:      String  = "Review Summary"
    @Published var reviewItems:      [ReviewItem] = []
    @Published var cleanupPlanItems: [CleanupPlanItem] = []
    @Published var cleanupPlanNotes: [String] = []
    @Published var cleanupPlanLoading: Bool = false

    @Published var stats: [StorageStat] = [
        StorageStat(label: "Disk Used",   value: "—"),
        StorageStat(label: "Reclaimable", value: "Refresh"),
        StorageStat(label: "Protected",   value: "On"),
        StorageStat(label: "Last Scan",   value: "Not yet"),
    ]

    @Published var categories: [CleanCategory] = [
        CleanCategory(title: "Caches",       tagline: "App & system caches accumulating silently",      icon: "xmark.bin.fill",        color: DS.C.cardForest,   action: .caches),
        CleanCategory(title: "JavaScript Packages", tagline: "Old project dependencies and package caches", icon: "shippingbox.fill",      color: DS.C.cardViolet,   action: .javascriptPackages),
        CleanCategory(title: "Downloads",    tagline: "Old downloads, DMGs, and forgotten installers",  icon: "arrow.down.to.line",    color: DS.C.cardAmber,    action: .downloads),
        CleanCategory(title: "Large Files",  tagline: "Files over 500 MB that may no longer be needed", icon: "doc.fill",              color: DS.C.cardSlate,    action: .largeFiles),
        CleanCategory(title: "Archives",     tagline: "Old zip archives, tar files, and disk images",   icon: "archivebox.fill",       color: DS.C.cardRose,     action: .archives),
        CleanCategory(title: "Developer Files", tagline: "Build artifacts, environments, and SDK caches", icon: "hammer.fill",           color: DS.C.cardTeal,     action: .developerFiles),
        CleanCategory(title: "Screenshots",  tagline: "Old screenshots accumulating on Desktop",        icon: "camera.viewfinder",     color: DS.C.cardBark,     action: .screenshots),
        CleanCategory(title: "Trash",        tagline: "Files waiting in macOS Trash",                   icon: "trash.fill",            color: DS.C.cardCharcoal, action: .trash),
    ]

    let filters: [(id: String, label: String)] = [
        ("all",       "OVERVIEW"),
        ("caches",    "CACHES"),
        ("dev",       "DEVELOPER"),
        ("downloads", "DOWNLOADS"),
        ("files",     "LARGE FILES"),
        ("archives",  "ARCHIVES"),
    ]

    var enginePath = ""
    private var lastStatsRefresh: Date? = nil
    private var currentProcess: Process? = nil
    private var currentRunID = UUID()

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
        resolveEngine()
        status = "Ready"
        activityMessage = "Choose a review, or refresh the storage summary when you want updated numbers."
    }

    // Expensive storage measurement; run only when the user asks or after cleanup.
    func refreshStats(force: Bool = false) {
        guard !running else { return }
        if !force,
           let lastStatsRefresh,
           Date().timeIntervalSince(lastStatsRefresh) < 30 {
            status = "Storage summary is up to date"
            activityMessage = "Your storage summary was refreshed recently."
            return
        }
        status = "Measuring storage..."
        activityMessage = "Checking disk usage without starting a cleanup."
        lastStatsRefresh = Date()
        let command = resolvedCommand(["dashboard", "--json"])
        Task.detached(priority: .background) {
            let raw = await Self.exec(command.executable, command.arguments)
            await MainActor.run {
                self.parseStats(raw.output)
                self.status = "Storage summary updated"
                self.activityMessage = "Storage summary updated. No files were changed."
            }
        }
    }

    func refreshCleanupPlan() {
        guard !cleanupPlanLoading else { return }
        cleanupPlanLoading = true
        cleanupPlanItems = []
        cleanupPlanNotes = []
        let command = resolvedCommand(["clean", "--preflight", "--json"])
        Task.detached(priority: .background) {
            let result = await Self.exec(command.executable, command.arguments)
            let parsed = Self.parseCleanupPlan(result.output)
            await MainActor.run {
                self.cleanupPlanItems = parsed.items
                self.cleanupPlanNotes = parsed.notes
                self.cleanupPlanLoading = false
            }
        }
    }

    private func parseStats(_ raw: String) {
        if parseStatsJSON(raw) {
            return
        }
        // Best-effort: scan for recognisable patterns in JSON output.
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

        if let used = grab("used_kb") ?? grab("disk_used") ?? grab("total_used") {
            stats[0].value = formatKBString(used)
        }
        if let rec = grab("estimate") ?? grab("reclaimable") ?? grab("recoverable") {
            stats[1].value = rec
        }
        if let protected = grab("protected_present") {
            stats[2].value = protected
        }
    }

    private func parseStatsJSON(_ raw: String) -> Bool {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        stats[3].value = formatter.string(from: Date())

        if let usedKB = numberValue(object["used_kb"]) {
            stats[0].value = formatKBString(String(usedKB))
        } else if let used = stringValue(object["used"]) ?? stringValue(object["disk_used"]) {
            stats[0].value = used
        }

        if let summary = object["summary"] as? [String: Any] {
            if let reclaimable = stringValue(summary["reclaimable"]) {
                stats[1].value = reclaimable
            }
            if let protected = numberValue(summary["protected_present"]) {
                stats[2].value = "\(protected) guarded"
            } else if let protected = stringValue(summary["protected_present"]) {
                stats[2].value = protected
            }
        }

        if let cards = object["cards"] as? [[String: Any]] {
            applyDashboardCards(cards)
        }
        return true
    }

    private func applyDashboardCards(_ cards: [[String: Any]]) {
        var valuesByTitle: [String: String] = [:]
        for card in cards {
            guard let title = stringValue(card["title"]),
                  let value = stringValue(card["value"]) else { continue }
            valuesByTitle[title] = value
        }
        categories = categories.map { category in
            var updated = category
            if let value = valuesByTitle[category.title] {
                updated.result = value
            }
            return updated
        }
    }

    private func numberValue(_ value: Any?) -> Int? {
        switch value {
        case let number as NSNumber:
            return number.intValue
        case let text as String:
            return Int(text)
        default:
            return nil
        }
    }

    private func formatKBString(_ raw: String) -> String {
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

    func run(_ action: AppAction) {
        guard !running else { return }
        let runID = UUID()
        currentRunID = runID
        currentProcess = nil
        running    = true
        status     = "\(action.title) in progress..."
        activityMessage = "\(action.title) is running. You can stop it anytime."
        output    += "\nReviewing \(action.title)...\n"
        reviewTitle = action.title
        reviewItems = []
        let commandArgs = appFacingArgs(action.args)
        let command = resolvedCommand(commandArgs)
        Task.detached(priority: .userInitiated) {
            let result = await Self.exec(command.executable, command.arguments) { process in
                Task { @MainActor in
                    if self.currentRunID == runID && self.running && process.isRunning {
                        self.currentProcess = process
                    }
                }
            }
            await MainActor.run {
                guard self.currentRunID == runID else { return }
                self.currentProcess = nil
                let displayOutput = self.presentableDetails(title: action.title, action: action, details: result.output)
                self.reviewTitle = action.title
                self.reviewItems = self.presentableReviewItems(title: action.title, action: action, details: result.output)
                self.output += displayOutput
                if result.status == 15 {
                    self.status = "\(action.title) stopped"
                    self.activityMessage = "\(action.title) stopped. Open the summary to see where it paused."
                    self.output += "Review stopped.\n"
                    self.outputOpen = true
                } else if result.status == 0 {
                    self.status = "\(action.title) complete"
                    self.activityMessage = self.summarizeAction(action: action, details: displayOutput)
                    self.outputOpen = false
                } else {
                    self.status = "\(action.title) needs attention"
                    self.activityMessage = "\(action.title) needs attention. Open the summary for what happened."
                    self.outputOpen = true
                }
                self.running = false
                if action == .safeCleanup {
                    self.refreshStats(force: true)
                }
            }
        }
    }

    func cancelRun() {
        guard let process = currentProcess, process.isRunning else { return }
        status = "Stopping..."
        activityMessage = "Stopping the current action..."
        output += "Stopping current action...\n"
        outputOpen = true
        currentProcess = nil
        reviewItems = []
        process.terminate()
    }

    func runLeftovers(_ query: String) {
        run(.appReview(query: query))
    }

    func copyDetails() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(appFacingSummaryText(), forType: .string)
        status = "Summary copied"
        activityMessage = "Review summary copied."
    }

    private func appFacingSummaryText() -> String {
        guard !reviewItems.isEmpty else {
            let clean = Self.sanitizeForApp(output)
            return clean.isEmpty ? "No review summary available yet.\n" : clean
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
            "downloads", "downloads-fast", "archives", "archives-fast", "screenshots", "screenshots-fast", "trash", "cloudfiles", "cloudfiles-fast", "caches-fast",
            "quicklook", "quicklook-fast", "fontcaches", "fontcaches-fast", "webcaches", "webcaches-fast", "savedstate", "savedstate-fast",
            "projectcaches", "projectcaches-fast", "updaters", "updaters-fast", "browsercaches", "browsercaches-fast",
            "aitools", "ai-tools", "ai",
            "xcode", "xcode-fast", "backups", "backups-fast", "system-data", "system-data-fast", "containers", "containers-fast", "toolchains", "toolchains-fast",
            "loginitems", "startup", "snapshot", "snapshot-fast", "state", "protect", "rules",
            "map", "map-fast", "doctor", "leftovers", "appreview", "history", "report-fast"
        ]
        if jsonActions.contains(action), !args.contains("--json") {
            return args + ["--json"]
        }
        if action == "clean", args.contains("--preflight"), !args.contains("--json") {
            return args + ["--json"]
        }
        return args
    }

    private func summarizeAction(action: AppAction, details: String) -> String {
        let changedFiles = action.args.contains("--apply")
        let title = action.title
        let noChangeText = changedFiles ? "" : " No files were changed."
        let lowerDetails = details.lowercased()

        if lowerDetails.contains("trash is empty") {
            return "Trash is empty. No files were changed."
        }
        if lowerDetails.contains("nothing to clean") || lowerDetails.contains("no matches") || lowerDetails.contains("no files found") {
            return "\(title) found nothing that needs attention.\(noChangeText)"
        }
        if changedFiles {
            return "\(title) finished. Items were moved to Trash where possible."
        }

        let rows = reviewRows(in: details)
        if rows.count == 1, let size = leadingSize(in: rows[0]) {
            return "\(title) found 1 review item, starting at \(size). No files were changed."
        }
        if rows.count > 1, let size = leadingSize(in: rows[0]) {
            return "\(title) found \(rows.count) review items, largest starts at \(size). No files were changed."
        }
        if rows.count > 0 {
            return "\(title) found \(rows.count) review items. No files were changed."
        }
        return "\(title) finished. A summary is available if you need it."
    }

    private func presentableDetails(title: String, action: AppAction, details: String) -> String {
        let trimmed = details.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: data),
              let items = jsonItems(from: parsed) else {
            let clean = Self.sanitizeForApp(details)
            return clean.isEmpty ? "\(title) finished. A summary is available if you need it.\n" : clean
        }

        if items.isEmpty {
            return "\(title) found nothing that needs attention.\n"
        }

        var lines = ["\(title) found \(items.count) review \(items.count == 1 ? "item" : "items")."]
        for item in items.prefix(40) {
            lines.append(summaryLine(for: item))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private func presentableReviewItems(title: String, action: AppAction, details: String) -> [ReviewItem] {
        let trimmed = details.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: data),
              let items = jsonItems(from: parsed) else {
            return []
        }
        return items.prefix(80).map { reviewItem(from: $0) }
    }

    private func jsonItems(from parsed: Any) -> [[String: Any]]? {
        if let array = parsed as? [[String: Any]] {
            return appFacingItems(array)
        }
        if let object = parsed as? [String: Any] {
            if let available = object["available"] as? Bool, !available {
                return []
            }
            if let preflightItems = preflightReviewItems(from: object) {
                return appFacingItems(preflightItems)
            }
            if let array = object["items"] as? [[String: Any]] {
                return appFacingItems(array)
            }
            if let array = object["categories"] as? [[String: Any]] {
                return appFacingItems(array)
            }
            if let array = object["buckets"] as? [[String: Any]] {
                return appFacingItems(array)
            }
            if let array = object["cards"] as? [[String: Any]] {
                return appFacingItems(array)
            }
            if let doctorItems = doctorReviewItems(from: object) {
                return appFacingItems(doctorItems)
            }
            var grouped: [[String: Any]] = []
            for key in ["apps", "uninstallers", "receipts", "leftovers"] {
                if let array = object[key] as? [[String: Any]] {
                    grouped.append(contentsOf: array)
                }
            }
            if !grouped.isEmpty {
                return appFacingItems(grouped)
            }
        }
        return nil
    }

    private func preflightReviewItems(from object: [String: Any]) -> [[String: Any]]? {
        guard stringValue(object["action"]) == "clean",
              let categories = object["categories"] as? [[String: Any]] else {
            return nil
        }

        var items: [[String: Any]] = categories.map { item in
            let title = stringValue(item["title"]) ?? stringValue(item["id"]) ?? "Cleanup Area"
            let safety = Self.friendlySafety(stringValue(item["safety"]))
            let recovery = Self.friendlyRecovery(stringValue(item["recoverability"]))
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
            "title": apply ? "Ready To Clean" : "Review Only",
            "size": apply ? "Ready" : "Preview",
            "status": apply ? "Review" : "Protected",
            "summary": apply
                ? "Cleaning will only start after confirmation."
                : "No files are changed in this review."
        ], at: 0)

        return items
    }

    private func doctorReviewItems(from object: [String: Any]) -> [[String: Any]]? {
        guard object["platform"] is [String: Any] ||
              object["tools"] is [[String: Any]] ||
              object["safety"] is [String: Any] else {
            return nil
        }

        var items: [[String: Any]] = []

        if let disk = object["disk"] as? [String: Any] {
            let capacity = stringValue(disk["capacity"]) ?? "Review"
            let available = numberValue(disk["available_kb"]).map { formatKBString(String($0)) } ?? "available space"
            let used = numberValue(disk["used_kb"]).map { formatKBString(String($0)) } ?? "current usage"
            items.append([
                "title": "Disk Space",
                "size": capacity,
                "status": "Review",
                "summary": "\(available) available, \(used) used."
            ])
        }

        if let safety = object["safety"] as? [String: Any] {
            let protected = numberValue(safety["protected_present"]) ?? 0
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
            let missingRequired = required.filter { stringValue($0["status"]) != "ok" }
            items.append([
                "title": "Required Tools",
                "size": missingRequired.isEmpty ? "Ready" : "\(missingRequired.count) missing",
                "status": missingRequired.isEmpty ? "Ready" : "Needs Attention",
                "summary": missingRequired.isEmpty
                    ? "All required system tools are available."
                    : "Some required system tools are missing or unavailable."
            ])

            for tool in tools.prefix(12) {
                let name = stringValue(tool["name"]) ?? "Tool"
                let requiredFlag = (tool["required"] as? Bool) == true
                let status = stringValue(tool["status"]) ?? "review"
                items.append([
                    "title": name,
                    "size": status == "ok" ? "Ready" : "Check",
                    "status": status == "ok" ? "Ready" : "Needs Attention",
                    "summary": requiredFlag ? "Required system capability." : "Optional capability for deeper reviews."
                ])
            }
        }

        if let platform = object["platform"] as? [String: Any] {
            let macOS = stringValue(platform["macos"]) ?? "macOS"
            let architecture = stringValue(platform["architecture"]) ?? "Mac"
            items.append([
                "title": "Mac Compatibility",
                "size": "Ready",
                "status": "Ready",
                "summary": "Running on macOS \(macOS) for \(architecture)."
            ])
        }

        return items.isEmpty ? nil : items
    }

    private func appFacingItems(_ items: [[String: Any]]) -> [[String: Any]] {
        items.map { item in
            var cleaned = item
            for key in cleaned.keys where key.lowercased().contains("command") {
                cleaned.removeValue(forKey: key)
            }
            return cleaned
        }
    }

    private func summaryLine(for item: [String: Any]) -> String {
        let size = stringValue(item["size"]) ?? stringValue(item["value"]) ?? stringValue(item["potential_reclaim"]) ?? "Review"
        let title = friendlyTitle(from: item)
        if let location = friendlyLocationHint(from: item) {
            return "\(size)  \(title)  \(location)"
        }
        return "\(size)  \(title)"
    }

    private func reviewItem(from item: [String: Any]) -> ReviewItem {
        let size = stringValue(item["size"]) ?? stringValue(item["value"]) ?? stringValue(item["potential_reclaim"]) ?? stringValue(item["total"]) ?? "Review"
        let title = friendlyTitle(from: item)
        let badge = friendlyBadge(from: item)
        let path = displayPath(from: item)
        let detail = friendlyDetail(from: item) ??
            friendlyLocationHint(from: item) ??
            "Review before cleaning."
        return ReviewItem(title: title, detail: detail, size: size, badge: badge, path: path)
    }

    private func friendlyTitle(from item: [String: Any]) -> String {
        let raw = stringValue(item["title"]) ??
            stringValue(item["name"]) ??
            stringValue(item["kind"]) ??
            stringValue(item["runtime"]) ??
            stringValue(item["id"]) ??
            stringValue(item["type"]) ??
            "Review item"
        return friendlyLabel(raw)
    }

    private func friendlyDetail(from item: [String: Any]) -> String? {
        let candidates = [
            stringValue(item["summary"]),
            stringValue(item["guidance"]),
            stringValue(item["description"]),
            stringValue(item["detail"]),
            stringValue(item["reason"]),
            stringValue(item["recoverability"]),
            stringValue(item["modified"]),
            stringValue(item["last_modified"])
        ]
        for candidate in candidates {
            guard let candidate,
                  let cleaned = friendlySentence(candidate) else { continue }
            return cleaned
        }
        return nil
    }

    private func friendlyBadge(from item: [String: Any]) -> String {
        let raw = stringValue(item["safety"]) ??
            stringValue(item["category"]) ??
            stringValue(item["kind"]) ??
            stringValue(item["type"]) ??
            stringValue(item["status"]) ??
            "Review"
        return friendlyLabel(raw)
    }

    private func displayPath(from item: [String: Any]) -> String? {
        if let path = stringValue(item["path"]) { return path }
        if let paths = item["paths"] as? [String], let first = paths.first { return first }
        if let paths = stringValue(item["paths"]) {
            return paths
                .components(separatedBy: CharacterSet(charactersIn: ";\n"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { !$0.isEmpty }
        }
        return nil
    }

    private func friendlySentence(_ raw: String) -> String? {
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
            lower.contains("apply command") {
            return nil
        }
        return friendlyLabelIfBackendToken(text)
    }

    private func friendlyLabelIfBackendToken(_ text: String) -> String {
        if text.range(of: "^[a-z0-9_.-]+$", options: .regularExpression) != nil {
            return friendlyLabel(text)
        }
        return text
            .replacingOccurrences(of: "dry-run", with: "review", options: .caseInsensitive)
            .replacingOccurrences(of: "opt-in", with: "optional", options: .caseInsensitive)
    }

    private func friendlyLabel(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Review item" }
        if trimmed.contains("/") {
            let last = URL(fileURLWithPath: trimmed).lastPathComponent
            if !last.isEmpty { return friendlyLabel(last) }
        }
        let expanded = trimmed
            .replacingOccurrences(of: "cleanroom ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: ".", with: " ")
        let known: [String: String] = [
            "ai": "AI",
            "api": "API",
            "cc": "CC",
            "cli": "Tools",
            "db": "DB",
            "ios": "iOS",
            "json": "JSON",
            "lm": "LM",
            "ndk": "NDK",
            "npm": "NPM",
            "pnpm": "PNPM",
            "sdk": "SDK",
            "sql": "SQL",
            "ui": "UI",
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

    private func friendlyLocationHint(from item: [String: Any]) -> String? {
        guard let path = displayPath(from: item) else { return nil }
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

    private func stringValue(_ value: Any?) -> String? {
        switch value {
        case let text as String where !text.isEmpty:
            return text
        case let number as NSNumber:
            return number.stringValue
        default:
            return nil
        }
    }

    private func reviewRows(in details: String) -> [String] {
        details
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { line in
                guard !line.isEmpty else { return false }
                guard line.range(of: "^[0-9]+(\\.[0-9]+)?\\s?(B|KB|MB|GB|TB)\\b", options: [.regularExpression, .caseInsensitive]) != nil else {
                    return false
                }
                return !line.localizedCaseInsensitiveContains("total:")
            }
    }

    private func leadingSize(in line: String) -> String? {
        guard let range = line.range(of: "^[0-9]+(\\.[0-9]+)?\\s?(B|KB|MB|GB|TB)\\b", options: [.regularExpression, .caseInsensitive]) else {
            return nil
        }
        return String(line[range])
    }

    func filteredCategories() -> [CleanCategory] {
        switch filter {
        case "caches":    return categories.filter { $0.title == "Caches" }
        case "dev":       return categories.filter { ["JavaScript Packages", "Developer Files"].contains($0.title) }
        case "downloads": return categories.filter { ["Downloads", "Archives"].contains($0.title) }
        case "files":     return categories.filter { $0.title == "Large Files" }
        case "archives":  return categories.filter { $0.title == "Archives" }
        default:          return categories
        }
    }

    private static func exec(_ executable: String, _ arguments: [String], onStart: ((Process) -> Void)? = nil) async -> CommandResult {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: executable)
        p.arguments = arguments
        let pipe = Pipe()
        p.standardOutput = pipe; p.standardError = pipe
        do {
            try p.run()
            onStart?(p)
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            p.waitUntilExit()
            let text = String(data: data, encoding: .utf8) ?? ""
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let isStructured = trimmed.hasPrefix("{") || trimmed.hasPrefix("[")
            let visibleText = isStructured && p.terminationStatus == 0 ? text : sanitizeForApp(text)
            if p.terminationStatus == 0 {
                return CommandResult(output: visibleText.isEmpty ? "Completed.\n" : visibleText, status: p.terminationStatus)
            }
            if p.terminationStatus == 15 {
                return CommandResult(output: visibleText, status: p.terminationStatus)
            }
            let fallback = visibleText.isEmpty ? "" : visibleText + "\n"
            return CommandResult(output: fallback + "This review could not finish. Please try again or run Health Check.\n", status: p.terminationStatus)
        } catch {
            return CommandResult(output: "Cleanroom could not start this review. \(error.localizedDescription)\n", status: -1)
        }
    }

    nonisolated private static func parseCleanupPlan(_ raw: String) -> (items: [CleanupPlanItem], notes: [String]) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ([], ["The safety plan could not be loaded. You can still review before cleaning."])
        }
        let categories = object["categories"] as? [[String: Any]] ?? []
        let items = categories.map { item -> CleanupPlanItem in
            let title = stringField("title", in: item) ?? stringField("id", in: item) ?? "Cleanup area"
            let safety = friendlySafety(stringField("safety", in: item))
            let recovery = friendlyRecovery(stringField("recoverability", in: item))
            return CleanupPlanItem(title: title, safety: safety, recovery: recovery)
        }
        let rawWarnings = object["warnings"] as? [String] ?? []
        let notes = rawWarnings.map(friendlyCleanupNote)
        return (items, notes)
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
        case "high-impact":
            return "High impact"
        case "irreversible":
            return "Irreversible"
        default:
            return "Protected"
        }
    }

    nonisolated private static func friendlyRecovery(_ raw: String?) -> String {
        guard let raw else { return "Moved to Trash where possible." }
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
        if raw.contains("--") || raw.localizedCaseInsensitiveContains("dry-run") {
            return "Review first; cleaning only happens after confirmation."
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

    private static func sanitizeForApp(_ text: String) -> String {
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
            "Use the deeper",
            "Use Apps when",
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
                    lowerTrimmed.contains("next steps") {
                    return nil
                }
                if hiddenFragments.contains(where: { line.localizedCaseInsensitiveContains($0) }) {
                    return nil
                }
                if lowerTrimmed.contains(" --apply") ||
                    lowerTrimmed.contains(" --json") ||
                    lowerTrimmed.contains(" --trash") ||
                    lowerTrimmed.contains(" --preflight") ||
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
                            NavRow("heart.text.square.fill",  "Health Check", .run(.healthCheck), state)
                            NavRow("chart.bar.fill",          "Storage Overview", .run(.storageOverview), state)
                            NavRow("magnifyingglass",         "Refresh Summary", .dashboard, state, onTap: { state.refreshStats(force: true) })
                            NavRow("text.badge.checkmark",    "Review",      .dashboard, state, onTap: { state.filter = "all"; state.refreshStats(force: true) })
                            NavRow("list.clipboard.fill",     "Clean Plan",  .dashboard, state, onTap: { state.showApplyConfirm = true })
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
                            NavRow("arrow.down.to.line",      "Downloads",   .run(.downloads), state)
                            NavRow("archivebox.fill",         "Archives",    .run(.archives), state)
                            NavRow("camera.viewfinder",       "Screenshots", .run(.screenshots), state)
                            NavRow("xmark.bin.fill",          "Caches",      .run(.caches), state)
                            NavRow("eye.fill",                "Preview Cache", .run(.previewCache), state)
                            NavRow("textformat",              "Font Cache", .run(.fontCache), state)
                            NavRow("safari.fill",             "Web Cache",  .run(.webCache), state)
                            NavRow("rectangle.stack.fill",    "Window State", .run(.windowState), state)
                            NavRow("chevron.left.forwardslash.chevron.right", "Project Cache", .run(.projectCache), state)
                            NavRow("arrow.clockwise.circle.fill", "Update Cache", .run(.updateCache), state)
                            NavRow("globe", "Browser Cache", .run(.browserCache), state)
                            NavRow("sparkles", "AI Tools", .run(.aiTools), state)
                            NavRow("shippingbox.fill",        "JavaScript Packages",.run(.javascriptPackages), state)
                            NavRow("square.stack.3d.up.fill", "Python Environments", .run(.pythonEnvironments), state)
                            NavRow("apps.iphone",             "Apps",        .run(.apps), state)
                            NavRow("app.badge.checkmark.fill","App Review",  .dashboard, state, onTap: { state.showLeftovers = true })
                            NavRow("trash.fill",              "Trash",       .run(.trash), state)
                            NavRow("icloud.fill",             "Cloud Files", .run(.cloudFiles), state)
                        }
                        SidebarSection("SYSTEM") {
                            NavRow("hammer.fill",             "Xcode",       .run(.xcode), state)
                            NavRow("clock.arrow.circlepath",  "Backups",     .run(.backups), state)
                            NavRow("externaldrive.fill",      "System Data", .run(.systemData), state)
                            NavRow("shippingbox.fill",        "Containers",  .run(.containers), state)
                            NavRow("wrench.and.screwdriver",  "Developer Tools", .run(.developerTools), state)
                            NavRow("person.crop.circle",      "Login Items", .run(.loginItems), state)
                            NavRow("bolt.fill",               "Startup",     .run(.startup), state)
                        }
                        SidebarSection("SAFETY") {
                            NavRow("camera.fill",             "Storage Record", .run(.storageRecord), state)
                            NavRow("clock.badge.checkmark.fill", "Restore History", .run(.restoreHistory), state)
                            NavRow("checkmark.shield.fill",   "Safety Check",     .run(.safetyCheck), state)
                            NavRow("doc.text.fill",           "Privacy Report",   .run(.privacyReport), state)
                            NavRow("clock.fill",              "Past Cleanups",    .run(.pastCleanups), state)
                            NavRow("shield.fill",             "Protected Items", .run(.protectedItems), state)
                            NavRow("flag.fill",               "Safety Policy", .run(.safetyPolicy), state)
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

    var body: some View {
        Button {
            if let tap = onTap { tap(); return }
            withAnimation(DS.Ani.snap) { state.dest = nav }
            if case .run(let action) = nav { state.run(action) }
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
                    NavArrow(icon: "arrow.left") { state.run(.pastCleanups) }
                    NavArrow(icon: "arrow.right") { state.showApplyConfirm = true }
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
                PillBtn("Refresh", style: .ghost) { state.refreshStats(force: true) }
                PillBtn("Update Summary", style: .ghost) { state.refreshStats(force: true) }
                Spacer()
                PillBtn("Clean Safely", style: .primary) {
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
            Button { state.refreshStats(force: true) } label: {
                HStack(spacing: 4) {
                    Text("Refresh Summary").font(DS.T.body)
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
                    state.dest = .run(category.action)
                    state.run(category.action)
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
// MARK: – Activity Summary Panel
// ═══════════════════════════════════════════════════════════════

struct OutputPanel: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: DS.Sp.sm) {
                Circle()
                    .fill(state.running ? DS.C.ctaOrange : DS.C.positive)
                    .frame(width: 7, height: 7)
                    .animation(DS.Ani.std, value: state.running)
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
                } else {
                    IconBtn(icon: "doc.on.clipboard", dark: true) {
                        state.copyDetails()
                    }
                    IconBtn(icon: "trash", dark: true) {
                        state.output = "No activity yet.\n"
                        state.reviewItems = []
                    }
                }
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
                        VStack(alignment: .leading, spacing: DS.Sp.md) {
                            if state.reviewItems.isEmpty {
                                Text(state.output)
                                    .font(DS.T.bodySm)
                                    .lineSpacing(3)
                                    .foregroundColor(DS.C.textOnDark.opacity(0.88))
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                        .id("bottom")
                    }
                    .frame(height: DS.Layout.outputH)
                    .background(DS.C.sidebarBg.opacity(0.98))
                    .onReceive(state.$output) { _ in
                        withAnimation(DS.Ani.snap) { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }
            }
        }
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
                Text("Enter an app or vendor name to preview matching files before cleaning anything.")
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
                    Text("Eligible files move to Trash and can be restored from a cleanup record.")
                        .font(DS.T.bodySm)
                        .foregroundColor(DS.C.textSecondary)
                }
            }

            Rectangle().fill(DS.C.divider).frame(height: 1)

            VStack(alignment: .leading, spacing: DS.Sp.sm) {
                HStack {
                    Text("READY TO CLEAN")
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
                PillBtn("Review First", style: .ghost) {
                    state.run(.safetyPlan)
                    dismiss()
                }
                PillBtn("Clean Now", style: .primary) {
                    state.run(.safeCleanup)
                    dismiss()
                }
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
                "A restore record is written for the cleanup session.",
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
        case "Optional":
            return DS.C.caution
        default:
            return DS.C.positive
        }
    }

    private var icon: String {
        switch item.safety {
        case "High impact", "Irreversible":
            return "exclamationmark.triangle.fill"
        case "Optional":
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
