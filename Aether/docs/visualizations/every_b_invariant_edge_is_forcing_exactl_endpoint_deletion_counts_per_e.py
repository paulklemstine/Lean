"""Visualization: for each edge of a graph, show how many perfect matchings
survive after deleting its two endpoints. Forcing edges are exactly those whose
deletion count equals 1. Requires matplotlib."""
from __future__ import annotations
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


g = graph(range(6), list(combinations(range(6), 2)))  # K6
labels, counts = [], []
for e in sorted(g[1], key=lambda s: sorted(s)):
    u, v = tuple(e)
    sub = ({w for w in g[0] if w not in (u, v)},
           {ee for ee in g[1] if u not in ee and v not in ee})
    labels.append(f"{u}-{v}")
    counts.append(len(pms(sub)))

plt.figure(figsize=(10, 5))
colors = ["#d1495b" if c == 1 else "#3b6ea5" for c in counts]
plt.bar(labels, counts, color=colors)
plt.axhline(1, color="black", ls="--", lw=1)
plt.ylabel("# perfect matchings after deleting endpoints")
plt.title("Deletion counts in K6 (red = forcing, count 1)")
plt.xticks(rotation=90)
plt.tight_layout()
plt.savefig("deletion_counts.png", dpi=150)
print("wrote deletion_counts.png")
