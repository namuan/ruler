import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  private let state = RulerState()
  private var window: RulerWindow?
  private var windowWatcher: RulerWindowWatcher?
  private var mousePoller: MouseLocationPoller?

  func applicationDidFinishLaunching(_ notification: Notification) {
    let rootView = RulerRootView(state: state)
    let hostingView = NSHostingView(rootView: rootView)

    let defaultSize = NSSize(width: 700, height: 96)
    let rect = NSRect(origin: .zero, size: defaultSize)

    let window = RulerWindow(
      contentRect: rect,
      styleMask: [.borderless, .resizable],
      backing: .buffered,
      defer: false
    )

    window.isReleasedWhenClosed = false
    window.backgroundColor = .clear
    window.isOpaque = false
    window.hasShadow = true
    window.level = .floating
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    window.title = "Ruler"
    window.contentView = hostingView
    window.isMovableByWindowBackground = true
    window.minSize = NSSize(width: 320, height: 96)
    window.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: 96)

    if let screen = NSScreen.main {
      let visible = screen.visibleFrame
      let origin = CGPoint(
        x: visible.minX + (visible.width - defaultSize.width) / 2,
        y: visible.maxY - defaultSize.height - 32
      )
      window.setFrameOrigin(origin)
    } else {
      window.center()
    }

    let watcher = RulerWindowWatcher(window: window, state: state)
    window.delegate = watcher
    self.windowWatcher = watcher
    self.window = window
    watcher.syncFromWindow()

    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    let poller = MouseLocationPoller { [weak self] location in
      guard let self else { return }
      self.state.mouseLocationInScreenPoints = location
    }
    poller.start()
    self.mousePoller = poller
  }

  func applicationWillTerminate(_ notification: Notification) {
    mousePoller?.stop()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}
