#!/usr/bin/env python3
"""
Algorithms for Mandelbrot Number Theory

Type-hinted implementations of the core algorithms connecting
quadratic iteration to number theory.
"""

from typing import List, Tuple, Optional
from functools import lru_cache


def moebius(n: int) -> int:
    """Compute the Möbius function μ(n).

    μ(1) = 1
    μ(n) = (-1)^k if n is a product of k distinct primes
    μ(n) = 0 if n has a squared prime factor

    Time complexity: O(√n)
    """
    if n <= 0:
        raise ValueError("Möbius function is defined for positive integers")
    if n == 1:
        return 1
    num_factors = 0
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            count = 0
            while temp % d == 0:
                temp //= d
                count += 1
            if count > 1:
                return 0
            num_factors += 1
        d += 1
    if temp > 1:
        num_factors += 1
    return (-1) ** num_factors


def divisors(n: int) -> List[int]:
    """Return sorted list of positive divisors of n.

    Time complexity: O(√n)
    """
    if n <= 0:
        raise ValueError("divisors defined for positive integers")
    small: List[int] = []
    large: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def dynatomic_sum(n: int) -> int:
    """Compute the dynatomic point count Ψ(n) = ∑_{d|n} μ(n/d) · 2^d.

    This counts the number of periodic points of exact period n
    for a generic degree-2 polynomial map (e.g., z → z² + c).

    Properties:
    - Ψ(p) = 2^p - 2 for prime p (connects to Fermat's little theorem)
    - Ψ(p^k) = 2^{p^k} - 2^{p^{k-1}} (totient analogy)
    - n | Ψ(n) for all n ≥ 1 (necklace divisibility)
    - Ψ(n) ≥ 0 for all n ≥ 1

    Time complexity: O(d(n) · n) where d(n) is the number of divisors
    """
    return sum(moebius(n // d) * (2 ** d) for d in divisors(n))


def necklace_number(n: int) -> int:
    """Count distinct binary necklaces of length n.

    A binary necklace is an equivalence class of binary strings
    under cyclic rotation. This equals Ψ(n)/n by Burnside's lemma.

    Examples:
    - N(1) = 2: "0" and "1"
    - N(2) = 3: "00", "01"≡"10", "11"
    - N(3) = 4: "000", "001"≡"010"≡"100", "011"≡"110"≡"101", "111"

    Time complexity: O(d(n) · n)
    """
    return dynatomic_sum(n) // n


def mandelbrot_iterate(c: complex, n: int) -> complex:
    """Compute the n-th Mandelbrot iterate f_c^n(0).

    The Mandelbrot iteration is defined by:
        z_0 = 0
        z_{k+1} = z_k² + c

    The Mandelbrot set M = {c ∈ ℂ : |f_c^n(0)| → ∞ as n → ∞}.

    Time complexity: O(n)
    """
    z = complex(0)
    for _ in range(n):
        z = z * z + c
    return z


def mandelbrot_period(c: complex, max_iter: int = 1000,
                       tolerance: float = 1e-10) -> Optional[int]:
    """Find the period of the critical orbit for parameter c.

    Returns the minimal n > 0 such that |f_c^n(0)| < tolerance,
    or None if no period is found within max_iter iterations.

    Time complexity: O(max_iter)
    """
    z = complex(0)
    for n in range(1, max_iter + 1):
        z = z * z + c
        if abs(z) < tolerance:
            return n
    return None


def tropical_iterate(c: float, z: float, n: int) -> float:
    """Compute the n-th tropical Mandelbrot iterate.

    In the tropical (max-plus) semiring:
        z² becomes 2z (tropical multiplication is addition)
        z + c becomes max(z, c) (tropical addition is max)

    So z ↦ z² + c becomes z ↦ max(2z, c).

    Key property: The tropical Mandelbrot set is {c ≤ 0}.

    Time complexity: O(n)
    """
    for _ in range(n):
        z = max(2 * z, c)
    return z


def mandelbrot_polynomial_coeffs(n: int) -> List[int]:
    """Compute coefficients of the n-th Mandelbrot polynomial P_n.

    P_n ∈ ℤ[X] satisfies P_n(c) = f_c^n(0).
    Recurrence: P_0 = 0, P_{n+1} = P_n² + X.

    Returns coefficients [a_0, a_1, ..., a_d] where P_n = ∑ a_i X^i.

    P_1 = X               → [0, 1]
    P_2 = X² + X           → [0, 1, 1]
    P_3 = X⁴+2X³+X²+X     → [0, 1, 1, 2, 1]

    Time complexity: O(2^n) (polynomial squaring)
    """
    if n == 0:
        return [0]

    # Polynomial multiplication
    def poly_mul(a: List[int], b: List[int]) -> List[int]:
        result = [0] * (len(a) + len(b) - 1)
        for i, ai in enumerate(a):
            for j, bj in enumerate(b):
                result[i + j] += ai * bj
        return result

    # Polynomial addition
    def poly_add(a: List[int], b: List[int]) -> List[int]:
        result = [0] * max(len(a), len(b))
        for i, ai in enumerate(a):
            result[i] += ai
        for i, bi in enumerate(b):
            result[i] += bi
        return result

    p = [0]  # P_0 = 0
    x = [0, 1]  # X
    for _ in range(n):
        p = poly_add(poly_mul(p, p), x)
    return p


def orbit_gcd_property(c_int: int, modulus: int) -> bool:
    """Verify the GCD theorem: if f^m(0) ≡ 0 and f^n(0) ≡ 0 mod p,
    then f^{gcd(m,n)}(0) ≡ 0 mod p.

    Time complexity: O(modulus²)
    """
    import math

    # Find all return times
    returns: List[int] = []
    z = 0
    for n in range(1, modulus * modulus + 1):
        z = (z * z + c_int) % modulus
        if z == 0:
            returns.append(n)
        if len(returns) >= 10:
            break

    # Check GCD property for all pairs
    for i, m in enumerate(returns):
        for n in returns[i + 1:]:
            g = math.gcd(m, n)
            z_g = 0
            for _ in range(g):
                z_g = (z_g * z_g + c_int) % modulus
            if z_g != 0:
                return False
    return True


# === Self-test ===
if __name__ == "__main__":
    # Test necklace divisibility
    for n in range(1, 30):
        psi = dynatomic_sum(n)
        assert psi % n == 0, f"Necklace divisibility failed for n={n}"
    print("✓ Necklace divisibility verified for n=1..29")

    # Test prime power formula
    for p in [2, 3, 5, 7]:
        for k in range(1, 6):
            pk = p ** k
            if pk > 500:
                continue
            psi = dynatomic_sum(pk)
            expected = 2 ** pk - 2 ** (p ** (k - 1))
            assert psi == expected, f"Prime power formula failed for {p}^{k}"
    print("✓ Prime power formula verified")

    # Test GCD property
    for p in [5, 7, 11, 13]:
        for c in range(p):
            assert orbit_gcd_property(c, p), f"GCD property failed for c={c} mod {p}"
    print("✓ GCD property verified for primes ≤ 13")

    # Test tropical dynamics
    assert tropical_iterate(-1, 0, 100) == 0, "Tropical bounded failed"
    assert tropical_iterate(2, 0, 5) == 32, "Tropical escape failed"
    print("✓ Tropical dynamics verified")

    print("\nAll self-tests passed!")
