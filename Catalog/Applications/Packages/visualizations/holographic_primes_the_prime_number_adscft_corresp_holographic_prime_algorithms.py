#!/usr/bin/env python3
"""
Algorithms for Holographic Prime Theory

Implements efficient algorithms for computing holographic prime data:
- Local partition functions
- Finite Euler products
- Chebyshev theta function
- Tropical bounds
- Von Mangoldt reconstruction
"""

import math
from typing import List, Tuple, Dict, Optional


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Generate all primes up to n using the Sieve of Eratosthenes.

    Time: O(n log log n)
    Space: O(n)

    >>> sieve_of_eratosthenes(20)
    [2, 3, 5, 7, 11, 13, 17, 19]
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


def local_partition_function(p: int, beta: float) -> float:
    """Compute Z_p(β) = (1 - p^(-β))⁻¹ for a prime p.

    This is the local boundary partition function in the prime hologram.

    Args:
        p: A prime number (must be ≥ 2)
        beta: Inverse temperature (must be > 0)

    Returns:
        The local partition function value

    Time: O(log β) for exponentiation
    Space: O(1)

    >>> abs(local_partition_function(2, 2) - 4/3) < 1e-10
    True
    """
    return 1.0 / (1.0 - p ** (-beta))


def bulk_weight(p: int, beta: float) -> float:
    """Compute w_p(β) = -log(1 - p^(-β)), the bulk weight / free energy.

    Args:
        p: A prime number (must be ≥ 2)
        beta: Inverse temperature (must be > 0)

    Returns:
        The bulk weight (always non-negative for beta > 0)

    >>> bulk_weight(2, 2) > 0
    True
    """
    return -math.log(1.0 - p ** (-beta))


def boundary_entropy(p: int) -> float:
    """Compute S_p = log(p), the boundary entropy.

    Args:
        p: A prime number

    Returns:
        log(p), the information content of Z/pZ

    >>> abs(boundary_entropy(2) - math.log(2)) < 1e-10
    True
    """
    return math.log(p)


def finite_euler_product(N: int, beta: float) -> float:
    """Compute ∏_{p≤N} (1 - p^(-β))⁻¹, the finite Euler product.

    This is the finite truncation of the holographic partition function.
    For beta > 1, this converges to ζ(β) as N → ∞.

    Args:
        N: Upper bound for primes
        beta: Inverse temperature (must be > 1 for convergence)

    Returns:
        The finite Euler product

    Time: O(N log log N) for sieve + O(π(N)) for product
    Space: O(N)

    >>> abs(finite_euler_product(10000, 2) - math.pi**2/6) < 0.01
    True
    """
    primes = sieve_of_eratosthenes(N)
    product = 1.0
    for p in primes:
        product *= local_partition_function(p, beta)
    return product


def chebyshev_theta(n: int) -> float:
    """Compute θ(n) = ∑_{p≤n} log(p), the Chebyshev theta function.

    In the holographic framework, this is the boundary area.

    Args:
        n: Upper bound

    Returns:
        The Chebyshev theta value

    Time: O(n log log n)
    Space: O(n)

    >>> abs(chebyshev_theta(10) - (math.log(2) + math.log(3) + math.log(5) + math.log(7))) < 1e-10
    True
    """
    primes = sieve_of_eratosthenes(n)
    return sum(math.log(p) for p in primes)


def von_mangoldt(n: int) -> float:
    """Compute Λ(n): the von Mangoldt function.

    Returns log(p) if n = p^k for some prime p and k ≥ 1, else 0.

    Args:
        n: Positive integer

    Returns:
        Λ(n)

    >>> abs(von_mangoldt(8) - math.log(2)) < 1e-10
    True
    >>> von_mangoldt(6)
    0.0
    """
    if n <= 1:
        return 0.0
    for p in range(2, n + 1):
        if p * p > n:
            break
        if n % p == 0:
            m = n
            while m % p == 0:
                m //= p
            return math.log(p) if m == 1 else 0.0
    return math.log(n)


def divisors(n: int) -> List[int]:
    """Return all divisors of n in sorted order.

    >>> divisors(12)
    [1, 2, 3, 4, 6, 12]
    """
    divs = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


def holographic_reconstruction(n: int) -> Tuple[float, float]:
    """Verify ∑_{d|n} Λ(d) = log(n) for a given n.

    Returns (sum_lambda, log_n) so you can check they match.

    >>> s, l = holographic_reconstruction(12)
    >>> abs(s - l) < 1e-10
    True
    """
    sum_lambda = sum(von_mangoldt(d) for d in divisors(n))
    return sum_lambda, math.log(n)


def tropical_bound_verification(N: int, beta: float) -> Tuple[float, float, bool]:
    """Verify exp(∑ p⁻ᵝ) ≤ ∏(1 - p⁻ᵝ)⁻¹ for primes up to N.

    Returns (lhs, rhs, valid).

    >>> lhs, rhs, valid = tropical_bound_verification(100, 2)
    >>> valid
    True
    """
    primes = sieve_of_eratosthenes(N)
    prime_sum = sum(p ** (-beta) for p in primes)
    lhs = math.exp(prime_sum)
    rhs = 1.0
    for p in primes:
        rhs *= local_partition_function(p, beta)
    return lhs, rhs, lhs <= rhs + 1e-10


def prime_zeta(beta: float, N: int = 100000) -> float:
    """Compute P(β) = ∑_{p≤N} p⁻ᵝ, the prime zeta function.

    Args:
        beta: Exponent (must be > 1 for convergence)
        N: Number of primes to include

    Returns:
        Finite approximation to P(β)
    """
    primes = sieve_of_eratosthenes(N)
    return sum(p ** (-beta) for p in primes)


def holographic_entropy_partial(N: int) -> float:
    """Compute ∑_{p≤N} 1/p, the partial holographic entropy.

    >>> holographic_entropy_partial(10) > 0
    True
    """
    primes = sieve_of_eratosthenes(N)
    return sum(1.0 / p for p in primes)


def log_euler_product_decomposition(
    N: int, beta: float
) -> Tuple[float, List[Tuple[int, float]]]:
    """Decompose log ∏(1-p⁻ᵝ)⁻¹ = ∑(-log(1-p⁻ᵝ)) into individual terms.

    Returns (total, [(p, weight), ...]) showing each prime's contribution.

    >>> total, terms = log_euler_product_decomposition(10, 2)
    >>> abs(total - sum(w for _, w in terms)) < 1e-10
    True
    """
    primes = sieve_of_eratosthenes(N)
    terms = [(p, bulk_weight(p, beta)) for p in primes]
    total = sum(w for _, w in terms)
    return total, terms


if __name__ == "__main__":
    print("Holographic Prime Algorithms — Quick Test")
    print("=" * 50)

    # Test Euler product
    ep = finite_euler_product(10000, 2)
    print(f"ζ(2) ≈ {ep:.10f} (exact: {math.pi**2/6:.10f})")

    # Test tropical bound
    lhs, rhs, valid = tropical_bound_verification(1000, 2)
    print(f"Tropical bound: {lhs:.6f} ≤ {rhs:.6f} → {valid}")

    # Test reconstruction
    for n in [12, 60, 100]:
        s, l = holographic_reconstruction(n)
        print(f"∑Λ(d|{n}) = {s:.6f}, log({n}) = {l:.6f}, match: {abs(s-l) < 1e-10}")

    # Test entropy divergence
    for N in [100, 1000, 10000, 100000]:
        h = holographic_entropy_partial(N)
        print(f"∑_{{p≤{N}}} 1/p = {h:.6f}")
