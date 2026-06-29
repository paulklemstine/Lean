#!/usr/bin/env python3
"""
Tropical Intersection Theory — Algorithm Implementations

Type-hinted Python implementations of the core algorithms:
1. Tropical polynomial evaluation and root finding
2. Tropical curve intersection
3. Stable intersection multiplicity computation
4. Tropical resultant computation
"""

from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass
import math


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class TropMonomial:
    """A tropical monomial: coeff + exp_x * x + exp_y * y."""
    coeff: float
    exp_x: int
    exp_y: int

    def eval(self, x: float, y: float) -> float:
        return self.coeff + self.exp_x * x + self.exp_y * y

    def total_deg(self) -> int:
        return self.exp_x + self.exp_y


@dataclass
class TropPoly1D:
    """Univariate tropical polynomial: min_i(coeffs[i] + i*x)."""
    coeffs: List[float]

    @property
    def degree(self) -> int:
        return len(self.coeffs) - 1

    def eval(self, x: float) -> float:
        """O(d) tropical evaluation."""
        return min(self.coeffs[i] + i * x for i in range(len(self.coeffs)))

    def slope(self, x: float) -> float:
        """Discrete derivative Δp(x) = p(x+1) - p(x)."""
        return self.eval(x + 1) - self.eval(x)

    def active_term(self, x: float) -> int:
        """Return index of the term achieving the minimum at x."""
        vals = [self.coeffs[i] + i * x for i in range(len(self.coeffs))]
        return int(min(range(len(vals)), key=lambda i: vals[i]))

    def find_roots(self, x_min: int = -1000, x_max: int = 1000) -> List[Tuple[int, float]]:
        """Find all tropical roots (breakpoints) with their slope drops.

        Returns list of (position, drop_magnitude) pairs.
        Time: O((x_max - x_min) * d).
        """
        roots: List[Tuple[int, float]] = []
        prev_slope = self.slope(x_min)
        for x in range(x_min + 1, x_max):
            curr_slope = self.slope(x)
            if curr_slope < prev_slope - 1e-10:
                roots.append((x - 1, prev_slope - curr_slope))
            prev_slope = curr_slope
        return roots

    def verify_concavity(self, x_min: int = -100, x_max: int = 100) -> bool:
        """Verify p(x-1) + p(x+1) ≤ 2p(x) for all x in range."""
        for x in range(x_min, x_max + 1):
            if self.eval(x - 1) + self.eval(x + 1) > 2 * self.eval(x) + 1e-10:
                return False
        return True


@dataclass
class TropCurve:
    """A tropical curve in ℝ² defined by monomials."""
    monomials: List[TropMonomial]

    @property
    def degree(self) -> int:
        return max(m.total_deg() for m in self.monomials)

    def eval(self, x: float, y: float) -> float:
        return min(m.eval(x, y) for m in self.monomials)

    def active_monomials(self, x: float, y: float, tol: float = 1e-8) -> List[int]:
        """Return indices of monomials achieving the minimum at (x,y)."""
        val = self.eval(x, y)
        return [i for i, m in enumerate(self.monomials)
                if abs(m.eval(x, y) - val) < tol]

    def is_corner_point(self, x: float, y: float, tol: float = 1e-8) -> bool:
        """Check if (x,y) is in the corner locus (min attained ≥ 2 times)."""
        return len(self.active_monomials(x, y, tol)) >= 2


# ============================================================
# Intersection Algorithms
# ============================================================

def lattice_det(u1: int, u2: int, v1: int, v2: int) -> int:
    """Compute |u₁v₂ - u₂v₁| (absolute lattice determinant)."""
    return abs(u1 * v2 - u2 * v1)


def stable_intersection_mult(
    u1: int, u2: int, v1: int, v2: int, w1: int, w2: int
) -> int:
    """Stable intersection multiplicity at a transverse intersection.

    Args:
        u1, u2: primitive direction vector of edge from curve 1
        v1, v2: primitive direction vector of edge from curve 2
        w1: weight of edge from curve 1
        w2: weight of edge from curve 2

    Returns:
        |u₁v₂ - u₂v₁| * w₁ * w₂
    """
    return lattice_det(u1, u2, v1, v2) * w1 * w2


@dataclass
class TropicalEdge:
    """An edge of a tropical curve in ℝ²."""
    start: Tuple[float, float]
    direction: Tuple[int, int]  # primitive direction vector
    weight: int
    length: Optional[float]  # None for unbounded rays


def intersect_edges(
    e1: TropicalEdge, e2: TropicalEdge
) -> Optional[Tuple[float, float, int]]:
    """Find intersection point and multiplicity of two tropical edges.

    Returns (x, y, multiplicity) or None if no intersection.
    """
    u1, u2 = e1.direction
    v1, v2 = e2.direction

    det = u1 * v2 - u2 * v1
    if det == 0:
        return None  # Parallel edges

    # Solve for intersection parameters
    dx = e2.start[0] - e1.start[0]
    dy = e2.start[1] - e1.start[1]

    t = (dx * v2 - dy * v1) / det
    s = (dx * u2 - dy * u1) / det

    # Check if intersection is on both edges
    if t < -1e-10 or s < -1e-10:
        return None
    if e1.length is not None and t > e1.length + 1e-10:
        return None
    if e2.length is not None and s > e2.length + 1e-10:
        return None

    x = e1.start[0] + t * u1
    y = e1.start[1] + t * u2
    mult = stable_intersection_mult(u1, u2, v1, v2, e1.weight, e2.weight)

    return (x, y, mult)


def tropical_bezout_verify(
    edges1: List[TropicalEdge],
    edges2: List[TropicalEdge],
    d1: int, d2: int
) -> Dict:
    """Verify tropical Bézout theorem for two tropical curves.

    Returns dictionary with intersection points and total multiplicity.
    """
    intersections: List[Tuple[float, float, int]] = []

    for e1 in edges1:
        for e2 in edges2:
            result = intersect_edges(e1, e2)
            if result is not None:
                intersections.append(result)

    total_mult = sum(m for _, _, m in intersections)

    return {
        "intersections": intersections,
        "count": len(intersections),
        "total_multiplicity": total_mult,
        "expected": d1 * d2,
        "bezout_satisfied": len(intersections) <= d1 * d2,
        "bezout_exact": total_mult == d1 * d2,
    }


# ============================================================
# Tropical Resultant
# ============================================================

def tropical_resultant_entry(
    p: TropPoly1D, q: TropPoly1D, i: int, j: int
) -> Optional[float]:
    """Compute entry (i,j) of the tropical resultant matrix.

    The matrix has size (d₁+d₂) × (d₁+d₂).
    """
    d1 = p.degree
    d2 = q.degree

    if i < d2 and 0 <= j - i <= d1:
        return p.coeffs[j - i]
    elif i >= d2 and 0 <= j - (i - d2) <= d2:
        return q.coeffs[j - (i - d2)]
    else:
        return None  # Tropical infinity


def tropical_det(matrix: List[List[Optional[float]]]) -> Optional[float]:
    """Compute tropical determinant: min over permutations of sum of entries.

    For an n×n matrix, this is min_{σ ∈ Sₙ} Σᵢ M[i][σ(i)].
    Returns None if all permutations have a None entry.
    """
    from itertools import permutations

    n = len(matrix)
    best = None

    for perm in permutations(range(n)):
        val = 0.0
        valid = True
        for i in range(n):
            entry = matrix[i][perm[i]]
            if entry is None:
                valid = False
                break
            val += entry
        if valid:
            if best is None or val < best:
                best = val

    return best


def compute_tropical_resultant(p: TropPoly1D, q: TropPoly1D) -> Optional[float]:
    """Compute the tropical resultant of two univariate tropical polynomials.

    The tropical resultant is the tropical determinant of the Sylvester-type matrix.
    """
    n = p.degree + q.degree
    matrix = [[tropical_resultant_entry(p, q, i, j) for j in range(n)] for i in range(n)]
    return tropical_det(matrix)


# ============================================================
# Convex Hull / Lower Envelope Algorithm
# ============================================================

def lower_envelope(coeffs: List[float]) -> List[Tuple[int, int, float]]:
    """Compute the lower convex hull of points (i, coeffs[i]).

    Returns list of (i_start, i_end, breakpoint_x) for each edge,
    where breakpoint_x is the x-coordinate where terms i_start and i_end meet.

    Time: O(d) using Andrew's monotone chain variant.
    """
    n = len(coeffs)
    if n <= 1:
        return []

    # Stack-based lower convex hull
    hull: List[int] = [0]
    edges: List[Tuple[int, int, float]] = []

    for i in range(1, n):
        while len(hull) >= 2:
            j, k = hull[-2], hull[-1]
            # Check if k is above the line from j to i
            # Breakpoint j-k: coeffs[j] + j*x = coeffs[k] + k*x → x = (coeffs[j]-coeffs[k])/(k-j)
            # Breakpoint k-i: x = (coeffs[k]-coeffs[i])/(i-k)
            bp_jk = (coeffs[j] - coeffs[k]) / (k - j)
            bp_ki = (coeffs[k] - coeffs[i]) / (i - k)
            if bp_ki <= bp_jk:
                hull.pop()
            else:
                break
        hull.append(i)

    for idx in range(len(hull) - 1):
        i, j = hull[idx], hull[idx + 1]
        bp = (coeffs[i] - coeffs[j]) / (j - i)
        edges.append((i, j, bp))

    return edges


# ============================================================
# Main execution
# ============================================================

if __name__ == "__main__":
    # Example: degree-3 polynomial
    p = TropPoly1D([3, 1, 0, 2])
    print(f"Polynomial: coeffs = {p.coeffs}, degree = {p.degree}")
    print(f"Concavity: {p.verify_concavity()}")
    print(f"Roots: {p.find_roots(-10, 10)}")

    # Lower envelope
    env = lower_envelope(p.coeffs)
    print(f"Lower envelope edges: {env}")

    # Tropical resultant
    q = TropPoly1D([0, 2, 1])
    res = compute_tropical_resultant(p, q)
    print(f"\nResultant of degree-{p.degree} and degree-{q.degree}: {res}")
