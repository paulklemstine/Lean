#!/usr/bin/env python3
"""
algorithms.py — Tropical Intersection Theory: Core Algorithms

Implements the algorithms underlying the tropical Bézout theorem:
  - Degree simplex construction and lattice point enumeration
  - Minkowski sum computation for finite lattice point sets
  - Mixed lattice index (mixed area proxy) computation
  - Tropical polynomial evaluation and corner locus detection
  - Stable intersection point detection

All algorithms include type hints, docstrings, and complexity analysis.
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple
import itertools


# ============================================================
# Algorithm 1: Degree Simplex Construction
# ============================================================

def degree_simplex(d: int) -> FrozenSet[Tuple[int, int]]:
    """
    Construct the degree-d simplex as a set of lattice points.
    
    Δ_d = {(i, j) ∈ ℕ² : i + j ≤ d}
    
    Args:
        d: Non-negative integer degree
        
    Returns:
        Frozenset of lattice points in the simplex
        
    Complexity:
        Time: O(d²)  — enumerate all valid (i,j) pairs
        Space: O(d²) — store (d+1)(d+2)/2 points
        
    Examples:
        >>> sorted(degree_simplex(0))
        [(0, 0)]
        >>> sorted(degree_simplex(1))
        [(0, 0), (0, 1), (1, 0)]
        >>> len(degree_simplex(5))
        21
    """
    if d < 0:
        raise ValueError(f"Degree must be non-negative, got {d}")
    return frozenset((i, j) for i in range(d + 1) for j in range(d - i + 1))


def degree_simplex_card(d: int) -> int:
    """
    Compute |Δ_d| = (d+1)(d+2)/2 directly (without enumeration).
    
    This is the closed-form formula proved in our formalization.
    
    Args:
        d: Non-negative integer degree
        
    Returns:
        Number of lattice points in Δ_d
        
    Complexity: O(1)
    
    Examples:
        >>> degree_simplex_card(0)
        1
        >>> degree_simplex_card(3)
        10
        >>> degree_simplex_card(10)
        66
    """
    return (d + 1) * (d + 2) // 2


# ============================================================
# Algorithm 2: Minkowski Sum
# ============================================================

def minkowski_sum(A: FrozenSet[Tuple[int, int]],
                  B: FrozenSet[Tuple[int, int]]) -> FrozenSet[Tuple[int, int]]:
    """
    Compute the Minkowski sum A ⊕ B = {a + b : a ∈ A, b ∈ B}.
    
    Args:
        A, B: Finite sets of lattice points in ℤ²
        
    Returns:
        Minkowski sum as a frozenset
        
    Complexity:
        Time: O(|A| · |B|)  — enumerate all pairs
        Space: O(|A| · |B|) — worst case for output size
        
    Properties (proved formally):
        - Δ_{d₁} ⊕ Δ_{d₂} = Δ_{d₁+d₂}
        - Monotone: A ⊆ A' ∧ B ⊆ B' → A⊕B ⊆ A'⊕B'
        
    Examples:
        >>> sorted(minkowski_sum(frozenset([(0,0)]), frozenset([(1,1)])))
        [(1, 1)]
    """
    return frozenset((a[0] + b[0], a[1] + b[1]) for a in A for b in B)


# ============================================================
# Algorithm 3: Mixed Lattice Index
# ============================================================

def mixed_lattice_index(A: FrozenSet[Tuple[int, int]],
                        B: FrozenSet[Tuple[int, int]]) -> int:
    """
    Compute the mixed lattice index of two finite lattice point sets.
    
    MixedIndex(A, B) = |A ⊕ B| - |A| - |B| + 1
    
    For convex lattice polygons, this equals the mixed area.
    For degree simplices, this equals the product of degrees.
    
    Args:
        A, B: Non-empty finite sets of lattice points
        
    Returns:
        Integer mixed lattice index
        
    Complexity:
        Time: O(|A| · |B|) — dominated by Minkowski sum computation
        Space: O(|A| · |B|)
        
    Key theorem (proved formally):
        mixed_lattice_index(Δ_{d₁}, Δ_{d₂}) = d₁ · d₂
        
    Examples:
        >>> mixed_lattice_index(degree_simplex(2), degree_simplex(3))
        6
        >>> mixed_lattice_index(degree_simplex(5), degree_simplex(5))
        25
    """
    mink = minkowski_sum(A, B)
    return len(mink) - len(A) - len(B) + 1


def bezout_number(d1: int, d2: int) -> int:
    """
    Compute the tropical Bézout number for degrees d₁, d₂.
    
    This is simply d₁ × d₂, which equals the mixed lattice index
    of the degree simplices by our main theorem.
    
    Args:
        d1, d2: Positive integer degrees
        
    Returns:
        d1 * d2
        
    Complexity: O(1)
    """
    return d1 * d2


# ============================================================
# Algorithm 4: Tropical Polynomial Evaluation
# ============================================================

class TropicalPoly2:
    """
    A tropical polynomial in two variables.
    
    Represents f(x, y) = max_{(i,j) ∈ support} {a_{ij} + i·x + j·y}
    
    Attributes:
        terms: dict mapping (expX, expY) -> coefficient
        degree: maximum of expX + expY over all terms
    """
    
    def __init__(self, terms: Dict[Tuple[int, int], float]):
        """
        Initialize a tropical polynomial from its terms.
        
        Args:
            terms: Dictionary mapping exponent pairs to coefficients.
                   Must be non-empty. All exponents must be non-negative.
        
        Raises:
            ValueError: If terms is empty or contains negative exponents.
        """
        if not terms:
            raise ValueError("Tropical polynomial must have at least one term")
        for (i, j) in terms:
            if i < 0 or j < 0:
                raise ValueError(f"Exponents must be non-negative, got ({i}, {j})")
        self.terms = dict(terms)
        self.degree = max(i + j for (i, j) in terms)
    
    @property
    def support(self) -> FrozenSet[Tuple[int, int]]:
        """The exponent support of the polynomial."""
        return frozenset(self.terms.keys())
    
    @property
    def is_dense(self) -> bool:
        """Whether the support equals the full degree simplex."""
        return self.support == degree_simplex(self.degree)
    
    def eval(self, x: float, y: float) -> float:
        """
        Evaluate the tropical polynomial at (x, y).
        
        Computes max_{(i,j)} {a_{ij} + i·x + j·y}.
        
        Complexity: O(|support|)
        """
        return max(c + i * x + j * y for (i, j), c in self.terms.items())
    
    def argmax_terms(self, x: float, y: float,
                     tol: float = 1e-10) -> List[Tuple[int, int]]:
        """
        Find all terms achieving the maximum at (x, y).
        
        Returns exponent pairs (i, j) where a_{ij} + ix + jy = f(x,y).
        
        Complexity: O(|support|)
        """
        val = self.eval(x, y)
        return [(i, j) for (i, j), c in self.terms.items()
                if abs(c + i * x + j * y - val) < tol]
    
    def is_corner_point(self, x: float, y: float,
                        tol: float = 1e-10) -> bool:
        """
        Check if (x, y) is a corner point (on the tropical curve).
        
        A point is a corner if at least two terms achieve the maximum.
        
        Complexity: O(|support|)
        """
        return len(self.argmax_terms(x, y, tol)) >= 2


# ============================================================
# Algorithm 5: Tropical Curve Sampling
# ============================================================

def sample_tropical_curve(f: TropicalPoly2,
                          x_range: Tuple[float, float] = (-5.0, 5.0),
                          y_range: Tuple[float, float] = (-5.0, 5.0),
                          steps: int = 500,
                          tol: float = 0.05) -> List[Tuple[float, float]]:
    """
    Sample approximate corner points of a tropical curve on a grid.
    
    This is a brute-force sampling approach. For a production implementation,
    one would compute the dual subdivision and extract exact edge/vertex data.
    
    Args:
        f: Tropical polynomial
        x_range, y_range: Sampling region
        steps: Grid resolution in each dimension
        tol: Tolerance for detecting corner points
        
    Returns:
        List of approximate corner points
        
    Complexity:
        Time: O(steps² · |support|)
        Space: O(steps²) worst case
    """
    corners = []
    dx = (x_range[1] - x_range[0]) / steps
    dy = (y_range[1] - y_range[0]) / steps
    for i in range(steps + 1):
        for j in range(steps + 1):
            x = x_range[0] + i * dx
            y = y_range[0] + j * dy
            if f.is_corner_point(x, y, tol):
                corners.append((round(x, 4), round(y, 4)))
    return corners


# ============================================================
# Algorithm 6: Stable Intersection Detection
# ============================================================

def detect_intersections(f: TropicalPoly2, g: TropicalPoly2,
                         x_range: Tuple[float, float] = (-5.0, 5.0),
                         y_range: Tuple[float, float] = (-5.0, 5.0),
                         steps: int = 500,
                         tol: float = 0.05) -> List[Tuple[float, float]]:
    """
    Detect approximate stable intersection points of two tropical curves.
    
    A stable intersection point is a point that lies on both tropical curves.
    
    Args:
        f, g: Tropical polynomials
        x_range, y_range: Search region
        steps: Grid resolution
        tol: Corner detection tolerance
        
    Returns:
        List of approximate intersection points
        
    Complexity:
        Time: O(steps² · (|supp(f)| + |supp(g)|))
    """
    intersections = []
    dx = (x_range[1] - x_range[0]) / steps
    dy = (y_range[1] - y_range[0]) / steps
    for i in range(steps + 1):
        for j in range(steps + 1):
            x = x_range[0] + i * dx
            y = y_range[0] + j * dy
            if f.is_corner_point(x, y, tol) and g.is_corner_point(x, y, tol):
                intersections.append((round(x, 4), round(y, 4)))
    return intersections


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Intersection Theory — Algorithm Demonstrations")
    print("=" * 55)
    print()
    
    # Verify degree simplex formula
    for d in range(20):
        assert len(degree_simplex(d)) == degree_simplex_card(d)
    print("✓ Degree simplex cardinality formula verified for d ≤ 19")
    
    # Verify Minkowski sum theorem
    for d1 in range(8):
        for d2 in range(8):
            assert minkowski_sum(degree_simplex(d1), degree_simplex(d2)) == degree_simplex(d1 + d2)
    print("✓ Minkowski sum theorem verified for d₁, d₂ ≤ 7")
    
    # Verify mixed lattice index = d₁ × d₂
    for d1 in range(1, 8):
        for d2 in range(1, 8):
            assert mixed_lattice_index(degree_simplex(d1), degree_simplex(d2)) == d1 * d2
    print("✓ Mixed lattice index = d₁×d₂ verified for 1 ≤ d₁, d₂ ≤ 7")
    print()
    
    # Tropical line intersection
    line1 = TropicalPoly2({(1, 0): 0.0, (0, 1): 0.0, (0, 0): 0.0})
    line2 = TropicalPoly2({(1, 0): 1.0, (0, 1): -1.0, (0, 0): 0.5})
    
    print(f"Line 1: degree {line1.degree}, dense: {line1.is_dense}")
    print(f"Line 2: degree {line2.degree}, dense: {line2.is_dense}")
    print(f"Bézout number: {bezout_number(line1.degree, line2.degree)}")
    print()
    
    # Conic-cubic intersection
    conic = TropicalPoly2({(i, j): 0.1 * (i - j) for i, j in degree_simplex(2)})
    cubic = TropicalPoly2({(i, j): 0.2 * (i + j) for i, j in degree_simplex(3)})
    
    print(f"Conic: degree {conic.degree}, {len(conic.terms)} terms, dense: {conic.is_dense}")
    print(f"Cubic: degree {cubic.degree}, {len(cubic.terms)} terms, dense: {cubic.is_dense}")
    print(f"Bézout number: {bezout_number(conic.degree, cubic.degree)}")
    print(f"Expected intersection points (with multiplicity): {conic.degree * cubic.degree}")
