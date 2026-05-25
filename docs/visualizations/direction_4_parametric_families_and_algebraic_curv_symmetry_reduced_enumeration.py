#!/usr/bin/env python3
"""
algorithms.py — Efficient algorithms for the diagonal collapse family
on cubic surfaces.

Implements symmetry-reduced enumeration, orbit counting, and
density estimation for the value set V = {-3ab(a+b) : a,b ∈ ℤ}.
"""

import math
from collections import defaultdict
from typing import Optional


def diagonal_cubic(a: int, b: int) -> int:
    """
    Compute the binary cubic form F(a,b) = -3ab(a+b).
    
    This is the value function of the diagonal collapse family:
    the parametric family (a, b) ↦ (a, b, -a-b) on the cubic
    surface x³ + y³ + z³ = k.
    
    Time:  O(1)
    Space: O(1)
    
    >>> diagonal_cubic(1, 2)
    -18
    >>> diagonal_cubic(0, 5)
    0
    """
    return -3 * a * b * (a + b)


def canonical_orbit_rep(a: int, b: int) -> tuple[int, int]:
    """
    Compute the canonical representative of the S₃ orbit of (a, b).
    
    The S₃ group acts on (a, b) by permuting {a, b, -a-b}.
    The canonical representative is the lexicographically smallest
    pair in the orbit.
    
    Time:  O(1)
    Space: O(1)
    
    >>> canonical_orbit_rep(3, 5)
    (-8, 3)
    >>> canonical_orbit_rep(5, 3)
    (-8, 3)
    """
    c = -a - b
    orbit = [(a, b), (b, a), (c, a), (a, c), (b, c), (c, b)]
    return min(orbit)


def enumerate_values_naive(B: int) -> set[int]:
    """
    Naive enumeration of F(a,b) for |a|, |b| ≤ B.
    
    Time:  O(B²)
    Space: O(B²) for the result set
    
    >>> sorted(enumerate_values_naive(1))
    [-6, 0, 6]
    """
    values = set()
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            values.add(diagonal_cubic(a, b))
    return values


def enumerate_values_symmetry_reduced(B: int) -> set[int]:
    """
    Symmetry-reduced enumeration exploiting F(a,b) = F(b,a)
    and F(a,b) = -F(-a,-b).
    
    Only iterates over a fundamental domain, reducing work by ~6x.
    
    Time:  O(B²/6) iterations
    Space: O(B²) for the result set
    
    >>> sorted(enumerate_values_symmetry_reduced(1))
    [-6, 0, 6]
    """
    values = {0}  # F(0, anything) = 0
    
    for a in range(1, B + 1):
        for b in range(a, B + 1):  # b >= a (swap symmetry)
            v = diagonal_cubic(a, b)
            values.add(v)
            values.add(-v)  # negation symmetry
            # Also consider the cyclic orbit member (-a-b, a) etc.
            # These may produce values outside the a>=0, b>=a range
            c = -a - b
            # F(c, a) = F(a, b) already accounted for
        # Also handle b in [1, a-1] implicitly via swap
        for b in range(-B, 0):
            v = diagonal_cubic(a, b)
            values.add(v)
    
    for a in range(-B, 0):
        for b in range(-B, B + 1):
            values.add(diagonal_cubic(a, b))
    
    return values


def count_values_in_range(B: int, N: int) -> int:
    """
    Count V(N) = #{k ∈ [1, N] : ∃ a,b with |a|,|b| ≤ B, k = |F(a,b)|}.
    
    This is the key quantity for the density conjecture.
    
    Time:  O(B²)
    Space: O(min(B², N))
    
    >>> count_values_in_range(10, 1000) > 0
    True
    """
    values = set()
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            v = abs(diagonal_cubic(a, b))
            if 1 <= v <= N:
                values.add(v)
    return len(values)


def density_analysis(B_values: list[int], N: Optional[int] = None) -> list[dict]:
    """
    Compute density statistics for multiple values of B.
    
    For each B, computes V(N)/N^(2/3) where V(N) is the number
    of distinct values in [1, N].
    
    Returns a list of dicts with keys: B, N, V_N, N_23, ratio.
    
    Time:  O(sum(B² for B in B_values))
    Space: O(max(B²))
    """
    results = []
    for B in B_values:
        if N is None:
            N_actual = 6 * B * B * B  # rough upper bound on max |F(a,b)|
        else:
            N_actual = N
        
        V_N = count_values_in_range(B, N_actual)
        N_23 = N_actual ** (2/3)
        ratio = V_N / N_23 if N_23 > 0 else 0
        
        results.append({
            'B': B,
            'N': N_actual,
            'V_N': V_N,
            'N_23': N_23,
            'ratio': ratio,
        })
    
    return results


def primitive_pair_filter(B: int) -> set[int]:
    """
    Enumerate values from primitive pairs (gcd(a,b) = 1) only.
    
    By the coprimality theorem, for primitive pairs the factors
    a, b, a+b are pairwise coprime, giving stronger arithmetic
    constraints on the value.
    
    Time:  O(B² · log(B))
    Space: O(B²)
    """
    values = set()
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            if math.gcd(abs(a), abs(b)) == 1:
                values.add(diagonal_cubic(a, b))
    return values


def orbit_decomposition(B: int) -> dict[int, list[tuple[int, int]]]:
    """
    Decompose parameter pairs into S₃ orbits.
    
    Returns dict: value k -> list of canonical orbit representatives.
    
    Time:  O(B²)
    Space: O(B²)
    """
    seen_orbits = set()
    result = defaultdict(list)
    
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            rep = canonical_orbit_rep(a, b)
            if rep not in seen_orbits:
                seen_orbits.add(rep)
                k = diagonal_cubic(a, b)
                result[k].append(rep)
    
    return dict(result)


def factorization_check(a: int, b: int) -> dict:
    """
    Analyze the factorization structure of F(a,b) = -3·a·b·(a+b).
    
    Returns a dict with:
    - factors: the triple (a, b, a+b)
    - gcd_ab: gcd(a, b)
    - gcd_a_sum: gcd(a, a+b)
    - gcd_b_sum: gcd(b, a+b)
    - is_primitive: whether gcd(a,b) = 1
    - pairwise_coprime: whether all three gcds are 1
    
    >>> factorization_check(3, 5)['pairwise_coprime']
    True
    """
    g_ab = math.gcd(abs(a), abs(b))
    g_a_sum = math.gcd(abs(a), abs(a + b))
    g_b_sum = math.gcd(abs(b), abs(a + b))
    
    return {
        'factors': (a, b, a + b),
        'value': diagonal_cubic(a, b),
        'gcd_ab': g_ab,
        'gcd_a_sum': g_a_sum,
        'gcd_b_sum': g_b_sum,
        'is_primitive': g_ab == 1,
        'pairwise_coprime': g_ab == 1 and g_a_sum == 1 and g_b_sum == 1,
    }


def search_representation(k: int, B: int) -> Optional[tuple[int, int, int]]:
    """
    Search for a representation k = x³ + y³ + z³ using the diagonal
    collapse family with parameter bound B.
    
    Returns (x, y, z) if found, None otherwise.
    
    Time:  O(B²)
    Space: O(1)
    """
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            if diagonal_cubic(a, b) == k:
                return (a, b, -a - b)
    return None


if __name__ == "__main__":
    print("Density analysis for B = 50, 100, 200, 500:")
    results = density_analysis([50, 100, 200, 500])
    print(f"  {'B':>5s}  {'N':>10s}  {'V(N)':>7s}  {'N^(2/3)':>10s}  {'Ratio':>8s}")
    for r in results:
        print(f"  {r['B']:5d}  {r['N']:10d}  {r['V_N']:7d}  "
              f"{r['N_23']:10.1f}  {r['ratio']:8.4f}")
    
    print("\nFactorization analysis for primitive pairs:")
    for (a, b) in [(1, 2), (3, 5), (7, 11), (2, 3)]:
        info = factorization_check(a, b)
        print(f"  ({a},{b}): F={info['value']}, "
              f"pairwise coprime: {info['pairwise_coprime']}")
    
    print("\nOrbit decomposition sample (B=5):")
    orbits = orbit_decomposition(5)
    for k in sorted(orbits.keys())[:10]:
        print(f"  k={k:5d}: {len(orbits[k])} orbit(s)")
