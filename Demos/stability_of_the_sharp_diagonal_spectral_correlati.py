"""
Numerical demonstrations for:

    Stability of the Sharp Diagonal Spectral Correlation Inequality
    for Monotone Boolean Functions

All computations use the uniform measure on the Boolean cube {0,1}^n.
Everything is self-contained: no third-party dependencies.

Key facts demonstrated:
  1. Variance identity:  Cov(f, f) = E[f] * (1 - E[f])   for Boolean f.
  2. Diagonal ceiling:   Cov(f, f) <= 1/4,  equality iff E[f] = 1/2.
  3. Exact stability identity:  1/4 - Cov(f, f) = (E[f] - 1/2)^2.
  4. Quantitative stability:  Cov(f, f) >= 1/4 - eps  ==>  (E[f]-1/2)^2 <= eps.
  5. Harris-FKG positivity:  increasing f, g  ==>  Cov(f, g) >= 0.
  6. AND/OR extremal value on the two-bit cube:  Cov(x&y, x|y) = 1/16.
  7. Dictatorship diagonal extremum:  Cov(x_i, x_i) = 1/4.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Iterable, List, Tuple

Point = Tuple[int, ...]
BoolFn = Callable[[Point], float]


# --------------------------------------------------------------------------
# Core functionals: expectation and covariance under the uniform measure.
# --------------------------------------------------------------------------
def cube(n: int) -> List[Point]:
    """All 2^n points of the Boolean cube {0,1}^n."""
    return list(product((0, 1), repeat=n))


def expect(f: BoolFn, n: int) -> float:
    """Uniform-measure average E[f] over {0,1}^n."""
    pts = cube(n)
    return sum(f(x) for x in pts) / len(pts)


def cov(f: BoolFn, g: BoolFn, n: int) -> float:
    """Covariance Cov(f, g) = E[f*g] - E[f]*E[g] under the uniform measure."""
    fg = lambda x: f(x) * g(x)
    return expect(fg, n) - expect(f, n) * expect(g, n)


def is_boolean(f: BoolFn, n: int) -> bool:
    """Check that f takes only the values 0 and 1 on the cube."""
    return all(f(x) in (0.0, 1.0, 0, 1) for x in cube(n))


def is_increasing(f: BoolFn, n: int) -> bool:
    """Check monotonicity: x <= y (coordinatewise) implies f(x) <= f(y)."""
    pts = cube(n)
    for x in pts:
        for y in pts:
            if all(xi <= yi for xi, yi in zip(x, y)) and f(x) > f(y):
                return False
    return True


# --------------------------------------------------------------------------
# Sample monotone Boolean functions.
# --------------------------------------------------------------------------
def dictatorship(i: int) -> BoolFn:
    """f(x) = x_i : the i-th coordinate dictator."""
    return lambda x: float(x[i])


def and_fn(x: Point) -> float:
    """Two-variable AND on the leading two coordinates."""
    return float(x[0] == 1 and x[1] == 1)


def or_fn(x: Point) -> float:
    """Two-variable OR on the leading two coordinates."""
    return float(x[0] == 1 or x[1] == 1)


def majority3(x: Point) -> float:
    """Majority of three bits: a balanced monotone function on {0,1}^3."""
    return float(sum(x) >= 2)


def threshold(k: int) -> BoolFn:
    """f(x) = 1 iff at least k coordinates are 1 (a monotone threshold)."""
    return lambda x: float(sum(x) >= k)


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------
def demo_variance_identity() -> None:
    print("=" * 70)
    print("1. Variance identity  Cov(f,f) = E[f](1-E[f])")
    print("=" * 70)
    cases: List[Tuple[str, BoolFn, int]] = [
        ("dictatorship x_0 on {0,1}^1", dictatorship(0), 1),
        ("dictatorship x_1 on {0,1}^3", dictatorship(1), 3),
        ("AND on {0,1}^2", and_fn, 2),
        ("OR on {0,1}^2", or_fn, 2),
        ("majority-of-3 on {0,1}^3", majority3, 3),
        ("threshold>=2 on {0,1}^4", threshold(2), 4),
    ]
    for name, f, n in cases:
        m = expect(f, n)
        lhs = cov(f, f, n)
        rhs = m * (1 - m)
        print(f"  {name:32s}  E[f]={m:.4f}  "
              f"Cov(f,f)={lhs:.6f}  E[f](1-E[f])={rhs:.6f}  "
              f"match={abs(lhs - rhs) < 1e-12}")
    print()


def demo_ceiling_and_extremal() -> None:
    print("=" * 70)
    print("2. Diagonal ceiling Cov(f,f) <= 1/4, equality iff balanced")
    print("=" * 70)
    cases: List[Tuple[str, BoolFn, int]] = [
        ("dictatorship (balanced)", dictatorship(0), 3),
        ("majority-of-3 (balanced)", majority3, 3),
        ("AND (unbalanced)", and_fn, 2),
        ("threshold>=1 on {0,1}^3", threshold(1), 3),
    ]
    for name, f, n in cases:
        m = expect(f, n)
        c = cov(f, f, n)
        print(f"  {name:28s}  Cov(f,f)={c:.6f} <= 0.25 : {c <= 0.25 + 1e-12}"
              f"   balanced(E[f]=1/2)={abs(m - 0.5) < 1e-12}"
              f"   extremal(Cov=1/4)={abs(c - 0.25) < 1e-12}")
    print()


def demo_stability() -> None:
    print("=" * 70)
    print("3-4. Exact stability identity and the stability bound")
    print("     1/4 - Cov(f,f) = (E[f]-1/2)^2   and   Cov>=1/4-eps => (E[f]-1/2)^2<=eps")
    print("=" * 70)
    cases: List[Tuple[str, BoolFn, int]] = [
        ("dictatorship x_0 on {0,1}^4", dictatorship(0), 4),
        ("AND on {0,1}^2", and_fn, 2),
        ("threshold>=2 on {0,1}^3", threshold(2), 3),
        ("threshold>=3 on {0,1}^4", threshold(3), 4),
    ]
    for name, f, n in cases:
        m = expect(f, n)
        c = cov(f, f, n)
        gap = 0.25 - c
        sq = (m - 0.5) ** 2
        # eps chosen exactly at the observed gap; stability must hold with equality
        eps = gap
        holds = sq <= eps + 1e-12
        print(f"  {name:30s}  1/4-Cov={gap:.6f}  (E[f]-1/2)^2={sq:.6f}  "
              f"identity_match={abs(gap - sq) < 1e-12}  stability_holds={holds}")
    print()


def demo_harris_fkg() -> None:
    print("=" * 70)
    print("5. Harris-FKG: increasing f,g  =>  Cov(f,g) >= 0")
    print("=" * 70)
    n = 4
    fns: List[Tuple[str, BoolFn]] = [
        ("x_0", dictatorship(0)),
        ("x_1", dictatorship(1)),
        ("thr>=2", threshold(2)),
        ("thr>=3", threshold(3)),
        ("AND(x_0,x_1)", and_fn),
        ("OR(x_0,x_1)", or_fn),
    ]
    all_ok = True
    for (na, fa) in fns:
        for (nb, fb) in fns:
            inc = is_increasing(fa, n) and is_increasing(fb, n)
            c = cov(fa, fb, n)
            if inc and c < -1e-12:
                all_ok = False
            print(f"  Cov({na:12s},{nb:12s}) = {c:+.6f}"
                  f"   increasing_pair={inc}")
    print(f"  ALL increasing pairs nonnegative: {all_ok}")
    print()


def demo_and_or() -> None:
    print("=" * 70)
    print("6-7. AND/OR extremal value = 1/16;  dictatorship diagonal = 1/4")
    print("=" * 70)
    n = 2
    c = cov(and_fn, or_fn, n)
    print(f"  E[AND]         = {expect(and_fn, n):.4f}   (expected 1/4  = 0.25)")
    print(f"  E[OR]          = {expect(or_fn, n):.4f}   (expected 3/4  = 0.75)")
    print(f"  Cov(AND, OR)   = {c:.6f} (expected 1/16 = {1/16:.6f})"
          f"   match={abs(c - 1/16) < 1e-12}")
    d = cov(dictatorship(0), dictatorship(0), 3)
    print(f"  Cov(x_0, x_0)  = {d:.6f} (expected 1/4  = 0.25)"
          f"   match={abs(d - 0.25) < 1e-12}")
    print()


def demo_biased_measure() -> None:
    """
    Robustness: under the p-biased product measure the variance identity
    Cov_p(f,f) = E_p[f](1 - E_p[f]) still holds, with the same stability bound.
    """
    print("=" * 70)
    print("Bonus: biased-measure robustness  Cov_p(f,f) = E_p[f](1-E_p[f])")
    print("=" * 70)

    def weight(x: Point, p: float) -> float:
        return 1.0 * _pow(p, sum(x)) * _pow(1 - p, len(x) - sum(x))

    def expect_p(f: BoolFn, n: int, p: float) -> float:
        return sum(f(x) * weight(x, p) for x in cube(n))

    def cov_p(f: BoolFn, g: BoolFn, n: int, p: float) -> float:
        fg = lambda x: f(x) * g(x)
        return expect_p(fg, n, p) - expect_p(f, n, p) * expect_p(g, n, p)

    n = 3
    for p in (0.2, 0.5, 0.7):
        for name, f in (("thr>=2", threshold(2)), ("x_0", dictatorship(0))):
            m = expect_p(f, n, p)
            lhs = cov_p(f, f, n, p)
            rhs = m * (1 - m)
            print(f"  p={p:.1f}  {name:8s}  E_p[f]={m:.4f}  "
                  f"Cov_p(f,f)={lhs:.6f}  E_p(1-E_p)={rhs:.6f}  "
                  f"match={abs(lhs - rhs) < 1e-12}")
    print()


def _pow(base: float, exp: int) -> float:
    """Integer power helper (avoids importing math)."""
    result = 1.0
    for _ in range(exp):
        result *= base
    return result


def main() -> None:
    demo_variance_identity()
    demo_ceiling_and_extremal()
    demo_stability()
    demo_harris_fkg()
    demo_and_or()
    demo_biased_measure()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
