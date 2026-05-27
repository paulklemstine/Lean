#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Sheaf-Theoretic Tropical Persistence

Implements the computational methods underlying the formal theorems:
1. Critical stratification computation
2. Stalk/rank data computation
3. Cumulative sheaf jump computation
4. Constructibility verification
5. Stability bound computation

Complexity analysis:
- Critical values: O(n log n) where n = |V|
- Sheaf jump at c: O(n) per critical value
- Full sheaf profile: O(n²) worst case, O(n · k) where k = |critical values|
- Stability check: O(n · k · T) where T = number of test thresholds
"""

from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass
import math


# ===========================================================================
# Data Structures
# ===========================================================================

@dataclass
class GraphData:
    """Adjacency-list representation of a simple graph."""
    n: int
    adj: Dict[int, Set[int]]

    def degree(self, v: int) -> int:
        return len(self.adj.get(v, set()))

    def vertices(self) -> range:
        return range(self.n)

    @classmethod
    def from_edges(cls, n: int, edges: List[Tuple[int, int]]) -> 'GraphData':
        adj = {i: set() for i in range(n)}
        for u, v in edges:
            if u != v:
                adj[u].add(v)
                adj[v].add(u)
        return cls(n=n, adj=adj)


@dataclass
class FiltrationData:
    """Vertex filtration: entrance time for each vertex."""
    times: List[float]

    def __call__(self, v: int) -> float:
        return self.times[v]

    def n(self) -> int:
        return len(self.times)


@dataclass
class SheafData:
    """Complete sheaf data for a tropical filtration."""
    critical_values: List[float]          # sorted critical thresholds
    jumps: Dict[float, int]               # sheaf jump at each critical value
    degree0_jumps: Dict[float, int]       # vertex-count jumps
    degree1_jumps: Dict[float, int]       # edge-density jumps
    stalk_ranks: Dict[float, int]         # rank at each critical value
    euler_char: int                       # total Euler characteristic


# ===========================================================================
# Algorithm 1: Critical Stratification
# ===========================================================================

def compute_critical_values(f: FiltrationData) -> List[float]:
    """
    Compute the sorted list of critical values for a vertex filtration.

    Time: O(n log n)
    Space: O(n)

    Returns: Sorted list of distinct entrance times.
    """
    return sorted(set(f.times))


# ===========================================================================
# Algorithm 2: Active Vertex Set
# ===========================================================================

def compute_active_vertices(f: FiltrationData, t: float) -> List[int]:
    """
    Compute the set of active vertices at threshold t.

    Time: O(n)
    Space: O(n)

    Returns: List of vertices v with f(v) ≤ t.
    """
    return [v for v in range(f.n()) if f(v) <= t]


# ===========================================================================
# Algorithm 3: Sheaf Jump Computation
# ===========================================================================

def compute_sheaf_jump(G: GraphData, f: FiltrationData, c: float) -> int:
    """
    Compute the sheaf jump at critical value c.

    sheafJump(c) = Σ_{v: f(v)=c} (degree(v) + 1)

    Time: O(n)
    Space: O(1)
    """
    return sum(G.degree(v) + 1 for v in range(G.n) if f(v) == c)


def compute_vertex_jump(f: FiltrationData, c: float) -> int:
    """Compute the degree-0 (vertex count) jump at c."""
    return sum(1 for v in range(f.n()) if f(v) == c)


def compute_degree1_jump(G: GraphData, f: FiltrationData, c: float) -> int:
    """Compute the degree-1 (edge density) jump at c."""
    return compute_sheaf_jump(G, f, c) - compute_vertex_jump(f, c)


# ===========================================================================
# Algorithm 4: Full Sheaf Data Construction
# ===========================================================================

def construct_sheaf(G: GraphData, f: FiltrationData) -> SheafData:
    """
    Construct the complete tropical rank sheaf data.

    This is the main algorithm: it computes the full constructible sheaf
    structure from a graph and filtration.

    Time: O(n · k) where k = number of distinct critical values
    Space: O(n + k)

    The algorithm:
    1. Compute critical values (O(n log n))
    2. For each critical value, compute jumps (O(n) each)
    3. Compute cumulative stalk ranks (O(k))
    4. Compute Euler characteristic (O(k))
    """
    crits = compute_critical_values(f)

    jumps = {}
    d0_jumps = {}
    d1_jumps = {}

    for c in crits:
        jumps[c] = compute_sheaf_jump(G, f, c)
        d0_jumps[c] = compute_vertex_jump(f, c)
        d1_jumps[c] = jumps[c] - d0_jumps[c]

    # Cumulative stalk ranks
    stalk_ranks = {}
    cumulative = 0
    for c in crits:
        cumulative += jumps[c]
        stalk_ranks[c] = cumulative

    euler_char = sum(jumps.values())

    return SheafData(
        critical_values=crits,
        jumps=jumps,
        degree0_jumps=d0_jumps,
        degree1_jumps=d1_jumps,
        stalk_ranks=stalk_ranks,
        euler_char=euler_char
    )


# ===========================================================================
# Algorithm 5: Sheaf Event Profile
# ===========================================================================

def compute_sheaf_profile(sheaf: SheafData, t: float) -> int:
    """
    Compute the sheaf event profile at threshold t.

    SheafEventProfile(t) = Σ_{c ≤ t} sheafJump(c)

    This equals the tropical event profile (Theorem 2).

    Time: O(k) where k = |critical values|
    Space: O(1)
    """
    return sum(sheaf.jumps[c] for c in sheaf.critical_values if c <= t)


# ===========================================================================
# Algorithm 6: Constructibility Verification
# ===========================================================================

def verify_constructibility(G: GraphData, f: FiltrationData,
                           num_samples: int = 10) -> bool:
    """
    Verify that the tropical rank sheaf is constructible:
    rank is constant between consecutive critical values.

    Time: O(n · k · num_samples)

    Returns: True if constructibility holds for all sampled points.
    """
    crits = compute_critical_values(f)

    for i in range(len(crits) - 1):
        c_lo = crits[i]
        c_hi = crits[i + 1]

        # Sample points in the gap (c_lo, c_hi)
        ranks_in_gap = set()
        for j in range(1, num_samples + 1):
            t = c_lo + j * (c_hi - c_lo) / (num_samples + 1)
            r = sum(G.degree(v) + 1 for v in compute_active_vertices(f, t))
            ranks_in_gap.add(r)

        if len(ranks_in_gap) > 1:
            return False

    return True


# ===========================================================================
# Algorithm 7: Stability Bound Computation
# ===========================================================================

def compute_stability_bound(G: GraphData, f: FiltrationData,
                           g: FiltrationData) -> Tuple[float, float]:
    """
    Compute the filtration sup-distance and verify the stability bound.

    Returns: (sup_distance, max_observed_profile_difference)

    The theorem guarantees:
        |SheafProfile_f(t) - SheafProfile_g(t)| is controlled by sup_distance
    """
    assert f.n() == g.n() == G.n

    sup_dist = max(abs(f(v) - g(v)) for v in range(G.n))

    sheaf_f = construct_sheaf(G, f)
    sheaf_g = construct_sheaf(G, g)

    # Check interleaving at a fine grid
    all_crits = sorted(set(sheaf_f.critical_values + sheaf_g.critical_values))
    t_min = min(all_crits) - 1 if all_crits else 0
    t_max = max(all_crits) + 1 if all_crits else 1

    max_diff = 0
    num_points = 100
    for i in range(num_points + 1):
        t = t_min + i * (t_max - t_min) / num_points
        pf = compute_sheaf_profile(sheaf_f, t)
        pg = compute_sheaf_profile(sheaf_g, t)
        max_diff = max(max_diff, abs(pf - pg))

    return sup_dist, max_diff


# ===========================================================================
# Algorithm 8: Interleaving Verification
# ===========================================================================

def verify_interleaving(G: GraphData, f: FiltrationData,
                       g: FiltrationData, epsilon: float,
                       num_points: int = 200) -> bool:
    """
    Verify the ε-interleaving of sheaf profiles (Theorem 3).

    For all t:
        SheafProfile_f(t) ≤ SheafProfile_g(t + ε)
        SheafProfile_g(t) ≤ SheafProfile_f(t + ε)

    Time: O(n · k · num_points)
    """
    sheaf_f = construct_sheaf(G, f)
    sheaf_g = construct_sheaf(G, g)

    all_crits = sorted(set(sheaf_f.critical_values + sheaf_g.critical_values))
    t_min = min(all_crits) - 2 if all_crits else -2
    t_max = max(all_crits) + 2 if all_crits else 2

    for i in range(num_points + 1):
        t = t_min + i * (t_max - t_min) / num_points
        pf = compute_sheaf_profile(sheaf_f, t)
        pg = compute_sheaf_profile(sheaf_g, t)
        pf_shift = compute_sheaf_profile(sheaf_f, t + epsilon)
        pg_shift = compute_sheaf_profile(sheaf_g, t + epsilon)

        if pf > pg_shift or pg > pf_shift:
            return False

    return True


# ===========================================================================
# Graph Constructors
# ===========================================================================

def make_path_graph(n: int) -> GraphData:
    """Path graph P_n."""
    return GraphData.from_edges(n, [(i, i+1) for i in range(n-1)])


def make_cycle_graph(n: int) -> GraphData:
    """Cycle graph C_n."""
    return GraphData.from_edges(n, [(i, (i+1) % n) for i in range(n)])


def make_natural_filtration(n: int) -> FiltrationData:
    """Natural filtration: vertex i enters at time i."""
    return FiltrationData([float(i) for i in range(n)])


# ===========================================================================
# Example Usage
# ===========================================================================

if __name__ == "__main__":
    print("Sheaf-Theoretic Tropical Persistence — Algorithm Suite")
    print("=" * 60)

    # Path graph example
    n = 6
    G = make_path_graph(n)
    f = make_natural_filtration(n)

    print(f"\nPath graph P_{n}:")
    sheaf = construct_sheaf(G, f)
    print(f"  Critical values: {sheaf.critical_values}")
    print(f"  Sheaf jumps: {sheaf.jumps}")
    print(f"  Degree-0 jumps: {sheaf.degree0_jumps}")
    print(f"  Degree-1 jumps: {sheaf.degree1_jumps}")
    print(f"  Euler characteristic: {sheaf.euler_char}")
    print(f"  Constructible: {verify_constructibility(G, f)}")

    # Stability test
    import random
    random.seed(42)
    eps = 0.5
    g = FiltrationData([f(v) + random.uniform(-eps, eps) for v in range(n)])
    sup_d, max_diff = compute_stability_bound(G, f, g)
    print(f"\n  Stability test (ε={eps}):")
    print(f"    Sup distance: {sup_d:.4f}")
    print(f"    Max profile difference: {max_diff}")
    print(f"    Interleaving holds: {verify_interleaving(G, f, g, sup_d)}")

    # Cycle graph example
    G_c = make_cycle_graph(n)
    sheaf_c = construct_sheaf(G_c, f)
    print(f"\nCycle graph C_{n}:")
    print(f"  Sheaf jumps: {sheaf_c.jumps}")
    print(f"  Euler characteristic: {sheaf_c.euler_char}")
    print(f"  Constructible: {verify_constructibility(G_c, f)}")
