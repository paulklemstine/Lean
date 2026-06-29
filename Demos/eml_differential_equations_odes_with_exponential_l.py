"""
Numerical demonstrations for:

    The Projective Galois Structure of the Riccati Equation
    and the Kovacic Obstruction for EML Ordinary Differential Equations

This self-contained script illustrates the paper's main results numerically:

  1. The DIFFERENCE LAW (`riccati_diff`): the difference of two Riccati
     solutions satisfies a first-order linear equation.
  2. The CROSS-RATIO INVARIANCE (`riccati_crossRatio_isConstant`): the
     cross-ratio of four Riccati solutions is constant in x (PGL2 invariant).
  3. The ODD-DEGREE OBSTRUCTION (`no_rational_solves_riccati_odd_deg`,
     `no_rational_solves_riccati_airy`): the cleared Riccati identity
     p'q - pq' + p^2 = f q^2 fails on parity for odd-degree f (Airy: f = X).
  4. The SHARPNESS WITNESS (`riccati_evenDeg_solvable`): f = X^2 + 1 has the
     explicit polynomial Riccati solution v = X (i.e. y = e^{x^2/2}).

All functions are inlined and type-hinted; no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# Part A. Analytic Riccati solutions from a second-order linear ODE.
#
# Take y'' = y  (i.e. p = 0, q = -1).  Its solutions are y = A e^x + B e^{-x}.
# The logarithmic derivative v = y'/y solves the Riccati equation
#     v' + v^2 - 1 = 0.
# Different (A, B) give different Riccati solutions, parametrized projectively
# by the ratio A:B -- exactly the PGL2 picture.
# ---------------------------------------------------------------------------

def riccati_solution(A: float, B: float) -> Callable[[float], float]:
    """Return v(x) = y'/y for y = A e^x + B e^{-x}, a solution of v' + v^2 = 1."""
    def v(x: float) -> float:
        ex, emx = math.exp(x), math.exp(-x)
        y = A * ex + B * emx
        yp = A * ex - B * emx
        return yp / y
    return v


def numerical_derivative(f: Callable[[float], float], x: float,
                         h: float = 1e-6) -> float:
    """Central finite-difference approximation of f'(x)."""
    return (f(x + h) - f(x - h)) / (2.0 * h)


def demo_difference_law() -> None:
    """Verify (v1 - v2)' = -(v1 + v2 + p)(v1 - v2) with p = 0."""
    print("=" * 70)
    print("DEMO 1: Difference law  (v1 - v2)' = -(v1 + v2 + p)(v1 - v2),  p = 0")
    print("=" * 70)
    v1 = riccati_solution(1.0, 0.5)
    v2 = riccati_solution(0.3, 2.0)
    header = "{:>6} | {:>14} | {:>16} | {:>10}".format(
        "x", "(v1-v2)'", "-(v1+v2)(v1-v2)", "abs err")
    print(header)
    for x in (-1.0, -0.3, 0.0, 0.7, 1.5):
        diff = lambda t: v1(t) - v2(t)
        lhs = numerical_derivative(diff, x)
        rhs = -(v1(x) + v2(x)) * (v1(x) - v2(x))
        print(f"{x:6.2f} | {lhs:14.8f} | {rhs:16.8f} | {abs(lhs - rhs):10.2e}")
    print()


def cross_ratio(a: float, b: float, c: float, d: float) -> float:
    """[a, b; c, d] = (a - c)(b - d) / ((a - d)(b - c))."""
    return ((a - c) * (b - d)) / ((a - d) * (b - c))


def demo_cross_ratio_invariance() -> None:
    """Verify the cross-ratio of four Riccati solutions is constant in x."""
    print("=" * 70)
    print("DEMO 2: Cross-ratio of four Riccati solutions is CONSTANT in x")
    print("=" * 70)
    vs = [
        riccati_solution(1.0, 0.0),   # pure e^x
        riccati_solution(0.0, 1.0),   # pure e^{-x}
        riccati_solution(1.0, 1.0),   # cosh
        riccati_solution(2.0, 0.5),   # generic
    ]
    print(f"{'x':>6} | {'cross-ratio [v1,v2;v3,v4]':>28}")
    values: List[float] = []
    for x in (-2.0, -1.0, 0.0, 0.5, 1.0, 2.0, 3.0):
        cr = cross_ratio(vs[0](x), vs[1](x), vs[2](x), vs[3](x))
        values.append(cr)
        print(f"{x:6.2f} | {cr:28.12f}")
    spread = max(values) - min(values)
    print(f"\nMax variation over all x: {spread:.3e}  (constant up to roundoff)")
    print()


# ---------------------------------------------------------------------------
# Part B. The polynomial / Kovacic obstruction.
#
# A rational solution v = p/q of v' + v^2 = f exists iff the polynomial identity
#     p' q - p q' + p^2 = f q^2
# holds.  We implement exact polynomial arithmetic over the rationals/reals and
# check the degree-parity obstruction directly.
# ---------------------------------------------------------------------------

Poly = List[float]  # coefficients low-to-high: [a0, a1, a2, ...]


def p_trim(p: Poly) -> Poly:
    """Drop trailing (high-degree) zero coefficients."""
    q = list(p)
    while len(q) > 1 and abs(q[-1]) < 1e-12:
        q.pop()
    return q


def p_degree(p: Poly) -> int:
    """Degree of a polynomial; the zero polynomial reports -1."""
    q = p_trim(p)
    if len(q) == 1 and abs(q[0]) < 1e-12:
        return -1
    return len(q) - 1


def p_add(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    return p_trim([(a[i] if i < len(a) else 0.0) +
                   (b[i] if i < len(b) else 0.0) for i in range(n)])


def p_sub(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    return p_trim([(a[i] if i < len(a) else 0.0) -
                   (b[i] if i < len(b) else 0.0) for i in range(n)])


def p_mul(a: Poly, b: Poly) -> Poly:
    out = [0.0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return p_trim(out)


def p_deriv(a: Poly) -> Poly:
    if len(a) <= 1:
        return [0.0]
    return p_trim([i * a[i] for i in range(1, len(a))])


def riccati_cleared_lhs(p: Poly, q: Poly) -> Poly:
    """p' q - p q' + p^2."""
    return p_add(p_sub(p_mul(p_deriv(p), q), p_mul(p, p_deriv(q))), p_mul(p, p))


def demo_odd_degree_obstruction() -> None:
    """Show the parity clash that rules out rational Airy Riccati solutions."""
    print("=" * 70)
    print("DEMO 3: Odd-degree (Kovacic) obstruction for Airy  v' + v^2 = x")
    print("=" * 70)
    f_airy: Poly = [0.0, 1.0]  # f = X, degree 1 (odd)
    print(f"Airy coefficient f = X, degree = {p_degree(f_airy)} (ODD)")
    print("Searching candidate rational solutions v = p/q ...\n")
    candidates: List[Tuple[Poly, Poly, str]] = [
        ([1.0], [1.0], "v = 1"),
        ([0.0, 1.0], [1.0], "v = x"),
        ([0.0, 0.0, 1.0], [1.0], "v = x^2"),
        ([1.0], [0.0, 1.0], "v = 1/x"),
        ([1.0, 1.0], [0.0, 1.0], "v = (1+x)/x"),
    ]
    for p, q, label in candidates:
        lhs = riccati_cleared_lhs(p, q)
        rhs = p_mul(f_airy, p_mul(q, q))  # f q^2
        ok = p_degree(p_sub(lhs, rhs)) == -1
        print(f"  {label:14s}: deg(LHS) = {p_degree(lhs):2d}, "
              f"deg(RHS = f q^2) = {p_degree(rhs):2d}  "
              f"-> identity holds? {ok}")
    print("\nParity argument: RHS degree = deg f + 2 deg q is ODD, while the")
    print("dominant LHS term p^2 has EVEN degree -- they can never match.")
    print("Hence Airy's equation y'' = x y has NO elementary (EML) solution.")
    print()


def demo_even_degree_witness() -> None:
    """Show the sharp even-degree witness f = X^2 + 1, solution v = x."""
    print("=" * 70)
    print("DEMO 4: Sharpness witness  f = X^2 + 1  (even degree) IS solvable")
    print("=" * 70)
    f: Poly = [1.0, 0.0, 1.0]  # X^2 + 1, degree 2 (even)
    p: Poly = [0.0, 1.0]       # v = x
    q: Poly = [1.0]            # q = 1
    lhs = riccati_cleared_lhs(p, q)
    rhs = p_mul(f, p_mul(q, q))
    print(f"f = X^2 + 1, degree = {p_degree(f)} (EVEN)")
    print(f"Candidate v = x  ->  p' q - p q' + p^2 = {p_trim(lhs)}")
    print(f"                     f q^2             = {p_trim(rhs)}")
    holds = p_degree(p_sub(lhs, rhs)) == -1
    print(f"Identity holds? {holds}")
    print("Corresponds to y'' = (x^2 + 1) y solved by y = e^{x^2/2},")
    print("whose logarithmic derivative is exactly v = x.")
    print()


def main() -> None:
    demo_difference_law()
    demo_cross_ratio_invariance()
    demo_odd_degree_obstruction()
    demo_even_degree_witness()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
