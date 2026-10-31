import string

ALPHABET = string.ascii_uppercase


def char_to_index(ch):
    return ord(ch) - ord('A')


def index_to_char(i):
    return chr(i % 26 + ord('A'))


def normalize_position(text, default='A'):
    text = text.strip().upper()
    if len(text) == 1 and text in ALPHABET:
        return text
    return default


def parse_plug_pairs(text):
    """
    支持输入：
    AQ EP TY UI
    或：
    AQ,EP,TY,UI
    """
    if not text.strip():
        return []

    parts = (
        text.upper()
        .replace(",", " ")
        .replace("\n", " ")
        .replace("\t", " ")
        .split()
    )

    return parts


class Plugboard:
    def __init__(self, pairs=None):
        """
        pairs: 例如 ['AB', 'CD', 'EF']
        表示 A<->B, C<->D, E<->F
        """
        self.mapping = {ch: ch for ch in ALPHABET}

        if pairs is None:
            pairs = []

        used = set()

        for pair in pairs:
            pair = pair.upper().strip()

            if len(pair) != 2:
                raise ValueError(f"非法插线板对: {pair}")

            a, b = pair[0], pair[1]

            if a not in ALPHABET or b not in ALPHABET:
                raise ValueError(f"插线板只能使用 A-Z 字母: {pair}")

            if a == b:
                raise ValueError(f"插线板不能连接相同字母: {pair}")

            if a in used or b in used:
                raise ValueError(f"字母不能重复出现在多个插线板对中: {pair}")

            used.add(a)
            used.add(b)

            self.mapping[a] = b
            self.mapping[b] = a

    def swap(self, ch):
        return self.mapping.get(ch, ch)


class Rotor:
    def __init__(self, name, wiring, notch='Z', position='A'):
        self.name = name
        self.wiring = wiring
        self.inverse_wiring = self._build_inverse_wiring(wiring)
        self.notch = notch
        self.position = char_to_index(position)

    def _build_inverse_wiring(self, wiring):
        inverse = [''] * 26

        for i, ch in enumerate(wiring):
            inverse[char_to_index(ch)] = index_to_char(i)

        return ''.join(inverse)

    def step(self):
        self.position = (self.position + 1) % 26

    def at_notch(self):
        return index_to_char(self.position) == self.notch

    def forward(self, ch):
        i = char_to_index(ch)

        shifted_in = (i + self.position) % 26
        mapped = self.wiring[shifted_in]
        shifted_out = (char_to_index(mapped) - self.position) % 26

        return index_to_char(shifted_out)

    def backward(self, ch):
        i = char_to_index(ch)

        shifted_in = (i + self.position) % 26
        mapped = self.inverse_wiring[shifted_in]
        shifted_out = (char_to_index(mapped) - self.position) % 26

        return index_to_char(shifted_out)


class Reflector:
    def __init__(self, wiring):
        self.wiring = wiring

    def reflect(self, ch):
        return self.wiring[char_to_index(ch)]


class EnhancedSimpleEnigma:
    def __init__(self, rotor_left, rotor_middle, rotor_right, reflector, plugboard=None):
        self.rotor_left = rotor_left
        self.rotor_middle = rotor_middle
        self.rotor_right = rotor_right
        self.reflector = reflector
        self.plugboard = plugboard if plugboard else Plugboard([])

    def step_rotors(self):
        """
        双步进逻辑 Double Stepping
        """

        # 如果中转子在 notch，左转子和中转子都转
        if self.rotor_middle.at_notch():
            self.rotor_left.step()
            self.rotor_middle.step()

        # 如果右转子在 notch，中转子转
        if self.rotor_right.at_notch():
            self.rotor_middle.step()

        # 右转子每次都转
        self.rotor_right.step()

    def process_char(self, ch):
        ch = ch.upper()

        if ch not in ALPHABET:
            return ch

        self.step_rotors()

        # 插线板：进入前
        ch = self.plugboard.swap(ch)

        # 正向过转子：右 -> 中 -> 左
        ch = self.rotor_right.forward(ch)
        ch = self.rotor_middle.forward(ch)
        ch = self.rotor_left.forward(ch)

        # 反射器
        ch = self.reflector.reflect(ch)

        # 反向过转子：左 -> 中 -> 右
        ch = self.rotor_left.backward(ch)
        ch = self.rotor_middle.backward(ch)
        ch = self.rotor_right.backward(ch)

        # 插线板：出来后
        ch = self.plugboard.swap(ch)

        return ch

    def process_text(self, text):
        return ''.join(self.process_char(ch) for ch in text)


ROTOR_SPECS = {
    "I": {
        "wiring": "EKMFLGDQVZNTOWYHXUSPAIBRCJ",
        "notch": "Q"
    },
    "II": {
        "wiring": "AJDKSIRUXBLHWTMCQGZNPYFVOE",
        "notch": "E"
    },
    "III": {
        "wiring": "BDFHJLCPRTXVZNYEIWGAKMUSQO",
        "notch": "V"
    },
    "IV": {
        "wiring": "ESOVPZJAYQUIRHXLNFTGKDCMWB",
        "notch": "J"
    },
    "V": {
        "wiring": "VZBRGITYUPSDNHLXAWMJQOFECK",
        "notch": "Z"
    },
}


REFLECTOR_B = "YRUHQSLDPXNGOKMIEBFZCWVJAT"


def create_rotor(rotor_name, position):
    rotor_name = rotor_name.upper().strip()

    if rotor_name not in ROTOR_SPECS:
        raise ValueError(f"没有这个转子型号: {rotor_name}")

    spec = ROTOR_SPECS[rotor_name]

    return Rotor(
        name=rotor_name,
        wiring=spec["wiring"],
        notch=spec["notch"],
        position=position
    )


def build_machine(
    left_rotor="I",
    middle_rotor="II",
    right_rotor="III",
    left_pos='A',
    middle_pos='A',
    right_pos='A',
    plug_pairs=None
):
    rotor_left = create_rotor(left_rotor, left_pos)
    rotor_middle = create_rotor(middle_rotor, middle_pos)
    rotor_right = create_rotor(right_rotor, right_pos)

    reflector = Reflector(REFLECTOR_B)
    plugboard = Plugboard(plug_pairs or [])

    return EnhancedSimpleEnigma(
        rotor_left=rotor_left,
        rotor_middle=rotor_middle,
        rotor_right=rotor_right,
        reflector=reflector,
        plugboard=plugboard
    )


def ask_setting(prompt, default):
    text = input(f"{prompt}（默认 {default}）: ").strip()
    return text if text else default


def run_once():
    print("=" * 40)
    plaintext = input("请输入文本（输入 ## 退出）: ")

    if plaintext.strip() == "##":
        return False

    print("\n可用转子型号：I II III IV V")
    rotor_input = ask_setting("请输入左 中 右转子型号，默认 I II III", "I II III")
    rotor_parts = rotor_input.upper().split()

    if len(rotor_parts) != 3:
        print("转子型号格式错误，请输入例如：I II III")
        return True

    left_rotor, middle_rotor, right_rotor = rotor_parts

    pos_input = ask_setting("请输入左 中 右初始位置，例如 M C X", "M C X")
    pos_parts = pos_input.upper().split()

    if len(pos_parts) != 3:
        print("转子位置格式错误，请输入例如：M C X")
        return True

    left_pos = normalize_position(pos_parts[0], "M")
    middle_pos = normalize_position(pos_parts[1], "C")
    right_pos = normalize_position(pos_parts[2], "X")

    plug_text = ask_setting("请输入插线板，例如 AQ EP TY UI", "AQ EP TY UI")
    plug_pairs = parse_plug_pairs(plug_text)

    try:
        machine = build_machine(
            left_rotor=left_rotor,
            middle_rotor=middle_rotor,
            right_rotor=right_rotor,
            left_pos=left_pos,
            middle_pos=middle_pos,
            right_pos=right_pos,
            plug_pairs=plug_pairs
        )

        result = machine.process_text(plaintext)

        print("\n设置：")
        print(f"转子顺序：{left_rotor} {middle_rotor} {right_rotor}")
        print(f"初始位置：{left_pos} {middle_pos} {right_pos}")
        print(f"插线板：{' '.join(plug_pairs) if plug_pairs else '无'}")

        print("\n输入:", plaintext)
        print("输出:", result)
        print("\n提示：使用完全相同设置再次处理输出文本，即可还原原文。")

    except ValueError as e:
        print("错误:", e)

    return True


if __name__ == "__main__":
    while run_once():
        pass
