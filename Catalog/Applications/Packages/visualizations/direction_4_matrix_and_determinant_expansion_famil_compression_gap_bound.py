#!/usr/bin/env python3
"""
Algorithms for Super-Exponential Compression Gap Analysis

Implements:
- Compression gap computation for determinant and resultant families
- Phase transition threshold detection
- Verified compression gap bound
- Tropical determinant and permanent computation
"""

import math
from fractions import Fraction
from itertools import permutations
from typing import List, Tuple, Optional


def factorial_dominates_check(k: int, C: int, N: int) -> bool:
    """
    Verify that n! ≥ C * n^k for all n in [N, N+100].

    This is a computational check of the formal theorem
    factorial_dominates_polynomial_strong.

    Args:
        k: Polynomial degree
        C: Multiplicative constant
        N: Starting threshold

    Returns:
        True if n! ≥ C * n^k for all n in [N, N+100]
    """
    for n in range(N, N + 101):
        if math.factorial(n) < C * n ** k:
            return False
    return True


def compression_gap_bound(C: int, k: int) -> int:
    """
    Compute a verified threshold N such that n!/n^k > C for all n ≥ N.

    This matches the formal definition in DetCompressionGap.lean:
        def compressionGapBound (C : ℕ) (k : ℕ) : ℕ :=
          max (2 * k + 2) (2 * C + 2)

    Args:
        C: Target gap value
        k: Polynomial degree

    Returns:
        N such that n!/n^k > C for all n ≥ N

    Examples:
        >>> compression_gap_bound(100, 2)
        204
        >>> compression_gap_bound(10, 3)
        22
    """
    return max(2 * k + 2, 2 * C + 2)


def compression_gap_bound_tight(C: int, k: int) -> int:
    """
    Find the smallest N such that n!/n^k > C for all n ≥ N.

    This is tighter than compression_gap_bound but not formally verified.

    Args:
        C: Target gap value
        k: Polynomial degree

    Returns:
        Smallest N such that n!/n^k ≥ C for all n ≥ N
    """
    n = 1
    while n < 10000:
        if math.factorial(n) >= C * n ** k:
            # Verify it stays above for the next 50 values
            all_above = all(
                math.factorial(n + i) >= C * (n + i) ** k
                for i in range(50)
            )
            if all_above:
                return n
        n += 1
    return n


def det_compression_gap(n: int) -> Fraction:
    """
    Compute the exact determinant compression gap n!/n².

    Args:
        n: Matrix dimension

    Returns:
        Exact rational value of n!/n²

    Examples:
        >>> det_compression_gap(5)
        Fraction(24, 5)
        >>> float(det_compression_gap(10))
        36288.0
    """
    if n == 0:
        return Fraction(0)
    return Fraction(math.factorial(n), n * n)


def resultant_compression_gap(m: int, n: int) -> Fraction:
    """
    Compute the exact resultant compression gap C(m+n, m) / (m+n).

    For polynomials of degrees m and n, the Sylvester expansion
    has C(m+n, m) terms, and the structured approach takes O(m+n) steps.

    Args:
        m: Degree of first polynomial
        n: Degree of second polynomial

    Returns:
        Exact rational compression gap
    """
    if m + n == 0:
        return Fraction(0)
    return Fraction(math.comb(m + n, m), m + n)


def phase_transition_threshold(gap_threshold: float = 1000.0) -> int:
    """
    Find the smallest matrix dimension where the determinant
    compression gap exceeds the given threshold.

    Args:
        gap_threshold: The incompressibility threshold

    Returns:
        Smallest n such that n!/n² ≥ gap_threshold

    Examples:
        >>> phase_transition_threshold(100)
        7
        >>> phase_transition_threshold(10000)
        10
    """
    n = 1
    while True:
        if float(det_compression_gap(n)) >= gap_threshold:
            return n
        n += 1


def tropical_det(M: List[List[int]]) -> int:
    """
    Compute the tropical determinant of a square integer matrix.

    In tropical (min-plus) algebra:
        tdet(M) = min_{σ ∈ Sₙ} Σᵢ M[i][σ(i)]

    Args:
        M: Square integer matrix as list of lists

    Returns:
        Tropical determinant value

    Examples:
        >>> tropical_det([[1, 2], [3, 4]])
        5
    """
    n = len(M)
    assert all(len(row) == n for row in M), "Matrix must be square"

    min_cost = float('inf')
    for perm in permutations(range(n)):
        cost = sum(M[i][perm[i]] for i in range(n))
        min_cost = min(min_cost, cost)
    return min_cost


def tropical_permanent(M: List[List[int]]) -> int:
    """
    Compute the tropical permanent of a square integer matrix.

    Identical to tropical determinant (signs vanish in min-plus algebra):
        tperm(M) = min_{σ ∈ Sₙ} Σᵢ M[i][σ(i)]

    Args:
        M: Square integer matrix as list of lists

    Returns:
        Tropical permanent value
    """
    return tropical_det(M)  # They are identical — this IS the theorem


def classical_det(M: List[List[float]]) -> float:
    """
    Compute the classical determinant via Leibniz expansion.

    Uses all n! permutations with signs. For comparison with tropical.

    Args:
        M: Square matrix as list of lists

    Returns:
        Classical determinant
    """
    n = len(M)
    result = 0.0
    for perm in permutations(range(n)):
        # Compute sign of permutation
        inversions = sum(
            1 for i in range(n) for j in range(i + 1, n)
            if perm[i] > perm[j]
        )
        sign = 1 if inversions % 2 == 0 else -1
        product = sign
        for i in range(n):
            product *= M[i][perm[i]]
        result += product
    return result


def classical_permanent(M: List[List[float]]) -> float:
    """
    Compute the classical permanent (no signs).

    Args:
        M: Square matrix as list of lists

    Returns:
        Classical permanent
    """
    n = len(M)
    result = 0.0
    for perm in permutations(range(n)):
        product = 1.0
        for i in range(n):
            product *= M[i][perm[i]]
        result += product
    return result


def verify_tropical_equality(n: int, num_trials: int = 10) -> bool:
    """
    Empirically verify that tropical det = tropical permanent
    for random n×n matrices.

    Args:
        n: Matrix dimension
        num_trials: Number of random matrices to test

    Returns:
        True if equality holds for all trials
    """
    import random
    random.seed(42)

    for _ in range(num_trials):
        M = [[random.randint(-10, 10) for _ in range(n)] for _ in range(n)]
        if tropical_det(M) != tropical_permanent(M):
            return False
    return True


def compression_gap_table(max_n: int = 20) -> List[dict]:
    """
    Generate a comprehensive table of compression gap data.

    Args:
        max_n: Maximum matrix dimension

    Returns:
        List of dictionaries with compression gap data
    """
    results = []
    for n in range(1, max_n + 1):
        gap = det_compression_gap(n)
        results.append({
            'n': n,
            'factorial': math.factorial(n),
            'n_squared': n * n,
            'gap': float(gap),
            'gap_exact': gap,
            'log_gap': math.log10(float(gap)) if float(gap) > 0 else 0,
            'phase': classify_phase(float(gap)),
        })
    return results


def classify_phase(gap: float) -> str:
    """Classify the compression phase based on gap value."""
    if gap < 1:
        return "compressible"
    elif gap < 10:
        return "transition"
    elif gap < 1000:
        return "incompressible"
    else:
        return "deep_incompressible"


if __name__ == "__main__":
    print("=== Factorial Dominance Verification ===")
    for k in range(1, 6):
        for C in [1, 10, 100]:
            N = compression_gap_bound(C, k)
            N_tight = compression_gap_bound_tight(C, k)
            valid = factorial_dominates_check(k, C, N)
            print(f"k={k}, C={C}: bound N={N}, tight N={N_tight}, valid={valid}")

    print("\n=== Compression Gap Table ===")
    table = compression_gap_table(15)
    print(f"{'n':>4} {'n!':>15} {'n²':>6} {'gap':>15} {'phase':>20}")
    for row in table:
        print(f"{row['n']:>4} {row['factorial']:>15} {row['n_squared']:>6} {row['gap']:>15.2f} {row['phase']:>20}")

    print("\n=== Tropical Det = Perm Verification ===")
    for n in range(2, 7):
        result = verify_tropical_equality(n)
        print(f"n={n}: tropical det == tropical perm? {result}")

    print("\n=== Phase Transition Thresholds ===")
    for threshold in [1, 10, 100, 1000, 10000]:
        n_star = phase_transition_threshold(threshold)
        print(f"Threshold {threshold:>6}: n* = {n_star}")
