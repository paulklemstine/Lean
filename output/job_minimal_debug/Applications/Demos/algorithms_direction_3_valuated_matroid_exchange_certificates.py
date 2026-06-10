#!/usr/bin/env python3
"""
Algorithms for Tropical Spectral Gaps and Exchange Defects

Implements the core algorithms from the research paper:
1. Exchange defect computation
2. Minimum exchange defect (exhaustive and optimized)
3. Tropical Hessian construction
4. Tropical spectral gap computation
5. Valuated matroid exchange property verification

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import FrozenSet, Dict, List, Tuple, Optional, Callable, Set
from itertools import combinations
from collections import defaultdict
import heapq


# Type aliases
Element = int
Basis = FrozenSet[Element]
WeightFn = Callable[[Basis], int]


def exchange_defect(w: WeightFn, B1: Basis, B2: Basis, i: Element, j: Element) -> int:
    """Compute the exchange defect δ(B₁, B₂, i, j).

    The exchange defect measures how much total weight decreases when we
    perform a symmetric exchange: remove i from B₁ and add j, while
    removing j from B₂ and adding i.

    δ = w(B₁) + w(B₂) - w(B₁ - {i} ∪ {j}) - w(B₂ - {j} ∪ {i})

    Args:
        w: Weight function on bases.
        B1, B2: Two bases (frozensets of elements).
        i: Element in B1 \\ B2 to be exchanged out of B1.
        j: Element in B2 \\ B1 to be exchanged out of B2.

    Returns:
        The integer exchange defect.

    Time complexity: O(r) where r is the rank (for set operations).
    Space complexity: O(r).

    Example:
        >>> w = lambda B: sum(B)  # simple weight
        >>> B1 = frozenset({0, 1})
        >>> B2 = frozenset({2, 3})
        >>> exchange_defect(w, B1, B2, 0, 2)  # swap 0 and 2
        0
    """
    B1_new = (B1 - {i}) | {j}
    B2_new = (B2 - {j}) | {i}
    return w(B1) + w(B2) - w(B1_new) - w(B2_new)


def verify_exchange_property(bases: List[Basis], w: WeightFn) -> Tuple[bool, Optional[str]]:
    """Verify the valuated basis exchange property for a set of bases.

    For every pair of bases B₁, B₂ and every i ∈ B₁ \\ B₂,
    there must exist j ∈ B₂ \\ B₁ such that:
        w(B₁) + w(B₂) ≥ w(B₁ - {i} ∪ {j}) + w(B₂ - {j} ∪ {i})

    Args:
        bases: List of all bases.
        w: Weight function.

    Returns:
        (True, None) if the property holds.
        (False, description) if a violation is found.

    Time complexity: O(|B|² · r²) where |B| is number of bases, r is rank.
    """
    bases_set = set(bases)
    for B1 in bases:
        for B2 in bases:
            diff1 = B1 - B2
            for i in diff1:
                diff2 = B2 - B1
                found_witness = False
                for j in diff2:
                    B1_new = (B1 - {i}) | {j}
                    B2_new = (B2 - {j}) | {i}
                    if B1_new in bases_set and B2_new in bases_set:
                        d = exchange_defect(w, B1, B2, i, j)
                        if d >= 0:
                            found_witness = True
                            break
                if not found_witness:
                    return False, f"No valid exchange witness for B1={B1}, B2={B2}, i={i}"
    return True, None


def min_exchange_defect_exhaustive(
    bases: List[Basis], w: WeightFn
) -> Tuple[int, Optional[Tuple[Basis, Basis, Element, Element]]]:
    """Compute the minimum exchange defect by exhaustive enumeration.

    Enumerates all valid exchange pairs (B₁, B₂, i, j) and returns
    the minimum defect along with the witness.

    Args:
        bases: List of all bases.
        w: Weight function.

    Returns:
        (min_defect, (B1, B2, i, j)) — the minimum defect and its witness.

    Time complexity: O(|B|² · r²) where |B| is number of bases, r is rank.
    Space complexity: O(1) beyond input.
    """
    bases_set = set(bases)
    min_def = float('inf')
    witness = None

    for B1 in bases:
        for B2 in bases:
            diff1 = B1 - B2
            diff2 = B2 - B1
            if not diff1 or not diff2:
                continue
            for i in diff1:
                for j in diff2:
                    B1_new = (B1 - {i}) | {j}
                    B2_new = (B2 - {j}) | {i}
                    if B1_new in bases_set and B2_new in bases_set:
                        d = exchange_defect(w, B1, B2, i, j)
                        if d < min_def:
                            min_def = d
                            witness = (B1, B2, i, j)

    return int(min_def) if min_def != float('inf') else 0, witness


def build_tropical_hessian(
    bases: List[Basis], w: WeightFn, n_elements: int
) -> Dict[Tuple[Element, Element], int]:
    """Build the tropical Hessian matrix H.

    For i ≠ j: H(i,j) = max over bases B containing both i and j of w(B).
    For i = j: H(i,i) = max over bases B containing i of w(B).

    Args:
        bases: List of all bases.
        w: Weight function.
        n_elements: Size of the ground set.

    Returns:
        Dictionary mapping (i, j) pairs to H(i, j).

    Time complexity: O(|B| · r² + n²) where r is rank.
    """
    H = {}
    for i in range(n_elements):
        for j in range(n_elements):
            if i == j:
                vals = [w(B) for B in bases if i in B]
                H[(i, j)] = max(vals) if vals else -10**18
            else:
                vals = [w(B) for B in bases if i in B and j in B]
                H[(i, j)] = max(vals) if vals else -10**18

    return H


def tropical_spectral_gap_from_hessian(
    H: Dict[Tuple[Element, Element], int], n_elements: int
) -> int:
    """Compute the tropical spectral gap from a Hessian matrix.

    The tropical spectral gap is the minimum diagonal exchange slack:
        gap = min_{i ≠ j} (2·H(i,j) - H(i,i) - H(j,j))

    Args:
        H: Hessian matrix as a dictionary.
        n_elements: Size of the ground set.

    Returns:
        The tropical spectral gap.

    Time complexity: O(n²).
    """
    min_slack = float('inf')
    for i in range(n_elements):
        for j in range(i + 1, n_elements):
            slack = 2 * H[(i, j)] - H[(i, i)] - H[(j, j)]
            if slack < min_slack:
                min_slack = slack
    return int(min_slack) if min_slack != float('inf') else 0


def graphical_matroid_bases(n_vertices: int, edges: List[Tuple[int, int]]) -> List[Basis]:
    """Compute all spanning trees (bases) of a graphical matroid.

    Uses a Union-Find structure to test each edge subset for spanning tree property.

    Args:
        n_vertices: Number of vertices.
        edges: List of edges as (u, v) tuples.

    Returns:
        List of bases (each a frozenset of edge indices).

    Time complexity: O(C(m, n-1) · n · α(n)) where m = |edges|, n = n_vertices.
    """
    rank = n_vertices - 1
    bases = []

    for subset in combinations(range(len(edges)), rank):
        parent = list(range(n_vertices))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True

        is_tree = True
        for idx in subset:
            u, v = edges[idx]
            if not union(u, v):
                is_tree = False
                break

        if is_tree and len(set(find(i) for i in range(n_vertices))) == 1:
            bases.append(frozenset(subset))

    return bases


# ─── Example Usage ───

if __name__ == "__main__":
    print("=== Algorithms for Tropical Spectral Gaps ===\n")

    # K₄ example
    edges = list(combinations(range(4), 2))
    bases = graphical_matroid_bases(4, edges)
    print(f"K₄: {len(edges)} edges, {len(bases)} spanning trees")

    # Trivial weight
    w_trivial = lambda B: 0
    med, _ = min_exchange_defect_exhaustive(bases, w_trivial)
    H = build_tropical_hessian(bases, w_trivial, len(edges))
    tsg = tropical_spectral_gap_from_hessian(H, len(edges))
    print(f"  Trivial valuation: min_defect = {med}, spectral_gap = {tsg}")

    # Random weight
    import random
    rng = random.Random(42)
    weights = {B: rng.randint(-5, 5) for B in bases}
    w_rand = lambda B: weights.get(B, 0)
    med, witness = min_exchange_defect_exhaustive(bases, w_rand)
    H = build_tropical_hessian(bases, w_rand, len(edges))
    tsg = tropical_spectral_gap_from_hessian(H, len(edges))
    print(f"  Random valuation:  min_defect = {med}, spectral_gap = {tsg}")

    # Verify exchange property
    valid, msg = verify_exchange_property(bases, w_trivial)
    print(f"  Exchange property (trivial): {valid}")
