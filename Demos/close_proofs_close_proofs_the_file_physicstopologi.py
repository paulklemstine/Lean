"""
Numerical demonstrations for:

  "Polynomials as Bridges: Certified Mahler-Measure Positivity for Lehmer's
   Polynomial and Degree-Stability of the Apollonian Koopman Action"

This script is fully self-contained: it uses only the Python standard library
(no numpy / sympy). It illustrates, numerically, the certified results:

  * Lehmer's polynomial L(x) = x^10 + x^9 - x^7 - x^6 - x^5 - x^4 - x^3 + x + 1
      - is monic of degree 10 and nonzero,
      - has L(1) = -1 < 0 and L(2) = 1291 > 0, hence a real root in (1, 2)
        by the Intermediate Value Theorem (a spectral-escape witness),
      - has a Salem root  ~ 1.176280818  outside the unit circle,
      - has logarithmic Mahler measure m(L) ~ 0.162357 > 0,
        i.e. Mahler measure M(L) ~ 1.176281.
  * Cyclotomic polynomials have all roots on the unit circle and Mahler measure 1.
  * The Apollonian (Descartes) reflections act on polynomial observables by
    precomposition and preserve total degree.

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from typing import Dict, List, Tuple

# ----------------------------------------------------------------------------
# Univariate integer/real polynomials represented as coefficient lists
# coeffs[k] is the coefficient of x^k (ascending order).
# ----------------------------------------------------------------------------

# Lehmer's polynomial L(x) = x^10 + x^9 - x^7 - x^6 - x^5 - x^4 - x^3 + x + 1
#                 degree:    0  1  2  3   4   5   6   7  8  9 10
LEHMER: List[int] = [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1]


def poly_eval(coeffs: List[float], x: complex) -> complex:
    """Evaluate a polynomial (ascending coeffs) at x via Horner's rule."""
    result: complex = 0
    for c in reversed(coeffs):
        result = result * x + c
    return result


def poly_degree(coeffs: List[float]) -> int:
    """Degree = index of the highest nonzero coefficient (-1 for the zero poly)."""
    for k in range(len(coeffs) - 1, -1, -1):
        if coeffs[k] != 0:
            return k
    return -1


def is_monic(coeffs: List[float]) -> bool:
    """True iff the leading coefficient equals 1."""
    d = poly_degree(coeffs)
    return d >= 0 and coeffs[d] == 1


def bisection_real_root(
    coeffs: List[float], a: float, b: float, tol: float = 1e-15, iters: int = 200
) -> float:
    """Bracket a real root in (a, b) by bisection (faithful to the IVT proof).

    Requires a sign change: poly_eval(a) * poly_eval(b) < 0.
    """
    fa = poly_eval(coeffs, a).real
    fb = poly_eval(coeffs, b).real
    if fa == 0:
        return a
    if fb == 0:
        return b
    if fa * fb > 0:
        raise ValueError("no sign change on the bracket; IVT does not apply")
    for _ in range(iters):
        m = 0.5 * (a + b)
        fm = poly_eval(coeffs, m).real
        if fm == 0 or (b - a) < tol:
            return m
        if fa * fm < 0:
            b, fb = m, fm
        else:
            a, fa = m, fm
    return 0.5 * (a + b)


def durand_kerner_roots(
    coeffs: List[float], iters: int = 1000, tol: float = 1e-14
) -> List[complex]:
    """All complex roots via the Durand-Kerner (Weierstrass) iteration.

    Pure-Python, no external dependencies. Assumes a monic-able polynomial of
    degree >= 1.
    """
    d = poly_degree(coeffs)
    if d < 1:
        return []
    lead = coeffs[d]
    monic = [c / lead for c in coeffs[: d + 1]]

    def f(z: complex) -> complex:
        return poly_eval(monic, z)

    # Spread initial guesses on a circle to break symmetry.
    seed = complex(0.4, 0.9)
    roots: List[complex] = [seed ** k for k in range(d)]
    for _ in range(iters):
        max_delta = 0.0
        new_roots = roots[:]
        for i in range(d):
            num = f(roots[i])
            den: complex = 1.0
            for j in range(d):
                if j != i:
                    den *= roots[i] - roots[j]
            if den == 0:
                continue
            delta = num / den
            new_roots[i] = roots[i] - delta
            max_delta = max(max_delta, abs(delta))
        roots = new_roots
        if max_delta < tol:
            break
    return roots


def log_mahler_measure(coeffs: List[float]) -> float:
    """m(P) = sum over roots alpha of max(0, log|alpha|)  (monic case).

    Implements the certified root-factorization formula numerically.
    """
    roots = durand_kerner_roots(coeffs)
    return sum(max(0.0, math.log(abs(r))) for r in roots if abs(r) > 0)


def mahler_measure(coeffs: List[float]) -> float:
    """M(P) = exp(m(P))."""
    return math.exp(log_mahler_measure(coeffs))


# Some cyclotomic polynomials (ascending coeffs) for comparison.
CYCLOTOMICS: Dict[int, List[int]] = {
    1: [-1, 1],            # x - 1
    2: [1, 1],             # x + 1
    3: [1, 1, 1],          # x^2 + x + 1
    4: [1, 0, 1],          # x^2 + 1
    6: [1, -1, 1],         # x^2 - x + 1
    5: [1, 1, 1, 1, 1],    # x^4 + x^3 + x^2 + x + 1
}


# ----------------------------------------------------------------------------
# Multivariate polynomials in 4 observable variables X0..X3.
# Represented as dict: exponent-tuple (e0,e1,e2,e3) -> coefficient.
# ----------------------------------------------------------------------------

Exp = Tuple[int, int, int, int]
MPoly = Dict[Exp, float]


def mpoly_total_degree(p: MPoly) -> int:
    """Total degree = max over monomials of the sum of exponents (-1 if empty)."""
    deg = -1
    for exp, c in p.items():
        if c != 0:
            deg = max(deg, sum(exp))
    return deg


def mpoly_add(a: MPoly, b: MPoly) -> MPoly:
    out: MPoly = dict(a)
    for exp, c in b.items():
        out[exp] = out.get(exp, 0.0) + c
    return {e: c for e, c in out.items() if c != 0}


def mpoly_mul(a: MPoly, b: MPoly) -> MPoly:
    out: MPoly = {}
    for ea, ca in a.items():
        for eb, cb in b.items():
            e = (ea[0] + eb[0], ea[1] + eb[1], ea[2] + eb[2], ea[3] + eb[3])
            out[e] = out.get(e, 0.0) + ca * cb
    return {e: c for e, c in out.items() if c != 0}


def mpoly_one() -> MPoly:
    return {(0, 0, 0, 0): 1.0}


def mpoly_pow(p: MPoly, n: int) -> MPoly:
    result = mpoly_one()
    for _ in range(n):
        result = mpoly_mul(result, p)
    return result


# The four Descartes / Apollonian reflection generators (4x4 integer matrices).
# S_i fixes three curvatures and replaces b_i by -b_i + 2*(sum of the others).
def apollonian_generator(i: int) -> List[List[int]]:
    """Return the 4x4 integer matrix S_i, i in {0,1,2,3}."""
    S = [[1 if r == c else 0 for c in range(4)] for r in range(4)]
    for c in range(4):
        S[i][c] = 2 if c != i else -1
    return S


def apollonian_linear_form(i: int, j: int) -> MPoly:
    """Lambda_{i,j} = sum_l S_i[j,l] * X_l, a polynomial of total degree <= 1."""
    S = apollonian_generator(i)
    form: MPoly = {}
    for l in range(4):
        if S[j][l] != 0:
            exp = tuple(1 if t == l else 0 for t in range(4))  # type: ignore
            form[exp] = form.get(exp, 0.0) + S[j][l]  # type: ignore
    return form


def precompose_apollonian(i: int, p: MPoly) -> MPoly:
    """Koopman action: substitute X_j -> Lambda_{i,j} into p (precomposition)."""
    forms = [apollonian_linear_form(i, j) for j in range(4)]
    out: MPoly = {}
    for exp, c in p.items():
        term: MPoly = {(0, 0, 0, 0): c}
        for j in range(4):
            if exp[j] > 0:
                term = mpoly_mul(term, mpoly_pow(forms[j], exp[j]))
        out = mpoly_add(out, term)
    return out


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_lehmer_anatomy() -> None:
    print("=" * 70)
    print("Lehmer's polynomial: anatomy")
    print("=" * 70)
    print(f"  monic?         {is_monic(LEHMER)}")
    print(f"  degree         {poly_degree(LEHMER)}")
    print(f"  L(1)           {poly_eval(LEHMER, 1).real:.0f}   (negative => not cyclotomic)")
    print(f"  L(2)           {poly_eval(LEHMER, 2).real:.0f}")
    print()


def demo_lehmer_ivt() -> None:
    print("=" * 70)
    print("Spectral-escape witness via the Intermediate Value Theorem")
    print("=" * 70)
    a, b = 1.0, 2.0
    fa, fb = poly_eval(LEHMER, a).real, poly_eval(LEHMER, b).real
    print(f"  L({a}) = {fa:.0f},  L({b}) = {fb:.0f}  =>  sign change on (1, 2)")
    root = bisection_real_root(LEHMER, a, b)
    print(f"  bracketed real root in (1,2):  z = {root:.15f}")
    print(f"  |z| = {abs(root):.15f} > 1  =>  a root escapes the unit circle")
    print()


def demo_lehmer_mahler() -> None:
    print("=" * 70)
    print("Logarithmic Mahler measure (certified positive)")
    print("=" * 70)
    roots = durand_kerner_roots(LEHMER)
    outside = [r for r in roots if abs(r) > 1 + 1e-9]
    m = log_mahler_measure(LEHMER)
    M = mahler_measure(LEHMER)
    print(f"  number of roots                  {len(roots)}")
    print(f"  roots with |alpha| > 1           {len(outside)}")
    for r in sorted(outside, key=abs, reverse=True):
        print(f"    alpha = {r.real:+.6f}{r.imag:+.6f}i   |alpha| = {abs(r):.9f}")
    print(f"  m(L) = sum max(0, log|alpha|)    {m:.9f}   (> 0  : certified)")
    print(f"  M(L) = exp(m(L))                 {M:.9f}   (~ 1.176280818)")
    print()


def demo_cyclotomic_flatness() -> None:
    print("=" * 70)
    print("Cyclotomic polynomials are flat (Mahler measure = 1)")
    print("=" * 70)
    for n, c in sorted(CYCLOTOMICS.items()):
        roots = durand_kerner_roots(c) if poly_degree(c) >= 1 else []
        max_mod = max((abs(r) for r in roots), default=1.0)
        M = mahler_measure(c)
        print(f"  Phi_{n:<2d} : deg {poly_degree(c)},  max|root| = {max_mod:.6f},  M = {M:.6f}")
    print()


def demo_apollonian_degree_preservation() -> None:
    print("=" * 70)
    print("Apollonian Koopman action preserves total degree")
    print("=" * 70)
    # A few sample observables of various total degrees.
    samples: List[Tuple[str, MPoly]] = [
        ("X0", {(1, 0, 0, 0): 1.0}),
        ("X0 + X3", {(1, 0, 0, 0): 1.0, (0, 0, 0, 1): 1.0}),
        ("X0*X1 - X2^2", {(1, 1, 0, 0): 1.0, (0, 0, 2, 0): -1.0}),
        ("X0^3 + X1*X2*X3", {(3, 0, 0, 0): 1.0, (0, 1, 1, 1): 1.0}),
    ]
    for i in range(4):
        print(f"  generator S_{i}:")
        for name, p in samples:
            q = precompose_apollonian(i, p)
            dp, dq = mpoly_total_degree(p), mpoly_total_degree(q)
            ok = "OK" if dq <= dp else "FAIL"
            print(f"    deg({name:<14}) = {dp}  ->  deg(K_{i} p) = {dq}   [{ok}]")
    print()
    # Coordinate images are affine-linear (degree <= 1).
    print("  coordinate images K_i(X_j) have total degree <= 1:")
    for i in range(4):
        degs = [mpoly_total_degree(precompose_apollonian(i, {tuple(1 if t == j else 0 for t in range(4)): 1.0})) for j in range(4)]  # type: ignore
        print(f"    S_{i}:  degrees of images = {degs}")
    print()


def main() -> None:
    demo_lehmer_anatomy()
    demo_lehmer_ivt()
    demo_lehmer_mahler()
    demo_cyclotomic_flatness()
    demo_apollonian_degree_preservation()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
