#!/usr/bin/env python3
"""
Algorithms for Canonical Path Poincaré Inequality

Implements the core algorithms for computing canonical path data,
congestion bounds, and spectral gap certificates for Cayley graphs.
"""

import itertools
import math
from collections import defaultdict
from typing import List, Tuple, Dict, Optional


def compose_perm(p: tuple, q: tuple) -> tuple:
    """Compose permutations: (p∘q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(p)))


def inverse_perm(p: tuple) -> tuple:
    """Inverse of a permutation."""
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)


def adj_transposition(n: int, j: int) -> tuple:
    """Adjacent transposition swapping positions j and j+1."""
    p = list(range(n))
    p[j], p[j + 1] = p[j + 1], p[j]
    return tuple(p)


def bubble_sort_path(sigma: tuple) -> List[int]:
    """
    Bubble-sort canonical path from identity to sigma.
    
    Returns list of generator indices [g₁, ..., gₖ] such that
    adj(g₁) * adj(g₂) * ... * adj(gₖ) = sigma.
    
    Algorithm: Standard bubble sort of sigma's array representation.
    Each swap of adjacent elements records a generator.
    
    Time complexity: O(n²) where n = len(sigma).
    Space complexity: O(n²) for the path (max length n(n-1)/2).
    
    Example:
        >>> bubble_sort_path((2, 0, 1))
        [0, 1, 0]  # swap(0,1) * swap(1,2) * swap(0,1) = (2,0,1)
    """
    n = len(sigma)
    arr = list(sigma)
    swaps = []
    
    for i in range(n):
        for j in range(n - 1 - i):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
                swaps.append(j)
    
    swaps.reverse()
    return swaps


def canonical_path(x: tuple, y: tuple) -> List[int]:
    """
    Canonical path from x to y in S_n with adjacent transpositions.
    
    Computes δ = y * x⁻¹ and returns bubble_sort_path(δ).
    The resulting path satisfies: path.prod * x = y.
    
    Args:
        x: Source permutation (tuple)
        y: Target permutation (tuple)
    
    Returns:
        List of generator indices forming the canonical path.
    
    Time complexity: O(n²)
    """
    x_inv = inverse_perm(x)
    delta = compose_perm(y, x_inv)
    return bubble_sort_path(delta)


def compute_spectral_certificate(n: int) -> Dict:
    """
    Compute a complete spectral gap certificate for S_n.
    
    This is the main algorithm: it constructs canonical paths for
    all pairs, computes exact congestion and path length bounds,
    and outputs a certified spectral gap lower bound.
    
    Args:
        n: Size of the symmetric group S_n
    
    Returns:
        Dictionary containing:
        - 'n': group parameter
        - 'group_order': |S_n| = n!
        - 'num_generators': |S| = n-1
        - 'max_path_length': L
        - 'congestion': κ
        - 'poincare_constant': κL/(2|G|²)
        - 'spectral_gap_lower': 2|G|²/(|S|κL)
        - 'mixing_time_upper': approximate mixing time bound
    
    Time complexity: O(n! × n! × n²) = O((n!)² · n²)
    Space complexity: O(n! × n) for edge usage counts
    """
    perms = list(itertools.permutations(range(n)))
    G_card = len(perms)
    S_card = n - 1
    
    max_length = 0
    edge_uses: Dict[Tuple[tuple, int], int] = defaultdict(int)
    
    for x in perms:
        for y in perms:
            path = canonical_path(x, y)
            max_length = max(max_length, len(path))
            
            # Track edges: walk from x applying generators right-to-left
            current = x
            for idx in range(len(path) - 1, -1, -1):
                g = path[idx]
                edge_uses[(current, g)] += 1
                t = adj_transposition(n, g)
                current = compose_perm(t, current)
    
    congestion = max(edge_uses.values()) if edge_uses else 0
    
    poincare_const = congestion * max_length / (2.0 * G_card**2) if G_card > 0 else float('inf')
    gap_lower = 2.0 * G_card**2 / (S_card * congestion * max_length) if congestion > 0 and max_length > 0 else 0
    mix_upper = congestion * max_length / (2.0 * G_card) * math.log(G_card) if G_card > 1 else 0
    
    return {
        'n': n,
        'group_order': G_card,
        'num_generators': S_card,
        'max_path_length': max_length,
        'congestion': congestion,
        'poincare_constant': poincare_const,
        'spectral_gap_lower': gap_lower,
        'mixing_time_upper': mix_upper,
        'edge_uses': dict(edge_uses),
    }


def congestion_by_generator(cert: Dict) -> Dict[int, int]:
    """
    Break down congestion by generator type.
    
    For each generator index j (transposition (j, j+1)),
    reports the maximum edge usage over all source vertices.
    
    Args:
        cert: Certificate from compute_spectral_certificate
    
    Returns:
        Dict mapping generator index to max congestion for that generator.
    """
    n = cert['n']
    gen_max = {}
    for j in range(n - 1):
        max_use = 0
        for (src, g), count in cert['edge_uses'].items():
            if g == j:
                max_use = max(max_use, count)
        gen_max[j] = max_use
    return gen_max


if __name__ == "__main__":
    print("Spectral Gap Certificates for S_n\n")
    for n in [3, 4, 5]:
        cert = compute_spectral_certificate(n)
        print(f"S_{n}:")
        print(f"  |G| = {cert['group_order']}")
        print(f"  |S| = {cert['num_generators']}")
        print(f"  L = {cert['max_path_length']}")
        print(f"  κ = {cert['congestion']}")
        print(f"  Poincaré const = {cert['poincare_constant']:.6f}")
        print(f"  Spectral gap ≥ {cert['spectral_gap_lower']:.6f}")
        print(f"  Mixing time ≤ {cert['mixing_time_upper']:.1f}")
        
        gen_cong = congestion_by_generator(cert)
        print(f"  Congestion by generator: {gen_cong}")
        print()
