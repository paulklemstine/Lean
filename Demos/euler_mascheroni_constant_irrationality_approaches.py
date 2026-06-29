"""Numerical demonstrations for the Euler--Mascheroni constant.

This self-contained script illustrates the main results developed in the
accompanying article and paper, organized around the single positive term

    g(k) = 1/k - ln(1 + 1/k),     k >= 1.

Results demonstrated:
  (1) positivity of g(k);
  (2) telescoping partial sum   sum_{k=1}^n g(k) = H_n - ln(n+1) = L_n;
  (3) series convergence        sum_{k>=1} g(k) = gamma;
  (4) integral form of a term   g(k) = int_k^{k+1} (1/k - 1/y) dy;
  (5) staircase representation  gamma = int_1^infty (1/floor(x) - 1/x) dx;
  (6) sharp per-term bound       g(k) < 1/(2 k^2);
  (7) convergence rate           0 < gamma - L_n < 1/(2 n);
  (8) Stieltjes anchor           gamma_0 = gamma;
  (9) the irrationality engine   (integer linear forms tending to 0).

Run with:  python demo.py
"""

from __future__ import annotations

import math

# High-precision reference value of the Euler--Mascheroni constant.
GAMMA: float = 0.57721566490153286060651209008240243104215933593992


def g(k: int) -> float:
    """The series term g(k) = 1/k - ln(1 + 1/k), with g(0) = 0."""
    if k == 0:
        return 0.0
    return 1.0 / k - math.log(1.0 + 1.0 / k)


def harmonic(n: int) -> float:
    """The n-th harmonic number H_n = sum_{k=1}^n 1/k (H_0 = 0)."""
    return sum(1.0 / k for k in range(1, n + 1))


def lower_approximant(n: int) -> float:
    """L_n = H_n - ln(n+1), the certified lower bound for gamma."""
    return harmonic(n) - math.log(n + 1)


def upper_approximant(n: int) -> float:
    """U_n = H_n - ln(n), the upper bound for gamma (n >= 1)."""
    return harmonic(n) - math.log(n)


def partial_series(n: int) -> float:
    """Partial sum sum_{k=1}^n g(k); equals L_n by the telescoping identity."""
    return sum(g(k) for k in range(1, n + 1))


def term_integral(k: int, steps: int = 200_000) -> float:
    """Midpoint-rule estimate of int_k^{k+1} (1/k - 1/y) dy, which equals g(k)."""
    h = 1.0 / steps
    total = 0.0
    for i in range(steps):
        y = k + (i + 0.5) * h
        total += (1.0 / k - 1.0 / y) * h
    return total


def staircase_integral(N: int, steps_per_unit: int = 20_000) -> float:
    """Midpoint estimate of int_1^N (1/floor(x) - 1/x) dx ( -> gamma as N -> oo)."""
    h = 1.0 / steps_per_unit
    total = 0.0
    x = 1.0
    while x < N - 1e-12:
        mid = x + 0.5 * h
        total += (1.0 / math.floor(mid) - 1.0 / mid) * h
        x += h
    return total


def stieltjes_seq(m: int, n: int) -> float:
    """S_m(n) = sum_{k=1}^n (ln k)^m / k - (ln n)^{m+1}/(m+1).  S_0 -> gamma."""
    s = sum((math.log(k) ** m) / k for k in range(1, n + 1))
    return s - (math.log(n) ** (m + 1)) / (m + 1)


def linear_form(a: int, b: int, x: float) -> float:
    """An integer linear form a + b*x used by the irrationality criterion."""
    return a + b * x


def demo_positivity() -> None:
    print("=" * 64)
    print("(1) Positivity of g(k):  g(k) > 0 for all k >= 1")
    print("=" * 64)
    for k in [1, 2, 5, 10, 100]:
        print(f"  g({k:>3}) = {g(k):.12e}  > 0 : {g(k) > 0}")


def demo_telescoping() -> None:
    print("=" * 64)
    print("(2) Telescoping:  sum_{k=1}^n g(k) = H_n - ln(n+1) = L_n")
    print("=" * 64)
    for n in [1, 5, 20, 100]:
        lhs = partial_series(n)
        rhs = lower_approximant(n)
        print(f"  n={n:>4}:  partial={lhs:.12f}  L_n={rhs:.12f}  "
              f"diff={abs(lhs - rhs):.2e}")


def demo_convergence() -> None:
    print("=" * 64)
    print("(3,7) Series -> gamma, and rate 0 < gamma - L_n < 1/(2n)")
    print("=" * 64)
    print(f"  reference gamma = {GAMMA:.15f}")
    for n in [10, 100, 1_000, 10_000]:
        Ln = lower_approximant(n)
        err = GAMMA - Ln
        bound = 1.0 / (2 * n)
        print(f"  n={n:>6}:  L_n={Ln:.12f}  gamma-L_n={err:.3e}  "
              f"1/(2n)={bound:.3e}  ok={0 < err < bound}")


def demo_integral_term() -> None:
    print("=" * 64)
    print("(4) Integral form:  g(k) = int_k^{k+1} (1/k - 1/y) dy")
    print("=" * 64)
    for k in [1, 2, 7]:
        approx = term_integral(k)
        exact = g(k)
        print(f"  k={k}:  quadrature={approx:.10f}  g(k)={exact:.10f}  "
              f"diff={abs(approx - exact):.2e}")


def demo_staircase() -> None:
    print("=" * 64)
    print("(5) Staircase:  gamma = int_1^infty (1/floor(x) - 1/x) dx")
    print("=" * 64)
    for N in [10, 100, 1_000]:
        val = staircase_integral(N)
        Ln = lower_approximant(N - 1)
        print(f"  int_1^{N:<5}={val:.10f}  L_(N-1)={Ln:.10f}  "
              f"gamma={GAMMA:.6f}")


def demo_per_term_bound() -> None:
    print("=" * 64)
    print("(6) Sharp per-term bound:  g(k) < 1/(2 k^2)")
    print("=" * 64)
    for k in [1, 2, 5, 50, 500]:
        gk = g(k)
        bd = 1.0 / (2 * k * k)
        print(f"  k={k:>4}:  g(k)={gk:.3e}  1/(2k^2)={bd:.3e}  "
              f"holds={gk < bd}")


def demo_stieltjes() -> None:
    print("=" * 64)
    print("(8) Stieltjes anchor:  gamma_0 = gamma   (S_0(n) -> gamma)")
    print("=" * 64)
    for n in [10, 100, 1_000, 10_000]:
        s0 = stieltjes_seq(0, n)
        print(f"  n={n:>6}:  S_0(n)={s0:.12f}  (= H_n - ln n)  "
              f"gamma={GAMMA:.6f}")


def demo_irrationality_engine() -> None:
    print("=" * 64)
    print("(9) Irrationality engine: a rational keeps nonzero forms >= 1/q")
    print("=" * 64)
    # For a RATIONAL x = p/q, every nonzero a + b x stays at distance >= 1/q.
    p, q = 22, 7  # x = 22/7
    x_rat = p / q
    print(f"  Rational x = {p}/{q}:  nonzero forms a+bx satisfy |a+bx| >= 1/q = {1/q:.4f}")
    worst = min(
        abs(linear_form(a, b, x_rat))
        for a in range(-20, 21)
        for b in range(-20, 21)
        if linear_form(a, b, x_rat) != 0
    )
    print(f"    smallest nonzero |a+bx| over |a|,|b|<=20 : {worst:.4f}  (>= {1/q:.4f})")
    # For an IRRATIONAL x, good rational approximations give nonzero forms -> 0.
    print(f"  Irrational-style forms for x = gamma via continued-fraction p/q:")
    for (a, b) in [(-1, 2), (-4, 7), (-7, 12), (-58, 100)]:
        # b = q (denominator), a = -p (numerator) so a + b*gamma = b*(gamma - p/b)
        print(f"    a={a:>5}, b={b:>4}:  a + b*gamma = {linear_form(a, b, GAMMA): .6f}")


def main() -> None:
    demo_positivity()
    demo_telescoping()
    demo_convergence()
    demo_integral_term()
    demo_staircase()
    demo_per_term_bound()
    demo_stieltjes()
    demo_irrationality_engine()
    print("=" * 64)
    print("All demonstrations complete.")
    print("=" * 64)


if __name__ == "__main__":
    main()
