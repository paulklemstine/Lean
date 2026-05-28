#!/usr/bin/env python3
"""
Algorithms for Primewise Birth Spectra Analysis

Implements the core algorithms from the research paper:
1. Computing global and primewise birth sets
2. Searching for distinguishing pairs
3. Computing information loss metrics
4. Prime support decomposition
"""

from typing import Dict, List, Set, Tuple, Optional
from math import log2, gcd
from itertools import combinations


# ---------- Core types ----------

class BirthProfile:
    """A finite birth profile recording torsion orders at each filtration level.

    Attributes:
        orders_at: dict mapping level -> set of torsion orders born there
    """

    def __init__(self, orders_at: Dict[int, Set[int]]):
        self.orders_at = {k: set(v) for k, v in orders_at.items()}

    @property
    def max_level(self) -> int:
        return max(self.orders_at.keys()) if self.orders_at else 0

    @property
    def nonempty_levels(self) -> Dict[int, Set[int]]:
        return {k: v for k, v in sorted(self.orders_at.items()) if v}

    def __repr__(self):
        return f"BirthProfile({self.nonempty_levels})"

    def __eq__(self, other):
        if not isinstance(other, BirthProfile):
            return False
        return self.orders_at == other.orders_at

    def __hash__(self):
        return hash(tuple(sorted(
            (k, frozenset(v)) for k, v in self.orders_at.items() if v
        )))


# ---------- Algorithm 1: Birth set computation ----------

def global_torsion_birth_set(F: BirthProfile) -> Set[int]:
    """Compute the global torsion birth set.

    Returns the set of levels at which some torsion order m > 1 is born.

    Time complexity: O(L * M) where L = number of levels, M = max orders per level
    Space complexity: O(L)

    >>> F = BirthProfile({1: {2}, 3: {6}})
    >>> sorted(global_torsion_birth_set(F))
    [1, 3]
    """
    return {level for level, orders in F.orders_at.items()
            if any(m > 1 for m in orders)}


def p_torsion_birth_set(p: int, F: BirthProfile) -> Set[int]:
    """Compute the p-torsion birth set.

    Returns the set of levels at which some torsion order m > 1
    divisible by p is born.

    Time complexity: O(L * M)
    Space complexity: O(L)

    >>> F = BirthProfile({1: {2}, 3: {6}})
    >>> sorted(p_torsion_birth_set(2, F))
    [1, 3]
    >>> sorted(p_torsion_birth_set(3, F))
    [3]
    """
    return {level for level, orders in F.orders_at.items()
            if any(m > 1 and m % p == 0 for m in orders)}


def primewise_birth_spectrum(F: BirthProfile, primes: List[int]) -> Dict[int, Set[int]]:
    """Compute the full primewise birth spectrum.

    Time complexity: O(P * L * M) where P = number of primes
    Space complexity: O(P * L)

    >>> F = BirthProfile({1: {2}, 3: {6}})
    >>> spec = primewise_birth_spectrum(F, [2, 3, 5])
    >>> sorted(spec[2])
    [1, 3]
    >>> sorted(spec[3])
    [3]
    """
    return {p: p_torsion_birth_set(p, F) for p in primes}


# ---------- Algorithm 2: Prime support at a level ----------

def prime_factors(n: int) -> Set[int]:
    """Return the set of prime factors of n.

    >>> sorted(prime_factors(12))
    [2, 3]
    >>> sorted(prime_factors(1))
    []
    """
    if n <= 1:
        return set()
    factors = set()
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors.add(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.add(temp)
    return factors


def prime_support_at_level(F: BirthProfile, level: int) -> Set[int]:
    """Compute the set of primes appearing in torsion orders at a given level.

    >>> F = BirthProfile({1: {6}, 3: {10}})
    >>> sorted(prime_support_at_level(F, 1))
    [2, 3]
    >>> sorted(prime_support_at_level(F, 3))
    [2, 5]
    """
    orders = F.orders_at.get(level, set())
    result = set()
    for m in orders:
        if m > 1:
            result |= prime_factors(m)
    return result


# ---------- Algorithm 3: Distinguishing pair search ----------

def distinguishing_pairs(
    profiles: List[BirthProfile],
    primes: List[int]
) -> List[Tuple[BirthProfile, BirthProfile, int]]:
    """Search for pairs with equal global but different primewise birth sets.

    For each pair (F, G) of profiles with equal global birth sets,
    checks whether some prime p produces different p-torsion birth sets.

    Time complexity: O(N^2 * P * L * M) where N = number of profiles
    Space complexity: O(N^2 * P) worst case for output

    Returns list of (F, G, p) tuples where p is a separating prime.

    >>> F = BirthProfile({1: {2}, 3: {6}})
    >>> G = BirthProfile({1: {3}, 3: {6}})
    >>> pairs = distinguishing_pairs([F, G], [2, 3])
    >>> len(pairs) > 0
    True
    """
    result = []
    for i, F in enumerate(profiles):
        gF = global_torsion_birth_set(F)
        for j, G in enumerate(profiles):
            if i >= j:
                continue
            gG = global_torsion_birth_set(G)
            if gF != gG:
                continue
            for p in primes:
                pF = p_torsion_birth_set(p, F)
                pG = p_torsion_birth_set(p, G)
                if pF != pG:
                    result.append((F, G, p))
    return result


# ---------- Algorithm 4: Information loss metric ----------

def spectral_entropy(F: BirthProfile, primes: List[int]) -> float:
    """Compute the spectral entropy of a birth profile.

    Measures the information content of the primewise birth spectrum
    by computing the entropy of the distribution of prime appearances
    across levels.

    Time complexity: O(P * L * M)
    Space complexity: O(P)

    >>> F = BirthProfile({1: {2}, 3: {6}})
    >>> spectral_entropy(F, [2, 3]) > 0
    True
    """
    counts = {}
    total = 0
    for p in primes:
        c = len(p_torsion_birth_set(p, F))
        if c > 0:
            counts[p] = c
            total += c

    if total == 0:
        return 0.0

    entropy = 0.0
    for p, c in counts.items():
        prob = c / total
        entropy -= prob * log2(prob)
    return entropy


def information_loss(F: BirthProfile, primes: List[int]) -> float:
    """Compute the information lost when projecting from primewise to global.

    Returns H(primewise) - H(global), measuring how much the global
    invariant compresses the primewise data.

    >>> F = BirthProfile({1: {6}, 3: {10}})
    >>> information_loss(F, [2, 3, 5]) >= 0
    True
    """
    h_prime = spectral_entropy(F, primes)

    global_set = global_torsion_birth_set(F)
    n_global = len(global_set)
    if n_global == 0:
        return 0.0
    h_global = log2(n_global) if n_global > 1 else 0.0

    return max(0.0, h_prime - h_global)


# ---------- Algorithm 5: Minimal separating pair search ----------

def find_minimal_separating_pair(
    max_level: int = 4,
    order_bound: int = 30,
    primes: Optional[List[int]] = None,
    max_orders_per_level: int = 2
) -> Optional[Tuple[BirthProfile, BirthProfile, int, str]]:
    """Find the minimal separating pair by exhaustive search.

    Minimality is measured by total number of born summands across both profiles.

    Time complexity: O(D^(2*L) * P) where D = number of candidate orders, L = levels
    Space complexity: O(D^L) for storing profiles

    Returns (F, G, separating_prime, description) or None.

    >>> result = find_minimal_separating_pair(max_level=3, order_bound=6)
    >>> result is not None
    True
    """
    if primes is None:
        primes = sorted(prime_factors(order_bound))

    divisors = sorted(d for d in range(2, order_bound + 1) if order_bound % d == 0)

    # Generate single-order subsets
    order_sets = [frozenset()]
    for d in divisors:
        order_sets.append(frozenset([d]))
    if max_orders_per_level >= 2:
        for i, d1 in enumerate(divisors):
            for d2 in divisors[i+1:]:
                order_sets.append(frozenset([d1, d2]))

    best = None
    best_size = float('inf')

    levels = list(range(max_level + 1))
    profiles_by_global = {}

    # Build profiles with 1-2 nonempty levels
    for l1 in levels:
        for s1 in order_sets:
            if not s1:
                continue
            # Single nonempty level
            orders = {l: set() for l in levels}
            orders[l1] = set(s1)
            F = BirthProfile(orders)
            gF = frozenset(global_torsion_birth_set(F))
            profiles_by_global.setdefault(gF, []).append(F)

            # Two nonempty levels
            for l2 in levels:
                if l2 <= l1:
                    continue
                for s2 in order_sets:
                    if not s2:
                        continue
                    orders2 = {l: set() for l in levels}
                    orders2[l1] = set(s1)
                    orders2[l2] = set(s2)
                    G = BirthProfile(orders2)
                    gG = frozenset(global_torsion_birth_set(G))
                    profiles_by_global.setdefault(gG, []).append(G)

    # Search within each global-birth-set class
    for gset, group in profiles_by_global.items():
        for i, F in enumerate(group):
            for G in group[i+1:]:
                size = (sum(len(v) for v in F.orders_at.values()) +
                        sum(len(v) for v in G.orders_at.values()))
                if size >= best_size:
                    continue
                for p in primes:
                    pF = p_torsion_birth_set(p, F)
                    pG = p_torsion_birth_set(p, G)
                    if pF != pG:
                        best = (F, G, p,
                                f"size={size}, global={sorted(gset)}")
                        best_size = size
                        break

    return best


if __name__ == "__main__":
    import doctest
    doctest.testmod()

    print("=== Minimal Separating Pair Search ===")
    result = find_minimal_separating_pair(max_level=4, order_bound=30)
    if result:
        F, G, p, desc = result
        print(f"Found: F={F}, G={G}")
        print(f"Separating prime: {p}")
        print(f"Details: {desc}")
    else:
        print("No separating pair found")
