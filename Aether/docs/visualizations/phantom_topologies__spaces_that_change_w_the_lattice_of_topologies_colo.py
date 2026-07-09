"""Visualize the lattice of topologies on a 3-point set, colored by
splittability (rigid vs. splittable), arranged by number of open sets.

Requires: matplotlib, networkx.
"""
from __future__ import annotations
from itertools import combinations
import matplotlib.pyplot as plt
import networkx as nx


def powerset(xs):
    items = list(xs)
    return [frozenset(c) for r in range(len(items) + 1)
            for c in combinations(items, r)]


def is_topology(opens, U):
    if frozenset() not in opens or U not in opens:
        return False
    for a in opens:
        for b in opens:
            if (a & b) not in opens or (a | b) not in opens:
                return False
    return True


def all_topologies(U):
    middle = [s for s in powerset(U) if s not in (frozenset(), U)]
    out = []
    for r in range(len(middle) + 1):
        for c in combinations(middle, r):
            o = set(c) | {frozenset(), U}
            if is_topology(o, U):
                out.append(frozenset(o))
    return out


def splittable(tau, tops):
    finer = [t for t in tops if tau <= t and t != tau]
    for a, b in combinations(finer, 2):
        if frozenset(a & b) == tau:
            return True
    return False


def main():
    U = frozenset({0, 1, 2})
    tops = all_topologies(U)
    G = nx.DiGraph()
    for t in tops:
        G.add_node(t)
    for a in tops:
        for b in tops:
            if a != b and a <= b:  # a finer than b; keep only cover edges
                if not any(a <= c <= b and c not in (a, b) for c in tops):
                    G.add_edge(b, a)
    colors = ["#e74c3c" if not splittable(t, tops) else "#2ecc71"
              for t in G.nodes]
    pos = {t: (i, len(t)) for i, t in enumerate(sorted(G.nodes, key=len))}
    nx.draw(G, pos, node_color=colors, node_size=120, arrows=False)
    plt.title("Topologies on {0,1,2}: red=rigid, green=splittable (y=#opens)")
    plt.savefig("lattice.png", dpi=150, bbox_inches="tight")
    print("saved lattice.png")


if __name__ == "__main__":
    main()
