#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the Oracle Spectral Algebra

Type-hinted implementations of the key algorithms from the L-Function Oracle research.
"""

import math
from typing import Callable, Dict, List, Optional, Tuple
from dataclasses import dataclass


# ============================================================
# Core Types
# ============================================================

@dataclass
class ArithmeticSpectrum:
    """An arithmetic spectrum: multiplicative function with Euler product structure."""
    coeff: Callable[[int], complex]
    conductor: int
    label: str = ""

    def __call__(self, n: int) -> complex:
        return self.coeff(n)


@dataclass
class OracleQuery:
    """A single oracle query and its result."""
    query_type: str  # "point", "derivative", "zero_cert", "euler_factor"
    parameter: any
    result: complex


class OraclePowerLevel:
    """The four levels of oracle power."""
    NO_ORACLE = 0
    POINT_EVAL = 1
    DERIVATIVE = 2
    ZERO_CERT = 3

    @staticmethod
    def name(level: int) -> str:
        return {0: "No Oracle", 1: "Point Evaluation",
                2: "Derivative", 3: "Zero Certificate"}[level]


# ============================================================
# Dirichlet Convolution
# ============================================================

def divisors(n: int) -> List[int]:
    """Compute all positive divisors of n in sorted order."""
    if n <= 0:
        return []
    result: List[int] = []
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            result.append(d)
            if d != n // d:
                result.append(n // d)
    return sorted(result)


def dirichlet_convolution(
    f: Callable[[int], complex],
    g: Callable[[int], complex],
    n: int
) -> complex:
    """
    Dirichlet convolution: (f * g)(n) = Σ_{d|n} f(d) · g(n/d)

    This is the multiplicative operation in the Oracle Spectral Algebra.
    Time complexity: O(d(n)) where d(n) is the number of divisors.

    Algorithm:
      FOR each divisor d of n:
        accumulate f(d) * g(n/d)
      RETURN sum
    """
    return sum(f(d) * g(n // d) for d in divisors(n))


def dirichlet_identity(n: int) -> complex:
    """The Dirichlet identity: ε(1) = 1, ε(n) = 0 for n > 1."""
    return complex(1, 0) if n == 1 else complex(0, 0)


# ============================================================
# Spectral Factoring Algorithm
# ============================================================

def sieve_primes(bound: int) -> List[int]:
    """Sieve of Eratosthenes up to bound."""
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(math.isqrt(bound)) + 1):
        if is_prime[i]:
            for j in range(i * i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(2, bound + 1) if is_prime[i]]


def spectral_factor(
    n: int,
    euler_oracle: Callable[[int, int], int]
) -> Tuple[List[int], int]:
    """
    Factor n using an Euler factor oracle.

    Algorithm:
      INPUT: n (integer to factor), euler_oracle (returns p if p|n)
      OUTPUT: list of prime factors, number of oracle queries

      1. FOR each prime p ≤ √n:
      2.   Query oracle(p, n)
      3.   IF oracle returns p (meaning p | n):
      4.     Compute gcd(p, n) to get factor
      5.     Recurse on n/p
      6. RETURN factors

    Theorem: At most π(√n) oracle queries suffice.
    """
    if n <= 1:
        return [], 0

    factors: List[int] = []
    queries = 0
    remaining = n

    primes = sieve_primes(int(math.isqrt(n)) + 1)

    for p in primes:
        if remaining <= 1:
            break
        while remaining % p == 0:
            queries += 1
            oracle_result = euler_oracle(p, remaining)
            if oracle_result > 0:
                factor = math.gcd(oracle_result, remaining)
                factors.append(factor)
                remaining //= factor
            else:
                break

    if remaining > 1:
        factors.append(remaining)

    return factors, queries


# ============================================================
# Vanishing Order Detection
# ============================================================

def detect_vanishing_order(
    derivative_oracle: Callable[[int], complex],
    max_order: int = 100,
    tolerance: float = 1e-12
) -> Optional[int]:
    """
    Detect the vanishing order using a derivative oracle.

    Algorithm:
      INPUT: derivative_oracle (returns f^(k)(s₀) for query k)
      OUTPUT: vanishing order r, or None if order > max_order

      1. FOR k = 0, 1, 2, ..., max_order:
      2.   Query derivative_oracle(k)
      3.   IF |result| > tolerance:
      4.     RETURN k  (this is the vanishing order)
      5. RETURN None  (order exceeds max_order)

    Theorem (Query Gap): Exactly r+1 queries are needed for order r.
    The first r queries necessarily return 0.
    """
    for k in range(max_order + 1):
        deriv_val = derivative_oracle(k)
        if abs(deriv_val) > tolerance:
            return k
    return None


# ============================================================
# Spectral Reconstruction
# ============================================================

def factorize(n: int) -> Dict[int, int]:
    """Return the prime factorization of n as {prime: exponent}."""
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


def spectral_reconstruct(
    prime_power_oracle: Callable[[int, int], complex],
    n: int
) -> complex:
    """
    Reconstruct f(n) from its values at prime powers.

    Algorithm:
      INPUT: prime_power_oracle (returns f(p^k)), n
      OUTPUT: f(n)

      1. Factorize n = p₁^k₁ · p₂^k₂ · ... · pₘ^kₘ
      2. FOR each (pᵢ, kᵢ):
      3.   Query prime_power_oracle(pᵢ, kᵢ)
      4. RETURN ∏ᵢ prime_power_oracle(pᵢ, kᵢ)

    Theorem (Spectral Reconstruction): This correctly recovers f(n)
    for any multiplicative function f.
    """
    if n <= 0:
        return complex(0, 0)
    if n == 1:
        return complex(1, 0)

    result = complex(1, 0)
    for p, k in factorize(n).items():
        result *= prime_power_oracle(p, k)
    return result


# ============================================================
# Oracle Hierarchy Separation
# ============================================================

def demonstrate_point_barrier(
    query_set: List[complex],
    target: complex
) -> Tuple[Callable, Callable]:
    """
    Construct two functions that agree on query_set but differ at target.

    This is the constructive proof of the point oracle barrier theorem.

    Returns (F, G) where:
    - F(z) = G(z) for all z in query_set
    - F(target) ≠ 0
    - G(target) = 0
    """
    query_set_set = set(query_set)

    def F(z: complex) -> complex:
        return complex(0, 0) if z in query_set_set else complex(1, 0)

    def G(z: complex) -> complex:
        return complex(0, 0)

    return F, G


def oracle_hierarchy_comparison() -> Dict[str, Dict[str, str]]:
    """
    Return a comparison table of oracle capabilities.
    """
    return {
        "Point Evaluation (Level 1)": {
            "CAN": "Evaluate L(s) at any s",
            "CANNOT": "Detect vanishing order (barrier theorem)",
            "ENABLES": "Identity principle: agreement on accumulation set → global equality",
            "QUERY_BOUND": "∞ for vanishing order"
        },
        "Derivative (Level 2)": {
            "CAN": "Compute all derivatives f^(k)(s₀)",
            "CANNOT": "Determine global zero distribution",
            "ENABLES": "BSD analytic rank, vanishing order detection",
            "QUERY_BOUND": "r+1 for vanishing order r"
        },
        "Zero Certificate (Level 3)": {
            "CAN": "List all zeros in any bounded region",
            "CANNOT": "Verify RH for infinite height (would need ∀T)",
            "ENABLES": "RH decidability up to any finite height T",
            "QUERY_BOUND": "1 for RH_T"
        }
    }


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    # Test Dirichlet convolution identity
    zeta = lambda n: complex(1, 0) if n >= 1 else complex(0, 0)
    for n in range(1, 20):
        assert abs(dirichlet_convolution(dirichlet_identity, zeta, n) - zeta(n)) < 1e-10

    # Test spectral factoring
    oracle = lambda p, n: p if n % p == 0 else 0
    factors, queries = spectral_factor(91, oracle)
    assert sorted(factors) == [7, 13], f"Expected [7, 13], got {factors}"
    print(f"91 = {' × '.join(map(str, factors))} ({queries} oracle queries)")

    # Test vanishing order detection for z^3 at z=0
    import math
    def z3_derivs(k: int) -> complex:
        # k-th derivative of z^3 at z=0: 0 for k<3, 6 for k=3, 0 for k>3
        if k == 3:
            return complex(6, 0)
        return complex(0, 0)

    order = detect_vanishing_order(z3_derivs)
    assert order == 3
    print(f"Vanishing order of z³ at 0: {order}")

    # Test spectral reconstruction with Liouville function
    liouville_oracle = lambda p, k: complex((-1)**k, 0)
    for n in [1, 2, 3, 4, 5, 6, 12, 30]:
        val = spectral_reconstruct(liouville_oracle, n)
        omega = sum(factorize(n).values())
        expected = (-1)**omega
        assert abs(val - expected) < 1e-10
    print("All spectral reconstruction tests passed!")

    # Display hierarchy
    hierarchy = oracle_hierarchy_comparison()
    for level, info in hierarchy.items():
        print(f"\n{level}:")
        for key, val in info.items():
            print(f"  {key}: {val}")
