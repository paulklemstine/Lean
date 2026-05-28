"""
Algorithms for Functorial Localization of Persistence Modules.

Implements the core algebraic constructions:
- Finite abelian group representation via invariant factors
- p-primary subgroup extraction
- Persistence module localization at a prime
- Torsion birth set computation
- Interleaving construction and verification

All algorithms operate on finitely generated abelian groups
represented as direct sums of cyclic groups Z/nZ.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass, field
from typing import Optional
from math import gcd
from functools import reduce


# ============================================================
# Finite Abelian Group Representation
# ============================================================

@dataclass
class FiniteAbelianGroup:
    """A finitely generated abelian group Z^r ⊕ ⊕_i Z/n_i Z.

    Represented by free_rank and a list of torsion_orders (each >= 2).
    Elements are tuples (free_part, torsion_part) where:
      - free_part is a tuple of integers (length = free_rank)
      - torsion_part is a tuple of integers mod respective orders

    Attributes:
        free_rank: Number of free Z summands
        torsion_orders: List of cyclic group orders (each >= 2)
    """
    free_rank: int = 0
    torsion_orders: list[int] = field(default_factory=list)

    def __post_init__(self):
        self.torsion_orders = sorted(self.torsion_orders)

    @property
    def total_rank(self) -> int:
        return self.free_rank + len(self.torsion_orders)

    def zero(self) -> tuple:
        """Return the zero element."""
        return (tuple(0 for _ in range(self.free_rank)),
                tuple(0 for _ in self.torsion_orders))

    def add(self, a: tuple, b: tuple) -> tuple:
        """Add two elements."""
        free = tuple(x + y for x, y in zip(a[0], b[0]))
        tors = tuple((x + y) % n for x, y, n in zip(a[1], b[1], self.torsion_orders))
        return (free, tors)

    def neg(self, a: tuple) -> tuple:
        """Negate an element."""
        free = tuple(-x for x in a[0])
        tors = tuple((-x) % n for x, n in zip(a[1], self.torsion_orders))
        return (free, tors)

    def smul(self, n: int, a: tuple) -> tuple:
        """Scalar multiply by integer n."""
        free = tuple(n * x for x in a[0])
        tors = tuple((n * x) % m for x, m in zip(a[1], self.torsion_orders))
        return (free, tors)

    def is_zero(self, a: tuple) -> bool:
        """Check if element is zero."""
        return all(x == 0 for x in a[0]) and all(x == 0 for x in a[1])

    def generators(self) -> list[tuple]:
        """Return standard generators."""
        gens = []
        for i in range(self.free_rank):
            free = tuple(1 if j == i else 0 for j in range(self.free_rank))
            tors = tuple(0 for _ in self.torsion_orders)
            gens.append((free, tors))
        for i in range(len(self.torsion_orders)):
            free = tuple(0 for _ in range(self.free_rank))
            tors = tuple(1 if j == i else 0 for j in range(len(self.torsion_orders)))
            gens.append((free, tors))
        return gens

    def all_elements(self) -> list[tuple]:
        """List all elements (only for finite groups with free_rank=0)."""
        if self.free_rank > 0:
            raise ValueError("Cannot enumerate elements of infinite group")
        if not self.torsion_orders:
            return [self.zero()]
        from itertools import product
        result = []
        for combo in product(*(range(n) for n in self.torsion_orders)):
            result.append(((), combo))
        return result


def p_torsion_detected(G: FiniteAbelianGroup, p: int) -> bool:
    """Check if p-torsion is detected: ∃ a ≠ 0, p·a = 0.

    For a group Z^r ⊕ ⊕ Z/n_i Z, p-torsion exists iff
    some n_i is divisible by p.

    Args:
        G: A finite abelian group
        p: An integer >= 2

    Returns:
        True if p-torsion is detected in G
    """
    # Free part never has torsion
    # Torsion part: Z/nZ has p-torsion iff p | n
    return any(n % p == 0 for n in G.torsion_orders)


def global_torsion_detected(G: FiniteAbelianGroup) -> bool:
    """Check if any torsion is detected: ∃ a ≠ 0, n·a = 0 for some n ≥ 2.

    Equivalent to the torsion subgroup being nontrivial.

    Args:
        G: A finite abelian group

    Returns:
        True if global torsion is detected
    """
    return len(G.torsion_orders) > 0


def p_primary_subgroup(G: FiniteAbelianGroup, p: int) -> FiniteAbelianGroup:
    """Compute the p-primary subgroup G[p^∞].

    For G = Z^r ⊕ ⊕ Z/n_i Z, the p-primary subgroup is
    ⊕_{p | n_i} Z/p^{v_p(n_i)} Z where v_p is the p-adic valuation.

    This models the torsion part of G ⊗_Z Z_(p).

    Args:
        G: A finite abelian group
        p: A prime number

    Returns:
        The p-primary subgroup as a FiniteAbelianGroup
    """
    p_primary_orders = []
    for n in G.torsion_orders:
        # Extract p-part of n
        pk = 1
        m = n
        while m % p == 0:
            pk *= p
            m //= p
        if pk > 1:
            p_primary_orders.append(pk)
    return FiniteAbelianGroup(free_rank=0, torsion_orders=p_primary_orders)


def p_adic_valuation(n: int, p: int) -> int:
    """Compute v_p(n), the p-adic valuation of n.

    Args:
        n: A positive integer
        p: A prime

    Returns:
        The largest k such that p^k divides n
    """
    if n == 0:
        return float('inf')
    k = 0
    while n % p == 0:
        k += 1
        n //= p
    return k


# ============================================================
# Persistence Module
# ============================================================

@dataclass
class PersistenceModule:
    """An N-indexed persistence module valued in finite abelian groups.

    Attributes:
        groups: List of FiniteAbelianGroup at each filtration level
        n_levels: Number of filtration levels
    """
    groups: list[FiniteAbelianGroup]

    @property
    def n_levels(self) -> int:
        return len(self.groups)


def localize_at_prime(F: PersistenceModule, p: int) -> PersistenceModule:
    """Localize a persistence module at prime p.

    Replaces each group F_i with its p-primary subgroup F_i[p^∞].
    This models the functor F ↦ F ⊗_Z Z_(p) restricted to torsion.

    Args:
        F: A persistence module
        p: A prime number

    Returns:
        The localized persistence module L_p(F)
    """
    return PersistenceModule(
        groups=[p_primary_subgroup(G, p) for G in F.groups]
    )


def p_torsion_birth_set(F: PersistenceModule, p: int) -> set[int]:
    """Compute the p-torsion birth set PTorBirth(p, F).

    Returns the set of indices where p-torsion first appears.
    Since the birth set has at most one element, this is either
    empty or a singleton.

    Args:
        F: A persistence module
        p: An integer >= 2

    Returns:
        Set of birth indices (at most one element)
    """
    for i, G in enumerate(F.groups):
        if p_torsion_detected(G, p):
            return {i}
    return set()


def global_torsion_birth_set(F: PersistenceModule) -> set[int]:
    """Compute the global torsion birth set GlobTorBirth(F).

    Returns the set of indices where any torsion first appears.

    Args:
        F: A persistence module

    Returns:
        Set of birth indices (at most one element)
    """
    for i, G in enumerate(F.groups):
        if global_torsion_detected(G):
            return {i}
    return set()


def hausdorff_distance(A: set[int], B: set[int]) -> Optional[int]:
    """Compute the Hausdorff distance between two finite sets of integers.

    Returns None if one set is empty and the other is not (infinite distance).
    Returns 0 if both sets are empty.

    Args:
        A: First set of integers
        B: Second set of integers

    Returns:
        Hausdorff distance, or None if undefined
    """
    if not A and not B:
        return 0
    if not A or not B:
        return None  # Infinite distance

    d1 = max(min(abs(a - b) for b in B) for a in A)
    d2 = max(min(abs(a - b) for a in A) for b in B)
    return max(d1, d2)


def prime_support(F: PersistenceModule) -> set[int]:
    """Compute the prime support of a persistence module.

    Returns the set of primes p such that p-torsion appears at some level.

    Args:
        F: A persistence module

    Returns:
        Set of primes in the torsion support
    """
    primes = set()
    for G in F.groups:
        for n in G.torsion_orders:
            # Factor n and collect prime factors
            m = n
            for p in range(2, m + 1):
                if p * p > m:
                    if m > 1:
                        primes.add(m)
                    break
                while m % p == 0:
                    primes.add(p)
                    m //= p
    return primes


def verify_birth_set_identification(F: PersistenceModule, p: int) -> bool:
    """Verify Theorem 2: PTorBirth(p, F) = GlobTorBirth(L_p(F)).

    Args:
        F: A persistence module
        p: A prime number

    Returns:
        True if the identification holds
    """
    lhs = p_torsion_birth_set(F, p)
    localized = localize_at_prime(F, p)
    rhs = global_torsion_birth_set(localized)
    return lhs == rhs


def verify_prime_decomposition(F: PersistenceModule) -> bool:
    """Verify the prime decomposition theorem.

    Checks that every global birth index has a prime channel birth ≤ it.

    Args:
        F: A persistence module

    Returns:
        True if the decomposition holds
    """
    glob_births = global_torsion_birth_set(F)
    primes = prime_support(F)

    for i in glob_births:
        found = False
        for p in primes:
            p_births = p_torsion_birth_set(F, p)
            if p_births and min(p_births) <= i:
                found = True
                break
        if not found:
            return False
    return True


# ============================================================
# Random Generation
# ============================================================

def random_finite_abelian_group(
    max_free_rank: int = 2,
    max_torsion_summands: int = 3,
    primes: list[int] = [2, 3, 5],
    max_power: int = 3,
    rng: Optional[np.random.Generator] = None
) -> FiniteAbelianGroup:
    """Generate a random finitely generated abelian group.

    Args:
        max_free_rank: Maximum free rank
        max_torsion_summands: Maximum number of torsion summands
        primes: Primes to use for torsion orders
        max_power: Maximum prime power exponent
        rng: Random number generator

    Returns:
        A random FiniteAbelianGroup
    """
    if rng is None:
        rng = np.random.default_rng()

    free_rank = rng.integers(0, max_free_rank + 1)
    n_torsion = rng.integers(0, max_torsion_summands + 1)
    torsion_orders = []
    for _ in range(n_torsion):
        p = primes[rng.integers(0, len(primes))]
        k = rng.integers(1, max_power + 1)
        torsion_orders.append(int(p ** k))
    return FiniteAbelianGroup(free_rank=int(free_rank), torsion_orders=torsion_orders)


def random_persistence_module(
    n_levels: int = 10,
    **kwargs
) -> PersistenceModule:
    """Generate a random persistence module.

    Each level gets a random finite abelian group. The structure maps
    are implicit (we only track groups for birth set analysis).

    Args:
        n_levels: Number of filtration levels
        **kwargs: Passed to random_finite_abelian_group

    Returns:
        A random PersistenceModule
    """
    rng = kwargs.pop('rng', np.random.default_rng())
    groups = []
    for i in range(n_levels):
        # Allow torsion to "appear" partway through
        if rng.random() < 0.3 and i < n_levels // 2:
            groups.append(FiniteAbelianGroup(free_rank=rng.integers(0, 3)))
        else:
            groups.append(random_finite_abelian_group(rng=rng, **kwargs))
    return PersistenceModule(groups=groups)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithms for Functorial Localization of Persistence Modules")
    print("=" * 60)

    # Example 1: Basic group operations
    G = FiniteAbelianGroup(free_rank=1, torsion_orders=[6, 4])
    print(f"\nGroup: Z ⊕ Z/6Z ⊕ Z/4Z")
    print(f"  2-torsion detected: {p_torsion_detected(G, 2)}")
    print(f"  3-torsion detected: {p_torsion_detected(G, 3)}")
    print(f"  5-torsion detected: {p_torsion_detected(G, 5)}")
    print(f"  2-primary subgroup: {p_primary_subgroup(G, 2)}")
    print(f"  3-primary subgroup: {p_primary_subgroup(G, 3)}")

    # Example 2: Persistence module localization
    F = PersistenceModule(groups=[
        FiniteAbelianGroup(free_rank=1),          # Level 0: Z (no torsion)
        FiniteAbelianGroup(free_rank=1),          # Level 1: Z (no torsion)
        FiniteAbelianGroup(torsion_orders=[6]),    # Level 2: Z/6Z (2,3-torsion)
        FiniteAbelianGroup(torsion_orders=[6, 4]), # Level 3: Z/6Z ⊕ Z/4Z
    ])
    print(f"\nPersistence module F:")
    for i, G in enumerate(F.groups):
        print(f"  Level {i}: Z^{G.free_rank} ⊕ {'⊕'.join(f'Z/{n}Z' for n in G.torsion_orders) or '0'}")

    L2 = localize_at_prime(F, 2)
    L3 = localize_at_prime(F, 3)
    print(f"\nLocalized at 2:")
    for i, G in enumerate(L2.groups):
        desc = '⊕'.join(f'Z/{n}Z' for n in G.torsion_orders) or '0'
        print(f"  Level {i}: {desc}")
    print(f"\nLocalized at 3:")
    for i, G in enumerate(L3.groups):
        desc = '⊕'.join(f'Z/{n}Z' for n in G.torsion_orders) or '0'
        print(f"  Level {i}: {desc}")

    # Verify theorems
    print(f"\nBirth set verification:")
    print(f"  PTorBirth(2, F) = {p_torsion_birth_set(F, 2)}")
    print(f"  GlobTorBirth(L_2(F)) = {global_torsion_birth_set(L2)}")
    print(f"  Theorem 2 verified: {verify_birth_set_identification(F, 2)}")
    print(f"  PTorBirth(3, F) = {p_torsion_birth_set(F, 3)}")
    print(f"  GlobTorBirth(L_3(F)) = {global_torsion_birth_set(L3)}")
    print(f"  Theorem 2 verified: {verify_birth_set_identification(F, 3)}")
    print(f"  Prime decomposition verified: {verify_prime_decomposition(F)}")
