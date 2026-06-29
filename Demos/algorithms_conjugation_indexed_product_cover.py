#!/usr/bin/env python3
"""
Algorithms for Conjugation-Indexed Product Covering

Implements the core algorithms:
1. ConjugationIndex: Compute [H : H ∩ g⁻¹Hg] for finite groups
2. ProductCoverBound: Compute the C²·L bound
3. GreedyCovering: Greedy algorithm for minimum covering number
4. DoubleCosetDecomposition: Decompose HgH into left cosets

All algorithms work with finite groups represented as sets of permutations.
"""

from typing import FrozenSet, Set, Tuple, List, Dict, Optional
from itertools import permutations


def compose_perm(p: tuple, q: tuple) -> tuple:
    """Compose permutations: (p∘q)(i) = p[q[i]].

    Time: O(n) where n = len(p)
    Space: O(n)
    """
    return tuple(p[q[i]] for i in range(len(p)))


def inverse_perm(p: tuple) -> tuple:
    """Inverse of a permutation.

    Time: O(n)
    Space: O(n)
    """
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def identity_perm(n: int) -> tuple:
    """Identity permutation of degree n."""
    return tuple(range(n))


def generate_subgroup(generators: List[tuple], n: int) -> FrozenSet[tuple]:
    """Generate the subgroup from generators by saturation.

    Uses BFS to explore all products of generators.

    Time: O(|H|² · n) where |H| is the subgroup size
    Space: O(|H| · n)
    """
    e = identity_perm(n)
    subgroup = {e}
    queue = list(generators)
    while queue:
        g = queue.pop()
        if g not in subgroup:
            subgroup.add(g)
            for h in list(subgroup):
                for new in [compose_perm(g, h), compose_perm(h, g), inverse_perm(g)]:
                    if new not in subgroup:
                        queue.append(new)
    return frozenset(subgroup)


def conjugation_intersection(H: FrozenSet[tuple], g: tuple, n: int) -> FrozenSet[tuple]:
    """Compute H ∩ g⁻¹Hg.

    Time: O(|H| · n)
    Space: O(|H| · n)
    """
    g_inv = inverse_perm(g)
    conj_H = frozenset(compose_perm(compose_perm(g_inv, h), g) for h in H)
    return H & conj_H


def conjugation_index(H: FrozenSet[tuple], g: tuple, n: int) -> int:
    """Compute the conjugation index [H : H ∩ g⁻¹Hg].

    This is the Hecke multiplicity — the number of left H-cosets
    in the double coset HgH.

    Time: O(|H| · n)
    Space: O(|H| · n)

    Returns:
        [H : H ∩ g⁻¹Hg] = |H| / |H ∩ g⁻¹Hg|
    """
    intersection = conjugation_intersection(H, g, n)
    return len(H) // len(intersection)


def max_conjugation_index(H: FrozenSet[tuple], T: List[tuple], n: int) -> int:
    """Compute L = max_{t ∈ T} [H : H ∩ t⁻¹Ht].

    Time: O(|T| · |H| · n)
    Space: O(|H| · n)
    """
    if not T:
        return 1
    return max(conjugation_index(H, t, n) for t in T)


def left_coset(g: tuple, H: FrozenSet[tuple]) -> FrozenSet[tuple]:
    """Compute the left coset gH.

    Time: O(|H| · n)
    Space: O(|H| · n)
    """
    n = len(g)
    return frozenset(compose_perm(g, h) for h in H)


def double_coset(H: FrozenSet[tuple], g: tuple) -> FrozenSet[tuple]:
    """Compute the double coset HgH.

    Time: O(|H|² · n)
    Space: O(|H|² · n) worst case
    """
    n = len(g)
    result = set()
    for h1 in H:
        for h2 in H:
            result.add(compose_perm(compose_perm(h1, g), h2))
    return frozenset(result)


def double_coset_decomposition(H: FrozenSet[tuple], g: tuple, n: int) -> List[FrozenSet[tuple]]:
    """Decompose HgH into disjoint left cosets of H.

    Returns a list of left cosets whose union is HgH.
    The number of cosets equals the conjugation index [H : H ∩ g⁻¹Hg].

    Time: O(|H|² · n)
    Space: O(|HgH| · n)
    """
    dc = double_coset(H, g)
    cosets = []
    remaining = set(dc)
    while remaining:
        rep = next(iter(remaining))
        coset = left_coset(rep, H)
        cosets.append(coset)
        remaining -= coset
    return cosets


def greedy_covering(A: FrozenSet[tuple], H: FrozenSet[tuple],
                    G: List[tuple], n: int) -> Tuple[int, List[tuple]]:
    """Greedy algorithm for minimum covering of A by left cosets of H.

    Uses the standard greedy set cover: at each step, pick the coset
    that covers the most uncovered elements.

    Time: O(|G| · |H| · n · C) where C is the covering number
    Space: O(|G| · |H| · n)

    Returns:
        (covering_number, covering_set)
    """
    if not A:
        return 0, []

    # Precompute all distinct cosets
    coset_map: Dict[tuple, FrozenSet[tuple]] = {}
    seen_cosets: Set[FrozenSet[tuple]] = set()
    for g in G:
        coset = left_coset(g, H)
        if coset not in seen_cosets:
            coset_map[g] = coset
            seen_cosets.add(coset)

    uncovered = set(A)
    cover_set = []
    while uncovered:
        best_g = None
        best_count = 0
        for g, coset in coset_map.items():
            count = len(uncovered & coset)
            if count > best_count:
                best_count = count
                best_g = g
        if best_g is None or best_count == 0:
            break
        cover_set.append(best_g)
        uncovered -= coset_map[best_g]

    return len(cover_set), cover_set


def product_cover_bound(A: FrozenSet[tuple], H: FrozenSet[tuple],
                        G: List[tuple], n: int) -> Dict:
    """Compute the product covering bound C²·L and verify it.

    Returns a dictionary with:
    - C_A: covering number of A
    - C_AA: covering number of A·A
    - L: max conjugation index
    - bound: C² · L
    - verified: whether C(A·A) ≤ C² · L

    Time: O(|G|² · |H| · n)
    Space: O(|G|² · n)
    """
    C_A, T_A = greedy_covering(A, H, G, n)

    if C_A == 0:
        return {"C_A": 0, "C_AA": 0, "L": 1, "bound": 0, "verified": True}

    L = max_conjugation_index(H, T_A, n)

    # Compute product set
    AA = frozenset(compose_perm(a, b) for a in A for b in A)

    C_AA, _ = greedy_covering(AA, H, G, n)

    bound = C_A ** 2 * L
    verified = C_AA <= bound

    return {
        "C_A": C_A,
        "C_AA": C_AA,
        "L": L,
        "bound": bound,
        "verified": verified,
        "A_size": len(A),
        "AA_size": len(AA),
    }


# Example usage
if __name__ == "__main__":
    import random
    random.seed(42)

    n = 4
    G = list(permutations(range(n)))
    e = identity_perm(n)

    # Non-normal subgroup of S_4
    H = generate_subgroup([(1, 0, 2, 3)], n)  # <(01)>
    print(f"S_{n}, H = <(01)>, |H| = {len(H)}")

    # Random test
    A = frozenset(random.sample(G, 8))
    result = product_cover_bound(A, H, G, n)
    print(f"  |A| = {result['A_size']}, |A·A| = {result['AA_size']}")
    print(f"  C(A) = {result['C_A']}, C(A·A) = {result['C_AA']}")
    print(f"  L = {result['L']}, bound = {result['bound']}")
    print(f"  Verified: {result['verified']}")

    # Double coset decomposition example
    g = (1, 2, 3, 0)  # 4-cycle
    print(f"\nDouble coset decomposition of H·{g}·H:")
    cosets = double_coset_decomposition(H, g, n)
    print(f"  Number of left cosets: {len(cosets)}")
    print(f"  Conjugation index: {conjugation_index(H, g, n)}")
    for i, coset in enumerate(cosets):
        rep = next(iter(coset))
        print(f"  Coset {i+1}: representative {rep}, size {len(coset)}")
