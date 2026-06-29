#!/usr/bin/env python3
"""
Algorithms for Compositional Phase Gauge Systems

Implements:
1. Exact partition function computation
2. Product system factorization algorithm
3. Gauge orbit enumeration
4. Triangle-free plaquette verification
5. Mantel bound checker

All algorithms have documented complexity and correctness guarantees
tied to the formally verified theorems.
"""

import itertools
import numpy as np
from typing import List, Tuple, Dict, Set, Optional, Callable
from collections import defaultdict


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: Exact Partition Function
# ──────────────────────────────────────────────────────────────────

def exact_partition_function(
    n_group: int,
    edges: List[str],
    plaquettes: List[str],
    holonomy_fn: Callable,
    phase_fn: Callable
) -> complex:
    """
    Compute the exact partition function Z = sum_A prod_p phase(hol(A,p)).

    Parameters:
        n_group: Order of the gauge group Z/nZ
        edges: List of edge labels
        plaquettes: List of plaquette labels
        holonomy_fn: (config, plaquette) -> group element (int mod n)
        phase_fn: group element (int) -> complex number

    Returns:
        Z: The partition function value

    Complexity:
        Time: O(|G|^|E| · |P|) where |G|=n_group, |E|=len(edges), |P|=len(plaquettes)
        Space: O(|E|)

    Correctness: Directly implements the definition
        Z = sum_{A in (E -> G)} prod_{p in P} phase(holonomy(A, p))
    """
    Z = 0.0 + 0j
    for config_vals in itertools.product(range(n_group), repeat=len(edges)):
        config = dict(zip(edges, config_vals))
        weight = 1.0 + 0j
        for p in plaquettes:
            hol = holonomy_fn(config, p)
            weight *= phase_fn(hol)
        Z += weight
    return Z


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Factorized Partition Function
# ──────────────────────────────────────────────────────────────────

def factorized_partition_function(
    n_group1: int,
    n_group2: int,
    edges: List[str],
    plaquettes: List[str],
    holonomy_fn: Callable,
    phase_fn1: Callable,
    phase_fn2: Callable
) -> Tuple[complex, complex, complex]:
    """
    Compute partition functions using the factorization theorem:
    Z(S1 x S2) = Z(S1) * Z(S2)

    Instead of enumerating |G1|^|E| * |G2|^|E| configurations of the
    product system, we compute Z(S1) and Z(S2) independently.

    Parameters:
        n_group1, n_group2: Orders of component gauge groups
        edges, plaquettes: Lattice structure
        holonomy_fn: Holonomy computation
        phase_fn1, phase_fn2: Phase maps for each component

    Returns:
        (Z1, Z2, Z_product): Component and product partition functions

    Complexity:
        Naive product: O((|G1|·|G2|)^|E| · |P|)
        Factorized:    O(|G1|^|E| · |P| + |G2|^|E| · |P|)
        Speedup ratio: (|G1|·|G2|)^|E| / (|G1|^|E| + |G2|^|E|)

    Correctness: Guaranteed by Theorem `partitionFunction_prod`
    """
    Z1 = exact_partition_function(n_group1, edges, plaquettes, holonomy_fn, phase_fn1)
    Z2 = exact_partition_function(n_group2, edges, plaquettes, holonomy_fn, phase_fn2)
    return Z1, Z2, Z1 * Z2


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: Gauge Orbit Enumeration
# ──────────────────────────────────────────────────────────────────

def enumerate_gauge_orbits(
    n_group: int,
    vertices: List[int],
    edges: List[Tuple[int, int]],
    plaquettes: List[List[Tuple[int, int]]],
) -> Dict[Tuple, List[Dict]]:
    """
    Enumerate gauge orbits: partition configurations by their
    holonomy data (which is gauge-invariant by our theorem).

    Parameters:
        n_group: Order of gauge group Z/nZ
        vertices: Vertex labels
        edges: Edge list as (source, target) pairs
        plaquettes: Each plaquette is a list of (edge_index, orientation) pairs

    Returns:
        Dictionary mapping holonomy tuples to lists of configs in that orbit

    Complexity:
        Time: O(|G|^|E| · |P|)
        Space: O(|G|^|E|) (stores all configs)

    Correctness: By `totalWeight_gauge_invariant`, all configs in the same
    orbit have identical total weight, so the partition function can be
    computed as Z = sum_{orbits} |orbit| * weight(representative).
    """
    orbits = defaultdict(list)
    edge_labels = list(range(len(edges)))

    for config_vals in itertools.product(range(n_group), repeat=len(edges)):
        config = dict(zip(edge_labels, config_vals))

        # Compute holonomy signature
        hol_signature = []
        for plaq in plaquettes:
            hol = 0
            for edge_idx, orient in plaq:
                g = config[edge_idx]
                if orient == -1:
                    g = (-g) % n_group
                hol = (hol + g) % n_group
            hol_signature.append(hol)

        orbits[tuple(hol_signature)].append(config)

    return dict(orbits)


# ──────────────────────────────────────────────────────────────────
# Algorithm 4: Triangle-Free Plaquette Verification
# ──────────────────────────────────────────────────────────────────

def verify_triangle_free_plaquettes(
    n_vertices: int,
    edges: List[Tuple[int, int]],
    plaquettes: List[Tuple[int, int, int]]
) -> Tuple[bool, List[Tuple[int, int, int]]]:
    """
    Verify that all plaquettes in a triangle-free graph are non-triangular.

    Parameters:
        n_vertices: Number of vertices
        edges: Edge list
        plaquettes: List of triangular plaquettes (a, b, c)

    Returns:
        (is_triangle_free, violating_plaquettes):
        - is_triangle_free: True if the graph has no triangles
        - violating_plaquettes: plaquettes that ARE triangular (should be empty)

    Complexity:
        Time: O(|E| + |P| + n^3) for triangle detection
        Space: O(n^2) for adjacency matrix

    Correctness: Implements `triangle_free_no_triangular_plaquettes'`
    """
    # Build adjacency
    adj = [[False] * n_vertices for _ in range(n_vertices)]
    for u, v in edges:
        adj[u][v] = True
        adj[v][u] = True

    # Check triangle-free
    triangles = []
    for a in range(n_vertices):
        for b in range(a + 1, n_vertices):
            if adj[a][b]:
                for c in range(b + 1, n_vertices):
                    if adj[b][c] and adj[a][c]:
                        triangles.append((a, b, c))

    is_triangle_free = len(triangles) == 0

    # Check plaquettes
    violating = []
    for a, b, c in plaquettes:
        if adj[a][b] and adj[b][c] and adj[a][c]:
            violating.append((a, b, c))

    return is_triangle_free, violating


# ──────────────────────────────────────────────────────────────────
# Algorithm 5: Mantel Bound Checker
# ──────────────────────────────────────────────────────────────────

def check_mantel_bound(
    n_vertices: int,
    edges: List[Tuple[int, int]],
    check_triangle_free: bool = True
) -> Dict:
    """
    Check the Mantel bound: triangle-free graphs have ≤ n²/4 edges.

    Parameters:
        n_vertices: Number of vertices
        edges: Edge list
        check_triangle_free: Whether to verify triangle-freeness

    Returns:
        Dictionary with bound analysis

    Complexity: O(n^3) for triangle check, O(1) for bound check
    Correctness: Implements `mantel_bound_limits_plaquettes'`
    """
    n_edges = len(edges)
    mantel_bound = n_vertices ** 2 // 4

    result = {
        'n_vertices': n_vertices,
        'n_edges': n_edges,
        'mantel_bound': mantel_bound,
        'satisfies_bound': n_edges <= mantel_bound,
        '4e_le_n2': 4 * n_edges <= n_vertices ** 2,
    }

    if check_triangle_free:
        is_tf, _ = verify_triangle_free_plaquettes(n_vertices, edges, [])
        result['is_triangle_free'] = is_tf
        if is_tf:
            result['theorem_applies'] = True
            result['bound_valid'] = 4 * n_edges <= n_vertices ** 2

    return result


# ──────────────────────────────────────────────────────────────────
# Algorithm 6: Speedup Calculator
# ──────────────────────────────────────────────────────────────────

def compute_factorization_speedup(
    n_group1: int,
    n_group2: int,
    n_edges: int
) -> Dict:
    """
    Compute the computational speedup from partition function factorization.

    The naive approach enumerates (|G1|·|G2|)^|E| product configurations.
    The factorized approach enumerates |G1|^|E| + |G2|^|E| configurations.

    Returns:
        Dictionary with complexity comparison

    Correctness: Direct consequence of `partitionFunction_prod`
    """
    naive = (n_group1 * n_group2) ** n_edges
    factorized = n_group1 ** n_edges + n_group2 ** n_edges
    speedup = naive / factorized if factorized > 0 else float('inf')

    return {
        'n_group1': n_group1,
        'n_group2': n_group2,
        'n_edges': n_edges,
        'naive_configs': naive,
        'factorized_configs': factorized,
        'speedup_ratio': speedup,
        'log10_speedup': np.log10(speedup) if speedup > 0 else 0,
    }


if __name__ == "__main__":
    print("Algorithms module — run demo.py for demonstrations")

    # Quick test of speedup calculation
    for n1, n2, ne in [(2, 3, 4), (3, 5, 6), (5, 7, 10)]:
        result = compute_factorization_speedup(n1, n2, ne)
        print(f"\nZ/{n1}Z × Z/{n2}Z, {ne} edges:")
        print(f"  Naive:      {result['naive_configs']:>15,} configs")
        print(f"  Factorized: {result['factorized_configs']:>15,} configs")
        print(f"  Speedup:    {result['speedup_ratio']:>15,.1f}x")
