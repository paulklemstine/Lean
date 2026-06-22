"""Heatmap of the 16x16 binary Gram matrix ip(x,y) of the Hamming code (all zeros:
the code is self-orthogonal)."""
from itertools import product
from typing import List, Tuple
import matplotlib.pyplot as plt

BinVec = Tuple[int, ...]
GEN: List[BinVec] = [
    (1, 1, 1, 1, 1, 1, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (0, 0, 1, 1, 0, 0, 1, 1),
    (0, 1, 0, 1, 0, 1, 0, 1),
]


def encode(a: Tuple[int, ...]) -> BinVec:
    out: BinVec = (0,) * 8
    for c, row in zip(a, GEN):
        if c == 1:
            out = tuple((p + q) % 2 for p, q in zip(out, row))
    return out


def ip(x: BinVec, y: BinVec) -> int:
    return sum(p * q for p, q in zip(x, y)) % 2


def main() -> None:
    code: List[BinVec] = [encode(a) for a in product((0, 1), repeat=4)]
    G = [[ip(x, y) for y in code] for x in code]
    plt.figure(figsize=(6, 6))
    plt.imshow(G, cmap="Greys", vmin=0, vmax=1)
    plt.title("Binary Gram matrix ip(x,y) of the Hamming code\n"
              "(all entries 0: self-orthogonal)")
    plt.xlabel("codeword index")
    plt.ylabel("codeword index")
    plt.colorbar(label="ip(x,y) in GF(2)")
    plt.tight_layout()
    plt.savefig("hamming_gram.png", dpi=150)
    print("saved hamming_gram.png; max entry =", max(max(r) for r in G))


if __name__ == "__main__":
    main()
