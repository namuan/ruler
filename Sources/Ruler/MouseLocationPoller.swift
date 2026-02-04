import AppKit
import CoreGraphics

final class MouseLocationPoller: @unchecked Sendable {
  private let handler: (CGPoint) -> Void
  private var timer: Timer?
  private var lastLocation: CGPoint?

  init(handler: @escaping (CGPoint) -> Void) {
    self.handler = handler
  }

  func start() {
    stop()

    let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
      guard let self else { return }
      let loc = NSEvent.mouseLocation
      if self.lastLocation != loc {
        self.lastLocation = loc
        self.handler(loc)
      }
    }
    RunLoop.main.add(timer, forMode: .common)
    self.timer = timer
  }

  func stop() {
    timer?.invalidate()
    timer = nil
    lastLocation = nil
  }
}
