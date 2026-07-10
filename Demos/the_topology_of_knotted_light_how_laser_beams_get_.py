"""
The Topology of Knotted Light: Alexander Polynomials in the OAM Spectrum
========================================================================

Numerical demonstrations of the correspondence between the vortex knot of a
"knotted light" beam and its orbital-angular-momentum (OAM) spectrum, mediated
by the Alexander polynomial of the knot.

For a knot K with Alexander polynomial Delta_K and modular period N, the OAM
spectrum is
        OAM(Delta_K, N) = { l : Delta_K(exp(2*pi*i*l/N)) = 0 }.

We verify:
  * trefoil    Delta = t^2 - t + 1        -> sixth roots of unity, l = 1, 5 (mod 6)
  * cinquefoil Delta = t^4 - t^3 + t^2 - t + 1 -> tenth roots, l = 1,3,7,9 (mod 10)
  * unknot     Delta = 1                  -> empty spectrum
  * figure-8   Delta = t^2 - 3t + 1       -> golden-ratio roots OFF the unit circle

Self-contained; requires only the Python standard library (cmath, math).
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Dict, List, Tuple

# --------------------------------------------------------------------------- #
# Alexander polynomials as complex evaluation functions                       #
# --------------------------------------------------------------------------- #

def alex_unknot(z: complex) -> complex:
    """Alexander polynomial of the unknot: Delta(t) = 1."""
    return 1.0 + 0j


def alex_trefoil(z: complex) -> complex:
    """Trefoil 3_1: Delta(t) = t^2 - t + 1  (= 6th cyclotomic polynomial)."""
    return z ** 2 - z + 1


def alex_figure_eight(z: complex) -> complex:
    """Figure-eight 4_1: Delta(t) = t^2 - 3t + 1."""
    return z ** 2 - 3 * z + 1


def alex_cinquefoil(z: complex) -> complex:
    """Cinquefoil 5_1: Delta(t) = t^4 - t^3 + t^2 - t + 1  (= 10th cyclotomic)."""
    return z ** 4 - z ** 3 + z ** 2 - z + 1


# --------------------------------------------------------------------------- #
# OAM spectrum by root testing on roots of unity                             #
# --------------------------------------------------------------------------- #

def root_of_unity(l: float, N: int) -> complex:
    """Return exp(2*pi*i*l/N), the phase point associated with OAM value l."""
    return cmath.exp(2j * math.pi * l / N)


def oam_spectrum(delta: Callable[[complex], complex], N: int,
                 tol: float = 1e-9) -> List[int]:
    """Enumerate l in {0,...,N-1} that lie in the OAM spectrum of `delta`.

    l is quantized iff |Delta(exp(2*pi*i*l/N))| < tol.
    """
    spectrum: List[int] = []
    for l in range(N):
        if abs(delta(root_of_unity(l, N))) < tol:
            spectrum.append(l)
    return spectrum


# --------------------------------------------------------------------------- #
# Root localization / unit-circle test                                        #
# --------------------------------------------------------------------------- #

def quadratic_roots(a: float, b: float, c: float) -> Tuple[complex, complex]:
    """Roots of a*t^2 + b*t + c via the quadratic formula (complex-safe)."""
    disc = cmath.sqrt(b * b - 4 * a * c)
    return ((-b + disc) / (2 * a), (-b - disc) / (2 * a))


def on_unit_circle(z: complex, tol: float = 1e-9) -> bool:
    """True iff |z| = 1 to within tolerance."""
    return abs(abs(z) - 1.0) < tol


# --------------------------------------------------------------------------- #
# Structural invariants                                                        #
# --------------------------------------------------------------------------- #

def knot_determinant(delta: Callable[[complex], complex]) -> int:
    """Knot determinant det(K) = |Delta(-1)|."""
    return round(abs(delta(-1.0 + 0j)))


def normalization(delta: Callable[[complex], complex]) -> int:
    """Delta(1); should be +/- 1 for a knot."""
    return round(delta(1.0 + 0j).real)


def reciprocity_residual(delta: Callable[[complex], complex], deg: int,
                         z: complex) -> float:
    """|z^deg * Delta(1/z) - Delta(z)|; should be ~0 for a palindromic Delta."""
    return abs(z ** deg * delta(1.0 / z) - delta(z))


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_spectra() -> None:
    print("=" * 68)
    print("OAM SPECTRA (quantized angular-momentum values)")
    print("=" * 68)
    cases: Dict[str, Tuple[Callable[[complex], complex], int]] = {
        "unknot     0_1": (alex_unknot, 6),
        "trefoil    3_1": (alex_trefoil, 6),
        "figure-8   4_1": (alex_figure_eight, 8),
        "cinquefoil 5_1": (alex_cinquefoil, 10),
    }
    for name, (delta, N) in cases.items():
        spec = oam_spectrum(delta, N)
        print(f"  {name}:  N = {N:2d}   OAM spectrum (mod N) = {spec}")
    print()
    print("  Expected: unknot []  |  trefoil [1,5]  |  fig-8 []  |  cinquefoil [1,3,7,9]")
    print()


def demo_roots() -> None:
    print("=" * 68)
    print("ROOT LOCALIZATION: on vs. off the unit circle")
    print("=" * 68)

    r1, r2 = quadratic_roots(1, -1, 1)  # trefoil
    print(f"  trefoil   roots: {r1:.4f}, {r2:.4f}")
    print(f"            |roots| = {abs(r1):.6f}, {abs(r2):.6f}  "
          f"on unit circle: {on_unit_circle(r1) and on_unit_circle(r2)}")

    g1, g2 = quadratic_roots(1, -3, 1)  # figure-eight
    phi2 = (3 + math.sqrt(5)) / 2
    psi2 = (3 - math.sqrt(5)) / 2
    print(f"  figure-8  roots: {g1.real:.6f}, {g2.real:.6f}")
    print(f"            golden phi^2 = {phi2:.6f}, psi^2 = {psi2:.6f}")
    print(f"            |roots| = {abs(g1):.6f}, {abs(g2):.6f}  "
          f"on unit circle: {on_unit_circle(g1) and on_unit_circle(g2)}")
    print(f"            product of roots phi^2 * psi^2 = {phi2 * psi2:.6f}  (=1)")
    print()


def demo_invariants() -> None:
    print("=" * 68)
    print("STRUCTURAL INVARIANTS")
    print("=" * 68)
    data = [
        ("trefoil    3_1", alex_trefoil, 2),
        ("figure-8   4_1", alex_figure_eight, 2),
        ("cinquefoil 5_1", alex_cinquefoil, 4),
    ]
    for name, delta, deg in data:
        det = knot_determinant(delta)
        norm = normalization(delta)
        recip = reciprocity_residual(delta, deg, 1.3 + 0.7j)
        print(f"  {name}:  Delta(1) = {norm:+d}   det = |Delta(-1)| = {det}"
              f"   reciprocity residual = {recip:.2e}")
    print()
    print("  Expected determinants: trefoil 3, figure-8 5, cinquefoil 5 (all odd).")
    print()


def main() -> None:
    print()
    print("THE TOPOLOGY OF KNOTTED LIGHT")
    print("Alexander polynomials in the orbital-angular-momentum spectrum")
    print()
    demo_spectra()
    demo_roots()
    demo_invariants()
    print("Done.")


if __name__ == "__main__":
    main()
