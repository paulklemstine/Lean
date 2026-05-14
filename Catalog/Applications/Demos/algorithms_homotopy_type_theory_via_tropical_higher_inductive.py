#!/usr/bin/env python3
"""
Tropical Homotopy Type Theory — Algorithms

Core algorithms for tropical path spaces, equivalence detection,
and tropical univalence checking.

Complexity analysis:
- Zero-distance class computation: O(n²)
- Tropical equivalence (brute force): O(n! · n²)
- Tropical equivalence (invariant pruning): O(n² log n) average, O(n! · n²) worst
- Quotient construction: O(n²)
"""

import itertools
import numpy as np
from typing import List, Tuple, Optional, Dict
from collections import Counter


def validate_tropical_path_space(D: np.ndarray) -> bool:
    """Check if a matrix defines a valid tropical path space.

    A valid tropical path space requires:
    1. Square matrix with non-negative integer entries
    2. Zero diagonal (reflexivity)
    3. Symmetric (d(x,y) = d(y,x))
    4. Triangle inequality (d(x,z) ≤ d(x,y) + d(y,z))

    Time complexity: O(n³)
    Space complexity: O(1) additional
    """
    n = D.shape[0]
    if D.shape != (n, n):
        return False
    if not np.all(D >= 0):
        return False
    if not np.all(np.diag(D) == 0):
        return False
    if not np.allclose(D, D.T):
        return False
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if D[i, k] > D[i, j] + D[j, k]:
                    return False
    return True


def compute_zero_distance_classes(D: np.ndarray) -> List[List[int]]:
    """Compute equivalence classes under zero tropical distance.

    Uses union-find for efficiency.

    Time complexity: O(n² · α(n)) ≈ O(n²)
    Space complexity: O(n)

    Args:
        D: n×n distance matrix

    Returns:
        List of equivalence classes (each a list of point indices)
    """
    n = D.shape[0]
    parent = list(range(n))
    rank = [0] * n

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1

    for i in range(n):
        for j in range(i + 1, n):
            if D[i, j] == 0:
                union(i, j)

    classes: Dict[int, List[int]] = {}
    for i in range(n):
        r = find(i)
        classes.setdefault(r, []).append(i)
    return list(classes.values())


def compute_distance_invariant(D: np.ndarray) -> Tuple:
    """Compute a permutation-invariant signature of a distance matrix.

    The signature consists of:
    1. Sorted multiset of all pairwise distances
    2. Sorted degree sequence of each distance value

    This is a necessary (but not sufficient) condition for tropical equivalence.
    Two matrices with different invariants are guaranteed non-equivalent.

    Time complexity: O(n² log n)
    Space complexity: O(n²)
    """
    n = D.shape[0]
    # Multiset of upper-triangle distances
    distances = sorted(D[i, j] for i in range(n) for j in range(i + 1, n))

    # For each vertex, sorted distance profile
    profiles = []
    for i in range(n):
        profile = sorted(D[i, j] for j in range(n) if j != i)
        profiles.append(tuple(profile))
    profile_counts = tuple(sorted(Counter(profiles).items()))

    return (tuple(distances), profile_counts)


def find_tropical_equivalence_bruteforce(
    D: np.ndarray, E: np.ndarray
) -> Optional[Tuple[int, ...]]:
    """Find a tropical equivalence between two distance matrices by
    exhaustive permutation search.

    Time complexity: O(n! · n²)
    Space complexity: O(n)

    Args:
        D, E: n×n distance matrices

    Returns:
        A permutation σ as tuple such that E[σ(i), σ(j)] = D[i, j],
        or None if no equivalence exists.
    """
    n = D.shape[0]
    if E.shape[0] != n:
        return None

    for perm in itertools.permutations(range(n)):
        if all(E[perm[i], perm[j]] == D[i, j]
               for i in range(n) for j in range(n)):
            return perm
    return None


def find_tropical_equivalence_pruned(
    D: np.ndarray, E: np.ndarray
) -> Optional[Tuple[int, ...]]:
    """Find a tropical equivalence with invariant-based pruning.

    First checks necessary invariant conditions, then searches with
    backtracking constrained by distance profiles.

    Average complexity: O(n² log n) when invariants differ
    Worst case: O(n! · n²) when invariants match but no equivalence exists

    Args:
        D, E: n×n distance matrices

    Returns:
        A permutation σ as tuple, or None.
    """
    n = D.shape[0]
    if E.shape[0] != n:
        return None

    # Quick invariant check
    inv_D = compute_distance_invariant(D)
    inv_E = compute_distance_invariant(E)
    if inv_D != inv_E:
        return None

    # Compute distance profiles for constraint propagation
    d_profiles = [tuple(sorted(D[i, j] for j in range(n) if j != i)) for i in range(n)]
    e_profiles = [tuple(sorted(E[i, j] for j in range(n) if j != i)) for i in range(n)]

    # Group vertices by profile
    d_groups: Dict[tuple, List[int]] = {}
    for i, p in enumerate(d_profiles):
        d_groups.setdefault(p, []).append(i)

    e_groups: Dict[tuple, List[int]] = {}
    for i, p in enumerate(e_profiles):
        e_groups.setdefault(p, []).append(i)

    # Profiles must match
    if sorted(d_groups.keys()) != sorted(e_groups.keys()):
        return None

    # Build candidate mappings respecting profiles
    sigma = [None] * n
    used = set()

    def backtrack(idx: int) -> bool:
        if idx == n:
            return True
        profile = d_profiles[idx]
        for candidate in e_groups.get(profile, []):
            if candidate in used:
                continue
            # Check consistency with already-assigned mappings
            ok = True
            for prev in range(idx):
                if sigma[prev] is not None:
                    if E[candidate, sigma[prev]] != D[idx, prev]:
                        ok = False
                        break
            if ok:
                sigma[idx] = candidate
                used.add(candidate)
                if backtrack(idx + 1):
                    return True
                sigma[idx] = None
                used.discard(candidate)
        return False

    if backtrack(0):
        return tuple(sigma)
    return None


def construct_quotient_space(D: np.ndarray) -> Tuple[np.ndarray, List[List[int]]]:
    """Construct the tropical quotient space by collapsing zero-distance classes.

    Time complexity: O(n²)
    Space complexity: O(n²)

    Args:
        D: n×n distance matrix

    Returns:
        (Q, classes) where Q is the quotient distance matrix and
        classes lists the equivalence classes.
    """
    classes = compute_zero_distance_classes(D)
    q = len(classes)
    Q = np.zeros((q, q), dtype=int)
    for ci in range(q):
        for cj in range(q):
            # Distance between classes is well-defined (constant within class)
            Q[ci, cj] = D[classes[ci][0], classes[cj][0]]
    return Q, classes


def compute_automorphism_group(D: np.ndarray) -> List[Tuple[int, ...]]:
    """Compute all distance-preserving permutations (automorphisms).

    Time complexity: O(n! · n²) worst case
    Space complexity: O(n · |Aut|)
    """
    n = D.shape[0]
    auts = []
    for perm in itertools.permutations(range(n)):
        if all(D[perm[i], perm[j]] == D[i, j]
               for i in range(n) for j in range(n)):
            auts.append(perm)
    return auts


def tropical_univalence_decide(D: np.ndarray, E: np.ndarray) -> Tuple[bool, str]:
    """Decide tropical univalence: are two distance matrices tropically equivalent?

    This is the algorithmic implementation of the tropical univalence theorem.
    Returns (decision, explanation).

    Time complexity: O(n² log n) average, O(n! · n²) worst case
    """
    n = D.shape[0]
    if E.shape[0] != n:
        return False, f"Different dimensions: {n} vs {E.shape[0]}"

    # Stage 1: invariant check
    inv_D = compute_distance_invariant(D)
    inv_E = compute_distance_invariant(E)
    if inv_D != inv_E:
        return False, "Distance invariants differ — no equivalence possible"

    # Stage 2: search with pruning
    sigma = find_tropical_equivalence_pruned(D, E)
    if sigma is not None:
        return True, f"Equivalent via permutation σ = {sigma}"
    else:
        return False, "Invariants match but no permutation witness found"


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Homotopy Type Theory — Algorithm Demonstrations")
    print("=" * 60)

    # Example 1: Validation
    D_valid = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]])
    D_invalid = np.array([[0, 1, 5], [1, 0, 1], [5, 1, 0]])  # violates triangle ineq? No, 5 ≤ 1+1=2? Yes violates.
    # Actually 5 > 1 + 1 = 2 violates triangle inequality
    print(f"Valid space: {validate_tropical_path_space(D_valid)}")
    print(f"Invalid space (triangle violation): {validate_tropical_path_space(D_invalid)}")

    # Example 2: Zero-distance classes
    D_collapse = np.array([
        [0, 0, 3, 3],
        [0, 0, 3, 3],
        [3, 3, 0, 0],
        [3, 3, 0, 0],
    ])
    classes = compute_zero_distance_classes(D_collapse)
    print(f"\nZero-distance classes of collapsed space: {classes}")

    # Example 3: Equivalence detection
    D1 = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]])
    D2 = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]])
    D3 = np.array([[0, 1, 1], [1, 0, 1], [1, 1, 0]])

    equiv, msg = tropical_univalence_decide(D1, D2)
    print(f"\nD1 ~ D2: {equiv} ({msg})")

    equiv, msg = tropical_univalence_decide(D1, D3)
    print(f"D1 ~ D3: {equiv} ({msg})")

    # Example 4: Automorphism group
    auts = compute_automorphism_group(D3)
    print(f"\nAutomorphisms of equilateral triangle: {len(auts)} elements")
    for a in auts:
        print(f"  {a}")

    # Example 5: Quotient construction
    Q, cls = construct_quotient_space(D_collapse)
    print(f"\nQuotient of collapsed space:")
    print(f"  Classes: {cls}")
    print(f"  Quotient matrix:\n{Q}")
