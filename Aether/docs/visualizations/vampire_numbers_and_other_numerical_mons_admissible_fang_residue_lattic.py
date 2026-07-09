"""Scatter of admissible fang residues (x mod 9, y mod 9) with (x-1)(y-1)==1."""
from __future__ import annotations

import matplotlib.pyplot as plt


def main() -> None:
    xs, ys = [], []
    for a in range(9):
        for b in range(9):
            if ((a - 1) * (b - 1)) % 9 == 1 % 9:
                xs.append(a)
                ys.append(b)
    plt.scatter(xs, ys, s=200, color="purple")
    plt.xticks(range(9))
    plt.yticks(range(9))
    plt.xlabel("x mod 9")
    plt.ylabel("y mod 9")
    plt.title("Admissible fang residues: (x-1)(y-1) == 1 (mod 9)")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("fang_residues.png", dpi=150)


if __name__ == "__main__":
    main()
