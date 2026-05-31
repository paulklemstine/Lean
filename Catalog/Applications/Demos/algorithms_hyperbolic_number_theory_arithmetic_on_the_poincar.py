#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Core Algorithms

Type-hinted implementations of the key algorithms for hyperbolic number theory.
"""

from typing import List, Tuple, Optional, Iterator
import math


def is_prime(n: int) -> bool:
    """
    Deterministic primality test using trial division.

    Time complexity: O(√n)

    Args:
        n: Integer to test.
    Returns:
        True if n is prime, False otherwise.
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


def lorentz_norm_sq(a: int, b: int) -> int:
    """
    Compute the Lorentzian norm squared: a² - b².

    This is the fundamental invariant of hyperbolic geometry,
    analogous to the Euclidean norm a² + b² in classical number theory.

    Args:
        a: First integer coordinate.
        b: Second integer coordinate.
    Returns:
        a² - b²
    """
    return a * a - b * b


def brahmagupta_product(
    a1: int, b1: int, a2: int, b2: int
) -> Tuple[int, int]:
    """
    Compute the Brahmagupta product of two Lorentzian lattice points.

    (a₁, b₁) × (a₂, b₂) = (a₁a₂ + b₁b₂, a₁b₂ + b₁a₂)

    This product preserves the Lorentzian norm:
    L(product) = L(a₁, b₁) · L(a₂, b₂)

    Args:
        a1, b1: First lattice point.
        a2, b2: Second lattice point.
    Returns:
        The Brahmagupta product (a₁a₂ + b₁b₂, a₁b₂ + b₁a₂).
    """
    return (a1 * a2 + b1 * b2, a1 * b2 + b1 * a2)


def brahmagupta_power(a: int, b: int, n: int) -> Tuple[int, int]:
    """
    Compute the n-th Brahmagupta power of (a, b) by repeated squaring.

    Time complexity: O(log n) multiplications.

    Args:
        a, b: Base lattice point.
        n: Exponent (non-negative).
    Returns:
        (a, b)^n under Brahmagupta multiplication.
    """
    if n == 0:
        return (1, 0)  # Identity element
    if n == 1:
        return (a, b)
    if n % 2 == 0:
        half = brahmagupta_power(a, b, n // 2)
        return brahmagupta_product(half[0], half[1], half[0], half[1])
    else:
        rest = brahmagupta_power(a, b, n - 1)
        return brahmagupta_product(a, b, rest[0], rest[1])


def enumerate_hyp_primes(N: int) -> List[Tuple[int, int, int]]:
    """
    Enumerate all consecutive hyperbolic primes (n+1, n) for n ≤ N.

    By the consecutive prime theorem, these exhaust all positive
    hyperbolic primes with both entries positive.

    Args:
        N: Upper bound on the index n.
    Returns:
        List of (n+1, n, 2n+1) triples where 2n+1 is prime.
    """
    result = []
    for n in range(1, N + 1):
        norm = 2 * n + 1
        if is_prime(norm):
            result.append((n + 1, n, norm))
    return result


def hyp_prime_counting(N: int) -> int:
    """
    Count consecutive hyperbolic primes with index ≤ N.

    This equals the number of odd primes ≤ 2N+1.

    Args:
        N: Upper bound.
    Returns:
        Number of n ∈ [1, N] with 2n+1 prime.
    """
    return sum(1 for n in range(1, N + 1) if is_prime(2 * n + 1))


def conformal_factor(z_re: float, z_im: float) -> float:
    """
    Compute the Poincaré disk conformal factor at z = z_re + i·z_im.

    λ(z) = 2 / (1 - |z|²)

    Args:
        z_re: Real part of z.
        z_im: Imaginary part of z.
    Returns:
        The conformal factor λ(z).
    Raises:
        ValueError if |z| ≥ 1 (point not in disk).
    """
    norm_sq = z_re * z_re + z_im * z_im
    if norm_sq >= 1.0:
        raise ValueError(f"|z|² = {norm_sq} ≥ 1: point not in Poincaré disk")
    return 2.0 / (1.0 - norm_sq)


def hyp_distance_from_origin(z_re: float, z_im: float) -> float:
    """
    Compute the hyperbolic distance from the origin to z in the Poincaré disk.

    d_H(0, z) = log((1 + |z|) / (1 - |z|))

    Args:
        z_re: Real part of z.
        z_im: Imaginary part of z.
    Returns:
        The hyperbolic distance d_H(0, z).
    """
    norm = math.sqrt(z_re * z_re + z_im * z_im)
    if norm >= 1.0:
        raise ValueError(f"|z| = {norm} ≥ 1: point not in Poincaré disk")
    if norm == 0.0:
        return 0.0
    return math.log((1 + norm) / (1 - norm))


def hyp_growth(k: int, r: int) -> int:
    """
    Compute the growth function G(k, r) = (2k+1)^r.

    This bounds the number of elements reachable by words of length r
    in a group with k generators and their inverses.

    Args:
        k: Number of generators.
        r: Radius (word length).
    Returns:
        (2k+1)^r.
    """
    return (2 * k + 1) ** r


def hyp_zeta_partial(s: float, N: int) -> float:
    """
    Compute the partial sum of the hyperbolic zeta function:
    ζ_H(s, N) = Σ_{k=0}^{N-1} 1/(2k+3)^s

    Args:
        s: Complex exponent (real part).
        N: Number of terms.
    Returns:
        The partial sum.
    """
    return sum(1.0 / (2 * k + 3) ** s for k in range(N))


def modular_S() -> List[List[int]]:
    """Return the modular group generator S = [[0,-1],[1,0]]."""
    return [[0, -1], [1, 0]]


def modular_T() -> List[List[int]]:
    """Return the modular group generator T = [[1,1],[0,1]]."""
    return [[1, 1], [0, 1]]


def mat_mul_2x2(A: List[List[int]], B: List[List[int]]) -> List[List[int]]:
    """Multiply two 2×2 integer matrices."""
    return [
        [A[0][0]*B[0][0]+A[0][1]*B[1][0], A[0][0]*B[0][1]+A[0][1]*B[1][1]],
        [A[1][0]*B[0][0]+A[1][1]*B[1][0], A[1][0]*B[0][1]+A[1][1]*B[1][1]],
    ]


def modular_T_pow(n: int) -> List[List[int]]:
    """Compute T^n = [[1,n],[0,1]] directly."""
    return [[1, n], [0, 1]]


def verify_density_conjecture(max_N: int = 10000) -> List[Tuple[int, bool, int, int]]:
    """
    Verify the hyperbolic prime density conjecture for N = 10, 20, ..., max_N.

    Conjecture: For all N ≥ 10,
    consHypPrimeCount(N) ≥ N / (3·log₂(N) + 1).

    Returns:
        List of (N, holds, count, lower_bound) tuples.
    """
    results = []
    N = 10
    while N <= max_N:
        count = hyp_prime_counting(N)
        log2_N = int(math.log2(N))
        lower = N // (3 * log2_N + 1)
        holds = lower <= count
        results.append((N, holds, count, lower))
        N = min(N * 2, max_N) if N < max_N else max_N + 1
    return results


if __name__ == "__main__":
    # Quick smoke test
    print("Brahmagupta identity test:")
    a1, b1, a2, b2 = 3, 2, 4, 3
    a3, b3 = brahmagupta_product(a1, b1, a2, b2)
    print(f"  ({a1},{b1}) × ({a2},{b2}) = ({a3},{b3})")
    print(f"  {lorentz_norm_sq(a1,b1)} × {lorentz_norm_sq(a2,b2)} = {lorentz_norm_sq(a3,b3)}")

    print("\nFirst 10 hyperbolic primes:")
    primes = enumerate_hyp_primes(20)
    for a, b, norm in primes[:10]:
        print(f"  ({a}, {b}) — norm {norm}")

    print("\nDensity conjecture verification:")
    for N, holds, count, lb in verify_density_conjecture(1000):
        print(f"  N={N}: count={count}, lower={lb}, holds={holds}")
