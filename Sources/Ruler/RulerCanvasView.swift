import SwiftUI

struct RulerCanvasView: View {
  @Environment(\.displayScale) private var displayScale

  var body: some View {
    Canvas { context, size in
      let scale = max(displayScale, 1)
      let onePx = 1 / scale

      let widthPx = Int((size.width * scale).rounded(.down))

      let borderTop = Color.black.opacity(0.45)
      let borderSide = Color.black.opacity(0.25)
      context.fill(Path(CGRect(x: 0, y: 0, width: size.width, height: onePx)), with: .color(borderTop))
      context.fill(Path(CGRect(x: 0, y: size.height - onePx, width: size.width, height: onePx)), with: .color(borderSide))
      context.fill(Path(CGRect(x: 0, y: 0, width: onePx, height: size.height)), with: .color(borderSide))
      context.fill(Path(CGRect(x: size.width - onePx, y: 0, width: onePx, height: size.height)), with: .color(borderSide))

      let minorEvery = 10
      let midEvery = 50
      let majorEvery = 100

      let minorHeightPx: CGFloat = 12
      let midHeightPx: CGFloat = 18
      let majorHeightPx: CGFloat = 26

      for px in stride(from: 0, through: widthPx, by: minorEvery) {
        let isMajor = px % majorEvery == 0
        let isMid = (!isMajor) && px % midEvery == 0

        let tickHeightPx: CGFloat = isMajor ? majorHeightPx : (isMid ? midHeightPx : minorHeightPx)
        let opacity: CGFloat = isMajor ? 0.72 : (isMid ? 0.60 : 0.45)

        let x = CGFloat(px) / scale
        let tickRect = CGRect(x: x, y: onePx, width: onePx, height: tickHeightPx / scale)
        context.fill(Path(tickRect), with: .color(Color.black.opacity(opacity)))

        if isMajor, px != 0 {
          let resolved = context.resolve(
            Text("\(px)")
              .font(.system(size: 12, weight: .medium, design: .default))
              .foregroundColor(Color.black.opacity(0.80))
          )

          let labelY = (tickHeightPx + 6) / scale
          context.draw(resolved, at: CGPoint(x: x, y: labelY), anchor: .top)
        }
      }
    }
    .allowsHitTesting(false)
  }
}
