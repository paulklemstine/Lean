"""Visualization: abundancy index A(n)=sigma(n)/n for n up to 200.

Plots each A(n), highlights the perfect line A=2, marks perfect numbers (6, 28),
and colors deficient vs abundant points. Saves abundancy_scatter.png.
"""
from fractions import Fraction
from math import isqrt
from typing import List
import matplotlib.pyplot as plt

def sigma(n: int) -> int:
    s, l = [], []
    for i in range(1, isqrt(n) + 1):
        if n % i == 0:
            s.append(i)
            if i != n // i:
                l.append(n // i)
    return sum(s + l)

def abundancy(n: int) -> float:
    return sigma(n) / n

def main() -> None:
    N = 200
    xs: List[int] = list(range(1, N + 1))
    ys: List[float] = [abundancy(n) for n in xs]
    colors = ["#2ca02c" if y < 2 else ("#000000" if y == 2 else "#d62728") for y in ys]
    plt.figure(figsize=(11, 6))
    plt.scatter(xs, ys, c=colors, s=14)
    plt.axhline(2.0, color="black", ls="--", lw=1, label="perfect: A(n)=2")
    for p in (6, 28):
        plt.annotate(f"{p} (perfect)", (p, 2.0), textcoords="offset points",
                     xytext=(5, 8), fontsize=9)
    plt.xlabel("n")
    plt.ylabel("abundancy index A(n) = sigma(n)/n")
    plt.title("Abundancy index: deficient (green), perfect (black), abundant (red)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("abundancy_scatter.png", dpi=150)
    print("saved abundancy_scatter.png")

if __name__ == "__main__":
    main()
