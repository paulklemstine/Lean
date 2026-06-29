"""Bar chart of the weight enumerator 1 + 14*x^4 + x^8 of the extended Hamming code."""
from itertools import product
from typing import Dict, List, Tuple
import matplotlib.pyplot as plt

BinVec = Tuple[int, ...]
GEN: List[BinVec] = [
    (1, 1, 1, 1, 1, 1, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (0, 0, 1, 1, 0, 0, 1, 1),
    (0, 1, 0, 1, 0, 1, 0, 1),
]


def wt(v: BinVec) -> int:
    return sum(v)


def encode(a: Tuple[int, ...]) -> BinVec:
    out: BinVec = (0,) * 8
    for c, row in zip(a, GEN):
        if c == 1:
            out = tuple((p + q) % 2 for p, q in zip(out, row))
    return out


def main() -> None:
    code = [encode(a) for a in product((0, 1), repeat=4)]
    hist: Dict[int, int] = {w: 0 for w in range(9)}
    for v in code:
        hist[wt(v)] += 1
    weights = list(range(9))
    counts = [hist[w] for w in weights]
    plt.figure(figsize=(8, 5))
    bars = plt.bar(weights, counts, color="#2b6cb0", edgecolor="black")
    for b, c in zip(bars, counts):
        if c:
            plt.text(b.get_x() + b.get_width() / 2, c + 0.2, str(c), ha="center")
    plt.title("Weight enumerator of the extended Hamming code [8,4,4]\n"
              "W(x) = 1 + 14 x^4 + x^8")
    plt.xlabel("Hamming weight")
    plt.ylabel("number of codewords")
    plt.xticks(weights)
    plt.tight_layout()
    plt.savefig("hamming_weight_enumerator.png", dpi=150)
    print("saved hamming_weight_enumerator.png")


if __name__ == "__main__":
    main()
