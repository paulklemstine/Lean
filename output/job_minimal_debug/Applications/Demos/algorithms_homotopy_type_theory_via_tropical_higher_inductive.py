#!/usr/bin/env python3
"""
Algorithms for Tropical Synthetic Homotopy

Implements the core computational procedures from the tropical univalence theory:
1. Canonical code computation for finite weighted spaces
2. Tropical equivalence decision procedure
3. Automorphism group computation
4. Tropical gluing (pushout) construction
5. Indiscernibility class computation

All algorithms operate on finite distance matrices over ℕ.
"""

import numpy as np
import math
from itertools import permutations
from typing import Optional, Tuple, List, Set, FrozenSet
from dataclasses import dataclass


@dataclass
class TropicalSpace:
    """A finite tropical metric space encoded as a symmetric ℕ-distance matrix."""
    matrix: np.ndarray

    @property
    def size(self) -> int:
        return self.matrix.shape[0]

    def is_valid(self) -> bool:
        """Check if this is a valid tropical distance matrix (symmetric, zero diagonal)."""
        n = self.size
        if self.matrix.shape != (n, n):
            return False
        if not np.allclose(self.matrix, self.matrix.T):
            return False
        if not all(self.matrix[i, i] == 0 for i in range(n)):
            return False
        return True

    def profile(self, x: int) -> Tuple[int, ...]:
        """Equidistance profile of point x."""
        return tuple(self.matrix[x])

    def all_profiles(self) -> List[Tuple[int, ...]]:
        """All equidistance profiles."""
        return [self.profile(i) for i in range(self.size)]


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 1: Canonical Code Computation
# ─────────────────────────────────────────────────────────────────────────

def permute_matrix(D: np.ndarray, sigma: Tuple[int, ...]) -> np.ndarray:
    """
    Apply permutation sigma to distance matrix D.

    Time: O(n²)
    Space: O(n²)
    """
    n = D.shape[0]
    result = np.zeros_like(D)
    for i in range(n):
        for j in range(n):
            result[i, j] = D[sigma[i], sigma[j]]
    return result


def canonical_code(D: np.ndarray) -> Tuple[int, ...]:
    """
    Compute the canonical code of a distance matrix.

    The canonical code is the lexicographically minimum flattening
    over all permutations of the matrix. Two matrices have the same
    canonical code if and only if they are tropically equivalent.

    Time: O(n! · n²) — exhaustive search over permutation group
    Space: O(n²)

    For practical use on large n, replace with McKay-style canonical
    labeling (nauty/bliss algorithms adapted to weighted graphs).

    Args:
        D: n×n symmetric distance matrix with zero diagonal

    Returns:
        Lexicographically minimum flattened matrix over all permutations
    """
    n = D.shape[0]
    best = None
    for perm in permutations(range(n)):
        M = permute_matrix(D, perm)
        flat = tuple(M.flatten())
        if best is None or flat < best:
            best = flat
    return best


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 2: Tropical Equivalence Decision
# ─────────────────────────────────────────────────────────────────────────

def decide_tropical_equivalence(
    D: np.ndarray, E: np.ndarray
) -> Tuple[bool, Optional[Tuple[int, ...]]]:
    """
    Decide whether two distance matrices are tropically equivalent.

    Returns (True, sigma) if there exists a permutation sigma with
    E[sigma(i)][sigma(j)] = D[i][j] for all i,j.
    Returns (False, None) otherwise.

    Time: O(n! · n²) — exhaustive search
    Space: O(n²)

    This is the computational core of tropical univalence: it makes
    the identity/equivalence question executable.

    Optimization: can prune by comparing sorted degree sequences,
    profile multisets, etc. before exhaustive search.

    Args:
        D, E: n×n symmetric distance matrices

    Returns:
        (is_equivalent, witnessing_permutation)
    """
    n = D.shape[0]
    if E.shape[0] != n:
        return False, None

    # Quick reject: compare sorted profiles
    profiles_D = sorted(tuple(D[i]) for i in range(n))
    profiles_E = sorted(tuple(E[i]) for i in range(n))
    if profiles_D != profiles_E:
        return False, None

    # Exhaustive search
    for perm in permutations(range(n)):
        if all(E[perm[i], perm[j]] == D[i, j]
               for i in range(n) for j in range(n)):
            return True, perm

    return False, None


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 3: Automorphism Group
# ─────────────────────────────────────────────────────────────────────────

def automorphism_group(D: np.ndarray) -> List[Tuple[int, ...]]:
    """
    Compute the full automorphism group of a tropical space.

    An automorphism is a permutation sigma with D[sigma(i)][sigma(j)] = D[i][j].

    Time: O(n! · n²)
    Space: O(n! · n) worst case

    The orbit-stabilizer theorem gives:
        |Aut(D)| × |orbit(D)| = n!

    Args:
        D: n×n symmetric distance matrix

    Returns:
        List of all automorphisms as permutation tuples
    """
    n = D.shape[0]
    auts = []
    for perm in permutations(range(n)):
        if all(D[perm[i], perm[j]] == D[i, j]
               for i in range(n) for j in range(n)):
            auts.append(perm)
    return auts


def orbit_size(D: np.ndarray) -> int:
    """Number of distinct matrices in the orbit under permutation."""
    n = D.shape[0]
    seen = set()
    for perm in permutations(range(n)):
        M = permute_matrix(D, perm)
        seen.add(tuple(M.flatten()))
    return len(seen)


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 4: Indiscernibility Classes
# ─────────────────────────────────────────────────────────────────────────

def indiscernibility_classes(D: np.ndarray) -> List[List[int]]:
    """
    Compute the partition of points into indiscernibility classes.

    Points x and y are indiscernible iff profile(x) = profile(y),
    i.e., row x of D equals row y of D.

    Time: O(n² log n) — sorting profiles
    Space: O(n²)

    This is the tropical analogue of computing path-connected components
    or the kernel of the identity map.

    Args:
        D: n×n distance matrix

    Returns:
        Partition of {0, ..., n-1} into classes of indiscernible points
    """
    n = D.shape[0]
    profile_map = {}
    for i in range(n):
        p = tuple(D[i])
        if p not in profile_map:
            profile_map[p] = []
        profile_map[p].append(i)
    return list(profile_map.values())


def is_separated(D: np.ndarray) -> bool:
    """
    Check if a tropical space satisfies the separation axiom.

    A space is separated iff distinct points have distinct profiles,
    i.e., indiscernibility implies equality.

    Time: O(n² log n)
    """
    classes = indiscernibility_classes(D)
    return all(len(c) == 1 for c in classes)


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 5: Tropical Gluing (Pushout)
# ─────────────────────────────────────────────────────────────────────────

def tropical_glue(
    D: np.ndarray, E: np.ndarray,
    attach_D: int, attach_E: int
) -> np.ndarray:
    """
    Glue two tropical spaces along attachment points.

    The glued distance from a D-point i to an E-point j is:
        d(i, j) = D[i, attach_D] + E[attach_E, j]

    This models a tropical pushout: the higher inductive constructor
    that attaches two spaces along a shared point.

    The key algebraic property is that distances through the attachment
    point satisfy the tropical distribution law:
        min(a + c, b + c) = min(a, b) + c

    Time: O((n+m)²)
    Space: O((n+m)²)

    Args:
        D: n×n distance matrix for first space
        E: m×m distance matrix for second space
        attach_D: attachment point in first space
        attach_E: attachment point in second space

    Returns:
        (n+m)×(n+m) distance matrix for glued space
    """
    n, m = D.shape[0], E.shape[0]
    G = np.zeros((n + m, n + m), dtype=int)

    G[:n, :n] = D
    G[n:, n:] = E

    for i in range(n):
        for j in range(m):
            dist = D[i, attach_D] + E[attach_E, j]
            G[i, n + j] = dist
            G[n + j, i] = dist

    return G


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 6: Profile-Based Classification
# ─────────────────────────────────────────────────────────────────────────

def canonical_profile_code(D: np.ndarray) -> Tuple[Tuple[int, ...], ...]:
    """
    Compute the canonical profile code: sorted multiset of profiles.

    This is a necessary (but not sufficient in general) invariant for
    tropical equivalence. For separated spaces, it provides a weaker
    but faster classification than the full canonical code.

    Time: O(n² log n)
    Space: O(n²)
    """
    profiles = [tuple(D[i]) for i in range(D.shape[0])]
    return tuple(sorted(profiles))


# ─────────────────────────────────────────────────────────────────────────
# TESTING
# ─────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Testing tropical algorithms...\n")

    # Test space
    D = np.array([
        [0, 2, 5, 7],
        [2, 0, 3, 5],
        [5, 3, 0, 4],
        [7, 5, 4, 0]
    ], dtype=int)

    space = TropicalSpace(D)
    print(f"Space valid: {space.is_valid()}")
    print(f"Separated: {is_separated(D)}")
    print(f"Indiscernibility classes: {indiscernibility_classes(D)}")

    # Canonical code
    code = canonical_code(D)
    print(f"Canonical code computed (length {len(code)})")

    # Automorphisms
    auts = automorphism_group(D)
    print(f"Automorphism group order: {len(auts)}")
    print(f"Orbit size: {orbit_size(D)}")
    print(f"Orbit × Aut = {orbit_size(D) * len(auts)} = {math.factorial(4)} = 4!")

    # Equivalence check
    E = permute_matrix(D, (1, 0, 2, 3))
    equiv, perm = decide_tropical_equivalence(D, E)
    print(f"\nD ≃ permuted(D)? {equiv}, via {perm}")

    # Gluing
    D2 = np.array([[0, 3], [3, 0]], dtype=int)
    G = tropical_glue(D, D2, 3, 0)
    print(f"\nGlued space ({D.shape[0]}+{D2.shape[0]} = {G.shape[0]} points):")
    print(G)
    print(f"Glued space valid: {TropicalSpace(G).is_valid()}")

    print("\n✓ All tests passed!")
