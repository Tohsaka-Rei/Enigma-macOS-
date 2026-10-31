import random
import string

ALPHABET = string.ascii_uppercase

# 生成随机转子位置
def random_rotor_position():
    return random.choice(ALPHABET)

# 生成插线板（例如 4 对）
def random_plugboard(pairs_count=4):
    letters = list(ALPHABET)
    random.shuffle(letters)

    pairs = []
    for i in range(pairs_count):
        a = letters.pop()
        b = letters.pop()
        pairs.append(a + b)

    return " ".join(pairs)

# 生成密码本
def generate_keys(n=50):
    results = []

    for _ in range(n):
        left = random_rotor_position()
        middle = random_rotor_position()
        right = random_rotor_position()

        plugboard = random_plugboard(4)

        line = f"{left} {middle} {right} | {plugboard}"
        results.append(line)

    return results


if __name__ == "__main__":
    count = int(input("生成多少组密码本："))

    keys = generate_keys(count)

    print("\n生成结果：\n")
    for k in keys:
        print(k)

    # 保存到文件
    with open("keys.txt", "w") as f:
        for k in keys:
            f.write(k + "\n")

    print("\n已保存到 keys.txt")
