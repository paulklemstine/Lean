"""Bar chart: minimum degree (ceiling) vs. exact d_stR for sample graphs."""
from itertools import combinations, product
from typing import Dict, List, Set

import matplotlib.pyplot as plt

Graph = Dict[int, Set[int]]


def mk(vs, es) -> Graph:
    g = {v: set() for v in vs}
    for a, b in es:
        g[a].add(b); g[b].add(a)
    return g


def min_degree(g): return min(len(g[v]) for v in g)


def is_strdf(g, f):
    if any(f[v] not in (-1, 1, 2) for v in g): return False
    if any(sum(f[u] for u in g[v]) < 1 for v in g): return False
    return all(f[v] != -1 or any(f[u] == 2 for u in g[v]) for v in g)


def d_stR(g):
    V = sorted(g)
    F = [dict(zip(V, c)) for c in product((-1, 1, 2), repeat=len(V))
         if is_strdf(g, dict(zip(V, c)))]
    if not F: return 0
    best = 0
    for k in range(1, min(min_degree(g), len(F)) + 1):
        if any(all(sum(f[v] for f in s) <= 1 for v in g)
               for s in combinations(F, k)):
            best = k
        else:
            break
    return best


graphs = {
    "P_3": mk([0, 1, 2], [(0, 1), (1, 2)]),
    "K_1,3": mk([0, 1, 2, 3], [(0, 1), (0, 2), (0, 3)]),
    "C_5": mk([0, 1, 2, 3, 4], [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]),
    "K_4": mk([0, 1, 2, 3],
              [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]),
}

names = list(graphs)
deltas = [min_degree(graphs[n]) for n in names]
vals = [d_stR(graphs[n]) for n in names]

x = range(len(names))
plt.figure(figsize=(8, 5))
plt.bar([i - 0.2 for i in x], deltas, width=0.4, label="delta(G) (ceiling)")
plt.bar([i + 0.2 for i in x], vals, width=0.4, label="d_stR(G) (exact)")
plt.xticks(list(x), names)
plt.ylabel("value")
plt.title("Signed total Roman domatic number vs. minimum-degree ceiling")
plt.legend()
plt.tight_layout()
plt.savefig("domatic_ceiling.png", dpi=150)
print("wrote domatic_ceiling.png")
