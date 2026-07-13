"""
The Topology of Knotted Light: Numerical Demonstrations
=======================================================

Self-contained numerical examples illustrating the topological charge of
orbital-angular-momentum (OAM) laser beams --- "knotted light".

The transverse azimuthal phase field of an OAM beam of integer charge L is

        phi_L(theta) = exp(i * L * theta),

and its topological charge equals the winding number

        w(phi) = 1/(2*pi*i) * integral_0^{2*pi} phi'(theta)/phi(theta) d theta.

This script verifies, purely numerically:
  1. winding number of exp(i L theta) == L           (charge = winding number)
  2. charge additivity under superposition (product of fields adds charges)
  3. opposite charges annihilate: product is a constant, winding 0
  4. the on-axis phase singularity: amplitude vanishes at r=0 iff L != 0
  5. charges come with a sign (handedness): w(phi_{-1}) = -1

Only the Python standard library is used.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, List


# --------------------------------------------------------------------------
# Core field definitions
# --------------------------------------------------------------------------

def oam_phase(L: int, theta: float) -> complex:
    """Azimuthal phase field phi_L(theta) = exp(i L theta)."""
    return cmath.exp(1j * L * theta)


def beam_amplitude(L: int, r: float, theta: float) -> complex:
    """Near-axis amplitude profile A_L(r, theta) = r^|L| * exp(i L theta)."""
    return (r ** abs(L)) * oam_phase(L, theta)


# --------------------------------------------------------------------------
# Winding number by numerical contour integration
# --------------------------------------------------------------------------

def winding_number(phi: Callable[[float], complex], n: int = 200_000) -> complex:
    """
    Numerically evaluate w(phi) = 1/(2 pi i) * int_0^{2pi} phi'/phi d theta,
    using centered finite differences for phi' and the trapezoidal rule.
    """
    two_pi = 2.0 * math.pi
    h = two_pi / n
    dtheta = 1e-7  # step for the derivative
    total = 0.0 + 0.0j

    def integrand(theta: float) -> complex:
        f = phi(theta)
        fp = (phi(theta + dtheta) - phi(theta - dtheta)) / (2.0 * dtheta)
        return fp / f

    prev = integrand(0.0)
    for k in range(1, n + 1):
        theta = k * h
        cur = integrand(theta)
        total += 0.5 * (prev + cur) * h
        prev = cur

    return total / (two_pi * 1j)


def charge_by_phase_unwrap(phi: Callable[[float], complex], n: int = 100_000) -> int:
    """Recover the integer charge by unwrapping arg(phi) around the loop."""
    two_pi = 2.0 * math.pi
    thetas = [k * two_pi / n for k in range(n + 1)]
    phases = [cmath.phase(phi(t)) for t in thetas]
    net = 0.0
    for a, b in zip(phases, phases[1:]):
        d = b - a
        # unwrap into (-pi, pi]
        while d > math.pi:
            d -= two_pi
        while d <= -math.pi:
            d += two_pi
        net += d
    return round(net / two_pi)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_charge_equals_winding() -> None:
    print("=" * 66)
    print("1. Topological charge = winding number:  w(exp(iL theta)) = L")
    print("=" * 66)
    for L in [-3, -1, 0, 1, 2, 5]:
        w = winding_number(lambda t, L=L: oam_phase(L, t))
        unwrapped = charge_by_phase_unwrap(lambda t, L=L: oam_phase(L, t))
        print(f"  L = {L:+d}:  contour integral = {w.real:+.5f}{w.imag:+.1e}i"
              f"   phase-unwrap = {unwrapped:+d}   (expected {L:+d})")
    print()


def demo_additivity() -> None:
    print("=" * 66)
    print("2. Charge additivity:  phi_L * phi_M = phi_{L+M}")
    print("=" * 66)
    for L, M in [(1, 2), (3, -1), (-2, -4), (5, -5)]:
        product = lambda t, L=L, M=M: oam_phase(L, t) * oam_phase(M, t)
        w = winding_number(product)
        print(f"  L={L:+d}, M={M:+d}:  winding of product = {w.real:+.4f}"
              f"   (expected {L + M:+d})")
    print()


def demo_annihilation() -> None:
    print("=" * 66)
    print("3. Opposite vortices annihilate:  phi_L * phi_{-L} = 1")
    print("=" * 66)
    for L in [1, 2, 7]:
        product = lambda t, L=L: oam_phase(L, t) * oam_phase(-L, t)
        w = winding_number(product)
        vals = [abs(product(k * 2 * math.pi / 8)) for k in range(8)]
        print(f"  L={L:+d}:  winding = {w.real:+.4f}   |field| samples "
              f"= {[round(v, 4) for v in vals]}  (constant 1, never 0)")
    print()


def demo_singularity() -> None:
    print("=" * 66)
    print("4. On-axis phase singularity:  |A_L(r,theta)| vanishes at r=0 iff L!=0")
    print("=" * 66)
    theta = 0.7
    for L in [0, 1, 3]:
        on_axis = abs(beam_amplitude(L, 0.0, theta))
        off_axis = abs(beam_amplitude(L, 0.5, theta))
        tag = "singular core" if L != 0 else "bright core"
        print(f"  L={L:+d}:  |A(0)| = {on_axis:.4f}   |A(0.5)| = {off_axis:.4f}"
              f"   -> {tag}")
    print()


def demo_handedness() -> None:
    print("=" * 66)
    print("5. Handedness: charge carries a sign; w(phi_{-1}) = -1 < 0")
    print("=" * 66)
    w_pos = winding_number(lambda t: oam_phase(1, t))
    w_neg = winding_number(lambda t: oam_phase(-1, t))
    print(f"  right-handed L=+1: winding = {w_pos.real:+.4f}")
    print(f"  left-handed  L=-1: winding = {w_neg.real:+.4f}")
    print("  => the conjecture 'charge is always nonnegative' is false.")
    print()


def main() -> None:
    demo_charge_equals_winding()
    demo_additivity()
    demo_annihilation()
    demo_singularity()
    demo_handedness()
    print("All numerical demonstrations completed.")


if __name__ == "__main__":
    main()
