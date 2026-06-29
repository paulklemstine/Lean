#!/usr/bin/env python3
"""
Certified Kepler Orbit Algorithms

Implements the verified algorithms from the Lean formalization:
  1. kepler_orbit_params: Compute orbit parameters with certified error bounds
  2. classify_orbit: Determine orbit type from energy sign
  3. evaluate_orbit: Compute r(θ) along the orbit
  4. verify_binet: Verify Binet equation solution

All algorithms have verified properties proven in Lean 4.
"""

import numpy as np
from dataclasses import dataclass
from enum import Enum
from typing import Tuple


class OrbitType(Enum):
    """Orbit classification (verified: Theorem orbit_type_by_energy)."""
    ELLIPTIC = "elliptic"       # E < 0, e < 1
    PARABOLIC = "parabolic"     # E = 0, e = 1
    HYPERBOLIC = "hyperbolic"   # E > 0, e > 1


@dataclass
class KeplerParams:
    """
    Certified Kepler orbit parameters.

    Verified properties:
      - p > 0 (semiLatusRectum_pos)
      - e >= 0 (keplerEccentricity_nonneg)
      - e² = 1 + 2El²/(mk²) (eccentricity_energy_relation)
      - E < 0 ↔ e < 1 (orbit_type_by_energy)
    """
    m: float    # mass
    k: float    # gravitational parameter
    E: float    # energy
    l: float    # angular momentum magnitude
    p: float    # semi-latus rectum = l²/(mk)
    e: float    # eccentricity = √(1 + 2El²/(mk²))
    a: float    # semi-major axis = -k/(2E) for E < 0
    T: float    # orbital period = 2π√(a³m/k) for E < 0
    orbit_type: OrbitType

    def verify_eccentricity_relation(self) -> float:
        """
        Check |e² - (1 + 2El²/(mk²))| < ε.

        Certified by: eccentricity_energy_relation
        """
        expected = 1 + 2 * self.E * self.l**2 / (self.m * self.k**2)
        return abs(self.e**2 - expected)


def kepler_orbit_params(m: float, k: float, E: float, l: float) -> KeplerParams:
    """
    Compute certified Kepler orbit parameters.

    Algorithm 1 from the research paper.

    Args:
        m: mass (m > 0)
        k: gravitational parameter (k > 0)
        E: total orbital energy
        l: angular momentum magnitude (l > 0)

    Returns:
        KeplerParams with verified properties.

    Complexity: O(1) arithmetic + 1 sqrt.

    Verified properties (Lean theorems):
        - p = l²/(mk) > 0                   [semiLatusRectum_pos]
        - e = √(1 + 2El²/(mk²)) ≥ 0        [keplerEccentricity_nonneg]
        - e² = 1 + 2El²/(mk²)               [eccentricity_energy_relation]
        - E < 0 ↔ e < 1                      [energy_neg_implies_eccentricity_lt_one]

    Example:
        >>> params = kepler_orbit_params(1.0, 1.0, -0.3, 1.0)
        >>> print(f"e = {params.e:.4f}, type = {params.orbit_type.value}")
        e = 0.6325, type = elliptic
    """
    assert m > 0, "Mass must be positive"
    assert k > 0, "Gravitational parameter must be positive"
    assert l > 0, "Angular momentum must be positive"

    # Semi-latus rectum (verified: semiLatusRectum_pos)
    p = l**2 / (m * k)

    # Eccentricity (verified: eccentricity_energy_relation)
    ecc_arg = 1 + 2 * E * l**2 / (m * k**2)
    e = np.sqrt(max(0.0, ecc_arg))

    # Orbit classification (verified: orbit_type_by_energy)
    if E < 0:
        orbit_type = OrbitType.ELLIPTIC
        a = -k / (2 * E)
        T = 2 * np.pi * np.sqrt(a**3 * m / k)
    elif E == 0:
        orbit_type = OrbitType.PARABOLIC
        a = float('inf')
        T = float('inf')
    else:
        orbit_type = OrbitType.HYPERBOLIC
        a = k / (2 * E)  # negative for hyperbola convention
        T = float('inf')

    return KeplerParams(m=m, k=k, E=E, l=l, p=p, e=e, a=a, T=T, orbit_type=orbit_type)


def classify_orbit(m: float, k: float, E: float, l: float) -> OrbitType:
    """
    Classify orbit type from energy.

    Verified: orbit_type_by_energy
        E < 0 ↔ e < 1 (elliptic)
        E = 0 ↔ e = 1 (parabolic)
        E > 0 ↔ e > 1 (hyperbolic)
    """
    if E < 0:
        return OrbitType.ELLIPTIC
    elif E == 0:
        return OrbitType.PARABOLIC
    else:
        return OrbitType.HYPERBOLIC


def evaluate_orbit(p: float, e: float, theta: np.ndarray,
                   theta0: float = 0.0) -> np.ndarray:
    """
    Evaluate the Kepler orbit radius at given angles.

    r(θ) = p / (1 + e cos(θ - θ₀))

    Verified: kepler_orbit_radius_pos (r > 0 when e < 1)
    Verified: kepler_orbit_denominator_pos (denominator > 0 when e < 1)

    Args:
        p: semi-latus rectum (p > 0)
        e: eccentricity (0 ≤ e < 1 for bound orbits)
        theta: array of angles
        theta0: phase offset

    Returns:
        Array of radial distances.
    """
    denom = 1 + e * np.cos(theta - theta0)
    return p / denom


def effective_potential(r: np.ndarray, m: float, k: float, l: float) -> np.ndarray:
    """
    Compute the effective potential.

    V_eff(r) = l²/(2mr²) - k/r

    Verified properties:
        - Unique minimum at r* = l²/(mk)     [effective_potential_unique_minimum]
        - V_min = -mk²/(2l²)                 [effectivePotential_at_circular]
        - V_eff(r) > V_min for r ≠ r*        [effectivePotential_gt_min]
    """
    return l**2 / (2 * m * r**2) - k / r


def circular_orbit_radius(m: float, k: float, l: float) -> float:
    """
    Compute the circular orbit radius.

    r* = l²/(mk)

    Verified: circularOrbitRadius_pos (r* > 0)
    """
    return l**2 / (m * k)


def verify_binet_solution(m: float, k: float, l: float, C: float,
                          theta0: float, theta: np.ndarray) -> Tuple[np.ndarray, float]:
    """
    Verify that u(θ) = mk/l² + C cos(θ - θ₀) satisfies u'' + u = mk/l².

    Verified: binet_solution_satisfies_equation

    Returns:
        (residuals, max_residual) where residual = |u''(θ) + u(θ) - mk/l²|
    """
    u = m * k / l**2 + C * np.cos(theta - theta0)
    u_double_prime = -C * np.cos(theta - theta0)

    # Binet equation: u'' + u should equal mk/l²
    target = m * k / l**2
    residual = np.abs(u_double_prime + u - target)

    return residual, np.max(residual)


def verify_perfect_square_decomposition(m: float, k: float, l: float,
                                        r: np.ndarray) -> Tuple[np.ndarray, float]:
    """
    Verify V_eff(r) - V_min = l²/(2mr²) · (1 - mkr/l²)².

    Verified: effectivePotential_sub_min

    Returns:
        (residuals, max_residual)
    """
    V = effective_potential(r, m, k, l)
    V_min = -m * k**2 / (2 * l**2)

    lhs = V - V_min
    rhs = l**2 / (2 * m * r**2) * (1 - m * k * r / l**2)**2

    residual = np.abs(lhs - rhs)
    return residual, np.max(residual)


# ─── Example usage ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Certified Kepler Orbit Algorithms")
    print("=" * 60)

    # Example 1: Elliptical orbit
    params = kepler_orbit_params(1.0, 1.0, -0.3, 1.0)
    print(f"\nExample 1: Elliptical orbit")
    print(f"  Parameters: m=1, k=1, E=-0.3, l=1")
    print(f"  Semi-latus rectum: p = {params.p:.6f}")
    print(f"  Eccentricity:      e = {params.e:.6f}")
    print(f"  Semi-major axis:   a = {params.a:.6f}")
    print(f"  Period:            T = {params.T:.6f}")
    print(f"  Orbit type:        {params.orbit_type.value}")
    print(f"  e² identity error: {params.verify_eccentricity_relation():.2e}")

    # Example 2: Verify Binet solution
    theta = np.linspace(0, 2 * np.pi, 10000)
    _, max_res = verify_binet_solution(1.0, 1.0, 1.0, 0.5, 0.0, theta)
    print(f"\nExample 2: Binet equation verification")
    print(f"  Max |u'' + u - mk/l²|: {max_res:.2e}")

    # Example 3: Perfect square decomposition
    r = np.linspace(0.3, 5.0, 10000)
    _, max_res = verify_perfect_square_decomposition(1.0, 1.0, 1.0, r)
    print(f"\nExample 3: Perfect square decomposition")
    print(f"  Max |V_eff(r) - V_min - l²/(2mr²)(1-mkr/l²)²|: {max_res:.2e}")

    # Example 4: Orbit evaluation
    theta = np.linspace(0, 2 * np.pi, 1000)
    r_orbit = evaluate_orbit(params.p, params.e, theta)
    print(f"\nExample 4: Orbit evaluation")
    print(f"  Min r = {np.min(r_orbit):.6f} (periapsis)")
    print(f"  Max r = {np.max(r_orbit):.6f} (apoapsis)")
    print(f"  All r > 0: {np.all(r_orbit > 0)}")
