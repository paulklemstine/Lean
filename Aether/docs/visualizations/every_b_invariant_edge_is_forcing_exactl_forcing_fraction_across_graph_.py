"""Visualization: bar chart of the forcing fraction (fraction of edges that are
forcing) across a family of named graphs. Requires matplotlib."""
from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, Iterator, List, Set, Tuple
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


names, fracs = [], []
family = {
    "P6": graph(range(6), [(i, i + 1) for i in range(5)]),
    "C6": graph(range(6), [(i, (i + 1) % 6) for i in range(6)]),
    "K4": graph(range(4), list(combinations(range(4), 2))),
    "K6": graph(range(6), list(combinations(range(6), 2))),
    "Petersen": graph(range(10),
                      [(i, (i + 1) % 5) for i in range(5)] +
                      [(i, i + 5) for i in range(5)] +
                      [(5 + i, 5 + (i + 2) % 5) for i in range(5)]),
}
for name, g in family.items():
    E = g[1]
    frac = sum(forcing(g, *tuple(e)) for e in E) / len(E)
    names.append(name); fracs.append(frac)

plt.figure(figsize=(8, 5))
plt.bar(names, fracs, color="#3b6ea5")
plt.ylabel("fraction of edges that are forcing")
plt.title("Forcing fraction across graph families")
plt.ylim(0, 1.05)
plt.tight_layout()
plt.savefig("forcing_fraction.png", dpi=150)
print("wrote forcing_fraction.png")
