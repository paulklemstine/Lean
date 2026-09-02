"""
Asymptotic comparison beyond coefficient extensionality
=======================================================

Numerical demonstrations of the germ interpretation of the integer rank scale
m_r(x) = x^r at +infinity.

The results demonstrated here:

  1.  RANK COMPARISON.  r < s  =>  x^r = o(x^s).
  2.  TAIL BOUND.  For |a_n| <= M rho^n and t = 1/x with rho*t < 1,
          | sum_n a_n t^n - sum_{n<k} a_n t^n |  <=  M (rho t)^k / (1 - rho t).
  3.  SIGN CONTROL.  If a_n = 0 for n < n0 and a_{n0} != 0, then the interpreted
      germ has the sign of a_{n0} for every x > (M + |a_{n0}|) / |a_{n0}|, and
      that threshold is sharp.
  4.  REALIZATION.  The interpreted germ has the series as its classical
      asymptotic expansion (recovered numerically by Richardson-style peeling).
  5.  LEXICOGRAPHIC ORDER EMBEDDING.  Eventual domination of germs is exactly the
      lexicographic order on coefficient sequences; no oscillation occurs.
  6.  THE FLAT KERNEL.  e^{-x} has every expansion coefficient equal to zero, so
      it is indistinguishable from 0 by expansion data alone; the fibres of the
      expansion map are cosets of the flat germs.
  7.  MULTIPLICATIVITY AND CLOSURE.  The germ of a Cauchy product is the product
      of the germs; the bounded fragment is not closed under the Cauchy product
      (squaring the all-ones series gives coefficients n+1); the geometric
      fragment is closed, with a rate inflation that is arbitrarily small but
      not removable.

Pure standard library.  Run:  python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core objects
# ----------------------------------------------------------------------------


def rank_ratio(r: int, s: int, x: float) -> float:
    """Ratio x^r / x^s of two rank monomials; tends to 0 when r < s."""
    return float(x) ** (r - s)


def eval_series_t(coeffs: Sequence[float], t: float, terms: int) -> float:
    """Partial sum sum_{n<terms} a_n t^n, evaluated by Horner's rule."""
    total = 0.0
    for n in range(terms - 1, -1, -1):
        total = total * t + (coeffs[n] if n < len(coeffs) else 0.0)
    return total


def eval_germ(coeffs: Sequence[float], x: float, terms: int) -> float:
    """Partial sum of sum_n a_n x^{-n}, i.e. the germ interpretation at x."""
    return eval_series_t(coeffs, 1.0 / x, terms)


def geometric_tail_bound(bound: float, ratio: float, t: float, k: int) -> float:
    """The certified truncation error M (rho t)^k / (1 - rho t)."""
    q = ratio * t
    if not 0.0 <= q < 1.0:
        raise ValueError("need 0 <= ratio * t < 1 for convergence")
    return bound * q**k / (1.0 - q)


def terms_for_accuracy(bound: float, ratio: float, t: float, eps: float) -> int:
    """Least k with M (rho t)^k / (1 - rho t) <= eps  (certified evaluation)."""
    q = ratio * t
    if not 0.0 <= q < 1.0:
        raise ValueError("need 0 <= ratio * t < 1 for convergence")
    if bound == 0.0:
        return 0
    target = eps * (1.0 - q) / bound
    if target >= 1.0:
        return 0
    return max(0, math.ceil(math.log(target) / math.log(q)))


def certified_eval(
    coeffs: Sequence[float], bound: float, ratio: float, x: float, eps: float
) -> Tuple[float, int, float]:
    """Evaluate the germ at x to within eps.  Returns (value, terms used, bound)."""
    t = 1.0 / x
    k = terms_for_accuracy(bound, ratio, t, eps)
    return eval_series_t(coeffs, t, k), k, geometric_tail_bound(bound, ratio, t, k)


def first_nonzero_index(coeffs: Sequence[float], tol: float = 0.0) -> int:
    """Index of the leading nonzero coefficient (len(coeffs) if there is none)."""
    for n, a in enumerate(coeffs):
        if abs(a) > tol:
            return n
    return len(coeffs)


def sign_threshold(coeffs: Sequence[float], bound: float) -> Tuple[int, float]:
    """The eventual sign and the certified threshold (M + |a_{n0}|)/|a_{n0}|."""
    n0 = first_nonzero_index(coeffs)
    if n0 >= len(coeffs):
        raise ValueError("the zero series has no leading monomial")
    lead = coeffs[n0]
    return (1 if lead > 0 else -1), (bound + abs(lead)) / abs(lead)


def cauchy_product(a: Sequence[float], b: Sequence[float], n_max: int) -> List[float]:
    """Coefficients (a*b)_n = sum_{i+j=n} a_i b_j for n <= n_max."""
    out: List[float] = []
    for n in range(n_max + 1):
        s = 0.0
        for i in range(n + 1):
            ai = a[i] if i < len(a) else 0.0
            bj = b[n - i] if n - i < len(b) else 0.0
            s += ai * bj
        out.append(s)
    return out


def lex_compare(a: Sequence[float], b: Sequence[float]) -> Tuple[str, int]:
    """Lexicographic comparison; returns ('<'|'>'|'=', first differing index)."""
    n_max = max(len(a), len(b))
    for n in range(n_max):
        an = a[n] if n < len(a) else 0.0
        bn = b[n] if n < len(b) else 0.0
        if an != bn:
            return ("<" if an < bn else ">"), n
    return "=", -1


def extract_expansion(
    f: Callable[[float], float], order: int, xs: Sequence[float]
) -> List[float]:
    """
    Recover the leading expansion coefficients a_0, ..., a_order of f at +infinity
    by solving, in exact rational arithmetic, the interpolation conditions
        f(x_i) = sum_{n<=order} a_n x_i^{-n},      i = 0, ..., order.
    This is the finite-sample form of the peeling identity
        a_N = lim_{x -> +infinity} x^N ( f(x) - sum_{n<N} a_n x^{-n} ):
    exact when f is a polynomial in 1/x, and accurate up to the size of the
    neglected tail otherwise.
    """
    if len(xs) < order + 1:
        raise ValueError("need at least order+1 sample points")
    m = order + 1
    rows: List[List[Fraction]] = []
    for i in range(m):
        t = Fraction(xs[i]).limit_denominator(10**12)
        t = 1 / t
        rows.append([t**n for n in range(m)] + [Fraction(f(xs[i]))])
    # Gaussian elimination with partial pivoting, over the rationals.
    for col in range(m):
        piv = max(range(col, m), key=lambda r: abs(rows[r][col]))
        if rows[piv][col] == 0:
            raise ValueError("singular sample matrix")
        rows[col], rows[piv] = rows[piv], rows[col]
        inv = 1 / rows[col][col]
        rows[col] = [v * inv for v in rows[col]]
        for r in range(m):
            if r != col and rows[r][col] != 0:
                factor = rows[r][col]
                rows[r] = [v - factor * w for v, w in zip(rows[r], rows[col])]
    return [float(rows[n][m]) for n in range(m)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_rank_comparison() -> None:
    banner("1.  RANK COMPARISON:  r < s  =>  x^r = o(x^s)")
    print(f"{'x':>12} {'x^-3 / x^-1':>16} {'x^1 / x^2':>16} {'x^2 / x^5':>16}")
    for x in (1e1, 1e2, 1e3, 1e4, 1e6):
        print(
            f"{x:12.0e} {rank_ratio(-3, -1, x):16.3e} "
            f"{rank_ratio(1, 2, x):16.3e} {rank_ratio(2, 5, x):16.3e}"
        )
    print("\nEvery ratio of a smaller rank to a larger rank collapses to 0.")


def demo_tail_bound() -> None:
    banner("2.  THE TAIL BOUND IS A CERTIFICATE")
    # All-ones series: sum_n x^{-n} = x / (x - 1) exactly, for x > 1.
    coeffs = [1.0] * 200
    bound, ratio = 1.0, 1.0
    print("Series: 1 + x^-1 + x^-2 + ...   (exact germ:  x / (x - 1))")
    print(f"\n{'x':>8} {'k':>5} {'partial sum':>18} {'exact':>18} "
          f"{'|error|':>12} {'certificate':>12}")
    for x in (2.0, 5.0, 10.0, 100.0):
        exact = x / (x - 1.0)
        for k in (5, 20, 60):
            approx = eval_germ(coeffs, x, k)
            err = abs(exact - approx)
            cert = geometric_tail_bound(bound, ratio, 1.0 / x, k)
            flag = "OK" if err <= cert + 1e-15 else "VIOLATED"
            print(f"{x:8.1f} {k:5d} {approx:18.12f} {exact:18.12f} "
                  f"{err:12.3e} {cert:12.3e}  {flag}")
    print("\nEvery observed error respects the certificate M t^k / (1 - t).")

    banner("2b. CERTIFIED EVALUATION: how many terms for a target accuracy?")
    print(f"{'x':>8} {'eps':>10} {'terms k':>9} {'certificate':>14} {'true error':>14}")
    for x in (1.5, 2.0, 10.0):
        for eps in (1e-3, 1e-6, 1e-12):
            val, k, cert = certified_eval(coeffs, bound, ratio, x, eps)
            true_err = abs(x / (x - 1.0) - val)
            print(f"{x:8.2f} {eps:10.0e} {k:9d} {cert:14.3e} {true_err:14.3e}")


def demo_sign_threshold() -> None:
    banner("3.  THE LEADING MONOMIAL CONTROLS THE EVENTUAL SIGN (SHARPLY)")
    # a_0 = 0, a_1 = 1, a_n = -1 for n >= 2: leading rank -1, bound M = 1.
    coeffs = [0.0, 1.0] + [-1.0] * 400
    bound = 1.0
    sgn, x_star = sign_threshold(coeffs, bound)
    print("Series: x^-1 - x^-2 - x^-3 - ...   with M = 1, leading a_1 = +1")
    print(f"Predicted eventual sign: {sgn:+d}")
    print(f"Certified threshold  X* = (M + |a_1|)/|a_1| = {x_star:.6f}")
    print(f"\n{'x':>10} {'germ value':>18} {'sign':>6} {'x > X*':>8}")
    for x in (1.5, 1.9, 2.0, 2.001, 2.5, 5.0, 50.0):
        v = eval_germ(coeffs, x, 400)
        print(f"{x:10.3f} {v:18.12f} {(1 if v > 0 else (-1 if v < 0 else 0)):6d} "
              f"{str(x > x_star):>8}")
    print("\nThe exact germ here is 1/x - (1/x^2)/(1 - 1/x) = (x - 2)/(x(x-1)),")
    print("which vanishes precisely at x = 2 = X*.  So the threshold produced by")
    print("the estimate is attained: 'eventually' cannot be strengthened.")


def demo_realization() -> None:
    banner("4.  THE GERM REALIZES THE SERIES AS ITS ASYMPTOTIC EXPANSION")
    coeffs = [1.0, -2.0, 0.5, 3.0, -1.0, 0.25, 0.0, 1.0]
    xs = [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0]

    def germ(y: float) -> float:
        return eval_germ(coeffs, y, len(coeffs))

    recovered = extract_expansion(germ, order=7, xs=xs)
    print(f"Peeling coefficients from samples at x = {xs}\n")
    print(f"{'n':>3} {'true a_n':>12} {'recovered':>18} {'abs error':>12}")
    for n, (t, r) in enumerate(zip(coeffs, recovered)):
        print(f"{n:3d} {t:12.6f} {r:18.10f} {abs(t - r):12.3e}")
    print("\nThe expansion coefficients are recovered rank by rank; the residual")
    print("error is only the finite precision of the function samples.")


def demo_lexicographic_order() -> None:
    banner("5.  ORDER EMBEDDING: LEXICOGRAPHIC ORDER = EVENTUAL DOMINATION")
    pairs: List[Tuple[str, List[float], List[float]]] = [
        ("differ at rank 0", [0.5, 9.0, 9.0], [0.7, -9.0, -9.0]),
        ("agree at 0, differ at 1", [1.0, -0.3, 5.0], [1.0, 0.2, -5.0]),
        ("agree at 0,1, differ at 2", [1.0, 1.0, 0.1], [1.0, 1.0, 0.9]),
        ("identical", [0.3, -0.4, 0.5], [0.3, -0.4, 0.5]),
    ]
    for label, a, b in pairs:
        rel, idx = lex_compare(a, b)
        print(f"\n{label}:  a = {a},  b = {b}")
        print(f"  lexicographic verdict: a {rel} b" +
              (f"  (first difference at rank {idx})" if idx >= 0 else ""))
        print(f"  {'x':>10} {'E_a(x)':>16} {'E_b(x)':>16} {'observed':>10}")
        for x in (2.0, 5.0, 20.0, 1e3, 1e6):
            va = eval_germ(a, x, len(a))
            vb = eval_germ(b, x, len(b))
            obs = "<" if va < vb else (">" if va > vb else "=")
            print(f"  {x:10.0f} {va:16.10f} {vb:16.10f} {obs:>10}")
    print("\nThe observed relation is eventually constant (no oscillation) and")
    print("agrees with the lexicographic verdict computed from coefficients alone.")


def demo_flat_kernel() -> None:
    banner("6.  THE FLAT KERNEL: e^{-x} IS INVISIBLE TO THE EXPANSION")
    print(f"{'x':>8} {'e^-x':>14} " + " ".join(f"{'x^' + str(n) + ' e^-x':>14}"
                                               for n in (1, 3, 6, 10)))
    for x in (5.0, 10.0, 20.0, 40.0, 80.0):
        row = [math.exp(-x)] + [x**n * math.exp(-x) for n in (1, 3, 6, 10)]
        print(f"{x:8.1f} " + " ".join(f"{v:14.3e}" for v in row))
    print("\nEvery ratio e^{-x} / x^{-n} = x^n e^{-x} decays to 0, so every")
    print("expansion coefficient of e^{-x} is 0 -- the same expansion as the")
    print("zero function, which e^{-x} never equals.\n")

    print("Two functions sharing an expansion differ by a flat germ:")
    coeffs = [1.0, -1.0, 2.0]

    def f(y: float) -> float:
        return eval_germ(coeffs, y, 3)

    def g(y: float) -> float:
        return f(y) + math.exp(-y) * math.sin(y)  # flat times bounded is flat

    print(f"\n{'x':>8} {'f(x)':>18} {'g(x)':>18} {'f - g':>14}")
    for x in (5.0, 10.0, 20.0, 40.0):
        print(f"{x:8.1f} {f(x):18.12f} {g(x):18.12f} {f(x) - g(x):14.3e}")
    samples = [40.0, 50.0, 60.0]
    rec_f = extract_expansion(f, 2, samples)
    rec_g = extract_expansion(g, 2, samples)
    print(f"\nrecovered expansion of f: {[round(v, 9) for v in rec_f]}")
    print(f"recovered expansion of g: {[round(v, 9) for v in rec_g]}")
    print("Identical expansions, different functions: the fibre of the expansion")
    print("map is exactly the coset f + (flat germs).")


def demo_cauchy_product() -> None:
    banner("7.  MULTIPLICATIVITY AND THE FAILURE OF CLOSURE")
    ones = [1.0] * 60
    conv = cauchy_product(ones, ones, 12)
    print("Cauchy square of the all-ones series (bound M = 1):")
    print("  coefficients:", [int(c) for c in conv])
    print("  predicted   :", [n + 1 for n in range(13)])
    print("\nThese are unbounded, so the BOUNDED fragment is NOT closed under the")
    print("Cauchy product -- the crude estimate |c_n| <= (n+1) M M' is sharp.\n")

    print("But the interpretation IS multiplicative.  Exact germ of the all-ones")
    print("series is x/(x-1); its square must be the germ of the coefficients n+1:")
    conv_long = cauchy_product(ones, ones, 400)
    print(f"\n{'x':>8} {'E(x)^2':>20} {'sum (n+1) x^-n':>20} {'|difference|':>14}")
    for x in (2.0, 3.0, 10.0, 100.0):
        lhs = (x / (x - 1.0)) ** 2
        rhs = eval_germ(conv_long, x, 400)
        print(f"{x:8.1f} {lhs:20.12f} {rhs:20.12f} {abs(lhs - rhs):14.3e}")

    banner("7b. THE GEOMETRIC FRAGMENT IS CLOSED -- WITH A NECESSARY INFLATION")
    # a_n = rho^n, b_n = sigma^n; both geometric with constant 1.
    rho, sigma = 0.8, 0.5
    a = [rho**n for n in range(80)]
    b = [sigma**n for n in range(80)]
    prod = cauchy_product(a, b, 40)
    rho_star = max(rho, sigma)
    print(f"rates rho = {rho}, sigma = {sigma};  rho* = max = {rho_star}")
    print(f"\n{'r':>8} {'constant C(r)':>16} {'max_n |c_n| / r^n':>22} {'holds':>8}")
    for r in (2 * rho_star, 1.5 * rho_star, 1.1 * rho_star, 1.01 * rho_star):
        C = (1.0 + 1.0 / (r / rho_star - 1.0)) * 1.0 * 1.0
        worst = max(abs(prod[n]) / r**n for n in range(41))
        print(f"{r:8.4f} {C:16.4f} {worst:22.6f} {str(worst <= C + 1e-9):>8}")
    print("\nC(r) blows up as r decreases to rho*, and at r = rho* closure fails:")
    ones_conv = cauchy_product([1.0] * 50, [1.0] * 50, 30)
    print("  all-ones series has rate 1; its square has coefficients")
    print("  ", [int(c) for c in ones_conv[:10]], "...,", int(ones_conv[30]))
    print("  which admit no bound M * 1^n.  The inflation cannot be removed.")


def main() -> None:
    print(__doc__)
    demo_rank_comparison()
    demo_tail_bound()
    demo_sign_threshold()
    demo_realization()
    demo_lexicographic_order()
    demo_flat_kernel()
    demo_cauchy_product()
    banner("SUMMARY")
    print(
        "Inside the convergent fragment the formal and analytic worlds coincide:\n"
        "  the interpretation is injective, linear, order preserving for the\n"
        "  lexicographic order, and multiplicative.\n"
        "Outside it, the formal world is exactly a quotient of the analytic one,\n"
        "  with kernel the flat germs -- and not one bit larger."
    )


if __name__ == "__main__":
    main()
