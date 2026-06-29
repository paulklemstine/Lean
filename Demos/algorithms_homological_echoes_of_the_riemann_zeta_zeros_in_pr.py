#!/usr/bin/env python3
"""
Prime Window Complex: Core Algorithms

Implements the algorithms for constructing prime gap graphs, computing
topological invariants, and analyzing the arithmetic-topological dictionary.

Each algorithm includes complexity analysis and docstrings.
"""

import math
from collections import defaultdict
from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 1: Prime Sieve for Windows
# ─────────────────────────────────────────────────────────────────────────────

def segmented_sieve(n: int, L: int) -> List[int]:
    """
    Compute primes in the interval [n, n+L-1] using a segmented sieve.
    
    Time: O(L log log(n+L) + √(n+L))
    Space: O(L + √(n+L))
    
    Args:
        n: Start of interval
        L: Length of interval
        
    Returns:
        Sorted list of primes in [n, n+L-1]
    
    Example:
        >>> segmented_sieve(10, 20)
        [11, 13, 17, 19, 23, 29]
    """
    if L <= 0:
        return []
    
    upper = n + L - 1
    sqrt_upper = int(math.isqrt(upper)) + 1
    
    # Small primes via standard sieve
    is_small_prime = [True] * (sqrt_upper + 1)
    is_small_prime[0] = is_small_prime[1] = False
    for i in range(2, int(math.isqrt(sqrt_upper)) + 1):
        if is_small_prime[i]:
            for j in range(i*i, sqrt_upper + 1, i):
                is_small_prime[j] = False
    small_primes = [i for i in range(2, sqrt_upper + 1) if is_small_prime[i]]
    
    # Segmented sieve for [n, n+L-1]
    is_prime_segment = [True] * L
    for p in small_primes:
        start = max(p * p, n + (-n % p)) - n
        if n <= p <= upper:
            start = p - n + p  # skip p itself
        for j in range(max(0, start), L, p):
            is_prime_segment[j] = False
    
    # Handle edge cases
    if n <= 1 and 1 - n < L:
        is_prime_segment[max(0, 1 - n)] = False
    if n == 0 and L > 0:
        is_prime_segment[0] = False
    
    return [n + i for i in range(L) if is_prime_segment[i] and n + i >= 2]


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Prime Gap Graph Construction
# ─────────────────────────────────────────────────────────────────────────────

def build_prime_gap_graph(
    n: int, L: int, S: Set[int]
) -> Tuple[List[int], Set[FrozenSet[int]], Dict[int, Set[int]]]:
    """
    Construct the prime gap graph G(n, L, S).
    
    Vertices: primes p in [n, n+L-1]
    Edges: {p, q} with p < q and q - p ∈ S
    
    Time: O(V² + V·|S|) where V = number of primes in window
    Space: O(V² + V·|S|)
    
    Args:
        n: Start of interval
        L: Length of interval  
        S: Set of admissible gaps (positive integers)
        
    Returns:
        (vertices, edges, adjacency_dict)
    
    Example:
        >>> V, E, adj = build_prime_gap_graph(10, 20, {2, 4, 6})
        >>> len(V), len(E)
        (6, 8)
    """
    primes = segmented_sieve(n, L)
    prime_set = set(primes)
    
    edges: Set[FrozenSet[int]] = set()
    adj: Dict[int, Set[int]] = defaultdict(set)
    
    for p in primes:
        for h in S:
            q = p + h
            if q in prime_set:
                edge = frozenset([p, q])
                edges.add(edge)
                adj[p].add(q)
                adj[q].add(p)
    
    return primes, edges, dict(adj)


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Clique Enumeration (Bron-Kerbosch)
# ─────────────────────────────────────────────────────────────────────────────

def bron_kerbosch_all(
    adj: Dict[int, Set[int]], vertices: List[int]
) -> Dict[int, List[FrozenSet[int]]]:
    """
    Enumerate all maximal cliques using Bron-Kerbosch with pivoting,
    then extract all cliques of each size.
    
    Time: O(3^(V/3)) worst case (Bron-Kerbosch)
    Space: O(V + number of maximal cliques)
    
    Args:
        adj: Adjacency dictionary
        vertices: List of all vertices
        
    Returns:
        Dictionary mapping clique size k to list of k-cliques
    
    Example:
        >>> _, _, adj = build_prime_gap_graph(10, 20, {2, 4, 6})
        >>> cliques = bron_kerbosch_all(adj, [11,13,17,19,23,29])
        >>> len(cliques.get(3, []))
        3
    """
    maximal_cliques: List[FrozenSet[int]] = []
    vertex_set = set(vertices)
    
    def _bk(R: Set[int], P: Set[int], X: Set[int]):
        if not P and not X:
            maximal_cliques.append(frozenset(R))
            return
        # Choose pivot to minimize branching
        pivot = max(P | X, key=lambda v: len(adj.get(v, set()) & P))
        for v in list(P - adj.get(pivot, set())):
            neighbors = adj.get(v, set())
            _bk(R | {v}, P & neighbors, X & neighbors)
            P.remove(v)
            X.add(v)
    
    _bk(set(), vertex_set, set())
    
    # Extract all sub-cliques organized by size
    all_cliques: Dict[int, List[FrozenSet[int]]] = defaultdict(list)
    seen: Dict[int, Set[FrozenSet[int]]] = defaultdict(set)
    
    for mc in maximal_cliques:
        mc_list = sorted(mc)
        for k in range(1, len(mc_list) + 1):
            for combo in combinations(mc_list, k):
                fs = frozenset(combo)
                if fs not in seen[k]:
                    seen[k].add(fs)
                    all_cliques[k].append(fs)
    
    # Also add isolated vertices
    for v in vertices:
        fs = frozenset([v])
        if fs not in seen[1]:
            seen[1].add(fs)
            all_cliques[1].append(fs)
    
    return dict(all_cliques)


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 4: Face Vector and Euler Characteristic
# ─────────────────────────────────────────────────────────────────────────────

def compute_face_vector(n: int, L: int, S: Set[int]) -> Dict[int, int]:
    """
    Compute the complete face vector (f_0, f_1, f_2, ...) of the
    prime gap clique complex K(n, L, S).
    
    Time: O(3^(V/3)) via Bron-Kerbosch clique enumeration
    Space: O(total number of cliques)
    
    The face vector satisfies:
        f_k = number of (k+1)-cliques in the prime gap graph
    
    Args:
        n: Window start
        L: Window length
        S: Admissible gap set
        
    Returns:
        Dictionary {dimension: face_count}
    
    Example:
        >>> fv = compute_face_vector(10, 20, {2, 4, 6})
        >>> fv[0], fv[1], fv[2]
        (6, 8, 3)
    """
    vertices, edges, adj = build_prime_gap_graph(n, L, S)
    cliques = bron_kerbosch_all(adj, vertices)
    
    face_vector = {}
    for k, clique_list in cliques.items():
        face_vector[k - 1] = len(clique_list)  # dimension = size - 1
    
    return face_vector


def compute_euler_characteristic(n: int, L: int, S: Set[int]) -> int:
    """
    Compute the Euler characteristic χ(K(n, L, S)).
    
    χ = Σ_{k≥0} (-1)^k f_k
    
    This is the fundamental topological invariant that bridges
    combinatorial topology and arithmetic statistics.
    
    Args:
        n: Window start
        L: Window length  
        S: Admissible gap set
        
    Returns:
        Integer Euler characteristic
    
    Example:
        >>> compute_euler_characteristic(10, 20, {2, 4, 6})
        1
    """
    fv = compute_face_vector(n, L, S)
    return sum((-1)**k * count for k, count in fv.items())


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 5: Gap-Set Filtration Profile
# ─────────────────────────────────────────────────────────────────────────────

def compute_filtration_profile(
    n: int, L: int, max_gap: int, gap_step: int = 2
) -> List[Dict]:
    """
    Compute the complete filtration profile of the prime gap complex
    as the admissible gap set grows: S_t = {gap_step, 2·gap_step, ..., t}.
    
    For each filtration parameter t, computes:
    - Face vector
    - Euler characteristic
    - Edge count and its decomposition by gap
    
    Time: O(max_gap/gap_step · 3^(V/3))
    Space: O(V² · max_gap/gap_step)
    
    Args:
        n: Window start
        L: Window length
        max_gap: Maximum gap to include
        gap_step: Gap increment (default 2 for even gaps)
        
    Returns:
        List of dictionaries with filtration data
    
    Example:
        >>> profile = compute_filtration_profile(10, 20, 10)
        >>> len(profile)
        5
    """
    profile = []
    for t in range(gap_step, max_gap + 1, gap_step):
        S = set(range(gap_step, t + 1, gap_step))
        fv = compute_face_vector(n, L, S)
        chi = sum((-1)**k * c for k, c in fv.items())
        
        # Edge decomposition by gap (Theorem 1)
        edge_decomp = {}
        vertices, _, _ = build_prime_gap_graph(n, L, S)
        prime_set = set(vertices)
        for h in sorted(S):
            count = sum(1 for p in vertices if p + h in prime_set)
            edge_decomp[h] = count
        
        profile.append({
            'max_gap': t,
            'gap_set_size': len(S),
            'face_vector': fv,
            'euler_char': chi,
            'edge_decomposition': edge_decomp,
        })
    
    return profile


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 6: Arithmetic Discrepancy Computation
# ─────────────────────────────────────────────────────────────────────────────

def compute_arithmetic_discrepancy(
    n: int, L: int, S: Set[int]
) -> Dict[str, float]:
    """
    Compute the discrepancy between actual prime gap complex statistics
    and the Bernoulli random model prediction.
    
    For the Bernoulli model with parameter p = π(n,L)/L:
        E[edges] = p² · Σ_{h∈S} (L - h)
        E[vertices] = L · p
    
    The discrepancy Δ = actual - E[Bernoulli] encodes arithmetic
    information about prime pair correlations beyond what's captured
    by the density alone.
    
    Time: O(V² + |S| · V)
    Space: O(V²)
    
    Args:
        n: Window start
        L: Window length
        S: Admissible gap set
        
    Returns:
        Dictionary with discrepancy statistics
    """
    vertices, edges, adj = build_prime_gap_graph(n, L, S)
    V_actual = len(vertices)
    E_actual = len(edges)
    
    # Prime density
    p = V_actual / L if L > 0 else 0
    
    # Bernoulli predictions
    E_V_bernoulli = L * p
    E_E_bernoulli = p**2 * sum(max(L - h, 0) for h in S)
    
    # Face vector for triangle count
    fv = compute_face_vector(n, L, S)
    T_actual = fv.get(2, 0)
    
    # Bernoulli triangle prediction (requires triple-gap compatibility)
    # For independent Bernoulli, E[triangles] = p³ · (number of compatible triples)
    compatible_triples = 0
    S_list = sorted(S)
    for i, h1 in enumerate(S_list):
        for h2 in S_list[i:]:
            if h1 + h2 in S:
                compatible_triples += max(L - h1 - h2, 0)
    E_T_bernoulli = p**3 * compatible_triples
    
    chi_actual = V_actual - E_actual + T_actual
    chi_bernoulli = E_V_bernoulli - E_E_bernoulli + E_T_bernoulli
    
    return {
        'prime_density': p,
        'vertex_actual': V_actual,
        'vertex_bernoulli': E_V_bernoulli,
        'edge_actual': E_actual,
        'edge_bernoulli': E_E_bernoulli,
        'edge_discrepancy': E_actual - E_E_bernoulli,
        'triangle_actual': T_actual,
        'triangle_bernoulli': E_T_bernoulli,
        'euler_actual': chi_actual,
        'euler_bernoulli': chi_bernoulli,
        'euler_discrepancy': chi_actual - chi_bernoulli,
    }


# ─────────────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Example 1: Basic construction
    n, L, S = 10, 20, {2, 4, 6}
    V, E, adj = build_prime_gap_graph(n, L, S)
    print(f"Graph G({n}, {L}, {sorted(S)}):")
    print(f"  Vertices: {V}")
    print(f"  Edges: {len(E)}")
    
    # Example 2: Face vector
    fv = compute_face_vector(n, L, S)
    print(f"  Face vector: {dict(sorted(fv.items()))}")
    print(f"  Euler char: {compute_euler_characteristic(n, L, S)}")
    
    # Example 3: Filtration
    print(f"\nFiltration profile for [{n}, {n+L-1}]:")
    profile = compute_filtration_profile(n, L, 20)
    for entry in profile:
        print(f"  max_gap={entry['max_gap']}: "
              f"χ={entry['euler_char']}, "
              f"edges={entry['face_vector'].get(1, 0)}")
    
    # Example 4: Discrepancy
    n2, L2 = 1000, 200
    disc = compute_arithmetic_discrepancy(n2, L2, {2, 4, 6, 8, 10})
    print(f"\nDiscrepancy for [{n2}, {n2+L2-1}], S={{2,4,6,8,10}}:")
    print(f"  Edge discrepancy: {disc['edge_discrepancy']:+.1f}")
    print(f"  Euler discrepancy: {disc['euler_discrepancy']:+.1f}")
    print(f"  Prime density: {disc['prime_density']:.4f}")
