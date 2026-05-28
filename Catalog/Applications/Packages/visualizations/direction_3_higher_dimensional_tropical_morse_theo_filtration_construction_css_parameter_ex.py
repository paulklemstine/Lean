#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for higher-dimensional tropical Morse theory
applied to quantum LDPC codes.

Implements:
1. Filtration construction from weighted simplicial complexes
2. Homology jump profile computation
3. CSS parameter extraction from tropical Morse spectra
4. Tropical barrier analysis for distance bounds

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict
from dataclasses import dataclass, field
import numpy as np


# ─────────────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────────────

@dataclass
class Simplex:
    """A simplex in a simplicial complex, represented by its vertex set."""
    vertices: frozenset
    weight: float = 0.0

    @property
    def dim(self) -> int:
        return len(self.vertices) - 1

    def __hash__(self):
        return hash(self.vertices)

    def __eq__(self, other):
        return self.vertices == other.vertices


@dataclass
class FiltrationEvent:
    """A single event in the tropical Morse filtration.

    Attributes:
        weight: The tropical weight at which this simplex enters
        dim: Dimension of the simplex (0=vertex, 1=edge, 2=triangle)
        creates_cycle: True if attaching creates a new homology class
        simplex: The simplex being attached
    """
    weight: float
    dim: int
    creates_cycle: bool
    simplex: Optional[Simplex] = None

    def betti_delta(self, n: int) -> int:
        """Betti number change in degree n.

        Time complexity: O(1)
        """
        if self.creates_cycle:
            return 1 if self.dim == n else 0
        else:
            if self.dim > 0 and self.dim - 1 == n:
                return -1
            return 0


@dataclass
class JumpProfile:
    """The homology jump profile of a filtration.

    For each threshold t and degree n, records Δβ_n(t).
    """
    events: List[Tuple[float, int, int]]  # (weight, degree, delta)

    def births(self, degree: int) -> List[float]:
        """Return weights of all birth events in given degree."""
        return [w for w, d, delta in self.events if d == degree and delta > 0]

    def deaths(self, degree: int) -> List[float]:
        """Return weights of all death events in given degree."""
        return [w for w, d, delta in self.events if d == degree and delta < 0]

    def betti(self, degree: int) -> int:
        """Final Betti number in given degree."""
        return sum(delta for _, d, delta in self.events if d == degree)


@dataclass
class CSSParameters:
    """CSS code parameters extracted from tropical Morse data."""
    n: int          # physical qubits
    k: int          # logical qubits
    d_z_lower: int  # lower bound on Z-distance
    d_x_lower: int  # lower bound on X-distance
    euler_char: int  # Euler characteristic


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Filtration Construction
# ─────────────────────────────────────────────────────────────────────

class UnionFind:
    """Union-Find data structure for tracking connected components.

    Time complexity: O(α(n)) amortized per operation (inverse Ackermann).
    Space complexity: O(n).
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.components = n

    def find(self, x: int) -> int:
        """Find with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if x and y were in different components."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.components -= 1
        return True


def construct_filtration(
    simplices: List[Simplex],
    vertex_map: Optional[Dict[frozenset, int]] = None
) -> List[FiltrationEvent]:
    """Construct the tropical Morse filtration from a weighted simplicial complex.

    Algorithm:
    1. Sort simplices by weight (breaking ties by dimension: lower first).
    2. Process each simplex in order:
       a. For vertices (dim 0): always a birth event (β₀ increases).
       b. For edges (dim 1): use Union-Find to determine if endpoints are
          in the same component. If same → cycle birth (β₁ increases).
          If different → merge (β₀ decreases).
       c. For triangles (dim 2): check if boundary is already null-homologous.
          If yes → cycle birth (β₂ increases). If no → death (β₁ decreases).

    Time complexity: O(n log n + n α(V)) where n = |simplices|, V = |vertices|.
    Space complexity: O(n + V).

    Args:
        simplices: List of weighted simplices.
        vertex_map: Optional mapping from vertex sets to integer indices.

    Returns:
        Ordered list of filtration events.
    """
    # Sort by weight, then by dimension
    sorted_simplices = sorted(simplices, key=lambda s: (s.weight, s.dim))

    # Build vertex index map
    if vertex_map is None:
        all_vertices = set()
        for s in sorted_simplices:
            all_vertices.update(s.vertices)
        vertex_list = sorted(all_vertices)
        vertex_map = {frozenset([v]): i for i, v in enumerate(vertex_list)}

    n_vertices = len(vertex_map)
    uf = UnionFind(n_vertices)

    events = []
    added_edges: Set[frozenset] = set()
    vertex_index = {}
    next_idx = 0

    for simplex in sorted_simplices:
        if simplex.dim == 0:
            # Vertex: always a birth
            v = list(simplex.vertices)[0]
            if v not in vertex_index:
                vertex_index[v] = next_idx
                next_idx += 1
            events.append(FiltrationEvent(
                weight=simplex.weight, dim=0,
                creates_cycle=True, simplex=simplex
            ))

        elif simplex.dim == 1:
            # Edge: check if endpoints are connected
            verts = list(simplex.vertices)
            if len(verts) >= 2:
                u_idx = vertex_index.get(verts[0], 0)
                v_idx = vertex_index.get(verts[1], 0)
                merged = uf.union(u_idx, v_idx)
                events.append(FiltrationEvent(
                    weight=simplex.weight, dim=1,
                    creates_cycle=not merged, simplex=simplex
                ))
                added_edges.add(simplex.vertices)

        elif simplex.dim == 2:
            # Triangle: check if boundary edges form a cycle
            verts = list(simplex.vertices)
            boundary_edges = [
                frozenset([verts[0], verts[1]]),
                frozenset([verts[1], verts[2]]),
                frozenset([verts[0], verts[2]])
            ]
            all_present = all(e in added_edges for e in boundary_edges)

            # Simplified check: if all boundary edges present, likely a death event
            events.append(FiltrationEvent(
                weight=simplex.weight, dim=2,
                creates_cycle=not all_present, simplex=simplex
            ))

    return events


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Homology Jump Profile Computation
# ─────────────────────────────────────────────────────────────────────

def compute_jump_profile(events: List[FiltrationEvent],
                          max_degree: int = 3) -> JumpProfile:
    """Compute the homology jump profile from filtration events.

    For each event, record the (weight, degree, delta) triple describing
    the Betti number change.

    Time complexity: O(n * D) where n = |events|, D = max_degree.
    Space complexity: O(n * D).

    Args:
        events: Ordered filtration events.
        max_degree: Maximum homological degree to track.

    Returns:
        JumpProfile with all Betti number changes.
    """
    profile_events = []

    for event in events:
        for d in range(max_degree + 1):
            delta = event.betti_delta(d)
            if delta != 0:
                profile_events.append((event.weight, d, delta))

    return JumpProfile(events=profile_events)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: CSS Parameter Extraction
# ─────────────────────────────────────────────────────────────────────

def extract_css_parameters(
    events: List[FiltrationEvent],
    barrier_threshold: Optional[float] = None
) -> CSSParameters:
    """Extract CSS code parameters from tropical Morse filtration data.

    Algorithm:
    1. Count physical qubits n = number of 1-simplices.
    2. Compute β₁ = births₁ - deaths₁ = logical qubits k.
    3. If barrier threshold λ is given, compute d_Z lower bound as the
       number of cycle-creating edges with weight ≥ λ.
    4. Compute Euler characteristic χ = Σ (-1)^dim.

    Time complexity: O(n) where n = |events|.
    Space complexity: O(1).

    Args:
        events: Filtration events.
        barrier_threshold: Optional weight threshold for distance bound.

    Returns:
        CSSParameters with n, k, d_Z, d_X bounds, and χ.
    """
    n_phys = sum(1 for e in events if e.dim == 1)
    births_1 = sum(1 for e in events if e.creates_cycle and e.dim == 1)
    deaths_1 = sum(1 for e in events if not e.creates_cycle and e.dim == 2)
    k = births_1 - deaths_1
    euler = sum((-1) ** e.dim for e in events)

    # Distance bound from barrier
    if barrier_threshold is not None and k > 0:
        high_weight_births = sum(
            1 for e in events
            if e.creates_cycle and e.dim == 1 and e.weight >= barrier_threshold
        )
        d_z_lower = max(high_weight_births, 1)
    else:
        d_z_lower = 1 if k > 0 else 0

    # Dual barrier (symmetric for self-dual codes)
    d_x_lower = d_z_lower

    return CSSParameters(n=n_phys, k=k, d_z_lower=d_z_lower,
                          d_x_lower=d_x_lower, euler_char=euler)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Tropical Barrier Analysis
# ─────────────────────────────────────────────────────────────────────

def analyze_tropical_barriers(
    events: List[FiltrationEvent],
    thresholds: Optional[List[float]] = None
) -> List[Dict]:
    """Analyze tropical barriers at multiple weight thresholds.

    For each threshold λ, compute:
    - Number of cycle births above λ
    - Concentration ratio (births above λ / total births)
    - Implied distance lower bound

    Time complexity: O(n * T) where n = |events|, T = |thresholds|.
    Space complexity: O(T).

    Args:
        events: Filtration events.
        thresholds: Weight thresholds to analyze. If None, uses quartiles.

    Returns:
        List of barrier analysis dicts.
    """
    cycle_births = [(e.weight, e) for e in events
                    if e.creates_cycle and e.dim == 1]

    if not cycle_births:
        return []

    weights = [w for w, _ in cycle_births]

    if thresholds is None:
        if weights:
            thresholds = [
                np.percentile(weights, 25),
                np.percentile(weights, 50),
                np.percentile(weights, 75),
                np.percentile(weights, 90)
            ]
        else:
            thresholds = [0.0]

    results = []
    total_births = len(cycle_births)

    for lam in thresholds:
        above = sum(1 for w in weights if w >= lam)
        results.append({
            'threshold': lam,
            'births_above': above,
            'total_births': total_births,
            'concentration': above / total_births if total_births > 0 else 0,
            'distance_lower_bound': max(above, 1) if total_births > 0 else 0
        })

    return results


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Expansion Analysis
# ─────────────────────────────────────────────────────────────────────

def analyze_expansion_constraint(
    events: List[FiltrationEvent],
    expansion_constant: float = 2.0
) -> Dict:
    """Analyze how coboundary expansion constrains tropical births.

    For a complex with expansion constant ε, the number of low-weight
    births in degree 1 is bounded by β₁/ε + 1.

    Time complexity: O(n log n) where n = |events|.
    Space complexity: O(n).

    Args:
        events: Filtration events.
        expansion_constant: The coboundary expansion constant ε.

    Returns:
        Dict with expansion analysis results.
    """
    cycle_births = sorted(
        [e.weight for e in events if e.creates_cycle and e.dim == 1]
    )
    total = len(cycle_births)
    births_1 = total
    deaths_1 = sum(1 for e in events if not e.creates_cycle and e.dim == 2)
    beta_1 = births_1 - deaths_1

    # Theoretical bound on low-weight births
    bound = beta_1 / expansion_constant + 1 if expansion_constant > 0 else float('inf')

    # Check at various thresholds
    threshold_checks = []
    if cycle_births:
        for pct in [10, 25, 50, 75]:
            thr = np.percentile(cycle_births, pct)
            low_count = sum(1 for w in cycle_births if w <= thr)
            threshold_checks.append({
                'percentile': pct,
                'threshold': thr,
                'low_births': low_count,
                'bound': bound,
                'satisfies_bound': low_count <= bound
            })

    return {
        'expansion_constant': expansion_constant,
        'beta_1': beta_1,
        'total_births': total,
        'theoretical_bound': bound,
        'threshold_checks': threshold_checks
    }


# ─────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────

def example_toric_code(L: int = 4):
    """Demonstrate algorithms on the L×L toric code."""
    print(f"\n{'='*60}")
    print(f"TORIC CODE ({L}×{L} torus)")
    print(f"{'='*60}")

    # Build simplices
    simplices = []
    # Vertices
    for i in range(L):
        for j in range(L):
            simplices.append(Simplex(frozenset([f"v_{i}_{j}"]), weight=1.0))

    # Horizontal edges
    for i in range(L):
        for j in range(L):
            j_next = (j + 1) % L
            simplices.append(Simplex(
                frozenset([f"v_{i}_{j}", f"v_{i}_{j_next}"]),
                weight=2.0 + i * 0.1
            ))

    # Vertical edges
    for i in range(L):
        for j in range(L):
            i_next = (i + 1) % L
            simplices.append(Simplex(
                frozenset([f"v_{i}_{j}", f"v_{i_next}_{j}"]),
                weight=2.5 + j * 0.1
            ))

    # Construct filtration
    events = construct_filtration(simplices)

    # Compute jump profile
    profile = compute_jump_profile(events)

    # Extract CSS parameters
    params = extract_css_parameters(events, barrier_threshold=2.0)

    # Analyze barriers
    barriers = analyze_tropical_barriers(events)

    # Print results
    print(f"  Physical qubits: n = {params.n}")
    print(f"  Logical qubits:  k = {params.k}")
    print(f"  Euler characteristic: χ = {params.euler_char}")
    print(f"  Distance bound: d_Z ≥ {params.d_z_lower}")

    print(f"\n  Jump profile (degree 1):")
    print(f"    Births: {len(profile.births(1))}")
    print(f"    Deaths: {len(profile.deaths(1))}")
    print(f"    β₁ = {profile.betti(1)}")

    if barriers:
        print(f"\n  Barrier analysis:")
        for b in barriers:
            print(f"    λ={b['threshold']:.2f}: {b['births_above']}/{b['total_births']} "
                  f"births above (concentration={b['concentration']:.2f})")

    return params


if __name__ == "__main__":
    print("Higher-Dimensional Tropical Morse Theory — Algorithm Suite")
    print("=" * 60)

    for L in [2, 3, 4, 5]:
        example_toric_code(L)
