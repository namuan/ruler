import CoreGraphics
import SwiftUI

@MainActor
final class RulerState: ObservableObject {
  @Published var windowFrameInScreenPoints: CGRect = .zero
  @Published var windowScale: CGFloat = 1
  @Published var mouseLocationInScreenPoints: CGPoint = .zero

  var deltaXPoints: CGFloat {
    mouseLocationInScreenPoints.x - windowFrameInScreenPoints.minX
  }

  var deltaXPixels: Int {
    Int((deltaXPoints * windowScale).rounded())
  }
}
