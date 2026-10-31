import SwiftUI

struct ContentView: View {
    @State private var inputText = "DUCK"
    @State private var outputText = ""

    @State private var leftPos = "M"
    @State private var middlePos = "C"
    @State private var rightPos = "X"
    @State private var plugPairsText = "AQ EP TY UI"

    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                
                // 转子位置
                Section("转子初始位置") {
                    HStack {
                        TextField("左", text: $leftPos)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                        
                        TextField("中", text: $middlePos)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                        
                        TextField("右", text: $rightPos)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                    }
                }

                // 插线板
                Section("插线板") {
                    TextField("例如 AQ EP TY UI", text: $plugPairsText)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                    
                    Text("默认值：AQ EP TY UI")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // 输入
                Section("输入文本") {
                    TextEditor(text: $inputText)
                        .frame(height: 160)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }

                // 按钮
                Section("操作") {
                    Button("加密 / 解密") {
                        encrypt()
                    }
                }

                // 错误提示
                if !errorMessage.isEmpty {
                    Section("提示") {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                // 输出
                Section("输出结果") {
                    TextEditor(text: .constant(outputText))
                        .frame(height: 160)
                }

                // 说明
                Section {
                    Text("Enigma 是自反加密：用相同设置再次加密即可解密")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Enigma")
            .onAppear {
                encrypt()
            }
        }
    }

    // MARK: - 工具函数

    private func normalizedPosition(_ text: String, fallback: Character) -> Character {
        guard let ch = text.uppercased().first,
              ("A"..."Z").contains(String(ch)) else {
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

    // MARK: - 核心逻辑

    private func encrypt() {
        errorMessage = ""

        let pairs = parsePlugPairs(plugPairsText)

        var machine = buildMachine(
            leftPos: normalizedPosition(leftPos, fallback: "M"),
            middlePos: normalizedPosition(middlePos, fallback: "C"),
            rightPos: normalizedPosition(rightPos, fallback: "X"),
            plugPairs: pairs
        )

        outputText = machine.processText(inputText)
    }
}

#Preview {
    ContentView()
}
