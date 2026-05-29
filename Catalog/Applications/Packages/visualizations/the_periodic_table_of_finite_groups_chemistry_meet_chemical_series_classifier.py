#!/usr/bin/env python3
"""
algorithms.py — Algorithms for the Periodic Table of Finite Groups

Implements computational tools for classifying finite groups into chemical series,
computing derived lengths, and testing group-theoretic conjectures.
"""

from math import gcd, factorial, log2
from typing import Optional
from collections import defaultdict


# ============================================================================
# Algorithm 1: Prime Factorization and Order Classification
# ============================================================================

def prime_factorization(n: int) -> dict[int, int]:
    """
    Compute the prime factorization of n.

    Time complexity: O(√n)
    Space complexity: O(log n)

    >>> prime_factorization(60)
    {2: 2, 3: 1, 5: 1}
    >>> prime_factorization(1)
    {}
    """
    if n <= 1:
        return {}
    factors: dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def euler_totient(n: int) -> int:
    """
    Compute Euler's totient function φ(n) using the product formula.

    φ(n) = n · ∏_{p|n} (1 - 1/p)

    Time complexity: O(√n)
    Space complexity: O(1)

    >>> euler_totient(12)
    4
    >>> euler_totient(1)
    1
    """
    if n <= 0:
        return 0
    result = n
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            while temp % d == 0:
                temp //= d
            result -= result // d
        d += 1
    if temp > 1:
        result -= result // temp
    return result


def is_prime(n: int) -> bool:
    """Check primality. O(√n)."""
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


# ============================================================================
# Algorithm 2: Chemical Series Classifier
# ============================================================================

class ChemicalSeries:
    """Chemical series classification for group orders."""
    NOBLE_GAS = "Noble Gas"
    ALKALINE_EARTH = "Alkaline Earth"
    COMPOUND = "Compound"
    RADIOACTIVE = "Radioactive"


def classify_group_order(n: int) -> tuple[str, str]:
    """
    Classify a group order into a chemical series with reasoning.

    Returns: (series_name, reason)

    Algorithm:
    1. n = 1 → trivial (Noble Gas)
    2. n prime → cyclic (Noble Gas)
    3. n = p^k → p-group, always solvable (Alkaline Earth/Compound)
    4. n = p^a·q^b → Burnside's theorem: solvable (Compound)
    5. n divisible by |A₅| = 60 → may be non-solvable (Radioactive)
    6. Otherwise → likely solvable (Compound)

    Time complexity: O(√n)

    >>> classify_group_order(7)
    ('Noble Gas', 'prime order, unique cyclic group')
    """
    if n <= 0:
        return ("Invalid", "non-positive order")
    if n == 1:
        return (ChemicalSeries.NOBLE_GAS, "trivial group")
    if is_prime(n):
        return (ChemicalSeries.NOBLE_GAS, "prime order, unique cyclic group")

    factors = prime_factorization(n)

    if len(factors) == 1:
        p, a = list(factors.items())[0]
        if a == 2:
            return (ChemicalSeries.ALKALINE_EARTH,
                    f"p²-group ({p}²={n}), includes abelian groups")
        return (ChemicalSeries.COMPOUND,
                f"p-group ({p}^{a}={n}), always solvable")

    if len(factors) == 2:
        return (ChemicalSeries.COMPOUND,
                f"order {n} = " + "·".join(f"{p}^{e}" for p, e in factors.items()) +
                ", solvable by Burnside's theorem")

    # Check for non-solvable indicators
    # The smallest non-solvable group is A₅ of order 60
    if n % 60 == 0:
        return (ChemicalSeries.RADIOACTIVE,
                f"divisible by 60 = |A₅|, may contain non-solvable groups")

    return (ChemicalSeries.COMPOUND,
            f"{len(factors)} prime factors, likely solvable")


# ============================================================================
# Algorithm 3: Derived Length Bounds
# ============================================================================

def derived_length_upper_bound(n: int) -> int:
    """
    Compute an upper bound on the derived length of any solvable group of order n.

    For a solvable group G of order n:
    - If n = 1: derived length = 0
    - If n is prime: derived length = 1
    - If n = p^a: derived length ≤ a
    - General: derived length ≤ 3·log₂(n)/2 + 1 (by a result of Gluck)

    Time complexity: O(√n)

    >>> derived_length_upper_bound(1)
    0
    >>> derived_length_upper_bound(7)
    1
    """
    if n <= 1:
        return 0
    if is_prime(n):
        return 1

    factors = prime_factorization(n)

    if len(factors) == 1:
        _, a = list(factors.items())[0]
        return a

    # General bound
    return int(3 * log2(n) / 2) + 1


def composition_factor_signature(n: int) -> list[int]:
    """
    Compute the composition factor signature of the cyclic group of order n.

    For ℤ/nℤ, the composition factors are ℤ/pℤ for each prime p dividing n,
    with multiplicity equal to the exponent of p in the factorization.

    Time complexity: O(√n)

    >>> composition_factor_signature(12)
    [2, 2, 3]
    >>> composition_factor_signature(60)
    [2, 2, 3, 5]
    """
    factors = prime_factorization(n)
    result = []
    for p in sorted(factors.keys()):
        result.extend([p] * factors[p])
    return result


# ============================================================================
# Algorithm 4: Isotope Detection
# ============================================================================

def are_isotopes(n1: int, n2: int) -> bool:
    """
    Check if cyclic groups of orders n1 and n2 are isotopes
    (same derived length).

    For cyclic groups, the derived length is always ≤ 1,
    so all non-trivial cyclic groups are isotopes.

    >>> are_isotopes(5, 7)
    True
    >>> are_isotopes(1, 5)
    False
    """
    dl1 = 0 if n1 <= 1 else 1
    dl2 = 0 if n2 <= 1 else 1
    return dl1 == dl2


def isotope_class(n: int) -> int:
    """
    Return the isotope class (derived length) of the cyclic group ℤ/nℤ.

    >>> isotope_class(1)
    0
    >>> isotope_class(7)
    1
    """
    return 0 if n <= 1 else 1


# ============================================================================
# Algorithm 5: Group Count Estimator
# ============================================================================

def estimate_group_count(n: int) -> str:
    """
    Estimate the number of groups of order n.

    Uses the formula: for n = p^k, the number of groups grows as p^(2k³/27).
    For general n, uses known heuristics.

    >>> estimate_group_count(7)
    '1 (exact: prime order)'
    """
    if n <= 0:
        return "invalid"
    if n == 1:
        return "1 (exact: trivial group)"
    if is_prime(n):
        return "1 (exact: prime order)"

    factors = prime_factorization(n)

    if len(factors) == 1:
        p, k = list(factors.items())[0]
        if k == 2:
            return "2 (exact: ℤ/p² and ℤ/p × ℤ/p)"
        # Rough estimate
        est = int(p ** (2 * k ** 3 / 27)) if k >= 3 else k + 1
        return f"~{est} (p^k estimate)"

    return f"unknown (multi-prime factorization)"


# ============================================================================
# Algorithm 6: Periodic Table Generator
# ============================================================================

def generate_periodic_table(max_order: int = 60) -> list[dict]:
    """
    Generate the periodic table of finite groups up to a given order.

    Returns a list of dictionaries with group order information.

    Time complexity: O(max_order · √max_order)
    """
    table = []
    for n in range(1, max_order + 1):
        series, reason = classify_group_order(n)
        table.append({
            "order": n,
            "series": series,
            "reason": reason,
            "totient": euler_totient(n),
            "factorization": prime_factorization(n),
            "derived_length_bound": derived_length_upper_bound(n),
            "composition_factors": composition_factor_signature(n),
        })
    return table


if __name__ == "__main__":
    # Demo: Generate and display the periodic table
    table = generate_periodic_table(30)
    print("Periodic Table of Finite Groups (Orders 1-30)")
    print("=" * 90)
    print(f"{'Order':>5} | {'Series':<16} | {'φ(n)':>4} | {'DL bound':>8} | {'Reason'}")
    print("-" * 90)
    for entry in table:
        print(f"{entry['order']:>5} | {entry['series']:<16} | "
              f"{entry['totient']:>4} | {entry['derived_length_bound']:>8} | "
              f"{entry['reason']}")

    print("\n\nIsotope test: ℤ/5ℤ and ℤ/7ℤ are isotopes?",
          are_isotopes(5, 7))
    print("Isotope test: {e} and ℤ/5ℤ are isotopes?",
          are_isotopes(1, 5))
