"""
Dyson Sphere Mathematics: Numerical demonstrations.

This self-contained script demonstrates the key results of the theory of
stellar-scale energy collection and its computational limits:

  1. Complete energy capture  : flux * area = luminosity, independent of radius.
  2. Thermal management       : equilibrium temperature is antitone in area;
                                the Dyson swarm runs cooler by exactly (1/2)^(1/4).
  3. Information capacity      : Landauer's principle, E / (k_B T ln 2) bits.
  4. Computational rate        : Margolus-Levitin, 2E / (pi hbar) ops/second.

All functions are inlined with type hints. Run with:  python demo.py
"""

from __future__ import annotations

import math

# ---------------------------------------------------------------------------
# Physical constants (SI units)
# ---------------------------------------------------------------------------
SIGMA_SB: float = 5.670374419e-8   # Stefan-Boltzmann constant, W m^-2 K^-4
K_B: float = 1.380649e-23          # Boltzmann constant, J/K
HBAR: float = 1.054571817e-34      # reduced Planck constant, J s
LN2: float = math.log(2.0)
AU: float = 1.495978707e11         # astronomical unit, meters
L_SUN: float = 3.828e26            # solar luminosity, watts


# ---------------------------------------------------------------------------
# 1. Geometry and energy capture
# ---------------------------------------------------------------------------
def dyson_area(radius: float) -> float:
    """Surface (collecting) area 4*pi*R^2 of a Dyson shell of radius R."""
    return 4.0 * math.pi * radius ** 2


def sphere_flux(luminosity: float, radius: float) -> float:
    """Radiative flux L / (4*pi*R^2) at radius R (inverse-square law)."""
    return luminosity / (4.0 * math.pi * radius ** 2)


def captured_power(luminosity: float, radius: float) -> float:
    """Total power intercepted by a closed shell: flux * area == luminosity."""
    return sphere_flux(luminosity, radius) * dyson_area(radius)


# ---------------------------------------------------------------------------
# 2. Thermal management (Stefan-Boltzmann)
# ---------------------------------------------------------------------------
def eq_temp(power: float, sigma: float, area: float) -> float:
    """Equilibrium temperature (P / (sigma * A))^(1/4)."""
    return (power / (sigma * area)) ** 0.25


def swarm_temperature_ratio() -> float:
    """Universal swarm/shell temperature ratio (1/2)^(1/4)."""
    return 0.5 ** 0.25


# ---------------------------------------------------------------------------
# 3. Information capacity (Landauer)
# ---------------------------------------------------------------------------
def landauer_bits(energy: float, k_b: float, temperature: float) -> float:
    """Number of irreversible bit operations affordable: E / (k_B T ln 2)."""
    return energy / (k_b * temperature * LN2)


# ---------------------------------------------------------------------------
# 4. Computational rate (Margolus-Levitin)
# ---------------------------------------------------------------------------
def ml_op_rate(energy: float, hbar: float) -> float:
    """Max elementary quantum operations per second: 2E / (pi hbar)."""
    return 2.0 * energy / (math.pi * hbar)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_capture() -> None:
    print("=" * 70)
    print("1. COMPLETE ENERGY CAPTURE (radius-independent)")
    print("=" * 70)
    for r_au in (0.4, 1.0, 5.2, 30.0):
        r = r_au * AU
        flux = sphere_flux(L_SUN, r)
        area = dyson_area(r)
        cap = captured_power(L_SUN, r)
        print(f"  R = {r_au:5.1f} AU | flux = {flux:10.3e} W/m^2 | "
              f"area = {area:10.3e} m^2 | captured = {cap:.6e} W")
    print(f"  Star luminosity L_sun = {L_SUN:.6e} W  (matches captured power)\n")


def demo_thermal() -> None:
    print("=" * 70)
    print("2. THERMAL MANAGEMENT: swarm runs cooler by (1/2)^(1/4)")
    print("=" * 70)
    r = 1.0 * AU
    area = dyson_area(r)
    power = L_SUN                       # full stellar power re-radiated
    t_shell = eq_temp(power, SIGMA_SB, area)        # single face
    t_swarm = eq_temp(power, SIGMA_SB, 2.0 * area)  # two faces
    print(f"  Shell temperature (area  A ) : {t_shell:8.3f} K")
    print(f"  Swarm temperature (area 2A ) : {t_swarm:8.3f} K")
    print(f"  Measured ratio T_swarm/T_shell : {t_swarm / t_shell:.6f}")
    print(f"  Predicted (1/2)^(1/4)          : {swarm_temperature_ratio():.6f}")
    # Antitonicity check
    print("  Antitonicity (temperature decreases as area grows):")
    for mult in (1.0, 2.0, 4.0, 8.0):
        print(f"    area = {mult:4.1f} A -> T = {eq_temp(power, SIGMA_SB, mult*area):8.3f} K")
    print()


def demo_information() -> None:
    print("=" * 70)
    print("3. INFORMATION CAPACITY (Landauer) at 1 AU")
    print("=" * 70)
    # Energy = full solar output collected over one year at swarm temperature.
    energy = L_SUN * 3.156e7            # one year of solar output, joules
    r = 1.0 * AU
    area = dyson_area(r)
    t_swarm = eq_temp(L_SUN, SIGMA_SB, 2.0 * area)
    bits = landauer_bits(energy, K_B, t_swarm)
    print(f"  Energy budget (1 yr of L_sun) : {energy:.3e} J")
    print(f"  Operating temperature          : {t_swarm:.3f} K")
    print(f"  Landauer bit capacity          : {bits:.3e} bits  (~10^{math.log10(bits):.0f})")
    # Storage-temperature duality: bits * T is invariant.
    print("  Storage-temperature duality (bits * T invariant at fixed E):")
    for temp in (100.0, 200.0, 400.0):
        b = landauer_bits(energy, K_B, temp)
        print(f"    T = {temp:6.1f} K -> bits = {b:.3e}, bits*T = {b*temp:.3e}")
    print()


def demo_computation() -> None:
    print("=" * 70)
    print("4. COMPUTATIONAL RATE (Margolus-Levitin), Type II civilization")
    print("=" * 70)
    for power in (1e17, 1e26):  # Type I-ish vs Type II
        rate = ml_op_rate(power, HBAR)  # energy per second -> ops per second
        print(f"  Power = {power:.0e} W -> {rate:.3e} ops/s  (~10^{math.log10(rate):.0f})")
    print("  (A Type II civilization ~1e26 W supports ~10^40 quantum ops/s.)\n")


def main() -> None:
    demo_capture()
    demo_thermal()
    demo_information()
    demo_computation()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
