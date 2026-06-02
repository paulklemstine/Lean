#!/usr/bin/env python3
"""
Algorithms for Matroid Minor Theory

Type-hinted implementations of key algorithms used in matroid minor theory,
including minor checking, forbidden minor detection, and antichain verification.
"""
from typing import Set, FrozenSet, List, Tuple, Optional, Iterator
import itertools


# ── Core Data Structures ────────────────────────────────────────────

class MatroidData:
    """Matroid represented by ground set and rank function."""

    def __init__(self, ground: FrozenSet[int], rank_fn: dict):
        """
        Args:
            ground: The ground set E.
            rank_fn: Dictionary mapping frozensets to their rank.
        """
        self.ground: FrozenSet[int] = ground
        self.rank_fn: dict = rank_fn

    def rank(self, S: FrozenSet[int]) -> int:
        """Return the rank of subset S."""
        return self.rank_fn.get(S, 0)

    def is_independent(self, S: FrozenSet[int]) -> bool:
        """S is independent iff rank(S) = |S|."""
        return self.rank(S) == len(S)


# ── Algorithm 1: Minor Detection ────────────────────────────────────

def is_minor(
    N_ground: FrozenSet[int],
    N_indep: Set[FrozenSet[int]],
    M_ground: FrozenSet[int],
    M_indep: Set[FrozenSet[int]]
) -> Tuple[bool, Optional[Tuple[FrozenSet[int], FrozenSet[int]]]]:
    """
    Check if matroid N is a minor of matroid M.

    Algorithm: Enumerate all disjoint pairs (C, D) with C, D ⊆ M.E,
    compute M/C\\D, and check isomorphism with N.

    Returns:
        (is_minor, witness) where witness = (C, D) if is_minor is True.

    Complexity: O(3^|M.E| * matroid_operations) — exponential but exact.
    """
    m_list: List[int] = sorted(M_ground)
    n: int = len(m_list)

    # Enumerate all assignments of M.E elements to {contract, delete, keep}
    for assignment in itertools.product(range(3), repeat=n):
        C: FrozenSet[int] = frozenset(m_list[i] for i in range(n) if assignment[i] == 0)
        D: FrozenSet[int] = frozenset(m_list[i] for i in range(n) if assignment[i] == 1)
        remaining: FrozenSet[int] = frozenset(m_list[i] for i in range(n) if assignment[i] == 2)

        if len(remaining) != len(N_ground):
            continue

        # Compute M/C\\D independent sets
        # Find max independent subset of C
        max_C_indep: FrozenSet[int] = frozenset()
        for k in range(len(C) + 1):
            for combo in itertools.combinations(C, k):
                fc = frozenset(combo)
                if fc in M_indep and len(fc) > len(max_C_indep):
                    max_C_indep = fc

        # Independent sets of M/C\\D
        minor_indep: Set[FrozenSet[int]] = set()
        for k in range(len(remaining) + 1):
            for combo in itertools.combinations(remaining, k):
                fc = frozenset(combo)
                if fc | max_C_indep in M_indep:
                    minor_indep.add(fc)

        # Check isomorphism (by relabeling)
        remaining_list = sorted(remaining)
        n_list = sorted(N_ground)
        if len(remaining_list) != len(n_list):
            continue

        # Try the identity mapping (elements match)
        relabeled: Set[FrozenSet[int]] = set()
        mapping = {remaining_list[i]: n_list[i] for i in range(len(n_list))}
        for I in minor_indep:
            relabeled.add(frozenset(mapping[e] for e in I))

        if relabeled == N_indep:
            return True, (C, D)

    return False, None


# ── Algorithm 2: Forbidden Minor Enumeration ────────────────────────

def find_forbidden_minors(
    property_check: callable,
    candidates: List[Tuple[FrozenSet[int], Set[FrozenSet[int]]]],
) -> List[Tuple[FrozenSet[int], Set[FrozenSet[int]]]]:
    """
    Find forbidden minors for a minor-closed property among candidates.

    A matroid M is a forbidden minor if:
    1. M does NOT satisfy the property
    2. Every proper minor of M DOES satisfy the property

    Args:
        property_check: Function (ground, indep) -> bool testing the property
        candidates: List of (ground, indep) pairs to check

    Returns:
        List of forbidden minors found.
    """
    forbidden: List[Tuple[FrozenSet[int], Set[FrozenSet[int]]]] = []

    for ground, indep in candidates:
        if property_check(ground, indep):
            continue  # M satisfies property, not a forbidden minor

        # Check all proper minors
        all_proper_satisfy: bool = True
        elements: List[int] = sorted(ground)

        for e in elements:
            # Deletion minor
            del_ground = ground - {e}
            del_indep = {I for I in indep if e not in I}
            if not property_check(del_ground, del_indep):
                all_proper_satisfy = False
                break

            # Contraction minor (simplified)
            con_ground = ground - {e}
            if frozenset({e}) in indep:
                con_indep = {I - {e} for I in indep if e in I}
            else:
                con_indep = {I for I in indep if e not in I}
            if not property_check(con_ground, con_indep):
                all_proper_satisfy = False
                break

        if all_proper_satisfy:
            forbidden.append((ground, indep))

    return forbidden


# ── Algorithm 3: Antichain Verification ──────────────────────────────

def verify_antichain(
    matroids: List[Tuple[FrozenSet[int], Set[FrozenSet[int]]]]
) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Verify that a list of matroids forms an antichain in the minor order.

    Returns:
        (is_antichain, counterexample) where counterexample = (i, j)
        means matroids[i] is a minor of matroids[j].
    """
    n: int = len(matroids)
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            g_i, ind_i = matroids[i]
            g_j, ind_j = matroids[j]
            found, _ = is_minor(g_i, ind_i, g_j, ind_j)
            if found:
                return False, (i, j)
    return True, None


# ── Algorithm 4: WQO Sequence Checker ────────────────────────────────

def check_wqo_sequence(
    sequence: List[Tuple[FrozenSet[int], Set[FrozenSet[int]]]]
) -> Optional[Tuple[int, int]]:
    """
    Given a finite sequence of matroids, find i < j with M_i ≤m M_j
    (if it exists). This witnesses the WQO property.

    Returns:
        (i, j) if found, None otherwise.
    """
    n: int = len(sequence)
    for i in range(n):
        for j in range(i + 1, n):
            g_i, ind_i = sequence[i]
            g_j, ind_j = sequence[j]
            found, _ = is_minor(g_i, ind_i, g_j, ind_j)
            if found:
                return (i, j)
    return None


# ── Algorithm 5: Matroid Dual Computation ────────────────────────────

def compute_dual(
    ground: FrozenSet[int], indep: Set[FrozenSet[int]]
) -> Tuple[FrozenSet[int], Set[FrozenSet[int]]]:
    """
    Compute the dual matroid.

    Bases of the dual = complements of bases of the original.
    """
    # Find bases (maximal independent sets)
    bases: Set[FrozenSet[int]] = set()
    for I in indep:
        if not any(I < J for J in indep):
            bases.add(I)

    # Dual bases = complements
    dual_bases: Set[FrozenSet[int]] = {ground - B for B in bases}

    # Dual independent sets = subsets of dual bases
    dual_indep: Set[FrozenSet[int]] = set()
    for B in dual_bases:
        for k in range(len(B) + 1):
            for combo in itertools.combinations(B, k):
                dual_indep.add(frozenset(combo))

    return ground, dual_indep


if __name__ == "__main__":
    # Quick test: U(2,4) and its dual
    ground = frozenset({0, 1, 2, 3})
    indep = set()
    for k in range(3):  # rank 2
        for combo in itertools.combinations(range(4), k):
            indep.add(frozenset(combo))

    print("U(2,4):", len(indep), "independent sets")
    dual_ground, dual_indep = compute_dual(ground, indep)
    print("U(2,4)*:", len(dual_indep), "independent sets")
    print("Self-dual:", indep == dual_indep)

    # Check WQO on a short sequence of uniform matroids
    seq = []
    for n in range(2, 6):
        g = frozenset(range(n))
        ind = set()
        for k in range(min(3, n + 1)):
            for combo in itertools.combinations(range(n), k):
                ind.add(frozenset(combo))
        seq.append((g, ind))

    result = check_wqo_sequence(seq)
    print(f"\nWQO witness in sequence of U(2,n) for n=2..5: {result}")
