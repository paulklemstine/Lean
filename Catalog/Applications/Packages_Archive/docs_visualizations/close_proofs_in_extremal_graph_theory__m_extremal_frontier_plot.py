"""
Visualization: edge-density frontier for triangle-free graphs (Mantel) and
the Turan family. Produces 'extremal_frontier.png'.
Requires matplotlib.
"""
from __future__ import annotations
import matplotlib.pyplot as plt

def mantel_bound(n: int) -> float:
    return n * n / 4.0

def turan_edges(n: int, p: int) -> int:
    # edges of T(n,p): pairs in different residue classes mod p
    sizes = [n // p + (1 if r < n % p else 0) for r in range(p)]
    total = n * (n - 1) // 2
    within = sum(s * (s - 1) // 2 for s in sizes)
    return total - within

ns = list(range(2, 41))
plt.figure(figsize=(9, 6))
plt.plot(ns, [mantel_bound(n) for n in ns], "k--",
         label="Mantel ceiling n^2/4 (triangle-free)")
for p in (2, 3, 4, 5):
    plt.plot(ns, [turan_edges(n, p) for n in ns], marker="o", ms=3,
             label=f"Turan T(n,{p}) edges (K_{{{p+1}}}-free)")
plt.xlabel("number of vertices n")
plt.ylabel("maximum edges")
plt.title("Extremal edge frontiers: Mantel and Turan families")
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("extremal_frontier.png", dpi=150)
print("wrote extremal_frontier.png")
