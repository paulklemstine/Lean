"""
Numerical demonstrations for the global spectral Ihara zeta function of a graph.

The global spectral zeta (reciprocal, entire form) is

    Z^{-1}(u) = prod_i ( 1 - lambda_i * u + q * u^2 )

for a (q+1)-regular graph with adjacency spectrum {lambda_i} and parameter q > 0.

We verify:
  * normalization  Z^{-1}(0) = 1
  * Euler-product multiplicativity over disjoint unions of spectra
  * the global functional equation  (q u^2)^n Z^{-1}(1/(qu)) = Z^{-1}(u)
  * the local Riemann Hypothesis: lambda^2 <= 4q  =>  every root has |z| = 1/sqrt(q)
  * the converse: lambda^2 > 4q  =>  an off-circle real root
  * the equivalence  RH  <=>  Ramanujan

Self-contained: standard library + cmath/math only.
"""

from __future__ import annotations

import cmath
import math
from typing import List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Core definitions
# --------------------------------------------------------------------------- #
def euler_factor(lam: complex, q: complex, u: complex) -> complex:
    """Local Bass-Ihara Euler factor p(lambda, q, u) = 1 - lambda*u + q*u^2."""
    return 1 - lam * u + q * u ** 2


def zeta_inv(spectrum: Sequence[complex], q: complex, u: complex) -> complex:
    """Global spectral zeta Z^{-1}(u) = prod_i (1 - lambda_i u + q u^2)."""
    result: complex = 1 + 0j
    for lam in spectrum:
        result *= euler_factor(lam, q, u)
    return result


def factor_roots(lam: float, q: float) -> Tuple[complex, complex]:
    """The two roots (in u) of q u^2 - lambda u + 1 = 0."""
    disc = cmath.sqrt(lam ** 2 - 4 * q)
    return ((lam + disc) / (2 * q), (lam - disc) / (2 * q))


def critical_radius(q: float) -> float:
    """Radius 1/sqrt(q) of the critical circle."""
    return 1.0 / math.sqrt(q)


def is_ramanujan(spectrum: Sequence[float], q: float) -> bool:
    """True iff every eigenvalue satisfies the Ramanujan bound lambda^2 <= 4q."""
    return all(lam ** 2 <= 4 * q + 1e-12 for lam in spectrum)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_normalization() -> None:
    print("=" * 70)
    print("Normalization:  Z^{-1}(0) = 1")
    print("=" * 70)
    spectrum = [2.0, -1.0, -1.0, 0.5]
    q = 2.0
    val = zeta_inv(spectrum, q, 0.0)
    print(f"  spectrum = {spectrum}, q = {q}")
    print(f"  Z^-1(0)  = {val:.12f}   (expected 1)")
    print()


def demo_multiplicativity() -> None:
    print("=" * 70)
    print("Euler-product multiplicativity:  Z^-1_{s U t} = Z^-1_s * Z^-1_t")
    print("=" * 70)
    s = [1.5, -0.5]
    t = [2.0, -1.0, 0.3]
    q, u = 3.0, 0.21 + 0.11j
    lhs = zeta_inv(s + t, q, u)
    rhs = zeta_inv(s, q, u) * zeta_inv(t, q, u)
    print(f"  s = {s}, t = {t}, q = {q}, u = {u}")
    print(f"  Z^-1_{{s U t}}(u) = {lhs:.10f}")
    print(f"  Z^-1_s * Z^-1_t  = {rhs:.10f}")
    print(f"  max |difference| = {abs(lhs - rhs):.2e}")
    print()


def demo_functional_equation() -> None:
    print("=" * 70)
    print("Functional equation:  (q u^2)^n Z^-1(1/(q u)) = Z^-1(u)")
    print("=" * 70)
    spectrum = [2.0, 0.7, -1.3, -0.4]
    q = 5.0
    n = len(spectrum)
    for u in (0.3 + 0.2j, -0.15 + 0.4j, 0.5 - 0.1j):
        lhs = (q * u ** 2) ** n * zeta_inv(spectrum, q, 1 / (q * u))
        rhs = zeta_inv(spectrum, q, u)
        print(f"  u = {u!s:>16}:  |LHS - RHS| = {abs(lhs - rhs):.2e}")
    print()


def demo_local_rh() -> None:
    print("=" * 70)
    print("Local RH:  lambda^2 <= 4q  =>  both roots have |z| = 1/sqrt(q)")
    print("=" * 70)
    q = 4.0
    r = critical_radius(q)
    print(f"  q = {q}, critical radius 1/sqrt(q) = {r:.6f}")
    for lam in (-4.0, -2.0, 0.0, 2.0, 3.9):  # all satisfy lam^2 <= 16
        z1, z2 = factor_roots(lam, q)
        print(f"  lambda = {lam:+.2f}:  |z1| = {abs(z1):.6f}, "
              f"|z2| = {abs(z2):.6f}  (on circle: "
              f"{abs(abs(z1) - r) < 1e-9 and abs(abs(z2) - r) < 1e-9})")
    print()


def demo_converse() -> None:
    print("=" * 70)
    print("Converse:  lambda^2 > 4q  =>  an off-circle real root")
    print("=" * 70)
    q = 4.0
    r = critical_radius(q)
    for lam in (5.0, 7.0, -6.0):  # violate lam^2 <= 16
        z1, z2 = factor_roots(lam, q)
        print(f"  lambda = {lam:+.2f}:  roots {z1.real:+.5f}, {z2.real:+.5f}  "
              f"(product = {(z1 * z2).real:.5f} = 1/q; off circle since "
              f"|z1|={abs(z1):.4f} != {r:.4f})")
    print()


def demo_rh_iff_ramanujan() -> None:
    print("=" * 70)
    print("Equivalence:  RH  <=>  Ramanujan")
    print("=" * 70)
    examples = [
        ("Cycle C_6 (q=1)", [2 * math.cos(2 * math.pi * k / 6) for k in range(6)], 1.0),
        ("Complete K_5 (q=3)", [4.0, -1.0, -1.0, -1.0, -1.0], 3.0),
        ("Non-expander (q=2)", [3.0, 4.0, -1.0, 0.5], 2.0),
    ]
    for name, spectrum, q in examples:
        r = critical_radius(q)
        ram = is_ramanujan(spectrum, q)
        # collect all zeros of Z^-1 and check they lie on the circle
        on_circle = True
        for lam in spectrum:
            for z in factor_roots(lam, q):
                if abs(abs(z) - r) > 1e-7:
                    on_circle = False
        print(f"  {name:24s}: Ramanujan = {ram!s:5s} | RH(all zeros on circle) "
              f"= {on_circle!s:5s} | match = {ram == on_circle}")
    print()


def main() -> None:
    demo_normalization()
    demo_multiplicativity()
    demo_functional_equation()
    demo_local_rh()
    demo_converse()
    demo_rh_iff_ramanujan()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
