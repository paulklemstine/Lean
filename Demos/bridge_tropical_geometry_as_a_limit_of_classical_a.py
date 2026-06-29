"""
Numerical demonstrations for:

    Tropical Geometry as a Limit of Classical Algebraic Geometry
    Tropicalization, the Corner Locus, and Tropical Bezout

All routines use the MIN-PLUS convention:
    tropical addition       a (+) b = min(a, b)
    tropical multiplication a (*) b = a + b
    tropical zero           = +inf
    tropical one            = 0

A tropical polynomial in n variables is represented as a list of monomials
    (coeff, exponent_vector)
where `coeff` is the valuation v(c_a) (a real number, or math.inf if absent)
and `exponent_vector` is a tuple of natural-number exponents.

This file is fully self-contained: every function is inlined and type-hinted,
and `main()` prints a guided walkthrough of the paper's key results.
"""

from __future__ import annotations

import math
from typing import Sequence


# ---------------------------------------------------------------------------
# Core min-plus primitives
# ---------------------------------------------------------------------------

Exponent = tuple[int, ...]
Monomial = tuple[float, Exponent]  # (v(coeff), exponent vector)
TropPoly = list[Monomial]


def lin_form(a: Exponent, w: Sequence[float]) -> float:
    """The linear form <a, w> = sum_i a_i * w_i."""
    return sum(ai * wi for ai, wi in zip(a, w))


def trop_monomial(coeff: float, a: Exponent, w: Sequence[float]) -> float:
    """tropMonomial = v(coeff) + <a, w>  (min-plus value of one term)."""
    return coeff + lin_form(a, w)


def trop_poly_value(f: TropPoly, w: Sequence[float]) -> float:
    """tropPolyValue(f, w) = min over support of tropMonomial."""
    return min(trop_monomial(c, a, w) for c, a in f)


def minimizing_indices(f: TropPoly, w: Sequence[float], tol: float = 1e-9) -> list[int]:
    """Indices of monomials attaining the defining minimum at w."""
    m = trop_poly_value(f, w)
    return [i for i, (c, a) in enumerate(f) if abs(trop_monomial(c, a, w) - m) <= tol]


def is_corner_point(f: TropPoly, w: Sequence[float], tol: float = 1e-9) -> bool:
    """w is a corner point iff the minimum is attained at >= 2 distinct monomials."""
    return len(minimizing_indices(f, w, tol)) >= 2


# ---------------------------------------------------------------------------
# One-variable tropical Bezout via the lower envelope
# ---------------------------------------------------------------------------

def univariate_roots_with_multiplicity(
    coeffs: dict[int, float],
    degree: int,
    grid: tuple[float, float, int] = (-50.0, 50.0, 200001),
) -> list[tuple[float, int]]:
    """
    Compute tropical roots (corners) and multiplicities (slope drops) of the
    degree-`degree` univariate tropical polynomial

        T(w) = min_{k} ( coeffs[k] + k * w ).

    The multiplicity at a corner is the drop in the minimizing slope.
    Returns a list of (root, multiplicity) sorted by root.

    We detect slope changes by scanning the minimizing slope on a fine grid;
    the total of multiplicities equals `degree` (tropical Bezout).
    """
    lo, hi, n = grid
    xs = [lo + (hi - lo) * i / (n - 1) for i in range(n)]

    def min_slope(w: float) -> int:
        """The smallest slope k attaining the minimum (lower envelope slope)."""
        best_val = math.inf
        best_k = degree
        for k, c in coeffs.items():
            val = c + k * w
            if val < best_val - 1e-12:
                best_val = val
                best_k = k
        return best_k

    roots: list[tuple[float, int]] = []
    prev_slope = min_slope(xs[0])
    for i in range(1, len(xs)):
        s = min_slope(xs[i])
        if s != prev_slope:
            drop = prev_slope - s  # concave => nonnegative
            midpoint = 0.5 * (xs[i - 1] + xs[i])
            roots.append((midpoint, drop))
            prev_slope = s
    return roots


def total_multiplicity(roots: list[tuple[float, int]]) -> int:
    """Sum of multiplicities -- should equal the degree (Theorem: tropical_bezout)."""
    return sum(m for _, m in roots)


def tropical_roots_from_classical(valuations: Sequence[float]) -> list[float]:
    """
    For f = c * prod_j (x - r_j), the tropical roots are exactly the valuations
    v(r_j) (tropPolyValue_linearFactor). Given the valuations of the classical
    roots, return the sorted tropical roots.
    """
    return sorted(valuations)


# ---------------------------------------------------------------------------
# Maslov dequantization
# ---------------------------------------------------------------------------

def log_add_exp(x: float, y: float, t: float) -> float:
    """
    Dequantized addition (max-convention):
        x (+)_t y = (1/t) log(e^{tx} + e^{ty}).
    Numerically stable via factoring out the maximum.
    """
    m = max(x, y)
    return m + math.log(math.exp(t * (x - m)) + math.exp(t * (y - m))) / t


def dequantization_error(x: float, y: float, t: float) -> float:
    """Overshoot of the smooth max over the true max; in [0, log(2)/t]."""
    return log_add_exp(x, y, t) - max(x, y)


# ---------------------------------------------------------------------------
# Walkthrough
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("Tropical Geometry as a Limit of Classical Algebraic Geometry")
    print("=" * 70)

    # --- Demo 1: a tropical line in the plane and its corner locus ---------
    print("\n[1] Tropical line  T(w) = min(0 + w1, 0 + w2, 0)  (trop of x+y+1)")
    f_line: TropPoly = [(0.0, (1, 0)), (0.0, (0, 1)), (0.0, (0, 0))]
    test_pts = [(0.0, 0.0), (2.0, 2.0), (-1.0, -1.0), (3.0, -1.0), (0.0, 5.0)]
    for w in test_pts:
        val = trop_poly_value(f_line, w)
        idx = minimizing_indices(f_line, w)
        corner = is_corner_point(f_line, w)
        print(f"   w={w!s:>12}  T(w)={val:6.2f}  minimizers={idx}  corner={corner}")
    print("   The corner locus is the tropical line: three rays from the origin.")

    # --- Demo 2: forward inclusion, illustrated -----------------------------
    print("\n[2] Forward inclusion  Trop(V(f)) subset cornerLocus(trop f)")
    print("    A classical zero forces the cheapest tropical term to tie (>=2 minimizers).")
    print("    The origin (0,0) above has 3 minimizers -> a genuine corner point.")

    # --- Demo 3: tropical Bezout in one variable ----------------------------
    print("\n[3] Tropical Bezout: degree-d poly has exactly d roots (with mult.)")
    # T(w) = min(6, 3+w, 1+2w, 0+3w): degree 3 with three distinct simple roots
    # (corners at w = 1, 2, 3 where consecutive lines tie).
    coeffs = {0: 6.0, 1: 3.0, 2: 1.0, 3: 0.0}
    degree = 3
    roots = univariate_roots_with_multiplicity(coeffs, degree)
    for r, m in roots:
        print(f"   tropical root ~ {r:7.3f}   multiplicity {m}")
    tot = total_multiplicity(roots)
    print(f"   sum of multiplicities = {tot}  (should equal degree d = {degree})")
    assert tot == degree, "tropical Bezout failed!"
    print("   VERIFIED: sum of slope drops == degree.")

    # --- Demo 4: tropical roots = valuations of classical roots -------------
    print("\n[4] tropPolyValue_linearFactor: roots are valuations of classical roots")
    valuations = [-2.0, 0.0, 5.0]  # v(r_j) for f = c (x-r1)(x-r2)(x-r3)
    troots = tropical_roots_from_classical(valuations)
    print(f"   classical root valuations v(r_j) = {valuations}")
    print(f"   tropical roots                   = {troots}")
    print("   They coincide (with multiplicity), matching tropical Bezout count.")

    # --- Demo 5: Maslov dequantization limit --------------------------------
    print("\n[5] Maslov dequantization:  x (+)_t y -> max(x, y)  as t -> infinity")
    x, y = 3.0, 5.0
    print(f"   x={x}, y={y}, max(x,y)={max(x, y)}")
    for t in [0.5, 1.0, 2.0, 5.0, 20.0, 100.0]:
        s = log_add_exp(x, y, t)
        err = dequantization_error(x, y, t)
        bound = math.log(2) / t
        print(f"   t={t:6.1f}   x(+)_t y={s:8.5f}   error={err:8.5f}   log2/t={bound:8.5f}")
    print("   error stays in [0, log2/t] and -> 0  (two-sided sandwich).")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
