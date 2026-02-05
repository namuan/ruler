import AppKit
import Combine

@MainActor
final class RulerWindowWatcher: NSObject, NSWindowDelegate {
  private weak var window: NSWindow?
  private let state: RulerState
  private var isSnapping = false
  private var cancellables = Set<AnyCancellable>()

  init(window: NSWindow, state: RulerState) {
    self.window = window
    self.state = state
    super.init()

    state.$measurementMode
      .dropFirst()
      .receive(on: RunLoop.main)
      .sink { [weak self] mode in
        self?.updateWindowForMode(mode)
      }
      .store(in: &cancellables)
  }

  private func updateWindowForMode(_ mode: RulerState.MeasurementMode) {
    guard let window else { return }

    let currentFrame = window.frame
    let center = CGPoint(x: currentFrame.midX, y: currentFrame.midY)
    
    // Swap dimensions
    let newSize = CGSize(width: currentFrame.height, height: currentFrame.width)
    let newOrigin = CGPoint(
        x: center.x - newSize.width / 2,
        y: center.y - newSize.height / 2
    )

    // Relax constraints to allow the transition
    window.minSize = .zero
    window.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

    // Apply new frame
    window.setFrame(NSRect(origin: newOrigin, size: newSize), display: true, animate: true)

    // Update constraints based on mode
    let shortSide: CGFloat = 96
    let longSideMin: CGFloat = 320
    
    switch mode {
    case .horizontal:
        window.minSize = NSSize(width: longSideMin, height: shortSide)
        window.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: shortSide)
    case .vertical:
        window.minSize = NSSize(width: shortSide, height: longSideMin)
        window.maxSize = NSSize(width: shortSide, height: CGFloat.greatestFiniteMagnitude)
    }
    
    // Force sync
    syncFromWindow()
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
