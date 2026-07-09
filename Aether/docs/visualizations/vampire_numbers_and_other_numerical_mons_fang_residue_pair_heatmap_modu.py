import matplotlib.pyplot as plt
import numpy as np
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


def fang_residue_heatmap(width: int) -> None:
    """Heatmap of admissible fang residue pairs (x-1, y-1) mod 9 that actually
    occur among fang pairs, illustrating the unit law (x-1)(y-1)=1 (mod 9)."""
    half = width // 2
    lo, hi = 10 ** (half - 1), 10 ** half
    grid = np.zeros((9, 9), dtype=int)
    for x in range(lo, hi):
        for y in range(x, hi):
            if not (x % 10 == 0 and y % 10 == 0) and is_fang_pair(10, x, y):
                grid[(x - 1) % 9, (y - 1) % 9] += 1
                grid[(y - 1) % 9, (x - 1) % 9] += 1
    plt.figure(figsize=(6, 5))
    plt.imshow(grid, origin="lower", cmap="magma")
    plt.colorbar(label="fang pairs observed")
    plt.xlabel("(y-1) mod 9")
    plt.ylabel("(x-1) mod 9")
    plt.title("Fang residue pairs concentrate where (x-1)(y-1)=1 (mod 9)")
    plt.tight_layout()
    plt.savefig("fang_residue_heatmap.png", dpi=150)
    print("saved fang_residue_heatmap.png")


if __name__ == "__main__":
    fang_residue_heatmap(4)
