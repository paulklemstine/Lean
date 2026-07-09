"""Visualization: surviving binomial coefficient C(n, minFac(n)) mod n.

Plots, for each composite n, the residue C(n, q) mod n where q = minFac(n).
The verified theorem `not_dvd_choose_of_prime_dvd` guarantees this residue is
never zero for composites, which is exactly why the AKS identity fails.
Requires matplotlib.
"""
from __future__ import annotations
from math import comb
from typing import List
import matplotlib.pyplot as plt


def min_fac(n: int) -> int:
    d = 2
    while d * d <= n:
        if n % d == 0:
            return d
        d += 1
    return n


def is_prime(n: int) -> bool:
    return n >= 2 and min_fac(n) == n


def main() -> None:
    ns: List[int] = list(range(2, 80))
    composites = [n for n in ns if not is_prime(n)]
    residues = [comb(n, min_fac(n)) % n for n in composites]

    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(composites, residues, color="#c0392b", alpha=0.85)
    ax.axhline(0, color="black", linewidth=0.8)
    ax.set_xlabel("composite n")
    ax.set_ylabel("C(n, minFac(n)) mod n  (the surviving witness)")
    ax.set_title("Every composite leaves a nonzero binomial witness (AKS reverse direction)")
    fig.tight_layout()
    fig.savefig("aks_witness.png", dpi=150)
    print("saved aks_witness.png")


if __name__ == "__main__":
    main()
