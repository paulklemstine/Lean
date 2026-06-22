"""Visualize tensor-power towers and their period spectra.

Plots, for several characters of Rep(Z/n), the iso-class trajectory X^k and a
bar chart of the least period (fundamental frequency). Saves periodicity.png.
"""
from __future__ import annotations
from typing import List
import matplotlib.pyplot as plt


def tower_mod(n: int, a: int, upto: int) -> List[int]:
    """Iso-class labels of X^0..X^upto for character a in Rep(Z/n): (a*k) mod n."""
    return [(a * k) % n for k in range(upto + 1)]


def least_period_mod(n: int, a: int) -> int:
    """Least period of character a in Rep(Z/n) = n / gcd(n, a) (a != 0)."""
    from math import gcd
    return 1 if a % n == 0 else n // gcd(n, a)


def main() -> None:
    n = 12
    chars = [1, 2, 3, 4]
    upto = 24

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    for a in chars:
        ax1.plot(range(upto + 1), tower_mod(n, a, upto),
                 marker="o", markersize=4, label=f"X = char {a}")
    ax1.set_title(f"Tensor-power trajectories in Rep(Z/{n})")
    ax1.set_xlabel("k  (power)")
    ax1.set_ylabel("iso class of X^k  (mod n)")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    periods = [least_period_mod(n, a) for a in chars]
    ax2.bar([f"char {a}" for a in chars], periods, color="#4C72B0")
    ax2.set_title("Least period (fundamental frequency)")
    ax2.set_ylabel("minPeriod")
    for i, p in enumerate(periods):
        ax2.text(i, p + 0.05, str(p), ha="center")
    ax2.grid(True, axis="y", alpha=0.3)

    fig.suptitle("Periodicity of tensor powers: when composition loops back",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("periodicity.png", dpi=130)
    print("saved periodicity.png")


if __name__ == "__main__":
    main()
