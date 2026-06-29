"""
Numerical demonstrations of the spectral theory of the hydrogen atom.

This module illustrates, with concrete numbers, the formally proved results:

  * Bohr energies  E_n = -1/n^2  (Rydberg units): negativity, ground state,
    lower bound -1, strict monotonicity, accumulation at 0.
  * The full spectrum  sigma(H) = {-1/n^2 : n >= 1} U [0, inf), with the
    discrete and continuous parts disjoint.
  * The Rydberg formula  E_n - E_m = 1/m^2 - 1/n^2  for emission energies,
    and the named spectral series (Lyman, Balmer, Paschen).
  * Subshell sizes  2*l + 1  and the shell degeneracy  sum_{l<n}(2l+1) = n^2.
  * The L_z eigenvalue equation  -i d/dphi e^{i m phi} = m e^{i m phi}.
  * The electric-dipole selection rule  |Delta l| = 1 and |Delta m| <= 1,
    with its forbidding / parity-flip / symmetry consequences.

All functions are self-contained and use only the Python standard library.
Run `python demo.py` to print the demonstrations.
"""

from __future__ import annotations

import cmath
import math
from typing import Iterator


# --------------------------------------------------------------------------
# 1. Bohr energies and the spectrum
# --------------------------------------------------------------------------

def bohr_energy(n: int) -> float:
    """Bohr energy E_n = -1/n^2 in Rydberg units (n >= 1)."""
    if n < 1:
        raise ValueError("principal quantum number n must be >= 1")
    return -1.0 / (n * n)


def is_bound_energy(e: float, tol: float = 1e-12) -> bool:
    """A bound (discrete) energy is strictly negative; scattering is e >= 0."""
    return e < -tol


def demo_energy_levels(n_max: int = 8) -> None:
    print("=== Bohr energy levels  E_n = -1/n^2  (Rydberg units) ===")
    prev = -math.inf
    for n in range(1, n_max + 1):
        e = bohr_energy(n)
        assert e < 0.0, "every bound energy is negative"
        assert e >= -1.0, "ground state -1 is a lower bound"
        assert e > prev, "levels strictly increase toward 0"
        prev = e
        print(f"  n={n:2d}   E_n = {e:+.6f}")
    print(f"  ground state  E_1 = {bohr_energy(1):+.1f}   (exactly -1)")
    print(f"  E_n -> 0 as n grows; E_{n_max} = {bohr_energy(n_max):+.6f}")
    print("  discrete spectrum (all < 0) is disjoint from [0, inf).\n")


# --------------------------------------------------------------------------
# 2. The Rydberg formula and spectral series
# --------------------------------------------------------------------------

def photon_energy(n: int, m: int) -> float:
    """Emission energy for the transition n -> m (m < n): 1/m^2 - 1/n^2."""
    if not (1 <= m < n):
        raise ValueError("require 1 <= m < n for emission")
    return 1.0 / (m * m) - 1.0 / (n * n)


def demo_rydberg(n_max: int = 6) -> None:
    print("=== Rydberg formula  E_n - E_m = 1/m^2 - 1/n^2 ===")
    series_names = {1: "Lyman (UV)", 2: "Balmer (visible)", 3: "Paschen (IR)"}
    for m in (1, 2, 3):
        limit = 1.0 / (m * m)
        print(f"  {series_names[m]} series, lower level m={m}, "
              f"limit = {limit:.6f}")
        for n in range(m + 1, n_max + 1):
            dE = photon_energy(n, m)
            assert dE > 0.0, "emitted photon energy is positive"
            assert dE < limit, "each line lies below the series limit 1/m^2"
            print(f"    {n}->{m}:  dE = {dE:.6f}")
    print()


# --------------------------------------------------------------------------
# 3. Subshell sizes and shell degeneracy
# --------------------------------------------------------------------------

def subshell_size(l: int) -> int:
    """Number of magnetic substates m in {-l, ..., l}: 2*l + 1."""
    return 2 * l + 1


def shell_degeneracy(n: int) -> int:
    """Total orbital states in shell n: sum_{l=0}^{n-1} (2l+1)."""
    return sum(subshell_size(l) for l in range(n))


def demo_degeneracy(n_max: int = 6) -> None:
    print("=== Shell degeneracy  sum_{l<n}(2l+1) = n^2 ===")
    for n in range(1, n_max + 1):
        sizes = [subshell_size(l) for l in range(n)]
        total = shell_degeneracy(n)
        assert total == n * n, "degeneracy equals n^2"
        print(f"  n={n}:  subshell sizes {sizes}  sum = {total} = {n}^2")
    print("  (with two spin states per orbital, capacity = 2 n^2)\n")


# --------------------------------------------------------------------------
# 4. The L_z eigenvalue equation
# --------------------------------------------------------------------------

def azimuthal(m: int, phi: float) -> complex:
    """Azimuthal eigenfunction Phi_m(phi) = e^{i m phi}."""
    return cmath.exp(1j * m * phi)


def lz_apply(m: int, phi: float, h: float = 1e-6) -> complex:
    """Numerically apply L_z = -i d/dphi to Phi_m at phi (central difference)."""
    deriv = (azimuthal(m, phi + h) - azimuthal(m, phi - h)) / (2.0 * h)
    return -1j * deriv


def demo_lz_eigenvalue() -> None:
    print("=== L_z eigenvalue equation:  -i d/dphi e^{i m phi} = m e^{i m phi} ===")
    phi = 0.7
    for m in range(-3, 4):
        lhs = lz_apply(m, phi)
        rhs = m * azimuthal(m, phi)
        err = abs(lhs - rhs)
        assert err < 1e-4, "L_z Phi_m = m Phi_m"
        print(f"  m={m:+d}:  L_z Phi_m = ({lhs.real:+.4f}{lhs.imag:+.4f}i)"
              f"   m*Phi_m = ({rhs.real:+.4f}{rhs.imag:+.4f}i)   |err|={err:.1e}")
    # periodicity check: Phi_m(phi + 2 pi) = Phi_m(phi)
    for m in range(-2, 3):
        assert abs(azimuthal(m, phi + 2 * math.pi) - azimuthal(m, phi)) < 1e-9
    print("  azimuthal functions are 2*pi-periodic (m forced to be an integer).\n")


# --------------------------------------------------------------------------
# 5. Electric-dipole selection rules
# --------------------------------------------------------------------------

def dipole_allowed(l: int, lp: int, m: int, mp: int) -> bool:
    """Electric-dipole rule: |Delta l| = 1 and |Delta m| <= 1."""
    return (lp == l + 1 or l == lp + 1) and abs(m - mp) <= 1


def states(n: int) -> Iterator[tuple[int, int]]:
    """Yield angular states (l, m) of shell n: 0 <= l < n, -l <= m <= l."""
    for l in range(n):
        for m in range(-l, l + 1):
            yield (l, m)


def demo_selection_rules() -> None:
    print("=== Electric-dipole selection rules  (|Delta l|=1, |Delta m|<=1) ===")
    # s -> s forbidden
    assert not dipole_allowed(0, 0, 0, 0), "s->s forbidden"
    print("  0->0 (s->s) forbidden:", not dipole_allowed(0, 0, 0, 0))
    # Lyman-alpha 2p -> 1s allowed
    assert dipole_allowed(1, 0, 0, 0), "Lyman-alpha allowed"
    print("  Lyman-alpha 2p->1s allowed:", dipole_allowed(1, 0, 0, 0))
    # parity flip: l + l' odd for every allowed pair
    parity_ok = True
    symm_ok = True
    for l in range(4):
        for lp in range(4):
            for m in range(-l, l + 1):
                for mp in range(-lp, lp + 1):
                    if dipole_allowed(l, lp, m, mp):
                        parity_ok &= (l + lp) % 2 == 1
                    symm_ok &= (dipole_allowed(l, lp, m, mp)
                                == dipole_allowed(lp, l, mp, m))
    assert parity_ok, "allowed transitions flip parity (l+l' odd)"
    assert symm_ok, "selection rule is symmetric"
    print("  every allowed transition flips orbital parity (l+l' odd):", parity_ok)
    print("  selection rule symmetric (detailed balance):", symm_ok)
    # count allowed transitions among states of shells up to n=3
    sts = list(states(3))
    allowed = sum(1 for (l, m) in sts for (lp, mp) in sts
                  if dipole_allowed(l, lp, m, mp))
    print(f"  allowed ordered transitions among {len(sts)} states "
          f"of n<=3: {allowed}\n")


def main() -> None:
    demo_energy_levels()
    demo_rydberg()
    demo_degeneracy()
    demo_lz_eigenvalue()
    demo_selection_rules()
    print("All demonstrations passed their internal assertions.")


if __name__ == "__main__":
    main()
