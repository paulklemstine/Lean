"""
demo.py — The Minimum-Spanning-Tree Law for H0 Persistence
==========================================================

A self-contained, dependency-free numerical demonstration of the results
formalized in `ProteinFoldingMST.lean`:

  * beta0(D, t)          : the connected-component count curve
  * total_persistence    : discrete area under (beta0 - 1)
  * layer_cake identity  : sum_{t<T} #{d>t} = sum_d min(d,T)
  * MST Law              : total persistence = sum of death times (past horizon)
  * Kruskal merge process: death multiset = MST edge weights
  * MST optimality       : brute-force certificate over all edge subsets

All weights are natural numbers, mirroring the Lean development (rationals
rescale to integers without losing combinatorial content).

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Optional, Tuple

Edge = Tuple[int, int, int]  # (u, v, w): endpoints u, v and weight w


# ---------------------------------------------------------------------------
# Persistence side
# ---------------------------------------------------------------------------

def alive_count(deaths: List[int], t: int) -> int:
    """Number of finite bars still alive at threshold t: #{ d in D : t < d }."""
    return sum(1 for d in deaths if t < d)


def beta0(deaths: List[int], t: int) -> int:
    """Component-count curve: 1 essential class + alive finite bars."""
    return 1 + alive_count(deaths, t)


def total_persistence(deaths: List[int], horizon: int) -> int:
    """Discrete area under (beta0 - 1) up to the horizon T."""
    return sum(beta0(deaths, t) - 1 for t in range(horizon))


def truncated_death_sum(deaths: List[int], horizon: int) -> int:
    """Right-hand side of the layer-cake identity: sum_d min(d, T)."""
    return sum(min(d, horizon) for d in deaths)


# ---------------------------------------------------------------------------
# Optimization side: constructive Kruskal / single-linkage
# ---------------------------------------------------------------------------

def kruskal_deaths(edges: List[Edge]) -> List[int]:
    """
    Fold the Kruskal step over a weight-sorted edge list, starting from the
    discrete partition (every vertex its own component). Emit a death at an
    edge's weight exactly when it joins two distinct components.

    Returns the multiset (as a list) of recorded death times = MST edge weights.
    """
    label: Dict[int, int] = {}

    def find(x: int) -> int:
        return label.get(x, x)

    deaths: List[int] = []
    for (u, v, w) in sorted(edges, key=lambda e: e[2]):
        cu, cv = find(u), find(v)
        if cu == cv:
            continue  # already connected: skip
        # relabel cv's class to cu (record every seen vertex first)
        for x in {u, v} | set(label.keys()):
            label.setdefault(x, x)
        for x in list(label.keys()):
            if label[x] == cv:
                label[x] = cu
        # also fix the just-merged endpoints
        label[u], label[v] = cu, cu
        for x in list(label.keys()):
            if find(x) == cv:
                label[x] = cu
        deaths.append(w)
    return deaths


def vertices_of(edges: List[Edge]) -> List[int]:
    """All vertices appearing in an edge list."""
    vs = set()
    for (u, v, _) in edges:
        vs.add(u)
        vs.add(v)
    return sorted(vs)


def spans(edges: List[Edge], n: int) -> bool:
    """Does the edge subset connect all of {0, ..., n-1}? (reachability from 0)."""
    adj: Dict[int, List[int]] = {i: [] for i in range(n)}
    for (u, v, _) in edges:
        if u < n and v < n:
            adj[u].append(v)
            adj[v].append(u)
    seen = {0}
    stack = [0]
    while stack:
        x = stack.pop()
        for y in adj[x]:
            if y not in seen:
                seen.add(y)
                stack.append(y)
    return len(seen) == n


def wsum(edges: List[Edge]) -> int:
    """Total weight of an edge subset."""
    return sum(w for (_, _, w) in edges)


def brute_force_min_spanning_weight(edges: List[Edge], n: int) -> Optional[int]:
    """Minimum weight over all spanning subsets (exhaustive 2^m search)."""
    best: Optional[int] = None
    for k in range(len(edges) + 1):
        for combo in combinations(edges, k):
            sub = list(combo)
            if spans(sub, n):
                w = wsum(sub)
                if best is None or w < best:
                    best = w
    return best


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_example_graph() -> None:
    """Reproduce the explicit 4-vertex graph from the Lean development."""
    print("=" * 68)
    print("Explicit 4-vertex graph (matches Lean `exEdges`)")
    print("=" * 68)
    edges: List[Edge] = [(0, 1, 1), (1, 2, 2), (0, 2, 3),
                         (2, 3, 4), (1, 3, 5), (0, 3, 6)]
    n = 4
    for (u, v, w) in edges:
        print(f"   {u}--{v}  weight {w}")

    deaths = kruskal_deaths(edges)
    print(f"\nKruskal death multiset : {sorted(deaths)}   (Lean: {{1, 2, 4}})")
    print(f"MST weight (sum)       : {sum(deaths)}        (Lean: 7)")

    T = sum(deaths)  # horizon dominating all deaths
    P = total_persistence(deaths, T)
    print(f"\nTotal H0 persistence P(D, {T}) : {P}")
    print(f"Sum of death times            : {sum(deaths)}")
    print(f"MST Law holds (P == sum)      : {P == sum(deaths)}")

    bf = brute_force_min_spanning_weight(edges, n)
    print(f"\nBrute-force min spanning weight : {bf}")
    print(f"Kruskal achieves optimum        : {bf == sum(deaths)}")


def demo_layer_cake() -> None:
    """Verify the layer-cake identity for several multisets and horizons."""
    print("\n" + "=" * 68)
    print("Layer-cake identity:  sum_{t<T} #{d>t}  ==  sum_d min(d, T)")
    print("=" * 68)
    cases = [
        ([1, 2, 4], 7),
        ([1, 2, 4], 3),
        ([3, 3, 5, 8], 6),
        ([1, 1, 1, 1], 10),
        ([], 5),
    ]
    for deaths, T in cases:
        lhs = total_persistence(deaths, T)
        rhs = truncated_death_sum(deaths, T)
        print(f"   D={deaths!s:<16} T={T:<3}  LHS={lhs:<3} RHS={rhs:<3} "
              f"match={lhs == rhs}")


def demo_beta0_curve() -> None:
    """Tabulate the beta0 staircase and confirm monotonicity + eventual unity."""
    print("\n" + "=" * 68)
    print("Component-count staircase beta0 for D = {1, 2, 4}")
    print("=" * 68)
    deaths = [1, 2, 4]
    horizon = 7
    print("   t     :", " ".join(f"{t:2d}" for t in range(horizon)))
    print("   alive :", " ".join(f"{alive_count(deaths, t):2d}"
                                  for t in range(horizon)))
    print("   beta0 :", " ".join(f"{beta0(deaths, t):2d}"
                                  for t in range(horizon)))
    vals = [beta0(deaths, t) for t in range(horizon)]
    print(f"\n   Antitone (non-increasing) : "
          f"{all(vals[i] >= vals[i + 1] for i in range(len(vals) - 1))}")
    print(f"   beta0 settles at 1        : {beta0(deaths, max(deaths)) == 1}")


def main() -> None:
    demo_example_graph()
    demo_layer_cake()
    demo_beta0_curve()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
