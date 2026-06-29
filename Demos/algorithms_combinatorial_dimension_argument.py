#!/usr/bin/env python3
"""
Algorithms for Cap Set Analysis and the Polynomial Method

Implements:
1. Fast cap set verification and enumeration
2. Efficient monomial counting via dynamic programming
3. Kernel matrix construction and rank analysis
4. EG bound computation with generating functions
5. Asymptotic analysis of the exponential base
"""

import numpy as np
from itertools import product
from typing import List, Tuple, Optional, Dict
from functools import lru_cache
import math


# ============================================================
# Algorithm 1: Cap Set Verification
# ============================================================

def verify_cap_set(A: List[Tuple[int, ...]], n: int) -> Tuple[bool, Optional[Tuple]]:
    """
    Verify whether A is a cap set in F_3^n.

    Algorithm:
    - For each pair (x, y) in A, compute z = -(x+y) mod 3
    - Check if z is in A and z != x or z != y
    - Uses hash set for O(1) membership testing

    Time: O(|A|^2)
    Space: O(|A|)

    Returns: (is_valid, counterexample_or_None)
    """
    A_set = set(A)
    for x in A:
        for y in A:
            z = tuple((3 - x[i] - y[i]) % 3 for i in range(n))
            if z in A_set and not (x == y == z):
                return False, (x, y, z)
    return True, None


# ============================================================
# Algorithm 2: Monomial Counting via Dynamic Programming
# ============================================================

def count_monomials_by_degree(n: int, q: int = 3) -> List[int]:
    """
    Count reduced monomials in n variables over F_q by total degree.

    Returns c[k] = number of n-tuples in {0,...,q-1}^n with sum = k.
    This equals the coefficient of x^k in (1 + x + ... + x^{q-1})^n.

    Algorithm: Convolution via dynamic programming.

    Time: O(n * (q-1) * n)
    Space: O((q-1) * n)

    Args:
        n: Number of variables
        q: Field size (default 3)

    Returns:
        List of length (q-1)*n + 1, where c[k] = #{m : sum(m) = k}
    """
    max_deg = (q - 1) * n
    # dp[k] = number of tuples with sum k using i variables
    dp = [0] * (max_deg + 1)
    dp[0] = 1

    for _ in range(n):
        new_dp = [0] * (max_deg + 1)
        for k in range(max_deg + 1):
            if dp[k] == 0:
                continue
            for j in range(q):
                if k + j <= max_deg:
                    new_dp[k + j] += dp[k]
        dp = new_dp

    return dp


def cumulative_monomial_count(n: int, q: int = 3) -> List[int]:
    """
    Compute D(d) = number of reduced monomials with total degree <= d.

    Returns: List where result[d] = D(d) for d = 0, 1, ..., (q-1)*n.

    Time: O(n * q * n)
    Space: O(q * n)
    """
    by_degree = count_monomials_by_degree(n, q)
    cumulative = [0] * len(by_degree)
    running = 0
    for k in range(len(by_degree)):
        running += by_degree[k]
        cumulative[k] = running
    return cumulative


def eg_bound(n: int, q: int = 3) -> int:
    """
    Compute the Ellenberg-Gijswijt bound for cap sets in F_q^n.

    The bound is: |A| <= q * D(floor((q-1)*n/q))

    where D(d) = #{m in {0,...,q-1}^n : sum(m) <= d}.

    Time: O(n^2 * q)
    Space: O(n * q)
    """
    d = ((q - 1) * n) // q  # floor((q-1)*n/q) for general q
    cumul = cumulative_monomial_count(n, q)
    D_d = cumul[min(d, len(cumul) - 1)]
    return q * D_d


# ============================================================
# Algorithm 3: Kernel Matrix Construction
# ============================================================

def build_kernel_matrix(A: List[Tuple[int, ...]], n: int) -> np.ndarray:
    """
    Build the kernel matrix M(a,b) = sum_{c in A} Delta(a+b+c) over F_3.

    On a cap set, M should equal the identity matrix.

    Time: O(|A|^3 * n)
    Space: O(|A|^2)
    """
    m = len(A)
    M = np.zeros((m, m), dtype=int)

    for i in range(m):
        for j in range(m):
            for k in range(m):
                v = tuple((A[i][l] + A[j][l] + A[k][l]) % 3 for l in range(n))
                if all(x == 0 for x in v):
                    M[i, j] = (M[i, j] + 1) % 3

    return M


def verify_kernel_identity(A: List[Tuple[int, ...]], n: int) -> bool:
    """
    Verify that the kernel matrix equals the identity on a cap set.
    This is the structural heart of the EG argument.
    """
    M = build_kernel_matrix(A, n)
    return np.array_equal(M, np.eye(len(A), dtype=int))


# ============================================================
# Algorithm 4: Asymptotic Analysis
# ============================================================

def exponential_base(n: int, q: int = 3) -> float:
    """
    Compute the effective exponential base of the EG bound.

    Returns c such that q * D(floor((q-1)*n/q)) ~ C * c^n.

    For F_3: the base approaches q * (q-1)^{(q-1)/q} / q^{1/q}
           = 3 * 2^{2/3} / 3^{1/3} ≈ 2.756.
    """
    bound = eg_bound(n, q)
    if bound <= 0 or n == 0:
        return float('inf')
    return bound ** (1.0 / n)


def theoretical_base(q: int = 3) -> float:
    """
    Compute the theoretical asymptotic base for the EG bound.

    For F_q, the base is q * ((q-1)/q)^{(q-1)} * (1/q)^{1} ... hmm.

    Actually, using the saddle point: the base is
    min over t > 0 of q * (1 + t + ... + t^{q-1})^{1} * t^{-(q-1)/q}

    For q=3: minimize f(t) = 3 * (1+t+t^2) * t^{-2/3}
    """
    from scipy.optimize import minimize_scalar

    def f(t):
        if t <= 0:
            return float('inf')
        poly = sum(t ** j for j in range(q))
        return q * poly * t ** (-(q - 1.0) / q)

    try:
        result = minimize_scalar(f, bounds=(0.01, 10), method='bounded')
        return result.fun
    except Exception:
        # Fallback for q=3
        if q == 3:
            return 3 * 2 ** (2 / 3) / 3 ** (1 / 3)
        return float('nan')


def density_decay_table(max_n: int = 20, q: int = 3) -> List[Dict]:
    """
    Generate a table showing how cap set density decays with dimension.

    Returns list of dicts with keys: n, trivial_bound, eg_bound,
    density_ratio, effective_base.
    """
    results = []
    for n in range(1, max_n + 1):
        trivial = q ** n
        bound = eg_bound(n, q)
        ratio = bound / trivial
        base = exponential_base(n, q)
        results.append({
            'n': n,
            'trivial_bound': trivial,
            'eg_bound': bound,
            'density_ratio': ratio,
            'effective_base': base
        })
    return results


# ============================================================
# Algorithm 5: Cap Set Construction (Greedy)
# ============================================================

def greedy_cap_set(n: int) -> List[Tuple[int, ...]]:
    """
    Construct a cap set in F_3^n using a greedy algorithm.

    Algorithm:
    - Order points of F_3^n (lexicographic)
    - For each point, add it to A if the cap property is maintained
    - Uses hash set for fast checking

    Time: O(3^n * |A| * n) where |A| is the output size
    Space: O(3^n)

    Note: This does NOT find the maximum cap set, but gives
    a reasonable lower bound.
    """
    all_points = list(product(range(3), repeat=n))
    A = []
    forbidden = set()

    for p in all_points:
        if p in forbidden:
            continue
        A.append(p)
        # For each existing point a in A, forbid -(a+p) mod 3
        for a in A[:-1]:
            z = tuple((3 - a[i] - p[i]) % 3 for i in range(n))
            forbidden.add(z)

    return A


# ============================================================
# Main: Run all algorithms with example outputs
# ============================================================

if __name__ == "__main__":
    print("Cap Set Polynomial Method - Algorithm Suite")
    print("=" * 60)
    print()

    # Algorithm 1: Cap set verification
    print("Algorithm 1: Cap Set Verification")
    print("-" * 40)
    A_valid = [(0, 0), (0, 1), (1, 0), (1, 1)]
    A_invalid = [(0, 0), (0, 1), (0, 2)]  # 0+1+2 = 0 mod 3
    print(f"  A = {A_valid}: valid = {verify_cap_set(A_valid, 2)[0]}")
    result, cex = verify_cap_set(A_invalid, 2)
    print(f"  A = {A_invalid}: valid = {result}, counterexample = {cex}")
    print()

    # Algorithm 2: Monomial counting
    print("Algorithm 2: Monomial Counting")
    print("-" * 40)
    for n in range(1, 8):
        coeffs = count_monomials_by_degree(n)
        d = (2 * n) // 3
        D_d = sum(coeffs[:d + 1])
        total = sum(coeffs)
        print(f"  n={n}: D({d}) = {D_d}, total = {total}, "
              f"EG bound = {3 * D_d}")
    print()

    # Algorithm 3: Kernel matrix
    print("Algorithm 3: Kernel Matrix Identity")
    print("-" * 40)
    for n in range(1, 4):
        A = greedy_cap_set(n)
        valid = verify_cap_set(A, n)[0]
        if valid:
            is_id = verify_kernel_identity(A, n)
            print(f"  n={n}: |A| = {len(A)}, "
                  f"M = Identity? {is_id}")
    print()

    # Algorithm 4: Asymptotic analysis
    print("Algorithm 4: Density Decay Analysis")
    print("-" * 40)
    table = density_decay_table(15)
    print(f"  {'n':>3} | {'EG bound':>10} | {'3^n':>10} | "
          f"{'Density':>8} | {'Base':>8}")
    print("  " + "-" * 50)
    for row in table:
        print(f"  {row['n']:>3} | {row['eg_bound']:>10} | "
              f"{row['trivial_bound']:>10} | "
              f"{row['density_ratio']:>8.4f} | "
              f"{row['effective_base']:>8.4f}")

    try:
        base = theoretical_base(3)
        print(f"\n  Theoretical asymptotic base: {base:.6f}")
    except ImportError:
        print("\n  (scipy not available for theoretical base)")

    # Algorithm 5: Greedy cap sets
    print()
    print("Algorithm 5: Greedy Cap Set Construction")
    print("-" * 40)
    for n in range(1, 8):
        A = greedy_cap_set(n)
        valid = verify_cap_set(A, n)[0]
        bound = eg_bound(n)
        print(f"  n={n}: greedy |A| = {len(A)}, "
              f"EG bound = {bound}, valid = {valid}")
