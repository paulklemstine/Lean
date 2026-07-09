"""Visualization: growth of facets and ridges along the suspension tower.

Shows on a log scale that facets double (2^k * 10) and ridges grow with each
suspension while the handshake ratio (d+1) f_d / f_{d-1} stays exactly 2.
"""
import matplotlib.pyplot as plt
from itertools import combinations

RP2 = [frozenset(t) for t in [
    (0,1,2),(0,2,3),(0,3,4),(0,4,5),(0,1,5),
    (1,2,4),(1,3,4),(1,3,5),(2,3,5),(2,4,5)]]

def suspend(F, a, b):
    return [s | {a} for s in F] + [s | {b} for s in F]

def ridges(F, d):
    R = set()
    for s in F:
        for r in combinations(sorted(s), d): R.add(frozenset(r))
    return R

ks, facets, ridge_counts = [], [], []
F, nxt = list(RP2), 6
for k in range(7):
    d = 2 + k
    ks.append(k); facets.append(len(F)); ridge_counts.append(len(ridges(F, d)))
    F = suspend(F, nxt, nxt + 1); nxt += 2

fig, ax = plt.subplots(figsize=(8, 5))
ax.semilogy(ks, facets, "o-", color="crimson", label="facets $f_d = 2^k\\cdot 10$")
ax.semilogy(ks, ridge_counts, "s-", color="navy", label="ridges $f_{d-1}$")
ax.set_xlabel("suspension height $k$ (dimension $d = k+2$)")
ax.set_ylabel("count (log scale)")
ax.set_title("Facet and ridge growth in the $\\mathbb{RP}^2$ suspension tower\n"
             "(handshake ratio $(d+1)f_d / f_{d-1} = 2$ throughout)")
ax.legend(); ax.grid(alpha=0.3, which="both")
plt.tight_layout()
plt.savefig("tower_growth.png", dpi=150)
print("saved tower_growth.png")
