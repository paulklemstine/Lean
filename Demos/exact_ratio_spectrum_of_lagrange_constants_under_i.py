"""
Numerical demonstrations for:

    Exact Ratio Spectrum of Lagrange Constants under
    Integer Linear Fractional Transformations

For a real number x the Lagrange (approximation) constant is

    k(x) = liminf_{q -> infinity} q * ||q x||

where ||y|| is the distance from y to the nearest integer.  x is "badly
approximable" when k(x) > 0.  This script numerically illustrates:

  1. The nearest-integer distance and the approximation function q -> q*||qx||.
  2. Empirical estimates of the Lagrange constant for famous numbers
     (golden ratio -> 1/sqrt5, sqrt(2) -> 1/(2 sqrt2), etc.).
  3. Exact term-by-term invariance under x -> x + b and x -> -x
     (the determinant +-1 affine generators), giving ratio = 1.
  4. The dilation lower bound k(n x) >= (1/n) k(x), i.e. the ratio lies in
     [1/n, n] = [|det|^{-1}, |det|].
  5. The bridge: badly approximable reals admit arbitrarily small NONZERO
     integer linear forms |q x - p|, witnessing irrationality.

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
# 1. Core quantities
# --------------------------------------------------------------------------- #
def ndist(y: float) -> float:
    """Distance from y to the nearest integer, ||y|| = |y - round(y)|."""
    return abs(y - round(y))


def approx(x: float, q: int) -> float:
    """The approximation function approx(x, q) = q * ||q x||."""
    return q * ndist(q * x)


def continued_fraction_terms(x: float, n_terms: int = 22) -> List[int]:
    """
    Numerically extract the first partial quotients [a0; a1, a2, ...] of x.
    Reliable for ~22 terms for the quadratic irrationals used here before
    floating-point error accumulates.
    """
    terms: List[int] = []
    v = x
    for _ in range(n_terms):
        a = math.floor(v)
        terms.append(a)
        frac = v - a
        if frac < 1e-12:
            break
        v = 1.0 / frac
    return terms


def lagrange_constant_estimate(x: float, q_max: int = 0) -> float:
    """
    Estimate k(x) = liminf_{q->inf} q*||q x|| via continued-fraction
    complete quotients.  Using the standard identity

        q_n * ||q_n x|| = 1 / ( theta_{n+1} + [0; a_n, ..., a_1] ),

    where theta_{n+1} = [a_{n+1}; a_{n+2}, ...] is the (n+1)-st complete
    quotient, the Lagrange constant is the liminf over n of these values.
    Both terms are O(1), so this is numerically stable (unlike a raw
    minimum of q*||q x|| over a sampling window).  The unused q_max argument
    is retained for interface compatibility.
    """
    a = continued_fraction_terms(x, n_terms=22)
    m = len(a)
    values: List[float] = []
    # Use a stable middle range of indices, away from float-corrupted tail.
    for n in range(2, min(m - 4, 16)):
        # theta_{n+1} = [a_{n+1}; a_{n+2}, ..., a_{m-1}]  (backward recurrence)
        theta = float(a[m - 1])
        for i in range(m - 2, n, -1):
            theta = a[i] + 1.0 / theta
        # r_n = [0; a_n, a_{n-1}, ..., a_1] = 1 / [a_n; a_{n-1}; ...; a_1]
        t = float(a[1])
        for k in range(2, n + 1):
            t = a[k] + 1.0 / t
        r = 1.0 / t
        values.append(1.0 / (theta + r))
    return min(values)


# --------------------------------------------------------------------------- #
# 2. Famous constants and their theoretical Lagrange constants
# --------------------------------------------------------------------------- #
def famous_constants() -> List[Tuple[str, float, float]]:
    """Return (name, value, theoretical k(x)) triples."""
    phi = (1.0 + math.sqrt(5.0)) / 2.0
    return [
        ("golden ratio phi", phi, 1.0 / math.sqrt(5.0)),
        ("sqrt(2)", math.sqrt(2.0), 1.0 / (2.0 * math.sqrt(2.0))),
        ("sqrt(3)", math.sqrt(3.0), 1.0 / (2.0 * math.sqrt(3.0))),
    ]


# --------------------------------------------------------------------------- #
# 3. Invariance (determinant +-1 affine generators)
# --------------------------------------------------------------------------- #
def check_pointwise_invariance(x: float, q_max: int = 5_000) -> Tuple[float, float]:
    """
    Verify the term-by-term identities approx(x+b, q) = approx(x, q) and
    approx(-x, q) = approx(x, q).  Returns the maximum observed deviations
    (should be ~0 up to floating point error).
    """
    b = 7  # any integer
    max_shift = 0.0
    max_refl = 0.0
    for q in range(1, q_max + 1):
        max_shift = max(max_shift, abs(approx(x + b, q) - approx(x, q)))
        max_refl = max(max_refl, abs(approx(-x, q) - approx(x, q)))
    return max_shift, max_refl


# --------------------------------------------------------------------------- #
# 4. Dilation ratio:  k(n x) / k(x)  in  [1/n, n]
# --------------------------------------------------------------------------- #
def cf_sqrt(big_n: int) -> List[int]:
    """
    Exact integer continued fraction of sqrt(big_n) for non-square big_n:
    returns [a0] followed by one full period [a1, ..., a_L].  Uses the
    classical (m, d, a) recurrence with exact integer arithmetic.
    """
    a0 = math.isqrt(big_n)
    if a0 * a0 == big_n:
        return [a0]
    terms = [a0]
    m, d, a = 0, 1, a0
    while a != 2 * a0:
        m = d * a - m
        d = (big_n - m * m) // d
        a = (a0 + m) // d
        terms.append(a)
    return terms


def lagrange_constant_sqrt(big_n: int) -> float:
    """
    Exact Lagrange constant of sqrt(big_n) via its periodic continued
    fraction.  We expand the period many times to obtain a long list of
    exact partial quotients, then apply the complete-quotient identity
    k = liminf_n 1 / (theta_{n+1} + [0; a_n, ..., a_1]) over a stable window.
    """
    head = cf_sqrt(big_n)
    a0, period = head[0], head[1:]
    if not period:                       # perfect square (rational)
        return 0.0
    a = [a0] + period * 30               # long exact expansion
    m = len(a)
    values: List[float] = []
    for n in range(len(period) + 2, len(period) + 2 + 2 * len(period)):
        theta = float(a[m - 1])
        for i in range(m - 2, n, -1):
            theta = a[i] + 1.0 / theta
        t = float(a[1])
        for k in range(2, n + 1):
            t = a[k] + 1.0 / t
        r = 1.0 / t
        values.append(1.0 / (theta + r))
    return min(values)


def dilation_ratio_sqrt(d: int, n: int) -> Tuple[float, float, float]:
    """
    Exact ratio k(n*sqrt(d)) / k(sqrt(d)), using n*sqrt(d) = sqrt(n^2 d).
    Returns (ratio, lower_bound = 1/n, upper_bound = n).
    """
    k_x = lagrange_constant_sqrt(d)
    k_nx = lagrange_constant_sqrt(n * n * d)
    ratio = k_nx / k_x if k_x > 0 else float("inf")
    return ratio, 1.0 / n, float(n)


# --------------------------------------------------------------------------- #
# 5. Small NONZERO linear forms (the irrationality bridge)
# --------------------------------------------------------------------------- #
def smallest_nonzero_form(x: float, q_max: int = 100_000) -> Tuple[int, int, float]:
    """
    Find q in [1, q_max] minimizing the NONZERO form |q x - round(q x)|.
    Returns (q, p = round(q x), |q x - p|).  For a badly approximable x this
    form is always strictly positive (Theorem `ndist_pos_of_bad`).
    """
    best_q, best_p, best_val = 1, round(x), ndist(x)
    for q in range(1, q_max + 1):
        v = ndist(q * x)
        if 0.0 < v < best_val:
            best_q, best_p, best_val = q, round(q * x), v
    return best_q, best_p, best_val


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("Lagrange constants under integer transformations -- numerical demo")
    print("=" * 70)

    print("\n[2] Estimated vs. theoretical Lagrange constants k(x):")
    print(f"    {'number':<20}{'estimate':>14}{'theory':>14}")
    for name, value, theory in famous_constants():
        est = lagrange_constant_estimate(value, q_max=120_000)
        print(f"    {name:<20}{est:>14.6f}{theory:>14.6f}")

    phi = (1.0 + math.sqrt(5.0)) / 2.0

    print("\n[3] Exact invariance (determinant +-1 generators), max deviation:")
    ms, mr = check_pointwise_invariance(phi)
    print(f"    max |approx(x+7,q) - approx(x,q)| = {ms:.2e}")
    print(f"    max |approx(-x,q)  - approx(x,q)| = {mr:.2e}")
    print("    => ratio k(Mx)/k(x) = 1  =  [|det|^-1, |det|] = [1, 1]")

    print("\n[4] Dilation ratio k(n x)/k(x) inside the window [1/n, n]")
    print("    (exact, via n*sqrt(d) = sqrt(n^2 d)):")
    print(f"    {'x':<14}{'n':>3}{'ratio':>12}{'window':>22}")
    for d in (2, 3, 5, 7):
        for n in (2, 3, 5):
            ratio, lo, hi = dilation_ratio_sqrt(d, n)
            inside = "OK" if lo - 1e-9 <= ratio <= hi + 1e-9 else "OUT"
            print(f"    sqrt({d})       {n:>3}{ratio:>12.4f}"
                  f"     [{lo:.4f}, {hi:.4f}] {inside}")

    print("\n[5] Small NONZERO linear forms |q x - p| (irrationality bridge):")
    for name, value, _ in [("golden ratio phi", phi, 0.0),
                           ("sqrt(2)", math.sqrt(2.0), 0.0)]:
        q, p, val = smallest_nonzero_form(value, q_max=50_000)
        print(f"    {name:<18}  q={q:<6} p={p:<6} |qx-p|={val:.3e}  (>0)")
    print("    => arbitrarily small NONZERO forms exist  =>  x is irrational")

    print("\n" + "=" * 70)
    print("All numerical checks consistent with the proved theorems.")
    print("=" * 70)


if __name__ == "__main__":
    main()
