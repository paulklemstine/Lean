#!/usr/bin/env python3
"""
Algorithms for Dreamtime Algebra: Aboriginal Kinship Systems as Group Theory

Type-hinted implementations of the core algorithms for constructing,
analyzing, and classifying kinship systems as finite group actions.
"""

from typing import List, Tuple, Set, Dict, Optional, Callable
from dataclasses import dataclass
from itertools import product as cartesian_product
import math


@dataclass
class KinshipSystem:
    """A kinship system on n sections with marriage and descent permutations.

    Attributes:
        n: Number of sections.
        marriage: Marriage permutation as a list (marriage[i] = partner of i).
        descent: Descent permutation as a list (descent[i] = child-section of i).
        section_names: Optional human-readable names for sections.
    """
    n: int
    marriage: List[int]
    descent: List[int]
    section_names: Optional[List[str]] = None

    def dreamtime(self) -> List[int]:
        """Compute the Dreamtime operator T = marriage ∘ descent."""
        return [self.marriage[self.descent[i]] for i in range(self.n)]

    def validate(self) -> Dict[str, bool]:
        """Check all kinship axioms."""
        m, d = self.marriage, self.descent
        n = self.n
        return {
            "marriage_involution": all(m[m[i]] == i for i in range(n)),
            "marriage_fixed_point_free": all(m[i] != i for i in range(n)),
            "descent_involution": all(d[d[i]] == i for i in range(n)),
            "marriage_is_permutation": sorted(m) == list(range(n)),
            "descent_is_permutation": sorted(d) == list(range(n)),
        }

    def is_commutative(self) -> bool:
        """Check if marriage and descent commute."""
        m, d = self.marriage, self.descent
        return all(m[d[i]] == d[m[i]] for i in range(self.n))


def compose_permutations(p: List[int], q: List[int]) -> List[int]:
    """Compose permutations: (p ∘ q)(i) = p(q(i))."""
    return [p[q[i]] for i in range(len(p))]


def generate_kinship_group(ks: KinshipSystem) -> List[List[int]]:
    """Generate all elements of the kinship group ⟨marriage, descent⟩.

    Uses BFS on the Cayley graph starting from the identity.

    Returns:
        List of permutations forming the group.
    """
    n = ks.n
    identity = list(range(n))
    seen: Set[Tuple[int, ...]] = {tuple(identity)}
    queue = [identity]
    generators = [ks.marriage, ks.descent]

    while queue:
        current = queue.pop(0)
        for gen in generators:
            new = compose_permutations(gen, current)
            key = tuple(new)
            if key not in seen:
                seen.add(key)
                queue.append(new)

    return [list(t) for t in sorted(seen)]


def is_regular_action(group: List[List[int]]) -> bool:
    """Check if a permutation group acts regularly (free + transitive).

    A regular action means:
    - Free: no non-identity element has a fixed point
    - Transitive: for any i, j there exists g with g(i) = j
    """
    n = len(group[0])
    identity = list(range(n))

    # Check freeness
    for g in group:
        if g != identity:
            if any(g[i] == i for i in range(n)):
                return False

    # Check transitivity
    for i in range(n):
        reachable = {g[i] for g in group}
        if reachable != set(range(n)):
            return False

    return True


def classify_abelian_group(group: List[List[int]]) -> List[int]:
    """Classify a finite abelian permutation group as a product of cyclic groups.

    Returns the invariant factors [d1, d2, ..., dk] such that
    G ≅ Z/d1 × Z/d2 × ... × Z/dk with d1 | d2 | ... | dk.
    """
    n = len(group[0])
    identity = list(range(n))
    order = len(group)

    if order == 1:
        return []

    # Compute order of each element
    orders = []
    for g in group:
        k = 1
        current = g[:]
        while current != identity:
            current = compose_permutations(g, current)
            k += 1
        orders.append(k)

    max_order = max(orders)

    # For elementary abelian 2-groups: all orders are 1 or 2
    if max_order <= 2:
        k = int(math.log2(order))
        return [2] * k

    # General case: use Smith normal form approach
    # (simplified for small groups)
    factors = []
    remaining = order
    for p in [2, 3, 5, 7, 11, 13]:
        while remaining % p == 0:
            factors.append(p)
            remaining //= p
    if remaining > 1:
        factors.append(remaining)

    return sorted(factors)


def construct_kariera() -> KinshipSystem:
    """Construct the 4-section Kariera kinship system.

    Sections: A(0), B(1), C(2), D(3)
    Marriage: A↔B, C↔D (moiety exchange)
    Descent: A↔C, B↔D (generational alternation)
    """
    return KinshipSystem(
        n=4,
        marriage=[1, 0, 3, 2],
        descent=[2, 3, 0, 1],
        section_names=["Banaka", "Burung", "Karimera", "Palyeri"]
    )


def construct_aranda() -> KinshipSystem:
    """Construct the 8-subsection Aranda kinship system.

    Uses bit-flip representation:
    - Marriage: flip bit 0 (moiety)
    - Descent: flip bit 1 (patriline)
    Matrilineal descent (flip bit 2) is the Dreamtime operator.
    """
    return KinshipSystem(
        n=8,
        marriage=[i ^ 1 for i in range(8)],
        descent=[i ^ 2 for i in range(8)],
        section_names=[
            "Pananka", "Paltara", "Purula", "Kamara",
            "Ngala", "Mbitjana", "Bangata", "Knuraia"
        ]
    )


def compute_coset_structure(ks: KinshipSystem) -> Dict[str, List[Set[int]]]:
    """Compute the coset decomposition induced by marriage.

    The descent subgroup H = ⟨d⟩ partitions sections into cosets.
    Marriage maps each coset to a different coset.

    Returns:
        Dictionary with 'cosets' (list of cosets of ⟨d⟩) and
        'marriage_map' showing which coset maps to which.
    """
    n = ks.n
    d = ks.descent
    m = ks.marriage

    # Generate descent subgroup orbits (cosets of ⟨d⟩)
    visited = [False] * n
    cosets = []
    for i in range(n):
        if not visited[i]:
            coset = set()
            x = i
            while x not in coset:
                coset.add(x)
                visited[x] = True
                x = d[x]
            cosets.append(coset)

    return {
        'cosets': cosets,
        'marriage_map': [{m[x] for x in coset} for coset in cosets]
    }


def hamming_distance(a: Tuple[int, ...], b: Tuple[int, ...]) -> int:
    """Compute Hamming distance between two binary tuples."""
    return sum(1 for x, y in zip(a, b) if x != y)


def binary_encode(x: int, k: int) -> Tuple[int, ...]:
    """Encode integer x as k-bit binary tuple."""
    return tuple((x >> i) & 1 for i in range(k))


def kinship_hamming_analysis(ks: KinshipSystem) -> Dict[str, any]:
    """Analyze Hamming distance structure of kinship transformations.

    Encodes sections as binary strings and computes Hamming distances
    between each section and its marriage/descent partner.
    """
    k = int(math.log2(ks.n))
    results = {
        'marriage_distances': [],
        'descent_distances': [],
        'dreamtime_distances': [],
    }

    T = ks.dreamtime()
    for i in range(ks.n):
        bi = binary_encode(i, k)
        results['marriage_distances'].append(
            hamming_distance(bi, binary_encode(ks.marriage[i], k))
        )
        results['descent_distances'].append(
            hamming_distance(bi, binary_encode(ks.descent[i], k))
        )
        results['dreamtime_distances'].append(
            hamming_distance(bi, binary_encode(T[i], k))
        )

    return results


def construct_generalized_kinship(k: int) -> KinshipSystem:
    """Construct a generalized 2^k-section kinship system.

    Uses k commuting involutions (bit flips) as generators.
    The first generator is marriage, the second is descent.

    Args:
        k: Number of generators (k ≥ 2).

    Returns:
        A kinship system on 2^k sections.
    """
    assert k >= 2, "Need at least 2 generators"
    n = 2 ** k
    marriage = [i ^ 1 for i in range(n)]  # flip bit 0
    descent = [i ^ 2 for i in range(n)]   # flip bit 1
    return KinshipSystem(n=n, marriage=marriage, descent=descent)


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("KINSHIP SYSTEM ANALYSIS")
    print("=" * 60)

    for name, ks in [("Kariera (4-section)", construct_kariera()),
                      ("Aranda (8-subsection)", construct_aranda())]:
        print(f"\n--- {name} ---")
        validation = ks.validate()
        print(f"  Valid: {all(validation.values())}")
        print(f"  Commutative: {ks.is_commutative()}")

        group = generate_kinship_group(ks)
        print(f"  Group order: {len(group)}")
        print(f"  Regular action: {is_regular_action(group)}")
        print(f"  Classification: Z_{' × Z_'.join(map(str, classify_abelian_group(group)))}")

        cosets = compute_coset_structure(ks)
        print(f"  Cosets of ⟨descent⟩: {cosets['cosets']}")

        hamming = kinship_hamming_analysis(ks)
        print(f"  Marriage Hamming distances: {hamming['marriage_distances']}")
        print(f"  All marriage distances = 1: {all(d == 1 for d in hamming['marriage_distances'])}")

    print(f"\n--- Generalized 16-section (k=4) ---")
    ks16 = construct_generalized_kinship(4)
    print(f"  Valid: {all(ks16.validate().values())}")
    group16 = generate_kinship_group(ks16)
    print(f"  Group order: {len(group16)}")
    print(f"  Regular: {is_regular_action(group16)}")
