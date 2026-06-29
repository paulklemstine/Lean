"""Standalone visualization: the coordinate-flip involution that powers
signSum_coord_eq_zero. Shows that flipping coordinate i pairs up all 2^n
sign patterns so the signs at coordinate i cancel.

Requires matplotlib. Run: python viz_cancellation.py
"""
from __future__ import annotations
import itertools
import matplotlib.pyplot as plt

def main() -> None:
    n, i = 3, 0
    patterns = list(itertools.product((1, -1), repeat=n))
    signs = [p[i] for p in patterns]
    colors = ["tab:blue" if s == 1 else "tab:red" for s in signs]
    plt.figure(figsize=(8, 4))
    plt.bar(range(len(patterns)), signs, color=colors)
    plt.axhline(0, color="black", linewidth=0.8)
    plt.xticks(range(len(patterns)),
               ["".join("+" if x == 1 else "-" for x in p) for p in patterns],
               rotation=45)
    plt.ylabel(f"sign at coordinate i={i}")
    plt.title(f"signSum_coord_eq_zero: sum = {sum(signs)} (n={n})")
    plt.tight_layout()
    plt.savefig("cancellation_visualization.png", dpi=150)
    print("Saved cancellation_visualization.png; column sum =", sum(signs))

if __name__ == "__main__":
    main()
