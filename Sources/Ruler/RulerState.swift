import CoreGraphics
import SwiftUI

@MainActor
final class RulerState: ObservableObject {
  enum MeasurementMode {
    case horizontal
    case vertical
  }

  @Published var windowFrameInScreenPoints: CGRect = .zero
  @Published var windowScale: CGFloat = 1
  @Published var mouseLocationInScreenPoints: CGPoint = .zero
  @Published var measurementMode: MeasurementMode = .horizontal

  var deltaXPoints: CGFloat {
    mouseLocationInScreenPoints.x - windowFrameInScreenPoints.minX
  }

  var deltaYPoints: CGFloat {
    windowFrameInScreenPoints.maxY - mouseLocationInScreenPoints.y
  }

  var measurementValuePoints: CGFloat {
    switch measurementMode {
    case .horizontal: return deltaXPoints
    case .vertical: return deltaYPoints
    }
  }

  var measurementValuePixels: Int {
    Int((measurementValuePoints * windowScale).rounded())
  }

  var rulerLengthPoints: CGFloat {
    switch measurementMode {
    case .horizontal: return windowFrameInScreenPoints.width
    case .vertical: return windowFrameInScreenPoints.height
    }
  }

  var rulerLengthPixels: Int {
    Int((rulerLengthPoints * windowScale).rounded())
  }
}
