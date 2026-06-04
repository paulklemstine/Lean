#!/usr/bin/env python3
"""
Algorithms for Invariant Spectrum Theory

Type-hinted implementations of the core algorithms from the research.
"""

from typing import TypeVar, Generic, Callable, List, Tuple, Optional, Set, Dict
from dataclasses import dataclass, field

T = TypeVar('T')
V = TypeVar('V')


@dataclass
class EquivalenceRelation(Generic[T]):
    """An equivalence relation on a finite type."""
    elements: List[T]
    is_equiv: Callable[[T, T], bool]


@dataclass
class GradedInvariant(Generic[T]):
    """A graded invariant system (Invariant Spectrum) on a finite type."""
    relation: EquivalenceRelation[T]
    levels: List[Callable[[T], object]]

    @property
    def max_level(self) -> int:
        return len(self.levels) - 1


def compute_confusion_set(
    spec: GradedInvariant[T],
    level: int
) -> Set[Tuple[int, int]]:
    """
    Compute the confusion set at a given level.

    Returns set of index pairs (i, j) with i < j where elements[i] and
    elements[j] are confused (same invariant values up to level, but not equivalent).

    Time complexity: O(n² * level) where n = |elements|.
    """
    elems = spec.relation.elements
    confused: Set[Tuple[int, int]] = set()
    for i in range(len(elems)):
        for j in range(i + 1, len(elems)):
            x, y = elems[i], elems[j]
            if all(spec.levels[k](x) == spec.levels[k](y) for k in range(level + 1)):
                if not spec.relation.is_equiv(x, y):
                    confused.add((i, j))
    return confused


def compute_confusion_count(spec: GradedInvariant[T], level: int) -> int:
    """Compute |confusion set| at a given level."""
    return len(compute_confusion_set(spec, level))


def compute_essential_dimension(spec: GradedInvariant[T]) -> Optional[int]:
    """
    Compute the essential dimension of a graded invariant system.

    Returns the minimum level n such that levels 0..n together form a
    complete invariant, or None if no such level exists within the
    available levels.

    Algorithm:
    1. For n = 0, 1, 2, ..., max_level:
    2.   Compute confusion count at level n
    3.   If confusion count = 0, return n
    4. Return None

    Time complexity: O(n² * L²) where n = |elements|, L = number of levels.
    Optimal by the monotone decrease property: we can stop at the first zero.
    """
    for n in range(spec.max_level + 1):
        if compute_confusion_count(spec, n) == 0:
            return n
    return None


def check_asphericity(spec: GradedInvariant[T]) -> bool:
    """
    Check if a spectrum is aspherical (K(G,1) condition).

    A spectrum is aspherical if all invariants at levels > 1 are constant
    (i.e., trivial — they don't distinguish any elements).

    Time complexity: O(n * L) where n = |elements|, L = number of levels.
    """
    elems = spec.relation.elements
    if len(elems) <= 1:
        return True
    for level in range(2, spec.max_level + 1):
        inv = spec.levels[level]
        first_val = inv(elems[0])
        for x in elems[1:]:
            if inv(x) != first_val:
                return False
    return True


def find_higher_dimensional_witness(
    spec: GradedInvariant[T]
) -> Optional[Tuple[T, T, int]]:
    """
    Find a higher-dimensional witness if one exists.

    A higher-dimensional witness is a triple (x, y, n) where:
    - x and y agree at level 1 (same "fundamental group")
    - n > 1 and x, y disagree at level n (different higher invariant)

    This witnesses that level 1 alone is incomplete.

    Time complexity: O(n² * L) where n = |elements|, L = number of levels.
    """
    elems = spec.relation.elements
    if spec.max_level < 2:
        return None
    inv1 = spec.levels[1]
    for i in range(len(elems)):
        for j in range(i + 1, len(elems)):
            x, y = elems[i], elems[j]
            if inv1(x) == inv1(y) and not spec.relation.is_equiv(x, y):
                for n in range(2, spec.max_level + 1):
                    if spec.levels[n](x) != spec.levels[n](y):
                        return (x, y, n)
    return None


def compute_confusion_profile(spec: GradedInvariant[T]) -> List[int]:
    """
    Compute the full confusion count profile [C₀, C₁, ..., C_L].

    By the Monotone Completeness theorem, this sequence is non-increasing.
    The first zero (if any) marks the essential dimension.

    Returns list of confusion counts, one per level.
    """
    return [compute_confusion_count(spec, n) for n in range(spec.max_level + 1)]


def verify_monotone_decrease(profile: List[int]) -> bool:
    """Verify that a confusion profile is monotonically non-increasing."""
    return all(profile[i] >= profile[i + 1] for i in range(len(profile) - 1))


def classify_spectrum(spec: GradedInvariant[T]) -> Dict[str, object]:
    """
    Full classification analysis of an invariant spectrum.

    Returns a dictionary with:
    - profile: confusion count sequence
    - essential_dim: essential dimension (or None)
    - aspherical: whether the spectrum is aspherical
    - witness: higher-dimensional witness (or None)
    - monotone_verified: whether monotone decrease holds
    """
    profile = compute_confusion_profile(spec)
    return {
        'profile': profile,
        'essential_dim': compute_essential_dimension(spec),
        'aspherical': check_asphericity(spec),
        'witness': find_higher_dimensional_witness(spec),
        'monotone_verified': verify_monotone_decrease(profile),
    }


# --- Example usage ---

if __name__ == '__main__':
    # Example: ZMod 8 with three levels of refinement
    rel = EquivalenceRelation(
        elements=list(range(8)),
        is_equiv=lambda x, y: x == y
    )
    spec = GradedInvariant(
        relation=rel,
        levels=[
            lambda x: x % 2,   # Level 0: parity
            lambda x: x % 4,   # Level 1: mod 4
            lambda x: x % 8,   # Level 2: identity (complete)
        ]
    )

    result = classify_spectrum(spec)
    print("ZMod 8 Spectrum Analysis:")
    for key, val in result.items():
        print(f"  {key}: {val}")
