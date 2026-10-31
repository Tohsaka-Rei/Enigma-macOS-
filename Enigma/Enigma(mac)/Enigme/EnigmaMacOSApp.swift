import SwiftUI

@main
struct EnigmaMacOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)

        Settings {
            VStack(alignment: .leading, spacing: 12) {
                Text("Enigma for macOS")
                    .font(.title2)
                    .bold()
                Text("这个版本默认参数与 enigma 4.py 一致，目的是保持加密结果一致。")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(20)
            .frame(width: 420, height: 180)
        }
    }
}
