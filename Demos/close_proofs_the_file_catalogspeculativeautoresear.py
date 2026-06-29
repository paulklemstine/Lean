"""
demo.py — Numerical demonstrations of the Minimum-Spanning-Tree Law for H0 persistence.

This script is fully self-contained (standard library only) and reproduces, in
Python, every result of the accompanying theory:

  * beta0(D, t)            — the connected-component count at scale t
  * total_persistence(D,T) — discrete area under the (beta0 - 1) curve
  * the layer-cake identity:  sum_{t<T} #{d in D : t<d} = sum_{d in D} min(d, T)
  * the MST Law:              total_persistence(D, T) = sum(D)   (when T >= max D)
  * a constructive Kruskal merge process producing the death multiset
  * an exhaustive MST-optimality check on an explicit 4-vertex graph

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Tuple

# A "death multiset" is modeled as a list of natural numbers (multiplicity = repeats).
Death = int
DeathMultiset = List[Death]
Edge = Tuple[int, int, int]  # (u, v, weight)


# --------------------------------------------------------------------------- #
# Section 1: the component-count curve and total persistence
# --------------------------------------------------------------------------- #
def beta0(deaths: DeathMultiset, t: int) -> int:
    """Number of connected components at threshold t.

    beta0(D, t) = 1 + #{ d in D : t < d }: one immortal class plus every finite
    bar still alive (death still pending) at scale t.
    """
    return 1 + sum(1 for d in deaths if t < d)


def total_persistence(deaths: DeathMultiset, horizon: int) -> int:
    """Discrete area under the (beta0 - 1) curve over [0, horizon).

    total_persistence(D, T) = sum_{t < T} (beta0(D, t) - 1).
    Computed here directly (the 'naive' column-by-column double count).
    """
    return sum(beta0(deaths, t) - 1 for t in range(horizon))


def total_persistence_layercake(deaths: DeathMultiset, horizon: int) -> int:
    """Total persistence via the layer-cake identity: sum_{d in D} min(d, T).

    This is the one-pass O(#D) formula proved by the layer-cake theorem.
    """
    return sum(min(d, horizon) for d in deaths)


# --------------------------------------------------------------------------- #
# Section 2: the constructive Kruskal merge process (single-linkage clustering)
# --------------------------------------------------------------------------- #
def kruskal_deaths(num_vertices: int, edges: List[Edge]) -> DeathMultiset:
    """Run Kruskal / single-linkage and return the multiset of death (merge) weights.

    A death is recorded exactly when an edge joins two distinct components. The
    recorded weights are the H0 finite-bar death times = MST edge weights.
    """
    label: Dict[int, int] = {v: v for v in range(num_vertices)}

    def rep(x: int) -> int:
        # path-compressing find
        root = x
        while label[root] != root:
            root = label[root]
        while label[x] != root:
            label[x], x = root, label[x]
        return root

    deaths: DeathMultiset = []
    for u, v, w in sorted(edges, key=lambda e: e[2]):
        ru, rv = rep(u), rep(v)
        if ru != rv:
            deaths.append(w)   # merger -> death recorded
            label[ru] = rv     # union
    return deaths


def wsum(edges: List[Edge], subset: Tuple[int, ...]) -> int:
    """Total weight of an edge subset (subset = tuple of indices into `edges`)."""
    return sum(edges[i][2] for i in subset)


def spans(num_vertices: int, edges: List[Edge], subset: Tuple[int, ...]) -> bool:
    """Does the chosen edge subset connect all vertices into one component?"""
    label = list(range(num_vertices))

    def rep(x: int) -> int:
        while label[x] != x:
            label[x] = label[label[x]]
            x = label[x]
        return x

    for i in subset:
        u, v, _ = edges[i]
        label[rep(u)] = rep(v)
    return len({rep(v) for v in range(num_vertices)}) == 1


def min_spanning_weight(num_vertices: int, edges: List[Edge]) -> int:
    """Exhaustive minimum spanning weight over ALL spanning edge subsets."""
    best = None
    n = len(edges)
    for r in range(num_vertices - 1, n + 1):
        for subset in combinations(range(n), r):
            if spans(num_vertices, edges, subset):
                w = wsum(edges, subset)
                best = w if best is None else min(best, w)
    assert best is not None, "graph is not connected"
    return best


# --------------------------------------------------------------------------- #
# Section 3: demonstrations
# --------------------------------------------------------------------------- #
def demo_layer_cake() -> None:
    print("=" * 70)
    print("DEMO 1 — The discrete layer-cake identity")
    print("=" * 70)
    deaths = [2, 3, 3, 7]
    for T in [0, 3, 5, 8, 10]:
        lhs = sum(sum(1 for d in deaths if t < d) for t in range(T))
        rhs = sum(min(d, T) for d in deaths)
        print(f"  D={deaths}  T={T:2d} :  "
              f"sum_t #{{d>t}} = {lhs:2d}   sum_d min(d,T) = {rhs:2d}   "
              f"{'OK' if lhs == rhs else 'MISMATCH'}")
    print()


def demo_total_persistence_two_ways() -> None:
    print("=" * 70)
    print("DEMO 2 — Total persistence: naive double count vs. one-pass formula")
    print("=" * 70)
    deaths = [1, 4, 4, 9, 12]
    for T in [0, 5, 9, 12, 20]:
        naive = total_persistence(deaths, T)
        fast = total_persistence_layercake(deaths, T)
        print(f"  D={deaths}  T={T:2d} :  naive={naive:3d}  layercake={fast:3d}  "
              f"{'OK' if naive == fast else 'MISMATCH'}")
    print()


def demo_mst_law() -> None:
    print("=" * 70)
    print("DEMO 3 — The MST Law: P(T) = sum(D) once T dominates every death")
    print("=" * 70)
    deaths = [3, 5, 8]
    big_T = max(deaths)  # horizon dominates every death
    p = total_persistence(deaths, big_T)
    print(f"  D={deaths}  T={big_T} (>= max D)")
    print(f"  total persistence = {p}")
    print(f"  sum of death times = {sum(deaths)}")
    print(f"  {'OK: persistence equals death-sum' if p == sum(deaths) else 'MISMATCH'}")
    print()


def demo_beta0_curve() -> None:
    print("=" * 70)
    print("DEMO 4 — The component-count curve is monotone and reaches 1")
    print("=" * 70)
    deaths = [2, 2, 5, 9]
    curve = [(t, beta0(deaths, t)) for t in range(0, 11)]
    print(f"  D={deaths}")
    print("  t      :", " ".join(f"{t:2d}" for t, _ in curve))
    print("  beta0  :", " ".join(f"{b:2d}" for _, b in curve))
    antitone = all(curve[i][1] >= curve[i + 1][1] for i in range(len(curve) - 1))
    print(f"  monotone non-increasing: {antitone}")
    print(f"  beta0 at t=max(D)={max(deaths)}: {beta0(deaths, max(deaths))} "
          f"(expected 1)")
    print()


def demo_kruskal_correspondence() -> None:
    print("=" * 70)
    print("DEMO 5 — Persistence = death-sum = MST weight (explicit 4-vertex graph)")
    print("=" * 70)
    # An explicit weighted graph on vertices {0,1,2,3}.
    edges: List[Edge] = [
        (0, 1, 1),
        (1, 2, 2),
        (2, 3, 3),
        (0, 2, 4),
        (0, 3, 5),
        (1, 3, 6),
    ]
    n = 4
    deaths = kruskal_deaths(n, edges)
    p = total_persistence(deaths, max(deaths))
    mst = min_spanning_weight(n, edges)
    print(f"  edges (u,v,w) = {edges}")
    print(f"  Kruskal death multiset      = {sorted(deaths)}")
    print(f"  sum of deaths (= Kruskal tree weight) = {sum(deaths)}")
    print(f"  total H0 persistence P(T)             = {p}")
    print(f"  exhaustive minimum spanning weight    = {mst}")
    ok = (p == sum(deaths) == mst)
    print(f"  {'OK: all three coincide' if ok else 'MISMATCH'}")
    print()


def main() -> None:
    demo_layer_cake()
    demo_total_persistence_two_ways()
    demo_mst_law()
    demo_beta0_curve()
    demo_kruskal_correspondence()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
