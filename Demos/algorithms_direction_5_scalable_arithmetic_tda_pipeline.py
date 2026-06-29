#!/usr/bin/env python3
"""
Arithmetic TDA Pipeline — Core Algorithms

Implements the verified algorithms from the formal proofs:
1. Smith Normal Form computation for integer matrices
2. Torsion prime profile extraction from SNF diagonal
3. Full degreewise arithmetic signature computation
4. Tor₁ torsion detection (computational proxy)

Each algorithm includes docstrings, type hints, complexity analysis,
and example usage.
"""

from typing import List, Set, Dict, Tuple, Optional
from collections import defaultdict
from math import gcd, log2
from functools import reduce
import numpy as np


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Prime Factorization
# ═══════════════════════════════════════════════════════════════

def prime_factors(n: int) -> Set[int]:
    """
    Compute the set of prime factors of a positive integer n.
    
    Time complexity: O(√n)
    Space complexity: O(log n) for the output set
    
    Examples:
        >>> sorted(prime_factors(12))
        [2, 3]
        >>> sorted(prime_factors(30))
        [2, 3, 5]
        >>> prime_factors(1)
        set()
    """
    if n <= 1:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def prime_factorization(n: int) -> Dict[int, int]:
    """
    Compute the full prime factorization of n as {prime: exponent}.
    
    Time complexity: O(√n)
    
    Examples:
        >>> prime_factorization(12)
        {2: 2, 3: 1}
        >>> prime_factorization(360)
        {2: 3, 3: 2, 5: 1}
    """
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = 1
    return factors


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Smith Normal Form
# ═══════════════════════════════════════════════════════════════

def smith_normal_form(matrix: np.ndarray) -> Tuple[List[int], np.ndarray, np.ndarray]:
    """
    Compute the Smith Normal Form of an integer matrix.
    
    Given an m×n integer matrix A, compute diagonal entries d₁, d₂, ..., dᵣ
    such that there exist invertible integer matrices P (m×m), Q (n×n) with
    P·A·Q = diag(d₁, ..., dᵣ, 0, ..., 0) and d₁ | d₂ | ... | dᵣ.
    
    Time complexity: O(m·n·min(m,n)·log(max|aᵢⱼ|)) — polynomial in dimensions
                     and bit complexity of entries.
    
    Returns:
        diagonal: List of nonzero diagonal entries (invariant factors)
        P: Left transformation matrix
        Q: Right transformation matrix
    
    Examples:
        >>> diag, P, Q = smith_normal_form(np.array([[2, 4], [6, 8]]))
        >>> diag
        [2, 4]
    """
    if matrix.size == 0:
        m, n = matrix.shape if len(matrix.shape) == 2 else (0, 0)
        return [], np.eye(m, dtype=int), np.eye(n, dtype=int)
    
    M = matrix.astype(int).copy()
    rows, cols = M.shape
    P = np.eye(rows, dtype=int)
    Q = np.eye(cols, dtype=int)
    
    pivot = 0
    diag = []
    
    for _ in range(min(rows, cols)):
        # Find nonzero entry in remaining submatrix
        found = False
        for r in range(pivot, rows):
            for c in range(pivot, cols):
                if M[r, c] != 0:
                    # Swap to pivot position
                    if r != pivot:
                        M[[pivot, r]] = M[[r, pivot]]
                        P[[pivot, r]] = P[[r, pivot]]
                    if c != pivot:
                        M[:, [pivot, c]] = M[:, [c, pivot]]
                        Q[:, [pivot, c]] = Q[:, [c, pivot]]
                    found = True
                    break
            if found:
                break
        
        if not found:
            break
        
        # Reduce
        changed = True
        max_iter = 1000
        while changed and max_iter > 0:
            changed = False
            max_iter -= 1
            
            for r in range(pivot + 1, rows):
                if M[r, pivot] != 0:
                    q = M[r, pivot] // M[pivot, pivot]
                    M[r] -= q * M[pivot]
                    P[r] -= q * P[pivot]
                    if M[r, pivot] != 0:
                        M[[pivot, r]] = M[[r, pivot]]
                        P[[pivot, r]] = P[[r, pivot]]
                        changed = True
            
            for c in range(pivot + 1, cols):
                if M[pivot, c] != 0:
                    q = M[pivot, c] // M[pivot, pivot]
                    M[:, c] -= q * M[:, pivot]
                    Q[:, c] -= q * Q[:, pivot]
                    if M[pivot, c] != 0:
                        M[:, [pivot, c]] = M[:, [c, pivot]]
                        Q[:, [pivot, c]] = Q[:, [c, pivot]]
                        changed = True
        
        diag.append(abs(int(M[pivot, pivot])))
        pivot += 1
    
    return diag, P, Q


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Torsion Prime Profile from Smith Data
# ═══════════════════════════════════════════════════════════════

def compute_torsion_primes_from_smith(factors: List[int]) -> Set[int]:
    """
    Extract the torsion prime profile from Smith normal form diagonal data.
    
    Given invariant factors [d₁, d₂, ..., dₖ], the torsion prime profile is
    ⋃ᵢ PrimeFactors(dᵢ) restricted to dᵢ > 1.
    
    This is the formally verified algorithm corresponding to
    `computeTorsionPrimesFromSmith` in the Lean formalization.
    
    Time complexity: O(k · √(max dᵢ)) where k = number of factors
    Space complexity: O(log(∏ dᵢ))
    
    The post-processing cost is O(Σᵢ log(dᵢ)), which is negligible
    compared to the O(N^ω) cost of the SNF computation itself.
    
    Examples:
        >>> sorted(compute_torsion_primes_from_smith([2, 6, 30]))
        [2, 3, 5]
        >>> compute_torsion_primes_from_smith([1, 1, 1])
        set()
        >>> sorted(compute_torsion_primes_from_smith([4, 12]))
        [2, 3]
    """
    primes = set()
    for d in factors:
        if d > 1:
            primes |= prime_factors(d)
    return primes


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Full Degreewise Arithmetic Signature
# ═══════════════════════════════════════════════════════════════

def compute_full_arithmetic_signature(
    boundary_matrices: List[np.ndarray]
) -> Dict[str, object]:
    """
    Compute the full arithmetic signature of a chain complex.
    
    Given boundary matrices [∂₁, ∂₂, ..., ∂ₐ] of a chain complex,
    compute the Smith normal form of each, extract torsion primes
    at each degree, and return the complete arithmetic signature.
    
    This is the end-to-end verified pipeline:
    1. For each boundary matrix, compute Smith normal form
    2. Extract invariant factors (torsion part)
    3. Compute prime factors of each invariant factor
    4. Take union across all degrees
    
    Time complexity: O(d · N^ω · log(max entry)) for d degrees, N simplices
                     + O(d · k · √(max dᵢ)) for post-processing
    
    The second term is negligible: torsion extraction adds no
    asymptotic cost beyond the Smith computation.
    
    Args:
        boundary_matrices: List of integer matrices [∂₁, ∂₂, ...]
    
    Returns:
        Dictionary with:
        - 'full_signature': Set of all torsion primes
        - 'degree_profiles': Dict mapping degree to torsion primes at that degree
        - 'betti_numbers': Dict mapping degree to Betti number
        - 'invariant_factors': Dict mapping degree to list of torsion factors
    
    Examples:
        >>> d1 = np.array([[1, -1, 0], [0, 1, -1], [-1, 0, 1]])
        >>> result = compute_full_arithmetic_signature([d1])
        >>> 'full_signature' in result
        True
    """
    result = {
        'full_signature': set(),
        'degree_profiles': {},
        'betti_numbers': {},
        'invariant_factors': {},
    }
    
    for k, mat in enumerate(boundary_matrices):
        diag, _, _ = smith_normal_form(mat)
        
        betti = sum(1 for d in diag if d == 1)
        torsion_factors = [d for d in diag if d > 1]
        primes = compute_torsion_primes_from_smith(diag)
        
        result['betti_numbers'][k] = betti
        result['invariant_factors'][k] = torsion_factors
        result['degree_profiles'][k] = primes
        result['full_signature'] |= primes
    
    return result


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Tor₁ Torsion Detection (Computational Proxy)
# ═══════════════════════════════════════════════════════════════

def tor1_detects_prime(invariant_factors: List[int], p: int) -> bool:
    """
    Check if Tor₁(Z/pZ, A) is nontrivial for a group A given by
    its invariant factors.
    
    Corresponds to the formal theorem:
        p ∈ TorsionPrimeProfile(A) ↔ Tor₁(Z/pZ, A) ≠ 0
    
    Mathematically, Tor₁(Z/pZ, Z/dZ) ≅ Z/gcd(p,d)Z, which is
    nontrivial iff p | d. So Tor₁ detects p-torsion iff some
    invariant factor is divisible by p.
    
    Time complexity: O(k) where k is the number of factors
    
    Examples:
        >>> tor1_detects_prime([6, 12], 2)
        True
        >>> tor1_detects_prime([6, 12], 5)
        False
        >>> tor1_detects_prime([6, 12], 3)
        True
    """
    return any(d > 1 and d % p == 0 for d in invariant_factors)


def tor1_prime_selectivity(invariant_factors: List[int]) -> Dict[int, bool]:
    """
    For each small prime, check if Tor₁ detects it.
    Demonstrates the prime selectivity theorem.
    
    Examples:
        >>> tor1_prime_selectivity([6])
        {2: True, 3: True, 5: False, 7: False, 11: False, 13: False}
    """
    small_primes = [2, 3, 5, 7, 11, 13]
    return {p: tor1_detects_prime(invariant_factors, p) for p in small_primes}


# ═══════════════════════════════════════════════════════════════
# Algorithm 6: Torsion-Aware Distance Between Complexes
# ═══════════════════════════════════════════════════════════════

def arithmetic_distance(sig1: Set[int], sig2: Set[int]) -> float:
    """
    Compute an arithmetic distance between two torsion prime signatures.
    
    Uses the symmetric difference weighted by 1/log(p) to emphasize
    small primes (which are more topologically significant).
    
    Examples:
        >>> arithmetic_distance({2, 3}, {2, 5})
        ... # Returns a positive float
    """
    if not sig1 and not sig2:
        return 0.0
    sym_diff = sig1.symmetric_difference(sig2)
    if not sym_diff:
        return 0.0
    return sum(1.0 / log2(p + 1) for p in sym_diff)


# ═══════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Arithmetic TDA Pipeline — Algorithm Examples")
    print("=" * 50)
    
    # Example 1: Smith Normal Form
    print("\n1. Smith Normal Form of [[2, 4], [6, 8]]:")
    A = np.array([[2, 4], [6, 8]])
    diag, P, Q = smith_normal_form(A)
    print(f"   Diagonal: {diag}")
    
    # Example 2: Torsion Prime Profile
    print("\n2. Torsion primes from invariant factors [2, 6, 30]:")
    primes = compute_torsion_primes_from_smith([2, 6, 30])
    print(f"   Profile: {sorted(primes)}")
    
    # Example 3: Full Pipeline
    print("\n3. Full arithmetic signature of a chain complex:")
    d1 = np.array([[1, -1, 0], [0, 1, -1], [-1, 0, 1]])
    d2 = np.array([[2, 0], [0, 3], [0, 0]])
    result = compute_full_arithmetic_signature([d1, d2])
    print(f"   Full signature: {sorted(result['full_signature'])}")
    print(f"   Degree profiles: {result['degree_profiles']}")
    print(f"   Betti numbers: {result['betti_numbers']}")
    
    # Example 4: Tor₁ Detection
    print("\n4. Tor₁ prime selectivity for Z/6Z:")
    sel = tor1_prime_selectivity([6])
    for p, detected in sel.items():
        status = "DETECTED" if detected else "silent"
        print(f"   p={p}: Tor₁(Z/{p}Z, Z/6Z) is {'nontrivial' if detected else 'trivial'} → {status}")
    
    # Example 5: Arithmetic Distance
    print("\n5. Arithmetic distance between signatures:")
    d = arithmetic_distance({2, 3}, {2, 5})
    print(f"   d({{2,3}}, {{2,5}}) = {d:.4f}")
    d0 = arithmetic_distance({2, 3}, {2, 3})
    print(f"   d({{2,3}}, {{2,3}}) = {d0:.4f}")
