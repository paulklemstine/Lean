"""Visualization: draw a graph and colour its forcing edges. Requires matplotlib.
Uses a simple circular layout so no networkx dependency is needed."""
from __future__ import annotations
import math
from itertools import combinations
from typing import FrozenSet, List, Set, Tuple
import matplotlib.pyplot as plt

Edge = FrozenSet[int]
Graph = Tuple[Set[int], Set[Edge]]


def graph(vs, es):
    return (set(vs), {frozenset(e) for e in es if e[0] != e[1]})


def pms(g):
    V, E = g

    def bt(rem):
        if not rem:
            yield frozenset(); return
        a, rest = rem[0], rem[1:]
        for b in rest:
            if frozenset((a, b)) in E:
                for m in bt(tuple(x for x in rest if x != b)):
                    yield m | {frozenset((a, b))}
    return list(bt(tuple(sorted(V))))


def forcing(g, u, v):
    V, E = g
    sub = ({w for w in V if w not in (u, v)}, {e for e in E if u not in e and v not in e})
    return frozenset((u, v)) in E and len(pms(sub)) == 1


g = graph(range(6), [(i, (i + 1) % 6) for i in range(6)])  # C6: all edges forcing
n = len(g[0])
pos = {v: (math.cos(2 * math.pi * v / n), math.sin(2 * math.pi * v / n))
       for v in sorted(g[0])}

plt.figure(figsize=(6, 6))
for e in g[1]:
    u, v = tuple(e)
    color = "#d1495b" if forcing(g, u, v) else "#bbbbbb"
    lw = 3 if forcing(g, u, v) else 1
    plt.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]], color=color, lw=lw, zorder=1)
for v, (x, y) in pos.items():
    plt.scatter([x], [y], s=400, color="#2e4057", zorder=2)
    plt.text(x, y, str(v), color="white", ha="center", va="center", zorder=3)
plt.title("Forcing edges (red) of C6")
plt.axis("equal"); plt.axis("off")
plt.tight_layout()
plt.savefig("forcing_highlight.png", dpi=150)
print("wrote forcing_highlight.png")
