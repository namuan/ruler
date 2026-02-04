import SwiftUI

@main
struct RulerApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    Settings {
      EmptyView()
        .frame(width: 0, height: 0)
    }
  }
}
