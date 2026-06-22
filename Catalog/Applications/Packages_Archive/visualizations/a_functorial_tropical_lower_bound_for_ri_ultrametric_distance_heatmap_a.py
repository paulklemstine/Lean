"""Visualization: connectivity threshold matrix and the antitone component curve
for the 2-adic integers (ultrametric) vs the integer line (Archimedean).
Run with matplotlib installed."""
from itertools import combinations
from typing import Callable, Dict, Hashable, List
import matplotlib.pyplot as plt


def two_adic_distance(a: int, b: int) -> float:
    if a == b:
        return 0.0
    d = abs(a - b)
    v = 0
    while d % 2 == 0:
        d //= 2
        v += 1
    return 2.0 ** (-v)


def euclidean_distance(a: int, b: int) -> float:
    return float(abs(a - b))


def component_count(points: List[int], dist: Callable[[int, int], float], eps: float) -> int:
    parent: Dict[int, int] = {p: p for p in points}

    def find(p: int) -> int:
        while parent[p] != p:
            parent[p] = parent[parent[p]]
            p = parent[p]
        return p

    for x, y in combinations(points, 2):
        if dist(x, y) <= eps:
            parent[find(x)] = find(y)
    return len({find(p) for p in points})


pts = list(range(16))

fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Left: 2-adic distance matrix (heatmap)
mat = [[two_adic_distance(i, j) for j in pts] for i in pts]
im = axes[0].imshow(mat, cmap="viridis")
axes[0].set_title("2-adic distance matrix (ultrametric)")
axes[0].set_xlabel("point index")
axes[0].set_ylabel("point index")
fig.colorbar(im, ax=axes[0], shrink=0.8)

# Right: component count vs eps (antitone)
scales = [s / 100 for s in range(0, 101)]
axes[1].step(scales, [component_count(pts, two_adic_distance, e) for e in scales],
             where="post", label="2-adic (ultrametric)")
es = list(range(0, 16))
axes[1].step(es, [component_count(pts, euclidean_distance, float(e)) for e in es],
             where="post", label="integer line (Archimedean)")
axes[1].set_title("Number of Rips components vs scale (antitone)")
axes[1].set_xlabel("scale eps")
axes[1].set_ylabel("# connected components")
axes[1].legend()

plt.tight_layout()
plt.savefig("rips_connectivity_viz.png", dpi=150)
print("saved rips_connectivity_viz.png")
