import SwiftUI

struct RulerCanvasView: View {
  @ObservedObject var state: RulerState
  @Environment(\.displayScale) private var displayScale

  var body: some View {
    Canvas { context, size in
      let scale = max(displayScale, 1)
      let onePx = 1 / scale
      let isVertical = state.measurementMode == .vertical

      let length = isVertical ? size.height : size.width

      let lengthPx = Int((length * scale).rounded(.down))

      let borderTop = Color.black.opacity(0.45)
      let borderSide = Color.black.opacity(0.25)
      
      // Draw Borders
      context.fill(Path(CGRect(x: 0, y: 0, width: size.width, height: onePx)), with: .color(isVertical ? borderSide : borderTop))
      context.fill(Path(CGRect(x: 0, y: size.height - onePx, width: size.width, height: onePx)), with: .color(borderSide))
      context.fill(Path(CGRect(x: 0, y: 0, width: onePx, height: size.height)), with: .color(isVertical ? borderTop : borderSide))
      context.fill(Path(CGRect(x: size.width - onePx, y: 0, width: onePx, height: size.height)), with: .color(borderSide))

      let minorEvery = 10
      let midEvery = 50
      let majorEvery = 100

      let minorHeightPx: CGFloat = 12
      let midHeightPx: CGFloat = 18
      let majorHeightPx: CGFloat = 26

      for px in stride(from: 0, through: lengthPx, by: minorEvery) {
        let isMajor = px % majorEvery == 0
        let isMid = (!isMajor) && px % midEvery == 0

        let tickHeightPx: CGFloat = isMajor ? majorHeightPx : (isMid ? midHeightPx : minorHeightPx)
        let opacity: CGFloat = isMajor ? 0.72 : (isMid ? 0.60 : 0.45)

        let position = CGFloat(px) / scale
        let tickRect: CGRect
        
        if isVertical {
            // Horizontal ticks along Y axis
            // Ticks start from left (x=onePx)
            tickRect = CGRect(x: onePx, y: position, width: tickHeightPx / scale, height: onePx)
        } else {
            // Vertical ticks along X axis
            // Ticks start from top (y=onePx)
            tickRect = CGRect(x: position, y: onePx, width: onePx, height: tickHeightPx / scale)
        }
        
        context.fill(Path(tickRect), with: .color(Color.black.opacity(opacity)))

        if isMajor, px != 0 {
          let resolved = context.resolve(
            Text("\(px)")
              .font(.system(size: 12, weight: .medium, design: .default))
              .foregroundColor(Color.black.opacity(0.80))
          )

          if isVertical {
             let labelX = (tickHeightPx + 6) / scale
             // Center vertically on the tick
             context.draw(resolved, at: CGPoint(x: labelX, y: position), anchor: .leading)
          } else {
             let labelY = (tickHeightPx + 6) / scale
             context.draw(resolved, at: CGPoint(x: position, y: labelY), anchor: .top)
          }
        }
      }
    }
    .allowsHitTesting(false)
  }
}
