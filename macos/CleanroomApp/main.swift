import AppKit

final class CleanroomAppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var outputView: NSTextView!
    private var statusLabel: NSTextField!
    private var cliPath: String = ""

    func applicationDidFinishLaunching(_ notification: Notification) {
        cliPath = resolveCLIPath()
        buildWindow()
        append("cleanroom GUI ready\nCLI: \(cliPath)\n\n")
        runCommand("doctor", title: "Doctor")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func resolveCLIPath() -> String {
        if let resourceURL = Bundle.main.resourceURL {
            let bundled = resourceURL.appendingPathComponent("bin/cleanroom").path
            if FileManager.default.isExecutableFile(atPath: bundled) {
                return bundled
            }
        }

        let candidates = [
            "/opt/homebrew/bin/cleanroom",
            "/usr/local/bin/cleanroom",
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".local/bin/cleanroom").path
        ]

        for candidate in candidates where FileManager.default.isExecutableFile(atPath: candidate) {
            return candidate
        }

        return "cleanroom"
    }

    private func buildWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 980, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "cleanroom"
        window.center()

        let root = NSStackView()
        root.orientation = .vertical
        root.spacing = 12
        root.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        root.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "cleanroom")
        title.font = NSFont.systemFont(ofSize: 28, weight: .semibold)

        let subtitle = NSTextField(labelWithString: "Safe-by-default macOS storage cleaner. GUI actions preview, report, or copy explicit terminal commands.")
        subtitle.font = NSFont.systemFont(ofSize: 13)
        subtitle.textColor = .secondaryLabelColor

        let commandRows = NSStackView()
        commandRows.orientation = .vertical
        commandRows.spacing = 8

        let inspectRow = NSStackView()
        inspectRow.orientation = .horizontal
        inspectRow.spacing = 8
        inspectRow.alignment = .centerY

        inspectRow.addArrangedSubview(button("Scan", action: #selector(scan)))
        inspectRow.addArrangedSubview(button("Plan", action: #selector(plan)))
        inspectRow.addArrangedSubview(button("Large Files", action: #selector(largeFiles)))
        inspectRow.addArrangedSubview(button("Duplicates", action: #selector(duplicates)))
        inspectRow.addArrangedSubview(button("Report to Desktop", action: #selector(report)))
        inspectRow.addArrangedSubview(button("History", action: #selector(history)))
        inspectRow.addArrangedSubview(button("Protected Data", action: #selector(protect)))
        inspectRow.addArrangedSubview(button("Guard Chrome", action: #selector(guardChrome)))
        inspectRow.addArrangedSubview(button("Rules", action: #selector(rules)))

        let actionRow = NSStackView()
        actionRow.orientation = .horizontal
        actionRow.spacing = 8
        actionRow.alignment = .centerY

        actionRow.addArrangedSubview(button("Dry Run Dev", action: #selector(dryRunDev)))
        actionRow.addArrangedSubview(button("Copy Safe Apply", action: #selector(copySafeApplyCommand)))
        actionRow.addArrangedSubview(button("Copy Trash Dev Apply", action: #selector(copyTrashDevCommand)))

        commandRows.addArrangedSubview(inspectRow)
        commandRows.addArrangedSubview(actionRow)

        statusLabel = NSTextField(labelWithString: "Ready")
        statusLabel.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        statusLabel.textColor = .secondaryLabelColor

        outputView = NSTextView()
        outputView.isEditable = false
        outputView.isRichText = false
        outputView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        outputView.textColor = .labelColor
        outputView.backgroundColor = .textBackgroundColor

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = outputView
        scrollView.borderType = .bezelBorder

        root.addArrangedSubview(title)
        root.addArrangedSubview(subtitle)
        root.addArrangedSubview(commandRows)
        root.addArrangedSubview(statusLabel)
        root.addArrangedSubview(scrollView)

        window.contentView = NSView()
        window.contentView?.addSubview(root)
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor),
            root.topAnchor.constraint(equalTo: window.contentView!.topAnchor),
            root.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 420)
        ])

        window.makeKeyAndOrderFront(nil)
    }

    private func button(_ title: String, action: Selector) -> NSButton {
        let control = NSButton(title: title, target: self, action: action)
        control.bezelStyle = .rounded
        control.controlSize = .large
        return control
    }

    @objc private func scan() {
        runCommand("scan", title: "Scan")
    }

    @objc private func plan() {
        runCommand("plan", title: "Plan")
    }

    @objc private func largeFiles() {
        runCommand("large --limit 30 --min-mb 500", title: "Large Files")
    }

    @objc private func duplicates() {
        runCommand("duplicates --limit 20 --min-mb 100", title: "Duplicates")
    }

    @objc private func report() {
        let reportPath = "~/Desktop/cleanroom-report.md"
        runCommand("report --output \(reportPath)", title: "Report") {
            self.openPath(reportPath)
        }
    }

    @objc private func dryRunDev() {
        runCommand("clean --preset dev", title: "Dry Run Dev")
    }

    @objc private func history() {
        runCommand("history", title: "History")
    }

    @objc private func protect() {
        runCommand("protect", title: "Protected Data")
    }

    @objc private func guardChrome() {
        runCommand("guard ~/Library/Application\\ Support/Google/Chrome ~/Library/Application\\ Support/Google/Chrome/Default/Login\\ Data", title: "Guard Chrome")
    }

    @objc private func rules() {
        runCommand("rules", title: "Rules")
    }

    @objc private func copySafeApplyCommand() {
        copyCommand("cleanroom clean --apply --trash")
    }

    @objc private func copyTrashDevCommand() {
        copyCommand("cleanroom clean --preset dev --apply --trash")
    }

    private func runCommand(_ arguments: String, title: String, completion: (() -> Void)? = nil) {
        statusLabel.stringValue = "Running \(title)..."
        append("\n$ cleanroom \(arguments)\n")

        let command = "\(shellQuote(cliPath)) \(arguments)"
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.shell(command)
            DispatchQueue.main.async {
                self.append(result)
                self.statusLabel.stringValue = "Finished \(title)"
                completion?()
            }
        }
    }

    private func shell(_ command: String) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-lc", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let text = String(data: data, encoding: .utf8) ?? ""
            return text + "\n(exit \(process.terminationStatus))\n"
        } catch {
            return "Failed to run command: \(error.localizedDescription)\n"
        }
    }

    private func append(_ text: String) {
        outputView.string += text
        outputView.scrollToEndOfDocument(nil)
    }

    private func copyCommand(_ command: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
        statusLabel.stringValue = "Copied: \(command)"
        append("\nCopied command:\n\(command)\n")
    }

    private func openPath(_ path: String) {
        let expanded = NSString(string: path).expandingTildeInPath
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: expanded)])
    }

    private func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}

let app = NSApplication.shared
let delegate = CleanroomAppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()
