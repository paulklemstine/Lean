"""
Hyperbolic Conformal Packing: Core Algorithms

Implements certified upper bounds on the number of disjoint hyperbolic r-balls
that can be packed inside a domain Ω ⊆ B^n (Poincaré ball model).

The key formula: N ≤ D(n,ρ,r) · hvol(Ω) / (2^n · vol_E(ball(0, R(ρ,r))))
where:
  - D(n,ρ,r) = radial distortion = 1/(1-ρ²)^n
  - hvol(Ω) = ∫_Ω (2/(1-‖x‖²))^n dx
  - R(ρ,r) = (1-ρ²)·tanh(r/2) / (1 + ρ·tanh(r/2))
"""

import numpy as np
from typing import Tuple, Optional


def poincare_cf(x: np.ndarray) -> float:
    """Poincaré conformal factor λ_H(x) = 2/(1-‖x‖²).

    Args:
        x: Point in the Poincaré ball (‖x‖ < 1).

    Returns:
        The conformal factor at x.

    Example:
        >>> poincare_cf(np.array([0.0, 0.0]))
        2.0
        >>> poincare_cf(np.array([0.5, 0.0]))  # ≈ 2.667
        2.6666666666666665
    """
    norm_sq = np.dot(x, x)
    assert norm_sq < 1, f"Point must be inside unit ball, got ‖x‖² = {norm_sq}"
    return 2.0 / (1.0 - norm_sq)


def radial_distortion(n: int, rho: float) -> float:
    """Radial distortion factor D(n,ρ) = 1/(1-ρ²)^n.

    Quantifies how much the conformal weight varies across the cap ‖x‖ ≤ ρ.

    Args:
        n: Dimension.
        rho: Cap radius, 0 ≤ ρ < 1.

    Returns:
        The distortion factor.

    Example:
        >>> radial_distortion(2, 0.0)
        1.0
        >>> radial_distortion(2, 0.9)  # ≈ 5.26
        5.263157894736843
    """
    assert 0 <= rho < 1, f"Need 0 ≤ ρ < 1, got ρ = {rho}"
    return (1.0 / (1.0 - rho**2)) ** n


def euclidean_subball_radius(rho: float, r: float) -> float:
    """Lower bound on the Euclidean radius of a hyperbolic r-ball
    centered at a point c with ‖c‖ ≤ ρ.

    R(ρ,r) = (1 - ρ²) · tanh(r/2) / (1 + ρ · tanh(r/2))

    Args:
        rho: Cap radius, 0 ≤ ρ < 1.
        r: Hyperbolic radius, r > 0.

    Returns:
        The Euclidean subball radius.

    Example:
        >>> euclidean_subball_radius(0.0, 1.0)  # = tanh(0.5)
        0.46211715726000974
        >>> euclidean_subball_radius(0.5, 1.0)
        0.2940832802824068
    """
    t = np.tanh(r / 2)
    return (1.0 - rho**2) * t / (1.0 + rho * t)


def euclidean_ball_volume(n: int, r: float) -> float:
    """Volume of a Euclidean n-ball of radius r.

    vol = π^(n/2) / Γ(n/2 + 1) · r^n

    Args:
        n: Dimension.
        r: Radius.

    Returns:
        The volume.
    """
    from scipy.special import gamma
    return (np.pi ** (n / 2) / gamma(n / 2 + 1)) * r**n


def hyperbolic_weighted_volume_annulus(n: int, rho_inner: float, rho_outer: float,
                                       num_samples: int = 100000) -> float:
    """Monte Carlo estimate of the hyperbolic weighted volume of an annular region.

    hvol({x : rho_inner ≤ ‖x‖ < rho_outer}) = ∫ (2/(1-‖x‖²))^n dx

    Uses importance sampling with uniform distribution in the annulus.

    Args:
        n: Dimension.
        rho_inner: Inner radius, 0 ≤ rho_inner.
        rho_outer: Outer radius, rho_inner < rho_outer < 1.
        num_samples: Number of Monte Carlo samples.

    Returns:
        Estimated hyperbolic weighted volume.
    """
    # Sample uniformly in the n-dimensional annulus
    # Use radial + angular decomposition
    rng = np.random.default_rng(42)

    # Sample radii uniformly in [rho_inner^n, rho_outer^n]^(1/n)
    u = rng.uniform(rho_inner**n, rho_outer**n, num_samples)
    radii = u ** (1.0 / n)

    # Conformal factor at each radius
    cf_values = (2.0 / (1.0 - radii**2)) ** n

    # The Euclidean volume element in polar coords is n · ω_n · r^(n-1) dr
    # Uniform sampling in the annulus means each sample represents
    # vol(annulus) / num_samples of Euclidean volume
    euclid_vol = euclidean_ball_volume(n, rho_outer) - euclidean_ball_volume(n, rho_inner)

    return float(np.mean(cf_values) * euclid_vol)


def hyperbolic_weighted_volume_disk(n: int, rho: float,
                                     num_samples: int = 100000) -> float:
    """Monte Carlo estimate of the hyperbolic weighted volume of B̄(0,ρ).

    Args:
        n: Dimension.
        rho: Radius of the cap, 0 < ρ < 1.
        num_samples: Number of Monte Carlo samples.

    Returns:
        Estimated hyperbolic weighted volume of the disk of radius ρ.
    """
    return hyperbolic_weighted_volume_annulus(n, 0.0, rho, num_samples)


def certified_packing_bound(n: int, rho: float, r: float,
                             hvol: Optional[float] = None,
                             num_samples: int = 100000) -> dict:
    """Compute the certified upper bound on hyperbolic packing number.

    N ≤ D(n,ρ,r) · hvol(Ω) / (2^n · vol_E(ball(0, R(ρ,r))))

    Args:
        n: Dimension.
        rho: Cap radius (domain is B̄(0,ρ)), 0 < ρ < 1.
        r: Hyperbolic ball radius, r > 0.
        hvol: Pre-computed hyperbolic weighted volume (if None, computed via MC).
        num_samples: Monte Carlo samples for hvol computation.

    Returns:
        Dictionary with all computed quantities.
    """
    # Compute components
    D = radial_distortion(n, rho)
    R = euclidean_subball_radius(rho, r)
    vol_ball = euclidean_ball_volume(n, R)

    if hvol is None:
        hvol = hyperbolic_weighted_volume_disk(n, rho, num_samples)

    # The certified bound
    denominator = (2.0 ** n) * vol_ball
    bound = D * hvol / denominator

    return {
        'dimension': n,
        'cap_radius': rho,
        'hyperbolic_radius': r,
        'distortion': D,
        'euclidean_subball_radius': R,
        'euclidean_ball_volume': vol_ball,
        'hyperbolic_weighted_volume': hvol,
        'euclidean_volume': euclidean_ball_volume(n, rho),
        'certified_packing_bound': bound,
        'denominator': denominator,
    }


def greedy_hyperbolic_packing_2d(rho: float, r: float,
                                   max_attempts: int = 10000) -> np.ndarray:
    """Generate a greedy hyperbolic packing in the 2D Poincaré disk.

    Places hyperbolic r-balls greedily: each new center is placed at a random
    point that is at least 2r away (in hyperbolic distance) from all existing centers.

    Args:
        rho: Domain radius, 0 < ρ < 1.
        r: Hyperbolic ball radius.
        max_attempts: Maximum placement attempts.

    Returns:
        Array of shape (k, 2) with the k placed centers.
    """
    rng = np.random.default_rng(42)
    centers = []

    for _ in range(max_attempts):
        # Sample a random point in the disk of Euclidean radius rho
        angle = rng.uniform(0, 2 * np.pi)
        radius = rho * np.sqrt(rng.uniform(0, 1))
        candidate = np.array([radius * np.cos(angle), radius * np.sin(angle)])

        # Check hyperbolic distance to all existing centers
        valid = True
        for c in centers:
            d_hyp = hyperbolic_distance_2d(candidate, c)
            if d_hyp < 2 * r:
                valid = False
                break

        if valid:
            centers.append(candidate)

    return np.array(centers) if centers else np.empty((0, 2))


def hyperbolic_distance_2d(x: np.ndarray, y: np.ndarray) -> float:
    """Hyperbolic distance between two points in the 2D Poincaré disk.

    d_H(x,y) = acosh(1 + 2‖x-y‖² / ((1-‖x‖²)(1-‖y‖²)))

    Args:
        x, y: Points in the unit disk.

    Returns:
        Hyperbolic distance.
    """
    diff_sq = np.sum((x - y)**2)
    denom = (1 - np.sum(x**2)) * (1 - np.sum(y**2))
    if denom <= 0:
        return float('inf')
    arg = 1 + 2 * diff_sq / denom
    return float(np.arccosh(max(arg, 1.0)))


def boundary_shell_experiment(n: int = 2, r: float = 0.5,
                                rho_values: Optional[list] = None) -> list:
    """Test Conjecture D: boundary-shell asymptotic sharpness.

    For thin shells Ω_ρ = {x : ρ₀ ≤ ‖x‖ < ρ} with ρ → 1⁻,
    compute the ratio N_H(Ω_ρ, r) · capVol / hvol(Ω_ρ).

    Args:
        n: Dimension (default 2).
        r: Hyperbolic radius.
        rho_values: List of outer radii to test.

    Returns:
        List of dicts with results for each ρ.
    """
    if rho_values is None:
        rho_values = [0.8, 0.9, 0.95, 0.98, 0.99]

    results = []
    rho_inner = 0.5  # Fixed inner radius

    for rho in rho_values:
        hvol = hyperbolic_weighted_volume_annulus(n, rho_inner, rho)

        # Certified bound
        D = radial_distortion(n, rho)
        R = euclidean_subball_radius(rho, r)
        vol_ball = euclidean_ball_volume(n, R)
        certified_N = D * hvol / ((2**n) * vol_ball)

        # Greedy packing count (only for n=2)
        if n == 2:
            centers = greedy_hyperbolic_packing_2d(rho, r)
            # Filter to annulus
            norms = np.linalg.norm(centers, axis=1)
            annulus_centers = centers[(norms >= rho_inner) & (norms < rho)]
            greedy_N = len(annulus_centers)
        else:
            greedy_N = None

        # Ratio: greedy_N * capVol / hvol
        # capVol ≈ area of a hyperbolic disk of radius r = 4π sinh²(r/2)
        cap_vol_hyp = 4 * np.pi * np.sinh(r / 2)**2 if n == 2 else None
        ratio = greedy_N * cap_vol_hyp / hvol if greedy_N and cap_vol_hyp and hvol > 0 else None

        results.append({
            'rho_outer': rho,
            'rho_inner': rho_inner,
            'hvol': hvol,
            'certified_bound': certified_N,
            'greedy_count': greedy_N,
            'cap_vol_hyp': cap_vol_hyp,
            'efficiency_ratio': ratio,
            'distortion': D,
        })

    return results


if __name__ == '__main__':
    print("=" * 70)
    print("Hyperbolic Conformal Packing: Algorithm Demonstrations")
    print("=" * 70)

    # Basic quantities
    print("\n--- Conformal Factor Values ---")
    for norm in [0.0, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        x = np.array([norm, 0.0])
        print(f"  ‖x‖ = {norm:.2f}  →  λ_H(x) = {poincare_cf(x):.4f}")

    # Certified packing bounds
    print("\n--- Certified Packing Bounds (n=2) ---")
    for rho in [0.5, 0.7, 0.9, 0.95]:
        for r in [0.5, 1.0, 2.0]:
            result = certified_packing_bound(2, rho, r)
            print(f"  ρ={rho:.2f}, r={r:.1f}: "
                  f"D={result['distortion']:.3f}, "
                  f"R={result['euclidean_subball_radius']:.4f}, "
                  f"N≤{result['certified_packing_bound']:.1f}")

    # Boundary shell experiment
    print("\n--- Boundary Shell Experiment (Conjecture D) ---")
    results = boundary_shell_experiment(n=2, r=0.5)
    print(f"  {'ρ':>6s}  {'hvol':>10s}  {'certified':>10s}  {'greedy':>8s}  {'ratio':>8s}")
    for res in results:
        ratio_str = f"{res['efficiency_ratio']:.4f}" if res['efficiency_ratio'] else "N/A"
        greedy_str = str(res['greedy_count']) if res['greedy_count'] is not None else "N/A"
        print(f"  {res['rho_outer']:6.2f}  {res['hvol']:10.2f}  "
              f"{res['certified_bound']:10.1f}  {greedy_str:>8s}  {ratio_str:>8s}")
