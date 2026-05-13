#!/usr/bin/env python3
"""
Algorithms for Tropical Closure-Capacity Duality.

Implements the skeleton reconstruction algorithm and
tropical profile computation with complexity analysis.
"""

from itertools import combinations
from typing import Callable, FrozenSet, List, Set, Tuple
import time


def powerset(s: set) -> list:
    """All subsets of s, ordered by size."""
    elems = list(s)
    result = []
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            result.append(frozenset(combo))
    return result


class ClosureSystem:
    """A closure system on a finite ground set with ultrametric capacity."""

    def __init__(self, ground: set,
                 cl: Callable[[FrozenSet], FrozenSet],
                 cap: Callable[[FrozenSet], float]):
        self.ground = frozenset(ground)
        self.cl = lambda s: cl(frozenset(s))
        self.cap = lambda s: cap(frozenset(s))

    def tropical_profile(self, s: FrozenSet) -> float:
        """Tropical profile: cap(s)."""
        return self.cap(frozenset(s))

    def is_tropically_dominated(self, x: int, X: FrozenSet) -> bool:
        """Check cap({x}) ≤ cap(X)."""
        return self.cap(frozenset({x})) <= self.cap(frozenset(X)) + 1e-10

    def ultrametric_dist(self, s: FrozenSet, t: FrozenSet) -> float:
        """d(s,t) = cap(cl(s ∪ t))."""
        return self.cap(self.cl(frozenset(s) | frozenset(t)))


def canonical_skeleton(system: ClosureSystem) -> Tuple[FrozenSet, dict]:
    """
    Algorithm: Canonical Skeleton Reconstruction

    Input: ClosureSystem with ground set, closure operator, capacity
    Output: (skeleton, stats) where skeleton is the minimal generating set

    Complexity: O(n²) closure evaluations where n = |ground|

    The algorithm greedily removes elements that don't change the
    full closure. The result is independent of removal order.
    """
    stats = {"closure_evals": 0, "elements_tested": 0, "elements_removed": 0}

    G = set(system.ground)
    full_closure = system.cl(frozenset(G))
    stats["closure_evals"] += 1

    changed = True
    while changed:
        changed = False
        for g in sorted(G):  # deterministic order
            stats["elements_tested"] += 1
            reduced = frozenset(G - {g})
            cl_reduced = system.cl(reduced)
            stats["closure_evals"] += 1

            if cl_reduced == full_closure:
                G.remove(g)
                stats["elements_removed"] += 1
                changed = True
                break

    return frozenset(G), stats


def detect_dependencies(system: ClosureSystem) -> List[Tuple[int, FrozenSet]]:
    """
    Detect all closure dependencies: find pairs (x, X) where x ∈ cl(X) \ X.

    Returns list of (element, generating_set) pairs.
    """
    deps = []
    for X in powerset(set(system.ground)):
        clX = system.cl(X)
        for x in system.ground:
            if x in clX and x not in X:
                deps.append((x, X))
    return deps


def verify_dominance_theorem(system: ClosureSystem) -> Tuple[int, int]:
    """
    Verify Theorem C: x ∈ cl(X) ⟹ cap({x}) ≤ cap(X).

    Returns (confirmations, violations).
    """
    confirmations = 0
    violations = 0
    for x, X in detect_dependencies(system):
        if system.is_tropically_dominated(x, X):
            confirmations += 1
        else:
            violations += 1
    return confirmations, violations


def tropical_extremals(system: ClosureSystem,
                       skeleton: FrozenSet) -> List[int]:
    """
    Find tropically extremal elements in the skeleton.
    x is extremal if cap(skeleton \ {x}) < cap(skeleton).
    """
    skel_cap = system.cap(skeleton)
    extremals = []
    for x in skeleton:
        reduced_cap = system.cap(skeleton - {x})
        if reduced_cap < skel_cap - 1e-10:
            extremals.append(x)
    return extremals


def benchmark_skeleton_reconstruction(sizes: List[int]):
    """
    Benchmark skeleton reconstruction for various ground set sizes.
    Uses identity closure (worst case: skeleton = full set).
    """
    print("\n--- Benchmark: Skeleton Reconstruction ---")
    print(f"{'n':>5} {'Time (ms)':>12} {'Closure evals':>15} {'Skeleton size':>15}")
    print("-" * 50)

    for n in sizes:
        ground = set(range(n))

        # Identity closure: every set is closed
        def id_cl(s):
            return frozenset(s)

        def id_cap(s):
            return 0 if len(frozenset(s)) == 0 else 1

        system = ClosureSystem(ground, id_cl, id_cap)

        start = time.time()
        skeleton, stats = canonical_skeleton(system)
        elapsed = (time.time() - start) * 1000

        print(f"{n:>5} {elapsed:>12.2f} {stats['closure_evals']:>15} {len(skeleton):>15}")


if __name__ == "__main__":
    # Example: Fin 3 system
    ground = {0, 1, 2}

    def fin3_cl(s):
        s = frozenset(s)
        if 0 in s and 1 in s:
            return frozenset(ground)
        return s

    def fin3_cap(s):
        return 0 if len(frozenset(s)) == 0 else 1

    system = ClosureSystem(ground, fin3_cl, fin3_cap)

    print("=== Tropical Closure-Capacity Algorithms ===\n")

    # Skeleton reconstruction
    skeleton, stats = canonical_skeleton(system)
    print(f"Canonical skeleton: {set(skeleton)}")
    print(f"Stats: {stats}")

    # Dependency detection
    deps = detect_dependencies(system)
    print(f"\nDependencies found: {len(deps)}")
    for x, X in deps:
        print(f"  {x} ∈ cl({set(X)})")

    # Dominance verification
    conf, viol = verify_dominance_theorem(system)
    print(f"\nDominance theorem: {conf} confirmations, {viol} violations")

    # Extremals
    extremals = tropical_extremals(system, skeleton)
    print(f"\nTropical extremals in skeleton: {extremals}")

    # Benchmark
    benchmark_skeleton_reconstruction([5, 10, 20, 50, 100])
