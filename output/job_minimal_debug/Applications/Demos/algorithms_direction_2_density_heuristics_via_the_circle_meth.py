#!/usr/bin/env python3
"""
Certified Algorithms for Local Density Computation in the Three Cubes Problem

These algorithms mirror the formally verified definitions in the Lean development.
Each function corresponds to a Lean definition with proved correctness properties:
- threeCubeResidueCount: count of solutions mod n
- threeCubeLocalDensity: normalized density (count / n²)
- truncatedSingularSeries: product of local densities at primes

Complexity Analysis:
- three_cube_residue_count(k, n): O(n³) time, O(1) space
- local_density(k, n): O(n³) time, O(1) space
- truncated_singular_series(k, P): O(Σ_{p≤P} p³) time
- empirical_count(k, N): O(N³) time, O(1) space

The algorithms are designed for mathematical correctness rather than speed.
For large-scale computation, FFT-based methods over Z/nZ would be preferred.
"""

from typing import List, Tuple, Dict
from fractions import Fraction
import math


def sieve_primes(limit: int) -> List[int]:
    """
    Compute all primes up to `limit` using the Sieve of Eratosthenes.

    Args:
        limit: Upper bound for prime search.

    Returns:
        Sorted list of primes ≤ limit.

    Example:
        >>> sieve_primes(20)
        [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def three_cube_residue_count(k: int, n: int) -> int:
    """
    Count solutions to a³ + b³ + c³ ≡ k (mod n) in (Z/nZ)³.

    This is the computational counterpart of the Lean definition
    `threeCubeResidueCount`, which counts elements of `threeCubeResidueSet`.

    Verified properties (proved in Lean):
    - Nonnegativity: result ≥ 0 (trivial for ℕ)
    - Positivity: if k = x³+y³+z³ for some integers, then result > 0
    - Multiplicativity: if gcd(m,n) = 1, then count(k, m*n) = count(k,m) * count(k,n)

    Args:
        k: Target integer value.
        n: Modulus (must be ≥ 1).

    Returns:
        Number of solutions in (Z/nZ)³.

    Time: O(n³), Space: O(1)

    Example:
        >>> three_cube_residue_count(0, 9)
        189
        >>> three_cube_residue_count(4, 9)
        0
    """
    assert n >= 1, "Modulus must be positive"
    k_mod = k % n
    count = 0
    for a in range(n):
        a3 = (a * a * a) % n
        for b in range(n):
            ab3 = (a3 + b * b * b) % n
            for c in range(n):
                if (ab3 + c * c * c) % n == k_mod:
                    count += 1
    return count


def three_cube_residue_count_exact(k: int, n: int) -> Fraction:
    """Exact rational count (for verification purposes)."""
    return Fraction(three_cube_residue_count(k, n))


def local_density(k: int, n: int) -> Fraction:
    """
    Compute δ_k(n) = #Sol(n) / n², the local density.

    This is the circle-method normalization for a codimension-1
    variety in 3 variables. It equals n times the uniform probability.

    Verified properties (proved in Lean):
    - Nonnegativity: δ_k(n) ≥ 0
    - Positivity: if k is a sum of three cubes, then δ_k(n) > 0 for all n ≥ 1
    - Multiplicativity: if gcd(m,n)=1, δ_k(mn) = δ_k(m) · δ_k(n)
    - Probability bridge: δ_k(n) = n · Pr[a³+b³+c³ ≡ k (mod n)]

    Args:
        k: Target integer value.
        n: Modulus (must be ≥ 1).

    Returns:
        Exact rational local density.

    Example:
        >>> local_density(0, 9)
        Fraction(7, 3)
        >>> local_density(4, 9)
        Fraction(0, 1)
    """
    return Fraction(three_cube_residue_count(k, n), n ** 2)


def uniform_probability(k: int, n: int) -> Fraction:
    """
    Pr[a³+b³+c³ ≡ k (mod n)] for uniform random (a,b,c) ∈ (Z/nZ)³.

    Related to local density by: δ_k(n) = n · Pr (proved in Lean).

    Args:
        k: Target integer value.
        n: Modulus (must be ≥ 1).

    Returns:
        Exact rational probability.
    """
    return Fraction(three_cube_residue_count(k, n), n ** 3)


def truncated_singular_series(k: int, prime_bound: int) -> Fraction:
    """
    Compute the squarefree truncated singular series:
        S^sf_{≤P}(k) = ∏_{p ≤ P, p prime} δ_k(p)

    Verified properties (proved in Lean):
    - Nonnegativity: S ≥ 0
    - Positivity: if k is a sum of three cubes, then S > 0
    - Specification: S = ∏ (count(k,p) / p²)

    Args:
        k: Target integer value.
        prime_bound: Include all primes up to this bound.

    Returns:
        Exact rational truncated singular series value.

    Example:
        >>> truncated_singular_series(0, 7)
        Fraction(...)
    """
    primes = sieve_primes(prime_bound)
    product = Fraction(1)
    for p in primes:
        product *= local_density(k, p)
    return product


def is_admissible_mod9(k: int) -> bool:
    """Check if k ≡ 4 or 5 (mod 9), which gives a local obstruction."""
    return (k % 9) not in (4, 5)


def empirical_count(k: int, N: int) -> int:
    """
    R_k(N) = #{(x,y,z) ∈ Z³ : |x|,|y|,|z| ≤ N, x³+y³+z³ = k}.

    Args:
        k: Target sum.
        N: Box radius.

    Returns:
        Number of representations.

    Time: O(N³), Space: O(1)
    """
    count = 0
    for x in range(-N, N + 1):
        x3 = x ** 3
        for y in range(-N, N + 1):
            xy3 = x3 + y ** 3
            for z in range(-N, N + 1):
                if xy3 + z ** 3 == k:
                    count += 1
    return count


def verify_multiplicativity(k: int, m: int, n: int) -> bool:
    """
    Verify the CRT multiplicativity theorem for specific values.

    Checks: #Sol(k, m*n) = #Sol(k, m) * #Sol(k, n)
    when gcd(m, n) = 1.

    This is the computational validation of the Lean theorem
    `threeCubeResidueCount_mul_of_coprime`.
    """
    assert math.gcd(m, n) == 1, f"m={m} and n={n} must be coprime"
    cnt_mn = three_cube_residue_count(k, m * n)
    cnt_m = three_cube_residue_count(k, m)
    cnt_n = three_cube_residue_count(k, n)
    return cnt_mn == cnt_m * cnt_n


def compute_density_table(k_values: List[int], prime_bound: int) -> Dict:
    """
    Compute a full density table for given k values and primes up to prime_bound.

    Returns a dictionary mapping k to a dict of {p: density} pairs.
    """
    primes = sieve_primes(prime_bound)
    table = {}
    for k in k_values:
        table[k] = {}
        for p in primes:
            table[k][p] = local_density(k, p)
    return table


if __name__ == "__main__":
    print("=== Certified Algorithm Demonstrations ===\n")

    # 1. Basic counts
    print("1. Residue counts at n=9:")
    for k in range(10):
        cnt = three_cube_residue_count(k, 9)
        adm = "admissible" if is_admissible_mod9(k) else "OBSTRUCTED"
        print(f"   k={k}: count={cnt:4d}, density={float(local_density(k, 9)):.4f} [{adm}]")

    # 2. Multiplicativity
    print("\n2. CRT multiplicativity verification:")
    for m, n in [(2, 3), (2, 5), (3, 5), (3, 7)]:
        for k in [0, 1, 2]:
            ok = verify_multiplicativity(k, m, n)
            print(f"   k={k}, m={m}, n={n}: {'✓' if ok else '✗'}")

    # 3. Truncated singular series
    print("\n3. Truncated singular series S^sf_{≤P}(k):")
    for k in [0, 1, 2, 3]:
        for P in [2, 5, 11, 13]:
            ss = truncated_singular_series(k, P)
            print(f"   k={k}, P≤{P:2d}: S = {float(ss):.6f} (exact: {ss})")

    # 4. Probability bridge
    print("\n4. Probability bridge: δ_k(n) = n · Pr:")
    for n in [2, 3, 5, 7]:
        for k in [0, 1]:
            d = local_density(k, n)
            p = uniform_probability(k, n)
            assert d == n * p, f"Bridge failed for k={k}, n={n}"
            print(f"   k={k}, n={n}: δ={float(d):.4f} = {n}·{float(p):.4f} ✓")
