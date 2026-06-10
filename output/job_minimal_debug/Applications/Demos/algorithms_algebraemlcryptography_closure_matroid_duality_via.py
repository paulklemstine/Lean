#!/usr/bin/env python3
"""
Algorithms for Closure–Matroid Duality

Implements the core algorithms from the research paper:
1. Rank computation from exchange closure
2. Circuit enumeration
3. Flat lattice construction
4. Canonical dependency presentation construction
5. Access structure enumeration
"""

import itertools
from typing import Set, FrozenSet, List, Tuple, Callable, Optional


def compute_rank(cl: Callable, ground: frozenset, A: frozenset) -> int:
    """
    Compute the rank of A in an exchange closure system.

    Algorithm: Find minimum |B| where B ⊆ A and cl(B) ⊇ A.
    Time complexity: O(2^|A| * cost(cl))

    Args:
        cl: Closure operator (frozenset -> frozenset)
        ground: Ground set
        A: Set to compute rank of

    Returns:
        Rank of A
    """
    A = frozenset(A)
    for r in range(len(A) + 1):
        for B in itertools.combinations(A, r):
            B = frozenset(B)
            if A <= cl(B):
                return r
    return len(A)


def enumerate_circuits(cl: Callable, ground: frozenset) -> List[frozenset]:
    """
    Enumerate all circuits of an exchange closure system.

    Algorithm: Bottom-up scan of subsets by size.
    A circuit C satisfies: rank(C) < |C| and for all x ∈ C, rank(C \ {x}) = |C| - 1.
    Time complexity: O(2^|ground| * |ground| * cost(cl))

    Args:
        cl: Closure operator
        ground: Ground set

    Returns:
        List of all circuits
    """
    def rank(A):
        return compute_rank(cl, ground, A)

    circuits = []
    for size in range(1, len(ground) + 1):
        for C in itertools.combinations(ground, size):
            C = frozenset(C)
            if rank(C) < len(C):
                # Check minimality: all proper subsets are independent
                if all(rank(C - {x}) == len(C) - 1 for x in C):
                    circuits.append(C)
    return circuits


def enumerate_flats(cl: Callable, ground: frozenset) -> List[frozenset]:
    """
    Enumerate all flats (closed sets) of an exchange closure system.

    Algorithm: Check each subset F to see if cl(F) = F.
    Time complexity: O(2^|ground| * cost(cl))

    Args:
        cl: Closure operator
        ground: Ground set

    Returns:
        List of all flats, sorted by size
    """
    flats = []
    for size in range(len(ground) + 1):
        for F in itertools.combinations(ground, size):
            F = frozenset(F)
            if cl(F) == F:
                flats.append(F)
    return sorted(flats, key=len)


def build_canonical_presentation(
    cl: Callable, ground: frozenset
) -> List[Tuple[frozenset, any]]:
    """
    Build the canonical dependency presentation from a closure system.

    For each pair (A, x) where x ∈ cl(A) \\ A, create a dependency
    with support = A ∪ {x} and target = x.

    Time complexity: O(2^|ground| * |ground| * cost(cl))

    Args:
        cl: Closure operator
        ground: Ground set

    Returns:
        List of (support, target) pairs
    """
    deps = []
    for size in range(len(ground) + 1):
        for A in itertools.combinations(ground, size):
            A = frozenset(A)
            cl_A = cl(A)
            for x in cl_A - A:
                deps.append((A | {x}, x))
    return deps


def enumerate_qualified_sets(
    deps: List[Tuple[frozenset, any]],
    ground: frozenset,
    target: any
) -> List[frozenset]:
    """
    Enumerate minimal qualified sets for a target element.

    A set Q is qualified if target ∈ cl(Q).
    A set Q is minimally qualified if no proper subset is qualified.

    Time complexity: O(2^|ground| * |deps|)

    Args:
        deps: List of (support, target) dependency pairs
        ground: Ground set
        target: Target element to reconstruct

    Returns:
        List of minimal qualified sets
    """
    def cl(A):
        A = frozenset(A)
        result = set(A)
        for support, tgt in deps:
            if (support - {tgt}) <= A:
                result.add(tgt)
        return frozenset(result)

    qualified = []
    for size in range(len(ground) + 1):
        for Q in itertools.combinations(ground - {target}, size):
            Q = frozenset(Q)
            if target in cl(Q):
                # Check minimality
                if all(target not in cl(Q - {x}) for x in Q):
                    qualified.append(Q)
    return qualified


def verify_rank_axioms(
    cl: Callable, ground: frozenset, verbose: bool = True
) -> dict:
    """
    Verify all matroid rank axioms for a closure system.

    Checks:
    1. Bounded: r(A) ≤ |A|
    2. Monotone: A ⊆ B → r(A) ≤ r(B)
    3. Submodular: r(A∪B) + r(A∩B) ≤ r(A) + r(B)
    4. Unit increase: r(A) ≤ r(A∪{x}) ≤ r(A) + 1

    Returns:
        Dict with keys 'bounded', 'monotone', 'submodular', 'unit_increase'
        each mapping to True/False
    """
    def rank(A):
        return compute_rank(cl, ground, A)

    all_sets = []
    for size in range(len(ground) + 1):
        for S in itertools.combinations(ground, size):
            all_sets.append(frozenset(S))

    results = {}

    # 1. Bounded
    results['bounded'] = all(rank(A) <= len(A) for A in all_sets)

    # 2. Monotone
    results['monotone'] = all(
        rank(A) <= rank(B)
        for A in all_sets for B in all_sets
        if A <= B
    )

    # 3. Submodular
    results['submodular'] = all(
        rank(A | B) + rank(A & B) <= rank(A) + rank(B)
        for A in all_sets for B in all_sets
    )

    # 4. Unit increase
    results['unit_increase'] = all(
        rank(A) <= rank(A | {x}) <= rank(A) + 1
        for A in all_sets for x in ground
    )

    if verbose:
        for name, ok in results.items():
            print(f"  {name}: {'✓' if ok else '✗'}")

    return results


def compute_flat_lattice(
    cl: Callable, ground: frozenset
) -> List[Tuple[frozenset, frozenset, bool]]:
    """
    Compute the covering relations in the flat lattice.

    Returns list of (F1, F2, covers) where F1 ⊂ F2 are flats
    and F2 covers F1 (no flat strictly between them).

    Time complexity: O(|flats|^2 * |ground|)
    """
    flats = enumerate_flats(cl, ground)
    covers = []
    for i, F1 in enumerate(flats):
        for j, F2 in enumerate(flats):
            if F1 < F2:
                # Check if F2 covers F1
                is_cover = True
                for k, F3 in enumerate(flats):
                    if F1 < F3 < F2:
                        is_cover = False
                        break
                if is_cover:
                    covers.append((F1, F2))
    return covers


if __name__ == "__main__":
    # Example: U(2,4) uniform matroid
    ground = frozenset(range(4))

    def cl_u24(A):
        A = frozenset(A)
        return ground if len(A) >= 2 else A

    print("Algorithms Demo: U(2,4)")
    print(f"Rank of {{0,1}}: {compute_rank(cl_u24, ground, frozenset({0,1}))}")
    print(f"Circuits: {[set(c) for c in enumerate_circuits(cl_u24, ground)]}")
    print(f"Flats: {[set(f) for f in enumerate_flats(cl_u24, ground)]}")

    deps = build_canonical_presentation(cl_u24, ground)
    print(f"Dependencies: {len(deps)}")

    qs = enumerate_qualified_sets(deps, ground, 3)
    print(f"Minimal qualified for 3: {[set(q) for q in qs]}")

    print("\nRank axiom verification:")
    verify_rank_axioms(cl_u24, ground)

    covers = compute_flat_lattice(cl_u24, ground)
    print(f"\nFlat lattice covering relations ({len(covers)}):")
    for F1, F2 in covers:
        print(f"  {set(F1)} ≺ {set(F2)}")
