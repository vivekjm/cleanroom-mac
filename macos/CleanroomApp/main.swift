// main.swift — Cleanroom macOS
// AppKit entry point that hosts the SwiftUI RootView via NSHostingView.
// All UI logic lives in CleanroomViews.swift; design tokens in DesignSystem.swift.

import AppKit
import SwiftUI

final class CleanroomAppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func buildWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 780),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "cleanroom"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.minSize = NSSize(width: DS.Layout.minWidth, height: DS.Layout.minHeight)
        window.setFrameAutosaveName("Cleanroom.Main")
        window.contentView = NSHostingView(rootView: RootView())
        window.backgroundColor = NSColor(DS.C.sidebarBg)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}

let app = NSApplication.shared
let delegate = CleanroomAppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()
