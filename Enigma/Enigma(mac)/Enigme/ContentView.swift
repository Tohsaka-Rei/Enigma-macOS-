import SwiftUI

struct ContentView: View {
    @State private var plaintext = "DUCK"
    @State private var ciphertext = ""
    @State private var decrypted = ""

    @State private var leftPos = "M"
    @State private var middlePos = "C"
    @State private var rightPos = "X"
    @State private var plugPairsText = "AQ EP TY UI"

    @State private var statusMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            header

            HStack(alignment: .top, spacing: 16) {
                configurationPanel
                    .frame(width: 280)

                VStack(spacing: 12) {
                    ioPanel(title: "明文", text: $plaintext, isEditable: true)
                    actionBar
                    ioPanel(title: "密文", text: $ciphertext, isEditable: false)
                   // ioPanel(title: "解密结果", text: $decrypted, isEditable: false)
                }
            }

            if !statusMessage.isEmpty {
                HStack {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .padding(20)
        .frame(minWidth: 900, minHeight: 620)
        .onAppear {
            encrypt()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Enigma for macOS")
                .font(.largeTitle)
                .bold()
            Text("默认参数与 enigma.py 一致，目标是得到相同的加密结果。")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var configurationPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("转子初始位置") {
                VStack(spacing: 10) {
                    rotorField(title: "左", text: $leftPos)
                    rotorField(title: "中", text: $middlePos)
                    rotorField(title: "右", text: $rightPos)
                }
                .padding(.top, 4)
            }

            GroupBox("插线板") {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("例如 AQ EP TY UI", text: $plugPairsText)
                        .textFieldStyle(.roundedBorder)
                    Text("默认值：AQ EP TY UI")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }

            GroupBox("说明") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• 只处理 A-Z，其它字符原样保留")
                    Text("• 重新解密时会用同一组初始设置重建机器")
                    Text("• 当前 Swift 核心保留了 Python 文件的实际步进行为")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }

            Spacer()
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button("加密") {
                encrypt()
            }
            .keyboardShortcut(.return)

           // Button("用同样设置解密") {
           //     decryptText()
            //}

            Button("复制密文") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(ciphertext, forType: .string)
                statusMessage = "密文已复制到剪贴板"
            }
            .disabled(ciphertext.isEmpty)

            Spacer()
        }
    }

    private func ioPanel(title: String, text: Binding<String>, isEditable: Bool) -> some View {
        GroupBox(title) {
            if isEditable {
                TextEditor(text: text)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 140)
                    .padding(4)
            } else {
                ScrollView {
                    Text(text.wrappedValue)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
                        .textSelection(.enabled)
                        .padding(8)
                }
                .frame(minHeight: 140)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    private func rotorField(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .frame(width: 28, alignment: .leading)
            TextField("A-Z", text: text)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func normalizedPosition(_ text: String, fallback: Character) -> Character {
        guard let ch = text.uppercased().first, ("A"..."Z").contains(String(ch)) else {
            return fallback
        }
        return ch
    }

    private func parsePlugPairs(_ text: String) -> [String] {
        text
            .uppercased()
            .split(whereSeparator: { $0 == " " || $0 == "," || $0 == "\n" || $0 == "\t" })
            .map(String.init)
    }

    private func encrypt() {
        statusMessage = ""
        let pairs = parsePlugPairs(plugPairsText)
        var machine = buildMachine(
            leftPos: normalizedPosition(leftPos, fallback: "M"),
            middlePos: normalizedPosition(middlePos, fallback: "C"),
            rightPos: normalizedPosition(rightPos, fallback: "X"),
            plugPairs: pairs
        )
        ciphertext = machine.processText(plaintext)
        decrypted = ""
    }

    private func decryptText() {
        statusMessage = ""
        let pairs = parsePlugPairs(plugPairsText)
        var machine = buildMachine(
            leftPos: normalizedPosition(leftPos, fallback: "M"),
            middlePos: normalizedPosition(middlePos, fallback: "C"),
            rightPos: normalizedPosition(rightPos, fallback: "X"),
            plugPairs: pairs
        )
        decrypted = machine.processText(ciphertext)
    }
}

#Preview {
    ContentView()
}
