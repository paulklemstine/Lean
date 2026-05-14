#!/usr/bin/env python3
"""
Tropical Quadratic Sieve: Algorithm Implementations

Implements the core algorithms from the research paper:
1. Smooth cost computation
2. Tropical sieve scoring
3. Tropical matrix-vector multiplication
4. Divisor tropical convolution
5. Full tropical quadratic sieve relation collector
"""

from typing import Dict, Set, List, Tuple, Optional
import math


# ============================================================
# Core: Prime Factorization
# ============================================================

def factorize(n: int) -> Dict[int, int]:
    """
    Compute the prime factorization of n.

    Returns:
        Dictionary mapping primes to their exponents.
        Empty dict for n <= 1.

    Example:
        >>> factorize(360)
        {2: 3, 3: 2, 5: 1}
    """
    if n <= 1:
        return {}
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def primes_up_to(B: int) -> List[int]:
    """Sieve of Eratosthenes returning primes up to B."""
    if B < 2:
        return []
    sieve = [True] * (B + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(B**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, B + 1, i):
                sieve[j] = False
    return [i for i in range(2, B + 1) if sieve[i]]


# ============================================================
# Algorithm 1: Smooth Cost Computation
# ============================================================

INF = float('inf')


def smooth_cost(P: Set[int], n: int) -> float:
    """
    Compute the tropical smoothness cost of n relative to factor base P.

    Algorithm: ComputeSmoothCost(P, n)
    1. Compute F ← factorize(n)
    2. cost ← 0
    3. For each (p, e) in F:
    4.     If p ∉ P: cost ← cost + e
    5. Return cost

    Args:
        P: Set of primes forming the factor base.
        n: Natural number to evaluate.

    Returns:
        The smooth cost (int for n > 0, inf for n = 0).

    Complexity: O(√n) for factorization, O(log n / log log n) for scoring.

    Example:
        >>> smooth_cost({2, 3, 5}, 60)  # 60 = 2² × 3 × 5
        0
        >>> smooth_cost({2, 3, 5}, 77)  # 77 = 7 × 11
        2
    """
    if n == 0:
        return INF
    factors = factorize(n)
    return sum(e for p, e in factors.items() if p not in P)


# ============================================================
# Algorithm 2: Tropical Sieve Scoring
# ============================================================

def tropical_sieve_score(
    N: int, M: int, R: int, P: Set[int]
) -> List[Tuple[int, int, float]]:
    """
    Compute tropical sieve scores for Q_N(x) = x² - N over [M, M+R).

    Algorithm: TropicalSieveScore(N, M, R, P)
    1. For x ← M to M+R-1:
    2.     Compute Q_N(x) = x² - N
    3.     If Q_N(x) > 0: score ← smoothCost(P, Q_N(x))
    4.     Else: score ← ⊤

    Args:
        N: Number to factor.
        M: Start of sieve interval.
        R: Length of sieve interval.
        P: Factor base (set of primes).

    Returns:
        List of (x, Q_N(x), smooth_cost) triples.

    Complexity: O(R · √max_Q) for brute-force; O(R · |P|) with sieve.

    Example:
        >>> scores = tropical_sieve_score(15347, 124, 10, {2,3,5,7,11,13})
        >>> [(x, q, c) for x, q, c in scores if c == 0]  # smooth values
    """
    results = []
    for x in range(M, M + R):
        qn = x * x - N
        if qn <= 0:
            results.append((x, qn, INF))
        else:
            cost = smooth_cost(P, qn)
            results.append((x, qn, cost))
    return results


# ============================================================
# Algorithm 3: Tropical Matrix-Vector Multiplication
# ============================================================

def tropical_mat_vec(
    M_mat: List[List[float]], v: List[float]
) -> List[float]:
    """
    Min-plus matrix-vector multiplication.

    Algorithm: TropicalMatVec(M, v)
    (M ⊗ v)(i) = min_j (M(i,j) + v(j))

    Args:
        M_mat: Matrix as list of rows, entries in ℝ ∪ {∞}.
        v: Vector, entries in ℝ ∪ {∞}.

    Returns:
        Result vector w where w[i] = min_j(M[i][j] + v[j]).

    Complexity: O(m · n) where M is m × n.

    Example:
        >>> M = [[0, 3, INF], [2, 0, 1]]
        >>> v = [1, 2, 4]
        >>> tropical_mat_vec(M, v)
        [1, 3]
    """
    m = len(M_mat)
    n = len(v)
    result = []
    for i in range(m):
        min_val = INF
        for j in range(n):
            val = M_mat[i][j] + v[j]
            if val < min_val:
                min_val = val
        result.append(min_val)
    return result


# ============================================================
# Algorithm 4: Divisor Tropical Convolution
# ============================================================

def divisors(n: int) -> List[int]:
    """Return all divisors of n."""
    if n <= 0:
        return []
    divs = []
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def divisor_trop_conv(
    f: callable, g: callable, n: int
) -> float:
    """
    Divisor tropical convolution of f and g at n.

    (f ★ g)(n) = min_{d | n} (f(d) + g(n/d))

    Args:
        f, g: Functions ℕ → ℝ ∪ {∞}.
        n: Point of evaluation.

    Returns:
        min over divisors d of n of f(d) + g(n/d).

    Complexity: O(τ(n)) where τ is the divisor function.

    Example:
        >>> f = lambda x: smooth_cost({2,3}, x)
        >>> divisor_trop_conv(f, f, 12)  # min over divisors of 12
    """
    if n <= 0:
        return INF
    return min(f(d) + g(n // d) for d in divisors(n))


# ============================================================
# Algorithm 5: Full Tropical QS Relation Collector
# ============================================================

def tropical_qs_collect_relations(
    N: int, B: int, R_half: int
) -> List[Tuple[int, int, Dict[int, int]]]:
    """
    Collect smooth relations for the quadratic sieve using tropical scoring.

    Algorithm:
    1. Build factor base P = {primes ≤ B with Legendre symbol (N/p) ≠ -1}
    2. Set sieve interval [⌈√N⌉ - R_half, ⌈√N⌉ + R_half]
    3. For each x in interval:
    4.     Compute Q = x² - N
    5.     If smoothCost(P, |Q|) = 0: record relation
    6. Return all smooth relations

    Args:
        N: Number to factor.
        B: Smoothness bound.
        R_half: Half-width of sieve interval.

    Returns:
        List of (x, Q_N(x), factorization) for smooth values.

    Example:
        >>> relations = tropical_qs_collect_relations(15347, 30, 500)
        >>> len(relations)  # number of smooth relations found
    """
    # Build factor base
    P_primes = primes_up_to(B)
    # Filter to primes where N is a quadratic residue
    P_filtered = []
    for p in P_primes:
        if p == 2 or pow(N % p, (p - 1) // 2, p) <= 1:
            P_filtered.append(p)
    P = set(P_filtered)

    # Sieve interval
    sqrt_N = int(math.isqrt(N))
    if sqrt_N * sqrt_N < N:
        sqrt_N += 1

    relations = []
    for x in range(max(sqrt_N - R_half, 1), sqrt_N + R_half + 1):
        Q = x * x - N
        if Q <= 0:
            continue
        cost = smooth_cost(P, Q)
        if cost == 0:
            factors = factorize(Q)
            relations.append((x, Q, factors))

    return relations


# ============================================================
# Algorithm 6: Valuation Vector (Exponent Profile)
# ============================================================

def valuation_vector(primes: List[int], n: int) -> List[int]:
    """
    Compute the valuation vector of n over a list of primes.

    The i-th component is v_{p_i}(n), the p_i-adic valuation of n.

    Args:
        primes: Ordered list of primes.
        n: Natural number.

    Returns:
        List of valuations [v_{p_1}(n), ..., v_{p_k}(n)].

    Example:
        >>> valuation_vector([2, 3, 5], 60)  # 60 = 2² × 3 × 5
        [2, 1, 1]
    """
    factors = factorize(n)
    return [factors.get(p, 0) for p in primes]


# ============================================================
# Main: Demonstrate algorithms
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("TROPICAL QUADRATIC SIEVE: ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Algorithm 1: Smooth cost
    print("\n--- Algorithm 1: Smooth Cost ---")
    P = {2, 3, 5, 7}
    for n in [1, 12, 60, 77, 360, 1001]:
        cost = smooth_cost(P, n)
        factors = factorize(n)
        print(f"  smoothCost({P}, {n}) = {cost}  "
              f"[{n} = {factors}]")

    # Algorithm 2: Tropical sieve
    print("\n--- Algorithm 2: Tropical Sieve Scoring ---")
    N = 2021
    M = int(math.isqrt(N)) + 1
    P = {2, 3, 5, 7, 11}
    scores = tropical_sieve_score(N, M, 50, P)
    smooth = [(x, q, c) for x, q, c in scores if c == 0]
    print(f"  N={N}, interval [{M}, {M+50}), base P={P}")
    print(f"  Smooth candidates: {len(smooth)}")
    for x, q, c in smooth[:5]:
        print(f"    x={x}, Q={q} = {factorize(q)}")

    # Algorithm 3: Tropical mat-vec
    print("\n--- Algorithm 3: Tropical Matrix-Vector ---")
    M_mat = [[0, 3, INF], [2, 0, 1], [INF, 1, 0]]
    v = [1, 2, 4]
    w = tropical_mat_vec(M_mat, v)
    print(f"  M = {M_mat}")
    print(f"  v = {v}")
    print(f"  M ⊗ v = {w}")

    # Algorithm 4: Divisor tropical convolution
    print("\n--- Algorithm 4: Divisor Tropical Convolution ---")
    P = {2, 3, 5}
    f = lambda n: smooth_cost(P, n)
    for n in [12, 30, 60, 77]:
        conv_val = divisor_trop_conv(f, f, n)
        direct = smooth_cost(P, n)
        print(f"  (f★f)({n}) = {conv_val}, smoothCost({n}) = {direct}, "
              f"conv ≤ direct: {conv_val <= direct}")

    # Algorithm 5: Full QS relation collection
    print("\n--- Algorithm 5: Tropical QS Relation Collection ---")
    N = 15347
    relations = tropical_qs_collect_relations(N, 30, 500)
    print(f"  N = {N}, B = 30, R = 1000")
    print(f"  Smooth relations found: {len(relations)}")
    for x, Q, factors in relations[:8]:
        print(f"    x={x}: {x}² - {N} = {Q} = {factors}")

    # Algorithm 6: Valuation vectors
    print("\n--- Algorithm 6: Valuation Vectors ---")
    primes = [2, 3, 5, 7]
    for n in [60, 42, 360, 77]:
        vec = valuation_vector(primes, n)
        print(f"  v({n}) over {primes} = {vec}")

    print("\n" + "=" * 60)
    print("All algorithm demonstrations completed.")
    print("=" * 60)
