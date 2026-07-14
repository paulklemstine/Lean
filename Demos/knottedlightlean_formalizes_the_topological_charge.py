"""
Numerical demonstrations for:

    The Winding Number as the Topological Charge of Knotted Light

This self-contained script illustrates, purely numerically, the main results:

  1. The winding number of the OAM phase e^{i l theta} equals l.
  2. Integrality: the winding number of any closed non-vanishing loop is an
     integer.
  3. Additivity under multiplication:  w(g * d) = w(g) + w(d).
  4. Inversion negates charge:         w(1/g)   = -w(g).
  5. Amplitude invariance:             w(c * g) =  w(g)   (c != 0).
  6. Non-additivity under addition:    w(f + f) != w(f) + w(f) in general.
  7. Charge annihilation:              two opposite vortices multiply to charge 0.

All functions are inlined; only the Python standard library is used.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable

Field = Callable[[float], complex]


# ---------------------------------------------------------------------------
# Core numerics
# ---------------------------------------------------------------------------
def winding_by_unwrap(phi: Field, n: int = 20000) -> float:
    """Winding number by summing principal-branch phase increments.

    Samples ``phi`` at ``n`` equally spaced points on [0, 2*pi] and accumulates
    ``arg(phi_{k+1} / phi_k)`` in (-pi, pi]. For a closed non-vanishing loop the
    sum divided by 2*pi is the (integer) winding number. Complexity O(n).
    """
    total = 0.0
    prev = phi(0.0)
    for k in range(1, n + 1):
        theta = 2.0 * math.pi * k / n
        cur = phi(theta)
        total += cmath.phase(cur / prev)  # principal value in (-pi, pi]
        prev = cur
    return total / (2.0 * math.pi)


def winding_by_contour(phi: Field, dphi: Field, n: int = 20000) -> complex:
    """Winding number as the log-derivative contour integral.

        (1 / 2*pi*i) * integral_0^{2*pi} phi'(theta) / phi(theta) d theta

    Uses the trapezoidal rule (spectrally accurate for smooth periodic
    integrands). Requires an analytic derivative ``dphi``. Complexity O(n).
    """
    acc = 0.0 + 0.0j
    h = 2.0 * math.pi / n
    for k in range(n):  # periodic trapezoid == plain average of samples
        theta = h * k
        acc += dphi(theta) / phi(theta)
    integral = acc * h
    return integral / (2.0 * math.pi * 1j)


# ---------------------------------------------------------------------------
# The canonical OAM phase field and helpers
# ---------------------------------------------------------------------------
def oam_phase(ell: int) -> Field:
    """The OAM phase field  theta |-> exp(i * ell * theta)."""
    return lambda theta: cmath.exp(1j * ell * theta)


def oam_phase_deriv(ell: int) -> Field:
    """Analytic derivative of the OAM phase:  i * ell * exp(i * ell * theta)."""
    return lambda theta: 1j * ell * cmath.exp(1j * ell * theta)


def product(f: Field, g: Field) -> Field:
    return lambda theta: f(theta) * g(theta)


def scaled(c: complex, f: Field) -> Field:
    return lambda theta: c * f(theta)


def summed(f: Field, g: Field) -> Field:
    return lambda theta: f(theta) + g(theta)


def inverted(f: Field) -> Field:
    return lambda theta: 1.0 / f(theta)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_charge_of_canonical_vortex() -> None:
    print("1) Winding number of e^{i l theta} equals l")
    for ell in range(-4, 5):
        w_unwrap = winding_by_unwrap(oam_phase(ell))
        w_contour = winding_by_contour(oam_phase(ell), oam_phase_deriv(ell))
        print(f"   l = {ell:+d}:  unwrap = {w_unwrap:+.6f},  "
              f"contour = {w_contour.real:+.6f}{w_contour.imag:+.1e}i")
    print()


def demo_integrality_general_loop() -> None:
    print("2) Integrality for a non-canonical closed loop")
    # A wobbly but closed, non-vanishing loop that still winds 3 times:
    #   g(theta) = (2 + sin(5 theta)) * exp(i * 3 * theta)
    def g(theta: float) -> complex:
        return (2.0 + math.sin(5.0 * theta)) * cmath.exp(3j * theta)
    w = winding_by_unwrap(g)
    print(f"   g(theta) = (2 + sin 5theta) e^(3 i theta):  w = {w:+.6f} "
          f"(rounds to {round(w):+d})")
    print()


def demo_additivity_under_multiplication() -> None:
    print("3) Additivity under multiplication:  w(g*d) = w(g) + w(d)")
    for a, b in [(2, 3), (5, -2), (-1, -4)]:
        g, d = oam_phase(a), oam_phase(b)
        w_prod = winding_by_unwrap(product(g, d))
        print(f"   w(l={a:+d} * l={b:+d}) = {w_prod:+.4f}   "
              f"vs  {a} + {b} = {a + b:+d}")
    print()


def demo_inversion() -> None:
    print("4) Inversion negates charge:  w(1/g) = -w(g)")
    for ell in [1, 3, -2]:
        w_inv = winding_by_unwrap(inverted(oam_phase(ell)))
        print(f"   w(1 / e^(i {ell:+d} theta)) = {w_inv:+.4f}  vs  -({ell:+d})"
              f" = {-ell:+d}")
    print()


def demo_amplitude_invariance() -> None:
    print("5) Amplitude invariance:  w(c*g) = w(g)  for c != 0")
    g = oam_phase(2)
    for c in [3.0 + 0j, 0.01 + 0j, -5.0 + 0j, 1.0 + 1.0j]:
        w = winding_by_unwrap(scaled(c, g))
        print(f"   c = {c}:  w(c * e^(2 i theta)) = {w:+.4f}  (unchanged: 2)")
    print()


def demo_non_additivity_under_sum() -> None:
    print("6) Non-additivity under pointwise addition")
    f = oam_phase(1)
    w_sum = winding_by_unwrap(summed(f, f))  # f + f = 2 f
    print(f"   w(e^(i theta) + e^(i theta)) = w(2 e^(i theta)) = {w_sum:+.4f}")
    print(f"   but  w(f) + w(f) = 1 + 1 = 2   ->   {round(w_sum)} != 2")
    print()


def demo_annihilation() -> None:
    print("7) Opposite vortices annihilate:  w(l * -l) = 0")
    g = product(oam_phase(1), oam_phase(-1))  # e^{i theta} * e^{-i theta} = 1
    w = winding_by_unwrap(g)
    print(f"   w(e^(i theta) * e^(-i theta)) = {w:+.4f}  (charge-0 beam)")
    print()


def main() -> None:
    print("=" * 68)
    print(" Topological charge of knotted light: numerical demonstrations")
    print("=" * 68)
    print()
    demo_charge_of_canonical_vortex()
    demo_integrality_general_loop()
    demo_additivity_under_multiplication()
    demo_inversion()
    demo_amplitude_invariance()
    demo_non_additivity_under_sum()
    demo_annihilation()


if __name__ == "__main__":
    main()
