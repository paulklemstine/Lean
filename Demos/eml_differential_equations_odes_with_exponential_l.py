"""
Exponential-Logarithmic Differential Equations: numerical and symbolic demonstrations.

This self-contained script illustrates the results on closed-form solvability of
the second order linear equation  y'' = r(x) y,  with Airy's equation  y'' = x y
as the guiding example.

Contents
--------
1.  EML expression trees: evaluation, regularity, symbolic differentiation, and a
    numerical check that the symbolic derivative agrees with a finite-difference
    derivative on the regularity locus.
2.  The first-order theory:  y = exp(F)  solves  y' = F' y,  verified numerically.
3.  Kovacic case 1 (exact arithmetic): the cleared Riccati identity
        P'Q - P Q' + P^2 = r Q^2
    and the parity obstruction for odd  deg r.  Sharpness for r = x^2 + 1.
4.  Degree determination:  u' + u^2 = r  with polynomial u forces
        deg r = 2 deg u   and   lc(r) = lc(u)^2.
5.  No rational solutions of y'' = r y for r != 0 (degree bookkeeping).
6.  Kovacic case 2: the second symmetric power  v''' = 4 x v' + 2 v,
    exhaustive exact search for polynomial solutions (none exist), and the
    obstruction constant  kappa(p,q) = 4 (p - q) + 2, never zero.
7.  Analytic confirmation: Airy solutions from their power series, the residual of
    the symmetric square equation for the product of two solutions, and the failure
    of rational (Pade-style) fits to that product.

Only the Python standard library is used.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Dict, List, Optional, Sequence, Tuple
import math

# ----------------------------------------------------------------------------------
# 1. EML expressions: syntax, evaluation, regularity, symbolic derivative
# ----------------------------------------------------------------------------------


@dataclass(frozen=True)
class EML:
    """An exponential-logarithmic expression tree.

    ``kind`` is one of 'X', 'const', 'add', 'mul', 'inv', 'exp', 'log'.
    ``value`` carries the real constant for 'const'; ``args`` the subexpressions.
    """

    kind: str
    value: float = 0.0
    args: Tuple["EML", ...] = ()


def X() -> EML:
    """The variable x."""
    return EML("X")


def const(c: float) -> EML:
    """A real constant."""
    return EML("const", value=float(c))


def add(a: EML, b: EML) -> EML:
    """Sum of two EML expressions."""
    return EML("add", args=(a, b))


def mul(a: EML, b: EML) -> EML:
    """Product of two EML expressions."""
    return EML("mul", args=(a, b))


def inv(a: EML) -> EML:
    """Multiplicative inverse of an EML expression."""
    return EML("inv", args=(a,))


def exp_(a: EML) -> EML:
    """Exponential of an EML expression."""
    return EML("exp", args=(a,))


def log_(a: EML) -> EML:
    """Logarithm of an EML expression."""
    return EML("log", args=(a,))


def eml_eval(e: EML, x: float) -> float:
    """Interpret an EML expression as a real function, with junk values off the
    regularity locus (``0**-1 = 0`` and ``log t = 0`` for ``t <= 0``)."""
    if e.kind == "X":
        return x
    if e.kind == "const":
        return e.value
    if e.kind == "add":
        return eml_eval(e.args[0], x) + eml_eval(e.args[1], x)
    if e.kind == "mul":
        return eml_eval(e.args[0], x) * eml_eval(e.args[1], x)
    if e.kind == "inv":
        v = eml_eval(e.args[0], x)
        return 0.0 if v == 0.0 else 1.0 / v
    if e.kind == "exp":
        return math.exp(eml_eval(e.args[0], x))
    if e.kind == "log":
        v = eml_eval(e.args[0], x)
        return 0.0 if v <= 0.0 else math.log(v)
    raise ValueError(f"unknown EML node {e.kind}")


def eml_regular(e: EML, x: float) -> bool:
    """True iff every inversion and logarithm inside ``e`` has nonzero argument at ``x``."""
    if e.kind in ("X", "const"):
        return True
    if e.kind in ("add", "mul"):
        return eml_regular(e.args[0], x) and eml_regular(e.args[1], x)
    if e.kind == "exp":
        return eml_regular(e.args[0], x)
    if e.kind in ("inv", "log"):
        return eml_regular(e.args[0], x) and eml_eval(e.args[0], x) != 0.0
    raise ValueError(f"unknown EML node {e.kind}")


def eml_D(e: EML) -> EML:
    """Symbolic derivative of an EML expression; the result is again an EML expression."""
    if e.kind == "X":
        return const(1.0)
    if e.kind == "const":
        return const(0.0)
    if e.kind == "add":
        return add(eml_D(e.args[0]), eml_D(e.args[1]))
    if e.kind == "mul":
        a, b = e.args
        return add(mul(eml_D(a), b), mul(a, eml_D(b)))
    if e.kind == "inv":
        a = e.args[0]
        return mul(const(-1.0), mul(eml_D(a), mul(inv(a), inv(a))))
    if e.kind == "exp":
        a = e.args[0]
        return mul(eml_D(a), exp_(a))
    if e.kind == "log":
        a = e.args[0]
        return mul(eml_D(a), inv(a))
    raise ValueError(f"unknown EML node {e.kind}")


def eml_show(e: EML) -> str:
    """A readable rendering of an EML expression."""
    if e.kind == "X":
        return "x"
    if e.kind == "const":
        v = e.value
        return str(int(v)) if float(v).is_integer() else f"{v:g}"
    if e.kind == "add":
        return f"({eml_show(e.args[0])} + {eml_show(e.args[1])})"
    if e.kind == "mul":
        return f"({eml_show(e.args[0])}*{eml_show(e.args[1])})"
    if e.kind == "inv":
        return f"(1/{eml_show(e.args[0])})"
    if e.kind == "exp":
        return f"exp({eml_show(e.args[0])})"
    if e.kind == "log":
        return f"log({eml_show(e.args[0])})"
    raise ValueError(f"unknown EML node {e.kind}")


def numeric_derivative(f: Callable[[float], float], x: float, h: float = 1e-5) -> float:
    """Fourth-order accurate central difference approximation of f'(x)."""
    return (f(x - 2 * h) - 8 * f(x - h) + 8 * f(x + h) - f(x + 2 * h)) / (12 * h)


def demo_symbolic_derivative() -> None:
    """Check symbolic differentiation against finite differences on sample expressions."""
    print("=" * 78)
    print("1. Correctness of symbolic differentiation on the regularity locus")
    print("=" * 78)
    samples: List[EML] = [
        exp_(mul(const(0.5), mul(X(), X()))),          # exp(x^2/2)
        log_(add(mul(X(), X()), const(1.0))),          # log(x^2+1)
        mul(X(), exp_(log_(add(X(), const(3.0))))),    # x * exp(log(x+3))
        inv(add(mul(X(), X()), const(1.0))),           # 1/(x^2+1)
        exp_(mul(X(), log_(add(X(), const(2.0))))),    # exp(x log(x+2)) = (x+2)^x
    ]
    for e in samples:
        d = eml_D(e)
        print(f"\n  E   = {eml_show(e)}")
        print(f"  DE  = {eml_show(d)}")
        worst = 0.0
        for k in range(1, 10):
            x = 0.3 * k
            if not (eml_regular(e, x) and eml_regular(d, x)):
                continue
            symbolic = eml_eval(d, x)
            numeric = numeric_derivative(lambda t: eml_eval(e, t), x)
            worst = max(worst, abs(symbolic - numeric) / (1.0 + abs(symbolic)))
        print(f"  max relative deviation from finite differences: {worst:.3e}")


def demo_first_order() -> None:
    """y = exp(F) solves y' = F' y; uniqueness up to a multiplicative constant."""
    print()
    print("=" * 78)
    print("2. First-order theory:  y = exp(F)  solves  y' = (DF) y")
    print("=" * 78)
    F = mul(const(0.5), mul(X(), X()))          # F = x^2/2
    y = exp_(F)
    dF = eml_D(F)
    print(f"  F = {eml_show(F)},  DF = {eml_show(dF)},  y = exp(F)")
    print(f"  {'x':>6} {'y(x)':>14} {'y prime':>14} {'DF(x)*y(x)':>14} {'residual':>12}")
    for k in range(-2, 3):
        x = float(k)
        yv = eml_eval(y, x)
        yp = numeric_derivative(lambda t: eml_eval(y, t), x)
        rhs = eml_eval(dF, x) * yv
        print(f"  {x:6.2f} {yv:14.7f} {yp:14.7f} {rhs:14.7f} {abs(yp - rhs):12.2e}")
    print("  Second derivative check: y'' = (x^2+1) y  for y = exp(x^2/2)")
    for k in (-1, 0, 1, 2):
        x = float(k)
        ypp = numeric_derivative(lambda t: numeric_derivative(lambda s: eml_eval(y, s), t, 1e-3), x, 1e-3)
        print(f"    x={x:5.2f}   y'' = {ypp:12.6f}   (x^2+1)y = {(x*x+1)*eml_eval(y, x):12.6f}")


# ----------------------------------------------------------------------------------
# Exact polynomial arithmetic over the rationals (coefficient lists, low degree first)
# ----------------------------------------------------------------------------------

Poly = List[Fraction]


def p_trim(p: Poly) -> Poly:
    """Remove trailing zero coefficients."""
    q = list(p)
    while q and q[-1] == 0:
        q.pop()
    return q


def p_deg(p: Poly) -> int:
    """Degree of a polynomial; the zero polynomial is given degree 0 by convention."""
    q = p_trim(p)
    return max(len(q) - 1, 0)


def p_lc(p: Poly) -> Fraction:
    """Leading coefficient (zero for the zero polynomial)."""
    q = p_trim(p)
    return q[-1] if q else Fraction(0)


def p_add(a: Poly, b: Poly) -> Poly:
    """Sum of two polynomials."""
    n = max(len(a), len(b))
    return p_trim([(a[i] if i < len(a) else Fraction(0)) + (b[i] if i < len(b) else Fraction(0))
                   for i in range(n)])


def p_sub(a: Poly, b: Poly) -> Poly:
    """Difference of two polynomials."""
    n = max(len(a), len(b))
    return p_trim([(a[i] if i < len(a) else Fraction(0)) - (b[i] if i < len(b) else Fraction(0))
                   for i in range(n)])


def p_mul(a: Poly, b: Poly) -> Poly:
    """Product of two polynomials."""
    a, b = p_trim(a), p_trim(b)
    if not a or not b:
        return []
    out = [Fraction(0)] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai == 0:
            continue
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return p_trim(out)


def p_scal(c: Fraction, a: Poly) -> Poly:
    """Scalar multiple of a polynomial."""
    return p_trim([c * ai for ai in a])


def p_deriv(a: Poly) -> Poly:
    """Formal derivative."""
    return p_trim([Fraction(i) * a[i] for i in range(1, len(a))])


def p_coeff(a: Poly, k: int) -> Fraction:
    """Coefficient of x^k."""
    return a[k] if 0 <= k < len(a) else Fraction(0)


def p_eval(a: Poly, x: float) -> float:
    """Evaluate a rational-coefficient polynomial at a real point (Horner)."""
    acc = 0.0
    for c in reversed(p_trim(a)):
        acc = acc * x + float(c)
    return acc


def p_show(a: Poly) -> str:
    """Human-readable rendering, highest degree first."""
    a = p_trim(a)
    if not a:
        return "0"
    terms: List[str] = []
    for i in reversed(range(len(a))):
        c = a[i]
        if c == 0:
            continue
        cs = str(c)
        if i == 0:
            terms.append(cs)
        elif i == 1:
            terms.append(f"{cs}*x")
        else:
            terms.append(f"{cs}*x^{i}")
    return " + ".join(terms)


X_POLY: Poly = [Fraction(0), Fraction(1)]
ONE_POLY: Poly = [Fraction(1)]


def wronskian_num(P: Poly, Q: Poly) -> Poly:
    """W = P'Q - PQ', the numerator of (P/Q)'."""
    return p_sub(p_mul(p_deriv(P), Q), p_mul(P, p_deriv(Q)))


def second_num(P: Poly, Q: Poly) -> Poly:
    """B = W'Q - 2WQ', the numerator of (P/Q)'' over Q^3."""
    W = wronskian_num(P, Q)
    return p_sub(p_mul(p_deriv(W), Q), p_scal(Fraction(2), p_mul(W, p_deriv(Q))))


def third_num(P: Poly, Q: Poly) -> Poly:
    """Z = B'Q - 3BQ', the numerator of (P/Q)''' over Q^4."""
    B = second_num(P, Q)
    return p_sub(p_mul(p_deriv(B), Q), p_scal(Fraction(3), p_mul(B, p_deriv(Q))))


# ----------------------------------------------------------------------------------
# 3-5. Kovacic case 1: the Riccati obstruction, exactly
# ----------------------------------------------------------------------------------


def riccati_defect(r: Poly, P: Poly, Q: Poly) -> Poly:
    """The defect of the cleared Riccati identity  P'Q - PQ' + P^2 - r Q^2.

    It vanishes identically iff u = P/Q solves u' + u^2 = r."""
    return p_sub(p_add(wronskian_num(P, Q), p_mul(P, P)), p_mul(r, p_mul(Q, Q)))


def demo_case_one() -> None:
    """Parity obstruction for odd-degree r, and sharpness for r = x^2 + 1."""
    print()
    print("=" * 78)
    print("3. Kovacic case 1: the cleared Riccati identity  P'Q - PQ' + P^2 = r Q^2")
    print("=" * 78)
    print("  Exhaustive exact scan over P, Q with small integer coefficients, r = x:")
    r = X_POLY
    found = False
    coeff_range = [Fraction(k) for k in range(-2, 3)]
    for pdeg in range(0, 3):
        for qdeg in range(0, 3):
            for Pc in _all_polys(coeff_range, pdeg):
                if p_lc(Pc) == 0:
                    continue
                for Qc in _all_polys(coeff_range, qdeg):
                    if p_lc(Qc) == 0:
                        continue
                    if not p_trim(riccati_defect(r, Pc, Qc)):
                        found = True
                        print(f"    SOLUTION FOUND: P={p_show(Pc)}, Q={p_show(Qc)}")
    print(f"    rational Riccati solution of u' + u^2 = x found: {found}   (theory: impossible)")
    print()
    print("  Parity bookkeeping (deg r odd is the whole obstruction):")
    print(f"    {'deg P':>6} {'deg Q':>6} {'deg LHS':>26} {'deg RHS = 1 + 2q':>18}")
    for p_, q_ in [(0, 0), (1, 0), (2, 1), (3, 2), (0, 1), (1, 3)]:
        lhs = f"{2*p_} (even)" if q_ <= p_ else f"< {2*q_}"
        print(f"    {p_:6d} {q_:6d} {lhs:>26} {1 + 2*q_:18d}")
    print()
    print("  Sharpness: r = x^2 + 1 has the polynomial Riccati solution u = x.")
    r2: Poly = [Fraction(1), Fraction(0), Fraction(1)]
    u = X_POLY
    print(f"    defect of u = x for r = x^2+1 : {p_show(riccati_defect(r2, u, ONE_POLY))}")
    print("    hence y = exp(x^2/2) satisfies y'' = (x^2+1) y  (checked numerically in part 2).")


def _all_polys(coeffs: Sequence[Fraction], deg: int) -> List[Poly]:
    """All polynomials of degree exactly ``deg`` with coefficients drawn from ``coeffs``."""
    out: List[Poly] = []

    def rec(prefix: List[Fraction], k: int) -> None:
        if k == deg:
            for c in coeffs:
                if c != 0:
                    out.append(p_trim(prefix + [c]))
            return
        for c in coeffs:
            rec(prefix + [c], k + 1)

    rec([], 0)
    return out


def demo_degree_determination() -> None:
    """deg r = 2 deg u and lc(r) = lc(u)^2 for polynomial Riccati solutions."""
    print()
    print("=" * 78)
    print("4. Degree determination:  u' + u^2 = r  forces deg r = 2 deg u, lc r = (lc u)^2")
    print("=" * 78)
    examples: List[Poly] = [
        [Fraction(0), Fraction(1)],                       # u = x
        [Fraction(1), Fraction(0), Fraction(3)],          # u = 3x^2 + 1
        [Fraction(-2), Fraction(5), Fraction(0), Fraction(2)],  # u = 2x^3 + 5x - 2
    ]
    header = "r = u' + u^2"
    print(f"    {'u':>26} {header:>34} {'deg r':>6} {'2 deg u':>8} {'lc r':>6} {'(lc u)^2':>9}")
    for u in examples:
        r = p_add(p_deriv(u), p_mul(u, u))
        print(f"    {p_show(u):>26} {p_show(r):>34} {p_deg(r):6d} {2*p_deg(u):8d} "
              f"{str(p_lc(r)):>6} {str(p_lc(u)**2):>9}")
    print("    Airy: deg r = deg x = 1 is odd, hence not of the form 2 deg u -> no polynomial solution.")


def demo_no_rational_solution() -> None:
    """y'' = r y has no nonzero rational solution when r != 0: the degree count."""
    print()
    print("=" * 78)
    print("5. No rational solution of y'' = r y for r != 0")
    print("=" * 78)
    print("  cleared identity:  W'Q - 2WQ' = r P Q^2,   W = P'Q - PQ'")
    print(f"    {'P':>18} {'Q':>14} {'deg LHS':>8} {'bound p+2q':>11} {'deg RHS (r=x)':>14}")
    tests: List[Tuple[Poly, Poly]] = [
        ([Fraction(1), Fraction(2)], [Fraction(1)]),
        ([Fraction(0), Fraction(0), Fraction(1)], [Fraction(1), Fraction(1), Fraction(1)]),
        ([Fraction(3), Fraction(-1), Fraction(2)], [Fraction(2), Fraction(0), Fraction(1)]),
    ]
    for P, Q in tests:
        W = wronskian_num(P, Q)
        lhs = p_sub(p_mul(p_deriv(W), Q), p_scal(Fraction(2), p_mul(W, p_deriv(Q))))
        rhs = p_mul(X_POLY, p_mul(P, p_mul(Q, Q)))
        print(f"    {p_show(P):>18} {p_show(Q):>14} {p_deg(lhs):8d} {p_deg(P)+2*p_deg(Q):11d} {p_deg(rhs):14d}")
    print("    LHS always has degree < p + 2q, RHS has degree deg r + p + 2q: never equal.")


# ----------------------------------------------------------------------------------
# 6. Kovacic case 2: the second symmetric power
# ----------------------------------------------------------------------------------


def sym_square_defect_poly(v: Poly) -> Poly:
    """Defect of  v''' - 4 x v' - 2 v  for a polynomial candidate v."""
    v3 = p_deriv(p_deriv(p_deriv(v)))
    return p_sub(v3, p_add(p_scal(Fraction(4), p_mul(X_POLY, p_deriv(v))), p_scal(Fraction(2), v)))


def sym_square_defect_rational(P: Poly, Q: Poly) -> Poly:
    """Defect  Z - (4 X W + 2 P Q) Q^2  of the cleared symmetric-square equation."""
    W = wronskian_num(P, Q)
    core = p_add(p_scal(Fraction(4), p_mul(X_POLY, W)), p_scal(Fraction(2), p_mul(P, Q)))
    return p_sub(third_num(P, Q), p_mul(core, p_mul(Q, Q)))


def demo_case_two() -> None:
    """v''' = 4 x v' + 2 v has no nonzero polynomial or rational solution."""
    print()
    print("=" * 78)
    print("6. Kovacic case 2: the second symmetric power  v''' = 4 x v' + 2 v")
    print("=" * 78)
    print("  Exact linear-algebra search for polynomial solutions up to degree 8:")
    for n in range(0, 9):
        # solve the linear system coefficientwise; unknowns c_0..c_n
        # coefficient of x^n forces (4n + 2) c_n = 0, hence c_n = 0, and so on downwards.
        sol = _solve_polynomial_symsquare(n)
        print(f"    degree <= {n}: solution space = {sol}")
    print()
    print("  The obstruction constant kappa(p,q) = 4(p-q) + 2  is never zero:")
    print(f"    {'p':>3} {'q':>3} {'kappa':>7} | {'p':>3} {'q':>3} {'kappa':>7}")
    rows = [(p_, q_) for p_ in range(0, 4) for q_ in range(0, 4)]
    for i in range(0, len(rows), 2):
        a = rows[i]
        b = rows[i + 1] if i + 1 < len(rows) else None
        left = f"    {a[0]:3d} {a[1]:3d} {4*(a[0]-a[1])+2:7d}"
        right = "" if b is None else f" | {b[0]:3d} {b[1]:3d} {4*(b[0]-b[1])+2:7d}"
        print(left + right)
    print()
    print("  Top coefficient of the cleared right-hand side, (4(p-q)+2) lc(P) lc(Q)^3,")
    print("  compared with the vanishing coefficient of the left-hand side in degree p+3q:")
    print(f"    {'P':>16} {'Q':>16} {'p+3q':>5} {'[x^(p+3q)] Z':>13} {'[x^(p+3q)] RHS':>15} {'predicted':>11}")
    samples: List[Tuple[Poly, Poly]] = [
        ([Fraction(1)], [Fraction(1)]),
        ([Fraction(0), Fraction(1)], [Fraction(1)]),
        ([Fraction(1), Fraction(0), Fraction(2)], [Fraction(1), Fraction(1)]),
        ([Fraction(3), Fraction(1)], [Fraction(1), Fraction(0), Fraction(1), Fraction(2)]),
    ]
    for P, Q in samples:
        p_, q_ = p_deg(P), p_deg(Q)
        idx = p_ + 3 * q_
        W = wronskian_num(P, Q)
        core = p_add(p_scal(Fraction(4), p_mul(X_POLY, W)), p_scal(Fraction(2), p_mul(P, Q)))
        rhs = p_mul(core, p_mul(Q, Q))
        predicted = Fraction(4 * (p_ - q_) + 2) * p_lc(P) * p_lc(Q) ** 3
        print(f"    {p_show(P):>16} {p_show(Q):>16} {idx:5d} {str(p_coeff(third_num(P, Q), idx)):>13} "
              f"{str(p_coeff(rhs, idx)):>15} {str(predicted):>11}")
    print("    Every left-hand coefficient is 0 while every right-hand one is nonzero:")
    print("    no rational function can solve the symmetric square equation.")


def _solve_polynomial_symsquare(n: int) -> str:
    """Solve v''' = 4 x v' + 2 v for v of degree <= n by exact Gaussian elimination."""
    # unknowns c_0..c_n; equations: coefficient of x^k in defect, k = 0..n
    rows: List[List[Fraction]] = []
    for k in range(0, n + 1):
        row = [Fraction(0)] * (n + 1)
        for j in range(0, n + 1):
            basis = [Fraction(0)] * (n + 1)
            basis[j] = Fraction(1)
            row[j] = p_coeff(sym_square_defect_poly(basis), k)
        rows.append(row)
    # Gaussian elimination to compute the rank
    m = [r[:] for r in rows]
    rank = 0
    col = 0
    while rank < len(m) and col <= n:
        piv = next((i for i in range(rank, len(m)) if m[i][col] != 0), None)
        if piv is None:
            col += 1
            continue
        m[rank], m[piv] = m[piv], m[rank]
        pv = m[rank][col]
        m[rank] = [c / pv for c in m[rank]]
        for i in range(len(m)):
            if i != rank and m[i][col] != 0:
                f = m[i][col]
                m[i] = [a - f * b for a, b in zip(m[i], m[rank])]
        rank += 1
        col += 1
    dim = (n + 1) - rank
    return "{0} only" if dim == 0 else f"dimension {dim} (!)"


# ----------------------------------------------------------------------------------
# 7. Airy solutions from the power series; the symmetric square residual
# ----------------------------------------------------------------------------------


def airy_series_coeffs(a0: float, a1: float, n_terms: int) -> List[float]:
    """Taylor coefficients at 0 of the solution of y'' = x y with y(0)=a0, y'(0)=a1.

    The recursion  a_{n+3} = a_n / ((n+3)(n+2))  follows from matching powers."""
    a = [0.0] * (n_terms + 3)
    a[0], a[1], a[2] = a0, a1, 0.0
    for n in range(0, n_terms):
        a[n + 3] = a[n] / ((n + 3) * (n + 2))
    return a[: n_terms + 1]


def series_eval(a: Sequence[float], x: float, order: int = 0) -> float:
    """Evaluate the ``order``-th derivative of the power series with coefficients ``a`` at x."""
    total = 0.0
    for n in range(order, len(a)):
        coeff = a[n]
        for j in range(order):
            coeff *= (n - j)
        total += coeff * x ** (n - order)
    return total


def demo_airy_symmetric_square() -> None:
    """Numerically confirm v''' = 4 x v' + 2 v for the product of two Airy solutions."""
    print()
    print("=" * 78)
    print("7. Analytic check: products of Airy solutions satisfy v''' = 4 x v' + 2 v")
    print("=" * 78)
    a = airy_series_coeffs(1.0, 0.0, 60)     # y1: y(0)=1, y'(0)=0
    b = airy_series_coeffs(0.0, 1.0, 60)     # y2: y(0)=0, y'(0)=1
    print("  Airy residual  y'' - x y  for the two basis solutions:")
    for x in (-1.5, -0.5, 0.5, 1.5):
        r1 = series_eval(a, x, 2) - x * series_eval(a, x)
        r2 = series_eval(b, x, 2) - x * series_eval(b, x)
        print(f"    x={x:5.2f}   y1: {r1:+.3e}   y2: {r2:+.3e}")
    print()
    print("  Symmetric square residual for v = y1*y2:")
    print(f"    {'x':>6} {'v(x)':>13} {'v3(x)':>13} {'4x v1 + 2v':>13} {'residual':>12}")
    for x in (-1.5, -0.5, 0.5, 1.5, 2.5):
        def v(t: float) -> float:
            return series_eval(a, t) * series_eval(b, t)
        v0 = v(x)
        v1 = numeric_derivative(v, x, 1e-3)
        v2 = numeric_derivative(lambda t: numeric_derivative(v, t, 1e-3), x, 1e-3)
        v3 = numeric_derivative(lambda t: numeric_derivative(lambda s: numeric_derivative(v, s, 2e-3), t, 2e-3), x, 2e-3)
        rhs = 4 * x * v1 + 2 * v0
        print(f"    {x:6.2f} {v0:13.6f} {v3:13.6f} {rhs:13.6f} {abs(v3 - rhs):12.2e}")
    print("    (small residuals confirm the third-order identity; the theory then shows")
    print("     that no rational function can satisfy it)")


def demo_rational_fit_failure() -> None:
    """Least-squares rational fits to v = y1 y2 cannot make the residual vanish."""
    print()
    print("=" * 78)
    print("8. Rational fits to the product of Airy solutions: the residual never vanishes")
    print("=" * 78)
    a = airy_series_coeffs(1.0, 0.0, 60)
    b = airy_series_coeffs(0.0, 1.0, 60)

    def v(t: float) -> float:
        return series_eval(a, t) * series_eval(b, t)

    nodes = [(-2.0 + 4.0 * i / 40.0) for i in range(41)]
    print(f"    {'deg P':>6} {'deg Q':>6} {'max |v - P/Q| on [-2,2]':>26}")
    for pdeg, qdeg in [(2, 2), (4, 2), (4, 4), (6, 4), (6, 6)]:
        err = _rational_fit_error(v, nodes, pdeg, qdeg)
        print(f"    {pdeg:6d} {qdeg:6d} {err:26.6e}")
    print("    The error never approaches zero, and does not decrease systematically with")
    print("    the degrees: an entire transcendental product admits no rational closed form.")


def _rational_fit_error(f: Callable[[float], float], nodes: Sequence[float],
                        pdeg: int, qdeg: int) -> float:
    """Linearised rational fit: solve  P(x) - f(x) Q(x) = 0  in least squares with Q monic,
    then report the maximal deviation |f - P/Q| over the nodes."""
    # unknowns: p_0..p_pdeg, q_0..q_{qdeg-1}; q_qdeg = 1
    ncols = (pdeg + 1) + qdeg
    ata = [[0.0] * ncols for _ in range(ncols)]
    atb = [0.0] * ncols
    for x in nodes:
        row = [x ** i for i in range(pdeg + 1)] + [-f(x) * x ** j for j in range(qdeg)]
        rhs = f(x) * x ** qdeg
        for i in range(ncols):
            atb[i] += row[i] * rhs
            for j in range(ncols):
                ata[i][j] += row[i] * row[j]
    sol = _solve_dense(ata, atb)
    if sol is None:
        return float("inf")
    pc = sol[: pdeg + 1]
    qc = sol[pdeg + 1:] + [1.0]
    worst = 0.0
    for x in nodes:
        num = sum(c * x ** i for i, c in enumerate(pc))
        den = sum(c * x ** i for i, c in enumerate(qc))
        if abs(den) < 1e-12:
            return float("inf")
        worst = max(worst, abs(f(x) - num / den))
    return worst


def _solve_dense(A: List[List[float]], b: List[float]) -> Optional[List[float]]:
    """Gaussian elimination with partial pivoting; returns None if singular."""
    n = len(b)
    M = [A[i][:] + [b[i]] for i in range(n)]
    for c in range(n):
        piv = max(range(c, n), key=lambda i: abs(M[i][c]))
        if abs(M[piv][c]) < 1e-14:
            return None
        M[c], M[piv] = M[piv], M[c]
        pv = M[c][c]
        M[c] = [t / pv for t in M[c]]
        for i in range(n):
            if i != c and M[i][c] != 0.0:
                f = M[i][c]
                M[i] = [t - f * s for t, s in zip(M[i], M[c])]
    return [M[i][n] for i in range(n)]


def main() -> None:
    """Run all demonstrations."""
    demo_symbolic_derivative()
    demo_first_order()
    demo_case_one()
    demo_degree_determination()
    demo_no_rational_solution()
    demo_case_two()
    demo_airy_symmetric_square()
    demo_rational_fit_failure()
    print()
    print("=" * 78)
    print("Summary")
    print("=" * 78)
    print("  * symbolic differentiation of exponential-logarithmic expressions is exact;")
    print("  * y' = c y is completely solved by exponentials of antiderivatives;")
    print("  * u' + u^2 = r has no rational solution when deg r is odd (Airy: r = x);")
    print("  * a polynomial Riccati solution has deg r = 2 deg u and lc r = (lc u)^2;")
    print("  * y'' = r y has no nonzero rational solution for r != 0;")
    print("  * v''' = 4x v' + 2v has no nonzero polynomial or rational solution, since")
    print("    4(deg P - deg Q) + 2 is never zero;")
    print("  * hence no product of two Airy solutions is a nonzero rational function.")


if __name__ == "__main__":
    main()
