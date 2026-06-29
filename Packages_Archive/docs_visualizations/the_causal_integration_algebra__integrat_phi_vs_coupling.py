"""Visualize Phi (minimum cut) as cross-block coupling eps increases.
Requires matplotlib. Saves phi_vs_coupling.png."""
from __future__ import annotations
from itertools import product
from typing import List, Sequence
import matplotlib.pyplot as plt

def cross_info(weight: Sequence[Sequence[float]], S: frozenset) -> float:
    n = len(weight); comp = [j for j in range(n) if j not in S]
    return sum(weight[i][j] for i in S for j in comp)

def phi(weight: Sequence[Sequence[float]]) -> float:
    n = len(weight)
    subsets = (frozenset(i for i, b in enumerate(bits) if b)
               for bits in product([0, 1], repeat=n))
    return min(cross_info(weight, S) for S in subsets if 0 < len(S) < n)

def complete(n: int, w: float) -> List[List[float]]:
    return [[0.0 if i == j else w for j in range(n)] for i in range(n)]

def coupled(eps: float) -> List[List[float]]:
    C1, C2 = complete(2, 3.0), complete(2, 3.0)
    M = [[0.0] * 4 for _ in range(4)]
    for i in range(2):
        for j in range(2):
            M[i][j] = C1[i][j]; M[2 + i][2 + j] = C2[i][j]
    for i in range(2):
        for j in range(2):
            M[i][2 + j] = eps; M[2 + j][i] = eps
    return M

epss = [k / 50.0 for k in range(0, 101)]
phis = [phi(coupled(e)) for e in epss]
plt.figure(figsize=(7, 4))
plt.plot(epss, phis, lw=2)
plt.xlabel("cross-block coupling eps")
plt.ylabel("Phi (minimum cut)")
plt.title("Weakly coupled direct sum: Phi grows linearly from 0")
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("phi_vs_coupling.png", dpi=150)
print("saved phi_vs_coupling.png")
