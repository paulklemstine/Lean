#!/usr/bin/env python3
"""
Holographic Primes: Core Algorithms

Type-hinted implementations of the holographic prime dictionary.
"""

import math
from typing import List, Tuple, Dict, Callable


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Return all primes up to n using the Sieve of Eratosthenes.

    Time: O(n log log n), Space: O(n)
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


def prime_factorization(n: int) -> List[Tuple[int, int]]:
    """Return the prime factorization of n as [(p1, e1), (p2, e2), ...].

    Time: O(√n)
    """
    if n <= 1:
        return []
    factors: List[Tuple[int, int]] = []
    d = 2
    while d * d <= n:
        exp = 0
        while n % d == 0:
            n //= d
            exp += 1
        if exp > 0:
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors


def local_partition_function(p: int, beta: float) -> float:
    """Compute Z_p(β) = (1 - p^{-β})⁻¹.

    The local partition function in the holographic dictionary.
    Requires: p ≥ 2, β > 0.
    """
    return 1.0 / (1.0 - p ** (-beta))


def bulk_weight(p: int, beta: float) -> float:
    """Compute w_p(β) = -log(1 - p^{-β}).

    The bulk weight, satisfying w_p(β) = log Z_p(β).
    Requires: p ≥ 2, β > 0.
    """
    return -math.log(1.0 - p ** (-beta))


def boundary_entropy(p: int) -> float:
    """Compute S_p = log(p).

    The boundary entropy of prime p.
    """
    return math.log(p)


def holographic_free_energy(p: int, beta: float) -> float:
    """Compute F_p(β) = log(1 - p^{-β}).

    The holographic free energy, negative of the bulk weight.
    """
    return math.log(1.0 - p ** (-beta))


def chebyshev_theta(n: int) -> float:
    """Compute θ(n) = Σ_{p ≤ n, prime p} log(p).

    The boundary area in the holographic dictionary.
    Time: O(n log log n)
    """
    return sum(math.log(p) for p in sieve_of_eratosthenes(n))


def von_mangoldt(n: int) -> float:
    """Compute Λ(n).

    Returns log(p) if n = p^k for some prime p and k ≥ 1, else 0.
    Time: O(√n)
    """
    if n <= 1:
        return 0.0
    factors = prime_factorization(n)
    if len(factors) == 1:
        return math.log(factors[0][0])
    return 0.0


def moebius(n: int) -> int:
    """Compute μ(n), the Möbius function.

    μ(1) = 1
    μ(n) = (-1)^k if n is a product of k distinct primes
    μ(n) = 0 if n has a squared prime factor
    """
    if n == 1:
        return 1
    factors = prime_factorization(n)
    for _, e in factors:
        if e > 1:
            return 0
    return (-1) ** len(factors)


def euler_totient(n: int) -> int:
    """Compute φ(n), Euler's totient function.

    φ(n) = n · ∏_{p|n} (1 - 1/p)
    """
    if n <= 0:
        return 0
    result = n
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            while temp % d == 0:
                temp //= d
            result -= result // d
        d += 1
    if temp > 1:
        result -= result // temp
    return result


def omega_big(n: int) -> int:
    """Compute Ω(n), the number of prime factors with multiplicity.

    The "holographic depth" of n.
    """
    return sum(e for _, e in prime_factorization(n))


def omega_small(n: int) -> int:
    """Compute ω(n), the number of distinct prime factors."""
    return len(prime_factorization(n))


def liouville_function(n: int) -> int:
    """Compute λ(n) = (-1)^{Ω(n)}.

    The holographic parity function.
    """
    return (-1) ** omega_big(n)


def finite_euler_product(n: int, beta: float) -> float:
    """Compute ∏_{p ≤ n} Z_p(β).

    The truncated bulk partition function.
    """
    result = 1.0
    for p in sieve_of_eratosthenes(n):
        result *= local_partition_function(p, beta)
    return result


def holographic_reconstruction(n: int) -> float:
    """Reconstruct log(n) from von Mangoldt boundary data.

    Computes Σ_{d|n} Λ(d) = log(n).
    Time: O(√n · d(n)) where d(n) = number of divisors
    """
    if n <= 0:
        return 0.0
    total = 0.0
    for d in range(1, n + 1):
        if n % d == 0:
            total += von_mangoldt(d)
    return total


def moebius_inversion(
    f: Callable[[int], float],
    n: int
) -> float:
    """Apply Möbius inversion: g(n) = Σ_{d|n} μ(d) · f(n/d).

    Given f = g * 1 (Dirichlet convolution with constant 1),
    recovers g via the holographic inverse transform.
    """
    total = 0.0
    for d in range(1, n + 1):
        if n % d == 0:
            total += moebius(d) * f(n // d)
    return total


def tropical_gap(p: int, beta: float) -> float:
    """Compute the tropical-algebraic gap: Z_p(β) - exp(p^{-β}).

    This measures how much the tropical approximation underestimates
    the exact partition function. Always ≥ 0.
    """
    return local_partition_function(p, beta) - math.exp(p ** (-beta))


def prime_zeta(beta: float, n_terms: int = 10000) -> float:
    """Compute the prime zeta function P(β) = Σ_p p^{-β}.

    Converges for β > 1. Uses primes up to n_terms.
    """
    return sum(p ** (-beta) for p in sieve_of_eratosthenes(n_terms))


def holographic_dictionary() -> Dict[str, str]:
    """Return the holographic dictionary mapping physics ↔ number theory."""
    return {
        "Boundary CFT": "Ring Z/pZ for each prime p",
        "Bulk gravity": "p-adic field Q_p",
        "Local partition function": "Z_p(β) = (1 - p^{-β})⁻¹",
        "Bulk partition function": "Riemann zeta ζ(s)",
        "Holographic assembly": "Euler product formula",
        "Holographic duality": "Functional equation Ξ(1-s) = Ξ(s)",
        "Boundary entropy": "log(p)",
        "Bulk reconstruction": "Von Mangoldt: Σ Λ(d) = log(n)",
        "Holographic inverse": "Möbius function: μ * ζ = ε",
        "RG flow parameter": "Depth β",
        "c-theorem": "Z_p(β) strictly decreasing",
        "Boundary factorization": "CRT: Z/mnZ ≅ Z/mZ × Z/nZ",
    }


if __name__ == "__main__":
    print("Holographic Dictionary:")
    for physics, math_ in holographic_dictionary().items():
        print(f"  {physics:30s} ↔ {math_}")
