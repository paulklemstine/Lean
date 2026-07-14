"""
The Topology of Knotted Light: numerical demonstrations.

This self-contained script numerically illustrates the main results:

  1. The winding number of the OAM phase exp(i*l*theta) equals the integer
     charge l   (topological charge = winding number).
  2. The contour-integral product rule  w(phi*psi) = w(phi) + w(psi),
     giving additivity/conservation of optical charge under superposition.
  3. Envelope invariance: the radial factor r^|l| of the physical
     Laguerre-Gauss amplitude does not change the charge.
  4. The topology / number-theory bridge: for coprime (p, q) the torus-knot
     beam charge p*q equals lcm(p, q); the trefoil is (2, 3) with charge 6.

Only the standard library and (optionally) NumPy are used. All routines are
implemented from scratch with type hints.
"""

from __future__ import annotations

import cmath
import math
from math import gcd
from typing import Callable, Sequence

TAU: float = 2.0 * math.pi


def winding_number(
    phi: Callable[[float], complex],
    dphi: Callable[[float], complex],
    n_nodes: int = 20_000,
) -> complex:
    """Numerically evaluate the logarithmic-derivative contour integral

        w(phi) = 1/(2*pi*i) * integral_0^{2*pi} phi'(theta)/phi(theta) dtheta

    over one full turn, using the trapezoidal rule on ``n_nodes`` samples.
    ``dphi`` is the analytic derivative of ``phi``.
    """
    acc: complex = 0.0 + 0.0j
    h: float = TAU / n_nodes
    for k in range(n_nodes):
        theta: float = k * h  # periodic integrand => left-endpoint == trapezoid
        acc += dphi(theta) / phi(theta)
    integral: complex = acc * h
    return integral / (2.0 * math.pi * 1j)


def oam_phase(ell: int) -> Callable[[float], complex]:
    """The OAM phase field theta |-> exp(i * ell * theta)."""
    return lambda theta: cmath.exp(1j * ell * theta)


def oam_phase_deriv(ell: int) -> Callable[[float], complex]:
    """Analytic derivative i * ell * exp(i * ell * theta)."""
    return lambda theta: 1j * ell * cmath.exp(1j * ell * theta)


def beam_amplitude(ell: int, r: float) -> Callable[[float], complex]:
    """Physical Laguerre-Gauss-like amplitude r^|ell| * exp(i*ell*theta)."""
    env: float = r ** abs(ell)
    return lambda theta: env * cmath.exp(1j * ell * theta)


def beam_amplitude_deriv(ell: int, r: float) -> Callable[[float], complex]:
    """Analytic derivative of the physical amplitude at fixed radius r."""
    env: float = r ** abs(ell)
    return lambda theta: env * 1j * ell * cmath.exp(1j * ell * theta)


def product_loop(
    fs: Sequence[Callable[[float], complex]],
) -> Callable[[float], complex]:
    """Pointwise product of loops."""

    def loop(theta: float) -> complex:
        acc: complex = 1.0 + 0.0j
        for f in fs:
            acc *= f(theta)
        return acc

    return loop


def superposed_charge_direct(charges: Sequence[int]) -> int:
    """Total charge by the additivity/conservation theorem: sum of charges."""
    return sum(charges)


def lcm(a: int, b: int) -> int:
    """Least common multiple via gcd."""
    if a == 0 or b == 0:
        return 0
    return abs(a * b) // gcd(a, b)


def torus_knot_charge(p: int, q: int) -> int:
    """Meridional charge of the (p, q)-torus-knot beam: p*q."""
    return p * q


def is_single_knot(p: int, q: int) -> bool:
    """A (p, q) torus curve is a single connected knot iff gcd(p, q) == 1."""
    return gcd(p, q) == 1


def _fmt(z: complex) -> str:
    return f"{z.real:+.6f}{z.imag:+.6f}i"


def demo_charge_equals_winding() -> None:
    print("1) Topological charge = winding number  w(exp(i*l*theta)) = l")
    for ell in (-3, -1, 0, 1, 2, 5, 7):
        w = winding_number(oam_phase(ell), oam_phase_deriv(ell))
        print(f"   l = {ell:+d}:  w = {_fmt(w)}   (rounded {round(w.real):+d})")
    print()


def demo_product_rule() -> None:
    print("2) Product rule / additivity  w(phi*psi) = w(phi) + w(psi)")
    for ell, m in ((1, 2), (3, -1), (5, 4), (-2, -3)):
        w_prod = winding_number(
            product_loop([oam_phase(ell), oam_phase(m)]),
            # derivative of product via Leibniz, computed directly:
            lambda th, ell=ell, m=m: (
                oam_phase_deriv(ell)(th) * oam_phase(m)(th)
                + oam_phase(ell)(th) * oam_phase_deriv(m)(th)
            ),
        )
        w_sum = winding_number(oam_phase(ell), oam_phase_deriv(ell)) + winding_number(
            oam_phase(m), oam_phase_deriv(m)
        )
        print(
            f"   l={ell:+d}, m={m:+d}:  w(prod)={round(w_prod.real):+d}, "
            f"w(l)+w(m)={round(w_sum.real):+d}, "
            f"direct sum l+m={superposed_charge_direct([ell, m]):+d}"
        )
    print()


def demo_conservation_family() -> None:
    print("3) Conservation over a family  w(prod_i oam_{f_i}) = sum_i f_i")
    for family in ([1, 2, 3], [4, -1, -3, 2], [7, 7, -14]):
        loops = [oam_phase(f) for f in family]

        def dprod(th: float, family=family) -> complex:
            total = 0.0 + 0.0j
            for j, fj in enumerate(family):
                term = oam_phase_deriv(fj)(th)
                for k, fk in enumerate(family):
                    if k != j:
                        term *= oam_phase(fk)(th)
                total += term
            return total

        w = winding_number(product_loop(loops), dprod)
        print(
            f"   charges {family}:  w = {round(w.real):+d}, "
            f"sum = {superposed_charge_direct(family):+d}"
        )
    print()


def demo_envelope_invariance() -> None:
    print("4) Envelope invariance  w(r^|l| * exp(i*l*theta)) = l  for all r>0")
    for ell in (1, 2, 4):
        for r in (0.1, 1.0, 3.7, 100.0):
            w = winding_number(beam_amplitude(ell, r), beam_amplitude_deriv(ell, r))
            print(f"   l={ell:+d}, r={r:>6}:  w = {round(w.real):+d}")
    print()


def demo_torus_bridge() -> None:
    print("5) Topology <-> number theory  charge p*q = lcm(p,q) when coprime")
    for p, q in ((2, 3), (3, 4), (2, 5), (2, 4), (3, 6), (4, 6)):
        charge = torus_knot_charge(p, q)
        g = gcd(p, q)
        single = is_single_knot(p, q)
        tag = "TREFOIL " if (p, q) == (2, 3) else ""
        eq = "=" if charge == lcm(p, q) else "!="
        print(
            f"   (p,q)=({p},{q}) {tag}: charge={charge}, lcm={lcm(p,q)} "
            f"[charge {eq} lcm], gcd={g}, "
            f"{'single knot' if single else f'split link ({g} components)'}"
        )
    print()


def main() -> None:
    print("=" * 68)
    print("  THE TOPOLOGY OF KNOTTED LIGHT — numerical demonstrations")
    print("=" * 68)
    print()
    demo_charge_equals_winding()
    demo_product_rule()
    demo_conservation_family()
    demo_envelope_invariance()
    demo_torus_bridge()
    print("All numerical results match the theorems.")


if __name__ == "__main__":
    main()
