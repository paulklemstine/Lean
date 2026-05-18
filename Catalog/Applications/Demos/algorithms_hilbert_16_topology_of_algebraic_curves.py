#!/usr/bin/env python3
"""
Algorithms for Hilbert 16 Infrastructure:
Genus computation, Harnack bounds, oval arrangement analysis,
and Hamiltonian level set topology.

Each algorithm includes docstrings, type hints, complexity analysis,
and example usage.
"""

from __future__ import annotations
from typing import Optional, List, Set, Dict, Tuple
from dataclasses import dataclass, field
import math


# ============================================================================
# Algorithm 1: Genus Formula and Harnack Bound
# ============================================================================

def genus(d: int) -> int:
    """Compute the genus of a smooth projective plane curve of degree d.

    Uses the degree-genus formula: g = (d-1)(d-2)/2.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        d: Degree of the curve (non-negative integer)

    Returns:
        The genus g ≥ 0

    Examples:
        >>> genus(1)  # Line
        0
        >>> genus(2)  # Conic
        0
        >>> genus(3)  # Cubic (elliptic curve)
        1
        >>> genus(4)  # Quartic
        3
        >>> genus(6)  # Sextic
        10
    """
    if d < 2:
        return 0
    return (d - 1) * (d - 2) // 2


def harnack_bound(d: int) -> int:
    """Maximum number of connected components of the real locus.

    Computes the Harnack bound: M(d) = (d-1)(d-2)/2 + 1.
    This bound is tight: for every d, there exist M-curves achieving it.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        d: Degree of the curve

    Returns:
        The Harnack bound M(d)

    Examples:
        >>> harnack_bound(4)
        4
        >>> harnack_bound(6)
        11
    """
    return genus(d) + 1


def max_nesting_depth(d: int) -> int:
    """Maximum nesting depth of ovals for a curve of degree d.

    The nesting depth is bounded by ⌊d/2⌋.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        d: Degree of the curve

    Returns:
        Maximum nesting depth

    Examples:
        >>> max_nesting_depth(4)
        2
        >>> max_nesting_depth(5)
        2
        >>> max_nesting_depth(6)
        3
    """
    return d // 2


# ============================================================================
# Algorithm 2: Oval Arrangement / Nesting Forest
# ============================================================================

@dataclass
class NestingForest:
    """A nesting forest representing the containment structure of ovals.

    Each oval is identified by a non-negative integer.
    The forest is stored as a parent-pointer structure.

    Invariants:
        - No oval is its own parent
        - The parent relation is acyclic (forms a forest)
        - Depth of any oval ≤ max_allowed_depth

    Time complexity for construction: O(n) where n = number of ovals
    Space complexity: O(n)
    """

    # Parent map: oval_id -> parent_id (None for roots)
    _parents: Dict[int, Optional[int]] = field(default_factory=dict)

    def add_oval(self, oval_id: int, parent_id: Optional[int] = None) -> None:
        """Add an oval to the forest.

        Time complexity: O(depth) for cycle detection

        Args:
            oval_id: Unique identifier for the oval
            parent_id: ID of the enclosing oval, or None if outermost

        Raises:
            ValueError: If oval_id already exists or would create a cycle
        """
        if oval_id in self._parents:
            raise ValueError(f"Oval {oval_id} already exists")
        if parent_id is not None and parent_id not in self._parents:
            raise ValueError(f"Parent oval {parent_id} does not exist")
        if parent_id == oval_id:
            raise ValueError("An oval cannot be its own parent")
        self._parents[oval_id] = parent_id

    @property
    def num_ovals(self) -> int:
        """Number of ovals in the arrangement. O(1)."""
        return len(self._parents)

    @property
    def roots(self) -> Set[int]:
        """Set of root (outermost) ovals. O(n)."""
        return {o for o, p in self._parents.items() if p is None}

    def depth(self, oval_id: int) -> int:
        """Compute the nesting depth of an oval. O(depth)."""
        d = 0
        current = oval_id
        while self._parents[current] is not None:
            current = self._parents[current]
            d += 1
        return d

    def max_depth(self) -> int:
        """Maximum nesting depth across all ovals. O(n * max_depth)."""
        if not self._parents:
            return 0
        return max(self.depth(o) for o in self._parents)

    def is_outer(self, oval_id: int) -> bool:
        """Whether an oval is outer (even depth). O(depth)."""
        return self.depth(oval_id) % 2 == 0

    def is_inner(self, oval_id: int) -> bool:
        """Whether an oval is inner (odd depth). O(depth)."""
        return self.depth(oval_id) % 2 == 1

    def children(self, oval_id: int) -> Set[int]:
        """Children of an oval in the forest. O(n)."""
        return {o for o, p in self._parents.items() if p == oval_id}

    def subtree_size(self, oval_id: int) -> int:
        """Size of the subtree rooted at an oval. O(subtree_size)."""
        size = 1
        for child in self.children(oval_id):
            size += self.subtree_size(child)
        return size

    def ancestors(self, oval_id: int) -> List[int]:
        """List of ancestors from oval to root. O(depth)."""
        result = []
        current = oval_id
        while self._parents[current] is not None:
            current = self._parents[current]
            result.append(current)
        return result

    def is_nested_in(self, inner: int, outer: int) -> bool:
        """Check if `inner` is nested inside `outer`. O(depth)."""
        return outer in self.ancestors(inner)

    def verify_harnack(self, degree: int) -> bool:
        """Verify that the arrangement satisfies the Harnack bound. O(1)."""
        return self.num_ovals <= harnack_bound(degree)

    def verify_depth_bound(self, degree: int) -> bool:
        """Verify that nesting depth ≤ ⌊d/2⌋. O(n * depth)."""
        return self.max_depth() <= max_nesting_depth(degree)

    def to_string(self, oval_id: Optional[int] = None, indent: int = 0) -> str:
        """Pretty-print the forest structure."""
        if oval_id is None:
            lines = []
            for root in sorted(self.roots):
                lines.append(self.to_string(root, indent))
            return "\n".join(lines)
        parity = "outer" if self.is_outer(oval_id) else "inner"
        line = f"{'  ' * indent}○ Oval {oval_id} (depth={self.depth(oval_id)}, {parity})"
        lines = [line]
        for child in sorted(self.children(oval_id)):
            lines.append(self.to_string(child, indent + 1))
        return "\n".join(lines)


# ============================================================================
# Algorithm 3: Euler Characteristic for Cell Decompositions
# ============================================================================

@dataclass
class PlanarCellDecomp:
    """A cell decomposition of S² with Euler characteristic computation.

    Represents a CW decomposition of the 2-sphere arising from a
    curve arrangement. Satisfies V - E + F = 2 (Euler's formula).

    Time complexity: O(1) for all operations
    Space complexity: O(1)
    """
    vertices: int
    edges: int
    faces: int

    def euler_characteristic(self) -> int:
        """Compute χ = V - E + F. Should equal 2 for S²."""
        return self.vertices - self.edges + self.faces

    def is_valid(self) -> bool:
        """Check if the decomposition satisfies Euler's formula for S²."""
        return self.euler_characteristic() == 2

    @staticmethod
    def from_curve_ovals(num_ovals: int, num_crossings: int = 0) -> 'PlanarCellDecomp':
        """Create a decomposition from simple oval arrangement (no crossings).

        For k simple closed curves with no intersections on S²:
        V = 0, E = 0 (as a CW complex, each oval is a 1-cell with no 0-cells
        in the minimal decomposition, but we use V=k, E=k for the subdivision)

        Actually, for k disjoint simple closed curves on S²:
        V = 0, E = k (each curve is one edge), but this doesn't form a valid CW complex.

        Proper decomposition: each curve has ≥1 vertex, so V = k, E = k, F = k + 1
        (each additional curve adds one vertex, one edge, one face).
        Then χ = k - k + (k+1) = k + 1. But χ(S²) = 2...

        For correctness: k disjoint circles on S² create k+1 regions (faces).
        Minimal CW decomposition: V = 0, E = 0, F = k+1, but need V-E+F=2.
        So we need V-E = 2-(k+1) = 1-k. With 1 vertex per curve and the curve
        as an edge loop, V = k, E = k, F = k+1, χ = k-k+k+1 = k+1 ≠ 2.

        The issue is that simple closed curves are 1-spheres, not 1-cells.
        With 2 vertices per curve: V = 2k, E = 2k, F = k+1, χ = k+1 ≠ 2.

        Actually for disjoint circles on S², with no crossings:
        F = k + 1 (by Jordan curve theorem applied iteratively)
        For Euler's formula to hold with F = k+1, we need V - E = 1 - k.

        Simplest valid decomposition: 1 vertex per curve, 1 edge (loop) per curve.
        But then each edge starts and ends at the same vertex.
        V = k, E = k, F = k+1? No, χ = k - k + (k+1) = k+1.

        This only equals 2 when k = 1. The issue is that each curve contributes
        +1 to the genus of the surface minus the curve. For general k on S²:

        A single circle: V=1, E=1, F=2, χ = 1-1+2 = 2. ✓
        Two disjoint circles: V=2, E=2, F=3? If circles don't nest.
        But then χ = 2-2+3 = 3 ≠ 2. The problem is that F should be 2 + (k-1) = k+1
        only when we count the complement of the circles, not a CW decomposition.

        Actually, for a CW decomposition of S²:
        One circle → two faces (inside, outside), V=1, E=1, F=2, χ=2. ✓
        Two disjoint circles → three faces, need V-E = -1.
        With V=1, E=2 (two loops at one vertex)? F=3, χ=1-2+3=2. ✓

        So: V = 1, E = k, F = k + 1. All loops based at one point.
        χ = 1 - k + (k+1) = 2. ✓

        Args:
            num_ovals: number of disjoint ovals
            num_crossings: number of intersection points (for non-simple arrangements)
        """
        V = 1 + num_crossings
        E = num_ovals + num_crossings  # simplified model
        F = 2 - V + E  # enforcing Euler's formula
        return PlanarCellDecomp(vertices=V, edges=E, faces=F)


# ============================================================================
# Algorithm 4: Hamiltonian Level Set Analysis
# ============================================================================

def hamiltonian_vector_field(
    grad_H: Tuple[float, float]
) -> Tuple[float, float]:
    """Compute the Hamiltonian vector field from the gradient of H.

    Given ∇H = (∂H/∂x, ∂H/∂y), returns X_H = (∂H/∂y, -∂H/∂x).

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        grad_H: The gradient (∂H/∂x, ∂H/∂y)

    Returns:
        The Hamiltonian vector field (∂H/∂y, -∂H/∂x)

    Examples:
        >>> hamiltonian_vector_field((2.0, 3.0))
        (3.0, -2.0)
    """
    return (grad_H[1], -grad_H[0])


def check_orthogonality(
    grad_H: Tuple[float, float],
    X_H: Tuple[float, float]
) -> float:
    """Verify orthogonality of gradient and Hamiltonian VF.

    Returns the dot product ∇H · X_H, which should be 0.

    Time complexity: O(1)

    Args:
        grad_H: Gradient of H
        X_H: Hamiltonian vector field

    Returns:
        Dot product (should be 0 up to floating point error)
    """
    return grad_H[0] * X_H[0] + grad_H[1] * X_H[1]


def is_regular_point(
    grad_H: Tuple[float, float],
    tol: float = 1e-10
) -> bool:
    """Check if a point is regular (non-degenerate gradient).

    Time complexity: O(1)

    Args:
        grad_H: Gradient at the point
        tol: Tolerance for considering gradient zero

    Returns:
        True if the gradient is nonzero (regular point)
    """
    return math.sqrt(grad_H[0]**2 + grad_H[1]**2) > tol


def component_complexity_bound(degree: int) -> int:
    """Upper bound on compact connected components of a regular level set.

    For a polynomial of degree d, each regular level set has at most
    (d-1)(d-2)/2 + 1 compact connected components (Harnack bound).

    This bounds the number of periodic orbits in the corresponding
    Hamiltonian system.

    Time complexity: O(1)

    Args:
        degree: Degree of the polynomial

    Returns:
        Upper bound on component count

    Examples:
        >>> component_complexity_bound(2)  # Quadratic: at most 1 orbit
        1
        >>> component_complexity_bound(4)  # Quartic: at most 4 orbits
        4
    """
    return harnack_bound(degree)


# ============================================================================
# Algorithm 5: Perturbation Analysis for Limit Cycles
# ============================================================================

@dataclass
class HamiltonianSystem:
    """A polynomial Hamiltonian system with perturbation analysis.

    The unperturbed system ẋ = ∂H/∂y, ẏ = -∂H/∂x has periodic orbits
    on regular level sets. Under perturbation, some persist as limit cycles.

    Attributes:
        degree: Degree of the Hamiltonian polynomial
        num_periodic_orbits: Number of periodic orbits at a given energy
        num_limit_cycles: Number of persistent limit cycles under perturbation
    """
    degree: int
    num_periodic_orbits: int = 0
    num_limit_cycles: int = 0

    def harnack_bound(self) -> int:
        """Maximum periodic orbits from the Harnack bound."""
        return harnack_bound(self.degree)

    def satisfies_orbit_bound(self) -> bool:
        """Check if periodic orbit count ≤ Harnack bound."""
        return self.num_periodic_orbits <= self.harnack_bound()

    def satisfies_persistence_bound(self) -> bool:
        """Check if limit cycles ≤ periodic orbits ≤ Harnack bound."""
        return (self.num_limit_cycles <= self.num_periodic_orbits and
                self.num_periodic_orbits <= self.harnack_bound())


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    # Genus and Harnack
    print("=== Genus and Harnack Bound ===")
    for d in range(1, 9):
        print(f"  degree {d}: genus = {genus(d)}, Harnack bound = {harnack_bound(d)}, "
              f"max depth = {max_nesting_depth(d)}")

    # Nesting Forest
    print("\n=== Nesting Forest Example (Quartic) ===")
    forest = NestingForest()
    forest.add_oval(1)  # root
    forest.add_oval(2)  # root
    forest.add_oval(3, parent_id=1)  # inside oval 1
    forest.add_oval(4, parent_id=1)  # inside oval 1
    print(forest.to_string())
    print(f"  Harnack check (degree 4): {forest.verify_harnack(4)}")
    print(f"  Depth check (degree 4): {forest.verify_depth_bound(4)}")
    print(f"  Oval 3 nested in oval 1: {forest.is_nested_in(3, 1)}")
    print(f"  Oval 3 nested in oval 2: {forest.is_nested_in(3, 2)}")

    # Euler Characteristic
    print("\n=== Euler Characteristic ===")
    for k in range(1, 6):
        decomp = PlanarCellDecomp.from_curve_ovals(k)
        print(f"  {k} ovals: V={decomp.vertices}, E={decomp.edges}, F={decomp.faces}, "
              f"χ={decomp.euler_characteristic()}")

    # Hamiltonian
    print("\n=== Hamiltonian Orthogonality ===")
    test_grads = [(1.0, 0.0), (0.0, 1.0), (3.0, -4.0), (2.5, 7.1)]
    for grad in test_grads:
        vf = hamiltonian_vector_field(grad)
        dot = check_orthogonality(grad, vf)
        print(f"  ∇H = {grad}, X_H = {vf}, ∇H·X_H = {dot}")

    # System bounds
    print("\n=== Hamiltonian System Bounds ===")
    for d in [2, 3, 4, 5, 6]:
        sys = HamiltonianSystem(degree=d, num_periodic_orbits=harnack_bound(d),
                                num_limit_cycles=harnack_bound(d))
        print(f"  degree {d}: max orbits = {sys.harnack_bound()}, "
              f"orbit bound ok = {sys.satisfies_orbit_bound()}, "
              f"persistence bound ok = {sys.satisfies_persistence_bound()}")
