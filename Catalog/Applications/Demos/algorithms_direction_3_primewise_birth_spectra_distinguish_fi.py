#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for primewise birth spectra analysis.

Implements:
  1. Birth set computation (global and primewise)
  2. Distinguishing pair search with pruning
  3. Information loss quantification
  4. Prime-resolved spectral decomposition
"""

from __future__ import annotations
from dataclasses import dataclass
from itertools import combinations, product
from math import log2
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


# ─── Data Structures ────────────────────────────────────────────────

@dataclass(frozen=True)
class FiniteBirthProfile:
    """A finite birth profile: maps each filtration level to a set of torsion orders.

    Attributes:
        max_level: The maximum filtration level (levels are 0, ..., max_level).
        orders_at: Tuple of frozensets giving torsion orders born at each level.

    Example:
        >>> F = FiniteBirthProfile(3, (frozenset(), frozenset({2}), frozenset(), frozenset({6})))
        >>> F.max_level
        3
    """
    max_level: int
    orders_at: Tuple[FrozenSet[int], ...]

    def __repr__(self) -> str:
        nonempty = {i: sorted(s) for i, s in enumerate(self.orders_at) if s}
        return f"BirthProfile(max={self.max_level}, births={nonempty})"

    @staticmethod
    def from_dict(max_level: int, births: Dict[int, Set[int]]) -> 'FiniteBirthProfile':
        """Construct from a dictionary of level -> orders.

        Example:
            >>> F = FiniteBirthProfile.from_dict(3, {1: {2}, 3: {6}})
        """
        orders = tuple(
            frozenset(births.get(i, set())) for i in range(max_level + 1)
        )
        return FiniteBirthProfile(max_level, orders)


# ─── Prime Utilities ─────────────────────────────────────────────────

def is_prime(n: int) -> bool:
    """Primality test. O(sqrt(n)) time."""
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


def prime_divisors(m: int) -> Set[int]:
    """Return the set of prime factors of m.

    Time complexity: O(sqrt(m)).

    Example:
        >>> sorted(prime_divisors(30))
        [2, 3, 5]
        >>> prime_divisors(1)
        set()
    """
    if m <= 1:
        return set()
    result = set()
    d = 2
    temp = m
    while d * d <= temp:
        if temp % d == 0:
            result.add(d)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        result.add(temp)
    return result


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes. O(n log log n) time, O(n) space."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


# ─── Birth Set Computation ──────────────────────────────────────────

def global_torsion_birth_set(F: FiniteBirthProfile) -> FrozenSet[int]:
    """Compute the global torsion birth set.

    A level i is included iff some order m > 1 is born at level i.

    Time complexity: O(L * M) where L = max_level + 1, M = max orders per level.

    Example:
        >>> F = FiniteBirthProfile.from_dict(3, {1: {2}, 3: {6}})
        >>> sorted(global_torsion_birth_set(F))
        [1, 3]
    """
    return frozenset(
        i for i, orders in enumerate(F.orders_at)
        if any(m > 1 for m in orders)
    )


def p_torsion_birth_set(p: int, F: FiniteBirthProfile) -> FrozenSet[int]:
    """Compute the p-torsion birth set.

    A level i is included iff some order m > 1 with p | m is born at level i.

    Time complexity: O(L * M).

    Example:
        >>> F = FiniteBirthProfile.from_dict(3, {1: {2}, 3: {6}})
        >>> sorted(p_torsion_birth_set(2, F))
        [1, 3]
        >>> sorted(p_torsion_birth_set(3, F))
        [3]
    """
    return frozenset(
        i for i, orders in enumerate(F.orders_at)
        if any(m > 1 and m % p == 0 for m in orders)
    )


def primewise_birth_spectrum(
    F: FiniteBirthProfile, primes: List[int]
) -> Dict[int, FrozenSet[int]]:
    """Compute the full primewise birth spectrum.

    Time complexity: O(P * L * M) where P = |primes|.

    Example:
        >>> F = FiniteBirthProfile.from_dict(3, {1: {2}, 3: {6}})
        >>> spec = primewise_birth_spectrum(F, [2, 3, 5])
        >>> sorted(spec[2])
        [1, 3]
        >>> sorted(spec[3])
        [3]
    """
    return {p: p_torsion_birth_set(p, F) for p in primes}


# ─── Distinguishing Pair Search ─────────────────────────────────────

def find_distinguishing_pairs(
    profiles: List[FiniteBirthProfile],
    primes: List[int],
    max_results: Optional[int] = None
) -> List[Tuple[FiniteBirthProfile, FiniteBirthProfile, int]]:
    """Find pairs with equal global birth sets but different primewise spectra.

    Algorithm:
      1. Group profiles by their global birth set (hash-based bucketing).
      2. Within each bucket, compare all pairs on each prime.
      3. Return (F, G, p) triples where p is the first separating prime.

    Time complexity: O(N^2 * P * L * M) worst case, but bucketing prunes
    most comparisons.

    Args:
        profiles: List of candidate profiles.
        primes: Primes to test for separation.
        max_results: Stop after finding this many pairs (None = find all).

    Returns:
        List of (F, G, p) where globalBirthSet(F) = globalBirthSet(G)
        but pTorsionBirthSet(p, F) ≠ pTorsionBirthSet(p, G).

    Example:
        >>> F = FiniteBirthProfile.from_dict(3, {1: {2}, 3: {6}})
        >>> G = FiniteBirthProfile.from_dict(3, {1: {3}, 3: {6}})
        >>> pairs = find_distinguishing_pairs([F, G], [2, 3])
        >>> len(pairs)
        1
    """
    # Step 1: Bucket by global birth set
    buckets: Dict[FrozenSet[int], List[int]] = {}
    global_sets = [global_torsion_birth_set(p) for p in profiles]
    for idx, gs in enumerate(global_sets):
        buckets.setdefault(gs, []).append(idx)

    results = []
    # Step 2: Compare within buckets
    for _gs, indices in buckets.items():
        if len(indices) < 2:
            continue
        for a, b in combinations(indices, 2):
            F, G = profiles[a], profiles[b]
            for p in primes:
                if p_torsion_birth_set(p, F) != p_torsion_birth_set(p, G):
                    results.append((F, G, p))
                    if max_results and len(results) >= max_results:
                        return results
                    break
    return results


# ─── Information Loss Quantification ─────────────────────────────────

def spectral_entropy(F: FiniteBirthProfile, primes: List[int]) -> float:
    """Compute a simple entropy measure of the primewise birth spectrum.

    Measures how spread the birth data is across primes. Higher entropy
    means more uniform distribution of torsion across prime channels.

    For each level with torsion, compute the distribution of primes that
    appear there, and sum the Shannon entropy.

    Example:
        >>> F = FiniteBirthProfile.from_dict(3, {1: {6}, 3: {6}})
        >>> spectral_entropy(F, [2, 3])  # 6 is divisible by both 2 and 3
        2.0
    """
    total = 0.0
    for i, orders in enumerate(F.orders_at):
        prime_count = sum(
            1 for p in primes
            if any(m > 1 and m % p == 0 for m in orders)
        )
        if prime_count > 0:
            # Each active prime contributes -log2(1/prime_count) * (1/prime_count)
            # = log2(prime_count) in total for this level
            total += log2(prime_count) if prime_count > 1 else 0.0
    return total


def information_loss(F: FiniteBirthProfile, primes: List[int]) -> float:
    """Quantify information lost when projecting primewise spectrum to global.

    Returns the ratio: 1 - (global_bits / primewise_bits).
    A value of 0 means no loss; positive values indicate lost information.

    Example:
        >>> F = FiniteBirthProfile.from_dict(3, {1: {2}, 3: {6}})
        >>> loss = information_loss(F, [2, 3])
        >>> loss > 0
        True
    """
    global_bs = global_torsion_birth_set(F)
    global_bits = len(global_bs)  # number of active levels

    primewise_bits = sum(
        len(p_torsion_birth_set(p, F)) for p in primes
    )

    if primewise_bits == 0:
        return 0.0
    return 1.0 - global_bits / primewise_bits


# ─── Profile Enumeration ────────────────────────────────────────────

def enumerate_profiles(
    max_level: int,
    order_pool: List[int],
    max_orders_per_level: int = 1
) -> List[FiniteBirthProfile]:
    """Enumerate birth profiles with bounded complexity.

    Args:
        max_level: Maximum filtration level.
        order_pool: Pool of allowed torsion orders (should be > 1).
        max_orders_per_level: Maximum number of orders at each level.

    Returns:
        List of all valid profiles.

    Time complexity: O(C(|pool|, k)^(L+1)) where k = max_orders_per_level.
    """
    subsets = [frozenset()]
    for size in range(1, max_orders_per_level + 1):
        for combo in combinations(order_pool, size):
            subsets.append(frozenset(combo))

    return [
        FiniteBirthProfile(max_level, assignment)
        for assignment in product(subsets, repeat=max_level + 1)
    ]


# ─── Example Usage ──────────────────────────────────────────────────

if __name__ == "__main__":
    # Construct the canonical witness pair
    F = FiniteBirthProfile.from_dict(3, {1: {2}, 3: {6}})
    G = FiniteBirthProfile.from_dict(3, {1: {3}, 3: {6}})

    primes = [2, 3, 5]

    print("Global birth sets:")
    print(f"  F: {sorted(global_torsion_birth_set(F))}")
    print(f"  G: {sorted(global_torsion_birth_set(G))}")

    print("\nPrimewise spectra:")
    for p in primes:
        print(f"  p={p}: F -> {sorted(p_torsion_birth_set(p, F))}, "
              f"G -> {sorted(p_torsion_birth_set(p, G))}")

    print(f"\nSpectral entropy: F={spectral_entropy(F, primes):.3f}, "
          f"G={spectral_entropy(G, primes):.3f}")
    print(f"Information loss: F={information_loss(F, primes):.3f}, "
          f"G={information_loss(G, primes):.3f}")

    pairs = find_distinguishing_pairs([F, G], primes)
    print(f"\nDistinguishing pairs found: {len(pairs)}")
    for f, g, p in pairs:
        print(f"  {f} vs {g}, separating prime: {p}")
