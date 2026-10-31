import Foundation

let ALPHABET = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

func charToIndex(_ ch: Character) -> Int {
    Int(ch.unicodeScalars.first!.value - Character("A").unicodeScalars.first!.value)
}

func indexToChar(_ i: Int) -> Character {
    let v = (i % 26 + 26) % 26
    return Character(UnicodeScalar(v + Int(Character("A").unicodeScalars.first!.value))!)
}

struct Plugboard {
    var mapping: [Character: Character] = [:]

    init(pairs: [String]? = nil) {
        for ch in ALPHABET {
            mapping[ch] = ch
        }

        let pairs = pairs ?? []
        var used = Set<Character>()

        for rawPair in pairs {
            let pair = rawPair.uppercased()
            let chars = Array(pair)
            if chars.count != 2 {
                continue
            }

            let a = chars[0]
            let b = chars[1]

            if a == b || used.contains(a) || used.contains(b) {
                continue
            }

            used.insert(a)
            used.insert(b)
            mapping[a] = b
            mapping[b] = a
        }
    }

    func swap(_ ch: Character) -> Character {
        mapping[ch] ?? ch
    }
}

struct Rotor {
    let wiring: [Character]
    let inverseWiring: [Character]
    let notch: Character
    var position: Int

    init(wiring: String, notch: Character = "Z", position: Character = "A") {
        self.wiring = Array(wiring)
        self.inverseWiring = Rotor.buildInverseWiring(wiring)
        self.notch = notch
        self.position = charToIndex(position)
    }

    static func buildInverseWiring(_ wiring: String) -> [Character] {
        var inverse = Array(repeating: Character("A"), count: 26)
        for (i, ch) in wiring.enumerated() {
            inverse[charToIndex(ch)] = indexToChar(i)
        }
        return inverse
    }

    mutating func step() {
        position = (position + 1) % 26
    }

    func atNotch() -> Bool {
        indexToChar(position) == notch
    }

    func forward(_ ch: Character) -> Character {
        let i = charToIndex(ch)
        let shiftedIn = (i + position) % 26
        let mapped = wiring[shiftedIn]
        let shiftedOut = (charToIndex(mapped) - position + 26) % 26
        return indexToChar(shiftedOut)
    }

    func backward(_ ch: Character) -> Character {
        let i = charToIndex(ch)
        let shiftedIn = (i + position) % 26
        let mapped = inverseWiring[shiftedIn]
        let shiftedOut = (charToIndex(mapped) - position + 26) % 26
        return indexToChar(shiftedOut)
    }
}

struct Reflector {
    let wiring: [Character]

    init(wiring: String) {
        self.wiring = Array(wiring)
    }

    func reflect(_ ch: Character) -> Character {
        wiring[charToIndex(ch)]
    }
}

struct EnhancedSimpleEnigma {
    var rotorLeft: Rotor
    var rotorMiddle: Rotor
    var rotorRight: Rotor
    let reflector: Reflector
    let plugboard: Plugboard

    init(rotorLeft: Rotor, rotorMiddle: Rotor, rotorRight: Rotor, reflector: Reflector, plugboard: Plugboard? = nil) {
        self.rotorLeft = rotorLeft
        self.rotorMiddle = rotorMiddle
        self.rotorRight = rotorRight
        self.reflector = reflector
        self.plugboard = plugboard ?? Plugboard(pairs: [])
    }

    mutating func stepRotors() {
        // 为了保证和用户提供的 Python 版本加密结果一致，这里保留同样的步进行为。
        // Python 文件里比较的是 Int(position) 和 Character(notch)，条件恒为 false，
        // 所以实际效果是：只有右转子每次都会转，中间和左转子不会因为 notch 触发转动。
        rotorRight.step()
    }

    mutating func processChar(_ ch: Character) -> Character {
        let up = Character(String(ch).uppercased())
        if !ALPHABET.contains(up) {
            return ch
        }

        stepRotors()

        var out = plugboard.swap(up)
        out = rotorRight.forward(out)
        out = rotorMiddle.forward(out)
        out = rotorLeft.forward(out)
        out = reflector.reflect(out)
        out = rotorLeft.backward(out)
        out = rotorMiddle.backward(out)
        out = rotorRight.backward(out)
        out = plugboard.swap(out)
        return out
    }

    mutating func processText(_ text: String) -> String {
        String(text.map { processChar($0) })
    }
}

func buildMachine(leftPos: Character = "A", middlePos: Character = "A", rightPos: Character = "A", plugPairs: [String]? = nil) -> EnhancedSimpleEnigma {
    let rotorI = Rotor(wiring: "EKMFLGDQVZNTOWYHXUSPAIBRCJ", notch: "Q", position: leftPos)
    let rotorII = Rotor(wiring: "AJDKSIRUXBLHWTMCQGZNPYFVOE", notch: "E", position: middlePos)
    let rotorIII = Rotor(wiring: "BDFHJLCPRTXVZNYEIWGAKMUSQO", notch: "V", position: rightPos)
    let reflectorB = Reflector(wiring: "YRUHQSLDPXNGOKMIEBFZCWVJAT")
    let plugboard = Plugboard(pairs: plugPairs ?? [])

    return EnhancedSimpleEnigma(
        rotorLeft: rotorI,
        rotorMiddle: rotorII,
        rotorRight: rotorIII,
        reflector: reflectorB,
        plugboard: plugboard
    )
}
