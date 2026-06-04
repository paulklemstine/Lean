#!/usr/bin/env python3
"""
Algorithms for Matroid Minor Theory and WQO

Type-hinted implementations of the core algorithms from the research.
"""

from typing import (Callable, Dict, FrozenSet, Generic, List, Optional,
                     Protocol, Set, Tuple, TypeVar)
from dataclasses import dataclass
from itertools import combinations

T = TypeVar('T')


@dataclass(frozen=True)
class RankMatroid:
    """A finite matroid represented by its ground set and rank function."""
    ground_set: FrozenSet[int]
    _rank_values: Dict[FrozenSet[int], int]

    def rank(self, A: FrozenSet[int]) -> int:
        """Return the rank of subset A."""
        return self._rank_values.get(A, 0)

    @property
    def full_rank(self) -> int:
        return self.rank(self.ground_set)

    @property
    def size(self) -> int:
        return len(self.ground_set)


def matroid_delete(M: RankMatroid, e: int) -> RankMatroid:
    """
    Deletion: M \\ e
    Remove element e from the ground set; rank function restricted to E \\ {e}.

    Time complexity: O(2^|E|)
    """
    new_E = M.ground_set - {e}
    new_rank: Dict[FrozenSet[int], int] = {}
    for size in range(len(new_E) + 1):
        for subset in combinations(sorted(new_E), size):
            fs = frozenset(subset)
            new_rank[fs] = M.rank(fs)
    return RankMatroid(new_E, new_rank)


def matroid_contract(M: RankMatroid, e: int) -> RankMatroid:
    """
    Contraction: M / e
    Contract element e; rank_{M/e}(A) = rank_M(A ∪ {e}) - rank_M({e}).

    Time complexity: O(2^|E|)
    """
    new_E = M.ground_set - {e}
    re = M.rank(frozenset({e}))
    new_rank: Dict[FrozenSet[int], int] = {}
    for size in range(len(new_E) + 1):
        for subset in combinations(sorted(new_E), size):
            fs = frozenset(subset)
            new_rank[fs] = M.rank(fs | {e}) - re
    return RankMatroid(new_E, new_rank)


def uniform_matroid(r: int, n: int) -> RankMatroid:
    """
    Construct the uniform matroid U_{r,n}.
    rank(A) = min(|A|, r) for all A.
    """
    ground_set = frozenset(range(n))
    rank_values: Dict[FrozenSet[int], int] = {}
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            fs = frozenset(subset)
            rank_values[fs] = min(len(fs), r)
    return RankMatroid(ground_set, rank_values)


def is_minor(M1: RankMatroid, M2: RankMatroid) -> bool:
    """
    Check if M1 is a minor of M2 (brute force).
    Tries all sequences of deletions and contractions.

    Time complexity: O(|E2|! · 2^|E2|) — exponential, for small instances only.
    """
    if M1.size > M2.size:
        return False
    if M1.size == M2.size:
        return _are_isomorphic(M1, M2)
    for e in M2.ground_set:
        if is_minor(M1, matroid_delete(M2, e)):
            return True
        if is_minor(M1, matroid_contract(M2, e)):
            return True
    return False


def _are_isomorphic(M1: RankMatroid, M2: RankMatroid) -> bool:
    """Check if two matroids are isomorphic (brute force permutation check)."""
    if M1.size != M2.size:
        return False
    from itertools import permutations
    elts1 = sorted(M1.ground_set)
    elts2 = sorted(M2.ground_set)
    for perm in permutations(elts2):
        mapping = dict(zip(elts1, perm))
        if all(M2.rank(frozenset(mapping[x] for x in fs)) == M1.rank(fs)
               for fs in M1._rank_values):
            return True
    return False


def find_excluded_minors(
    matroids: List[RankMatroid],
    property_fn: Callable[[RankMatroid], bool]
) -> List[RankMatroid]:
    """
    Find excluded minors for a minor-closed property among a list of matroids.

    An excluded minor is a matroid M such that:
    - property_fn(M) is False
    - For all proper minors M' of M, property_fn(M') is True

    Algorithm:
    1. Filter to matroids failing the property
    2. For each, check if all single-element deletions/contractions satisfy the property
    3. Return those that pass the check

    Time complexity: O(n · |E| · T_property) where T_property is the cost of property_fn
    """
    excluded: List[RankMatroid] = []
    for M in matroids:
        if property_fn(M):
            continue
        # Check if all proper minors satisfy the property
        is_excluded = True
        for e in M.ground_set:
            if not property_fn(matroid_delete(M, e)):
                is_excluded = False
                break
            if not property_fn(matroid_contract(M, e)):
                is_excluded = False
                break
        if is_excluded:
            excluded.append(M)
    return excluded


def obstruction_spectrum(
    excluded_minors: List[RankMatroid]
) -> Dict[int, int]:
    """
    Compute the obstruction spectrum: σ(k) = number of excluded minors of size k.

    Under WQO, this function has finite support.
    """
    spectrum: Dict[int, int] = {}
    for M in excluded_minors:
        k = M.size
        spectrum[k] = spectrum.get(k, 0) + 1
    return dict(sorted(spectrum.items()))


def verify_wqo_sequence(
    sequence: List[RankMatroid],
    le_fn: Callable[[RankMatroid, RankMatroid], bool]
) -> Optional[Tuple[int, int]]:
    """
    Verify the WQO property for a finite sequence: find i < j with seq[i] ≤ seq[j].

    Returns the pair (i, j) if found, None otherwise.
    For a true WQO, any sufficiently long sequence will have such a pair.
    """
    for i in range(len(sequence)):
        for j in range(i + 1, len(sequence)):
            if le_fn(sequence[i], sequence[j]):
                return (i, j)
    return None


def dickson_product_check(
    seq: List[Tuple[int, int]]
) -> Optional[Tuple[int, int]]:
    """
    Verify Dickson's lemma for a sequence of pairs: find i < j with
    seq[i][0] ≤ seq[j][0] and seq[i][1] ≤ seq[j][1].

    Dickson's lemma guarantees this exists for any infinite sequence.
    """
    for i in range(len(seq)):
        for j in range(i + 1, len(seq)):
            if seq[i][0] <= seq[j][0] and seq[i][1] <= seq[j][1]:
                return (i, j)
    return None


def gf_matrix_rank(matrix: List[List[int]], p: int) -> int:
    """
    Compute the rank of a matrix over GF(p) using Gaussian elimination.

    Pseudocode:
    1. For each column, find a nonzero pivot in the remaining rows.
    2. Swap the pivot row into position and scale to make the pivot 1.
    3. Eliminate all other entries in the column.
    4. The rank is the number of pivots found.
    """
    if not matrix or not matrix[0]:
        return 0
    m, n = len(matrix), len(matrix[0])
    mat = [row[:] for row in matrix]
    rank = 0
    for col in range(n):
        pivot = next((r for r in range(rank, m) if mat[r][col] % p != 0), None)
        if pivot is None:
            continue
        mat[rank], mat[pivot] = mat[pivot], mat[rank]
        inv = pow(mat[rank][col], p - 2, p)
        mat[rank] = [(x * inv) % p for x in mat[rank]]
        for row in range(m):
            if row != rank and mat[row][col] % p != 0:
                factor = mat[row][col]
                mat[row] = [(mat[row][j] - factor * mat[rank][j]) % p for j in range(n)]
        rank += 1
    return rank


if __name__ == "__main__":
    # Quick test
    u23 = uniform_matroid(2, 3)
    u24 = uniform_matroid(2, 4)
    print(f"U_{{2,3}} is a minor of U_{{2,4}}: {is_minor(u23, u24)}")
    print(f"U_{{2,4}} is a minor of U_{{2,3}}: {is_minor(u24, u23)}")

    spec = obstruction_spectrum([u24])
    print(f"Obstruction spectrum: {spec}")
