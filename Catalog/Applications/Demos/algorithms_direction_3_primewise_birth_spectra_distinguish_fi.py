#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Primewise Birth Spectra Analysis

Implements:
1. Spectral multiplicity computation
2. Separating pair search algorithm
3. Prime decomposition depth analysis
4. Spectral multiplicity bound verification
"""

from typing import Dict, List, Set, Tuple, Optional, FrozenSet
from itertools import product, combinations
import math


def prime_factors(n: int) -> Set[int]:
    """Return the set of prime factors of n.

    Time complexity: O(sqrt(n))
    Space complexity: O(log n)

    Examples:
        >>> sorted(prime_factors(30))
        [2, 3, 5]
        >>> prime_factors(1)
        set()
    """
    if n <= 1:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def is_prime(n: int) -> bool:
    """Check if n is prime."""
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


class BirthProfile:
    """A finite birth profile for a filtered abelian group.

    Attributes:
        max_level: Maximum filtration level
        orders_at: Dict mapping level -> set of torsion orders born there
    """

    def __init__(self, max_level: int, orders_at: Dict[int, Set[int]]):
        self.max_level = max_level
        self.orders_at = {i: set(orders_at.get(i, set())) for i in range(max_level + 1)}

    def global_birth_set(self) -> FrozenSet[int]:
        """Compute the global torsion birth set.

        Returns levels where some m > 1 is born.

        Time: O(L * M) where L = max_level, M = max orders per level
        """
        return frozenset(i for i in range(self.max_level + 1)
                         if any(m > 1 for m in self.orders_at[i]))

    def p_birth_set(self, p: int) -> FrozenSet[int]:
        """Compute the p-torsion birth set.

        Returns levels where some m > 1 divisible by p is born.

        Time: O(L * M)
        """
        return frozenset(i for i in range(self.max_level + 1)
                         if any(m > 1 and m % p == 0 for m in self.orders_at[i]))

    def active_primes(self) -> Set[int]:
        """Compute the set of active primes.

        Time: O(L * M * sqrt(max_order))
        """
        all_orders = set().union(*self.orders_at.values())
        return set().union(*(prime_factors(m) for m in all_orders if m > 1))

    def primewise_spectrum(self) -> Dict[int, FrozenSet[int]]:
        """Compute the full primewise birth spectrum.

        Returns: dict mapping each active prime to its birth set

        Time: O(P * L * M) where P = number of active primes
        """
        return {p: self.p_birth_set(p) for p in self.active_primes()}

    def spectral_multiplicity(self) -> int:
        """Compute the spectral multiplicity.

        The number of distinct nonempty p-birth patterns.

        Time: O(P * L * M)
        """
        spectrum = self.primewise_spectrum()
        return len(set(v for v in spectrum.values() if v))

    def prime_depth_at(self, level: int) -> int:
        """Compute the prime decomposition depth at a level.

        The number of distinct primes dividing some order at this level.
        """
        orders = self.orders_at.get(level, set())
        return len(set().union(*(prime_factors(m) for m in orders if m > 1)) if orders else set())

    def total_prime_depth(self) -> int:
        """Sum of prime depths across all levels."""
        return sum(self.prime_depth_at(i) for i in range(self.max_level + 1))


def find_separating_pairs(
    profiles: List[BirthProfile],
    primes: Optional[List[int]] = None
) -> List[Tuple[int, int, int, FrozenSet[int], FrozenSet[int]]]:
    """Find all pairs of profiles with same global but different primewise birth.

    Algorithm:
        1. Group profiles by global birth set (O(n) with hashing)
        2. Within each group, check primewise equality for each prime
        3. Report differences

    Args:
        profiles: List of BirthProfile objects
        primes: Primes to test (default: union of all active primes)

    Returns:
        List of (index_i, index_j, prime_p, F_p_birth, G_p_birth) tuples

    Time: O(n^2 * P * L * M) worst case, typically much better with grouping
    Space: O(n * L) for the grouping
    """
    # Group by global birth set
    groups: Dict[FrozenSet[int], List[int]] = {}
    for idx, prof in enumerate(profiles):
        gb = prof.global_birth_set()
        groups.setdefault(gb, []).append(idx)

    # Collect all primes if not specified
    if primes is None:
        all_primes = set()
        for prof in profiles:
            all_primes |= prof.active_primes()
        primes = sorted(all_primes)

    results = []
    for gb, indices in groups.items():
        for a, i in enumerate(indices):
            for j in indices[a + 1:]:
                for p in primes:
                    f_birth = profiles[i].p_birth_set(p)
                    g_birth = profiles[j].p_birth_set(p)
                    if f_birth != g_birth:
                        results.append((i, j, p, f_birth, g_birth))
                        break  # One prime suffices to distinguish

    return results


def verify_spectral_multiplicity_bound(
    max_level: int,
    N: int,
    sample_size: int = 1000
) -> Tuple[bool, int, Optional['BirthProfile']]:
    """Verify the spectral multiplicity bound conjecture.

    Conjecture: spectral_mult ≤ ω(N) × (max_level + 1)

    Args:
        max_level: Maximum filtration level
        N: All orders must divide N
        sample_size: Number of random profiles to test

    Returns:
        (bound_holds, max_observed, worst_case_profile)

    Algorithm:
        Exhaustive or sampled search over profiles with orders dividing N.
    """
    import random

    divisors = [d for d in range(2, N + 1) if N % d == 0]
    omega_N = len(prime_factors(N))
    bound = omega_N * (max_level + 1)

    max_mult = 0
    worst = None

    for _ in range(sample_size):
        orders = {}
        for level in range(max_level + 1):
            k = random.randint(0, min(3, len(divisors)))
            if k > 0:
                orders[level] = set(random.sample(divisors, k))
        prof = BirthProfile(max_level, orders)
        mult = prof.spectral_multiplicity()
        if mult > max_mult:
            max_mult = mult
            worst = prof

    return max_mult <= bound, max_mult, worst


def spectral_distance(F: BirthProfile, G: BirthProfile) -> int:
    """Compute the spectral distance between two profiles.

    The number of primes where the p-birth sets differ.
    This is a metric on the space of birth profiles.

    Time: O(P * L * M)
    """
    all_primes = F.active_primes() | G.active_primes()
    return sum(1 for p in all_primes if F.p_birth_set(p) != G.p_birth_set(p))


if __name__ == "__main__":
    # Example usage
    F = BirthProfile(3, {1: {2}, 3: {6}})
    G = BirthProfile(3, {1: {3}, 3: {6}})

    print("Profile F spectrum:", F.primewise_spectrum())
    print("Profile G spectrum:", G.primewise_spectrum())
    print(f"Spectral distance: {spectral_distance(F, G)}")
    print(f"F multiplicity: {F.spectral_multiplicity()}")
    print(f"G multiplicity: {G.spectral_multiplicity()}")

    # Verify bound conjecture
    holds, max_obs, _ = verify_spectral_multiplicity_bound(3, 30, 5000)
    omega_30 = len(prime_factors(30))
    bound = omega_30 * 4
    print(f"\nBound conjecture (N=30, L=3): ω(30)={omega_30}, bound={bound}")
    print(f"Max observed multiplicity: {max_obs}")
    print(f"Bound holds: {holds}")
