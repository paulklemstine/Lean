#!/usr/bin/env python3
"""
Algorithms for Inverse Stereographic Neural Field Theory

Implements the core computational methods:
1. Inverse stereographic projection and its properties
2. Spherical harmonic pullback computation
3. Funk-Hecke eigenvalue computation for radial kernels
4. PDE residual verification
5. Mode selection analysis for Mexican-hat kernels

All algorithms include docstrings, type hints, and example usage.
"""

import numpy as np
from scipy.special import sph_harm_y as sph_harm, legendre, eval_legendre
from scipy.integrate import quad
from typing import Tuple, List, Dict, Optional, Callable


# =============================================================================
# Algorithm 1: Inverse Stereographic Projection
# =============================================================================

def inverse_stereographic(
    p: np.ndarray
) -> np.ndarray:
    """
    Inverse stereographic projection σ: ℝ² → S² ⊂ ℝ³.

    Maps (x, y) ↦ (2x/(1+r²), 2y/(1+r²), (r²-1)/(1+r²))
    where r² = x² + y².

    Complexity: O(1) per point, O(N) for N points.

    Parameters:
        p: Array of shape (..., 2) with planar coordinates

    Returns:
        Array of shape (..., 3) with sphere coordinates

    Example:
        >>> p = np.array([0.0, 0.0])
        >>> inverse_stereographic(p)
        array([ 0.,  0., -1.])  # South pole

        >>> p = np.array([1.0, 0.0])
        >>> inverse_stereographic(p)
        array([1., 0., 0.])  # East point
    """
    p = np.asarray(p, dtype=float)
    x, y = p[..., 0], p[..., 1]
    r2 = x**2 + y**2
    D = 1 + r2

    result = np.empty(p.shape[:-1] + (3,))
    result[..., 0] = 2 * x / D
    result[..., 1] = 2 * y / D
    result[..., 2] = (r2 - 1) / D
    return result


def stereographic_projection(
    q: np.ndarray
) -> np.ndarray:
    """
    Stereographic projection π: S² \ {N} → ℝ² (inverse of inverse_stereographic).

    Maps (X, Y, Z) ↦ (X/(1-Z), Y/(1-Z)).

    Parameters:
        q: Array of shape (..., 3) with sphere coordinates (not at north pole)

    Returns:
        Array of shape (..., 2) with planar coordinates

    Example:
        >>> q = np.array([0.0, 0.0, -1.0])
        >>> stereographic_projection(q)
        array([0., 0.])  # Origin
    """
    q = np.asarray(q, dtype=float)
    X, Y, Z = q[..., 0], q[..., 1], q[..., 2]
    denom = 1 - Z

    result = np.empty(q.shape[:-1] + (2,))
    result[..., 0] = X / denom
    result[..., 1] = Y / denom
    return result


def stereo_denom(p: np.ndarray) -> np.ndarray:
    """
    Stereographic denominator D(p) = 1 + |p|².

    Parameters:
        p: Array of shape (..., 2)

    Returns:
        Array of shape (...)
    """
    return 1 + np.sum(p**2, axis=-1)


def conformal_weight(p: np.ndarray) -> np.ndarray:
    """
    Conformal weight w(p) = 2/D(p).

    Parameters:
        p: Array of shape (..., 2)

    Returns:
        Array of shape (...)
    """
    return 2.0 / stereo_denom(p)


def metric_weight(p: np.ndarray) -> np.ndarray:
    """
    Metric conformal factor w(p)² = 4/D(p)².

    Parameters:
        p: Array of shape (..., 2)

    Returns:
        Array of shape (...)
    """
    return conformal_weight(p)**2


# =============================================================================
# Algorithm 2: Spherical Harmonic Pullback
# =============================================================================

def spherical_harmonic_pullback(
    p: np.ndarray,
    l: int,
    m: int
) -> np.ndarray:
    """
    Compute the pullback of real spherical harmonic Y_l^m to ℝ² via σ.

    v(p) = Y_l^m(σ(p))

    Uses the real spherical harmonic convention:
    - m > 0: √2 · Re(Y_l^m)
    - m = 0: Y_l^0
    - m < 0: √2 · Im(Y_l^|m|)

    Complexity: O(l) per point for Legendre evaluation.

    Parameters:
        p: Array of shape (..., 2) with planar coordinates
        l: Degree (non-negative integer)
        m: Order (-l ≤ m ≤ l)

    Returns:
        Array of shape (...) with harmonic values

    Example:
        >>> p = np.array([[0., 0.], [1., 0.], [0., 1.]])
        >>> spherical_harmonic_pullback(p, 1, 0)  # Y_1^0 = sqrt(3/4π) cos θ
        array([-0.4886, 0.    , 0.    ])
    """
    q = inverse_stereographic(p)
    X, Y, Z = q[..., 0], q[..., 1], q[..., 2]

    theta = np.arccos(np.clip(Z, -1, 1))
    phi = np.arctan2(Y, X)

    Ylm = sph_harm(l, abs(m), theta, phi)

    if m > 0:
        return np.real(Ylm) * np.sqrt(2) * (-1)**m
    elif m < 0:
        return np.imag(Ylm) * np.sqrt(2) * (-1)**(abs(m))
    else:
        return np.real(Ylm)


def all_mode_pullbacks(
    p: np.ndarray,
    l: int
) -> np.ndarray:
    """
    Compute pullbacks of all 2l+1 real spherical harmonics of degree l.

    Parameters:
        p: Array of shape (..., 2) with planar coordinates
        l: Degree

    Returns:
        Array of shape (2l+1, ...) with mode values indexed by m from -l to l
    """
    modes = []
    for m in range(-l, l + 1):
        modes.append(spherical_harmonic_pullback(p, l, m))
    return np.array(modes)


# =============================================================================
# Algorithm 3: Funk-Hecke Eigenvalue Computation
# =============================================================================

def funk_hecke_eigenvalue(
    kernel_func: Callable[[np.ndarray], np.ndarray],
    l: int,
    n_quad: int = 500
) -> float:
    """
    Compute the Funk-Hecke eigenvalue of a zonal kernel for degree l.

    For a radial kernel K(cos γ) on S², the Funk-Hecke theorem gives:
    λ_l = 2π ∫_{-1}^{1} K(t) P_l(t) dt

    where P_l is the Legendre polynomial of degree l.

    Complexity: O(n_quad · l) for quadrature with Legendre evaluation.

    Parameters:
        kernel_func: Function K(t) for t ∈ [-1, 1]
        l: Degree
        n_quad: Number of quadrature points

    Returns:
        Eigenvalue λ_l

    Example:
        >>> # Constant kernel K(t) = 1
        >>> lambda_0 = funk_hecke_eigenvalue(lambda t: np.ones_like(t), 0)
        >>> abs(lambda_0 - 4*np.pi) < 0.01
        True
    """
    def integrand(t):
        return kernel_func(np.atleast_1d(t))[0] * eval_legendre(l, t)

    result, error = quad(integrand, -1, 1, limit=200)
    return 2 * np.pi * result


def mexican_hat_kernel(
    t: np.ndarray,
    sigma1: float = 0.3,
    sigma2: float = 0.8
) -> np.ndarray:
    """
    Mexican-hat (difference of Gaussians) kernel on S².

    K(cos γ) = exp(-γ²/(2σ₁²)) - exp(-γ²/(2σ₂²))

    where γ = arccos(t) is the geodesic distance.

    Parameters:
        t: cos(γ) values in [-1, 1]
        sigma1: Width of excitatory Gaussian (narrow)
        sigma2: Width of inhibitory Gaussian (wide)

    Returns:
        Kernel values
    """
    t = np.asarray(t, dtype=float)
    gamma = np.arccos(np.clip(t, -1, 1))
    return np.exp(-gamma**2 / (2*sigma1**2)) - np.exp(-gamma**2 / (2*sigma2**2))


def compute_mode_spectrum(
    kernel_func: Callable,
    max_l: int = 20
) -> Dict[str, object]:
    """
    Compute the full mode eigenvalue spectrum for a radial kernel.

    Parameters:
        kernel_func: Zonal kernel function K(cos γ)
        max_l: Maximum degree to compute

    Returns:
        Dictionary with:
        - 'eigenvalues': list of λ_l for l = 0, ..., max_l
        - 'max_degree': degree with maximum eigenvalue
        - 'max_eigenvalue': the maximum eigenvalue
        - 'multiplicity': 2*max_degree + 1

    Example:
        >>> kernel = lambda t: mexican_hat_kernel(t, 0.3, 0.8)
        >>> result = compute_mode_spectrum(kernel, max_l=10)
        >>> result['multiplicity']  # 2*max_degree + 1
    """
    eigenvalues = [funk_hecke_eigenvalue(kernel_func, l) for l in range(max_l + 1)]

    max_idx = int(np.argmax(eigenvalues))

    return {
        'eigenvalues': eigenvalues,
        'max_degree': max_idx,
        'max_eigenvalue': eigenvalues[max_idx],
        'multiplicity': 2 * max_idx + 1,
        'is_unique_max': all(
            eigenvalues[l] < eigenvalues[max_idx]
            for l in range(max_l + 1) if l != max_idx
        )
    }


# =============================================================================
# Algorithm 4: PDE Residual Verification
# =============================================================================

def weighted_laplacian_residual(
    v_func: Callable[[np.ndarray], np.ndarray],
    l: int,
    grid_range: float = 5.0,
    resolution: int = 200
) -> Dict[str, float]:
    """
    Compute the residual of the weighted eigenvalue equation:
    Δv(x) + 4l(l+1)/(1+|x|²)² · v(x) = 0

    Uses a 5-point finite difference Laplacian.

    Complexity: O(N²) for N×N grid.

    Parameters:
        v_func: Function v: ℝ² → ℝ (takes array of shape (..., 2))
        l: Degree for the potential
        grid_range: Half-width of computation domain
        resolution: Grid points per dimension

    Returns:
        Dictionary with residual statistics
    """
    h = 2 * grid_range / resolution
    x = np.linspace(-grid_range, grid_range, resolution)
    y = np.linspace(-grid_range, grid_range, resolution)
    X, Y = np.meshgrid(x, y)

    points = np.stack([X, Y], axis=-1)
    v = v_func(points)

    # 5-point Laplacian
    lap = np.zeros_like(v)
    lap[1:-1, 1:-1] = (
        v[2:, 1:-1] + v[:-2, 1:-1] +
        v[1:-1, 2:] + v[1:-1, :-2] -
        4 * v[1:-1, 1:-1]
    ) / h**2

    # Conformal potential
    V = 4 * l * (l + 1) / stereo_denom(points)**2

    # Interior residual
    interior = slice(1, -1)
    residual = lap[interior, interior] + V[interior, interior] * v[interior, interior]

    max_v = np.max(np.abs(v))
    return {
        'max_residual': float(np.max(np.abs(residual))),
        'l2_residual': float(np.sqrt(np.mean(residual**2))),
        'relative_residual': float(np.max(np.abs(residual)) / (max_v + 1e-15)),
        'grid_spacing': h,
        'max_value': float(max_v)
    }


# =============================================================================
# Algorithm 5: Mode Selection Analysis
# =============================================================================

def mode_selection_analysis(
    radius_values: List[float],
    sigma_ratio: float = 2.5,
    max_l: int = 20
) -> List[Dict]:
    """
    Analyze mode selection for Mexican-hat kernels at various radii.

    For each radius r, constructs a Mexican-hat kernel with σ₁ = r and σ₂ = ratio·r,
    computes the Funk-Hecke spectrum, and identifies the dominant mode.

    Parameters:
        radius_values: List of interaction radii to test
        sigma_ratio: Ratio σ₂/σ₁
        max_l: Maximum degree to compute

    Returns:
        List of result dictionaries, one per radius

    Example:
        >>> results = mode_selection_analysis([1.0, 0.5, 1/3])
        >>> for r in results:
        ...     print(f"r={r['radius']:.3f}: dominant ℓ={r['max_degree']}")
    """
    results = []
    for r in radius_values:
        sigma1 = r
        sigma2 = sigma_ratio * r
        kernel = lambda t, s1=sigma1, s2=sigma2: mexican_hat_kernel(t, s1, s2)
        spectrum = compute_mode_spectrum(kernel, max_l)
        spectrum['radius'] = r
        spectrum['sigma1'] = sigma1
        spectrum['sigma2'] = sigma2
        spectrum['predicted_k'] = int(np.floor(1.0 / r)) if r > 0 else 0
        results.append(spectrum)
    return results


# =============================================================================
# Algorithm 6: Sphere Landing Verification
# =============================================================================

def verify_sphere_properties(
    n_samples: int = 10000
) -> Dict[str, float]:
    """
    Numerically verify key properties of inverse stereographic projection:
    1. Image lies on S² (|σ(p)| = 1)
    2. Conformal factor identity (|σ(p) - N|² = 4/D)
    3. South pole mapping (σ(0) = (0,0,-1))

    Parameters:
        n_samples: Number of random test points

    Returns:
        Dictionary with maximum errors for each property
    """
    np.random.seed(42)
    points = np.random.randn(n_samples, 2) * 10.0

    # Property 1: Unit norm
    q = inverse_stereographic(points)
    norms_sq = np.sum(q**2, axis=-1)
    sphere_error = np.max(np.abs(norms_sq - 1.0))

    # Property 2: Conformal factor
    north = np.array([0, 0, 1])
    diff = q - north
    dist_sq = np.sum(diff**2, axis=-1)
    D = stereo_denom(points)
    factor_error = np.max(np.abs(dist_sq - 4.0 / D))

    # Property 3: Origin → south pole
    origin = np.array([[0.0, 0.0]])
    south = inverse_stereographic(origin)
    south_error = np.max(np.abs(south - np.array([[0, 0, -1]])))

    return {
        'sphere_landing_error': float(sphere_error),
        'conformal_factor_error': float(factor_error),
        'south_pole_error': float(south_error)
    }


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == '__main__':
    print("=" * 60)
    print("  Algorithms for Stereographic Neural Field Theory")
    print("=" * 60)
    print()

    # 1. Verify basic properties
    print("1. Verifying stereographic projection properties...")
    props = verify_sphere_properties()
    for key, val in props.items():
        print(f"   {key}: {val:.2e}")
    print()

    # 2. Compute mode spectrum
    print("2. Computing Mexican-hat mode spectrum...")
    kernel = lambda t: mexican_hat_kernel(t, 0.3, 0.8)
    spectrum = compute_mode_spectrum(kernel, max_l=15)
    print(f"   Maximum eigenvalue at ℓ = {spectrum['max_degree']}")
    print(f"   Multiplicity = {spectrum['multiplicity']}")
    print(f"   Unique maximum: {spectrum['is_unique_max']}")
    print(f"   Eigenvalues: {[f'{v:.4f}' for v in spectrum['eigenvalues'][:8]]}")
    print()

    # 3. Mode selection analysis
    print("3. Mode selection analysis...")
    results = mode_selection_analysis([1.0, 0.5, 1/3, 0.25, 0.2])
    print(f"   {'Radius':>8} {'Predicted k':>12} {'Actual ℓ_max':>12} {'Multiplicity':>14}")
    for r in results:
        print(f"   {r['radius']:>8.3f} {r['predicted_k']:>12d} "
              f"{r['max_degree']:>12d} {r['multiplicity']:>14d}")
    print()

    # 4. PDE residual
    print("4. PDE residual verification (ℓ=2, m=0)...")
    v_func = lambda p: spherical_harmonic_pullback(p, 2, 0)
    for res in [50, 100, 200]:
        residual = weighted_laplacian_residual(v_func, l=2, resolution=res)
        print(f"   {res}×{res}: max_res={residual['max_residual']:.2e}, "
              f"rel_res={residual['relative_residual']:.2e}")
    print()

    print("All algorithms completed successfully.")
