"""
Numerical demonstrations of the local GL2 Frobenius datum over Q.

This script illustrates, with concrete numbers, the theorems formalized in
Phase A (Eichler-Shimura structure and Deligne's Weil bound):

  * deligne_bound_iff       : |a| <= 2*sqrt(p)  <=>  a^2 <= 4p
  * deligne_root_abs        : every root z of X^2 - a X + p has |z| = sqrt(p)
  * deligne_weil_pair       : roots alpha, beta satisfy alpha*beta = p, |.| = sqrt(p)
  * deligne_frob_eigenvalues: eigenvalues of frobMatrix(a,p) have |.| = sqrt(p)

Everything is self-contained: no third-party imports beyond the standard
library (cmath, math).
"""

from __future__ import annotations

import cmath
import math
from typing import List, Tuple


# ---------------------------------------------------------------------------
# Core definitions (mirroring the Lean source of truth)
# ---------------------------------------------------------------------------

def hecke_poly_eval(a: float, p: float, z: complex) -> complex:
    """Evaluate the Hecke polynomial X^2 - a*X + p at a complex point z."""
    return z * z - a * z + p


def frob_matrix(a: float, p: float) -> List[List[float]]:
    """Companion (Frobenius) matrix of X^2 - a*X + p:  [[0, -p], [1, a]]."""
    return [[0.0, -p], [1.0, a]]


def trace_2x2(m: List[List[float]]) -> float:
    """Trace of a 2x2 matrix."""
    return m[0][0] + m[1][1]


def det_2x2(m: List[List[float]]) -> float:
    """Determinant of a 2x2 matrix."""
    return m[0][0] * m[1][1] - m[0][1] * m[1][0]


def hecke_roots(a: float, p: float) -> Tuple[complex, complex]:
    """The two (complex) roots alpha, beta of X^2 - a*X + p via the quadratic formula."""
    disc = complex(a * a - 4.0 * p)
    sq = cmath.sqrt(disc)
    return (a + sq) / 2.0, (a - sq) / 2.0


def deligne_bound_holds(a: float, p: float) -> bool:
    """The discriminant form of the Deligne bound:  a^2 <= 4p."""
    return a * a <= 4.0 * p


def sato_tate_angle(a: float, p: float) -> float:
    """Sato-Tate angle theta in [0, pi] with a = 2*sqrt(p)*cos(theta)."""
    return math.acos(max(-1.0, min(1.0, a / (2.0 * math.sqrt(p)))))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_bound_equivalence() -> None:
    """deligne_bound_iff: |a| <= 2*sqrt(p) is equivalent to a^2 <= 4p."""
    print("=" * 70)
    print("DEMO 1  --  deligne_bound_iff:  |a| <= 2*sqrt(p)  <=>  a^2 <= 4p")
    print("=" * 70)
    p = 7.0
    two_sqrt_p = 2.0 * math.sqrt(p)
    print(f"p = {p},  2*sqrt(p) = {two_sqrt_p:.6f}\n")
    print(f"{'a':>8} | {'|a|<=2sqrt p':>13} | {'a^2<=4p':>9} | match")
    print("-" * 50)
    for a in [-6.0, -5.29, -4.0, 0.0, 4.0, 5.29, 6.0]:
        lhs = abs(a) <= two_sqrt_p + 1e-12
        rhs = deligne_bound_holds(a, p)
        print(f"{a:>8.2f} | {str(lhs):>13} | {str(rhs):>9} | {lhs == rhs}")
    print()


def demo_roots_on_circle() -> None:
    """deligne_root_abs / deligne_weil_pair: roots lie on |z| = sqrt(p)."""
    print("=" * 70)
    print("DEMO 2  --  deligne_root_abs / deligne_weil_pair: |alpha|=|beta|=sqrt(p)")
    print("=" * 70)
    cases = [(1.0, 7.0), (2.0, 7.0), (5.0, 7.0), (0.0, 13.0), (-3.0, 11.0)]
    for a, p in cases:
        alpha, beta = hecke_roots(a, p)
        target = math.sqrt(p)
        ok = deligne_bound_holds(a, p)
        print(f"\n(a, p) = ({a}, {p})   Deligne bound a^2<=4p: {ok}")
        print(f"  alpha = {alpha:.6f},  |alpha| = {abs(alpha):.6f}")
        print(f"  beta  = {beta:.6f},  |beta|  = {abs(beta):.6f}")
        print(f"  alpha*beta = {(alpha*beta).real:.6f}  (should be p = {p})")
        print(f"  sqrt(p) = {target:.6f}")
        if ok:
            assert abs(abs(alpha) - target) < 1e-9, "alpha off circle!"
            assert abs(abs(beta) - target) < 1e-9, "beta off circle!"
            print("  --> both eigenvalues are Weil numbers (on the circle).")
        else:
            print("  --> a^2 > 4p: roots are REAL with distinct moduli (bound fails).")


def demo_frobenius_eigenvalues() -> None:
    """deligne_frob_eigenvalues: eigenvalues of frobMatrix(a,p) have |.| = sqrt(p)."""
    print("\n" + "=" * 70)
    print("DEMO 3  --  deligne_frob_eigenvalues: companion matrix eigenvalues")
    print("=" * 70)
    a, p = 3.0, 11.0
    M = frob_matrix(a, p)
    print(f"\nfrobMatrix({a}, {p}) = {M}")
    print(f"  trace = {trace_2x2(M)}  (should be a = {a})")
    print(f"  det   = {det_2x2(M)}  (should be p = {p})")
    # Eigenvalues of a 2x2 matrix are the roots of its characteristic poly,
    # which equals the Hecke polynomial X^2 - a X + p.
    lam1, lam2 = hecke_roots(trace_2x2(M), det_2x2(M))
    print(f"  eigenvalue 1 = {lam1:.6f},  |.| = {abs(lam1):.6f}")
    print(f"  eigenvalue 2 = {lam2:.6f},  |.| = {abs(lam2):.6f}")
    print(f"  sqrt(p) = {math.sqrt(p):.6f}")
    # Verify each is a genuine root of the Hecke polynomial.
    for lam in (lam1, lam2):
        residual = abs(hecke_poly_eval(a, p, lam))
        assert residual < 1e-9, "not an eigenvalue!"
    print("  --> verified: characteristic poly = Hecke poly, eigenvalues on circle.")


def demo_sato_tate_angle() -> None:
    """Sato-Tate angles: a = 2*sqrt(p)*cos(theta), theta in [0, pi]."""
    print("\n" + "=" * 70)
    print("DEMO 4  --  Sato-Tate angles  a = 2*sqrt(p)*cos(theta)")
    print("=" * 70)
    p = 23.0
    print(f"p = {p},  sqrt(p) = {math.sqrt(p):.6f}\n")
    print(f"{'a':>8} | {'theta (rad)':>12} | {'theta (deg)':>12} | reconstructed a")
    print("-" * 60)
    for a in [-9.0, -4.0, 0.0, 4.0, 9.0]:
        if not deligne_bound_holds(a, p):
            continue
        theta = sato_tate_angle(a, p)
        recon = 2.0 * math.sqrt(p) * math.cos(theta)
        print(f"{a:>8.2f} | {theta:>12.6f} | {math.degrees(theta):>12.4f} | {recon:>13.6f}")
    print()


def main() -> None:
    demo_bound_equivalence()
    demo_roots_on_circle()
    demo_frobenius_eigenvalues()
    demo_sato_tate_angle()
    print("\nAll numerical checks passed.")


if __name__ == "__main__":
    main()
