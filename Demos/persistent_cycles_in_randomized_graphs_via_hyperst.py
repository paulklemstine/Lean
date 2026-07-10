"""
Persistent Cycles in Randomized Graphs -- numerical demonstrations.

This self-contained script illustrates the main results on cycle persistence
in a random subgraph G_p obtained by retaining each edge of a host graph
independently with probability p:

  * Survival law:            Pr[S survives] = p ** |S|
  * Total probability law:   sum of outcome weights = 1
  * First-moment identity:   E[# survivors of family F] = sum_S p**|S|
  * Family union bound:      Pr[some S survives] <= sum_S p**|S|
  * Expected retained edges: E[# retained edges] = p * |E|
  * Single-structure fragility: p ** L -> 0 as L -> infinity
  * Deterministic backbone:  min-degree >= k  =>  path of length >= k

Only the Python standard library is used.
"""

from __future__ import annotations

import itertools
import random
from typing import Dict, Hashable, List, Sequence, Set, Tuple

Vertex = Hashable
Edge = Tuple[Vertex, Vertex]


# ---------------------------------------------------------------------------
# 1. Exact survival law and probability mass function
# ---------------------------------------------------------------------------

def survival_probability(p: float, edge_set_size: int) -> float:
    """Exact probability that a fixed edge set of given size survives: p**|S|."""
    return p ** edge_set_size


def total_probability(p: float, num_edges: int) -> float:
    """Brute-force sum of weights over all 2**num_edges outcomes; equals 1."""
    total = 0.0
    for bits in itertools.product([False, True], repeat=num_edges):
        weight = 1.0
        for retained in bits:
            weight *= p if retained else (1.0 - p)
        total += weight
    return total


# ---------------------------------------------------------------------------
# 2. First moment and union bound over a family of edge sets
# ---------------------------------------------------------------------------

def expected_survivors(p: float, family_sizes: Sequence[int]) -> float:
    """First-moment identity: E[# survivors] = sum_S p**|S|."""
    return sum(p ** size for size in family_sizes)


def union_bound(p: float, family_sizes: Sequence[int]) -> float:
    """Union-bound upper estimate on Pr[some member survives]."""
    return sum(p ** size for size in family_sizes)


def monte_carlo_some_survives(
    p: float, family: Sequence[frozenset], num_edges: int, trials: int, seed: int = 0
) -> float:
    """Empirical Pr[some member of `family` survives] via simulation."""
    rng = random.Random(seed)
    hits = 0
    for _ in range(trials):
        retained = {e for e in range(num_edges) if rng.random() < p}
        if any(S <= retained for S in family):
            hits += 1
    return hits / trials


def expected_retained_edges(p: float, num_edges: int) -> float:
    """Expected number of retained edges: p * |E|."""
    return p * num_edges


# ---------------------------------------------------------------------------
# 3. Deterministic backbone: min-degree forces a long path
# ---------------------------------------------------------------------------

def degrees(vertices: Sequence[Vertex], edges: Sequence[Edge]) -> Dict[Vertex, int]:
    deg = {v: 0 for v in vertices}
    for a, b in edges:
        deg[a] += 1
        deg[b] += 1
    return deg


def min_degree(vertices: Sequence[Vertex], edges: Sequence[Edge]) -> int:
    d = degrees(vertices, edges)
    return min(d.values()) if d else 0


def adjacency(vertices: Sequence[Vertex], edges: Sequence[Edge]) -> Dict[Vertex, Set[Vertex]]:
    adj: Dict[Vertex, Set[Vertex]] = {v: set() for v in vertices}
    for a, b in edges:
        adj[a].add(b)
        adj[b].add(a)
    return adj


def longest_path_length(vertices: Sequence[Vertex], edges: Sequence[Edge]) -> int:
    """Longest simple path length via exhaustive DFS (small graphs only)."""
    adj = adjacency(vertices, edges)
    best = 0

    def dfs(v: Vertex, visited: Set[Vertex], length: int) -> None:
        nonlocal best
        best = max(best, length)
        for w in adj[v]:
            if w not in visited:
                visited.add(w)
                dfs(w, visited, length + 1)
                visited.remove(w)

    for start in vertices:
        dfs(start, {start}, 0)
    return best


def percolate(edges: Sequence[Edge], p: float, rng: random.Random) -> List[Edge]:
    """Retain each edge independently with probability p."""
    return [e for e in edges if rng.random() < p]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_survival_law() -> None:
    print("=" * 64)
    print("Survival law:  Pr[S survives] = p ** |S|")
    print("=" * 64)
    p = 0.9
    for L in [1, 5, 10, 50, 100]:
        print(f"  p={p}, |S|={L:4d}  ->  survival prob = {survival_probability(p, L):.6e}")
    print("  Note the exponential decay: a single long cycle is doomed.\n")


def demo_total_probability() -> None:
    print("=" * 64)
    print("Total probability law:  sum of outcome weights = 1")
    print("=" * 64)
    for p in [0.2, 0.5, 0.75]:
        for m in [1, 3, 6]:
            print(f"  p={p}, |E|={m}  ->  sum of weights = {total_probability(p, m):.10f}")
    print()


def demo_first_moment_and_union_bound() -> None:
    print("=" * 64)
    print("First moment & union bound over a family of cycles")
    print("=" * 64)
    p = 0.6
    num_edges = 12
    # A family of edge sets (as index subsets of {0,...,11}).
    family = [
        frozenset({0, 1, 2}),
        frozenset({3, 4, 5}),
        frozenset({0, 1, 2, 3}),
        frozenset({6, 7, 8, 9, 10}),
    ]
    sizes = [len(S) for S in family]
    e_surv = expected_survivors(p, sizes)
    ub = union_bound(p, sizes)
    mc = monte_carlo_some_survives(p, family, num_edges, trials=200_000)
    print(f"  expected number of survivors  = {e_surv:.4f}")
    print(f"  union-bound upper estimate    = {ub:.4f}")
    print(f"  Monte-Carlo Pr[some survives] = {mc:.4f}")
    print(f"  union bound holds (mc <= ub): {mc <= ub + 1e-3}\n")


def demo_expected_retained_edges() -> None:
    print("=" * 64)
    print("Expected retained edges:  E[#retained] = p * |E|")
    print("=" * 64)
    edges = [(i, i + 1) for i in range(20)]
    p = 0.35
    rng = random.Random(42)
    trials = 50_000
    total = sum(len(percolate(edges, p, rng)) for _ in range(trials))
    empirical = total / trials
    print(f"  |E|={len(edges)}, p={p}")
    print(f"  theory    p*|E| = {expected_retained_edges(p, len(edges)):.4f}")
    print(f"  empirical mean  = {empirical:.4f}\n")


def demo_deterministic_backbone() -> None:
    print("=" * 64)
    print("Deterministic backbone:  min-degree >= k  =>  path length >= k")
    print("=" * 64)
    # Complete graph K_n has minimum degree n-1 and a Hamiltonian path of length n-1.
    for n in [4, 5, 6]:
        vertices = list(range(n))
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        delta = min_degree(vertices, edges)
        lp = longest_path_length(vertices, edges)
        print(f"  K_{n}: min-degree = {delta}, longest path length = {lp}, "
              f"guarantee (>= min-degree) holds: {lp >= delta}")
    print()

    # Random host graph, percolated, then measured.
    print("  Percolate-and-measure on a random dense host:")
    rng = random.Random(7)
    n = 8
    vertices = list(range(n))
    host = [(i, j) for i in range(n) for j in range(i + 1, n)]
    for p in [0.4, 0.6, 0.8]:
        kept = percolate(host, p, rng)
        delta = min_degree(vertices, kept)
        lp = longest_path_length(vertices, kept)
        print(f"    p={p}: retained {len(kept):2d}/{len(host)} edges, "
              f"min-degree={delta}, longest path length={lp}, "
              f"lp >= min-degree: {lp >= delta}")
    print()


def main() -> None:
    demo_survival_law()
    demo_total_probability()
    demo_first_moment_and_union_bound()
    demo_expected_retained_edges()
    demo_deterministic_backbone()


if __name__ == "__main__":
    main()
