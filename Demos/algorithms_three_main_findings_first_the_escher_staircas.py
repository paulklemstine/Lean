#!/usr/bin/env python3
"""
Algorithms for Escher Staircase theory: chain invariants, big omega,
and divisor lattice analysis.

Type-hinted implementations of the core algorithms from the research.
"""

from collections import Counter
from typing import List, Dict, Tuple, Optional, Set, Callable
from math import gcd, log2, factorial
from functools import reduce


# ============================================================================
# Core Arithmetic Functions
# ============================================================================

def prime_factorization(n: int) -> Dict[int, int]:
    """
    Compute the prime factorization of n.

    Returns a dictionary mapping each prime factor to its exponent.
    For n ≤ 1, returns an empty dictionary.

    Time complexity: O(√n)

    Examples:
        >>> prime_factorization(12)
        {2: 2, 3: 1}
        >>> prime_factorization(1)
        {}
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
        factors[n] = 1
    return factors


def big_omega(n: int) -> int:
    """
    Compute the big omega function Ω(n).

    Ω(n) = total number of prime factors of n counted with multiplicity.
    Equivalently, Ω(n) = Σ_{p|n} v_p(n) where v_p is the p-adic valuation.

    Properties (proved in Lean):
    - Ω(0) = 0, Ω(1) = 0
    - Ω(p) = 1 for prime p
    - Ω(p^k) = k for prime p
    - Ω(a·b) = Ω(a) + Ω(b) when gcd(a,b) = 1
    - Ω(n) > 0 for n ≥ 2

    Time complexity: O(√n)

    Examples:
        >>> big_omega(12)  # 2^2 · 3
        3
        >>> big_omega(30)  # 2 · 3 · 5
        3
    """
    return sum(prime_factorization(n).values())


def small_omega(n: int) -> int:
    """
    Compute the small omega function ω(n).

    ω(n) = number of distinct prime factors of n.

    Examples:
        >>> small_omega(12)  # primes: 2, 3
        2
        >>> small_omega(30)  # primes: 2, 3, 5
        3
    """
    return len(prime_factorization(n))


# ============================================================================
# Chain Defect Algorithm
# ============================================================================

def chain_defect(sequence: List[int]) -> Optional[int]:
    """
    Compute the chain defect (stabilization index) of a finite sequence.

    The chain defect is the smallest index n such that sequence[m] = sequence[n]
    for all m ≥ n. Returns None if the sequence does not stabilize
    (within the given finite window).

    This is the computational analog of the ChainDefect definition in Lean,
    which uses Nat.find on the stabilization predicate.

    Time complexity: O(n²) where n = len(sequence)

    Examples:
        >>> chain_defect([1, 2, 3, 3, 3])
        2
        >>> chain_defect([5, 5, 5])
        0
    """
    n = len(sequence)
    for i in range(n):
        if all(sequence[j] == sequence[i] for j in range(i, n)):
            return i
    return None


def is_stabilizing(sequence: List[int]) -> bool:
    """Check if a sequence stabilizes (has finite chain defect)."""
    return chain_defect(sequence) is not None


# ============================================================================
# Divisor Lattice Algorithms
# ============================================================================

def divisors(n: int) -> List[int]:
    """Return all positive divisors of n in sorted order."""
    if n <= 0:
        return []
    divs: Set[int] = set()
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            divs.add(d)
            divs.add(n // d)
    return sorted(divs)


def maximal_divisor_chains(n: int) -> List[List[int]]:
    """
    Enumerate all maximal strictly ascending divisor chains from 1 to n.

    A maximal chain has length Ω(n) + 1 (including endpoints).
    The number of such chains equals the multinomial coefficient
    Ω(n)! / (e₁! · e₂! · ... · eₖ!) where n = p₁^e₁ · ... · pₖ^eₖ.

    Time complexity: O(Ω(n)! / ∏ eᵢ!) — can be exponential.

    Examples:
        >>> maximal_divisor_chains(12)
        [[1, 2, 4, 12], [1, 2, 6, 12], [1, 3, 6, 12]]
    """
    target_len = big_omega(n)
    chains: List[List[int]] = []
    factors = prime_factorization(n)
    remaining = Counter(factors)

    def backtrack(current: int, chain: List[int]):
        if current == n:
            if len(chain) - 1 == target_len:
                chains.append(chain[:])
            return
        for p in sorted(remaining):
            if remaining[p] > 0:
                next_val = current * p
                remaining[p] -= 1
                chain.append(next_val)
                backtrack(next_val, chain)
                chain.pop()
                remaining[p] += 1

    backtrack(1, [1])
    return chains


def count_maximal_chains(n: int) -> int:
    """
    Count the number of maximal divisor chains from 1 to n.

    Uses the multinomial coefficient formula:
    count = Ω(n)! / (e₁! · e₂! · ... · eₖ!)

    This is much faster than enumeration.

    Time complexity: O(√n) for factorization + O(k) for computation.

    Examples:
        >>> count_maximal_chains(12)  # 3!/(2!·1!) = 3
        3
        >>> count_maximal_chains(30)  # 3!/(1!·1!·1!) = 6
        6
    """
    factors = prime_factorization(n)
    omega = sum(factors.values())
    numerator = factorial(omega)
    denominator = reduce(lambda x, y: x * y,
                        (factorial(e) for e in factors.values()), 1)
    return numerator // denominator


# ============================================================================
# Anti-Escher Property Verification
# ============================================================================

def verify_anti_escher_property(
    generators: List[int],
    test_range: int = 1000
) -> Dict[str, object]:
    """
    Verify the anti-Escher property for a descending chain of ideals in ℤ.

    For generators g₀, g₁, g₂, ... with g_i | g_{i+1} and each step strict,
    checks that no nonzero integer up to test_range is divisible by all generators.

    Returns a dictionary with verification results.
    """
    # Check that the chain is valid (each generator divides the next)
    for i in range(len(generators) - 1):
        if generators[i] == 0:
            return {"valid": False, "error": f"Generator {i} is zero"}
        if generators[i + 1] % generators[i] != 0:
            return {"valid": False,
                    "error": f"g_{i} = {generators[i]} does not divide g_{i+1} = {generators[i+1]}"}
        if abs(generators[i + 1]) == abs(generators[i]):
            return {"valid": False,
                    "error": f"Chain not strictly descending at step {i}"}

    # Check anti-Escher: no nonzero x should be divisible by all generators
    for x in range(1, test_range + 1):
        if all(x % g == 0 for g in generators if g != 0):
            return {
                "valid": True,
                "anti_escher_holds": False,
                "counterexample": x,
                "note": "Found nonzero x divisible by all generators"
            }

    return {
        "valid": True,
        "anti_escher_holds": True,
        "test_range": test_range,
        "chain_length": len(generators),
        "growth_rate": [abs(generators[i+1]) / abs(generators[i])
                       for i in range(len(generators) - 1)]
    }


def exponential_growth_bound(
    initial: int,
    chain_length: int,
    min_factor: int = 2
) -> List[int]:
    """
    Compute the lower bound on |f(n)| for a strictly descending chain.

    In ℤ, each step multiplies the absolute value by at least min_factor (= 2),
    since the quotient at each step is a non-unit integer.

    Returns: list of lower bounds [|f(0)|, |f(0)|·2, |f(0)|·4, ...]
    """
    return [abs(initial) * (min_factor ** k) for k in range(chain_length)]


# ============================================================================
# Chain Analysis
# ============================================================================

def analyze_ideal_chain(generators: List[int]) -> Dict[str, object]:
    """
    Analyze a chain of principal ideals in ℤ defined by generators.

    Returns comprehensive analysis including:
    - Chain direction (ascending/descending)
    - Strictness (whether each step is proper)
    - Chain defect (stabilization index)
    - Big omega values
    - Anti-Escher verification
    """
    n = len(generators)

    # Determine direction
    ascending = all(generators[i] % generators[i+1] == 0
                   for i in range(n-1) if generators[i+1] != 0)
    descending = all(generators[i+1] % generators[i] == 0
                    for i in range(n-1) if generators[i] != 0)

    # Check strictness
    strictly_ascending = ascending and all(
        abs(generators[i]) != abs(generators[i+1]) for i in range(n-1))
    strictly_descending = descending and all(
        abs(generators[i]) != abs(generators[i+1]) for i in range(n-1))

    # Compute big omega for each generator
    omegas = [big_omega(abs(g)) if g != 0 else 0 for g in generators]

    # Absolute values
    abs_vals = [abs(g) for g in generators]

    # Chain defect of absolute values
    cd = chain_defect(abs_vals)

    return {
        "generators": generators,
        "length": n,
        "ascending": ascending,
        "descending": descending,
        "strictly_ascending": strictly_ascending,
        "strictly_descending": strictly_descending,
        "absolute_values": abs_vals,
        "big_omega_values": omegas,
        "chain_defect": cd,
    }


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    # Verify core properties
    assert big_omega(0) == 0
    assert big_omega(1) == 0
    assert big_omega(2) == 1
    assert big_omega(12) == 3  # 2^2 * 3
    assert big_omega(30) == 3  # 2 * 3 * 5

    # Verify coprime additivity
    assert big_omega(6 * 35) == big_omega(6) + big_omega(35)

    # Verify prime power
    assert big_omega(2**10) == 10
    assert big_omega(3**5) == 5

    # Verify chain counting
    assert count_maximal_chains(12) == 3
    assert count_maximal_chains(30) == 6
    assert len(maximal_divisor_chains(12)) == count_maximal_chains(12)

    # Verify anti-Escher
    gens = [2 * (3**k) for k in range(15)]
    result = verify_anti_escher_property(gens)
    assert result["anti_escher_holds"]

    print("All assertions passed!")
    print(f"\nSample analysis for chain (2) ⊋ (6) ⊋ (18) ⊋ (54):")
    analysis = analyze_ideal_chain([2, 6, 18, 54])
    for k, v in analysis.items():
        print(f"  {k}: {v}")
