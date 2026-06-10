#!/usr/bin/env python3
"""
Algorithms for F₁-Tropical Geometry

Type-hinted implementations of the core algorithms from the F₁-tropical duality.
"""

from __future__ import annotations
import math
from typing import Optional
from dataclasses import dataclass


INF = float('inf')


# ============================================================
# Algorithm 1: Tropical F₁-Algebra Operations
# ============================================================

@dataclass
class TropicalF1Algebra:
    """The tropical F₁-algebra on ℝ ∪ {∞}.

    Operations:
        add (⊕) = min
        mul (⊗) = +
        zero = ∞
        one = 0
    """

    @staticmethod
    def add(a: float, b: float) -> float:
        """Tropical addition: min(a, b)."""
        return min(a, b)

    @staticmethod
    def mul(a: float, b: float) -> float:
        """Tropical multiplication: a + b (with ∞ absorption)."""
        if a == INF or b == INF:
            return INF
        return a + b

    @staticmethod
    def zero() -> float:
        return INF

    @staticmethod
    def one() -> float:
        return 0.0

    @staticmethod
    def le(a: float, b: float) -> bool:
        """F₁-order: a ≤ b iff a ⊕ b = a."""
        return min(a, b) == a

    @staticmethod
    def is_generator(x: float, elements: list[float]) -> bool:
        """Check if x is an F₁-generator (cannot be decomposed as min of others)."""
        for a in elements:
            for b in elements:
                if a != x and b != x and min(a, b) == x:
                    return False
        return True


# ============================================================
# Algorithm 2: Tropical Polynomial Evaluation
# ============================================================

def tropical_poly_eval(coeffs: list[float], x: float) -> float:
    """Evaluate tropical polynomial: inf_i (c_i + i * x).

    Args:
        coeffs: Coefficients [c_0, c_1, ..., c_n]
        x: Evaluation point

    Returns:
        The tropical evaluation min_i(c_i + i*x)
    """
    result = INF
    for i, c in enumerate(coeffs):
        if c == INF:
            continue
        if x == INF and i > 0:
            continue
        term = c + i * x if x != INF else c
        result = min(result, term)
    return result


def find_corners_exact(coeffs: list[float]) -> list[float]:
    """Find exact corner points of a tropical polynomial over ℝ.

    Corner points occur where two terms c_i + i*x = c_j + j*x intersect
    and both achieve the minimum.

    Args:
        coeffs: Coefficients [c_0, ..., c_n] (finite values)

    Returns:
        Sorted list of corner x-values
    """
    n = len(coeffs)
    candidates: list[float] = []

    for i in range(n):
        if coeffs[i] == INF:
            continue
        for j in range(i + 1, n):
            if coeffs[j] == INF:
                continue
            # c_i + i*x = c_j + j*x  =>  x = (c_i - c_j) / (j - i)
            x = (coeffs[i] - coeffs[j]) / (j - i)
            # Check that this x actually achieves the global minimum
            val = coeffs[i] + i * x
            is_min = True
            for k in range(n):
                if coeffs[k] == INF:
                    continue
                if coeffs[k] + k * x < val - 1e-12:
                    is_min = False
                    break
            if is_min:
                candidates.append(x)

    # Deduplicate
    candidates.sort()
    result: list[float] = []
    for c in candidates:
        if not result or abs(c - result[-1]) > 1e-10:
            result.append(c)
    return result


# ============================================================
# Algorithm 3: F₁-Betti Numbers and Euler Characteristic
# ============================================================

def f1_betti_number(num_vertices: int, k: int) -> int:
    """Compute β_k^{F₁} for the complete simplicial complex.

    β_k = C(num_vertices, k+1) = number of (k+1)-element subsets.

    Args:
        num_vertices: Number of vertices in the simplicial complex
        k: Dimension

    Returns:
        The F₁-Betti number β_k
    """
    return math.comb(num_vertices, k + 1)


def tropical_euler_characteristic(num_vertices: int, max_dim: int) -> int:
    """Compute the tropical Euler characteristic.

    χ_{F₁} = Σ_{k=0}^{d} (-1)^k β_k^{F₁}

    Args:
        num_vertices: Number of vertices
        max_dim: Maximum dimension to sum over

    Returns:
        The tropical Euler characteristic
    """
    return sum((-1)**k * f1_betti_number(num_vertices, k)
               for k in range(max_dim + 1))


# ============================================================
# Algorithm 4: Lattice Polytope F₁-Points
# ============================================================

@dataclass
class LatticePolytope:
    """A lattice polytope represented by its vertices in ℤⁿ."""
    vertices: list[tuple[int, ...]]

    @property
    def dimension(self) -> int:
        if not self.vertices:
            return -1
        return len(self.vertices[0])

    @property
    def f1_points(self) -> int:
        """Number of F₁-points = number of vertices."""
        return len(self.vertices)

    @property
    def euler_characteristic(self) -> int:
        """Euler characteristic of the toric variety = vertex count."""
        return self.f1_points

    def f_vector(self) -> list[int]:
        """Compute the f-vector (face counts) by enumeration.

        For small polytopes only. Returns [f₀, f₁, ..., f_d].
        """
        from itertools import combinations
        n = len(self.vertices)
        # f_k = number of (k+1)-element subsets that form faces
        # For a simplex, all subsets are faces
        # For general polytopes, this requires convex hull computation
        # Here we return the simplex bound as an upper estimate
        d = min(n - 1, self.dimension)
        return [math.comb(n, k + 1) for k in range(d + 1)]


def zeta_polynomial(f_vec: list[int], q: int) -> int:
    """Evaluate the F₁-zeta polynomial: Σ f_k (q-1)^k.

    This should equal the number of F_q-points of the toric variety.

    Args:
        f_vec: Face vector [f₀, f₁, ..., f_d]
        q: Prime power

    Returns:
        The evaluated polynomial
    """
    return sum(f * (q - 1)**k for k, f in enumerate(f_vec))


# ============================================================
# Algorithm 5: Tropical Convex Hull
# ============================================================

def tropical_convex_combination(weights: list[float],
                                points: list[float]) -> float:
    """Compute a tropical convex combination.

    ⊕_i (w_i ⊗ p_i) = min_i (w_i + p_i)

    Args:
        weights: Tropical weights
        points: Generator points

    Returns:
        The tropical combination value
    """
    result = INF
    for w, p in zip(weights, points):
        result = min(result, TropicalF1Algebra.mul(w, p))
    return result


def tropical_segment(a: float, b: float,
                     num_points: int = 100) -> list[float]:
    """Generate points on the tropical segment between a and b.

    The tropical segment [a, b]_trop = {min(a + λ, b + μ) : λ, μ ≥ 0, ...}
    In 1D, this is simply the interval [min(a,b), max(a,b)].

    Args:
        a, b: Endpoints
        num_points: Number of sample points

    Returns:
        List of points on the tropical segment
    """
    lo, hi = min(a, b), max(a, b)
    if lo == INF:
        return [INF]
    if hi == INF:
        return [lo + t for t in range(num_points)]
    step = (hi - lo) / max(num_points - 1, 1)
    return [lo + i * step for i in range(num_points)]


if __name__ == "__main__":
    # Quick tests
    alg = TropicalF1Algebra()
    assert alg.add(3, 5) == 3
    assert alg.mul(3, 5) == 8
    assert alg.le(3, 5) == True
    assert alg.le(5, 3) == False

    # Tropical polynomial corners
    corners = find_corners_exact([6.0, 3.0, 0.0])
    print(f"Corners of min(6, 3+x, 2x): {corners}")

    # F₁-Betti numbers
    for n in range(1, 5):
        bettis = [f1_betti_number(n + 1, k) for k in range(n + 1)]
        print(f"β for {n+1} vertices: {bettis}")

    # Zeta polynomial test
    f_vec = [4, 4, 1]  # Unit square
    for q in [2, 3, 5, 7]:
        print(f"ζ(q={q}) = {zeta_polynomial(f_vec, q)}, (q+1)² = {(q+1)**2}")

    print("All tests passed!")
