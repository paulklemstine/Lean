#!/usr/bin/env python3
"""
Algorithms for Exchange-Closure Dependency Systems

Implements the key algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

from __future__ import annotations
from typing import Callable, FrozenSet, Optional
from itertools import combinations

Element = int
Subset = FrozenSet[Element]
ClosureOracle = Callable[[Subset], Subset]


def greedy_sparse_predictor(
    cl: ClosureOracle,
    A: Subset,
    b: Element,
) -> Optional[Subset]:
    """Greedy minimal support extraction under exchange.

    Given a closure oracle cl and b ∈ cl(A), finds a minimal A* ⊆ A
    with b ∈ cl(A*) by greedily removing elements.

    Under the exchange property, this algorithm is guaranteed to find
    a minimal support regardless of elimination order.

    Args:
        cl: Closure oracle mapping subsets to their closures
        A: Initial feature set (support)
        b: Target element to derive

    Returns:
        Minimal subset A* ⊆ A with b ∈ cl(A*), or None if b ∉ cl(A)

    Time complexity: O(|A|) closure oracle calls
    Space complexity: O(|A|)

    Example:
        >>> ground = {0, 1, 2, 3}
        >>> def cl(S): return frozenset(ground) if len(S) >= 2 else S
        >>> greedy_sparse_predictor(cl, frozenset({0, 1, 2}), 3)
        frozenset({0, 1})  # or any 2-element subset
    """
    if b not in cl(A):
        return None

    current = set(A)
    for a in sorted(A):
        candidate = frozenset(current - {a})
        if b in cl(candidate):
            current = set(candidate)

    return frozenset(current)


def enumerate_canonical_basis(
    ground: set[Element],
    cl: ClosureOracle,
) -> list[tuple[Subset, Element]]:
    """Enumerate the canonical sparse predictor basis.

    Finds all pairs (A, b) where A is a minimal support for b,
    i.e., b ∈ cl(A) and no proper subset of A supports b.

    Args:
        ground: The finite ground set
        cl: Closure oracle

    Returns:
        List of (minimal_support, target) pairs

    Time complexity: O(2^|ground| · |ground|²) closure oracle calls
    Space complexity: O(|basis|)
    """
    basis = []
    all_subsets = []
    elems = sorted(ground)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            all_subsets.append(frozenset(combo))

    for b in sorted(ground):
        for A in all_subsets:
            if b not in cl(A):
                continue
            # Check minimality
            is_min = True
            for a in A:
                if b in cl(A - {a}):
                    is_min = False
                    break
            if is_min:
                basis.append((A, b))

    return basis


def find_closed_sets(
    ground: set[Element],
    cl: ClosureOracle,
) -> list[Subset]:
    """Find all closed sets of a closure operator.

    Args:
        ground: The finite ground set
        cl: Closure oracle

    Returns:
        List of all closed sets (S where cl(S) = S), sorted by size

    Time complexity: O(2^|ground|) closure oracle calls
    """
    closed = []
    elems = sorted(ground)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            S = frozenset(combo)
            if cl(S) == S:
                closed.append(S)
    return sorted(closed, key=lambda s: (len(s), sorted(s)))


def find_join_irreducibles(
    ground: set[Element],
    cl: ClosureOracle,
) -> list[Subset]:
    """Find join-irreducible closed sets.

    A closed set F is join-irreducible if F ≠ cl(∅) and
    F cannot be written as cl(G ∪ H) for closed G ≠ F and H ≠ F.

    Args:
        ground: The finite ground set
        cl: Closure oracle

    Returns:
        List of join-irreducible closed sets

    Time complexity: O(2^(3|ground|)) in worst case
    """
    closed = find_closed_sets(ground, cl)
    cl_empty = cl(frozenset())
    ji = []

    for F in closed:
        if F == cl_empty:
            continue
        is_ji = True
        for G in closed:
            if not is_ji:
                break
            if G == F:
                continue
            for H in closed:
                if H == F:
                    continue
                if cl(G | H) == F:
                    is_ji = False
                    break
        if is_ji:
            ji.append(F)

    return ji


def verify_exchange_property(
    ground: set[Element],
    cl: ClosureOracle,
) -> tuple[bool, Optional[str]]:
    """Verify the Steinitz exchange property.

    Checks: for all A, x, y:
      y ∈ cl(A ∪ {x}) \\ cl(A) ⟹ x ∈ cl(A ∪ {y})

    Args:
        ground: The finite ground set
        cl: Closure oracle

    Returns:
        (True, None) if exchange holds, (False, counterexample_str) otherwise

    Time complexity: O(2^|ground| · |ground|²)
    """
    elems = sorted(ground)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            A = frozenset(combo)
            for x in ground - A:
                clAx = cl(A | {x})
                clA = cl(A)
                for y in ground - A:
                    if x == y:
                        continue
                    if y in clAx and y not in clA:
                        clAy = cl(A | {y})
                        if x not in clAy:
                            return (False,
                                f"y={y} ∈ cl({set(A)}∪{{{x}}})\\cl({set(A)}), "
                                f"but x={x} ∉ cl({set(A)}∪{{{y}}})")
    return (True, None)


def reconstruct_closure_from_basis(
    ground: set[Element],
    basis: list[tuple[Subset, Element]],
) -> ClosureOracle:
    """Reconstruct a closure operator from its canonical basis.

    Given the canonical basis {(A, b) : A is a minimal support for b},
    reconstructs the closure operator by iterating implications to fixpoint.

    This implements the constructive direction of the Canonical Basis
    Determination Theorem.

    Args:
        ground: The finite ground set
        basis: List of (support, target) pairs

    Returns:
        Closure oracle equivalent to the original

    Time complexity per call: O(|ground| · |basis|)
    """
    def cl(S: Subset) -> Subset:
        current = set(S)
        changed = True
        while changed:
            changed = False
            for A, b in basis:
                if A <= current and b not in current:
                    current.add(b)
                    changed = True
        return frozenset(current)
    return cl


if __name__ == "__main__":
    # Example: uniform matroid U(2, 4)
    ground = {0, 1, 2, 3}

    def rank_fn(A: Subset) -> int:
        return min(len(A), 2)

    def cl(A: Subset) -> Subset:
        rA = rank_fn(A)
        return frozenset(x for x in ground if rank_fn(A | {x}) == rA)

    print("Exchange-Closure Algorithms Demo")
    print("=" * 40)

    # Verify exchange
    ok, msg = verify_exchange_property(ground, cl)
    print(f"Exchange property: {'✓' if ok else '✗ ' + str(msg)}")

    # Closed sets
    closed = find_closed_sets(ground, cl)
    print(f"Closed sets: {[set(s) for s in closed]}")

    # Join-irreducibles
    ji = find_join_irreducibles(ground, cl)
    print(f"Join-irreducibles: {[set(s) for s in ji]}")

    # Canonical basis
    basis = enumerate_canonical_basis(ground, cl)
    print(f"Canonical basis ({len(basis)} entries)")

    # Reconstruct and verify
    cl2 = reconstruct_closure_from_basis(ground, basis)
    all_match = True
    for r in range(len(ground) + 1):
        for combo in combinations(sorted(ground), r):
            S = frozenset(combo)
            if cl(S) != cl2(S):
                all_match = False
                print(f"Mismatch at {set(S)}: {set(cl(S))} ≠ {set(cl2(S))}")
    print(f"Reconstruction verified: {'✓' if all_match else '✗'}")
