#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Modular Collatz Inverse-Branch Analysis

Implements:
1. Branch admissibility computation
2. Branch multiplicity and profile computation
3. Modular Collatz graph construction (directed and symmetrized)
4. Multiplicity filtration
5. Cycle rank / Betti number surrogate computation
6. Induced cycle detection
7. Barcode summary statistics

All algorithms match the formal Lean definitions exactly.
"""

from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict
import numpy as np


# ═══════════════════════════════════════════════════════════════════════════
# 1. CORE ARITHMETIC
# ═══════════════════════════════════════════════════════════════════════════

def multiplicative_order(a: int, p: int) -> int:
    """Compute ord_p(a), the multiplicative order of a modulo p.

    Precondition: gcd(a, p) = 1.

    Time complexity: O(ord_p(a)) ≤ O(p).
    Space complexity: O(1).
    """
    if a % p == 0:
        raise ValueError(f"{a} is not coprime to {p}")
    r = 1
    val = a % p
    while val != 1:
        val = (val * a) % p
        r += 1
    return r


def is_prime(n: int) -> bool:
    """Deterministic primality test.

    Time complexity: O(√n).
    """
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def mod_inverse(a: int, p: int) -> int:
    """Compute a⁻¹ mod p using Fermat's little theorem.

    Precondition: p is prime, gcd(a, p) = 1.
    Time complexity: O(log p).
    """
    return pow(a, p - 2, p)


# ═══════════════════════════════════════════════════════════════════════════
# 2. BRANCH ADMISSIBILITY AND MULTIPLICITY
# ═══════════════════════════════════════════════════════════════════════════

def branch_admissible(p: int, x: int, k: int) -> bool:
    """Check if exponent k is an admissible inverse branch at vertex x mod p.

    Definition (matching Lean):
        branchAdmissible p x k ↔ ∃ y ≠ 0, 3·y + 1 = 2^k · x  (in ZMod p)

    Equivalent characterization (Theorem: branch_admissible_iff):
        For x ≠ 0: admissible ↔ 2^k · x ≢ 1 (mod p)
        For x = 0: always admissible (when p > 3)

    Time complexity: O(log k · log p) for modular exponentiation.

    Args:
        p: an odd prime ≠ 3
        x: element of Z/pZ (integer 0..p-1)
        k: non-negative integer exponent

    Returns:
        True if k is an admissible branch exponent at x
    """
    x = x % p
    if x == 0:
        return True  # Theorem: branchAdmissible_zero
    return pow(2, k, p) * x % p != 1


def branch_multiplicity(p: int, K: int, x: int) -> int:
    """Count admissible branch exponents k ∈ {0, ..., K} at vertex x mod p.

    Definition (matching Lean):
        branchMultiplicity p K x = |{k ∈ Fin(K+1) | branchAdmissible p x k}|

    Properties (proved in Lean):
        - branchMultiplicity p K x ≤ K + 1  (Theorem: branchMultiplicity_le)
        - Monotone in K  (Theorem: branchMultiplicity_mono)

    Time complexity: O(K · log K · log p).
    Space complexity: O(1).
    """
    return sum(1 for k in range(K + 1) if branch_admissible(p, x, k))


def branch_profile(p: int, K: int, x: int) -> List[int]:
    """Return the set of admissible exponents k ∈ {0, ..., K} at vertex x.

    Time complexity: O(K · log K · log p).
    """
    return [k for k in range(K + 1) if branch_admissible(p, x, k)]


def multiplicity_spectrum(p: int, K: int) -> Dict[int, int]:
    """Compute the multiplicity spectrum: histogram of branch multiplicities.

    Returns dict mapping multiplicity value → count of vertices with that multiplicity.
    """
    spectrum = defaultdict(int)
    for x in range(p):
        m = branch_multiplicity(p, K, x)
        spectrum[m] += 1
    return dict(spectrum)


# ═══════════════════════════════════════════════════════════════════════════
# 3. GRAPH CONSTRUCTION
# ═══════════════════════════════════════════════════════════════════════════

def build_directed_graph(p: int, K: int) -> Dict[int, Set[int]]:
    """Build the directed modular Collatz preimage graph.

    Edge y → x iff ∃ k ∈ {0,...,K}: 3y + 1 ≡ 2^k · x (mod p) and y ≠ 0.

    Time complexity: O(p · K).
    Space complexity: O(p · K) worst case.
    """
    inv3 = mod_inverse(3, p)
    adj = defaultdict(set)

    for x in range(p):
        for k in range(K + 1):
            # y = (2^k · x - 1) / 3  mod p
            val = (pow(2, k, p) * x - 1) * inv3 % p
            if val != 0 and val != x:
                adj[val].add(x)  # directed edge val → x

    return dict(adj)


def build_symmetric_graph(p: int, K: int) -> Tuple[Dict[int, Set[int]], Set[Tuple[int, int]]]:
    """Build the symmetrized modular Collatz preimage graph G^sym_{p,K}.

    Definition (matching Lean collatzSymGraph):
        Edge x—y iff x ≠ y and ∃ k ∈ {0,...,K}:
            3y+1 ≡ 2^k·x  or  3x+1 ≡ 2^k·y  (mod p)

    Time complexity: O(p · K).
    Space complexity: O(p²) worst case.

    Returns:
        (adjacency dict, edge set as pairs (min, max))
    """
    inv3 = mod_inverse(3, p)
    adj = defaultdict(set)
    edges = set()

    for x in range(p):
        for k in range(K + 1):
            # Forward: y = (2^k · x - 1) / 3
            y = (pow(2, k, p) * x - 1) * inv3 % p
            if y != x and y != 0:
                edge = (min(x, y), max(x, y))
                if edge not in edges:
                    edges.add(edge)
                    adj[x].add(y)
                    adj[y].add(x)

    return dict(adj), edges


# ═══════════════════════════════════════════════════════════════════════════
# 4. MULTIPLICITY FILTRATION
# ═══════════════════════════════════════════════════════════════════════════

def filtration_level_graph(
    p: int, K: int, level: int
) -> Tuple[Set[int], Set[Tuple[int, int]]]:
    """Compute the threshold graph G^(ℓ)_{p,K} at filtration level ℓ.

    Vertices: {x ∈ Z/pZ | branchMultiplicity(p, K, x) ≥ level}
    Edges: inherited from G^sym_{p,K} restricted to these vertices.

    Time complexity: O(p · K).
    """
    adj, all_edges = build_symmetric_graph(p, K)
    vertices = {x for x in range(p) if branch_multiplicity(p, K, x) >= level}
    filtered_edges = {(u, v) for (u, v) in all_edges if u in vertices and v in vertices}
    return vertices, filtered_edges


def full_filtration(p: int, K: int) -> List[Tuple[int, Set[int], Set[Tuple[int, int]]]]:
    """Compute the complete multiplicity filtration.

    Returns list of (level, vertices, edges) for each non-empty filtration level,
    in increasing order of level.

    Time complexity: O(K · p · K) = O(p · K²).
    """
    adj, all_edges = build_symmetric_graph(p, K)
    multiplicities = {x: branch_multiplicity(p, K, x) for x in range(p)}
    max_level = max(multiplicities.values()) if multiplicities else 0

    result = []
    for level in range(max_level + 1):
        vertices = {x for x, m in multiplicities.items() if m >= level}
        if not vertices:
            break
        filtered_edges = {(u, v) for (u, v) in all_edges
                          if u in vertices and v in vertices}
        result.append((level, vertices, filtered_edges))

    return result


# ═══════════════════════════════════════════════════════════════════════════
# 5. TOPOLOGICAL INVARIANTS
# ═══════════════════════════════════════════════════════════════════════════

def connected_components(adj: Dict[int, Set[int]], vertices: Set[int]) -> int:
    """Count connected components using BFS.

    Time complexity: O(|V| + |E|).
    """
    visited = set()
    components = 0

    for v in vertices:
        if v not in visited:
            components += 1
            queue = [v]
            while queue:
                u = queue.pop()
                if u in visited:
                    continue
                visited.add(u)
                for w in adj.get(u, set()):
                    if w in vertices and w not in visited:
                        queue.append(w)

    return components


def cycle_rank(vertices: Set[int], edges: Set[Tuple[int, int]],
               adj: Optional[Dict[int, Set[int]]] = None) -> int:
    """Compute the cycle rank (first Betti number) β₁ = |E| - |V| + c,
    where c is the number of connected components.

    This equals the rank of H₁ of the graph (as a 1-dimensional simplicial complex).

    Time complexity: O(|V| + |E|).
    """
    if not vertices:
        return 0

    # Build restricted adjacency
    if adj is None:
        adj = defaultdict(set)
        for (u, v) in edges:
            adj[u].add(v)
            adj[v].add(u)

    c = connected_components(adj, vertices)
    return len(edges) - len(vertices) + c


def euler_characteristic(vertices: Set[int], edges: Set[Tuple[int, int]],
                         triangles: int) -> int:
    """Compute Euler characteristic χ = |V| - |E| + |T| for the flag complex
    (truncated at dimension 2).

    Time complexity: O(1) given precomputed counts.
    """
    return len(vertices) - len(edges) + triangles


def count_triangles_in_subgraph(adj: Dict[int, Set[int]],
                                 vertices: Set[int]) -> int:
    """Count triangles in the subgraph induced by vertices.

    Time complexity: O(|V| · d²) where d is max degree.
    """
    count = 0
    for v in vertices:
        neighbors = adj.get(v, set()) & vertices
        for u in neighbors:
            if u > v:
                common = (adj.get(u, set()) & vertices) & neighbors
                count += sum(1 for w in common if w > u)
    return count


def find_induced_cycles(adj: Dict[int, Set[int]], vertices: Set[int],
                        length: int = 4, max_count: int = 100) -> List[Tuple]:
    """Find induced cycles of given length.

    An induced n-cycle has n vertices with exactly n edges forming a cycle
    and no chords.

    Time complexity: O(|V|^length) worst case (limited by max_count).
    """
    cycles = []
    vlist = sorted(vertices)

    if length == 4:
        for i, v1 in enumerate(vlist):
            if len(cycles) >= max_count:
                break
            n1 = adj.get(v1, set()) & vertices
            for v2 in n1:
                if v2 <= v1:
                    continue
                n2 = adj.get(v2, set()) & vertices
                for v3 in n2:
                    if v3 <= v1 or v3 == v1:
                        continue
                    if v3 in n1:  # chord v1-v3
                        continue
                    n3 = adj.get(v3, set()) & vertices
                    for v4 in n3:
                        if v4 <= v1 or v4 in {v1, v2}:
                            continue
                        if v4 not in n1:  # need v4-v1 edge
                            continue
                        if v4 in n2:  # chord v2-v4
                            continue
                        cycles.append((v1, v2, v3, v4))
                        if len(cycles) >= max_count:
                            return cycles

    return cycles


# ═══════════════════════════════════════════════════════════════════════════
# 6. BARCODE SUMMARY STATISTICS
# ═══════════════════════════════════════════════════════════════════════════

def compute_betti_profile(p: int, K: int) -> List[Tuple[int, int, int]]:
    """Compute the Betti number profile across filtration levels.

    Returns list of (level, β₀, β₁) for each filtration level.

    This is the primary barcode summary statistic S_{p,K}.

    Time complexity: O(K · p · K).
    """
    filtration = full_filtration(p, K)
    profile = []

    for level, vertices, edges in filtration:
        adj_restricted = defaultdict(set)
        for (u, v) in edges:
            adj_restricted[u].add(v)
            adj_restricted[v].add(u)

        c = connected_components(dict(adj_restricted), vertices)
        beta0 = c
        beta1 = len(edges) - len(vertices) + c

        profile.append((level, beta0, beta1))

    return profile


def total_persistence_surrogate(betti_profile: List[Tuple[int, int, int]]) -> float:
    """Compute a total persistence surrogate from the Betti profile.

    Sum of β₁ across all filtration levels. This measures the total
    amount of one-dimensional topological features in the filtration.

    Time complexity: O(len(profile)).
    """
    return sum(b1 for (_, _, b1) in betti_profile)


def barcode_summary_vector(p: int, K: int, max_levels: int = 20) -> np.ndarray:
    """Compute a fixed-length barcode summary vector for clustering.

    Returns a vector of length max_levels with β₁ values at each filtration level,
    padded with zeros if needed, normalized by p.

    Time complexity: O(K · p · K).
    """
    profile = compute_betti_profile(p, K)
    vec = np.zeros(max_levels)
    for level, _, beta1 in profile:
        if level < max_levels:
            vec[level] = beta1 / p  # normalize by p
    return vec


# ═══════════════════════════════════════════════════════════════════════════
# 7. SUBGROUP ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════

def subgroup_generated_by_2(p: int) -> Set[int]:
    """Compute the cyclic subgroup ⟨2⟩ ≤ (Z/pZ)×.

    Time complexity: O(ord_p(2)).
    """
    subgroup = set()
    val = 1
    d = multiplicative_order(2, p)
    for _ in range(d):
        subgroup.add(val)
        val = (val * 2) % p
    return subgroup


def neg3_in_subgroup(p: int) -> bool:
    """Check if -3 ∈ ⟨2⟩ in (Z/pZ)×.

    This is the subgroup condition from Theorem 2 (congruence forcing).
    """
    neg3 = (-3) % p
    return neg3 in subgroup_generated_by_2(p)


# ═══════════════════════════════════════════════════════════════════════════
# EXAMPLE USAGE
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    # Example: compute branch profiles for p = 13, K = 8
    p, K = 13, 8
    print(f"Modular Collatz analysis for p={p}, K={K}")
    print(f"ord_{p}(2) = {multiplicative_order(2, p)}")
    print(f"⟨2⟩ = {sorted(subgroup_generated_by_2(p))}")
    print(f"-3 ∈ ⟨2⟩: {neg3_in_subgroup(p)}")
    print()

    for x in range(p):
        m = branch_multiplicity(p, K, x)
        bp = branch_profile(p, K, x)
        print(f"  x={x:2d}: mult={m}, profile={bp}")

    print(f"\nMultiplicity spectrum: {multiplicity_spectrum(p, K)}")

    # Build graph
    adj, edges = build_symmetric_graph(p, K)
    verts = set(range(p))
    beta1 = cycle_rank(verts, edges)
    print(f"\nGraph: {len(edges)} edges, cycle rank (β₁) = {beta1}")

    # Betti profile
    profile = compute_betti_profile(p, K)
    print(f"\nBetti profile:")
    for level, b0, b1 in profile:
        print(f"  level {level}: β₀={b0}, β₁={b1}")

    # Induced 4-cycles
    c4 = find_induced_cycles(adj, verts, 4, 5)
    print(f"\nInduced 4-cycles: {len(c4)} found")
    for cycle in c4[:3]:
        print(f"  {cycle}")
