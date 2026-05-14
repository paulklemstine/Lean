#!/usr/bin/env python3
"""
Algorithms for Tropical T-Duality and Corner Locus Detection.

Implements:
  1. Tropical potential evaluation and duality
  2. Multi-branch corner detection
  3. Tropical Legendre transform (finite version)
  4. Active corner filtering
"""

from typing import List, Tuple, Optional
import numpy as np


# ──────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────

class AffineForm:
    """An affine function f(x) = slope * x + intercept."""

    def __init__(self, slope: float, intercept: float):
        self.slope = slope
        self.intercept = intercept

    def __call__(self, x: float) -> float:
        return self.slope * x + self.intercept

    def __repr__(self) -> str:
        return f"AffineForm(slope={self.slope}, intercept={self.intercept})"


class TropicalPolynomial:
    """A tropical polynomial: min of a collection of affine forms.

    f(x) = min_i (a_i * x + b_i)

    The corner locus is the set where two or more branches tie.
    """

    def __init__(self, branches: List[AffineForm]):
        if not branches:
            raise ValueError("Need at least one branch")
        self.branches = branches

    def __call__(self, x: float) -> float:
        """Evaluate the tropical polynomial at x."""
        return min(branch(x) for branch in self.branches)

    def active_branches(self, x: float, tol: float = 1e-12) -> List[int]:
        """Return indices of branches achieving the minimum at x."""
        val = self(x)
        return [i for i, b in enumerate(self.branches) if abs(b(x) - val) < tol]

    def eval_array(self, xs: np.ndarray) -> np.ndarray:
        """Vectorized evaluation."""
        vals = np.array([b.slope * xs + b.intercept for b in self.branches])
        return vals.min(axis=0)


# ──────────────────────────────────────────────────────────────
# Algorithm 1: Tropical Potential and T-Duality
# ──────────────────────────────────────────────────────────────

def tropical_potential_log(rho: float, x: float) -> float:
    """Evaluate Φ_ρ(x) = min(x + ρ, -x - ρ).

    Time: O(1), Space: O(1)

    This is the tropicalized circle energy with log-radius ρ.
    The two branches represent momentum and winding energy.
    """
    return min(x + rho, -x - rho)


def tropical_potential(r: float, x: float) -> float:
    """Evaluate Φ_r(x) = min(x + log r, -x - log r).

    Time: O(1), Space: O(1)

    Requires r > 0.
    """
    log_r = np.log(r)
    return min(x + log_r, -x - log_r)


def verify_t_duality(rho: float, x: float, tol: float = 1e-14) -> bool:
    """Verify Φ_{-ρ}(x) = Φ_ρ(-x) for given (ρ, x).

    Returns True if the identity holds within tolerance.
    """
    return abs(tropical_potential_log(-rho, x) - tropical_potential_log(rho, -x)) < tol


# ──────────────────────────────────────────────────────────────
# Algorithm 2: Corner Detection
# ──────────────────────────────────────────────────────────────

def compute_pairwise_corners(
    branches: List[AffineForm],
) -> List[Tuple[int, int, float]]:
    """Compute all pairwise corner points between branches.

    For each pair (i, j) with a_i ≠ a_j, computes
    x₀ = (b_j - b_i) / (a_i - a_j).

    Time: O(n²), Space: O(n²)

    Returns list of (i, j, x₀) triples.
    """
    corners = []
    n = len(branches)
    for i in range(n):
        for j in range(i + 1, n):
            ai, bi = branches[i].slope, branches[i].intercept
            aj, bj = branches[j].slope, branches[j].intercept
            if abs(ai - aj) > 1e-15:  # slopes differ
                x0 = (bj - bi) / (ai - aj)
                corners.append((i, j, x0))
    return corners


def detect_active_corners(
    poly: TropicalPolynomial,
    tol: float = 1e-10,
) -> List[Tuple[int, int, float, float]]:
    """Detect active corners: points where tied branches achieve the global min.

    A corner (i, j, x₀) is active if branches i and j both achieve
    the minimum of the tropical polynomial at x₀.

    Time: O(n² · n) = O(n³), Space: O(n²)

    Returns list of (i, j, x₀, value) tuples, sorted by x₀.
    """
    candidates = compute_pairwise_corners(poly.branches)
    active = []
    for i, j, x0 in candidates:
        tie_val = poly.branches[i](x0)
        global_min = poly(x0)
        if abs(tie_val - global_min) < tol:
            active.append((i, j, x0, tie_val))
    active.sort(key=lambda t: t[2])
    return active


# ──────────────────────────────────────────────────────────────
# Algorithm 3: Tropical Legendre Transform (Finite)
# ──────────────────────────────────────────────────────────────

def tropical_legendre_finite(
    f: TropicalPolynomial,
    grid: np.ndarray,
) -> np.ndarray:
    """Compute the tropical Legendre transform on a finite grid.

    f*(p) = sup_x (p·x - f(x))

    Evaluated at each grid point p using grid points as x samples.

    Time: O(m²) where m = |grid|, Space: O(m)
    """
    f_vals = f.eval_array(grid)  # f(x) for each x in grid
    result = np.empty(len(grid))
    for ip, p in enumerate(grid):
        # sup_x (p*x - f(x))
        result[ip] = np.max(p * grid - f_vals)
    return result


def tropical_legendre_biconjugate(
    f: TropicalPolynomial,
    grid: np.ndarray,
) -> np.ndarray:
    """Compute f** on a finite grid.

    f**(x) = sup_p (p·x - f*(p))

    Time: O(m²) per step × 2 steps = O(m²), Space: O(m)
    """
    f_star = tropical_legendre_finite(f, grid)
    result = np.empty(len(grid))
    for ix, x in enumerate(grid):
        result[ix] = np.max(x * grid - f_star)
    return result


# ──────────────────────────────────────────────────────────────
# Algorithm 4: Tropical Variety Visualization Data
# ──────────────────────────────────────────────────────────────

def tropical_variety_data(
    poly: TropicalPolynomial,
    x_range: Tuple[float, float] = (-5.0, 5.0),
    n_points: int = 1000,
) -> dict:
    """Generate visualization data for a tropical polynomial.

    Returns dict with keys:
      'xs': x coordinates
      'ys': tropical polynomial values
      'branches': list of branch values arrays
      'corners': list of active corner (x, y) pairs
      'active_indices': which branches are active at each x

    Time: O(n·b + b²) where b = #branches, n = n_points
    """
    xs = np.linspace(x_range[0], x_range[1], n_points)
    ys = poly.eval_array(xs)
    branches = [np.array([b(x) for x in xs]) for b in poly.branches]

    corners = detect_active_corners(poly)
    corner_points = [(x0, val) for _, _, x0, val in corners
                     if x_range[0] <= x0 <= x_range[1]]

    return {
        'xs': xs,
        'ys': ys,
        'branches': branches,
        'corners': corner_points,
    }


# ──────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Tropical T-Duality Algorithms ===\n")

    # T-duality verification
    print("1. T-Duality Verification")
    print("-" * 40)
    n_tests = 10000
    np.random.seed(42)
    rhos = np.random.uniform(-10, 10, n_tests)
    xs = np.random.uniform(-10, 10, n_tests)
    all_pass = all(verify_t_duality(rho, x) for rho, x in zip(rhos, xs))
    print(f"   {n_tests} random tests: {'ALL PASS' if all_pass else 'FAILURE'}")

    # Corner detection
    print("\n2. Corner Detection")
    print("-" * 40)
    poly = TropicalPolynomial([
        AffineForm(2.0, 1.0),
        AffineForm(-1.0, 4.0),
        AffineForm(0.5, -1.0),
    ])
    corners = detect_active_corners(poly)
    print(f"   Branches: {poly.branches}")
    print(f"   Active corners:")
    for i, j, x0, val in corners:
        print(f"     Branches {i+1},{j+1} tie at x={x0:.4f}, value={val:.4f}")

    # Legendre biconjugation
    print("\n3. Legendre Biconjugation")
    print("-" * 40)
    grid = np.linspace(-5, 5, 200)
    f_vals = poly.eval_array(grid)
    f_biconj = tropical_legendre_biconjugate(poly, grid)
    # For convex piecewise-linear f, f** should equal f
    # Our f = min of affine is concave, so f** ≤ f in general
    max_diff = np.max(np.abs(f_biconj - f_vals))
    print(f"   max |f**(x) - f(x)| over grid: {max_diff:.6f}")
    # For the sup-convention conjugate applied to -f (convex):
    neg_poly = TropicalPolynomial([
        AffineForm(-b.slope, -b.intercept) for b in poly.branches
    ])
    neg_f_vals = neg_poly.eval_array(grid)
    # Using max-plus convention: (-f)*(p) = sup_x(px - (-f)(x)) = sup_x(px + f(x))
    print(f"   (Biconjugation is exact for convex functions; our min-of-affine is concave)")

    print("\n=== Done ===")
