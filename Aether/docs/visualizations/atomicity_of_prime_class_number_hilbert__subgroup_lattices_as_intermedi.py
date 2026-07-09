"""
Visualization: subgroup / intermediate-field lattices of Hilbert class fields.
Draws the subgroup lattice of Cl(O_K) for several class-group shapes; by the
Galois correspondence this is (as an order dual) the intermediate-field lattice
of H/K. Prime class number yields the two-node atomic lattice.
Requires matplotlib and networkx.
"""
from __future__ import annotations
from itertools import product
from typing import List, Tuple
import matplotlib.pyplot as plt
import networkx as nx

Group = Tuple[int, ...]


def elems(factors: Group):
    return [tuple(e) for e in product(*[range(f) for f in factors])]


def closure(gens, factors: Group) -> frozenset:
    idv = tuple(0 for _ in factors)
    S = {idv}
    frontier = [idv]
    while frontier:
        nxt = []
        for x in frontier:
            for g in gens:
                y = tuple((a + b) % f for a, b, f in zip(x, g, factors))
                if y not in S:
                    S.add(y); nxt.append(y)
        frontier = nxt
    return frozenset(S)


def subgroups(factors: Group) -> List[frozenset]:
    subs = [closure([], factors)]; seen = set(subs); changed = True
    while changed:
        changed = False
        for H in list(subs):
            for g in elems(factors):
                new = closure(list(H) + [g], factors)
                if new not in seen:
                    seen.add(new); subs.append(new); changed = True
    return subs


def draw(factors: Group, ax) -> None:
    subs = subgroups(factors)
    G = nx.DiGraph()
    for i, S in enumerate(subs):
        G.add_node(i, size=len(S))
    for i, A in enumerate(subs):
        for j, B in enumerate(subs):
            if i != j and A < B and not any(
                A < C < B for C in subs):
                G.add_edge(i, j)
    order = " x ".join(f"Z/{f}" for f in factors)
    pos = {i: (0, len(S)) for i, S in enumerate(subs)}
    # spread nodes of equal size horizontally
    from collections import defaultdict
    by_size = defaultdict(list)
    for i, S in enumerate(subs):
        by_size[len(S)].append(i)
    for size, ids in by_size.items():
        for k, i in enumerate(ids):
            pos[i] = (k - (len(ids) - 1) / 2, size)
    nx.draw(G, pos, ax=ax, with_labels=False, node_size=400,
            node_color="#4C72B0", arrows=False)
    ax.set_title(f"Cl(O_K) = {order}\n#nodes = {len(subs)}")


def main() -> None:
    shapes = [(2,), (4,), (9,), (2, 2), (6,), (3, 3)]
    fig, axes = plt.subplots(2, 3, figsize=(13, 8))
    for ax, factors in zip(axes.ravel(), shapes):
        draw(factors, ax)
    fig.suptitle("Subgroup lattices = intermediate-field lattices of H/K "
                 "(atomic iff prime order)")
    fig.tight_layout()
    fig.savefig("class_field_lattices.png", dpi=150)
    print("wrote class_field_lattices.png")


if __name__ == "__main__":
    main()
