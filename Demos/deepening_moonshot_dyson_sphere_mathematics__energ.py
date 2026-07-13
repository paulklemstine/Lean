"""
Numerical demonstrations of the exact optimization theory of stellar energy
collection (Dyson spheres and Dyson swarms).

All quantities are in SI-consistent abstract units. The Sun's luminosity is used
as a concrete example: L_sun = 3.828e26 watts. One astronomical unit (AU),
the Earth-Sun distance, is 1.496e11 metres.

Every function is self-contained and type-hinted. Running this file prints a
sequence of demonstrations verifying the theory's central results.
"""

from __future__ import annotations

import math
from typing import Sequence

# --- Physical constants (concrete example: the Sun) ---------------------------
L_SUN: float = 3.828e26          # solar luminosity, watts
AU: float = 1.495978707e11       # astronomical unit, metres

FOUR_PI: float = 4.0 * math.pi


# --- Core model ---------------------------------------------------------------
def flux(L: float, R: float) -> float:
    """Radiative flux (power per unit area) at radius R from a star of
    luminosity L, obtained by spreading L over the sphere of area 4*pi*R^2."""
    return L / (FOUR_PI * R ** 2)


def collected_power(L: float, R: float, A: float) -> float:
    """Power collected by a flat collector of area A at radius R, facing the
    star."""
    return A * flux(L, R)


def sphere_area(R: float) -> float:
    """Surface area of a sphere of radius R (a complete Dyson shell)."""
    return FOUR_PI * R ** 2


def solid_angle(A: float, R: float) -> float:
    """Solid angle subtended at the star by a collector of area A at radius R."""
    return A / R ** 2


def swarm_power(L: float, areas: Sequence[float], radii: Sequence[float]) -> float:
    """Total power collected by a swarm of collectors with given areas at given
    radii."""
    return sum(collected_power(L, R, A) for A, R in zip(areas, radii))


def efficiency(areas: Sequence[float], radii: Sequence[float]) -> float:
    """Fraction of stellar luminosity captured by the swarm."""
    return sum(solid_angle(A, R) for A, R in zip(areas, radii)) / FOUR_PI


# --- Demonstrations -----------------------------------------------------------
def demo_inverse_square() -> None:
    """Verify flux(L, c*R) = flux(L, R) / c^2 and strict monotonic decrease."""
    print("=" * 70)
    print("1. Inverse-square law")
    print("=" * 70)
    R = AU
    for c in (2.0, 3.0, 10.0):
        lhs = flux(L_SUN, c * R)
        rhs = flux(L_SUN, R) / c ** 2
        print(f"  c={c:5.1f}:  flux(L, cR)={lhs:.6e}   flux(L,R)/c^2={rhs:.6e}"
              f"   match={math.isclose(lhs, rhs)}")
    print(f"  flux at 1 AU  = {flux(L_SUN, AU):.3f} W/m^2 (compare solar constant ~1361)")
    print(f"  flux at 5 AU  = {flux(L_SUN, 5 * AU):.3f} W/m^2 (strictly smaller)\n")


def demo_sphere_captures_all() -> None:
    """A complete shell of area 4*pi*R^2 captures exactly L, at any radius."""
    print("=" * 70)
    print("2. A complete shell captures the entire luminosity (scale invariant)")
    print("=" * 70)
    for R in (0.5 * AU, AU, 40.0 * AU):
        P = collected_power(L_SUN, R, sphere_area(R))
        print(f"  R={R/AU:6.2f} AU:  captured={P:.6e} W   fraction of L={P/L_SUN:.10f}")
    print()


def demo_solid_angle_factorization() -> None:
    """Collected power depends only on solid angle: a tiny near panel and a huge
    far panel with the same A/R^2 capture the same power."""
    print("=" * 70)
    print("3. Collection is governed by solid angle only")
    print("=" * 70)
    # Two collectors with the SAME solid angle A/R^2 but very different A and R.
    A1, R1 = 1.0e6, 0.5 * AU
    A2, R2 = A1 * (2.0 ** 2), 1.0 * AU  # A2/R2^2 == A1/R1^2
    print(f"  collector 1: A={A1:.3e} m^2 at R={R1/AU:.2f} AU  -> "
          f"P={collected_power(L_SUN, R1, A1):.6e} W")
    print(f"  collector 2: A={A2:.3e} m^2 at R={R2/AU:.2f} AU  -> "
          f"P={collected_power(L_SUN, R2, A2):.6e} W")
    print(f"  same solid angle => same power: "
          f"{math.isclose(collected_power(L_SUN, R1, A1), collected_power(L_SUN, R2, A2))}\n")


def demo_optimal_area() -> None:
    """Full capture at a common radius R holds iff total area = 4*pi*R^2."""
    print("=" * 70)
    print("4. Optimal collecting area: full capture iff total area = 4 pi R^2")
    print("=" * 70)
    R = AU
    target = sphere_area(R)
    print(f"  Dyson-sphere area at 1 AU = {target:.6e} m^2")
    for frac in (0.5, 0.9, 1.0, 1.1):
        # Split the area into 1000 identical tiles (refinement invariance).
        n = 1000
        total = frac * target
        areas = [total / n] * n
        radii = [R] * n
        P = swarm_power(L_SUN, areas, radii)
        print(f"  total area = {frac:4.2f} * (4 pi R^2):  captured/L = {P/L_SUN:.6f}"
              f"   ({n} tiles)")
    print()


def demo_concentration() -> None:
    """With a fixed area budget, capture is maximized at the smallest radius."""
    print("=" * 70)
    print("5. Concentration principle: build as close as possible")
    print("=" * 70)
    A_budget = 1.0e18  # fixed total area, m^2
    for R in (0.3 * AU, 1.0 * AU, 5.0 * AU):
        P = collected_power(L_SUN, R, A_budget)
        print(f"  budget {A_budget:.1e} m^2 at R={R/AU:4.1f} AU -> captured={P:.6e} W")
    print("  (smaller radius => strictly more power for the same area)\n")


def demo_efficiency_limit() -> None:
    """Efficiency lies in [0,1] and tends continuously to 1 as coverage -> 4 pi."""
    print("=" * 70)
    print("6. Efficiency in [0,1] and continuous approach to full capture")
    print("=" * 70)
    R = AU
    for frac in (0.0, 0.25, 0.5, 0.99, 1.0):
        A = frac * sphere_area(R)
        eff = efficiency([A], [R])
        print(f"  coverage = {frac:4.2f} of sky: efficiency = {eff:.6f}"
              f"   in [0,1] = {0.0 <= eff <= 1.0 + 1e-12}")
    print()


def demo_gauss_law() -> None:
    """Total power crossing any closed surface of area 4 pi R^2 equals L."""
    print("=" * 70)
    print("7. Gauss-law identity: total flux through an enclosing surface = L")
    print("=" * 70)
    for R in (AU, 3.0 * AU):
        area = sphere_area(R)
        total_flux = area * flux(L_SUN, R)  # constant flux integrated over area
        print(f"  R={R/AU:4.1f} AU:  surface area * flux = {total_flux:.6e} W"
              f"   (= L: {math.isclose(total_flux, L_SUN)})")
    print()


def main() -> None:
    print("\nSTELLAR ENERGY COLLECTION: NUMERICAL DEMONSTRATIONS\n")
    demo_inverse_square()
    demo_sphere_captures_all()
    demo_solid_angle_factorization()
    demo_optimal_area()
    demo_concentration()
    demo_efficiency_limit()
    demo_gauss_law()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
