"""Visualize the finite omega-towers converging to epsilon_0.

Plots the syntactic size (notation-tree node count) of tower(n), illustrating
that every finite tower has a FINITE, hence countable, notation while the tower
climbs toward epsilon_0.  Requires matplotlib.
"""
from __future__ import annotations
from typing import List
import matplotlib.pyplot as plt


def tower_syntax_size(n: int) -> int:
    # tower(n) = w^w^...^w (n omegas); its CNF tree has 2n+1 nodes for n>=1.
    return 1 if n == 0 else 2 * n + 1


def main() -> None:
    ns: List[int] = list(range(0, 12))
    sizes: List[int] = [tower_syntax_size(n) for n in ns]
    plt.figure(figsize=(8, 5))
    plt.plot(ns, sizes, "o-", color="#2b6cb0")
    plt.title("Finite omega-towers: finite notation size, sup = epsilon_0")
    plt.xlabel("n  (tower height)")
    plt.ylabel("notation-tree node count of tower(n)")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("tower_growth.png", dpi=150)
    print("wrote tower_growth.png")


if __name__ == "__main__":
    main()
