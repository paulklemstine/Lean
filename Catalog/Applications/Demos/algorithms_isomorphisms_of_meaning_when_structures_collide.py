#!/usr/bin/env python3
"""
Semantic Bundles — Core Algorithms

Type-hinted implementations of the key algorithms from the semantic bundle theory.
"""

from typing import Callable, Optional
from itertools import permutations
from collections import Counter
from math import log2
from dataclasses import dataclass


BinOp = Callable[[int, int], int]


@dataclass
class DecoratedMagma:
    """A finite decorated magma: carrier {0, ..., n-1} with operation and labeling."""
    n: int
    op: BinOp
    label: list[int]

    def __post_init__(self) -> None:
        assert len(self.label) == self.n


def cycle_decomposition(perm: tuple[int, ...], n: int) -> list[list[int]]:
    """Decompose a permutation into disjoint cycles."""
    visited = [False] * n
    cycles: list[list[int]] = []
    for i in range(n):
        if not visited[i]:
            cycle = []
            j = i
            while not visited[j]:
                visited[j] = True
                cycle.append(j)
                j = perm[j]
            cycles.append(cycle)
    return cycles


def is_operation_preserving(op1: BinOp, op2: BinOp, n: int, perm: tuple[int, ...]) -> bool:
    """Check if perm : {0,...,n-1} -> {0,...,n-1} preserves the operation."""
    for x in range(n):
        for y in range(n):
            if perm[op1(x, y)] != op2(perm[x], perm[y]):
                return False
    return True


def automorphism_group(D: DecoratedMagma) -> list[tuple[int, ...]]:
    """Compute the automorphism group of D's underlying operation."""
    return [
        p for p in permutations(range(D.n))
        if is_operation_preserving(D.op, D.op, D.n, p)
    ]


def algebraic_isomorphisms(D1: DecoratedMagma, D2: DecoratedMagma) -> list[tuple[int, ...]]:
    """Find all algebraic isomorphisms from D1 to D2."""
    assert D1.n == D2.n
    return [
        p for p in permutations(range(D1.n))
        if is_operation_preserving(D1.op, D2.op, D1.n, p)
    ]


def semantic_isomorphisms(D1: DecoratedMagma, D2: DecoratedMagma) -> list[tuple[int, ...]]:
    """Find all semantic isomorphisms from D1 to D2."""
    return [
        p for p in algebraic_isomorphisms(D1, D2)
        if all(D1.label[x] == D2.label[p[x]] for x in range(D1.n))
    ]


def are_algebraically_isomorphic(D1: DecoratedMagma, D2: DecoratedMagma) -> bool:
    """Test algebraic isomorphism."""
    return len(algebraic_isomorphisms(D1, D2)) > 0


def are_semantically_isomorphic(D1: DecoratedMagma, D2: DecoratedMagma) -> bool:
    """Test semantic isomorphism."""
    return len(semantic_isomorphisms(D1, D2)) > 0


def is_rigid(D: DecoratedMagma) -> bool:
    """Test if D is semantically rigid (trivial automorphism group)."""
    auts = automorphism_group(D)
    return len(auts) == 1 and auts[0] == tuple(range(D.n))


def semantic_diversity(D: DecoratedMagma) -> int:
    """Compute the semantic diversity of D."""
    return len(set(D.label))


def semantic_spectrum(D: DecoratedMagma) -> list[int]:
    """Compute the semantic spectrum of D (sorted label frequencies)."""
    return sorted(Counter(D.label).values(), reverse=True)


def semantic_orbit_count(D: DecoratedMagma, k: int) -> int:
    """Count semantically distinct labelings of D's operation with k label values.

    Uses Burnside's lemma: count = (1/|Aut|) * Σ_{φ∈Aut} k^{cycles(φ)}
    """
    auts = automorphism_group(D)
    total = 0
    for aut in auts:
        cycles = len(cycle_decomposition(aut, D.n))
        total += k ** cycles
    return total // len(auts)


def semantic_entropy(D: DecoratedMagma, k: int) -> float:
    """Compute the semantic entropy H(D, k) = log₂(orbit_count)."""
    orbits = semantic_orbit_count(D, k)
    return log2(orbits) if orbits > 0 else 0.0


def truth_meaning_gap(
    D1: DecoratedMagma,
    D2: DecoratedMagma,
    phi: Callable[[int], int],
    truth: Callable[[int], bool],
) -> tuple[bool, bool]:
    """Check truth preservation and meaning preservation of phi.

    Returns (truth_preserved, meaning_preserved).
    """
    truth_ok = all(
        not truth(D1.label[x]) or truth(D2.label[phi(x)])
        for x in range(D1.n)
    )
    meaning_ok = all(
        D1.label[x] == D2.label[phi(x)]
        for x in range(D1.n)
    )
    return truth_ok, meaning_ok


# =============================================================
# Example usage
# =============================================================

if __name__ == "__main__":
    xor = lambda a, b: (a + b) % 2

    D_id = DecoratedMagma(2, xor, [0, 1])
    D_swap = DecoratedMagma(2, xor, [1, 0])

    print(f"Rigid(D_id): {is_rigid(D_id)}")
    print(f"AlgIso: {are_algebraically_isomorphic(D_id, D_swap)}")
    print(f"SemIso: {are_semantically_isomorphic(D_id, D_swap)}")
    print(f"Diversity(D_id): {semantic_diversity(D_id)}")
    print(f"Spectrum(D_id): {semantic_spectrum(D_id)}")
    print(f"Orbits(XOR, k=2): {semantic_orbit_count(D_id, 2)}")
    print(f"Entropy(XOR, k=2): {semantic_entropy(D_id, 2):.2f} bits")

    tp, mp = truth_meaning_gap(D_id, D_swap, lambda x: x, lambda v: v != 0)
    print(f"Truth preserved: {tp}, Meaning preserved: {mp}")
