import AppKit
import SwiftUI

struct RulerRootView: View {
  @ObservedObject var state: RulerState
  @Environment(\.displayScale) private var displayScale

  var body: some View {
    ZStack {
      RulerBackgroundView(state: state)
      RulerCanvasView(state: state)
      CursorLineView(state: state)
      RulerReadoutView(state: state)
    }
    .onExitCommand { NSApp.terminate(nil) }
    .contextMenu {
      Button("Switch to Horizontal") {
        withAnimation {
          state.measurementMode = .horizontal
        }
      }
      .disabled(state.measurementMode == .horizontal)
      
      Button("Switch to Vertical") {
        withAnimation {
          state.measurementMode = .vertical
        }
      }
      .disabled(state.measurementMode == .vertical)
      
      Divider()
      
      Button("Quit Ruler") { NSApp.terminate(nil) }
    }
  }
}

private struct RulerBackgroundView: View {
  @ObservedObject var state: RulerState
  
  var body: some View {
    let top = Color(red: 0.95, green: 0.85, blue: 0.55)
    let mid = Color(red: 0.92, green: 0.78, blue: 0.44)
    let bottom = Color(red: 0.86, green: 0.70, blue: 0.33)

    let isVertical = state.measurementMode == .vertical
    let startPoint: UnitPoint = isVertical ? .leading : .top
    let endPoint: UnitPoint = isVertical ? .trailing : .bottom

    LinearGradient(colors: [top, mid, bottom], startPoint: startPoint, endPoint: endPoint)
      .overlay(
        LinearGradient(
          colors: [
            Color.white.opacity(0.30),
            Color.white.opacity(0.06),
            Color.black.opacity(0.08)
          ],
          startPoint: startPoint,
          endPoint: endPoint
        )
      )
  }
}

private struct CursorLineView: View {
  @ObservedObject var state: RulerState
  @Environment(\.displayScale) private var displayScale

  var body: some View {
    GeometryReader { proxy in
      let scale = max(displayScale, 1)
      let onePx = 1 / scale
      let isVertical = state.measurementMode == .vertical

      let value = clamp(state.measurementValuePoints, min: 0, max: isVertical ? proxy.size.height : proxy.size.width)
      let aligned = (value * scale).rounded() / scale

      Rectangle()
        .fill(Color.accentColor.opacity(0.85))
        .frame(width: isVertical ? nil : onePx, height: isVertical ? onePx : nil)
        .offset(x: isVertical ? 0 : aligned, y: isVertical ? aligned : 0)
    }
    .allowsHitTesting(false)
  }
}

private struct RulerReadoutView: View {
  @ObservedObject var state: RulerState
  @Environment(\.displayScale) private var displayScale

  var body: some View {
    let scale = max(displayScale, 1)
    let onePx = 1 / scale

    Text("\(state.measurementValuePixels) px")
      .font(.system(size: 13, weight: .semibold, design: .monospaced))
      .foregroundStyle(Color.black.opacity(0.82))
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(Color.white.opacity(0.40))
          .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
              .strokeBorder(Color.black.opacity(0.18), lineWidth: onePx)
          )
      )
      .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
      .padding(10)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
      .allowsHitTesting(false)
  }
}

private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
  if value < min { return min }
  if value > max { return max }
  return value
}
