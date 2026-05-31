"""
Matroid Minor Algorithms

Type-hinted implementations of key algorithms for matroid minor theory,
including matroid construction, minor operations, and representability testing.
"""

from __future__ import annotations
from typing import FrozenSet, Set, List, Tuple, Optional, Dict
from itertools import combinations
import numpy as np


class Matroid:
    """A matroid defined by its ground set and collection of independent sets."""

    def __init__(self, ground_set: FrozenSet[int], independent_sets: Set[FrozenSet[int]]):
        self.ground_set = ground_set
        self.independent_sets = independent_sets
        self._validate()

    def _validate(self) -> None:
        """Verify matroid axioms: (I1) empty set, (I2) hereditary, (I3) augmentation."""
        assert frozenset() in self.independent_sets, "Empty set must be independent"
        for I in self.independent_sets:
            assert I <= self.ground_set, f"{I} not subset of ground set"
            for e in I:
                assert I - {e} in self.independent_sets, f"Hereditary property violated for {I}"

    def rank(self, S: FrozenSet[int]) -> int:
        """Compute the rank of a subset S."""
        return max(
            (len(I) for I in self.independent_sets if I <= S),
            default=0
        )

    def matroid_rank(self) -> int:
        """The rank of the matroid (rank of the ground set)."""
        return self.rank(self.ground_set)

    def bases(self) -> Set[FrozenSet[int]]:
        """Return all bases (maximal independent sets)."""
        r = self.matroid_rank()
        return {I for I in self.independent_sets if len(I) == r}

    def circuits(self) -> Set[FrozenSet[int]]:
        """Return all circuits (minimal dependent sets)."""
        result: Set[FrozenSet[int]] = set()
        for size in range(1, len(self.ground_set) + 1):
            for S in combinations(self.ground_set, size):
                S_frozen = frozenset(S)
                if S_frozen not in self.independent_sets:
                    # Check minimality
                    if all(S_frozen - {e} in self.independent_sets for e in S_frozen):
                        result.add(S_frozen)
        return result

    def delete(self, D: FrozenSet[int]) -> 'Matroid':
        """Delete elements D from the matroid."""
        new_ground = self.ground_set - D
        new_indep = {I for I in self.independent_sets if I <= new_ground}
        return Matroid(new_ground, new_indep)

    def contract(self, C: FrozenSet[int]) -> 'Matroid':
        """Contract elements C from the matroid."""
        # Find a maximal independent subset of C
        max_indep_in_C = frozenset()
        for I in self.independent_sets:
            if I <= C and len(I) > len(max_indep_in_C):
                max_indep_in_C = I

        new_ground = self.ground_set - C
        new_indep: Set[FrozenSet[int]] = set()
        for S_size in range(len(new_ground) + 1):
            for S in combinations(new_ground, S_size):
                S_frozen = frozenset(S)
                if S_frozen | max_indep_in_C in self.independent_sets:
                    new_indep.add(S_frozen)
        return Matroid(new_ground, new_indep)

    def is_minor_of(self, other: 'Matroid') -> bool:
        """Check if self is a minor of other (brute force for small matroids)."""
        n = len(other.ground_set)
        elems = sorted(other.ground_set)
        for c_size in range(n + 1):
            for C in combinations(elems, c_size):
                C_set = frozenset(C)
                remaining = other.ground_set - C_set
                for d_size in range(len(remaining) + 1):
                    for D in combinations(sorted(remaining), d_size):
                        D_set = frozenset(D)
                        minor = other.contract(C_set).delete(D_set)
                        if self._is_isomorphic_to(minor):
                            return True
        return False

    def _is_isomorphic_to(self, other: 'Matroid') -> bool:
        """Check if two matroids are isomorphic (same up to relabeling)."""
        if len(self.ground_set) != len(other.ground_set):
            return False
        if len(self.independent_sets) != len(other.independent_sets):
            return False
        # Simple check: compare rank sequences
        self_ranks = sorted(self.rank(frozenset(S))
                           for k in range(len(self.ground_set) + 1)
                           for S in combinations(sorted(self.ground_set), k))
        other_ranks = sorted(other.rank(frozenset(S))
                            for k in range(len(other.ground_set) + 1)
                            for S in combinations(sorted(other.ground_set), k))
        return self_ranks == other_ranks


def uniform_matroid(n: int, r: int) -> Matroid:
    """Construct the uniform matroid U_{r,n}: all subsets of size <= r are independent."""
    ground = frozenset(range(n))
    indep: Set[FrozenSet[int]] = set()
    for k in range(r + 1):
        for S in combinations(range(n), k):
            indep.add(frozenset(S))
    return Matroid(ground, indep)


def is_representable_over_gf(M: Matroid, q: int) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Test if matroid M is representable over GF(q) by brute-force search.
    Returns (is_representable, witness_matrix_or_None).

    Only works for small matroids and small fields (q prime).
    """
    n = len(M.ground_set)
    r = M.matroid_rank()
    elems = sorted(M.ground_set)

    if r == 0:
        return True, np.zeros((0, n), dtype=int)

    # Try all r×n matrices over GF(q)
    def matrix_gen(rows: int, cols: int, field_size: int):
        """Generate all rows×cols matrices over GF(field_size)."""
        total = rows * cols
        for val in range(field_size ** total):
            entries = []
            v = val
            for _ in range(total):
                entries.append(v % field_size)
                v //= field_size
            yield np.array(entries, dtype=int).reshape(rows, cols)

    def gf_rank(matrix: np.ndarray, cols: List[int], q: int) -> int:
        """Compute rank of submatrix over GF(q) using Gaussian elimination."""
        if len(cols) == 0:
            return 0
        sub = matrix[:, cols].copy() % q
        rows, c = sub.shape
        rank = 0
        for col in range(c):
            pivot = None
            for row in range(rank, rows):
                if sub[row, col] % q != 0:
                    pivot = row
                    break
            if pivot is None:
                continue
            sub[[rank, pivot]] = sub[[pivot, rank]]
            inv = pow(int(sub[rank, col]), q - 2, q)
            sub[rank] = (sub[rank] * inv) % q
            for row in range(rows):
                if row != rank and sub[row, col] % q != 0:
                    sub[row] = (sub[row] - sub[row, col] * sub[rank]) % q
            rank += 1
        return rank

    # For small cases, try all matrices
    if r * n <= 12:  # Only feasible for very small cases
        for A in matrix_gen(r, n, q):
            # Check: I is independent iff columns indexed by I are linearly independent over GF(q)
            valid = True
            for I in M.independent_sets:
                cols = [elems.index(e) for e in sorted(I)]
                if gf_rank(A, cols, q) != len(I):
                    valid = False
                    break
            if not valid:
                continue
            # Also check dependent sets have rank < size
            all_good = True
            for k in range(1, n + 1):
                for S in combinations(range(n), k):
                    S_set = frozenset(elems[i] for i in S)
                    is_indep = S_set in M.independent_sets
                    rk = gf_rank(A, list(S), q)
                    if is_indep and rk != len(S):
                        all_good = False
                        break
                    if not is_indep and rk == len(S):
                        all_good = False
                        break
                if not all_good:
                    break
            if all_good:
                return True, A
        return False, None
    return None, None  # Too large for brute force


def fano_matroid() -> Matroid:
    """Construct the Fano matroid F_7 (the projective plane of order 2).

    Ground set: {0,...,6}, rank 3.
    Lines (dependent triples): {0,1,3}, {1,2,4}, {2,3,5}, {3,4,6}, {0,4,5}, {1,5,6}, {0,2,6}
    """
    ground = frozenset(range(7))
    lines = [
        frozenset({0, 1, 3}), frozenset({1, 2, 4}), frozenset({2, 3, 5}),
        frozenset({3, 4, 6}), frozenset({0, 4, 5}), frozenset({1, 5, 6}),
        frozenset({0, 2, 6})
    ]
    indep: Set[FrozenSet[int]] = set()
    indep.add(frozenset())
    for e in ground:
        indep.add(frozenset({e}))
    for pair in combinations(ground, 2):
        indep.add(frozenset(pair))
    for triple in combinations(ground, 3):
        t = frozenset(triple)
        if t not in lines:
            indep.add(t)
    return Matroid(ground, indep)


def check_wqo_property(matroids: List[Matroid]) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check if a finite list of matroids satisfies the WQO condition:
    there exist i < j with matroids[i] a minor of matroids[j].

    Returns (found_pair, (i, j) or None).
    """
    for i in range(len(matroids)):
        for j in range(i + 1, len(matroids)):
            if matroids[i].is_minor_of(matroids[j]):
                return True, (i, j)
    return False, None


def find_antichain(matroids: List[Matroid]) -> List[int]:
    """Find a maximal antichain (no minor relations) from the given list."""
    antichain: List[int] = []
    for i in range(len(matroids)):
        is_comparable = False
        for j in antichain:
            if matroids[i].is_minor_of(matroids[j]) or matroids[j].is_minor_of(matroids[i]):
                is_comparable = True
                break
        if not is_comparable:
            antichain.append(i)
    return antichain


if __name__ == "__main__":
    # Quick self-test
    U23 = uniform_matroid(3, 2)
    print(f"U(2,3) rank: {U23.matroid_rank()}")
    print(f"U(2,3) bases: {U23.bases()}")
    print(f"U(2,3) circuits: {U23.circuits()}")

    F7 = fano_matroid()
    print(f"\nFano matroid rank: {F7.matroid_rank()}")
    print(f"Fano matroid circuits (lines): {F7.circuits()}")

    # Test representability
    rep2, _ = is_representable_over_gf(U23, 2)
    print(f"\nU(2,3) representable over GF(2): {rep2}")
