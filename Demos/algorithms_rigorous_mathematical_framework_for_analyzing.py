"""
Algorithms for Dimensional Gravity Analysis

Implements the mathematical framework for analyzing gravitational orbits
across spatial dimensions, including apsidal angle computation, stability
analysis, and Bertrand classification.
"""

from typing import Optional
import math


def apsidal_ratio(n: int) -> float:
    """Compute the apsidal angle ratio ρ(n) = √(4 - n) for spatial dimension n.

    Returns 0.0 for n ≥ 4 (no stable orbits).

    Args:
        n: Spatial dimension (positive integer)

    Returns:
        The apsidal ratio √(4-n), or 0 if n ≥ 4
    """
    arg = 4 - n
    if arg <= 0:
        return 0.0
    return math.sqrt(arg)


def apsidal_angle(n: int) -> float:
    """Compute the apsidal angle Ψ = π/√(4-n) for spatial dimension n.

    The apsidal angle is the angle swept between consecutive apsides
    (perihelion/aphelion) of a nearly-circular orbit.

    Args:
        n: Spatial dimension (positive integer, n < 4)

    Returns:
        The apsidal angle in radians, or infinity if n ≥ 4
    """
    rho = apsidal_ratio(n)
    if rho == 0:
        return float('inf')
    return math.pi / rho


def is_orbit_closed(n: int, tolerance: float = 1e-10) -> bool:
    """Check if nearly-circular orbits close in dimension n.

    An orbit closes iff the apsidal angle is a rational multiple of π,
    equivalently iff √(4-n) is rational.

    For exact results, this checks whether 4-n is a perfect square.

    Args:
        n: Spatial dimension
        tolerance: Numerical tolerance (not used for exact check)

    Returns:
        True if orbits close in dimension n
    """
    arg = 4 - n
    if arg < 0:
        return False
    if arg == 0:
        return True  # √0 = 0 is rational
    # Check if arg is a perfect square of a rational
    sqrt_val = math.isqrt(arg)
    return sqrt_val * sqrt_val == arg


def has_stable_orbits(n: int) -> bool:
    """Check if circular orbits are stable in dimension n.

    Stability requires the effective potential to have a local minimum,
    which happens iff n < 4 for inverse-power-law gravity.

    Args:
        n: Spatial dimension

    Returns:
        True if stable circular orbits exist
    """
    return n < 4


def has_finite_escape_velocity(n: int) -> bool:
    """Check if escape velocity is finite in dimension n.

    Finite escape velocity requires the gravitational potential
    to vanish at infinity, which happens iff n ≥ 3.

    Args:
        n: Spatial dimension

    Returns:
        True if escape velocity is finite
    """
    return n >= 3


def is_goldilocks_dimension(n: int) -> bool:
    """Check all three Goldilocks conditions for dimension n.

    A dimension is "Goldilocks" iff it has:
    1. Stable circular orbits (n < 4)
    2. Closed orbits (√(4-n) rational)
    3. Finite escape velocity (n ≥ 3)

    Args:
        n: Spatial dimension (positive integer)

    Returns:
        True iff n satisfies all three conditions
    """
    return (has_stable_orbits(n)
            and is_orbit_closed(n)
            and has_finite_escape_velocity(n)
            and n >= 1)


def bertrand_apsidal_ratio(alpha: float) -> float:
    """Compute the Bertrand apsidal ratio β(α) = √(3 + α).

    For a central force F(r) = -k·r^α, this determines
    the apsidal angle Ψ = π/β(α) for nearly-circular orbits.

    Args:
        alpha: Force-law exponent

    Returns:
        The Bertrand apsidal ratio
    """
    arg = 3 + alpha
    if arg <= 0:
        return 0.0
    return math.sqrt(arg)


def classify_bertrand_exponents(
    alpha_min: int = -2,
    alpha_max: int = 2
) -> dict[int, dict[str, object]]:
    """Classify integer force-law exponents by the Bertrand criterion.

    For each integer α in [alpha_min, alpha_max], determine whether
    the apsidal ratio √(3+α) is rational (closed orbits) or irrational.

    Args:
        alpha_min: Minimum exponent to check
        alpha_max: Maximum exponent to check

    Returns:
        Dictionary mapping α → classification info
    """
    results: dict[int, dict[str, object]] = {}
    for alpha in range(alpha_min, alpha_max + 1):
        arg = 3 + alpha
        if arg < 0:
            status = "unstable"
            rational = False
        elif arg == 0:
            status = "degenerate"
            rational = True
        else:
            sqrt_val = math.isqrt(arg)
            rational = sqrt_val * sqrt_val == arg
            status = "closed" if rational else "open"

        results[alpha] = {
            "exponent": alpha,
            "argument": arg,
            "apsidal_ratio": bertrand_apsidal_ratio(alpha),
            "rational": rational,
            "status": status,
            "force_type": _force_type_name(alpha),
        }
    return results


def _force_type_name(alpha: int) -> str:
    """Human-readable name for force law F(r) ∝ r^α."""
    names = {
        -3: "inverse-cube",
        -2: "inverse-square (gravity in 3D)",
        -1: "inverse (gravity in 2D)",
        0: "constant",
        1: "linear (harmonic oscillator)",
        2: "quadratic",
    }
    return names.get(alpha, f"r^{alpha}")


def effective_potential(
    r: float, n: int, L: float = 1.0, k: float = 1.0
) -> float:
    """Compute the effective radial potential in n dimensions.

    V_eff(r) = L²/(2r²) - k/((n-2)·r^(n-2))  for n ≥ 3
    V_eff(r) = L²/(2r²) - k·ln(r)              for n = 2
    V_eff(r) = L²/(2r²) + k·r                  for n = 1

    Args:
        r: Radial distance (positive)
        n: Spatial dimension
        L: Angular momentum
        k: Gravitational coupling constant

    Returns:
        Value of the effective potential
    """
    centrifugal = L**2 / (2 * r**2)
    if n == 1:
        gravitational = k * r
    elif n == 2:
        gravitational = -k * math.log(r)
    else:
        gravitational = -k / ((n - 2) * r**(n - 2))
    return centrifugal + gravitational


def find_circular_orbit_radius(
    n: int, L: float = 1.0, k: float = 1.0
) -> Optional[float]:
    """Find the radius of the circular orbit in n dimensions.

    The circular orbit occurs where V_eff'(r) = 0:
    r₀ = (L²/k)^(1/(n-3)) for n ≠ 3
    r₀ = L²/k for n = 3

    Args:
        n: Spatial dimension (must be < 4 for stable orbits)
        L: Angular momentum
        k: Gravitational coupling

    Returns:
        Circular orbit radius, or None if no stable orbit exists
    """
    if n >= 4:
        return None
    if n == 3:
        return L**2 / k
    # General case: r₀ = (L²/k)^(1/(4-n-1))
    # From V_eff'(r) = 0: -L²/r³ + k/r^(n-1) = 0
    # => r^(n-4) = k/L² ... wait, let me redo this
    # V_eff'(r) = -L²/r³ + k/r^(n-1)
    # Setting to 0: L²/r³ = k/r^(n-1)
    # => L² = k · r^(4-n)  (since r³/r^(n-1) = r^(4-n))
    # => r₀ = (L²/k)^(1/(4-n))
    exponent = 4 - n
    if exponent <= 0:
        return None
    return (L**2 / k) ** (1.0 / exponent)


def goldilocks_scan(max_dim: int = 20) -> list[dict[str, object]]:
    """Scan dimensions 1..max_dim for Goldilocks properties.

    Args:
        max_dim: Maximum dimension to check

    Returns:
        List of dimension analysis results
    """
    results = []
    for n in range(1, max_dim + 1):
        results.append({
            "dimension": n,
            "stable": has_stable_orbits(n),
            "closed": is_orbit_closed(n),
            "finite_escape": has_finite_escape_velocity(n),
            "goldilocks": is_goldilocks_dimension(n),
            "apsidal_ratio": apsidal_ratio(n),
            "apsidal_angle_deg": math.degrees(apsidal_angle(n))
                if apsidal_angle(n) != float('inf') else "∞",
        })
    return results
