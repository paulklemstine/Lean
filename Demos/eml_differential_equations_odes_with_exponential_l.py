"""Numerical demonstrations for the nonexistence of polynomial solutions to
Airy's equation y'' = x*y and its Riccati form u' + u^2 = x.

The two theorems established are:

    Theorem A (linear form).   The only polynomial p with p'' = x*p is p = 0.
    Theorem B (Riccati form).  No polynomial u satisfies u' + u^2 = x.

This script represents polynomials by their coefficient lists and implements
the formal derivative, multiplication by x, and degree, so that the
degree-counting arguments behind both theorems can be exhibited explicitly and
checked on concrete examples. Everything is self-contained: no third-party
libraries are required.
"""

from __future__ import annotations

from typing import List

# A polynomial is represented as a list of real coefficients in ascending
# order of degree:  [a0, a1, a2, ...]  denotes  a0 + a1*x + a2*x^2 + ...


def trim(p: List[float]) -> List[float]:
    """Remove trailing (high-degree) zero coefficients; [] denotes the zero poly."""
    q = list(p)
    while q and abs(q[-1]) < 1e-12:
        q.pop()
    return q


def degree(p: List[float]) -> int:
    """Degree of a polynomial; the zero polynomial is given degree -1."""
    q = trim(p)
    return len(q) - 1


def derivative(p: List[float]) -> List[float]:
    """Formal derivative:  d/dx sum a_k x^k = sum k a_k x^{k-1}."""
    q = trim(p)
    if len(q) <= 1:
        return []
    return trim([k * q[k] for k in range(1, len(q))])


def mul_by_x(p: List[float]) -> List[float]:
    """Multiply a polynomial by x: shift all coefficients up by one degree."""
    q = trim(p)
    if not q:
        return []
    return [0.0] + q


def add(p: List[float], q: List[float]) -> List[float]:
    """Add two polynomials."""
    n = max(len(p), len(q))
    pe = p + [0.0] * (n - len(p))
    qe = q + [0.0] * (n - len(q))
    return trim([pe[i] + qe[i] for i in range(n)])


def mul(p: List[float], q: List[float]) -> List[float]:
    """Multiply two polynomials (convolution of coefficient lists)."""
    p, q = trim(p), trim(q)
    if not p or not q:
        return []
    out = [0.0] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            out[i + j] += a * b
    return trim(out)


def square(p: List[float]) -> List[float]:
    """Square a polynomial."""
    return mul(p, p)


def fmt(p: List[float]) -> str:
    """Pretty-print a polynomial."""
    q = trim(p)
    if not q:
        return "0"
    terms = []
    for k, a in enumerate(q):
        if abs(a) < 1e-12:
            continue
        if k == 0:
            terms.append(f"{a:g}")
        elif k == 1:
            terms.append(f"{a:g}*x")
        else:
            terms.append(f"{a:g}*x^{k}")
    return " + ".join(terms) if terms else "0"


# --------------------------------------------------------------------------
# Demonstration 1: the degree gap in the linear form p'' = x*p.
# --------------------------------------------------------------------------

def airy_linear_residual(p: List[float]) -> List[float]:
    """Return p'' - x*p; this is zero exactly when p solves Airy's equation."""
    return add(derivative(derivative(p)), [-c for c in mul_by_x(p)])


def demo_linear_degree_gap() -> None:
    print("=" * 70)
    print("Demonstration 1: linear form  p'' = x*p")
    print("=" * 70)
    print("For any nonzero p of degree n:")
    print("   deg(x*p)  = n + 1   (multiplication by x raises degree by 1)")
    print("   deg(p'')  <= n - 2  (each derivative lowers degree by >= 1)")
    print("These can never be equal, so no nonzero polynomial can solve it.\n")

    test_polys = {
        "1 (constant)":      [1.0],
        "x":                 [0.0, 1.0],
        "x^2":               [0.0, 0.0, 1.0],
        "3x^4 - x + 7":      [7.0, -1.0, 0.0, 0.0, 3.0],
        "x^5 + 2x^2":        [0.0, 0.0, 2.0, 0.0, 0.0, 1.0],
    }
    for name, p in test_polys.items():
        n = degree(p)
        d_rhs = degree(mul_by_x(p))
        d_lhs = degree(derivative(derivative(p)))
        res = airy_linear_residual(p)
        print(f"  p = {name}")
        print(f"     deg p = {n},  deg(x*p) = {d_rhs},  deg(p'') = {d_lhs}")
        print(f"     residual p'' - x*p = {fmt(res)}  (nonzero -> not a solution)")
    print("\n  Only p = 0 gives zero residual:")
    print(f"     residual for p = 0 is {fmt(airy_linear_residual([]))}\n")


# --------------------------------------------------------------------------
# Demonstration 2: the Riccati form u' + u^2 = x.
# --------------------------------------------------------------------------

def riccati_residual(u: List[float]) -> List[float]:
    """Return u' + u^2 - x; zero exactly when u solves the Riccati equation."""
    return add(add(derivative(u), square(u)), [0.0, -1.0])


def demo_riccati() -> None:
    print("=" * 70)
    print("Demonstration 2: Riccati form  u' + u^2 = x")
    print("=" * 70)
    print("Let d = deg(u).")
    print("   deg(u^2) = 2d,   deg(u') <= d - 1,   deg(x) = 1.")
    print("   d = 0 : LHS has degree <= 0, but x has degree 1.")
    print("   d >= 1: u^2 dominates, LHS has degree 2d >= 2 != 1.")
    print("So no polynomial u can solve it -- not even u = 0.\n")

    test_polys = {
        "0":             [],
        "1":             [1.0],
        "x":             [0.0, 1.0],
        "x - 1":         [-1.0, 1.0],
        "x^2":           [0.0, 0.0, 1.0],
    }
    for name, u in test_polys.items():
        d = degree(u)
        d_sq = degree(square(u))
        d_du = degree(derivative(u))
        res = riccati_residual(u)
        print(f"  u = {name}")
        print(f"     deg u = {d},  deg(u^2) = {d_sq},  deg(u') = {d_du}")
        print(f"     residual u' + u^2 - x = {fmt(res)}  (never zero)")
    print()


# --------------------------------------------------------------------------
# Demonstration 3: the generalized linear form p'' = q*p.
# --------------------------------------------------------------------------

def demo_general_coefficient() -> None:
    print("=" * 70)
    print("Demonstration 3: generalized form  p'' = q*p,  deg q >= 1")
    print("=" * 70)
    print("Same degree gap: deg(q*p) = deg q + n >= n + 1 > n - 2 >= deg(p'').")
    print("So p'' = q*p has only the zero polynomial solution for any such q.\n")

    q_list = {
        "q = x":          [0.0, 1.0],
        "q = x^2 + 1":    [1.0, 0.0, 1.0],
        "q = 2x^3":       [0.0, 0.0, 0.0, 2.0],
    }
    p = [7.0, -1.0, 0.0, 0.0, 3.0]  # 3x^4 - x + 7
    for name, q in q_list.items():
        lhs = derivative(derivative(p))
        rhs = mul(q, p)
        residual = add(lhs, [-c for c in rhs])
        print(f"  {name},  p = 3x^4 - x + 7")
        print(f"     deg(q*p) = {degree(rhs)},  deg(p'') = {degree(lhs)}")
        print(f"     residual p'' - q*p = {fmt(residual)}  (nonzero)\n")


# --------------------------------------------------------------------------
# Demonstration 4: contrast with the convergent power-series solution.
# --------------------------------------------------------------------------

def airy_series_coeffs(num_terms: int) -> List[float]:
    """Coefficients a_k of a power-series solution of y'' = x*y with a_0 = 1,
    a_1 = 0, obtained from the recurrence (k+2)(k+1) a_{k+2} = a_{k-1}.

    This shows the solution exists as an *infinite* series with infinitely many
    nonzero coefficients -- precisely why it is not a polynomial.
    """
    a = [0.0] * num_terms
    if num_terms > 0:
        a[0] = 1.0
    if num_terms > 1:
        a[1] = 0.0
    for k in range(num_terms - 2):
        prev = a[k - 1] if k - 1 >= 0 else 0.0
        a[k + 2] = prev / ((k + 2) * (k + 1))
    return a


def demo_power_series() -> None:
    print("=" * 70)
    print("Demonstration 4: the genuine (non-polynomial) series solution")
    print("=" * 70)
    print("Airy's equation DOES have a power-series solution, but it has")
    print("infinitely many nonzero coefficients -- it is not a polynomial.\n")
    coeffs = airy_series_coeffs(13)
    nonzero = [(k, c) for k, c in enumerate(coeffs) if abs(c) > 1e-12]
    print("  Nonzero coefficients a_k (a_0 = 1, a_1 = 0):")
    for k, c in nonzero:
        print(f"     a_{k:<2} = {c:.10f}")
    print("\n  The pattern a_{3m} = 1 / [ (2)(3)(5)(6)...(3m-1)(3m) ] continues")
    print("  forever: there is no highest degree, hence no polynomial.\n")


def main() -> None:
    demo_linear_degree_gap()
    demo_riccati()
    demo_general_coefficient()
    demo_power_series()
    print("=" * 70)
    print("Summary: degree counting forbids polynomial solutions of both the")
    print("linear and Riccati forms of Airy's equation; the true solution is")
    print("an irreducibly infinite power series.")
    print("=" * 70)


if __name__ == "__main__":
    main()
