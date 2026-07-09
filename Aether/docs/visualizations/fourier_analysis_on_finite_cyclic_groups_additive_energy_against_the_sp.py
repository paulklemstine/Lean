"""Scatter additive energy against the lower bound |A|^4/N over many random sets.

For random subsets A of Z/NZ of varying density, plot the exact additive energy E[A]
against the certified lower bound |A|^4/N, confirming E[A] >= |A|^4/N and showing how
structured sets sit far above the bound. Requires matplotlib.
"""
from __future__ import annotations
import random
from typing import List, Set
import matplotlib.pyplot as plt

def additive_energy(N: int, A: Set[int]) -> int:
    return sum(1 for a in A for b in A for c in A for d in A if (a+b) % N == (c+d) % N)

def energy_scatter(N: int = 23, trials: int = 200) -> None:
    bounds: List[float] = []
    energies: List[int] = []
    for _ in range(trials):
        k = random.randint(2, N)
        A = set(random.sample(range(N), k))
        bounds.append(len(A)**4 / N)
        energies.append(additive_energy(N, A))
    lo, hi = min(bounds), max(energies)
    plt.figure(figsize=(6, 6))
    plt.scatter(bounds, energies, s=14, alpha=0.6, color="#3b6ea5", label="random sets")
    plt.plot([0, hi], [0, hi], "r--", label="E = |A|^4/N (lower bound)")
    plt.xlabel("|A|^4 / N  (lower bound)")
    plt.ylabel("E[A]  (exact additive energy)")
    plt.title(f"Additive energy vs. lower bound in Z/{N}Z")
    plt.legend(); plt.tight_layout()
    plt.savefig("energy_scatter.png", dpi=150)
    print("wrote energy_scatter.png")

if __name__ == "__main__":
    energy_scatter()
