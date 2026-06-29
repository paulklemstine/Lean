#!/usr/bin/env python3
"""
Algorithms for the Quantum Runge-Lenz Algebra and Hydrogen Atom Spectrum.

Implements verified algorithms for:
  1. Hydrogen shell data computation (Casimir, energy, degeneracy)
  2. Angular momentum branching rule enumeration
  3. Spectral transition computation (Rydberg formula)
  4. Tropical hydrogen spectrum analysis
  5. Sum-of-squares verification for total state counting

All algorithms have O(1) per-shell complexity for direct formulas,
and O(n) for the branching rule enumeration.

Time complexity:
  - hydrogen_shell_data: O(1)
  - branching_rule: O(n)
  - transition_energy: O(1)
  - tropical_spectrum: O(N) for N shells
  - total_states: O(1) using closed-form
"""

from dataclasses import dataclass
from typing import List, Tuple
import math


@dataclass
class PhysicalConstants:
    """Physical constants for the hydrogen atom problem.

    Attributes:
        hbar: Reduced Planck constant (ℏ) in J·s
        mass: Electron mass in kg
        coulomb: Coulomb coupling constant (k = e²/(4πε₀)) in N·m²
    """
    hbar: float = 1.054571817e-34
    mass: float = 9.1093837015e-31
    coulomb: float = 2.307077552e-28


@dataclass
class HydrogenShellData:
    """Complete data for a hydrogen energy shell.

    Attributes:
        n: Principal quantum number
        energy: Energy level E_n in Joules
        casimir: Casimir eigenvalue C_n in (J·s)²
        degeneracy: Number of degenerate states n²
        j_plus: so(4) quantum number j⁺ = (n-1)/2
        j_minus: so(4) quantum number j⁻ = (n-1)/2
        angular_momenta: List of (l, 2l+1) pairs for the branching rule
    """
    n: int
    energy: float
    casimir: float
    degeneracy: int
    j_plus: float
    j_minus: float
    angular_momenta: List[Tuple[int, int]]


def hydrogen_shell_data(n: int, constants: PhysicalConstants = None) -> HydrogenShellData:
    """
    Compute complete hydrogen shell data for principal quantum number n.

    Algorithm:
        1. E_n = -mk²/(2ℏ²n²)           -- Energy quantization (Theorem D)
        2. C_n = ℏ²(n² - 1)              -- Casimir eigenvalue (Theorem B)
        3. deg = n²                        -- Degeneracy (Theorem C)
        4. j = (n-1)/2                     -- so(4) quantum number
        5. Enumerate (l, 2l+1) for l=0..n-1 -- Branching rule

    Time: O(n) due to branching rule enumeration
    Space: O(n) for storing angular momentum data

    Args:
        n: Principal quantum number (n ≥ 1)
        constants: Physical constants (defaults to electron in hydrogen)

    Returns:
        HydrogenShellData with all verified quantities

    Raises:
        ValueError: If n < 1
    """
    if n < 1:
        raise ValueError(f"Principal quantum number must be ≥ 1, got {n}")

    if constants is None:
        constants = PhysicalConstants()

    c = constants
    energy = -(c.mass * c.coulomb**2) / (2 * c.hbar**2 * n**2)
    casimir = c.hbar**2 * (n**2 - 1)
    degeneracy = n**2
    j = (n - 1) / 2.0
    angular_momenta = [(l, 2*l + 1) for l in range(n)]

    return HydrogenShellData(
        n=n,
        energy=energy,
        casimir=casimir,
        degeneracy=degeneracy,
        j_plus=j,
        j_minus=j,
        angular_momenta=angular_momenta,
    )


def verify_degeneracy(data: HydrogenShellData) -> bool:
    """
    Verify the three algebraic identities from Theorems A-D:
      1. (2j⁺+1)(2j⁻+1) = n²     (Degeneracy from so(4))
      2. Σ(2l+1) = n²              (Branching rule)
      3. C = ℏ²(n²-1)              (Casimir identification)

    Time: O(n)
    """
    n = data.n
    # Identity 1: (2j+1)² = n²
    dim_so4 = int(2 * data.j_plus + 1) * int(2 * data.j_minus + 1)
    check1 = (dim_so4 == n**2)

    # Identity 2: sum of odd numbers
    sum_odd = sum(dim for _, dim in data.angular_momenta)
    check2 = (sum_odd == n**2)

    # Identity 3: Casimir
    c = PhysicalConstants()
    check3 = abs(data.casimir - c.hbar**2 * (n**2 - 1)) < 1e-60

    return check1 and check2 and check3


def transition_energy(n1: int, n2: int,
                      constants: PhysicalConstants = None) -> float:
    """
    Compute the photon energy for a transition n2 → n1.

    Uses the Rydberg formula:
        ΔE = mk²/(2ℏ²) · (1/n1² - 1/n2²)

    Time: O(1)

    Args:
        n1: Lower principal quantum number
        n2: Upper principal quantum number (n2 > n1)
        constants: Physical constants

    Returns:
        Photon energy in Joules
    """
    if n2 <= n1:
        raise ValueError(f"Need n2 > n1, got n1={n1}, n2={n2}")

    if constants is None:
        constants = PhysicalConstants()

    c = constants
    rydberg_energy = c.mass * c.coulomb**2 / (2 * c.hbar**2)
    return rydberg_energy * (1/n1**2 - 1/n2**2)


def transition_wavelength(n1: int, n2: int,
                          constants: PhysicalConstants = None) -> float:
    """
    Compute the photon wavelength for a transition n2 → n1.

    λ = hc / ΔE

    Time: O(1)

    Returns:
        Wavelength in meters
    """
    h = 6.62607015e-34  # Planck's constant
    c_light = 299792458  # speed of light
    dE = transition_energy(n1, n2, constants)
    return h * c_light / dE


def total_states(N: int) -> int:
    """
    Total number of hydrogen states from n=1 to n=N.

    Uses the verified formula: Σ_{n=1}^{N} n² = N(N+1)(2N+1)/6

    Time: O(1)
    Space: O(1)

    Args:
        N: Maximum principal quantum number

    Returns:
        Total state count
    """
    return N * (N + 1) * (2 * N + 1) // 6


def tropical_spectrum(N: int) -> List[Tuple[int, float, float, float]]:
    """
    Compute the tropical hydrogen spectrum for n = 1,...,N.

    The tropicalization maps the multiplicative spectrum structure
    to additive (min-plus) structure:
        Trop(E_n) = log(mk²/(2ℏ²)) - 2·log(n)

    Returns list of (n, trop_energy, trop_casimir, trop_gap) tuples.

    Time: O(N)
    Space: O(N)
    """
    results = []
    for n in range(1, N + 1):
        trop_energy = -2 * math.log(n)  # up to additive constant
        trop_casimir = math.log(n**2 - 1) if n > 1 else float('-inf')
        trop_gap = 2 * (math.log(n + 1) - math.log(n))
        results.append((n, trop_energy, trop_casimir, trop_gap))
    return results


def verify_sum_of_squares(N: int) -> bool:
    """
    Verify the sum-of-squares formula: 6·Σ(k+1)² = N(N+1)(2N+1)
    for k = 0,...,N-1.

    This is the verified identity from total_states_sum_sq.

    Time: O(N)
    """
    lhs = 6 * sum((k + 1)**2 for k in range(N))
    rhs = N * (N + 1) * (2 * N + 1)
    return lhs == rhs


# ─── Example Usage ───────────────────────────────────────────────────

if __name__ == "__main__":
    print("Quantum Runge-Lenz Algebra — Algorithm Demonstrations\n")

    # Compute shell data for n = 1..5
    for n in range(1, 6):
        data = hydrogen_shell_data(n)
        verified = verify_degeneracy(data)
        eV = data.energy / 1.602176634e-19
        print(f"n={n}: E={eV:+.4f} eV, C/ℏ²={n**2-1:3d}, "
              f"deg={data.degeneracy:3d}, verified={verified}")

    # Verify sum-of-squares for large N
    print(f"\nSum-of-squares verification:")
    for N in [10, 100, 1000]:
        print(f"  N={N:5d}: total={total_states(N):10d}, "
              f"verified={verify_sum_of_squares(N)}")

    # Spectral transitions
    print(f"\nLyman series wavelengths:")
    for n2 in range(2, 7):
        lam = transition_wavelength(1, n2) * 1e9
        print(f"  n={n2}→1: λ = {lam:.2f} nm")

    # Tropical spectrum
    print(f"\nTropical spectrum (first 10 shells):")
    for n, te, tc, tg in tropical_spectrum(10):
        print(f"  n={n:2d}: Trop(E)={te:+.4f}, Trop(C)={tc:+.4f}, gap={tg:.4f}")
