#!/usr/bin/env python3
"""
Algorithms for Explicit Class Field Theory

Implements the core computational methods formalized in the Hilbert 12 blueprint:
1. Regular permutation representation construction
2. Orbit computation engine
3. Faithfulness verification
4. Cycle decomposition and type analysis
5. Class-action collapse detection

All algorithms correspond to formally verified constructions in the companion
proof development.
"""

from typing import List, Tuple, Dict, Set, Optional, FrozenSet
from collections import Counter
from itertools import product
import math


# ─────────────────────────────────────────────────────────────────────
# Core Data Structures
# ─────────────────────────────────────────────────────────────────────

class FiniteGroup:
    """
    Abstract base for a finite group with elements indexed 0..n-1.

    Subclasses must implement:
      - op(a, b) -> int : group operation
      - inv(a) -> int   : group inverse
      - identity -> int : identity element index
    """

    def __init__(self, size: int):
        self.size = size
        self.elements = list(range(size))

    def op(self, a: int, b: int) -> int:
        raise NotImplementedError

    def inv(self, a: int) -> int:
        raise NotImplementedError

    @property
    def identity(self) -> int:
        raise NotImplementedError


class CyclicGroup(FiniteGroup):
    """The cyclic group Z/nZ."""

    def __init__(self, n: int):
        super().__init__(n)
        self.n = n

    def op(self, a: int, b: int) -> int:
        return (a + b) % self.n

    def inv(self, a: int) -> int:
        return (-a) % self.n

    @property
    def identity(self) -> int:
        return 0

    def __repr__(self):
        return f"Z/{self.n}"


class ProductGroup(FiniteGroup):
    """
    Direct product of finite abelian groups, represented as products of cyclic groups.

    Elements are encoded as integers via mixed-radix representation.

    Time complexity:
      - op: O(k) where k = number of factors
      - inv: O(k)

    Space: O(n) where n = product of orders
    """

    def __init__(self, orders: Tuple[int, ...]):
        """
        Args:
            orders: Tuple of positive integers (n1, n2, ..., nk).
                    Represents Z/n1 × Z/n2 × ... × Z/nk.
        """
        self.orders = orders
        size = math.prod(orders)
        super().__init__(size)

    def _encode(self, components: Tuple[int, ...]) -> int:
        """Encode a tuple of components into a single integer index."""
        idx = 0
        for i, (c, n) in enumerate(zip(components, self.orders)):
            idx = idx * n + c
        return idx

    def _decode(self, idx: int) -> Tuple[int, ...]:
        """Decode an integer index into component tuple."""
        components = []
        for n in reversed(self.orders):
            components.append(idx % n)
            idx //= n
        return tuple(reversed(components))

    def op(self, a: int, b: int) -> int:
        ca, cb = self._decode(a), self._decode(b)
        result = tuple((ai + bi) % n for ai, bi, n in zip(ca, cb, self.orders))
        return self._encode(result)

    def inv(self, a: int) -> int:
        ca = self._decode(a)
        result = tuple((-c) % n for c, n in zip(ca, self.orders))
        return self._encode(result)

    @property
    def identity(self) -> int:
        return 0

    def __repr__(self):
        return " × ".join(f"Z/{n}" for n in self.orders)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Regular Permutation Representation
# ─────────────────────────────────────────────────────────────────────

def regular_representation(G: FiniteGroup) -> List[List[int]]:
    """
    Construct the left regular permutation representation.

    For each group element g, computes the permutation σ_g where
    σ_g(x) = g · x.

    Args:
        G: A finite group.

    Returns:
        List of permutations, one per group element.
        perms[g][x] = index of g · x.

    Time complexity: O(n²) where n = |G|
    Space complexity: O(n²)

    Corresponds to the formally verified `regularClassAction` definition.
    """
    n = G.size
    perms = []
    for g in range(n):
        perm = [G.op(g, x) for x in range(n)]
        perms.append(perm)
    return perms


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Faithfulness Verification
# ─────────────────────────────────────────────────────────────────────

def verify_faithfulness(perms: List[List[int]]) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Verify that a permutation representation is faithful (injective).

    Args:
        perms: List of permutations.

    Returns:
        (True, None) if faithful, or (False, (g, h)) where g ≠ h but ρ(g) = ρ(h).

    Time complexity: O(n² log n) using sorted comparison
    Space complexity: O(n²)

    Corresponds to `regularClassAction_injective`.
    """
    seen: Dict[tuple, int] = {}
    for g, perm in enumerate(perms):
        key = tuple(perm)
        if key in seen:
            return False, (seen[key], g)
        seen[key] = g
    return True, None


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Orbit Computation
# ─────────────────────────────────────────────────────────────────────

def compute_orbit(perms: List[List[int]], x: int) -> Set[int]:
    """
    Compute the orbit of element x under all permutations.

    Uses BFS to find all elements reachable from x.

    Args:
        perms: List of permutations (the representation).
        x: Starting element index.

    Returns:
        Set of all elements in the orbit of x.

    Time complexity: O(n · |G|) where n = number of points
    Space complexity: O(n)

    Corresponds to `permOrbit` and `mem_permOrbit_iff`.
    """
    orbit = {x}
    frontier = [x]
    while frontier:
        current = frontier.pop()
        for perm in perms:
            img = perm[current]
            if img not in orbit:
                orbit.add(img)
                frontier.append(img)
    return orbit


def compute_all_orbits(perms: List[List[int]], n: int) -> List[FrozenSet[int]]:
    """
    Partition {0, ..., n-1} into orbits under the permutation group.

    Time complexity: O(n² · |G|)
    Space complexity: O(n)
    """
    remaining = set(range(n))
    orbits = []
    while remaining:
        x = min(remaining)
        orb = compute_orbit(perms, x)
        orbits.append(frozenset(orb))
        remaining -= orb
    return orbits


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Cycle Decomposition
# ─────────────────────────────────────────────────────────────────────

def cycle_decomposition(perm: List[int]) -> List[List[int]]:
    """
    Decompose a permutation into disjoint cycles.

    Args:
        perm: Permutation as a list of images.

    Returns:
        List of cycles. Each cycle is a list of elements.
        Fixed points are included as 1-cycles.

    Time complexity: O(n)
    Space complexity: O(n)
    """
    n = len(perm)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if visited[i]:
            continue
        cycle = []
        j = i
        while not visited[j]:
            visited[j] = True
            cycle.append(j)
            j = perm[j]
        cycles.append(cycle)
    return cycles


def cycle_type(perm: List[int]) -> Tuple[int, ...]:
    """
    Compute the cycle type of a permutation.

    Returns sorted tuple of cycle lengths (descending).

    Time complexity: O(n)
    """
    cycles = cycle_decomposition(perm)
    return tuple(sorted([len(c) for c in cycles], reverse=True))


def cycle_type_signature(G: FiniteGroup) -> Counter:
    """
    Compute the complete cycle type signature of a group's regular representation.

    This is the multiset of cycle types over all non-identity elements.
    By the conjecture, this should distinguish non-isomorphic abelian groups
    in most cases.

    Time complexity: O(n²)
    """
    perms = regular_representation(G)
    sig = Counter()
    for g in range(G.size):
        if g == G.identity:
            continue
        ct = cycle_type(perms[g])
        sig[ct] += 1
    return sig


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Commutativity Verification
# ─────────────────────────────────────────────────────────────────────

def verify_commutativity(perms: List[List[int]]) -> Tuple[bool, Optional[Tuple[int, int, int]]]:
    """
    Verify that all permutation pairs commute.

    Args:
        perms: List of permutations.

    Returns:
        (True, None) if all commute, or (False, (a, b, x)) witnessing non-commutativity.

    Time complexity: O(|G|² · n)

    Corresponds to `abelian_class_symmetry_commuting`.
    """
    n = len(perms[0]) if perms else 0
    for i, pa in enumerate(perms):
        for j, pb in enumerate(perms):
            if j <= i:
                continue
            for x in range(n):
                if pa[pb[x]] != pb[pa[x]]:
                    return False, (i, j, x)
    return True, None


# ─────────────────────────────────────────────────────────────────────
# Algorithm 6: Class-Action Collapse Detection
# ─────────────────────────────────────────────────────────────────────

def detect_collapse(G: FiniteGroup) -> Dict[str, object]:
    """
    Detect whether the class action collapses (all permutations are identity).

    This implements the computational test for the trivial-class-group theorem:
    when |G| = 1, all permutations should be trivial.

    Returns a diagnostic dict with:
      - 'collapsed': bool
      - 'group_size': int
      - 'non_trivial_count': int
      - 'identity_count': int

    Corresponds to `trivial_class_data_gives_trivial_representation`.
    """
    perms = regular_representation(G)
    n = G.size

    identity = list(range(n))
    id_count = sum(1 for p in perms if p == identity)

    return {
        'collapsed': id_count == len(perms),
        'group_size': n,
        'non_trivial_count': len(perms) - id_count,
        'identity_count': id_count,
    }


# ─────────────────────────────────────────────────────────────────────
# Algorithm 7: Extension Degree Bound Computation
# ─────────────────────────────────────────────────────────────────────

def extension_degree_bounds(G: FiniteGroup) -> Dict[str, int]:
    """
    Compute the orbit-based extension degree bounds.

    For each element, the orbit size under the regular action gives
    an upper bound on the 'extension degree' controlled by that element.

    Returns:
      - 'max_orbit_size': maximum orbit size over all elements
      - 'min_orbit_size': minimum orbit size
      - 'group_order': |G| (the universal upper bound)
      - 'rep_image_size': |image(ρ)| (equals |G| by faithfulness)

    Corresponds to `orbit_card_le_classGroup_card` and `class_card_eq_rep_image_card`.
    """
    perms = regular_representation(G)
    n = G.size

    orbit_sizes = []
    for x in range(n):
        orb = compute_orbit(perms, x)
        orbit_sizes.append(len(orb))

    rep_image = set(tuple(p) for p in perms)

    return {
        'max_orbit_size': max(orbit_sizes),
        'min_orbit_size': min(orbit_sizes),
        'group_order': n,
        'rep_image_size': len(rep_image),
        'all_orbits_equal_group_order': all(s == n for s in orbit_sizes),
    }


# ─────────────────────────────────────────────────────────────────────
# Enumeration of all abelian groups of given order
# ─────────────────────────────────────────────────────────────────────

def abelian_groups_of_order(n: int) -> List[ProductGroup]:
    """
    Enumerate all finite abelian groups of order n (up to isomorphism).

    Uses the fundamental theorem of finite abelian groups: every finite
    abelian group is a product of cyclic groups of prime power order.

    Time complexity: O(p(n)) where p is the partition function applied
    to prime factorization.
    """
    if n <= 0:
        return []
    if n == 1:
        return [ProductGroup((1,))]

    # Factor n into prime powers
    factors = {}
    temp = n
    d = 2
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = factors.get(temp, 0) + 1

    # For each prime p^k, enumerate partitions of k
    def integer_partitions(k: int) -> List[List[int]]:
        if k == 0:
            return [[]]
        result = []
        def helper(remaining, max_part, current):
            if remaining == 0:
                result.append(list(current))
                return
            for part in range(min(remaining, max_part), 0, -1):
                helper(remaining - part, part, current + [part])
        helper(k, k, [])
        return result

    # Generate all combinations
    prime_partitions = []
    for p, k in sorted(factors.items()):
        parts = integer_partitions(k)
        prime_partitions.append([(p, part) for part in parts])

    # Take Cartesian product over primes
    groups = []
    for combo in product(*prime_partitions):
        orders = []
        for p, partition in combo:
            for exp in partition:
                orders.append(p ** exp)
        orders.sort(reverse=True)
        groups.append(ProductGroup(tuple(orders)))

    return groups


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Explicit Class Field Theory")
    print("=" * 50)

    # Example: Z/6
    G = ProductGroup((6,))
    print(f"\nGroup: {G}")

    perms = regular_representation(G)
    faithful, witness = verify_faithfulness(perms)
    print(f"Faithful: {faithful}")

    commuting, cw = verify_commutativity(perms)
    print(f"Commuting: {commuting}")

    bounds = extension_degree_bounds(G)
    print(f"Extension bounds: {bounds}")

    collapse = detect_collapse(G)
    print(f"Collapse: {collapse}")

    sig = cycle_type_signature(G)
    print(f"Cycle type signature: {dict(sig)}")

    # Enumerate all abelian groups of order 12
    print(f"\nAbelian groups of order 12:")
    for g in abelian_groups_of_order(12):
        print(f"  {g} — signature: {dict(cycle_type_signature(g))}")
