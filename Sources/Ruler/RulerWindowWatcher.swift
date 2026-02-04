import AppKit

@MainActor
final class RulerWindowWatcher: NSObject, NSWindowDelegate {
  private weak var window: NSWindow?
  private let state: RulerState
  private var isSnapping = false

  init(window: NSWindow, state: RulerState) {
    self.window = window
    self.state = state
  }

  func syncFromWindow() {
    guard let window else { return }
    state.windowFrameInScreenPoints = window.frame
    state.windowScale = window.screen?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1
  }

  func windowDidMove(_ notification: Notification) {
    snapOriginToPixelGridIfNeeded()
    syncFromWindow()
  }

  func windowDidResize(_ notification: Notification) {
    syncFromWindow()
  }

  func windowDidChangeScreen(_ notification: Notification) {
    syncFromWindow()
  }

  private func snapOriginToPixelGridIfNeeded() {
    guard let window else { return }
    guard !isSnapping else { return }

    let scale = window.screen?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1
    var frame = window.frame

    let snappedX = (frame.origin.x * scale).rounded() / scale
    let snappedY = (frame.origin.y * scale).rounded() / scale

    let dx = abs(snappedX - frame.origin.x)
    let dy = abs(snappedY - frame.origin.y)
    guard dx > 0.0001 || dy > 0.0001 else { return }

    frame.origin.x = snappedX
    frame.origin.y = snappedY

    isSnapping = true
    window.setFrame(frame, display: false)
    isSnapping = false
  }
}
