#!/usr/bin/env python3
"""
Algorithms for Self-Referential Types and Fixed-Point Hierarchies.

Implements the core mathematical constructions:
1. Lawvere diagonal construction
2. Fixed-point iteration (Knaster-Tarski)
3. Closure operator computation
4. Operator hierarchy construction
"""

from typing import Callable, TypeVar, Optional, Set, FrozenSet
from dataclasses import dataclass
import math

T = TypeVar('T')


# ============================================================
# Algorithm 1: Lawvere Diagonal
# ============================================================

def lawvere_diagonal(
    enum: Callable[[int], Callable[[int], bool]],
    transform: Callable[[bool], bool],
    domain_size: int
) -> Callable[[int], bool]:
    """
    Lawvere's diagonal construction.

    Given an enumeration of functions and a transformation,
    produces a function not in the enumeration.

    Pseudocode:
        LAWVERE-DIAGONAL(enum, f, n):
            define g(i) = f(enum(i)(i)) for i in 0..n-1
            return g

    Args:
        enum: Maps index i to a function A → B
        transform: The endomorphism f : B → B (e.g., negation)
        domain_size: Size of the domain

    Returns:
        A function not in the range of enum
    """
    def diagonal(i: int) -> bool:
        if i < domain_size:
            return transform(enum(i)(i))
        return False
    return diagonal


def verify_diagonal_escape(
    enum: Callable[[int], Callable[[int], bool]],
    diagonal: Callable[[int], bool],
    domain_size: int
) -> bool:
    """Verify the diagonal function differs from every enum(i)."""
    for i in range(domain_size):
        if all(enum(i)(j) == diagonal(j) for j in range(domain_size)):
            return False  # Found a match — shouldn't happen!
    return True


# ============================================================
# Algorithm 2: Knaster-Tarski Fixed Point Iteration
# ============================================================

@dataclass
class FixedPointResult:
    """Result of fixed-point iteration."""
    value: float
    iterations: int
    converged: bool
    trajectory: list[float]


def knaster_tarski_lfp(
    f: Callable[[float], float],
    bottom: float = 0.0,
    epsilon: float = 1e-10,
    max_iter: int = 10000
) -> FixedPointResult:
    """
    Compute the least fixed point of a monotone function on [0, ∞)
    by iterating from bottom.

    Pseudocode:
        KNASTER-TARSKI-LFP(f, ⊥, ε):
            x ← ⊥
            trajectory ← [x]
            while |f(x) - x| > ε:
                x ← f(x)
                trajectory.append(x)
            return x, trajectory

    Args:
        f: Monotone function (assumed, not checked)
        bottom: Starting point (should be ≤ lfp)
        epsilon: Convergence threshold
        max_iter: Maximum iterations

    Returns:
        FixedPointResult with the approximation
    """
    x = bottom
    trajectory = [x]

    for i in range(max_iter):
        x_new = f(x)
        trajectory.append(x_new)
        if abs(x_new - x) < epsilon:
            return FixedPointResult(x_new, i + 1, True, trajectory)
        x = x_new

    return FixedPointResult(x, max_iter, False, trajectory)


def knaster_tarski_gfp(
    f: Callable[[float], float],
    top: float = 1.0,
    epsilon: float = 1e-10,
    max_iter: int = 10000
) -> FixedPointResult:
    """
    Compute the greatest fixed point by iterating from top.

    Pseudocode:
        KNASTER-TARSKI-GFP(f, ⊤, ε):
            x ← ⊤
            while |f(x) - x| > ε:
                x ← f(x)
            return x
    """
    x = top
    trajectory = [x]

    for i in range(max_iter):
        x_new = f(x)
        trajectory.append(x_new)
        if abs(x_new - x) < epsilon:
            return FixedPointResult(x_new, i + 1, True, trajectory)
        x = x_new

    return FixedPointResult(x, max_iter, False, trajectory)


# ============================================================
# Algorithm 3: Closure Operator on Finite Power Sets
# ============================================================

def closure_from_galois(
    relation: dict[int, Set[str]],
    objects: Set[int],
    properties: Set[str]
) -> Callable[[FrozenSet[int]], FrozenSet[int]]:
    """
    Build a closure operator from a Galois connection defined by a relation.

    Pseudocode:
        GALOIS-CLOSURE(R, S):
            T ← ∩{R[i] : i ∈ S}       (common properties)
            return {j : T ⊆ R[j]}       (objects with all common properties)

    Args:
        relation: Maps each object to its set of properties
        objects: The set of all objects
        properties: The set of all properties

    Returns:
        The closure operator u ∘ l
    """
    def lower(S: FrozenSet[int]) -> FrozenSet[str]:
        if not S:
            return frozenset(properties)
        return frozenset.intersection(*(frozenset(relation[i]) for i in S))

    def upper(T: FrozenSet[str]) -> FrozenSet[int]:
        return frozenset(i for i in objects if T <= frozenset(relation[i]))

    def closure(S: FrozenSet[int]) -> FrozenSet[int]:
        return upper(lower(S))

    return closure


def find_all_closed_sets(
    closure: Callable[[FrozenSet[int]], FrozenSet[int]],
    universe: Set[int]
) -> list[FrozenSet[int]]:
    """
    Find all closed sets (fixed points of the closure operator).

    Pseudocode:
        FIND-CLOSED-SETS(cl, U):
            closed ← []
            for S ⊆ U:
                if cl(S) = S:
                    closed.append(S)
            return closed
    """
    n = len(universe)
    elements = sorted(universe)
    closed = []

    for mask in range(2**n):
        S = frozenset(elements[i] for i in range(n) if mask & (1 << i))
        if closure(S) == S:
            closed.append(S)

    return closed


# ============================================================
# Algorithm 4: Operator Hierarchy
# ============================================================

@dataclass
class HierarchyLevel:
    """One level of the fixed-point hierarchy."""
    level: int
    lfp: float
    gfp: float
    num_fixed_points_approx: int


def build_operator_hierarchy(
    operator_family: Callable[[int], Callable[[float], float]],
    num_levels: int,
    search_points: int = 1000
) -> list[HierarchyLevel]:
    """
    Build an operator hierarchy and analyze each level.

    Pseudocode:
        BUILD-HIERARCHY(Φ, N):
            for n = 0 to N-1:
                compute lfp(Φ_n) by iteration from 0
                compute gfp(Φ_n) by iteration from 1
                count approximate fixed points in [0,1]
            return hierarchy

    Args:
        operator_family: Maps level n to monotone operator Φ_n
        num_levels: Number of levels to compute
        search_points: Resolution for fixed-point counting

    Returns:
        List of HierarchyLevel descriptions
    """
    hierarchy = []

    for n in range(num_levels):
        phi = operator_family(n)

        lfp_result = knaster_tarski_lfp(phi)
        gfp_result = knaster_tarski_gfp(phi)

        # Count approximate fixed points
        count = 0
        for k in range(search_points + 1):
            x = k / search_points
            if abs(phi(x) - x) < 1e-6:
                count += 1

        hierarchy.append(HierarchyLevel(
            level=n,
            lfp=lfp_result.value,
            gfp=gfp_result.value,
            num_fixed_points_approx=max(1, count // 5)  # cluster
        ))

    return hierarchy


# ============================================================
# Algorithm 5: Self-Referential Complexity Bound
# ============================================================

def diagonal_separation(
    enum: list[Set[int]],
    universe_size: int
) -> Set[int]:
    """
    Construct a set not in the enumeration via diagonalization.

    Pseudocode:
        DIAGONAL-SEPARATE(enum, n):
            return {i ∈ [n] : i ∉ enum[i]}

    This always produces a set different from every enum[i].
    """
    return {i for i in range(min(len(enum), universe_size)) if i not in enum[i]}


def verify_separation(enum: list[Set[int]], escaped: Set[int]) -> bool:
    """Verify the escaped set differs from all enumerated sets."""
    return all(enum[i] != escaped for i in range(len(enum)))


if __name__ == "__main__":
    # Demo: Lawvere diagonal
    print("=== Lawvere Diagonal ===")
    matrix = [[True, False, True], [False, True, False], [True, True, True]]
    enum = lambda i: lambda j: matrix[i][j]
    diag = lawvere_diagonal(enum, lambda b: not b, 3)
    print(f"Diagonal: {[diag(i) for i in range(3)]}")
    print(f"Escapes: {verify_diagonal_escape(enum, diag, 3)}")

    # Demo: Knaster-Tarski
    print("\n=== Knaster-Tarski LFP ===")
    result = knaster_tarski_lfp(lambda x: math.sqrt(x), bottom=0.5)
    print(f"lfp(sqrt) from 0.5: {result.value:.8f} in {result.iterations} iterations")

    result = knaster_tarski_gfp(lambda x: math.sqrt(x), top=2.0)
    print(f"gfp(sqrt) from 2.0: {result.value:.8f} in {result.iterations} iterations")

    # Demo: Hierarchy
    print("\n=== Operator Hierarchy ===")
    hierarchy = build_operator_hierarchy(
        lambda n: lambda x: x ** (1.0 / (n + 2)),
        num_levels=5
    )
    for level in hierarchy:
        print(f"  Level {level.level}: lfp={level.lfp:.6f}, gfp={level.gfp:.6f}, "
              f"~{level.num_fixed_points_approx} fixed points")
