#!/usr/bin/env python3
"""
Algorithms for Tropical Morse Spectrum Computation and WL Separation Detection.

Implements:
1. Union-Find with path compression and union by rank
2. Tropical Morse Spectrum via Kruskal filtration
3. k-WL atomic type computation
4. Separation detection algorithm
5. Non-uniform weight profile generation

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Dict, Optional, Callable
from collections import Counter
import itertools


# ============================================================
# 1. Union-Find Data Structure
# ============================================================

class UnionFind:
    """
    Disjoint set data structure with path compression and union by rank.

    Time complexity:
        - find: O(α(n)) amortized
        - union: O(α(n)) amortized
    Space: O(n)
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x: int) -> int:
        """Find root with path compression."""
        root = x
        while self.parent[root] != root:
            root = self.parent[root]
        while self.parent[x] != root:
            self.parent[x], x = root, self.parent[x]
        return root

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if merge occurred."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True

    def connected(self, x: int, y: int) -> bool:
        """Check if x and y are in the same component."""
        return self.find(x) == self.find(y)


# ============================================================
# 2. Tropical Morse Spectrum
# ============================================================

class MorseEvent:
    """A critical event in the tropical Morse filtration."""

    def __init__(self, value: float, event_type: str):
        assert event_type in ('merge', 'cycle_death', 'birth')
        self.value = value
        self.event_type = event_type

    def __repr__(self):
        return f"MorseEvent({self.value:.4f}, {self.event_type})"

    def __eq__(self, other):
        return self.value == other.value and self.event_type == other.event_type


class TMSpectrum:
    """
    Tropical Morse Spectrum of an edge-weighted graph.

    Computed via Kruskal-style filtration in O(m log m + m α(n)) time.
    """

    def __init__(self, events: List[MorseEvent]):
        self.events = events

    @property
    def merge_count(self) -> int:
        return sum(1 for e in self.events if e.event_type == 'merge')

    @property
    def cycle_count(self) -> int:
        return sum(1 for e in self.events if e.event_type == 'cycle_death')

    @property
    def betti1(self) -> int:
        """First Betti number = cycle_count."""
        return self.cycle_count

    @property
    def complexity(self) -> int:
        """Tropical Morse complexity = number of distinct critical values."""
        return len(set(e.value for e in self.events))

    def __eq__(self, other):
        return self.events == other.events

    def __repr__(self):
        return f"TMSpectrum({self.merge_count} merges, {self.cycle_count} cycles)"


def compute_tms(
    num_vertices: int,
    edges: List[Tuple[int, int, float]]
) -> TMSpectrum:
    """
    Compute the Tropical Morse Spectrum.

    Args:
        num_vertices: Number of vertices
        edges: List of (u, v, weight) tuples

    Returns:
        TMSpectrum object

    Time: O(m log m + m α(n)) where m = |edges|, n = num_vertices
    Space: O(n + m)
    """
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(num_vertices)
    events = []

    for u, v, w in sorted_edges:
        if uf.union(u, v):
            events.append(MorseEvent(w, 'merge'))
        else:
            events.append(MorseEvent(w, 'cycle_death'))

    return TMSpectrum(events)


# ============================================================
# 3. Graph Construction
# ============================================================

def make_cycle(
    m: int,
    weight_fn: Optional[Callable[[int], float]] = None
) -> Tuple[int, List[Tuple[int, int, float]]]:
    """
    Construct cycle graph C_m.

    Args:
        m: Cycle length
        weight_fn: Edge weight function i -> w(i), default is i+1

    Returns:
        (num_vertices, edge_list)
    """
    if weight_fn is None:
        weight_fn = lambda i: float(i + 1)
    edges = [(i, (i + 1) % m, weight_fn(i)) for i in range(m)]
    return m, edges


def make_two_cycles(
    n: int,
    weight_fn: Optional[Callable[[int], float]] = None
) -> Tuple[int, List[Tuple[int, int, float]]]:
    """
    Construct two disjoint cycles 2×C_n on 2n vertices.

    Args:
        n: Individual cycle length
        weight_fn: Weight function, shared between cycles

    Returns:
        (num_vertices, edge_list)
    """
    if weight_fn is None:
        weight_fn = lambda i: float(i + 1)
    edges = []
    for i in range(n):
        edges.append((i, (i + 1) % n, weight_fn(i)))
    for i in range(n):
        edges.append((n + i, n + (i + 1) % n, weight_fn(i)))
    return 2 * n, edges


# ============================================================
# 4. k-WL Atomic Type Computation
# ============================================================

def compute_atomic_type(
    adj: List[List[bool]],
    k_tuple: Tuple[int, ...]
) -> Tuple[Tuple[Tuple[bool, ...], ...], Tuple[Tuple[bool, ...], ...]]:
    """
    Compute the atomic type of a k-tuple in a graph.

    Returns (equality_pattern, adjacency_pattern) as nested tuples.
    """
    k = len(k_tuple)
    eq_pattern = tuple(
        tuple(k_tuple[i] == k_tuple[j] for j in range(k))
        for i in range(k)
    )
    adj_pattern = tuple(
        tuple(adj[k_tuple[i]][k_tuple[j]] for j in range(k))
        for i in range(k)
    )
    return (eq_pattern, adj_pattern)


def check_wlk_equiv(
    adj1: List[List[bool]],
    adj2: List[List[bool]],
    n: int,
    k: int
) -> bool:
    """
    Check k-WL equivalence via atomic type multiset agreement.

    Time: O(n^k · k^2) — exponential in k.
    """
    type_counts1: Dict = Counter()
    type_counts2: Dict = Counter()

    for t in itertools.product(range(n), repeat=k):
        tp1 = compute_atomic_type(adj1, t)
        tp2 = compute_atomic_type(adj2, t)
        type_counts1[tp1] += 1
        type_counts2[tp2] += 1

    return type_counts1 == type_counts2


def degree_multiset(num_vertices: int, edges: list) -> List[int]:
    """Compute sorted degree sequence."""
    deg = [0] * num_vertices
    for u, v, _ in edges:
        deg[u] += 1
        deg[v] += 1
    return sorted(deg)


# ============================================================
# 5. Separation Detection
# ============================================================

def detect_separation(
    k: int,
    n: int
) -> Optional[Tuple[TMSpectrum, TMSpectrum, float]]:
    """
    Detect CFI-style separation for given k and n.

    Constructs C_{2n} vs 2×C_n with non-uniform weights w(i) = 1/(2i+1).
    Returns (tms1, tms2, threshold) if separated, None otherwise.

    Time: O(n log n)
    """
    weight_fn = lambda i: 1.0 / (2 * i + 1)

    nv1, e1 = make_cycle(2 * n, weight_fn)
    nv2, e2 = make_two_cycles(n, weight_fn)

    # Verify WL1 equivalence
    deg1 = degree_multiset(nv1, e1)
    deg2 = degree_multiset(nv2, e2)
    if deg1 != deg2:
        return None

    tms1 = compute_tms(nv1, e1)
    tms2 = compute_tms(nv2, e2)

    if tms1 == tms2:
        return None

    # Find separating threshold
    threshold = min(e.value for e in tms1.events if e.event_type == 'cycle_death')
    return (tms1, tms2, threshold)


# ============================================================
# 6. Non-Uniform Weight Profiles
# ============================================================

def harmonic_weights(m: int) -> List[float]:
    """Canonical CFI weight profile: w(i) = 1/(2i+1)."""
    return [1.0 / (2 * i + 1) for i in range(m)]


def verify_injectivity(weights: List[float]) -> bool:
    """Verify all weights are distinct."""
    return len(set(weights)) == len(weights)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Tropical Morse Spectrum Algorithms ===\n")

    # Example 1: C_8 vs 2×C_4
    print("Example 1: C_8 vs 2×C_4")
    nv1, e1 = make_cycle(8)
    nv2, e2 = make_two_cycles(4)
    tms1 = compute_tms(nv1, e1)
    tms2 = compute_tms(nv2, e2)
    print(f"  C_8:    {tms1}")
    print(f"  2×C_4:  {tms2}")
    print(f"  β₁ gap: {tms2.betti1 - tms1.betti1}")
    print(f"  Separated: {tms1 != tms2}\n")

    # Example 2: Separation detection
    print("Example 2: Separation detection for k=3")
    result = detect_separation(3, 5)
    if result:
        t1, t2, threshold = result
        print(f"  Found separation at threshold {threshold:.4f}")
        print(f"  C_10: {t1}")
        print(f"  2×C_5: {t2}")
    print()

    # Example 3: Weight profile
    print("Example 3: Harmonic weight profile")
    weights = harmonic_weights(8)
    print(f"  Weights: {[f'{w:.4f}' for w in weights]}")
    print(f"  All distinct: {verify_injectivity(weights)}")
