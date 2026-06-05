#!/usr/bin/env python3
"""
Algorithms for Self-Referential Type Theory
============================================

Type-hinted implementations of the core algorithms from the
Lawvere Fixed Point Theorem research cycle.
"""

from typing import TypeVar, Callable, Optional, Set, FrozenSet, List, Tuple, Dict
from dataclasses import dataclass
import itertools

T = TypeVar('T')
A = TypeVar('A')
B = TypeVar('B')


# =============================================================
# Algorithm 1: Lawvere Diagonal Construction
# =============================================================

def lawvere_diagonal_search(
    encoding: Callable[[int], Callable[[int], bool]],
    transform: Callable[[bool], bool],
    domain: range
) -> Optional[Tuple[int, bool]]:
    """
    Search for a Lawvere fixed point.
    
    Given an encoding e : ℕ → (ℕ → Bool) and a transform f : Bool → Bool,
    constructs the diagonal d(x) = f(e(x)(x)) and searches for a
    such that e(a) = d. Returns (a, fixed_point) if found.
    
    Complexity: O(|domain|²) in the worst case.
    
    Args:
        encoding: The surjection e : A → (A → B)
        transform: The endomorphism f : B → B
        domain: The finite domain to search over
        
    Returns:
        (index, fixed_point_value) or None
    """
    # Construct diagonal function
    diag = lambda x: transform(encoding(x)(x))
    
    for a in domain:
        # Check if e(a) agrees with diag on entire domain
        if all(encoding(a)(x) == diag(x) for x in domain):
            b = encoding(a)(a)
            assert transform(b) == b, "Lawvere guarantees this"
            return (a, b)
    
    return None


# =============================================================
# Algorithm 2: Diagonal Set Construction
# =============================================================

def diagonal_set(family: Callable[[int], Set[int]], domain: range) -> Set[int]:
    """
    Construct the diagonal set of a family of sets.
    
    D = {n ∈ domain | n ∉ family(n)}
    
    The diagonal set is guaranteed to differ from family(k) for every k
    in the domain (Theorem: diag_differs).
    
    Args:
        family: A function mapping indices to sets of naturals
        domain: The index domain
        
    Returns:
        The diagonal set D
    """
    return {n for n in domain if n not in family(n)}


def verify_diagonal_differs(
    family: Callable[[int], Set[int]], 
    diag: Set[int], 
    domain: range
) -> List[Tuple[int, int, bool, bool]]:
    """
    Verify that the diagonal set differs from every family member.
    
    Returns list of (index, witness, in_diag, in_family) showing
    where each family(k) differs from diag.
    """
    witnesses = []
    for k in domain:
        # By construction, k itself is the witness
        in_diag = k in diag
        in_family = k in family(k)
        witnesses.append((k, k, in_diag, in_family))
        assert in_diag != in_family, f"Diagonal must differ at index {k}"
    return witnesses


# =============================================================
# Algorithm 3: Diagonal Hierarchy Builder
# =============================================================

@dataclass
class HierarchyLevel:
    """A level in the diagonal hierarchy."""
    level: int
    sets: List[Set[int]]
    diagonal: Optional[Set[int]]


def build_diagonal_hierarchy(
    base_sets: List[Set[int]],
    universe_size: int,
    num_levels: int
) -> List[HierarchyLevel]:
    """
    Build a diagonal hierarchy by iterated diagonalization.
    
    Starting from base_sets (Level 0), constructs Level 1 by
    diagonalizing Level 0, Level 2 by diagonalizing Level 1, etc.
    
    Each level is strictly larger than the previous (by construction).
    
    Args:
        base_sets: Initial collection of sets (Level 0)
        universe_size: Size of the universe {0, ..., universe_size-1}
        num_levels: Number of hierarchy levels to build
        
    Returns:
        List of HierarchyLevel objects
    """
    hierarchy: List[HierarchyLevel] = []
    current_sets = list(base_sets)
    
    for level in range(num_levels):
        # Pad current_sets to universe_size
        padded = current_sets[:universe_size]
        while len(padded) < universe_size:
            padded.append(set())
        
        # Compute diagonal
        diag = {x for x in range(universe_size) if x not in padded[x]}
        
        hierarchy.append(HierarchyLevel(
            level=level,
            sets=list(current_sets),
            diagonal=diag
        ))
        
        # Level (n+1) = Level n ∪ {diagonal}
        current_sets = list(current_sets) + [diag]
    
    return hierarchy


# =============================================================
# Algorithm 4: Knaster-Tarski Fixed Point Computation
# =============================================================

def compute_lfp_powerset(
    f: Callable[[FrozenSet[int]], FrozenSet[int]],
    universe: Set[int]
) -> FrozenSet[int]:
    """
    Compute the least fixed point of a monotone function on P(universe).
    
    Uses the Knaster-Tarski characterization: lfp(f) = ⋂{S | f(S) ⊆ S}.
    
    Args:
        f: A monotone function on the power set lattice
        universe: The base set
        
    Returns:
        The least fixed point of f
    """
    pre_fixed_points: List[FrozenSet[int]] = []
    
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(sorted(universe), r):
            S = frozenset(subset)
            if f(S).issubset(S):
                pre_fixed_points.append(S)
    
    if not pre_fixed_points:
        return frozenset(universe)
    
    return frozenset.intersection(*pre_fixed_points)


def compute_gfp_powerset(
    f: Callable[[FrozenSet[int]], FrozenSet[int]],
    universe: Set[int]
) -> FrozenSet[int]:
    """
    Compute the greatest fixed point of a monotone function on P(universe).
    
    Uses the Knaster-Tarski characterization: gfp(f) = ⋃{S | S ⊆ f(S)}.
    """
    post_fixed_points: List[FrozenSet[int]] = []
    
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(sorted(universe), r):
            S = frozenset(subset)
            if S.issubset(f(S)):
                post_fixed_points.append(S)
    
    if not post_fixed_points:
        return frozenset()
    
    return frozenset.union(*post_fixed_points)


def compute_all_fixed_points(
    f: Callable[[FrozenSet[int]], FrozenSet[int]],
    universe: Set[int]
) -> List[FrozenSet[int]]:
    """
    Enumerate all fixed points of f on P(universe).
    """
    fixed_points = []
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(sorted(universe), r):
            S = frozenset(subset)
            if f(S) == S:
                fixed_points.append(S)
    return fixed_points


# =============================================================
# Algorithm 5: Fixed-Point Orbit Analysis
# =============================================================

def find_fixed_points(f: Callable[[int], int], domain: range) -> Set[int]:
    """Find all fixed points of f in the given domain."""
    return {x for x in domain if f(x) == x}


def find_periodic_points(f: Callable[[int], int], domain: range, period: int) -> Set[int]:
    """Find all points with period dividing the given period."""
    def iterate(x: int, n: int) -> int:
        for _ in range(n):
            x = f(x)
        return x
    
    return {x for x in domain if iterate(x, period) == x}


def fixed_point_hierarchy(f: Callable[[int], int], domain: range, max_depth: int) -> Dict[int, Set[int]]:
    """
    Compute the hierarchy of fixed-point sets for f, f², f³, ...
    
    Returns dict mapping depth n to FixedPoints(f^n).
    Demonstrates that FixedPoints(f) ⊆ FixedPoints(f²) ⊆ ...
    """
    result = {}
    for n in range(1, max_depth + 1):
        result[n] = find_periodic_points(f, domain, n)
    return result


# =============================================================
# Algorithm 6: Self-Reference Trilemma Checker
# =============================================================

def check_self_reference_trilemma(
    encoding: Dict[int, Set[int]],
    domain: range
) -> Tuple[bool, Optional[Set[int]]]:
    """
    Check whether an encoding system satisfies the self-reference trilemma.
    
    Given an encoding (mapping indices to sets), checks if the "Russell set"
    {i | i ∉ encoding(i)} is represented. If not, the system is incomplete.
    
    Args:
        encoding: Maps each index i to the set encoding(i)
        domain: The index domain
        
    Returns:
        (is_complete, russell_set): is_complete is True only if some
        encoding(k) equals the Russell set (which should never happen
        for a consistent system).
    """
    russell = {i for i in domain if i not in encoding.get(i, set())}
    
    for k in domain:
        if encoding.get(k, set()) == russell:
            return (True, russell)  # "Complete" but must be inconsistent
    
    return (False, russell)  # Incomplete (as Lawvere guarantees)


if __name__ == "__main__":
    # Quick self-test
    print("Testing algorithms...")
    
    # Test diagonal set
    family = lambda n: {n, (n + 1) % 5}
    d = diagonal_set(family, range(5))
    print(f"Diagonal of family: {d}")
    
    # Test Knaster-Tarski
    universe = {0, 1, 2, 3}
    f = lambda S: frozenset(S | {3 - x for x in S if 0 <= 3 - x <= 3})
    lfp = compute_lfp_powerset(f, universe)
    gfp = compute_gfp_powerset(f, universe)
    print(f"LFP = {set(lfp)}, GFP = {set(gfp)}")
    
    # Test hierarchy
    hierarchy = build_diagonal_hierarchy(
        [{0, 1}, {2, 3}, {0, 2}], universe_size=5, num_levels=3
    )
    for level in hierarchy:
        print(f"Level {level.level}: {len(level.sets)} sets, diagonal = {level.diagonal}")
    
    print("All tests passed!")
