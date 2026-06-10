#!/usr/bin/env python3
"""
Algorithms for Symmetric-Power Euler Factor Computation

Implements the core algorithms from the formal development:
1. Power sum oracle via Chebyshev recurrence
2. Euler factor computation via two-step recurrence
3. Coefficient extraction via Newton identities
4. Holonomic detection for coefficient families

All algorithms work over exact arithmetic (integers/rationals).
"""

from typing import List, Dict, Tuple, Optional
from fractions import Fraction
from functools import lru_cache


# =============================================================================
# Algorithm 1: Power Sum Oracle
# =============================================================================

def power_sum_oracle(t: int, d: int, n: int) -> int:
    """
    Compute S_n(t,d) = α^n + β^n where α+β = t, αβ = d.

    Uses the Chebyshev recurrence:
        S(0) = 2, S(1) = t, S(n+2) = t·S(n+1) - d·S(n)

    Time complexity: O(n) arithmetic operations.
    Space complexity: O(1).

    Examples:
        >>> power_sum_oracle(5, 6, 4)  # α=2, β=3: 2^4+3^4 = 97
        97
        >>> power_sum_oracle(3, 2, 6)  # α=1, β=2: 1^6+2^6 = 65
        65
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - d * prev
    return curr


def power_sum_oracle_batch(t: int, d: int, max_n: int) -> List[int]:
    """
    Compute S_0(t,d), S_1(t,d), ..., S_{max_n}(t,d) simultaneously.

    Time complexity: O(max_n) arithmetic operations.
    Space complexity: O(max_n).

    Examples:
        >>> power_sum_oracle_batch(5, 6, 5)
        [2, 5, 13, 35, 97, 275]
    """
    if max_n < 0:
        return []
    result = [0] * (max_n + 1)
    result[0] = 2
    if max_n == 0:
        return result
    result[1] = t
    for i in range(2, max_n + 1):
        result[i] = t * result[i-1] - d * result[i-2]
    return result


# =============================================================================
# Algorithm 2: Symmetric Trace Recurrence
# =============================================================================

def symm_trace_rec(t: int, d: int, n: int) -> int:
    """
    Compute P_n(t,d) = ∑_{k=0}^{n} α^{n-k} β^k where α+β = t, αβ = d.

    Uses the recurrence:
        P(0) = 1, P(1) = t, P(n+2) = t·P(n+1) - d·P(n)

    This is the trace of Sym^n(V) for a rank-2 representation V
    with characteristic polynomial X² - tX + d.

    Time complexity: O(n) arithmetic operations.
    Space complexity: O(1).

    Examples:
        >>> symm_trace_rec(5, 6, 3)  # 2^3+2^2·3+2·3^2+3^3 = 8+12+18+27 = 65
        65
    """
    if n == 0:
        return 1
    if n == 1:
        return t
    prev, curr = 1, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - d * prev
    return curr


# =============================================================================
# Algorithm 3: Euler Factor Polynomial Computation
# =============================================================================

def euler_factor_poly(t: int, d: int, n: int) -> List[int]:
    """
    Compute the coefficients of Φ_n(t,d;X) = ∏_{k=0}^{n}(1 - α^{n-k}β^k X).

    Returns coefficients [c_0, c_1, ..., c_{n+1}] where
    Φ_n(t,d;X) = ∑_j c_j X^j.

    Uses the two-step recurrence:
        Φ(0) = [1, -1]
        Φ(1) = [1, -t, d]
        Φ(n+2) = [1, -S_{n+2}, d^{n+2}] * Φ(n)|_{X → dX}

    Time complexity: O(n²) arithmetic operations.
    Space complexity: O(n).

    Examples:
        >>> euler_factor_poly(3, 2, 0)
        [1, -1]
        >>> euler_factor_poly(3, 2, 1)
        [1, -3, 2]
        >>> euler_factor_poly(3, 2, 2)
        [1, -7, 14, -8]
    """
    if n == 0:
        return [1, -1]
    if n == 1:
        return [1, -t, d]

    # Recursive: Φ_{n} = Q_n * Φ_{n-2}(dX)
    s_n = power_sum_oracle(t, d, n)
    quad = [1, -s_n, d**n]  # 1 - S_n X + d^n X²

    inner = euler_factor_poly(t, d, n - 2)

    # Substitute X → dX: coefficient of X^j gets multiplied by d^j
    shifted = [c * d**j for j, c in enumerate(inner)]

    # Multiply quad and shifted
    result = [0] * (len(quad) + len(shifted) - 1)
    for i, c1 in enumerate(quad):
        for j, c2 in enumerate(shifted):
            result[i + j] += c1 * c2

    return result


def euler_factor_poly_iterative(t: int, d: int, max_n: int) -> Dict[int, List[int]]:
    """
    Compute Euler factor polynomials for n = 0, 1, ..., max_n.

    Returns a dictionary mapping n to the coefficient list.

    Time complexity: O(max_n²) total arithmetic operations.

    Examples:
        >>> polys = euler_factor_poly_iterative(3, 2, 4)
        >>> polys[2]
        [1, -7, 14, -8]
    """
    result = {}
    result[0] = [1, -1]
    if max_n >= 1:
        result[1] = [1, -t, d]

    sums = power_sum_oracle_batch(t, d, max_n)

    for n in range(2, max_n + 1):
        s_n = sums[n]
        quad = [1, -s_n, d**n]
        inner = result[n - 2]
        shifted = [c * d**j for j, c in enumerate(inner)]

        coeffs = [0] * (len(quad) + len(shifted) - 1)
        for i, c1 in enumerate(quad):
            for j, c2 in enumerate(shifted):
                coeffs[i + j] += c1 * c2

        result[n] = coeffs

    return result


# =============================================================================
# Algorithm 4: Coefficient Family Analysis
# =============================================================================

def coefficient_family(t: int, d: int, max_n: int, j: int) -> List[int]:
    """
    Extract the family n ↦ c_{n,j}(t,d) = [X^j] Φ_n(t,d;X) for n = 0,...,max_n.

    Examples:
        >>> coefficient_family(3, 2, 6, 1)  # First coefficient family
        [-1, -3, -7, -15, -31, -63, -127]
    """
    polys = euler_factor_poly_iterative(t, d, max_n)
    return [polys[n][j] if j < len(polys[n]) else 0 for n in range(max_n + 1)]


def detect_linear_recurrence(seq: List[int], max_order: int = 10) -> Optional[Tuple[int, List[int]]]:
    """
    Detect if a sequence satisfies a linear recurrence with constant coefficients.

    Returns (order, [c_1, ..., c_r]) such that
        a(n) = c_1 * a(n-1) + c_2 * a(n-2) + ... + c_r * a(n-r)

    Uses the Berlekamp-Massey algorithm (simplified for exact arithmetic).

    Returns None if no recurrence of order ≤ max_order is detected.

    Examples:
        >>> detect_linear_recurrence([1, 1, 2, 3, 5, 8, 13, 21])
        (2, [Fraction(1, 1), Fraction(1, 1)])
    """
    n = len(seq)
    frac_seq = [Fraction(x) for x in seq]

    for r in range(1, min(max_order + 1, n // 2)):
        # Try to solve a(n) = c_1 a(n-1) + ... + c_r a(n-r)
        # Set up linear system

        # Build matrix equation: A * c = b
        A = []
        b = []
        for i in range(r, min(2*r + 2, n)):
            row = [frac_seq[i - k - 1] for k in range(r)]
            A.append(row)
            b.append(frac_seq[i])

        if len(A) < r:
            continue

        # Solve via Gaussian elimination
        coeffs = _solve_linear(A[:r], b[:r])
        if coeffs is None:
            continue

        # Verify on remaining data
        valid = True
        for i in range(r, n):
            predicted = sum(coeffs[k] * frac_seq[i - k - 1] for k in range(r))
            if predicted != frac_seq[i]:
                valid = False
                break

        if valid:
            return r, coeffs

    return None


def _solve_linear(A: List[List[Fraction]], b: List[Fraction]) -> Optional[List[Fraction]]:
    """Solve Ax = b using Gaussian elimination with exact arithmetic."""
    n = len(b)
    # Augmented matrix
    M = [row[:] + [b[i]] for i, row in enumerate(A)]

    for col in range(n):
        # Find pivot
        pivot = None
        for row in range(col, n):
            if M[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return None

        M[col], M[pivot] = M[pivot], M[col]

        for row in range(n):
            if row != col and M[row][col] != 0:
                factor = M[row][col] / M[col][col]
                for k in range(n + 1):
                    M[row][k] -= factor * M[col][k]

    return [M[i][n] / M[i][i] for i in range(n)]


# =============================================================================
# Algorithm 5: Weight Multiset Power Sums
# =============================================================================

def weight_power_sum(t: int, d: int, n: int, m: int) -> int:
    """
    Compute p_m(n; t, d) = ∑_{k=0}^{n} (α^{n-k} β^k)^m.

    Uses the formula: p_m = symmTraceRec(S_m(t,d), d^m, n)
    where S_m = power_sum_oracle(t, d, m).

    Time complexity: O(n + m) arithmetic operations.
    Space complexity: O(1).

    Examples:
        >>> weight_power_sum(5, 6, 3, 2)  # Direct: 8² + 12² + 18² + 27² = 64+144+324+729 = 1261
        1261
    """
    s_m = power_sum_oracle(t, d, m)
    d_m = d ** m
    return symm_trace_rec(s_m, d_m, n)


# =============================================================================
# Main: Run all algorithm demonstrations
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Power sum oracle
    print("\n1. Power Sum Oracle S_n(t,d) = α^n + β^n")
    print("-" * 50)
    t, d = 5, 6  # α=2, β=3
    print(f"   t={t}, d={d} (eigenvalues α=2, β=3)")
    sums = power_sum_oracle_batch(t, d, 10)
    for i, s in enumerate(sums):
        print(f"   S_{i:>2} = {s}")

    # Demo 2: Euler factor polynomials
    print("\n2. Euler Factor Polynomials Φ_n(t,d;X)")
    print("-" * 50)
    t, d = 3, 2  # α=1, β=2
    print(f"   t={t}, d={d} (eigenvalues α=1, β=2)")
    polys = euler_factor_poly_iterative(t, d, 8)
    for n in range(9):
        coeffs = polys[n]
        terms = " + ".join(f"({c})X^{j}" if j > 0 else str(c)
                          for j, c in enumerate(coeffs) if c != 0)
        print(f"   Φ_{n} = {terms}")

    # Demo 3: Coefficient families and recurrence detection
    print("\n3. Coefficient Families and Recurrence Detection")
    print("-" * 50)
    t, d = 3, 2
    for j in range(5):
        family = coefficient_family(t, d, 20, j)
        rec = detect_linear_recurrence(family)
        print(f"   j={j}: first values = {family[:8]}")
        if rec:
            order, coeffs = rec
            coeff_str = ", ".join(str(c) for c in coeffs)
            print(f"        Recurrence of order {order}: coeffs = [{coeff_str}]")
        print()

    # Demo 4: Weight power sums
    print("4. Weight Power Sums p_m(n; t,d)")
    print("-" * 50)
    t, d = 5, 6
    print(f"   t={t}, d={d}")
    for n in range(5):
        for m in range(1, 5):
            val = weight_power_sum(t, d, n, m)
            print(f"   p_{m}({n}; {t},{d}) = {val}")
        print()

    print("=" * 70)
    print("All algorithm demonstrations complete.")
    print("=" * 70)
