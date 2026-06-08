#!/usr/bin/env python3
"""
Algorithms for Chip-Firing and Graph Riemann-Roch Theory

Implements:
1. Canonical divisor computation
2. Chip-firing simulation
3. Dhar's burning algorithm for q-reduced divisors
4. Genus and degree computation
5. Rank estimation via exhaustive search (small graphs)
"""

from typing import Dict, List, Set, Tuple, Optional
from collections import deque
import itertools


class SimpleGraph:
    """A simple undirected graph."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.vertices: List[int] = list(range(n))
        self.adj: Dict[int, Set[int]] = {v: set() for v in self.vertices}
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        """Degree of vertex v."""
        return len(self.adj[v])

    def num_edges(self) -> int:
        """Total number of edges."""
        return sum(self.degree(v) for v in self.vertices) // 2

    def genus(self) -> int:
        """First Betti number: g = |E| - |V| + 1."""
        return self.num_edges() - self.n + 1

    @staticmethod
    def complete(n: int) -> 'SimpleGraph':
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        return SimpleGraph(n, edges)

    @staticmethod
    def cycle(n: int) -> 'SimpleGraph':
        edges = [(i, (i + 1) % n) for i in range(n)]
        return SimpleGraph(n, edges)

    @staticmethod
    def path(n: int) -> 'SimpleGraph':
        edges = [(i, i + 1) for i in range(n - 1)]
        return SimpleGraph(n, edges)


class Divisor:
    """Integer-valued function on vertices (a divisor)."""

    def __init__(self, G: SimpleGraph, values: Optional[Dict[int, int]] = None):
        self.G = G
        self.values: Dict[int, int] = {v: 0 for v in G.vertices}
        if values:
            self.values.update(values)

    def __getitem__(self, v: int) -> int:
        return self.values[v]

    def __setitem__(self, v: int, val: int) -> None:
        self.values[v] = val

    def degree(self) -> int:
        return sum(self.values.values())

    def is_effective(self) -> bool:
        return all(c >= 0 for c in self.values.values())

    def copy(self) -> 'Divisor':
        return Divisor(self.G, dict(self.values))

    def __add__(self, other: 'Divisor') -> 'Divisor':
        return Divisor(self.G, {v: self[v] + other[v] for v in self.G.vertices})

    def __sub__(self, other: 'Divisor') -> 'Divisor':
        return Divisor(self.G, {v: self[v] - other[v] for v in self.G.vertices})

    def __repr__(self) -> str:
        return "(" + ", ".join(f"{self[v]}" for v in sorted(self.G.vertices)) + ")"


# ============================================================
# Algorithm 1: Canonical Divisor
# ============================================================

def canonical_divisor(G: SimpleGraph) -> Divisor:
    """
    Compute the canonical divisor K_G.

    K_G(v) = deg(v) - 2 for each vertex v.

    Time: O(|V|)
    """
    return Divisor(G, {v: G.degree(v) - 2 for v in G.vertices})


# ============================================================
# Algorithm 2: Chip-Firing
# ============================================================

def chip_fire(D: Divisor, v: int) -> Divisor:
    """
    Fire vertex v: sends one chip along each incident edge.

    D'(v) = D(v) - deg(v)
    D'(w) = D(w) + 1   if w ~ v
    D'(w) = D(w)        otherwise

    Time: O(deg(v))
    """
    result = D.copy()
    result[v] -= D.G.degree(v)
    for w in D.G.adj[v]:
        result[w] += 1
    return result


def apply_firing_script(D: Divisor, script: Dict[int, int]) -> Divisor:
    """
    Apply a firing script f: fire each vertex v exactly f[v] times.
    Equivalent to D + Δf (Laplacian of f).

    Time: O(|V| + |E|)
    """
    result = D.copy()
    for v in D.G.vertices:
        fv = script.get(v, 0)
        result[v] += sum(fv - script.get(w, 0) for w in D.G.adj[v])
    return result


# ============================================================
# Algorithm 3: Dhar's Burning Algorithm
# ============================================================

def dhars_burning(G: SimpleGraph, q: int, D: Divisor) -> Tuple[bool, Optional[Set[int]]]:
    """
    Dhar's burning algorithm to test if D is q-reduced.

    Start a fire at q. A vertex v burns if D(v) < outdeg_S(v)
    where outdeg_S(v) = number of neighbors of v outside the unburnt set.
    Repeat until stable.

    Returns:
        (is_q_reduced, unburnt_set) where unburnt_set is None if q-reduced.

    Time: O(|V| * |E|) worst case
    """
    unburnt = set(G.vertices) - {q}
    changed = True

    while changed:
        changed = False
        to_burn = set()
        for v in unburnt:
            outdeg = sum(1 for w in G.adj[v] if w not in unburnt)
            if D[v] < outdeg:
                to_burn.add(v)
                changed = True
        unburnt -= to_burn

    if not unburnt:
        return True, None
    else:
        return False, unburnt


def q_reduce(G: SimpleGraph, q: int, D: Divisor) -> Divisor:
    """
    Compute the unique q-reduced divisor linearly equivalent to D.

    Algorithm: repeatedly find a non-empty subset S ⊆ V\\{q}
    that can fire (all vertices have enough chips) and fire it.

    Time: O(|V|^2 * max|D|) in worst case
    """
    result = D.copy()
    max_iterations = 1000

    for _ in range(max_iterations):
        is_reduced, unburnt = dhars_burning(G, q, result)
        if is_reduced:
            return result

        # Fire the unburnt set
        if unburnt:
            for v in unburnt:
                for w in G.adj[v]:
                    if w not in unburnt:
                        result[v] -= 1
                        result[w] += 1

    return result  # May not converge for all inputs


# ============================================================
# Algorithm 4: Rank Computation (Exhaustive, Small Graphs Only)
# ============================================================

def compute_rank(G: SimpleGraph, D: Divisor, q: int = 0) -> int:
    """
    Compute the rank r(D) by exhaustive search.

    r(D) = max{k : for all effective E of degree k, D - E ~ effective}
    or -1 if D is not equivalent to any effective divisor.

    Uses q-reduction to test equivalence to effective divisors.

    Time: O(C(|V|+k-1, k) * reduction_time) — exponential in k.
    Only suitable for small graphs (|V| ≤ 6).
    """
    # First check if D ~ effective
    D_red = q_reduce(G, q, D)
    if not all(D_red[v] >= 0 for v in G.vertices if v != q):
        return -1

    # Binary search / sequential for rank
    k = 0
    while True:
        k += 1
        if k > D.degree():
            return k - 1

        # Check all effective divisors of degree k
        found_counterexample = False
        for combo in _effective_divisors_of_degree(G, k):
            E = Divisor(G, combo)
            diff = D - E
            diff_red = q_reduce(G, q, diff)
            if not all(diff_red[v] >= 0 for v in G.vertices if v != q):
                found_counterexample = True
                break

        if found_counterexample:
            return k - 1


def _effective_divisors_of_degree(G: SimpleGraph, k: int):
    """Generate all effective divisors of degree k on G."""
    n = G.n
    for combo in itertools.combinations_with_replacement(range(n), k):
        values = {v: 0 for v in range(n)}
        for v in combo:
            values[v] += 1
        yield values


# ============================================================
# Algorithm 5: Rank Stability Spectrum
# ============================================================

def rank_stability(G: SimpleGraph, D: Divisor, k: int, q: int = 0) -> int:
    """
    Compute the rank stability σ(D, k): the minimum number of chips
    that must be removed to reduce the rank below k.

    σ(D, k) = min{deg(E) : E effective, r(D - E) < k}

    This is a novel invariant that refines the rank function.

    Returns -1 if r(D) < k (already below threshold).
    """
    r = compute_rank(G, D, q)
    if r < k:
        return -1
    if k < 0:
        return 0

    # Search for minimum effective E such that r(D - E) < k
    for m in range(D.degree() + 1):
        for combo in _effective_divisors_of_degree(G, m):
            E = Divisor(G, combo)
            diff = D - E
            if compute_rank(G, diff, q) < k:
                return m

    return D.degree() + 1


# ============================================================
# Main: Run demonstrations
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Chip-Firing Algorithms Demo")
    print("=" * 60)

    # Complete graph K_4
    G = SimpleGraph.complete(4)
    K = canonical_divisor(G)
    print(f"\nK_4: canonical divisor = {K}, degree = {K.degree()}, genus = {G.genus()}")

    # Rank of canonical divisor
    r_K = compute_rank(G, K)
    print(f"  rank(K) = {r_K}")
    print(f"  genus - 1 = {G.genus() - 1}")

    # Dhar's burning on a specific divisor
    D = Divisor(G, {0: 3, 1: 0, 2: 1, 3: 0})
    is_red, _ = dhars_burning(G, 0, D)
    print(f"\n  D = {D}")
    print(f"  q-reduced (q=0)? {is_red}")

    D_red = q_reduce(G, 0, D)
    print(f"  q-reduced form: {D_red}")

    # Rank stability
    D2 = Divisor(G, {0: 2, 1: 2, 2: 2, 3: 2})
    r2 = compute_rank(G, D2)
    print(f"\n  D = {D2}, rank = {r2}")
    for k in range(r2 + 1):
        s = rank_stability(G, D2, k)
        print(f"  σ(D, {k}) = {s}")

    print("\nDone!")
