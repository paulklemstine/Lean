"""
demo.py — Integrated Information as a Maximum Co-Active Coalition.

Numerical demonstrations of the surrogate IIT model:

  * A probabilistic system is a distribution over Boolean configurations.
  * Two variables are *co-active* if jointly active with positive probability.
  * A *co-active coalition* is a pairwise co-active variable set.
  * Phi across a bipartition = largest co-active coalition straddling the cut.
  * Phi_max = max over all bipartitions.

The demos verify, on concrete examples, the three headline theorems:

  (T1) Collapse:    Phi_max(P) == Omega(P)   (the global co-active number)
                    [Lean: phiMax_eq_global]
  (T2) Ceiling:     Phi_max(P) <= n          [Lean: phiMax_le_card / phiMax_le_pow]
  (T3) Reduction:   Phi_max(S(G)) == omega(G)  (clique number)
                    [Lean: coactive_iff_adj, card_SSupport_le, reduction]

All functions are self-contained and type-hinted; run with `python demo.py`.
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import Dict, FrozenSet, Iterable, List, Tuple

# A configuration assigns each variable index a Boolean (True = active).
Config = Tuple[bool, ...]
# A probabilistic system: configuration -> probability (only positive support kept).
System = Dict[Config, float]


# --------------------------------------------------------------------------- #
# Core model
# --------------------------------------------------------------------------- #
def support(p: System) -> List[Config]:
    """Configurations of positive probability."""
    return [x for x, prob in p.items() if prob > 0.0]


def coactive(p: System, u: int, v: int) -> bool:
    """True iff some positive-probability configuration activates both u and v.

    Mirrors `IIT.Coactive`: exists x in support with x u = true and x v = true.
    """
    return any(x[u] and x[v] for x in support(p))


def is_coactive_set(p: System, k: FrozenSet[int]) -> bool:
    """True iff every distinct pair in k is co-active (a co-active coalition).

    Mirrors `IIT.IsCoactiveSet`.
    """
    members = sorted(k)
    return all(
        coactive(p, u, v)
        for i, u in enumerate(members)
        for v in members[i + 1 :]
    )


def straddles(a: FrozenSet[int], k: FrozenSet[int]) -> bool:
    """True iff k has a member in a and a member outside a.

    Mirrors `IIT.Straddles`.
    """
    return any(u in a for u in k) and any(v not in a for v in k)


def _subsets(items: Iterable[int]) -> Iterable[FrozenSet[int]]:
    pool = list(items)
    return (
        frozenset(c)
        for c in chain.from_iterable(
            combinations(pool, r) for r in range(len(pool) + 1)
        )
    )


def phi_bip(p: System, n: int, a: FrozenSet[int]) -> int:
    """Phi across the bipartition (a, complement): size of the largest co-active
    coalition straddling the cut (0 if none). Mirrors `IIT.PhiBip`."""
    best = 0
    for k in _subsets(range(n)):
        if straddles(a, k) and is_coactive_set(p, k):
            best = max(best, len(k))
    return best


def phi_max(p: System, n: int) -> int:
    """Maximum integrated information over all bipartitions. Mirrors `IIT.PhiMax`.

    Computed directly from its definition (search over all subsets a)."""
    return max((phi_bip(p, n, a) for a in _subsets(range(n))), default=0)


def global_coactive(p: System, n: int) -> int:
    """Omega(P): size of the largest co-active coalition with >= 2 members.

    Mirrors `IIT.GlobalCoactive`."""
    best = 0
    for k in _subsets(range(n)):
        if len(k) >= 2 and is_coactive_set(p, k):
            best = max(best, len(k))
    return best


# --------------------------------------------------------------------------- #
# The reduction S(G) from graphs to systems
# --------------------------------------------------------------------------- #
Graph = Tuple[int, List[Tuple[int, int]]]  # (n_vertices, edge_list)


def system_of_graph(g: Graph) -> System:
    """Construction S(G): uniform over {all-off} and one config per edge.

    Mirrors `IIT.S` from the reduction file. Support size <= n^2 + 1
    (Lean: `card_SSupport_le`)."""
    n, edges = g
    configs: List[Config] = [tuple(False for _ in range(n))]  # all-off
    for u, v in edges:
        cfg = [False] * n
        cfg[u] = True
        cfg[v] = True
        configs.append(tuple(cfg))
    # de-duplicate, then make uniform
    uniq = list(dict.fromkeys(configs))
    weight = 1.0 / len(uniq)
    return {cfg: weight for cfg in uniq}


def clique_number(g: Graph) -> int:
    """omega(G): largest clique of size >= 2 (matching Omega's >= 2 convention)."""
    n, edges = g
    adj = {frozenset((u, v)) for u, v in edges}

    def is_clique(s: FrozenSet[int]) -> bool:
        members = sorted(s)
        return all(
            frozenset((u, v)) in adj
            for i, u in enumerate(members)
            for v in members[i + 1 :]
        )

    best = 0
    for s in _subsets(range(n)):
        if len(s) >= 2 and is_clique(s):
            best = max(best, len(s))
    return best


# --------------------------------------------------------------------------- #
# Polynomial-time greedy approximation of Phi_max (degeneracy-style)
# --------------------------------------------------------------------------- #
def coactivation_graph(p: System, n: int) -> Dict[int, set]:
    """Adjacency of the co-activation graph G_P."""
    adj: Dict[int, set] = {u: set() for u in range(n)}
    for u in range(n):
        for v in range(u + 1, n):
            if coactive(p, u, v):
                adj[u].add(v)
                adj[v].add(u)
    return adj


def greedy_phi_lower_bound(p: System, n: int) -> int:
    """A fast lower bound on Phi_max: greedily grow a coalition by repeatedly
    adding the highest-degree vertex adjacent to all chosen so far. Polynomial
    time; returns the size of the coalition found (always <= Phi_max)."""
    adj = coactivation_graph(p, n)
    best = 0
    for seed in sorted(range(n), key=lambda v: len(adj[v]), reverse=True):
        coalition = {seed}
        candidates = set(adj[seed])
        while candidates:
            # pick candidate with most connections inside candidate set
            nxt = max(candidates, key=lambda v: len(adj[v] & candidates))
            coalition.add(nxt)
            candidates &= adj[nxt]
            candidates.discard(nxt)
        if len(coalition) >= 2:
            best = max(best, len(coalition))
    return best


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_collapse_and_ceiling() -> None:
    print("=" * 68)
    print("DEMO 1  Collapse theorem (Phi_max = Omega) and ceiling (Phi_max <= n)")
    print("=" * 68)
    # A 4-variable system: a triangle {0,1,2} of mutual co-activation plus an
    # isolated pendant 3 co-active only with 0.
    n = 4
    p: System = {
        (True, True, False, False): 0.25,  # 0,1 together
        (False, True, True, False): 0.25,  # 1,2 together
        (True, False, True, False): 0.25,  # 0,2 together
        (True, False, False, True): 0.25,  # 0,3 together
    }
    pm = phi_max(p, n)
    om = global_coactive(p, n)
    print(f"  variables n          = {n}")
    print(f"  Phi_max(P)           = {pm}")
    print(f"  Omega(P)             = {om}")
    print(f"  collapse Phi_max==Om : {pm == om}   [phiMax_eq_global]")
    print(f"  ceiling Phi_max<=n   : {pm <= n}   [phiMax_le_card]")
    assert pm == om and pm <= n
    print("  -> largest co-active coalition is the triangle {0,1,2}, size 3.")


def demo_reduction(graphs: List[Tuple[str, Graph]]) -> None:
    print()
    print("=" * 68)
    print("DEMO 2  Reduction S(G): Phi_max(S(G)) == clique number omega(G)")
    print("=" * 68)
    print(f"  {'graph':<22}{'n':>3}{'|supp|':>8}{'<=n^2+1':>9}"
          f"{'Phi_max':>9}{'omega':>7}{'match':>7}")
    for name, g in graphs:
        n, _ = g
        p = system_of_graph(g)
        ssz = len(support(p))
        pm = phi_max(p, n)
        om = clique_number(g)
        print(f"  {name:<22}{n:>3}{ssz:>8}{str(ssz <= n * n + 1):>9}"
              f"{pm:>9}{om:>7}{str(pm == om):>7}")
        assert ssz <= n * n + 1            # card_SSupport_le
        assert pm == om                    # reduction theorem


def demo_greedy_approximation(graphs: List[Tuple[str, Graph]]) -> None:
    print()
    print("=" * 68)
    print("DEMO 3  Polynomial-time greedy lower bound on Phi_max")
    print("=" * 68)
    print(f"  {'graph':<22}{'Phi_max (exact)':>16}{'greedy lb':>12}{'valid':>7}")
    for name, g in graphs:
        n, _ = g
        p = system_of_graph(g)
        pm = phi_max(p, n)
        lb = greedy_phi_lower_bound(p, n)
        print(f"  {name:<22}{pm:>16}{lb:>12}{str(lb <= pm):>7}")
        assert lb <= pm


def main() -> None:
    triangle: Graph = (3, [(0, 1), (1, 2), (0, 2)])
    path4: Graph = (4, [(0, 1), (1, 2), (2, 3)])
    k4: Graph = (4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)])
    star4: Graph = (5, [(0, 1), (0, 2), (0, 3), (0, 4)])
    # K4 plus a disjoint edge -> clique number 4
    k4_plus_edge: Graph = (6, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3),
                               (2, 3), (4, 5)])
    graphs = [
        ("triangle K3", triangle),
        ("path P4", path4),
        ("complete K4", k4),
        ("star (5 vertices)", star4),
        ("K4 + disjoint edge", k4_plus_edge),
    ]

    demo_collapse_and_ceiling()
    demo_reduction(graphs)
    demo_greedy_approximation(graphs)

    print()
    print("All assertions passed: the numerical examples confirm the theorems.")


if __name__ == "__main__":
    main()


"""
visualization.py — Visualize the reduction Phi_max(S(G)) = omega(G).

Draws a small graph G, highlights its maximum clique (= largest co-active
coalition of the induced system S(G)), and plots Phi_max vs. clique number
across a family of graphs to illustrate the exact reduction theorem.

Run: python visualization.py   (requires matplotlib; networkx optional)
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

Graph = Tuple[int, List[Tuple[int, int]]]


def clique_number_and_witness(g: Graph) -> Tuple[int, FrozenSet[int]]:
    n, edges = g
    adj = {frozenset((u, v)) for u, v in edges}

    def is_clique(s: Tuple[int, ...]) -> bool:
        return all(frozenset((u, v)) in adj for u, v in combinations(s, 2))

    best_size, best_set = 0, frozenset()
    for r in range(2, n + 1):
        for s in combinations(range(n), r):
            if is_clique(s):
                if r > best_size:
                    best_size, best_set = r, frozenset(s)
    return best_size, best_set


def circle_layout(n: int) -> Dict[int, Tuple[float, float]]:
    return {
        i: (float(np.cos(2 * np.pi * i / n)), float(np.sin(2 * np.pi * i / n)))
        for i in range(n)
    }


def draw_graph_with_clique(ax, g: Graph, title: str) -> None:
    n, edges = g
    pos = circle_layout(n)
    omega, clique = clique_number_and_witness(g)
    clique_edges = {frozenset(e) for e in combinations(sorted(clique), 2)}

    for u, v in edges:
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        in_clique = frozenset((u, v)) in clique_edges
        ax.plot(x, y, color="#d62728" if in_clique else "#bbbbbb",
                lw=3.0 if in_clique else 1.2, zorder=1)
    for i, (x, y) in pos.items():
        on = i in clique
        ax.scatter([x], [y], s=520, zorder=2,
                   color="#d62728" if on else "#1f77b4",
                   edgecolors="black", linewidths=1.0)
        ax.text(x, y, str(i), ha="center", va="center",
                color="white", fontsize=11, fontweight="bold", zorder=3)
    ax.set_title(f"{title}\nomega(G) = Phi_max(S(G)) = {omega}", fontsize=11)
    ax.set_aspect("equal")
    ax.axis("off")


def main() -> None:
    graphs = [
        ("Triangle K3", (3, [(0, 1), (1, 2), (0, 2)])),
        ("Complete K4", (4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)])),
        ("K4 + pendant", (5, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3),
                              (2, 3), (3, 4)])),
        ("Two triangles", (6, [(0, 1), (1, 2), (0, 2), (3, 4), (4, 5), (3, 5)])),
    ]

    fig = plt.figure(figsize=(12, 7))
    for idx, (name, g) in enumerate(graphs):
        ax = fig.add_subplot(2, 3, idx + 1)
        draw_graph_with_clique(ax, g, name)

    # Scatter: Phi_max (== omega) vs |V|, confirming the linear ceiling Phi <= n.
    ax = fig.add_subplot(2, 3, (5, 6))
    ns = [g[0] for _, g in graphs]
    omegas = [clique_number_and_witness(g)[0] for _, g in graphs]
    ax.plot(range(0, max(ns) + 2), range(0, max(ns) + 2),
            "--", color="gray", label="ceiling Phi_max = n")
    ax.scatter(ns, omegas, s=120, color="#d62728", zorder=3,
               label="Phi_max(S(G)) = omega(G)")
    for (name, _), x, y in zip(graphs, ns, omegas):
        ax.annotate(name, (x, y), textcoords="offset points",
                    xytext=(6, 6), fontsize=8)
    ax.set_xlabel("number of variables n")
    ax.set_ylabel("Phi_max")
    ax.set_title("Integrated information vs. system size")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)

    fig.suptitle("Phi_max(S(G)) = omega(G): the exact CLIQUE reduction",
                 fontsize=14, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("phi_clique_reduction.png", dpi=150)
    print("Saved phi_clique_reduction.png")


if __name__ == "__main__":
    main()
