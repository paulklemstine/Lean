"""
Split Geometry: Core Algorithms
================================

Type-hinted implementations of split geometry computations including
curvature evaluation, phase classification, divergence computation,
and curvature spectrum analysis.
"""

from __future__ import annotations
import math
from enum import Enum
from typing import Tuple, List, Optional
import numpy as np


class SplitPhase(Enum):
    """Phase classification for points in split geometry."""
    ELLIPTIC = "elliptic"     # K > 0: |x| < |y|
    HYPERBOLIC = "hyperbolic" # K < 0: |x| > |y|
    BOUNDARY = "boundary"     # K = 0: |x| = |y|


def sech_sq(x: float) -> float:
    """Compute sech²(x) = 1/cosh²(x), the fundamental building block."""
    c = math.cosh(x)
    return 1.0 / (c * c)


def split_curvature(x: float, y: float) -> float:
    """Gaussian curvature K(x,y) = sech²(x) - sech²(y) of the split metric."""
    return sech_sq(x) - sech_sq(y)


def split_area_element(x: float, y: float) -> float:
    """Area element sech(x)·sech(y) of the split metric."""
    return 1.0 / (math.cosh(x) * math.cosh(y))


def anisotropy_ratio(x: float, y: float) -> float:
    """Anisotropy ratio cosh(x)/cosh(y), measuring directional distortion."""
    return math.cosh(x) / math.cosh(y)


def classify_phase(x: float, y: float, tol: float = 1e-12) -> SplitPhase:
    """Classify a point (x,y) into its phase region."""
    K = split_curvature(x, y)
    if abs(K) < tol:
        return SplitPhase.BOUNDARY
    elif K > 0:
        return SplitPhase.ELLIPTIC
    else:
        return SplitPhase.HYPERBOLIC


def split_divergence(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    """Split divergence D(p,q) measuring metric tensor deviation."""
    d1 = sech_sq(p[0]) - sech_sq(q[0])
    d2 = sech_sq(p[1]) - sech_sq(q[1])
    return d1 * d1 + d2 * d2


def curvature_potential(x: float) -> float:
    """Curvature potential Φ(x) = log(cosh(x))."""
    return math.log(math.cosh(x))


def curvature_spectrum(points: np.ndarray) -> np.ndarray:
    """
    Compute the curvature spectrum matrix for a set of points.
    
    Parameters
    ----------
    points : np.ndarray of shape (n,)
        Coordinate values for the point configuration.
    
    Returns
    -------
    np.ndarray of shape (n, n)
        Matrix where entry (i,j) = K(points[i], points[j]).
    """
    n = len(points)
    spectrum = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            spectrum[i, j] = split_curvature(points[i], points[j])
    return spectrum


def curvature_variance(xs: np.ndarray, y0: float) -> float:
    """
    Compute the curvature variance of a point configuration.
    
    Parameters
    ----------
    xs : np.ndarray
        x-coordinates of sample points.
    y0 : float
        Fixed y-coordinate reference.
    
    Returns
    -------
    float
        Variance of curvature values K(xᵢ, y₀).
    """
    curvatures = np.array([split_curvature(x, y0) for x in xs])
    return float(np.mean(curvatures ** 2))


def discrete_gauss_bonnet(coords: List[float]) -> float:
    """
    Compute the discrete Gauss-Bonnet sum for a closed polygon.
    
    The sum of K(cᵢ, cᵢ₊₁) around a closed circuit should be zero
    due to telescoping cancellation.
    
    Parameters
    ----------
    coords : List[float]
        Coordinate values forming a closed polygon.
    
    Returns
    -------
    float
        Total curvature around the circuit (should be ~0).
    """
    n = len(coords)
    if n < 2:
        return 0.0
    total = 0.0
    for i in range(n):
        total += split_curvature(coords[i], coords[(i + 1) % n])
    return total


def split_laplacian(
    f: callable, x: float, y: float, h: float = 0.01
) -> float:
    """
    Discrete split Laplacian of f at (x,y) with step size h.
    
    Δ_split f = sech²(x) · f_xx + sech²(y) · f_yy
    """
    fxx = (f(x + h, y) - 2 * f(x, y) + f(x - h, y)) / (h * h)
    fyy = (f(x, y + h) - 2 * f(x, y) + f(x, y - h)) / (h * h)
    return sech_sq(x) * fxx + sech_sq(y) * fyy


def curvature_flow_step(
    f_grid: np.ndarray,
    x_coords: np.ndarray,
    y_coords: np.ndarray,
    dt: float,
    h: float
) -> np.ndarray:
    """
    One step of the split curvature flow on a grid.
    
    Parameters
    ----------
    f_grid : np.ndarray of shape (nx, ny)
        Current function values on the grid.
    x_coords, y_coords : np.ndarray
        1D coordinate arrays.
    dt : float
        Time step.
    h : float
        Spatial step (assumed uniform).
    
    Returns
    -------
    np.ndarray
        Updated function values after one flow step.
    """
    nx, ny = f_grid.shape
    result = f_grid.copy()
    for i in range(1, nx - 1):
        for j in range(1, ny - 1):
            fxx = (f_grid[i+1, j] - 2*f_grid[i, j] + f_grid[i-1, j]) / (h*h)
            fyy = (f_grid[i, j+1] - 2*f_grid[i, j] + f_grid[i, j-1]) / (h*h)
            lap = sech_sq(x_coords[i]) * fxx + sech_sq(y_coords[j]) * fyy
            result[i, j] += dt * lap
    return result


def elliptic_area_fraction(R: float, n_samples: int = 1000) -> float:
    """
    Numerically estimate the fraction of area (under the split metric)
    in the elliptic region within [-R, R]².
    
    This tests the Curvature Concentration Conjecture: the fraction
    should approach 1/2 as R → ∞.
    
    Parameters
    ----------
    R : float
        Half-width of the square domain.
    n_samples : int
        Number of grid points per axis.
    
    Returns
    -------
    float
        Estimated fraction of area in the elliptic region.
    """
    xs = np.linspace(-R, R, n_samples)
    ys = np.linspace(-R, R, n_samples)
    dx = 2 * R / (n_samples - 1)
    dy = 2 * R / (n_samples - 1)
    
    total_area = 0.0
    elliptic_area = 0.0
    
    for x in xs:
        for y in ys:
            dA = split_area_element(x, y) * dx * dy
            total_area += dA
            if split_curvature(x, y) > 0:
                elliptic_area += dA
    
    return elliptic_area / total_area if total_area > 0 else 0.0


if __name__ == "__main__":
    # Quick self-test
    print("=== Split Geometry Algorithms Self-Test ===")
    
    # Curvature bound
    import random
    random.seed(42)
    for _ in range(1000):
        x, y = random.uniform(-10, 10), random.uniform(-10, 10)
        K = split_curvature(x, y)
        assert abs(K) <= 1.0 + 1e-15, f"|K({x},{y})| = {abs(K)} > 1"
    print("✓ Curvature bound |K| ≤ 1 verified for 1000 random points")
    
    # Antisymmetry
    for _ in range(100):
        x, y = random.uniform(-5, 5), random.uniform(-5, 5)
        assert abs(split_curvature(x, y) + split_curvature(y, x)) < 1e-14
    print("✓ Antisymmetry K(x,y) = -K(y,x) verified")
    
    # Discrete Gauss-Bonnet
    coords = [random.uniform(-5, 5) for _ in range(20)]
    gb = discrete_gauss_bonnet(coords)
    assert abs(gb) < 1e-12, f"Gauss-Bonnet sum = {gb}"
    print(f"✓ Discrete Gauss-Bonnet: sum = {gb:.2e}")
    
    # Divergence bound
    for _ in range(100):
        p = (random.uniform(-5, 5), random.uniform(-5, 5))
        q = (random.uniform(-5, 5), random.uniform(-5, 5))
        D = split_divergence(p, q)
        assert D <= 2.0 + 1e-14
        assert D >= -1e-14
    print("✓ Divergence bound D ≤ 2 verified")
    
    print("\nAll tests passed!")
