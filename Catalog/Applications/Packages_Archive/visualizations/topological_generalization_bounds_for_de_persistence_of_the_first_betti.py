"""Visualization: birth/death of the first Betti number across VR scales,
for a point cloud sampled on a circle (known topology b1 = 1)."""
import math
from itertools import combinations
from typing import Dict, List, Tuple
import matplotlib.pyplot as plt

Point = Tuple[float, float]

def dist(x: Point, y: Point) -> float:
    return math.hypot(x[0] - y[0], x[1] - y[1])

def _gf2_rank(mat: List[List[int]]) -> int:
    if not mat or not mat[0]:
        return 0
    rows = [r[:] for r in mat]; rank = 0
    for col in range(len(rows[0])):
        piv = next((r for r in range(rank, len(rows)) if rows[r][col]), None)
        if piv is None: continue
        rows[rank], rows[piv] = rows[piv], rows[rank]
        for r in range(len(rows)):
            if r != rank and rows[r][col]:
                rows[r] = [a ^ b for a, b in zip(rows[r], rows[rank])]
        rank += 1
    return rank

def betti(points, r):
    n = len(points)
    edges = [e for e in combinations(range(n), 2) if dist(points[e[0]], points[e[1]]) <= r]
    tris = [t for t in combinations(range(n), 3)
            if all(dist(points[a], points[b]) <= r for a, b in combinations(t, 2))]
    d1 = [[0]*len(edges) for _ in range(n)]
    for j,(a,b) in enumerate(edges): d1[a][j]^=1; d1[b][j]^=1
    ei = {e:i for i,e in enumerate(edges)}
    d2 = [[0]*len(tris) for _ in range(len(edges))]
    for j,(a,b,c) in enumerate(tris):
        for e in ((a,b),(a,c),(b,c)): d2[ei[e]][j]^=1
    b0 = n - _gf2_rank(d1)
    b1 = (len(edges) - _gf2_rank(d1)) - _gf2_rank(d2)
    return b0, b1

pts = [(math.cos(2*math.pi*k/12), math.sin(2*math.pi*k/12)) for k in range(12)]
scales = [0.02*i for i in range(1, 110)]
b0s = [betti(pts, r)[0] for r in scales]
b1s = [betti(pts, r)[1] for r in scales]

plt.figure(figsize=(8, 5))
plt.step(scales, b0s, where="post", label="b0 (components)")
plt.step(scales, b1s, where="post", label="b1 (loops)")
plt.xlabel("Vietoris-Rips scale r")
plt.ylabel("Betti number")
plt.title("Persistent homology of a sampled circle: b1 born then filled in")
plt.legend(); plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig("betti_persistence.png", dpi=150)
print("saved betti_persistence.png")
