#!/usr/bin/env python3
"""
Holographic Primes: Core Algorithms

Type-hinted implementations of the mathematical structures from the
holographic prime correspondence.
"""

from typing import List, Dict, Tuple, Optional
import math


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Return all primes up to n using the Sieve of Eratosthenes.

    Time complexity: O(n log log n)
    Space complexity: O(n)
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def p_adic_valuation(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n).

    The p-adic valuation is the largest k such that p^k divides n.
    In the holographic dictionary, this is the "depth" of n in the
    p-adic bulk geometry.

    Args:
        p: A prime number (p >= 2)
        n: A positive integer

    Returns:
        The p-adic valuation of n
    """
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        k += 1
        n //= p
    return k


def factorization(n: int) -> Dict[int, int]:
    """Compute the prime factorization of n.

    Returns a dictionary mapping primes to their exponents.
    In holographic terms, this maps each prime (boundary site)
    to the depth of n in that prime's bulk.
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


def total_holographic_weight(n: int) -> int:
    """Compute the total holographic weight Ω(n).

    The total weight is the sum of p-adic valuations across all primes
    dividing n. This equals the number of prime factors counted with
    multiplicity.

    In the holographic dictionary, this measures the "total bulk depth"
    of n — how deep it sits across all prime sectors simultaneously.
    """
    return sum(factorization(n).values())


def euler_product_partial(s: float, N: int) -> float:
    """Compute the partial Euler product ∏_{p≤N} (1 - p^{-s})^{-1}.

    This is the "holographic partition function" truncated to primes ≤ N.
    As N → ∞, it converges to ζ(s) for Re(s) > 1.

    Args:
        s: The complex frequency parameter (real part > 1)
        N: Upper bound for primes in the product

    Returns:
        The partial Euler product value
    """
    product = 1.0
    for p in sieve_of_eratosthenes(N):
        product /= (1.0 - p ** (-s))
    return product


def chebyshev_theta(n: int) -> float:
    """Compute the Chebyshev theta function θ(n) = Σ_{p≤n} log(p).

    In the holographic dictionary, θ(n) is the "boundary area" —
    the total information content of the boundary theory up to
    energy scale n.

    The Prime Number Theorem is equivalent to θ(n) ~ n.
    """
    return sum(math.log(p) for p in sieve_of_eratosthenes(n))


def chebyshev_psi(n: int) -> float:
    """Compute the Chebyshev psi function ψ(n) = Σ_{p^k≤n} log(p).

    ψ counts prime powers weighted by log. It's more natural from the
    holographic perspective because it includes contributions from all
    depths in the bulk (not just depth 1).
    """
    total = 0.0
    for p in sieve_of_eratosthenes(n):
        pk = p
        while pk <= n:
            total += math.log(p)
            pk *= p
    return total


def prime_partition_function(beta: float, N: int) -> float:
    """Compute the prime partition function Z(β) = ∏_p (1 - e^{-β log p})^{-1}.

    This is the "thermal partition function" of the holographic system
    at inverse temperature β. Setting β = s gives Z(s) = ζ(s).

    Args:
        beta: Inverse temperature parameter (> 0)
        N: Upper bound for primes

    Returns:
        The partition function value
    """
    product = 1.0
    for p in sieve_of_eratosthenes(N):
        boltzmann = math.exp(-beta * math.log(p))
        product /= (1.0 - boltzmann)
    return product


def holographic_entropy(n: int) -> float:
    """Compute the holographic entropy S(n) = log(n) - Σ_p v_p(n) log(p) / Ω(n).

    This measures the "disorder" in the prime decomposition of n.
    Numbers with few large prime factors have low entropy;
    numbers with many small prime factors have high entropy.
    """
    if n <= 1:
        return 0.0
    facts = factorization(n)
    omega = sum(facts.values())
    if omega == 0:
        return 0.0
    weighted_sum = sum(v * math.log(p) for p, v in facts.items())
    return math.log(n) - weighted_sum / omega


def boundary_projection(n: int, p: int) -> int:
    """Project n onto the boundary at prime p: n ↦ n mod p.

    This is the holographic projection from the bulk (ℤ) to the
    boundary (ℤ/pℤ).
    """
    return n % p


def holographic_distance(a: int, b: int, p: int) -> int:
    """Compute the holographic distance between a and b at prime p.

    d_p(a, b) = v_p(a - b), the p-adic valuation of the difference.
    Two numbers are "close" in the p-adic bulk if their difference
    is highly divisible by p.
    """
    if a == b:
        return float('inf')  # type: ignore
    return p_adic_valuation(p, abs(a - b))


def euler_factor_denominator(p: int, s: int) -> int:
    """Compute the Euler factor denominator p^s - 1.

    For p ≥ 2 and s ≥ 1, this is always positive,
    ensuring the partition function is well-defined.
    """
    return p ** s - 1


def partial_primorial(n: int) -> int:
    """Compute the primorial n# = product of primes ≤ n.

    This equals the partial Euler product at s=1.
    """
    result = 1
    for p in sieve_of_eratosthenes(n):
        result *= p
    return result


if __name__ == "__main__":
    # Quick sanity checks
    print("Primes up to 30:", sieve_of_eratosthenes(30))
    print("v_2(12) =", p_adic_valuation(2, 12))  # Should be 2
    print("v_3(12) =", p_adic_valuation(3, 12))  # Should be 1
    print("Ω(12) =", total_holographic_weight(12))  # Should be 3
    print("θ(100) =", chebyshev_theta(100))
    print("ψ(100) =", chebyshev_psi(100))
    print("Z(2, 100) =", prime_partition_function(2.0, 100))
    print("ζ(2) exact =", math.pi**2 / 6)
    print("Primorial 10# =", partial_primorial(10))  # 2*3*5*7 = 210
