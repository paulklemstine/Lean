import matplotlib.pyplot as plt
from collections import Counter
from typing import List


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b)
        n //= b
    return out


def is_fang_pair(b: int, x: int, y: int) -> bool:
    return Counter(digits(b, x * y)) == Counter(digits(b, x)) + Counter(digits(b, y))


def count_vampires_per_window(max_width: int) -> None:
    widths, counts = [], []
    for width in range(2, max_width + 1, 2):
        half = width // 2
        lo, hi = 10 ** (half - 1), 10 ** half
        c = 0
        for x in range(lo, hi):
            for y in range(x, hi):
                if not (x % 10 == 0 and y % 10 == 0) and is_fang_pair(10, x, y):
                    c += 1
        widths.append(width)
        counts.append(c)
    plt.figure(figsize=(7, 4))
    plt.bar([str(w) for w in widths], counts, color="#7b1fa2")
    plt.xlabel("number of digits (2n)")
    plt.ylabel("count of vampire numbers")
    plt.title("Vampire population by digit window")
    plt.tight_layout()
    plt.savefig("vampire_population.png", dpi=150)
    print("saved vampire_population.png")


if __name__ == "__main__":
    count_vampires_per_window(6)
