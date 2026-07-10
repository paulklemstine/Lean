"""
Numerical demonstrations for:

    A Spectral-Arithmetic Dictionary for the Ihara Zeta Function of a Regular Graph

For a (q+1)-regular graph with adjacency eigenvalues {lambda_j}, the inverse
Ihara zeta function is

    zeta_G(u)^{-1} = (1 - u^2)^{(n-1)(q-1)/2} * prod_j (1 - lambda_j u + q u^2).

Each quadratic  p(lambda, q, u) = 1 - lambda u + q u^2  is a "local factor"
having the shape of the Euler factor 1 - a T + p T^2 of an elliptic curve.

This script demonstrates, with no external dependencies:
  1. the local-factor functional equation  q u^2 p(l, q, 1/(qu)) = p(l, q, u);
  2. the reciprocal-root factorization  p = (1 - a u)(1 - b u),  a b = q;
  3. the Riemann Hypothesis:  |z| = 1/sqrt(q) for zeros when lambda^2 <= 4q,
     and two distinct real straddling zeros of product 1/q when lambda^2 > 4q;
  4. the cycle-graph collapse  det(I - A u + u^2 I) = (1 - u^n)^2.
"""

from __future__ import annotations

import cmath
import math
from typing import List, Tuple


# --------------------------------------------------------------------------
# Core objects
# --------------------------------------------------------------------------
def local_factor(lam: complex, q: complex, u: complex) -> complex:
    """The Bass-Ihara local factor p(lambda, q, u) = 1 - lambda*u + q*u^2."""
    return 1 - lam * u + q * u ** 2


def local_factor_zeros(lam: float, q: float) -> Tuple[complex, complex]:
    """Return the two zeros z of p(lam, q, z) = q z^2 - lam z + 1 = 0."""
    disc = complex(lam * lam - 4 * q)
    root = cmath.sqrt(disc)
    return (lam - root) / (2 * q), (lam + root) / (2 * q)


def frobenius_roots(lam: float, q: float) -> Tuple[complex, complex]:
    """Reciprocal (Frobenius-type) roots alpha, beta: alpha+beta=lam, alpha*beta=q."""
    disc = complex(lam * lam - 4 * q)
    root = cmath.sqrt(disc)
    return (lam + root) / 2, (lam - root) / 2


# --------------------------------------------------------------------------
# 1. Functional equation
# --------------------------------------------------------------------------
def demo_functional_equation() -> None:
    print("=" * 68)
    print("1. Functional equation:  q u^2 p(l,q,1/(qu)) = p(l,q,u)")
    print("=" * 68)
    for lam, q, u in [(1.3, 2.0, 0.4 + 0.2j), (-0.7, 3.0, 0.9j), (2.0, 5.0, 0.31)]:
        lhs = q * u ** 2 * local_factor(lam, q, 1 / (q * u))
        rhs = local_factor(lam, q, u)
        print(f"  l={lam:+.2f} q={q:.1f} u={u}: "
              f"|LHS-RHS| = {abs(lhs - rhs):.2e}")
    print()


# --------------------------------------------------------------------------
# 2. Reciprocal-root factorization
# --------------------------------------------------------------------------
def demo_factorization() -> None:
    print("=" * 68)
    print("2. Factorization:  p = (1 - a u)(1 - b u),  a+b=l,  a*b=q")
    print("=" * 68)
    for lam, q in [(1.3, 2.0), (3.5, 2.0), (-2.0, 4.0)]:
        a, b = frobenius_roots(lam, q)
        u = 0.37 + 0.11j
        direct = local_factor(lam, q, u)
        factored = (1 - a * u) * (1 - b * u)
        print(f"  l={lam:+.2f} q={q:.1f}: a+b={ (a+b).real:+.3f}, "
              f"a*b={(a*b).real:.3f} (=q), |p - (1-au)(1-bu)|={abs(direct-factored):.2e}")
    print()


# --------------------------------------------------------------------------
# 3. Riemann Hypothesis dichotomy
# --------------------------------------------------------------------------
def demo_riemann_hypothesis() -> None:
    print("=" * 68)
    print("3. Riemann Hypothesis dichotomy at threshold l^2 = 4q")
    print("=" * 68)
    q = 3.0
    crit = 1 / math.sqrt(q)
    print(f"  q = {q},  critical radius 1/sqrt(q) = {crit:.6f}\n")
    for lam in [2.0, 2 * math.sqrt(q), 4.5]:
        z1, z2 = local_factor_zeros(lam, q)
        regime = "RAMANUJAN (l^2 <= 4q)" if lam * lam <= 4 * q + 1e-12 else "NON-RAMANUJAN"
        print(f"  l = {lam:.4f}  [{regime}]")
        print(f"    zeros: {z1:.4f}, {z2:.4f}")
        print(f"    |z1| = {abs(z1):.6f}, |z2| = {abs(z2):.6f}, "
              f"product = {(z1*z2).real:.6f} (= 1/q = {1/q:.6f})")
        if lam * lam > 4 * q:
            inside = min(abs(z1), abs(z2)) < crit
            outside = max(abs(z1), abs(z2)) > crit
            print(f"    straddles critical circle: inside={inside}, outside={outside}")
        print()


# --------------------------------------------------------------------------
# 4. Cycle graph collapse
# --------------------------------------------------------------------------
def cycle_eigenvalues(n: int) -> List[float]:
    """Adjacency eigenvalues of C_n:  2 cos(2 pi k / n)."""
    return [2 * math.cos(2 * math.pi * k / n) for k in range(n)]


def cycle_determinant(n: int, u: complex) -> complex:
    """Product over the spectrum of local factors with q = 1."""
    prod = 1 + 0j
    for lam in cycle_eigenvalues(n):
        prod *= local_factor(lam, 1.0, u)
    return prod


def demo_cycle_graph() -> None:
    print("=" * 68)
    print("4. Cycle graph:  det(I - A u + u^2 I) = (1 - u^n)^2")
    print("=" * 68)
    for n in [3, 4, 5, 6, 7]:
        u = 0.42 + 0.17j
        det = cycle_determinant(n, u)
        closed = (1 - u ** n) ** 2
        print(f"  n = {n}: |det - (1 - u^{n})^2| = {abs(det - closed):.2e}")
    print()


# --------------------------------------------------------------------------
def main() -> None:
    demo_functional_equation()
    demo_factorization()
    demo_riemann_hypothesis()
    demo_cycle_graph()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
