#!/usr/bin/env python3
"""
Algorithms for Matroid Minor Theory

Type-hinted implementations of core algorithms for matroid minor detection,
forbidden minor enumeration, and WQO verification.
"""

from typing import (
    Set, FrozenSet, List, Optional, Tuple, Dict, Callable,
    Iterator, Sequence
)
import itertools
from dataclasses import dataclass, field


@dataclass(frozen=True)
class Matroid:
    """A matroid represented by ground set and independent sets.

    Attributes:
        ground: The ground set E of the matroid.
        indep: The collection of independent sets, satisfying:
            (I1) ∅ ∈ indep
            (I2) If I ∈ indep and J ⊆ I, then J ∈ indep
            (I3) If I, J ∈ indep with |I| < |J|, then ∃ e ∈ J \\ I with I ∪ {e} ∈ indep
    """
    ground: FrozenSet[int]
    indep: FrozenSet[FrozenSet[int]]

    def rank(self, S: Optional[FrozenSet[int]] = None) -> int:
        """Compute the rank of a subset S (default: full rank)."""
        target = S if S is not None else self.ground
        return max((len(I) for I in self.indep if I <= target), default=0)

    def bases(self) -> FrozenSet[FrozenSet[int]]:
        """Return all bases (maximal independent sets)."""
        r = self.rank()
        return frozenset(I for I in self.indep if len(I) == r)

    def circuits(self) -> FrozenSet[FrozenSet[int]]:
        """Return all circuits (minimal dependent sets)."""
        result: Set[FrozenSet[int]] = set()
        for size in range(1, len(self.ground) + 1):
            for S in itertools.combinations(self.ground, size):
                fs = frozenset(S)
                if fs not in self.indep:
                    # Check minimality
                    if all(fs - {e} in self.indep for e in fs):
                        result.add(fs)
        return frozenset(result)

    def dual(self) -> 'Matroid':
        """Compute the dual matroid M*."""
        bases_M = self.bases()
        # Bases of M* are complements of bases of M
        dual_bases = frozenset(self.ground - B for B in bases_M)
        # Independent sets of M* are subsets of dual bases
        dual_indep: Set[FrozenSet[int]] = {frozenset()}
        for B in dual_bases:
            for size in range(len(B) + 1):
                for subset in itertools.combinations(B, size):
                    dual_indep.add(frozenset(subset))
        return Matroid(self.ground, frozenset(dual_indep))


def uniform_matroid(k: int, n: int) -> Matroid:
    """Construct the uniform matroid U(k, n).

    Args:
        k: The rank parameter.
        n: The size of the ground set.

    Returns:
        The uniform matroid where every set of size ≤ k is independent.
    """
    ground = frozenset(range(n))
    indep: Set[FrozenSet[int]] = set()
    for size in range(min(k, n) + 1):
        for subset in itertools.combinations(range(n), size):
            indep.add(frozenset(subset))
    return Matroid(ground, frozenset(indep))


def matroid_delete(M: Matroid, D: Set[int]) -> Matroid:
    """Delete elements D from matroid M.

    M \\ D has ground set E \\ D and independent sets
    {I ∈ I(M) : I ⊆ E \\ D}.

    Args:
        M: The matroid.
        D: Elements to delete.

    Returns:
        The deletion M \\ D.
    """
    D_fs = frozenset(D)
    new_ground = M.ground - D_fs
    new_indep = frozenset(I for I in M.indep if I <= new_ground)
    return Matroid(new_ground, new_indep)


def matroid_contract(M: Matroid, C: Set[int]) -> Matroid:
    """Contract elements C from matroid M.

    M / C has ground set E \\ C and a set I ⊆ E \\ C is independent
    iff I ∪ B_C is independent in M, where B_C is a basis for C in M.

    Args:
        M: The matroid.
        C: Elements to contract.

    Returns:
        The contraction M / C.
    """
    C_fs = frozenset(C) & M.ground
    # Find a maximal independent subset of C (basis for C)
    basis: FrozenSet[int] = frozenset()
    for e in sorted(C_fs):
        candidate = basis | {e}
        if candidate in M.indep:
            basis = candidate

    new_ground = M.ground - C_fs
    new_indep: Set[FrozenSet[int]] = set()
    for size in range(len(new_ground) + 1):
        for subset in itertools.combinations(sorted(new_ground), size):
            I = frozenset(subset)
            if I | basis in M.indep:
                new_indep.add(I)
    return Matroid(new_ground, frozenset(new_indep))


def matroid_minor(M: Matroid, C: Set[int], D: Set[int]) -> Matroid:
    """Compute the minor M / C \\ D.

    Args:
        M: The matroid.
        C: Elements to contract.
        D: Elements to delete (must be disjoint from C).

    Returns:
        The minor M / C \\ D.
    """
    assert not (frozenset(C) & frozenset(D)), "C and D must be disjoint"
    return matroid_delete(matroid_contract(M, C), D)


def is_matroid_isomorphic(M1: Matroid, M2: Matroid) -> bool:
    """Test if two matroids are isomorphic.

    Uses brute force permutation search. Only feasible for small matroids.

    Args:
        M1, M2: Matroids to compare.

    Returns:
        True if M1 ≅ M2.
    """
    if len(M1.ground) != len(M2.ground):
        return False
    if M1.rank() != M2.rank():
        return False
    if len(M1.indep) != len(M2.indep):
        return False

    elems1 = sorted(M1.ground)
    elems2 = sorted(M2.ground)

    for perm in itertools.permutations(elems2):
        mapping = dict(zip(elems1, perm))
        mapped = frozenset(
            frozenset(mapping[e] for e in I) for I in M1.indep
        )
        if mapped == M2.indep:
            return True
    return False


def has_minor(N: Matroid, M: Matroid, max_ground: int = 10) -> bool:
    """Test if N is a minor of M.

    Searches over all possible (C, D) pairs to find N as M / C \\ D.

    Args:
        N: The potential minor.
        M: The host matroid.
        max_ground: Skip if M has too many elements.

    Returns:
        True if N ≤m M.
    """
    if len(M.ground) > max_ground:
        return False
    if len(N.ground) > len(M.ground):
        return False

    target_size = len(N.ground)
    elems = sorted(M.ground)

    for c_size in range(len(elems) + 1):
        for C in itertools.combinations(elems, c_size):
            C_set = set(C)
            remaining = [e for e in elems if e not in C_set]
            d_size = len(remaining) - target_size
            if d_size < 0:
                continue
            for D in itertools.combinations(remaining, d_size):
                D_set = set(D)
                try:
                    minor = matroid_minor(M, C_set, D_set)
                    if is_matroid_isomorphic(minor, N):
                        return True
                except (AssertionError, ValueError):
                    pass
    return False


def enumerate_forbidden_minors(
    property_test: Callable[[Matroid], bool],
    candidates: List[Matroid]
) -> List[Matroid]:
    """Find all forbidden minors for a property from a list of candidates.

    A matroid N is a forbidden minor for property P if:
    - ¬P(N)
    - For every proper minor M of N: P(M)

    Args:
        property_test: Function testing whether a matroid has the property.
        candidates: List of matroid candidates to check.

    Returns:
        List of forbidden minors found among candidates.
    """
    forbidden: List[Matroid] = []

    for N in candidates:
        if property_test(N):
            continue  # N satisfies P, so it's not a forbidden minor

        # Check if every proper minor satisfies P
        is_forbidden = True
        elems = sorted(N.ground)

        # Check single-element deletions and contractions
        for e in elems:
            del_minor = matroid_delete(N, {e})
            if not property_test(del_minor):
                is_forbidden = False
                break
            con_minor = matroid_contract(N, {e})
            if not property_test(con_minor):
                is_forbidden = False
                break

        if is_forbidden:
            # Verify it's not isomorphic to an already found forbidden minor
            if not any(is_matroid_isomorphic(N, F) for F in forbidden):
                forbidden.append(N)

    return forbidden


def verify_wqo(
    sequence: Sequence[Matroid],
    max_check: int = 100
) -> Optional[Tuple[int, int]]:
    """Verify the WQO property on a finite sequence.

    For a sequence M_1, M_2, ..., find i < j such that M_i ≤m M_j.

    Args:
        sequence: Sequence of matroids.
        max_check: Maximum pairs to check.

    Returns:
        Tuple (i, j) witnessing WQO, or None if not found.
    """
    checked = 0
    for i in range(len(sequence)):
        for j in range(i + 1, len(sequence)):
            if checked >= max_check:
                return None
            if has_minor(sequence[i], sequence[j]):
                return (i, j)
            checked += 1
    return None


# --- GF(q) Representability Testing ---

def gf_elements(q: int) -> List[int]:
    """Return elements of GF(q) for prime q."""
    return list(range(q))


def is_gf_representable(M: Matroid, q: int, max_dim: int = 5) -> bool:
    """Test if matroid M is representable over GF(q) (prime q).

    Uses brute force search over all possible representations.
    Only feasible for very small matroids.

    Args:
        M: The matroid.
        q: Prime field size.
        max_dim: Maximum dimension to try.

    Returns:
        True if a representation was found.
    """
    n = len(M.ground)
    if n == 0:
        return True

    elems = sorted(M.ground)
    field = gf_elements(q)

    for dim in range(1, min(max_dim, n) + 1):
        # Try all possible dim × n matrices over GF(q)
        for vectors in itertools.product(
            itertools.product(field, repeat=dim), repeat=n
        ):
            # Check if this representation matches the matroid
            repr_map = {elems[i]: list(vectors[i]) for i in range(n)}
            if _check_representation(M, repr_map, q):
                return True
    return False


def _check_representation(
    M: Matroid,
    repr_map: Dict[int, List[int]],
    q: int
) -> bool:
    """Check if a representation matches the matroid's independent sets."""
    elems = sorted(M.ground)

    for size in range(len(elems) + 1):
        for subset in itertools.combinations(elems, size):
            fs = frozenset(subset)
            vectors = [repr_map[e] for e in subset]
            lin_indep = _is_linearly_independent_gf(vectors, q)
            if (fs in M.indep) != lin_indep:
                return False
    return True


def _is_linearly_independent_gf(vectors: List[List[int]], q: int) -> bool:
    """Test linear independence over GF(q) by Gaussian elimination."""
    if not vectors:
        return True

    n = len(vectors)
    m = len(vectors[0])

    # Copy matrix
    matrix = [row[:] for row in vectors]

    pivot_row = 0
    for col in range(m):
        # Find pivot
        found = False
        for row in range(pivot_row, n):
            if matrix[row][col] % q != 0:
                matrix[pivot_row], matrix[row] = matrix[row], matrix[pivot_row]
                found = True
                break
        if not found:
            continue

        # Eliminate
        inv = _mod_inverse(matrix[pivot_row][col] % q, q)
        if inv is None:
            continue
        for row in range(n):
            if row != pivot_row and matrix[row][col] % q != 0:
                factor = (matrix[row][col] * inv) % q
                for c in range(m):
                    matrix[row][c] = (matrix[row][c] - factor * matrix[pivot_row][c]) % q
        pivot_row += 1

    return pivot_row == n


def _mod_inverse(a: int, p: int) -> Optional[int]:
    """Compute modular inverse of a mod p (p prime)."""
    a = a % p
    if a == 0:
        return None
    return pow(a, p - 2, p)


if __name__ == "__main__":
    # Quick test
    U24 = uniform_matroid(2, 4)
    print(f"U(2,4): rank={U24.rank()}, |E|={len(U24.ground)}")
    print(f"  GF(2)-representable? {is_gf_representable(U24, 2, max_dim=3)}")
    print(f"  GF(3)-representable? {is_gf_representable(U24, 3, max_dim=3)}")

    U23 = uniform_matroid(2, 3)
    print(f"\nU(2,3) is a minor of U(2,4)? {has_minor(U23, U24)}")
