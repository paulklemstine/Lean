"""
Inverse Stereographic Neural Field Theory — Core Algorithms

Type-hinted implementations of key mathematical functions from the theory.
"""

from typing import Tuple, List
import math
from math import comb, factorial


def conformal_factor(r_sq: float) -> float:
    """Conformal factor of stereographic projection: σ(r²) = 2/(1 + r²)."""
    return 2.0 / (1.0 + r_sq)


def spherical_eigenvalue(n: int, l: int) -> int:
    """Eigenvalue of the Laplace-Beltrami operator on S^n for degree l.
    Returns the positive part: l(l + n - 1)."""
    return l * (l + n - 1)


def spherical_harmonic_dim(n: int, l: int) -> int:
    """Dimension of the space of spherical harmonics of degree l on S^n.
    For S^2 (n=2), this equals 2l+1."""
    if n == 0:
        return 1 if l == 0 else 0
    return comb(n + l, n) - comb(n + l - 2, n)


def pattern_count(l: int) -> int:
    """Number of independent pattern solutions for degree l on S^2: 2l+1."""
    return 2 * l + 1


def mexican_hat_pattern_count(r: float) -> int:
    """Number of patterns for Mexican-hat kernel with interaction radius r.
    The kernel selects degree l = floor(1/r)."""
    assert r > 0, "Interaction radius must be positive"
    l = int(1.0 / r)
    return pattern_count(l)


def mode_energy(l: int, a: float) -> float:
    """Energy of spherical harmonic mode of degree l with amplitude a on S^2.
    E_l(a) = l(l+1) * a² * (2l+1)."""
    return spherical_eigenvalue(2, l) * a ** 2 * spherical_harmonic_dim(2, l)


def conformal_laplacian_exponent(n: int) -> int:
    """Exponent in the conformal weight for the Laplacian: n + 2."""
    return n + 2


def inverse_stereographic_projection(
    x: Tuple[float, ...],
) -> Tuple[float, ...]:
    """Inverse stereographic projection from R^n to S^n.
    Maps x ∈ R^n to a point on S^n ⊂ R^{n+1}.
    The south pole (0,...,0,-1) maps to the origin."""
    r_sq = sum(xi ** 2 for xi in x)
    sigma = conformal_factor(r_sq)
    # Coordinates on sphere: (σ·x₁, σ·x₂, ..., σ·xₙ, 1 - σ)
    sphere_coords = tuple(sigma * xi for xi in x) + (1.0 - sigma,)
    return sphere_coords


def stereographic_projection(
    p: Tuple[float, ...],
) -> Tuple[float, ...]:
    """Stereographic projection from S^n to R^n.
    Projects from the north pole (0,...,0,1).
    Maps a point (y₁,...,yₙ,yₙ₊₁) on S^n to R^n."""
    n = len(p) - 1
    y_last = p[-1]
    denom = 1.0 - y_last
    if abs(denom) < 1e-15:
        return tuple(float("inf") for _ in range(n))
    return tuple(p[i] / denom for i in range(n))


def mexican_hat_kernel_2d(r: float, sigma_e: float, sigma_i: float) -> float:
    """2D Mexican-hat (difference of Gaussians) connectivity kernel.
    K(r) = exp(-r²/2σ_e²) - A·exp(-r²/2σ_i²)
    where A is chosen so ∫K = 0 (balanced excitation/inhibition)."""
    A = (sigma_e / sigma_i) ** 2
    return math.exp(-r ** 2 / (2 * sigma_e ** 2)) - A * math.exp(
        -r ** 2 / (2 * sigma_i ** 2)
    )


def spherical_harmonic_real_Y(l: int, m: int, theta: float, phi: float) -> float:
    """Real spherical harmonic Y_l^m(θ, φ) for S^2.
    Simplified computation for low degrees."""
    if l == 0 and m == 0:
        return 1.0 / (2.0 * math.sqrt(math.pi))
    elif l == 1:
        if m == -1:
            return math.sqrt(3 / (4 * math.pi)) * math.sin(theta) * math.sin(phi)
        elif m == 0:
            return math.sqrt(3 / (4 * math.pi)) * math.cos(theta)
        elif m == 1:
            return math.sqrt(3 / (4 * math.pi)) * math.sin(theta) * math.cos(phi)
    elif l == 2:
        if m == -2:
            return (
                0.5
                * math.sqrt(15 / math.pi)
                * math.sin(theta) ** 2
                * math.sin(2 * phi)
            )
        elif m == -1:
            return (
                0.5
                * math.sqrt(15 / math.pi)
                * math.sin(2 * theta)
                * math.sin(phi)
            )
        elif m == 0:
            return (
                0.25
                * math.sqrt(5 / math.pi)
                * (3 * math.cos(theta) ** 2 - 1)
            )
        elif m == 1:
            return (
                0.5
                * math.sqrt(15 / math.pi)
                * math.sin(2 * theta)
                * math.cos(phi)
            )
        elif m == 2:
            return (
                0.5
                * math.sqrt(15 / math.pi)
                * math.sin(theta) ** 2
                * math.cos(2 * phi)
            )
    raise NotImplementedError(f"Y_{l}^{m} not implemented for l > 2")


def total_harmonics_up_to(n: int, L: int) -> int:
    """Total number of spherical harmonics up to degree L on S^n.
    For S^2, this is (L+1)²."""
    return sum(spherical_harmonic_dim(n, l) for l in range(L + 1))


def eigenvalue_gap(n: int, l: int) -> int:
    """Gap between consecutive eigenvalues on S^n."""
    return spherical_eigenvalue(n, l + 1) - spherical_eigenvalue(n, l)


def conformal_decay_bound(l: int, r_sq: float) -> float:
    """Upper bound for the projected pattern decay: 2^l / r_sq^l."""
    if r_sq <= 0:
        return float("inf")
    return (2.0 ** l) / (r_sq ** l)


def verify_pattern_count_conjecture(k_max: int = 20) -> List[Tuple[int, int, int, bool]]:
    """Verify the Mexican-hat pattern count conjecture for k = 1 to k_max.
    Returns list of (k, dim_H_k, pattern_count_k, match)."""
    results = []
    for k in range(1, k_max + 1):
        dim = spherical_harmonic_dim(2, k)
        pc = pattern_count(k)
        results.append((k, dim, pc, dim == pc))
    return results
