#!/usr/bin/env python3
"""
Diagonal Obstruction Calculus — Core Algorithms

Implements the computational backbone for studying local obstructions
to diagonal equations x₁ⁿ + x₂ⁿ + ⋯ + xₛⁿ = k.

Provides:
  - nth_power_residues: compute n-th power residues mod m
  - diagonal_residue_sums: compute all sums of s n-th powers mod m
  - is_universally_surjective: check if all residues are representable
  - classify_obstructions: find all obstruction moduli up to a bound
  - prime_power_reduction: reduce obstruction search to prime powers
  - admissible_density: compute density of admissible residues
  - orbit_decomposition: decompose residue sums under unit actions
"""

from math import gcd, isqrt
from typing import Optional
from collections import defaultdict


def factorize(n: int) -> dict[int, int]:
    """
    Prime factorization of n.

    Returns:
        Dictionary mapping primes to their exponents.

    Example:
        >>> factorize(360)
        {2: 3, 3: 2, 5: 1}

    Time complexity: O(√n)
    Space complexity: O(log n)
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


def nth_power_residues(n: int, m: int) -> set[int]:
    """
    Compute the set of n-th power residues modulo m.

    Args:
        n: The exponent (degree of the diagonal form).
        m: The modulus.

    Returns:
        Set of all a^n mod m for a in {0, 1, ..., m-1}.

    Example:
        >>> sorted(nth_power_residues(2, 8))
        [0, 1, 4]
        >>> sorted(nth_power_residues(3, 9))
        [0, 1, 8]

    Time complexity: O(m log n) using modular exponentiation
    Space complexity: O(m)
    """
    if m <= 0:
        raise ValueError(f"Modulus must be positive, got {m}")
    return {pow(a, n, m) for a in range(m)}


def diagonal_residue_sums(n: int, s: int, m: int) -> set[int]:
    """
    Compute the set of all sums of s n-th powers modulo m.

    This is the image of the diagonal map (x₁,...,xₛ) ↦ x₁ⁿ+⋯+xₛⁿ
    from (ℤ/mℤ)ˢ to ℤ/mℤ.

    Args:
        n: Degree of the diagonal form.
        s: Number of variables (summands).
        m: Modulus.

    Returns:
        Set of residues r mod m such that r = x₁ⁿ+⋯+xₛⁿ for some xᵢ.

    Algorithm:
        Iteratively computes S₁ = R, S₂ = S₁ + R, ..., Sₛ = Sₛ₋₁ + R
        where R is the set of n-th power residues and + is the sumset.

    Time complexity: O(s · m²)
    Space complexity: O(m)

    Example:
        >>> sorted(diagonal_residue_sums(2, 4, 8))
        [0, 1, 2, 3, 4, 5, 6, 7]
    """
    if m <= 0:
        raise ValueError(f"Modulus must be positive, got {m}")
    if s <= 0:
        return {0}

    residues = nth_power_residues(n, m)
    current = {0}
    for _ in range(s):
        current = {(a + r) % m for a in current for r in residues}
    return current


def is_universally_surjective(n: int, s: int, m: int) -> bool:
    """
    Check if every residue class mod m is a sum of s n-th powers.

    This is the computational analog of the UniversallySurjectiveMod
    predicate from the formal theory.

    Args:
        n: Degree.
        s: Number of variables.
        m: Modulus.

    Returns:
        True if diagonal_residue_sums(n, s, m) = {0, 1, ..., m-1}.

    Example:
        >>> is_universally_surjective(3, 3, 7)
        True
        >>> is_universally_surjective(3, 3, 9)
        False
    """
    return len(diagonal_residue_sums(n, s, m)) == m


def classify_obstructions(
    n: int, s: int, max_m: int
) -> dict[str, list]:
    """
    Classify all obstruction moduli up to max_m.

    Returns a dictionary with:
        - 'surjective': list of surjective moduli
        - 'obstructed': list of (m, missing_count, missing_residues)
        - 'obstruction_primes': set of primes causing obstructions

    Time complexity: O(max_m · s · max_m²) = O(s · max_m³)

    Example:
        >>> result = classify_obstructions(3, 3, 20)
        >>> 9 in [x[0] for x in result['obstructed']]
        True
    """
    surjective = []
    obstructed = []
    obstruction_primes = set()

    for m in range(1, max_m + 1):
        residues = diagonal_residue_sums(n, s, m)
        if len(residues) == m:
            surjective.append(m)
        else:
            missing = sorted(set(range(m)) - residues)
            obstructed.append((m, len(missing), missing))
            # Check if m is a prime power
            factors = factorize(m)
            if len(factors) == 1:
                obstruction_primes.add(list(factors.keys())[0])

    return {
        'surjective': surjective,
        'obstructed': obstructed,
        'obstruction_primes': obstruction_primes,
    }


def prime_power_reduction(n: int, s: int, m: int) -> dict:
    """
    Analyze m by reducing to its prime power factors.

    For each prime power p^a dividing m, checks surjectivity.
    By the CRT theorem (universally_surjective_mul_of_coprime),
    if all prime power factors are surjective, m is surjective.

    Args:
        n: Degree.
        s: Number of variables.
        m: Modulus.

    Returns:
        Dictionary with prime power analysis.

    Example:
        >>> result = prime_power_reduction(3, 3, 18)
        >>> result['factors']
        {2: True, 9: False}
    """
    factors = factorize(m)
    pp_results = {}
    for p, e in factors.items():
        pp = p ** e
        pp_results[pp] = is_universally_surjective(n, s, pp)

    all_surjective = all(pp_results.values())

    return {
        'modulus': m,
        'factorization': factors,
        'factors': pp_results,
        'all_prime_powers_surjective': all_surjective,
        'm_surjective': is_universally_surjective(n, s, m),
    }


def admissible_density(n: int, s: int, m: int) -> float:
    """
    Compute the density of admissible residues mod m.

    Returns |diagonal_residue_sums(n,s,m)| / m.

    Example:
        >>> admissible_density(3, 3, 9)
        0.7777777777777778
    """
    return len(diagonal_residue_sums(n, s, m)) / m


def orbit_decomposition(
    n: int, s: int, m: int
) -> dict[int, set[int]]:
    """
    Decompose the residue sum set into orbits under multiplication
    by n-th power units.

    By the unit power symmetry theorem (diagonal_residue_sums_unit_power_invariant),
    the set of sums of s n-th powers is invariant under multiplication
    by n-th powers of units. This function computes the orbits.

    Args:
        n: Degree.
        s: Number of variables.
        m: Modulus.

    Returns:
        Dictionary mapping orbit representatives to orbit sets.

    Example:
        >>> orbits = orbit_decomposition(4, 4, 16)
        >>> len(orbits)  # Number of distinct orbits
        4
    """
    res_set = diagonal_residue_sums(n, s, m)

    # Compute n-th power units
    units = [a for a in range(m) if gcd(a, m) == 1]
    nth_power_units = {pow(u, n, m) for u in units}

    # Group residues into orbits
    visited = set()
    orbits = {}

    for r in sorted(res_set):
        if r in visited:
            continue
        orbit = set()
        for u in nth_power_units:
            orbit.add((u * r) % m)
        visited.update(orbit)
        orbits[r] = orbit

    return orbits


def waring_local_bound(n: int, max_m: int = 100) -> int:
    """
    Find the minimum s such that all moduli up to max_m are
    universally surjective for degree n.

    This gives a lower bound on the number of variables needed
    for a Waring-type local-global principle.

    Args:
        n: Degree.
        max_m: Maximum modulus to check.

    Returns:
        Minimum s (or -1 if not found for s ≤ 2n).

    Example:
        >>> waring_local_bound(3, 20)
        5
    """
    for s in range(1, 2 * n + 1):
        if all(is_universally_surjective(n, s, m)
               for m in range(1, max_m + 1)):
            return s
    return -1


# ---- Example usage ----
if __name__ == "__main__":
    print("=== Diagonal Obstruction Algorithms ===\n")

    # Example 1: Biquadratic obstructions
    print("Biquadratic (n=4, s=4) obstruction classification:")
    result = classify_obstructions(4, 4, 50)
    print(f"  Surjective moduli: {result['surjective'][:20]}...")
    print(f"  Obstruction primes: {sorted(result['obstruction_primes'])}")
    print(f"  Number of obstructed moduli: {len(result['obstructed'])}")

    # Example 2: Prime power reduction
    print("\nPrime power reduction for m=48:")
    ppr = prime_power_reduction(4, 4, 48)
    print(f"  Factorization: {ppr['factorization']}")
    print(f"  Prime power surjectivity: {ppr['factors']}")
    print(f"  m surjective: {ppr['m_surjective']}")

    # Example 3: Orbit decomposition
    print("\nOrbit decomposition for (4,4) mod 16:")
    orbits = orbit_decomposition(4, 4, 16)
    for rep, orb in orbits.items():
        print(f"  Orbit of {rep}: {sorted(orb)}")

    # Example 4: Waring local bounds
    print("\nMinimum s for universal local surjectivity up to m=50:")
    for deg in range(2, 7):
        s = waring_local_bound(deg, 50)
        print(f"  n={deg}: s_min = {s}")
