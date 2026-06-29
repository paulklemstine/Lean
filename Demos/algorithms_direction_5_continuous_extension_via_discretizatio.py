#!/usr/bin/env python3
"""
Certified Discretization Algorithms for Continuous-to-Discrete Robustness Transfer

Implements the complete certified pipeline from continuous log-concave geometry
to discrete Lorentzian stability bounds and mixing time certificates.

Classes:
    CertifiedDiscretization: Core data structure for grid discretization
    RobustnessTransferPipeline: End-to-end certified transfer engine

Functions:
    compute_coefficient_distance: L¹ distance between mass functions
    compute_chi_squared: χ² divergence
    compute_kl_divergence: KL divergence
    certified_gap_bound: Gap lower bound from perturbation theory
    certified_mixing_time: Mixing time upper bound from gap
"""

from dataclasses import dataclass, field
from typing import Optional, Callable, Tuple, List, Dict
import numpy as np
from scipy.special import erf


@dataclass
class CertifiedDiscretization:
    """
    A certified discretization of a continuous density on a bounded region.

    Packages all data needed for the continuous-to-discrete robustness transfer:
    grid geometry, mass assignments, and error certificates.

    Attributes:
        n: Dimension of the ambient space
        h: Grid spacing (positive)
        R: Half-side length of the bounding box [-R, R]^n
        cell_centers: Array of cell center coordinates, shape (N, n)
        cell_weights: Exact cell-integrated masses (ideal discretization)
        point_weights: Point-sampled masses (approximate discretization)
        truncation_error: Mass outside the bounding box
        local_oscillation: Maximum density variation within any cell
    """
    n: int
    h: float
    R: float
    cell_centers: np.ndarray
    cell_weights: np.ndarray
    point_weights: np.ndarray
    truncation_error: float = 0.0
    local_oscillation: float = 0.0

    @property
    def num_cells(self) -> int:
        return len(self.cell_weights)

    @property
    def coefficient_distance(self) -> float:
        """L¹ distance between point-sampled and cell-integrated weights."""
        mu = self.point_weights / np.sum(self.point_weights)
        nu = self.cell_weights / np.sum(self.cell_weights)
        return np.sum(np.abs(mu - nu))

    @property
    def chi_squared(self) -> float:
        """χ² divergence from point-sampled to cell-integrated."""
        mu = self.point_weights / np.sum(self.point_weights)
        nu = self.cell_weights / np.sum(self.cell_weights)
        mask = nu > 0
        return np.sum((mu[mask] - nu[mask])**2 / nu[mask])

    @property
    def kl_divergence(self) -> float:
        """KL divergence from point-sampled to cell-integrated."""
        mu = self.point_weights / np.sum(self.point_weights)
        nu = self.cell_weights / np.sum(self.cell_weights)
        mask = (mu > 0) & (nu > 0)
        return np.sum(mu[mask] * np.log(mu[mask] / nu[mask]))


def gaussian_density(x: np.ndarray, sigma: float = 1.0) -> float:
    """Evaluate standard Gaussian density at point x ∈ ℝ^n."""
    return np.exp(-np.sum(x**2) / (2 * sigma**2)) / (
        (2 * np.pi * sigma**2) ** (len(x) / 2))


def discretize_product_density(
    density_1d: Callable[[float], float],
    cdf_1d: Callable[[float], float],
    n: int,
    h: float,
    R: float
) -> CertifiedDiscretization:
    """
    Discretize an n-dimensional product density f(x) = ∏ f_i(x_i).

    For product densities, exact cell integrals decompose as products
    of 1D integrals, enabling efficient exact computation.

    Args:
        density_1d: Marginal density function
        cdf_1d: Marginal CDF function
        n: Dimension
        h: Grid spacing
        R: Half-side of bounding box

    Returns:
        CertifiedDiscretization with exact cell integrals
    """
    n_per_side = int(np.ceil(2 * R / h))
    edges = np.linspace(-R, -R + n_per_side * h, n_per_side + 1)
    centers = (edges[:-1] + edges[1:]) / 2

    # 1D cell integrals via CDF differences
    cdf_vals = np.array([cdf_1d(e) for e in edges])
    cell_integrals_1d = np.diff(cdf_vals)

    # 1D point samples
    point_samples_1d = np.array([density_1d(c) for c in centers]) * h

    # n-dimensional: take tensor products
    # For cell weights: product of 1D integrals
    cell_weights = cell_integrals_1d.copy()
    for _ in range(n - 1):
        cell_weights = np.outer(cell_weights, cell_integrals_1d).flatten()

    point_weights = point_samples_1d.copy()
    for _ in range(n - 1):
        point_weights = np.outer(point_weights, point_samples_1d).flatten()

    # Cell centers in n dimensions
    grids = [centers] * n
    mesh = np.meshgrid(*grids, indexing='ij')
    cell_centers_nd = np.stack([m.flatten() for m in mesh], axis=-1)

    # Truncation error: mass outside [-R, R]^n
    mass_inside_1d = cdf_1d(R) - cdf_1d(-R)
    trunc_error = 1.0 - mass_inside_1d ** n

    # Local oscillation bound for Gaussian: max gradient * cell diameter
    # For N(0,σ²), |∇f| ≤ f * |x|/σ², max over cell
    # Approximate: L * h * √n where L = max |∇f|
    L_approx = 1.0 / (2 * np.pi * np.e)  # max |∇f| for 2D standard Gaussian
    osc = L_approx * h * np.sqrt(n)

    return CertifiedDiscretization(
        n=n, h=h, R=R,
        cell_centers=cell_centers_nd,
        cell_weights=cell_weights,
        point_weights=point_weights,
        truncation_error=trunc_error,
        local_oscillation=osc
    )


def gaussian_discretization(n: int, h: float, R: float = 5.0,
                             sigma: float = 1.0) -> CertifiedDiscretization:
    """
    Discretize the standard Gaussian on ℝ^n.

    Uses exact CDF-based cell integrals for the ideal discretization
    and point sampling at cell centers for the approximate version.

    Complexity: O((2R/h)^n) time and space.
    """
    def density_1d(x):
        return np.exp(-x**2 / (2*sigma**2)) / (np.sqrt(2*np.pi) * sigma)

    def cdf_1d(x):
        return 0.5 * (1 + erf(x / (sigma * np.sqrt(2))))

    return discretize_product_density(density_1d, cdf_1d, n, h, R)


@dataclass
class RobustnessCertificate:
    """
    A certified robustness certificate for a discretized distribution.

    Contains all the quantitative bounds produced by the transfer pipeline.
    """
    coefficient_distance: float
    chi_squared_divergence: float
    kl_divergence: float
    isoperimetric_constant: float
    error_rate: float  # A such that coeffDist ≈ A*h
    certified_gap_lower_bound: float
    certified_mixing_time: float
    stability_radius: float
    grid_spacing: float
    num_cells: int
    dimension: int
    truncation_error: float

    @property
    def gap_recovery_fraction(self) -> float:
        """Fraction of continuous gap preserved after discretization."""
        if self.isoperimetric_constant <= 0:
            return 0.0
        return self.certified_gap_lower_bound / self.isoperimetric_constant


class RobustnessTransferPipeline:
    """
    End-to-end certified transfer from continuous isoperimetry to discrete mixing.

    The pipeline implements:
    1. Grid discretization with certified error bounds
    2. Perturbation accumulation via iterated gap degradation
    3. Mixing time certification from residual gap

    Algorithm:
        Input: density f, isoperimetric constant ψ, grid spacing h
        Step 1: Compute discretization D_h(f) with point and cell weights
        Step 2: Compute coeffDist(point, cell) = Σ |μ_h(z) - ν_h(z)|
        Step 3: Extract error rate A = coeffDist / h
        Step 4: Compute certified gap: gap ≥ ψ - 2*A*h
        Step 5: Compute stability radius: r = ψ / (2*A)
        Step 6: Compute mixing time: t_mix ≤ (1/gap) * ln(N/η)
        Output: RobustnessCertificate with all bounds

    Complexity:
        Time: O(N) where N = (2R/h)^n is the number of cells
        Space: O(N)
    """

    def __init__(self, isoperimetric_constant: float,
                 mixing_eta: float = 0.01):
        """
        Args:
            isoperimetric_constant: ψ > 0, the continuous isoperimetric constant
            mixing_eta: Target total variation distance for mixing
        """
        assert isoperimetric_constant > 0
        assert 0 < mixing_eta < 1
        self.psi = isoperimetric_constant
        self.eta = mixing_eta

    def certify(self, disc: CertifiedDiscretization) -> RobustnessCertificate:
        """
        Run the full certification pipeline on a discretization.

        Returns a RobustnessCertificate with all quantitative bounds.
        """
        # Step 1: Compute distances
        cd = disc.coefficient_distance
        chi2 = disc.chi_squared
        kl = disc.kl_divergence

        # Step 2: Error rate
        A = cd / disc.h if disc.h > 0 else 0.0

        # Step 3: Certified gap (from Theorem 1: discretization_iterated_gap)
        gap = max(0.0, self.psi - 2 * A * disc.h)

        # Step 4: Stability radius (from stabilityRadius_pos)
        stab_radius = self.psi / (2 * A) if A > 0 else float('inf')

        # Step 5: Mixing time (from mixingBound_of_gap)
        N = disc.num_cells
        if gap > 0:
            mix_time = (1.0 / gap) * np.log(N / self.eta)
        else:
            mix_time = float('inf')

        return RobustnessCertificate(
            coefficient_distance=cd,
            chi_squared_divergence=chi2,
            kl_divergence=kl,
            isoperimetric_constant=self.psi,
            error_rate=A,
            certified_gap_lower_bound=gap,
            certified_mixing_time=mix_time,
            stability_radius=stab_radius,
            grid_spacing=disc.h,
            num_cells=N,
            dimension=disc.n,
            truncation_error=disc.truncation_error
        )

    def sweep(self, discretizer: Callable[[float], CertifiedDiscretization],
              h_values: List[float]) -> List[RobustnessCertificate]:
        """
        Run the pipeline over multiple grid spacings.

        Useful for convergence analysis and conjecture testing.
        """
        return [self.certify(discretizer(h)) for h in h_values]


def convergence_analysis(certs: List[RobustnessCertificate]) -> Dict:
    """
    Analyze convergence rates from a sequence of certificates.

    Returns estimated convergence exponents for:
    - Coefficient distance: should be O(h^p) with p ≈ 2 for Gaussian
    - KL divergence: should be O(h^q) with q ≈ 2p
    - Gap deficit: should be O(h^r)
    """
    h_vals = [c.grid_spacing for c in certs]
    cd_vals = [c.coefficient_distance for c in certs]
    kl_vals = [c.kl_divergence for c in certs]
    deficit_vals = [c.isoperimetric_constant - c.certified_gap_lower_bound
                    for c in certs]

    def estimate_exponent(h, vals):
        exponents = []
        for i in range(1, len(h)):
            if vals[i-1] > 1e-15 and vals[i] > 1e-15:
                exp = np.log(vals[i-1] / vals[i]) / np.log(h[i-1] / h[i])
                exponents.append(exp)
        return exponents

    return {
        'cd_exponents': estimate_exponent(h_vals, cd_vals),
        'kl_exponents': estimate_exponent(h_vals, kl_vals),
        'deficit_exponents': estimate_exponent(h_vals, deficit_vals),
    }


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Standard Gaussian on ℝ²
    psi = 1.0 / np.sqrt(2 * np.pi)  # Cheeger constant

    pipeline = RobustnessTransferPipeline(
        isoperimetric_constant=psi,
        mixing_eta=0.01
    )

    h_values = [1.0, 0.5, 0.25, 0.125, 0.0625]

    print("Certified Robustness Transfer Pipeline — Gaussian ℝ²")
    print("=" * 60)

    for h in h_values:
        disc = gaussian_discretization(n=2, h=h, R=5.0)
        cert = pipeline.certify(disc)

        print(f"\nh = {h:.4f}:")
        print(f"  Cells: {cert.num_cells}")
        print(f"  CoeffDist: {cert.coefficient_distance:.2e}")
        print(f"  KL div: {cert.kl_divergence:.2e}")
        print(f"  Certified gap: {cert.certified_gap_lower_bound:.6f}")
        print(f"  Gap recovery: {cert.gap_recovery_fraction*100:.1f}%")
        print(f"  Mixing time: {cert.certified_mixing_time:.1f}")
        print(f"  Stability radius: {cert.stability_radius:.4f}")
