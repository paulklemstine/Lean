#!/usr/bin/env python3
"""
Tropical Morse Spectrum Algorithms for Quantum Graph Codes

Implements certified algorithms for computing tropical Morse spectra and
extracting quantum code parameters from interaction graphs.

Algorithms:
  1. compute_tms — Full tropical Morse spectrum via Kruskal filtration
  2. first_cycle_birth — First cycle critical value
  3. compute_cycle_rank — β₁ computation (logical qubit count)
  4. compute_girth — Shortest cycle (code distance in unit-weight regime)
  5. estimate_code_distance — Combined distance estimator
  6. spectral_classifier — Classify codes by their TMS

Complexity:
  - compute_tms: O(E log E + E α(V)) where α is inverse Ackermann
  - compute_girth: O(V * (V + E)) via BFS from each vertex
  - compute_cycle_rank: O(E α(V))

Type hints and docstrings throughout.
"""

from __future__ import annotations
from collections import defaultdict, deque
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class MorseEvent:
    """A single event in the tropical Morse spectrum."""
    value: float
    event_type: str  # 'merge' or 'cycle'
    edge: tuple[int, int] = (0, 0)

    def __repr__(self) -> str:
        sym = "M" if self.event_type == "merge" else "C"
        return f"({self.value},{sym})"


@dataclass
class TMSpectrum:
    """The tropical Morse spectrum of a weighted graph."""
    events: list[MorseEvent] = field(default_factory=list)
    n_vertices: int = 0
    n_edges: int = 0

    @property
    def merge_count(self) -> int:
        return sum(1 for e in self.events if e.event_type == 'merge')

    @property
    def cycle_count(self) -> int:
        return sum(1 for e in self.events if e.event_type == 'cycle')

    @property
    def beta1(self) -> int:
        """First Betti number = cycle rank = number of cycle events."""
        return self.cycle_count

    @property
    def first_cycle_birth(self) -> Optional[float]:
        """Weight of the first cycle-creating edge."""
        for e in self.events:
            if e.event_type == 'cycle':
                return e.value
        return None

    @property
    def cycle_values(self) -> list[float]:
        """All cycle birth values in order."""
        return [e.value for e in self.events if e.event_type == 'cycle']

    @property
    def critical_values(self) -> list[float]:
        """All distinct critical values."""
        return sorted(set(e.value for e in self.events))

    @property
    def tropical_morse_complexity(self) -> int:
        """Number of distinct critical values."""
        return len(self.critical_values)

    def __repr__(self) -> str:
        return (f"TMSpectrum(V={self.n_vertices}, E={self.n_edges}, "
                f"β₁={self.beta1}, events={self.events})")


@dataclass
class CSSCodeParameters:
    """Parameters of a CSS quantum code extracted from tropical analysis."""
    n_physical: int  # number of physical qubits
    k_logical: int   # number of logical qubits
    d_lower: Optional[float]  # lower bound on distance
    d_exact: Optional[int]    # exact distance (if computable)
    girth: Optional[int]      # graph girth

    @property
    def rate(self) -> float:
        """Code rate k/n."""
        return self.k_logical / self.n_physical if self.n_physical > 0 else 0.0

    def __repr__(self) -> str:
        d = self.d_exact if self.d_exact is not None else f"≥{self.d_lower}"
        return f"[[{self.n_physical}, {self.k_logical}, {d}]]"


class UnionFind:
    """
    Union-Find with path compression and union by rank.

    Time complexity: O(α(n)) amortized per operation,
    where α is the inverse Ackermann function.
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.n_components = n

    def find(self, x: int) -> int:
        """Find root with path compression."""
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        """
        Union by rank. Returns True if merge (different components),
        False if cycle (same component).
        """
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.n_components -= 1
        return True


def compute_tms(
    n_vertices: int,
    edges: list[tuple[int, int, float]]
) -> TMSpectrum:
    """
    Compute the tropical Morse spectrum via Kruskal filtration.

    Algorithm:
      1. Sort edges by weight (ascending).
      2. Process edges in order using Union-Find.
      3. Each edge either merges two components (merge event)
         or creates a cycle (cycle event).

    Args:
        n_vertices: Number of vertices in the graph.
        edges: List of (u, v, weight) tuples.

    Returns:
        TMSpectrum with all Morse events in filtration order.

    Time: O(E log E + E α(V))
    Space: O(V + E)
    """
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n_vertices)
    events = []

    for u, v, w in sorted_edges:
        if uf.union(u, v):
            events.append(MorseEvent(w, 'merge', (u, v)))
        else:
            events.append(MorseEvent(w, 'cycle', (u, v)))

    return TMSpectrum(events, n_vertices, len(edges))


def first_cycle_birth(
    n_vertices: int,
    edges: list[tuple[int, int, float]]
) -> Optional[float]:
    """
    Compute only the first cycle birth value (early termination).

    More efficient than full TMS when only the distance bound is needed.

    Time: O(E log E) worst case, but typically terminates much earlier.
    """
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n_vertices)

    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            return w  # First cycle found!

    return None  # Graph is a forest


def compute_cycle_rank(
    n_vertices: int,
    edges: list[tuple[int, int, float]]
) -> int:
    """
    Compute the cycle rank β₁ = E - V + C where C is the number of
    connected components.

    This equals the number of logical qubits in a graph-CSS model.

    Time: O(E α(V))
    """
    uf = UnionFind(n_vertices)
    for u, v, _ in edges:
        uf.union(u, v)
    components = uf.n_components
    return len(edges) - n_vertices + components


def compute_girth(
    n_vertices: int,
    edges: list[tuple[int, int, float]]
) -> Optional[int]:
    """
    Compute the girth (shortest cycle length) using BFS from each vertex.

    In the unit-weight simple-cycle regime, girth = code distance.

    Time: O(V * (V + E))
    Space: O(V + E)
    """
    adj: dict[int, set[int]] = defaultdict(set)
    for u, v, _ in edges:
        adj[u].add(v)
        adj[v].add(u)

    girth = float('inf')

    for start in range(n_vertices):
        dist: dict[int, int] = {start: 0}
        queue = deque([start])
        while queue:
            u = queue.popleft()
            for v in adj[u]:
                if v not in dist:
                    dist[v] = dist[u] + 1
                    queue.append(v)
                elif dist[v] >= dist[u]:
                    cycle_len = dist[u] + dist[v] + 1
                    girth = min(girth, cycle_len)

    return int(girth) if girth != float('inf') else None


def estimate_code_distance(
    n_vertices: int,
    edges: list[tuple[int, int, float]],
    unit_weights: bool = True
) -> CSSCodeParameters:
    """
    Estimate CSS code parameters from graph structure.

    Combines:
      - β₁ for logical qubits (Theorem 1)
      - First cycle birth for distance lower bound (Theorem 2)
      - Girth for exact distance in unit-weight regime (Theorem 3)

    Args:
        n_vertices: Number of vertices.
        edges: Edge list with weights.
        unit_weights: If True, compute girth for exact distance.

    Returns:
        CSSCodeParameters with all computed values.
    """
    tms = compute_tms(n_vertices, edges)
    k = tms.beta1
    fcb = tms.first_cycle_birth

    girth = None
    d_exact = None
    if unit_weights:
        girth = compute_girth(n_vertices, edges)
        d_exact = girth

    return CSSCodeParameters(
        n_physical=len(edges),
        k_logical=k,
        d_lower=fcb,
        d_exact=d_exact,
        girth=girth
    )


def spectral_classifier(
    n_vertices: int,
    edges: list[tuple[int, int, float]]
) -> dict:
    """
    Classify a graph-CSS code using its tropical Morse spectrum.

    Returns a dictionary of invariants that characterize the code.
    """
    tms = compute_tms(n_vertices, edges)
    girth = compute_girth(n_vertices, edges)

    return {
        'n_vertices': n_vertices,
        'n_edges': len(edges),
        'beta1': tms.beta1,
        'merge_count': tms.merge_count,
        'cycle_count': tms.cycle_count,
        'first_cycle_birth': tms.first_cycle_birth,
        'cycle_values': tms.cycle_values,
        'girth': girth,
        'tropical_morse_complexity': tms.tropical_morse_complexity,
        'critical_values': tms.critical_values,
        'euler_characteristic': n_vertices - len(edges),
    }


# ═══════════════════════════════════════════════════════════
#  Example Usage
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=== Tropical Morse Spectrum Algorithms ===\n")

    # Triangle K₃
    edges_k3 = [(0, 1, 1), (1, 2, 2), (0, 2, 3)]
    tms = compute_tms(3, edges_k3)
    print(f"K₃ (distinct weights): {tms}")
    print(f"  β₁ = {tms.beta1}, fcb = {tms.first_cycle_birth}")
    print(f"  Parameters: {estimate_code_distance(3, edges_k3, unit_weights=False)}")
    print()

    # Petersen graph
    outer = [(i, (i+1) % 5, 1) for i in range(5)]
    inner = [(5+i, 5+(i+2) % 5, 1) for i in range(5)]
    spokes = [(i, i+5, 1) for i in range(5)]
    petersen_edges = outer + inner + spokes
    params = estimate_code_distance(10, petersen_edges)
    print(f"Petersen graph: {params}")
    print(f"  Classification: {spectral_classifier(10, petersen_edges)}")
    print()

    # 3×3 Grid
    grid_edges = []
    for r in range(3):
        for c in range(3):
            if c + 1 < 3:
                grid_edges.append((r*3+c, r*3+c+1, 1))
            if r + 1 < 3:
                grid_edges.append((r*3+c, (r+1)*3+c, 1))
    params = estimate_code_distance(9, grid_edges)
    print(f"3×3 Grid: {params}")
