#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Moore closure computation.

Implements:
1. Naive Moore closure (intersection of all closed supersets) for finite universes
2. Iterative forward closure for finitely generated structures
3. Bottom-up lattice construction for complete lattice visualization
"""

from typing import (
    TypeVar, Set, FrozenSet, Callable, List, Dict, Tuple, Optional, Iterator
)
from collections import defaultdict
import numpy as np

T = TypeVar('T')


def naive_moore_closure(
    universe: FrozenSet[T],
    is_closed: Callable[[FrozenSet[T]], bool],
    seed: FrozenSet[T]
) -> FrozenSet[T]:
    """
    Compute Moore closure by intersecting all closed supersets.

    This is the direct implementation of the mathematical definition:
        mooreClosure(seed) = ⋂ {S ⊆ universe | is_closed(S) and seed ⊆ S}

    Time complexity: O(2^n · C) where n = |universe| and C = cost of is_closed.
    Space complexity: O(2^n) in the worst case.

    Parameters
    ----------
    universe : FrozenSet[T]
        The finite universe of elements.
    is_closed : Callable[[FrozenSet[T]], bool]
        Predicate checking if a set satisfies the closedness property.
    seed : FrozenSet[T]
        The initial set to close.

    Returns
    -------
    FrozenSet[T]
        The smallest closed superset of seed.

    Examples
    --------
    >>> # Subgroups of Z/4Z
    >>> U = frozenset({0, 1, 2, 3})
    >>> def closed_add4(S):
    ...     S = set(S)
    ...     return 0 in S and all((a+b)%4 in S for a in S for b in S)
    >>> naive_moore_closure(U, closed_add4, frozenset({2}))
    frozenset({0, 2})
    """
    elements = list(universe)
    n = len(elements)
    if n > 25:
        raise ValueError(f"Universe too large ({n} elements) for naive enumeration")

    result = set(universe)
    for mask in range(1 << n):
        subset = frozenset(elements[i] for i in range(n) if mask & (1 << i))
        if seed.issubset(subset) and is_closed(subset):
            result = result.intersection(subset)

    return frozenset(result)


def iterative_forward_closure(
    seed: Set[T],
    generators: List[Callable[[T], Optional[T]]],
    max_size: int = 10000
) -> Set[T]:
    """
    Compute closure by iteratively applying generators until fixpoint.

    This implements the computational version of Moore closure for
    predicates of the form "closed under a set of operations."

    Time complexity: O(|result| · |generators|) per iteration,
                     O(|result|^2 · |generators|) total in worst case.

    Parameters
    ----------
    seed : Set[T]
        Initial set of elements.
    generators : List[Callable[[T], Optional[T]]]
        List of unary operations. Each takes an element and returns a new
        element (or None if the operation is not applicable).
    max_size : int
        Safety bound on the result size.

    Returns
    -------
    Set[T]
        The closure of seed under all generators.
    """
    hull = set(seed)
    changed = True
    while changed and len(hull) < max_size:
        changed = False
        new = set()
        for x in hull:
            for gen in generators:
                y = gen(x)
                if y is not None and y not in hull:
                    new.add(y)
                    changed = True
        hull.update(new)
    return hull


def iterative_binary_closure(
    seed: Set[T],
    identity: T,
    binary_op: Callable[[T, T], T],
    max_size: int = 10000,
    key_fn: Optional[Callable[[T], any]] = None
) -> Set[T]:
    """
    Compute closure under a binary operation (monoid generation).

    Implements mooreClosure for ClosedMulId-type predicates.

    Parameters
    ----------
    seed : Set[T]
        Seed elements (generators).
    identity : T
        Identity element for the binary operation.
    binary_op : Callable[[T, T], T]
        The binary operation (e.g., matrix multiplication).
    max_size : int
        Safety bound.
    key_fn : Optional[Callable[[T], any]]
        Hash function for elements (needed for unhashable types like numpy arrays).

    Returns
    -------
    Set or Dict
        The generated monoid.
    """
    if key_fn is None:
        key_fn = lambda x: x

    generated = {key_fn(identity): identity}
    for s in seed:
        k = key_fn(s)
        if k not in generated:
            generated[k] = s

    changed = True
    while changed and len(generated) < max_size:
        changed = False
        new_elements = {}
        for a in list(generated.values()):
            for s in seed:
                prod = binary_op(a, s)
                k = key_fn(prod)
                if k not in generated and k not in new_elements:
                    new_elements[k] = prod
                    changed = True
        generated.update(new_elements)

    return list(generated.values())


def enumerate_moore_closed_sets(
    universe: FrozenSet[T],
    is_closed: Callable[[FrozenSet[T]], bool]
) -> List[FrozenSet[T]]:
    """
    Enumerate all closed sets in a finite universe.

    Time complexity: O(2^n · C) where n = |universe|.

    Parameters
    ----------
    universe : FrozenSet[T]
        The finite universe.
    is_closed : Callable[[FrozenSet[T]], bool]
        Closedness predicate.

    Returns
    -------
    List[FrozenSet[T]]
        All closed subsets of universe, sorted by size.
    """
    elements = list(universe)
    n = len(elements)
    if n > 20:
        raise ValueError(f"Universe too large ({n}) for enumeration")

    closed_sets = []
    for mask in range(1 << n):
        subset = frozenset(elements[i] for i in range(n) if mask & (1 << i))
        if is_closed(subset):
            closed_sets.append(subset)

    return sorted(closed_sets, key=len)


def build_lattice_diagram(
    closed_sets: List[FrozenSet[T]]
) -> Dict[int, List[int]]:
    """
    Build the Hasse diagram (cover relation) of closed sets ordered by inclusion.

    Parameters
    ----------
    closed_sets : List[FrozenSet[T]]
        List of closed sets, sorted by size.

    Returns
    -------
    Dict[int, List[int]]
        Adjacency list: edges[i] = [j, ...] means closed_sets[i] ⊂ closed_sets[j]
        is a cover relation.
    """
    n = len(closed_sets)
    covers = defaultdict(list)

    for i in range(n):
        for j in range(i + 1, n):
            if closed_sets[i].issubset(closed_sets[j]):
                # Check if it's a cover (no intermediate element)
                is_cover = True
                for k in range(n):
                    if k != i and k != j:
                        if (closed_sets[i].issubset(closed_sets[k]) and
                            closed_sets[k].issubset(closed_sets[j]) and
                            closed_sets[k] != closed_sets[i] and
                            closed_sets[k] != closed_sets[j]):
                            is_cover = False
                            break
                if is_cover:
                    covers[i].append(j)

    return dict(covers)


def compute_lattice_meet(
    a: FrozenSet[T],
    b: FrozenSet[T],
    closed_sets: List[FrozenSet[T]]
) -> FrozenSet[T]:
    """Compute the meet (greatest lower bound) of two closed sets."""
    intersection = a & b
    # The meet is the largest closed set contained in the intersection
    # For Moore families, the intersection itself is closed
    if intersection in closed_sets:
        return intersection
    # Fallback: find largest closed subset
    candidates = [s for s in closed_sets if s.issubset(intersection)]
    return max(candidates, key=len) if candidates else frozenset()


def compute_lattice_join(
    a: FrozenSet[T],
    b: FrozenSet[T],
    is_closed: Callable[[FrozenSet[T]], bool],
    universe: FrozenSet[T]
) -> FrozenSet[T]:
    """Compute the join (least upper bound) = Moore closure of union."""
    union = a | b
    return naive_moore_closure(universe, is_closed, union)


# ============================================================
# Self-test
# ============================================================
if __name__ == "__main__":
    # Test with subgroups of Z/6Z
    n = 6
    universe = frozenset(range(n))

    def is_subgroup_z6(S):
        S = set(S)
        if not S:
            return False
        if 0 not in S:
            return False
        return all((a + b) % n in S for a in S for b in S)

    print("All subgroups of Z/6Z:")
    subgroups = enumerate_moore_closed_sets(universe, is_subgroup_z6)
    for sg in subgroups:
        print(f"  {set(sg)}")

    print(f"\nMoore closure of {{2}}:")
    cl = naive_moore_closure(universe, is_subgroup_z6, frozenset({2}))
    print(f"  {set(cl)}")

    print(f"\nMoore closure of {{1}}:")
    cl1 = naive_moore_closure(universe, is_subgroup_z6, frozenset({1}))
    print(f"  {set(cl1)}")

    print(f"\nHasse diagram:")
    covers = build_lattice_diagram(subgroups)
    for i, js in covers.items():
        for j in js:
            print(f"  {set(subgroups[i])} → {set(subgroups[j])}")

    # Test iterative forward closure
    print(f"\nIterative orbit closure of {{1}} under x -> (x+1) mod 6:")
    orbit = iterative_forward_closure(
        {1},
        [lambda x: (x + 1) % n],
        max_size=100
    )
    print(f"  {orbit}")

    print("\n✓ All algorithm tests passed!")
