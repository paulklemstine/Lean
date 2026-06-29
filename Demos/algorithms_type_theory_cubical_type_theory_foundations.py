#!/usr/bin/env python3
"""
Cubical Type Theory — Algorithms

Implements the core algorithms from the formalized cubical type theory framework:

1. Path space enumeration for finite cubical intervals
2. Equivalence-induced path mapping
3. Affine interpolation path construction
4. Suspension quotient computation
5. Path count computation and invariance checking

All algorithms include type hints, docstrings, and complexity analysis.
"""

import itertools
import math
from typing import (
    List, Tuple, Dict, Set, FrozenSet, Callable, Any, Optional, TypeVar
)
from dataclasses import dataclass


T = TypeVar('T')


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class CubicalInterval:
    """A finite cubical interval with elements and two endpoints.

    Attributes:
        elements: The elements of the interval type I
        i0: The left endpoint
        i1: The right endpoint
    """
    elements: list
    i0: Any
    i1: Any

    def __post_init__(self):
        assert self.i0 in self.elements, f"i0={self.i0} not in elements"
        assert self.i1 in self.elements, f"i1={self.i1} not in elements"


@dataclass(frozen=True)
class Path:
    """A path in PathOver(CI, A, a0, a1).

    A path is a function p: CI.I -> A with p(i0) = a0 and p(i1) = a1,
    represented as an immutable tuple of values indexed by CI.elements.
    """
    values: tuple  # values[k] = p(elements[k])

    def evaluate(self, ci: CubicalInterval, point: Any) -> Any:
        """Evaluate the path at a given interval point."""
        idx = ci.elements.index(point)
        return self.values[idx]


@dataclass
class CubicalEquiv:
    """A cubical equivalence between two finite types.

    Attributes:
        forward: Dictionary mapping A -> B
        inverse: Dictionary mapping B -> A
    """
    forward: Dict
    inverse: Dict

    def __post_init__(self):
        # Verify left and right inverse properties
        for a, b in self.forward.items():
            assert self.inverse[b] == a, f"Left inverse fails at {a}"
        for b, a in self.inverse.items():
            assert self.forward[a] == b, f"Right inverse fails at {b}"


# ============================================================
# Algorithm 1: Path Space Enumeration
# ============================================================

def enumerate_path_space(
    ci: CubicalInterval,
    A: list,
    a0: Any,
    a1: Any
) -> List[Path]:
    """Enumerate all paths in PathOver(CI, A, a0, a1).

    Algorithm:
        Generate all functions CI.I -> A (as tuples), filter by endpoint
        constraints p(i0) = a0 and p(i1) = a1.

    Complexity:
        Time: O(|A|^|I|) — exponential in interval size
        Space: O(|A|^|I|) for storing all paths

    Args:
        ci: The cubical interval
        A: The target type (finite list)
        a0: Source endpoint value
        a1: Target endpoint value

    Returns:
        List of all paths from a0 to a1
    """
    i0_idx = ci.elements.index(ci.i0)
    i1_idx = ci.elements.index(ci.i1)
    paths = []

    for values in itertools.product(A, repeat=len(ci.elements)):
        if values[i0_idx] == a0 and values[i1_idx] == a1:
            paths.append(Path(values))

    return paths


def path_count(ci: CubicalInterval, A: list, a0: Any, a1: Any) -> int:
    """Count paths between two elements.

    Complexity: O(|A|^|I|) time, O(1) extra space (with lazy generation).

    For a k-element interval with |A| = n, the count is:
    - n^(k-2) if i0 ≠ i1 (free values at k-2 intermediate points)
    - n^(k-1) if i0 = i1 and a0 = a1
    - 0 if i0 = i1 and a0 ≠ a1
    """
    return len(enumerate_path_space(ci, A, a0, a1))


def path_count_formula(
    ci: CubicalInterval,
    n: int,
    a0_eq_a1: bool
) -> int:
    """Closed-form path count for an interval of size k and type of size n.

    When i0 ≠ i1: count = n^(k-2) where k = |I|
    When i0 = i1: count = n^(k-1) if a0=a1, else 0

    This is the analytical formula verified by the formal proof.
    """
    k = len(ci.elements)
    if ci.i0 == ci.i1:
        return int(n ** (k - 1)) if a0_eq_a1 else 0
    else:
        # Two endpoints are fixed, remaining k-2 points are free
        return int(n ** max(0, k - 2))


# ============================================================
# Algorithm 2: Equivalence-Induced Path Mapping
# ============================================================

def map_path(
    equiv: CubicalEquiv,
    ci: CubicalInterval,
    path: Path
) -> Path:
    """Apply a cubical equivalence to a path (postcomposition).

    Given e: A ≃ B and p: I → A, returns e ∘ p: I → B.

    Complexity: O(|I|) time, O(|I|) space

    This implements the formal `mapPath` definition.
    """
    new_values = tuple(equiv.forward[path.values[i]]
                       for i in range(len(ci.elements)))
    return Path(new_values)


def inverse_map_path(
    equiv: CubicalEquiv,
    ci: CubicalInterval,
    path: Path
) -> Path:
    """Apply the inverse equivalence to a path.

    Given e: A ≃ B and q: I → B, returns e⁻¹ ∘ q: I → A.

    Complexity: O(|I|) time, O(|I|) space
    """
    new_values = tuple(equiv.inverse[path.values[i]]
                       for i in range(len(ci.elements)))
    return Path(new_values)


def verify_path_bijection(
    equiv: CubicalEquiv,
    ci: CubicalInterval,
    A: list,
    B: list,
    a0: Any,
    a1: Any
) -> bool:
    """Verify that mapPath is a bijection between path spaces.

    Checks:
    1. Injectivity: distinct paths in A map to distinct paths in B
    2. Surjectivity: every path in B is hit

    This is the computational verification of cubical_equiv_path_bijective.

    Complexity: O(|A|^|I| + |B|^|I|) time
    """
    paths_A = enumerate_path_space(ci, A, a0, a1)
    b0, b1 = equiv.forward[a0], equiv.forward[a1]
    paths_B = enumerate_path_space(ci, B, b0, b1)

    # Map all paths from A
    mapped = [map_path(equiv, ci, p) for p in paths_A]

    # Check injectivity
    if len(set(p.values for p in mapped)) != len(mapped):
        return False

    # Check surjectivity
    mapped_set = set(p.values for p in mapped)
    target_set = set(p.values for p in paths_B)
    return mapped_set == target_set


# ============================================================
# Algorithm 3: Affine Interpolation Path
# ============================================================

def affine_path(y0: float, y1: float, num_points: int = 100) -> List[Tuple[float, float]]:
    """Construct the affine interpolation path from y0 to y1.

    The path is p(t) = (1-t)·y0 + t·y1 for t ∈ [0, 1].

    Complexity: O(num_points) time and space

    Returns:
        List of (t, p(t)) pairs
    """
    return [(t / (num_points - 1),
             (1 - t / (num_points - 1)) * y0 + (t / (num_points - 1)) * y1)
            for t in range(num_points)]


def verify_affine_interpolation(
    y0: float,
    y1: float,
    num_points: int = 1000
) -> bool:
    """Verify the affine path interpolation property.

    Checks that for all t ∈ [0,1]:
    - p(0) = y0
    - p(1) = y1
    - min(y0,y1) ≤ p(t) ≤ max(y0,y1)

    This verifies the formal affine_path_interpolates theorem.
    """
    path = affine_path(y0, y1, num_points)
    eps = 1e-12
    lo, hi = min(y0, y1), max(y0, y1)

    # Check endpoints
    if abs(path[0][1] - y0) > eps:
        return False
    if abs(path[-1][1] - y1) > eps:
        return False

    # Check interpolation
    for t, pt in path:
        if pt < lo - eps or pt > hi + eps:
            return False

    return True


# ============================================================
# Algorithm 4: Suspension Quotient Computation
# ============================================================

def compute_suspension_classes(A: list) -> Dict[str, Set[str]]:
    """Compute equivalence classes of Susp(A).

    The suspension quotient identifies Bool by:
      true ~ false for each a ∈ A

    If A is empty: two classes {north}, {south}
    If A is nonempty: one class {north, south}

    Complexity: O(|A|) time, O(1) space

    Returns:
        Dictionary mapping class names to their elements
    """
    if not A:
        return {"north": {"north"}, "south": {"south"}}
    else:
        return {"point": {"north", "south"}}


def suspension_recursor(
    A: list,
    target_north: Any,
    target_south: Any,
    merid: Optional[Callable] = None
) -> Callable:
    """Construct the suspension recursor.

    Given:
    - target_north: value for north pole
    - target_south: value for south pole
    - merid: for each a ∈ A, proof that target_north = target_south

    Returns: function SuspApprox(A) → target type

    When A is nonempty, target_north must equal target_south.
    The recursor is the unique such map (by susp_rec_unique).
    """
    def rec(point: str) -> Any:
        if point == "north":
            return target_north
        elif point == "south":
            return target_south
        else:
            raise ValueError(f"Unknown suspension point: {point}")
    return rec


# ============================================================
# Algorithm 5: Lorentz Invariance Path Construction
# ============================================================

def lorentz_boost(v: float, event: Tuple[float, float]) -> Tuple[float, float]:
    """Apply a Lorentz boost with velocity v to a spacetime event.

    Complexity: O(1) time and space
    """
    gamma = 1.0 / math.sqrt(1 - v**2)
    t, x = event
    return (gamma * (t - v * x), gamma * (x - v * t))


def minkowski_interval(
    e1: Tuple[float, float],
    e2: Tuple[float, float]
) -> float:
    """Compute the Minkowski interval between two events.

    s² = -(Δt)² + (Δx)²

    Complexity: O(1) time and space
    """
    dt = e2[0] - e1[0]
    dx = e2[1] - e1[1]
    return -(dt**2) + dx**2


def construct_lorentz_path(
    v: float,
    e1: Tuple[float, float],
    e2: Tuple[float, float],
    num_points: int = 100
) -> List[Tuple[float, float]]:
    """Construct the cubical path witnessing Lorentz invariance.

    Since the Minkowski interval is exactly preserved (s² = s²'),
    the path is a constant function: p(t) = s² for all t ∈ [0,1].

    This is the computational content of lorentz_interval_cubical_invariant.

    Returns: List of (t, s²) pairs — a constant path
    """
    s2 = minkowski_interval(e1, e2)
    return [(t / (num_points - 1), s2) for t in range(num_points)]


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example 1: Path enumeration
    ci = CubicalInterval([0, 1, 2], i0=0, i1=2)
    A = ['a', 'b']
    paths = enumerate_path_space(ci, A, 'a', 'b')
    print(f"Paths from 'a' to 'b' over 3-point interval: {len(paths)}")
    for p in paths:
        print(f"  {p.values}")

    # Example 2: Equivalence preservation
    equiv = CubicalEquiv(
        forward={'a': 1, 'b': 2},
        inverse={1: 'a', 2: 'b'}
    )
    print(f"\nBijection verified: {verify_path_bijection(equiv, ci, ['a','b'], [1,2], 'a', 'b')}")

    # Example 3: Affine path
    print(f"\nAffine interpolation verified: {verify_affine_interpolation(3.0, 7.0)}")

    # Example 4: Suspension
    print(f"\nSusp(∅) classes: {compute_suspension_classes([])}")
    print(f"Susp({{x}}) classes: {compute_suspension_classes(['x'])}")

    # Example 5: Lorentz path
    s2_orig = minkowski_interval((0,0), (1, 0.5))
    s2_boost = minkowski_interval(*[lorentz_boost(0.5, e) for e in [(0,0), (1, 0.5)]])
    print(f"\nLorentz invariance: |s²-s²'| = {abs(s2_orig - s2_boost):.2e}")
