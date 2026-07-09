"""Visualization: exact count N(n) against the star/fan floors on a log scale."""
from __future__ import annotations
from itertools import combinations
from typing import List, Tuple
import matplotlib.pyplot as plt

Chord = Tuple[int, int]


def num_plane(n: int) -> int:
    cs: List[Chord] = [(i, j) for i in range(n) for j in range(i + 1, n)]

    def cross(x: Chord, y: Chord) -> bool:
        a, b = x; c, d = y
        return (a < c < b < d) or (c < a < d < b)

    def plane(g: Tuple[Chord, ...]) -> bool:
        return all(not cross(g[i], g[j])
                   for i in range(len(g)) for j in range(i + 1, len(g)))
    return sum(1 for k in range(len(cs) + 1)
               for s in combinations(cs, k) if plane(s))


ns = list(range(2, 6))
exact = [num_plane(n) for n in ns]
star = [2 ** (n - 1) for n in ns]
fan = [2 ** (2 * n - 3) for n in ns]

plt.figure(figsize=(7, 5))
plt.semilogy(ns, exact, "o-", label="exact N(n)")
plt.semilogy(ns, fan, "s--", label="fan floor $2^{2n-3}$")
plt.semilogy(ns, star, "^--", label="star floor $2^{n-1}$")
plt.xlabel("n (points in convex position)")
plt.ylabel("number of plane graphs (log scale)")
plt.title("Plane graphs on convex points vs. lower bounds")
plt.legend()
plt.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("plane_graph_bounds.png", dpi=150)
print("saved plane_graph_bounds.png")
