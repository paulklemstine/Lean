#!/usr/bin/env python3
"""
Algorithms for Dimensional Gravity Analysis

Type-hinted implementations of the key mathematical algorithms
used in the Flatland Catastrophe analysis.
"""

import math
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class GravitationalDimension:
    """A gravitational theory in n spatial dimensions."""
    n: int

    def __post_init__(self) -> None:
        if self.n < 2:
            raise ValueError(f"Dimension must be ≥ 2, got {self.n}")

    @property
    def force_exponent(self) -> int:
        """Force exponent: F ∝ r^(1-n)."""
        return 1 - self.n

    @property
    def stability_param(self) -> int:
        """Stability parameter σ = 4 - n."""
        return 4 - self.n

    @property
    def has_stable_orbits(self) -> bool:
        """Whether circular orbits are linearly stable."""
        return self.stability_param > 0

    @property
    def apsidal_ratio(self) -> Optional[float]:
        """Apsidal angle ratio 1/√(4-n), or None if unstable."""
        if self.stability_param <= 0:
            return None
        return 1.0 / math.sqrt(self.stability_param)

    @property
    def has_closed_orbits(self) -> bool:
        """Whether orbits close (apsidal ratio is rational).
        In practice, only n=3 gives rational ratio (1/√1 = 1)."""
        if not self.has_stable_orbits:
            return False
        # √(4-n) is rational iff (4-n) is a perfect square
        s = self.stability_param
        root = int(math.isqrt(s))
        return root * root == s

    @property
    def has_escape_velocity(self) -> bool:
        """Whether particles can escape to infinity."""
        return self.n >= 3

    @property
    def is_logarithmic(self) -> bool:
        """Whether the potential is logarithmic (n=2 case)."""
        return self.n == 2

    def classify(self) -> str:
        """Classify the gravitational dimension."""
        if self.n == 2:
            return "flatland"
        elif self.n == 3:
            return "goldilocks"
        elif self.n == 4:
            return "marginal"
        else:
            return "catastrophic"

    def viability_score(self) -> int:
        """Count viability conditions: stability + closure + escape."""
        return (
            (1 if self.has_stable_orbits else 0) +
            (1 if self.has_closed_orbits else 0) +
            (1 if self.has_escape_velocity else 0)
        )


def effective_potential_2d(r: float, L: float, k: float = 1.0) -> float:
    """2D effective potential: V_eff(r) = k·ln(r) + L²/(2r²)."""
    if r <= 0:
        raise ValueError("r must be positive")
    return k * math.log(r) + L**2 / (2 * r**2)


def effective_potential_deriv_2d(r: float, L: float, k: float = 1.0) -> float:
    """Derivative of 2D effective potential: V_eff'(r) = k/r - L²/r³."""
    if r <= 0:
        raise ValueError("r must be positive")
    return k / r - L**2 / r**3


def effective_potential_deriv2_2d(r: float, L: float, k: float = 1.0) -> float:
    """Second derivative: V_eff''(r) = -k/r² + 3L²/r⁴."""
    if r <= 0:
        raise ValueError("r must be positive")
    return -k / r**2 + 3 * L**2 / r**4


def circular_orbit_radius(L: float, k: float = 1.0, m: float = 1.0) -> float:
    """Circular orbit radius: r₀ = |L|/√(mk)."""
    return abs(L) / math.sqrt(m * k)


def verify_critical_point(L: float, k: float = 1.0) -> Tuple[float, float]:
    """Verify that r₀ = |L|/√k is a critical point of V_eff.
    Returns (V_eff'(r₀), V_eff''(r₀))."""
    r0 = circular_orbit_radius(L, k)
    deriv1 = effective_potential_deriv_2d(r0, L, k)
    deriv2 = effective_potential_deriv2_2d(r0, L, k)
    return deriv1, deriv2


def simulate_orbit(
    n_dim: int,
    steps: int = 10000,
    dt: float = 0.001,
    r0: float = 1.0,
    vr0: float = 0.1,
    L: float = 1.0,
    k: float = 1.0,
) -> List[Tuple[float, float]]:
    """Simulate a gravitational orbit in n dimensions.

    Uses Störmer-Verlet integration for the radial equation:
      r'' = L²/r³ - k·r^(1-n)

    Returns list of (r, θ) pairs.
    """
    r = r0
    vr = vr0
    theta = 0.0
    trajectory: List[Tuple[float, float]] = []

    force_exp = 1 - n_dim  # F ∝ r^(1-n)

    for _ in range(steps):
        trajectory.append((r, theta))

        # Radial acceleration: centrifugal - gravitational
        ar = L**2 / r**3 - k * r**force_exp

        # Störmer-Verlet
        r_new = r + vr * dt + 0.5 * ar * dt**2
        r_new = max(r_new, 1e-6)  # Prevent collision

        ar_new = L**2 / r_new**3 - k * r_new**force_exp
        vr = vr + 0.5 * (ar + ar_new) * dt
        r = r_new
        theta += L / r**2 * dt

    return trajectory


def compute_apsidal_positions(
    alpha: float, N: int
) -> List[float]:
    """Compute the fractional parts {n·α} for n = 0, ..., N-1.

    For 2D gravity, α = 1/√2 gives the apsidal angular positions.
    """
    return [n * alpha - math.floor(n * alpha) for n in range(N)]


def is_equidistributed(
    sequence: List[float], n_bins: int = 20, tolerance: float = 0.3
) -> bool:
    """Test whether a sequence in [0,1) is approximately equidistributed.

    Uses chi-squared-like test: check if all bins have
    counts within tolerance of the expected count.
    """
    N = len(sequence)
    expected = N / n_bins
    bins = [0] * n_bins

    for x in sequence:
        bin_idx = min(int(x * n_bins), n_bins - 1)
        bins[bin_idx] += 1

    return all(abs(count - expected) / expected < tolerance for count in bins)


def goldilocks_search(max_dim: int = 20) -> List[int]:
    """Search for Goldilocks dimensions among n = 2, ..., max_dim.

    A dimension is Goldilocks if it has stable orbits, closed orbits,
    and escape velocity. Returns list of qualifying dimensions.
    """
    result: List[int] = []
    for n in range(2, max_dim + 1):
        g = GravitationalDimension(n)
        if g.viability_score() == 3:
            result.append(n)
    return result


def conjectured_intersections(N: int) -> int:
    """Conjectured self-intersection count after N radial oscillations: N(N-1)/2."""
    return N * (N - 1) // 2


# ============================================================
# Self-tests
# ============================================================

if __name__ == "__main__":
    # Test GravitationalDimension
    for n in range(2, 8):
        g = GravitationalDimension(n)
        print(f"n={n}: class={g.classify():15s} score={g.viability_score()}/3 "
              f"stable={g.has_stable_orbits} closed={g.has_closed_orbits} "
              f"escape={g.has_escape_velocity}")

    # Verify Goldilocks uniqueness
    goldilocks = goldilocks_search(100)
    print(f"\nGoldilocks dimensions (n ≤ 100): {goldilocks}")
    assert goldilocks == [3], f"Expected [3], got {goldilocks}"

    # Verify critical point
    for L in [0.5, 1.0, 2.0]:
        d1, d2 = verify_critical_point(L)
        print(f"L={L}: V'(r₀) = {d1:.2e}, V''(r₀) = {d2:.4f} > 0 ✓")
        assert abs(d1) < 1e-10, f"Critical point check failed: V'(r₀) = {d1}"
        assert d2 > 0, f"Stability check failed: V''(r₀) = {d2}"

    # Test equidistribution
    alpha = 1.0 / math.sqrt(2)
    fracs = compute_apsidal_positions(alpha, 10000)
    eq = is_equidistributed(fracs)
    print(f"\nEquidistribution of {{n/√2}} (N=10000): {eq}")
    assert eq, "Equidistribution test failed"

    print("\nAll tests passed ✓")
