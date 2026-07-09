"""Visualise the girth/minimum-distance relationship for bipartite graph codes.

Generates two panels:
 (1) the Fano incidence graph drawn bipartitely with a highlighted 6-cycle;
 (2) a bar chart comparing predicted lower bound (girth/2) with the true minimum
     distance for a family of example graphs.

Requires matplotlib. Saves 'girth_distance.png'.
"""
from __future__ import annotations
import math
from itertools import combinations
from collections import deque
from typing import Dict, Set, List, Tuple
import matplotlib.pyplot as plt


def girth(adj: Dict[Tuple[str, int], Set[Tuple[str, int]]]) -> float:
    best = math.inf
    for src in adj:
        dist = {src: 0}; parent = {src: src}; q = deque([src])
        while q:
            u = q.popleft()
            for w in adj[u]:
                if w not in dist:
                    dist[w] = dist[u] + 1; parent[w] = u; q.append(w)
                elif parent[u] != w:
                    best = min(best, dist[u] + dist[w] + 1)
    return best


def min_distance(inc: Dict[int, Set[int]]) -> int:
    rights = set().union(*inc.values())
    for size in range(1, len(inc) + 1):
        for S in combinations(sorted(inc), size):
            counts = {r: 0 for r in rights}
            for l in S:
                for r in inc[l]:
                    counts[r] += 1
            if all(c % 2 == 0 for c in counts.values()):
                return size
    return 0


def adjacency(inc: Dict[int, Set[int]]):
    adj: Dict[Tuple[str, int], Set[Tuple[str, int]]] = {}
    for l, nb in inc.items():
        adj.setdefault(("L", l), set())
        for r in nb:
            adj.setdefault(("R", r), set())
            adj[("L", l)].add(("R", r)); adj[("R", r)].add(("L", l))
    return adj


fano = {0: {0,1,2}, 1: {0,3,4}, 2: {0,5,6}, 3: {1,3,5},
        4: {1,4,6}, 5: {2,3,6}, 6: {2,4,5}}
examples = {
    "K(2,3)": {l: {0,1,2} for l in range(2)},
    "K(3,3)": {l: {0,1,2} for l in range(3)},
    "Fano":   fano,
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

# Panel 1: Fano bipartite drawing
lines = sorted(fano); pts = sorted(set().union(*fano.values()))
ly = {l: i for i, l in enumerate(lines)}; ry = {r: i for i, r in enumerate(pts)}
for l in lines:
    for r in fano[l]:
        ax1.plot([0, 1], [ly[l], ry[r]], color="0.8", lw=0.8, zorder=1)
ax1.scatter([0]*len(lines), [ly[l] for l in lines], s=200, c="#2c7fb8", zorder=2)
ax1.scatter([1]*len(pts), [ry[r] for r in pts], s=200, c="#de2d26", zorder=2)
for l in lines: ax1.text(-0.06, ly[l], f"L{l}", ha="right", va="center")
for r in pts:   ax1.text(1.06, ry[r], f"P{r}", ha="left", va="center")
ax1.set_title("Fano incidence graph (left-3-regular, girth 6)")
ax1.axis("off")

# Panel 2: bound vs actual
names = list(examples); g = [girth(adjacency(examples[n])) for n in names]
bound = [int(x)//2 for x in g]; actual = [min_distance(examples[n]) for n in names]
x = range(len(names)); w = 0.35
ax2.bar([i - w/2 for i in x], bound, w, label="girth/2 (theorem bound)", color="#2c7fb8")
ax2.bar([i + w/2 for i in x], actual, w, label="true d_min", color="#de2d26")
ax2.set_xticks(list(x)); ax2.set_xticklabels(names)
ax2.set_ylabel("distance"); ax2.legend()
ax2.set_title("Predicted lower bound vs. actual minimum distance")

fig.tight_layout()
fig.savefig("girth_distance.png", dpi=150)
print("wrote girth_distance.png")
