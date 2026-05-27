#!/usr/bin/env python3
"""
Algorithms for Support-Compressed Lorentzian Recognition
========================================================

Implements the support-compressed leaf counting algorithm and related
matroid operations. The key insight: instead of differentiating the full
polynomial, enumerate independent (r-2)-sets directly.

Algorithm 1: CountNonzeroQuadraticLeaves
  Input: Basis family F (as list of frozensets), rank r, ground set size n
  Output: Number of nonzero quadratic derivative leaves
  Complexity: O(C(n, r-2) * |F|) worst case, O(C(k, r-2) * |F|) with
              active variable pruning where k = |active vars|

Algorithm 2: ActiveVariablePruning
  Input: Basis family F
  Output: Set of active variables
  Used to restrict enumeration to relevant variables only.

Algorithm 3: EnumerateLeaves
  Input: Basis family F, rank r
  Output: List of all independent (r-2)-sets (the actual leaves)
"""

from itertools import combinations
from typing import Iterator


def active_variables(bases: list[frozenset[int]]) -> frozenset[int]:
    """Compute the set of active variables (appearing in at least one basis).

    Args:
        bases: List of basis sets (each a frozenset of ground set elements).

    Returns:
        Frozenset of all elements appearing in at least one basis.

    Complexity: O(sum of basis sizes)

    Example:
        >>> active_variables([frozenset({0,1,2}), frozenset({1,2,3})])
        frozenset({0, 1, 2, 3})
    """
    result: set[int] = set()
    for B in bases:
        result |= B
    return frozenset(result)


def is_independent(subset: frozenset[int], bases: list[frozenset[int]]) -> bool:
    """Test if a subset is independent (contained in some basis).

    Args:
        subset: The subset to test.
        bases: The basis family.

    Returns:
        True if subset is contained in some basis.

    Complexity: O(|bases| * |subset|)

    Example:
        >>> bases = [frozenset({0,1,2}), frozenset({1,2,3})]
        >>> is_independent(frozenset({0,1}), bases)
        True
        >>> is_independent(frozenset({0,3}), bases)
        False
    """
    return any(subset <= B for B in bases)


def count_nonzero_quadratic_leaves(
    bases: list[frozenset[int]],
    n: int,
    r: int,
    use_active_pruning: bool = True
) -> int:
    """Count the number of nonzero quadratic derivative leaves.

    This is the main algorithm: count independent (r-2)-sets without
    performing any polynomial differentiation.

    Args:
        bases: The basis family (list of r-element frozensets from [n]).
        n: Ground set size.
        r: Rank (size of each basis).
        use_active_pruning: If True, enumerate only over active variables.

    Returns:
        Number of independent (r-2)-sets.

    Complexity:
        Without pruning: O(C(n, r-2) * |bases|)
        With pruning: O(C(k, r-2) * |bases|) where k = |active variables|

    Correctness: This equals the number of nonzero quadratic derivative
    leaves of the basis generating polynomial B_M, by the Exact Support
    Criterion theorem.

    Example:
        >>> # Uniform matroid U_{3,5}: all 3-subsets of {0,...,4}
        >>> from itertools import combinations
        >>> bases = [frozenset(S) for S in combinations(range(5), 3)]
        >>> count_nonzero_quadratic_leaves(bases, 5, 3)
        5
        >>> # This equals C(5, 1) = 5 ✓
    """
    if r < 2:
        return 1

    k = r - 2

    if use_active_pruning:
        active = sorted(active_variables(bases))
        ground = active
    else:
        ground = list(range(n))

    count = 0
    for subset in combinations(ground, k):
        if is_independent(frozenset(subset), bases):
            count += 1
    return count


def enumerate_leaves(
    bases: list[frozenset[int]],
    n: int,
    r: int
) -> list[frozenset[int]]:
    """Enumerate all nonzero quadratic derivative leaves.

    Returns the actual independent (r-2)-sets, not just the count.

    Args:
        bases: The basis family.
        n: Ground set size.
        r: Rank.

    Returns:
        List of independent (r-2)-element frozensets.

    Example:
        >>> from itertools import combinations
        >>> bases = [frozenset(S) for S in combinations(range(4), 3)]
        >>> leaves = enumerate_leaves(bases, 4, 3)
        >>> sorted(sorted(s) for s in leaves)
        [[0], [1], [2], [3]]
    """
    if r < 2:
        return [frozenset()]

    k = r - 2
    active = sorted(active_variables(bases))
    leaves = []
    for subset in combinations(active, k):
        fs = frozenset(subset)
        if is_independent(fs, bases):
            leaves.append(fs)
    return leaves


def compression_ratio(
    bases: list[frozenset[int]],
    n: int,
    r: int
) -> float:
    """Compute the compression ratio: actual / ambient.

    A ratio of 1.0 means no compression (e.g., uniform matroid).
    A ratio near 0.0 means excellent compression.

    Args:
        bases: The basis family.
        n: Ground set size.
        r: Rank.

    Returns:
        Ratio of actual leaf count to ambient worst-case count.

    Example:
        >>> from itertools import combinations
        >>> bases = [frozenset(S) for S in combinations(range(5), 3)]
        >>> compression_ratio(bases, 5, 3)
        1.0
    """
    from math import comb
    if r < 2:
        return 1.0
    ambient = comb(n, r - 2)
    if ambient == 0:
        return 0.0
    actual = count_nonzero_quadratic_leaves(bases, n, r)
    return actual / ambient


def extending_bases(
    subset: frozenset[int],
    bases: list[frozenset[int]]
) -> list[frozenset[int]]:
    """Find all bases containing a given subset.

    This is useful for understanding *why* a particular leaf survives:
    each extending basis contributes a term to the quadratic derivative.

    Args:
        subset: An independent set.
        bases: The basis family.

    Returns:
        List of bases containing the subset.

    Example:
        >>> from itertools import combinations
        >>> bases = [frozenset(S) for S in combinations(range(4), 3)]
        >>> extending_bases(frozenset({0}), bases)
        [frozenset({0, 1, 2}), frozenset({0, 1, 3}), frozenset({0, 2, 3})]
    """
    return [B for B in bases if subset <= B]


if __name__ == "__main__":
    from math import comb

    print("Algorithm Demonstrations")
    print("=" * 50)

    # Uniform matroid U_{4,8}
    bases = [frozenset(S) for S in combinations(range(8), 4)]
    n, r = 8, 4
    actual = count_nonzero_quadratic_leaves(bases, n, r)
    print(f"\nU_{{4,8}}: leaves = {actual}, C(8,2) = {comb(8,2)}")
    assert actual == comb(8, 2), "Uniform matroid theorem failed!"

    # Show some leaves
    leaves = enumerate_leaves(bases, n, r)
    print(f"  First 5 leaves: {[sorted(s) for s in leaves[:5]]}")
    print(f"  Compression ratio: {compression_ratio(bases, n, r):.4f}")

    # Sparse graphic matroid
    edges = [(0,1), (1,2), (2,3), (3,4)]  # Path P5
    n_v = 5
    n_e = len(edges)

    # Build graphic matroid bases (spanning trees)
    graphic_bases = []
    rank = n_v - 1
    for subset in combinations(range(n_e), rank):
        parent = list(range(n_v))
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
        ok = all(union(*edges[i]) for i in subset)
        if ok and len(set(find(v) for v in range(n_v))) == 1:
            graphic_bases.append(frozenset(subset))

    actual = count_nonzero_quadratic_leaves(graphic_bases, n_e, rank)
    ambient = comb(n_e, rank - 2)
    print(f"\nPath P5 graphic matroid:")
    print(f"  Bases: {[sorted(b) for b in graphic_bases]}")
    print(f"  Leaves: {actual}, Ambient: {ambient}")
    print(f"  Compression ratio: {compression_ratio(graphic_bases, n_e, rank):.4f}")
    print(f"  Active variables: {sorted(active_variables(graphic_bases))}")
