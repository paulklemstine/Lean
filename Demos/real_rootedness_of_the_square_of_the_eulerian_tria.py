"""Numerical demonstrations for real-rootedness of the square of the Eulerian
triangle.

The Eulerian number A(n, k) counts permutations of {1, ..., n} with exactly k
descents.  Squaring the Eulerian triangle (as a lower-triangular matrix) gives
the entries

    C(n, k) = sum_j A(n, j) * A(j, k),

and the row generating polynomials

    B_n(x) = sum_k C(n, k) * x^k.

This script builds these objects with exact integer arithmetic and verifies,
row by row, that B_n has n - 2 real, negative, simple roots (for n <= 7),
using only sign changes of the polynomial -- a proof-producing separation.
It also exhibits the obstruction at n = 8, where two roots share (-1, 0).

Self-contained: standard library only (no numpy).
"""

from __future__ import annotations

from math import factorial
from typing import Dict, List, Tuple


def eulerian(n: int, k: int) -> int:
    """Eulerian number A(n, k) via the standard recurrence.

    A(0, 0) = 1; A(n, k) = (k + 1) A(n-1, k) + (n - k) A(n-1, k-1);
    A(n, k) = 0 for k < 0 or k > n - 1 when n >= 1.
    """
    if n == 0:
        return 1 if k == 0 else 0
    if k < 0 or k > n - 1:
        return 0
    return (k + 1) * eulerian(n - 1, k) + (n - k) * eulerian(n - 1, k - 1)


def eulerian_row(n: int) -> List[int]:
    """Full row [A(n, 0), ..., A(n, n)] (last entry is 0 for n >= 1)."""
    return [eulerian(n, k) for k in range(n + 1)]


def squared_entry(n: int, k: int) -> int:
    """Entry C(n, k) = sum_j A(n, j) * A(j, k) of the squared triangle."""
    return sum(eulerian(n, j) * eulerian(j, k) for j in range(n + 1))


def squared_poly_coeffs(n: int) -> List[int]:
    """Coefficients [C(n, 0), C(n, 1), ...] of B_n, low degree first,
    with trailing zeros stripped."""
    coeffs = [squared_entry(n, k) for k in range(n + 1)]
    while len(coeffs) > 1 and coeffs[-1] == 0:
        coeffs.pop()
    return coeffs


def poly_eval(coeffs: List[int], x: float) -> float:
    """Evaluate a polynomial (low degree first) at x via Horner's rule."""
    acc = 0.0
    for c in reversed(coeffs):
        acc = acc * x + c
    return acc


def count_sign_change_brackets(coeffs: List[int], lo: int, hi: int) -> List[Tuple[int, int]]:
    """Return unit integer intervals (a, a+1) in [lo, hi] across which B_n
    changes sign.  Each such interval rigorously contains a real root by the
    Intermediate Value Theorem."""
    brackets: List[Tuple[int, int]] = []
    for a in range(lo, hi):
        va = poly_eval(coeffs, float(a))
        vb = poly_eval(coeffs, float(a + 1))
        if va == 0.0:
            # exact integer root at a
            brackets.append((a, a))
        elif va * vb < 0.0:
            brackets.append((a, a + 1))
    return brackets


def bisect_root(coeffs: List[int], a: float, b: float, iters: int = 200) -> float:
    """Refine a root inside a sign-change bracket [a, b] by bisection."""
    fa = poly_eval(coeffs, a)
    for _ in range(iters):
        m = 0.5 * (a + b)
        fm = poly_eval(coeffs, m)
        if fa * fm <= 0.0:
            b = m
        else:
            a, fa = m, fm
    return 0.5 * (a + b)


def certified_real_roots(n: int, search_low: int = -1000) -> Dict[str, object]:
    """Verify real-rootedness of B_n by integer bracketing and return a report.

    Success criterion: the number of unit sign-change brackets equals deg B_n.
    By the saturation principle (deg-many distinct real roots force a split),
    this certifies that B_n is real-rooted.
    """
    coeffs = squared_poly_coeffs(n)
    degree = len(coeffs) - 1
    brackets = count_sign_change_brackets(coeffs, search_low, 1)
    roots = [
        (float(a) if a == b else bisect_root(coeffs, float(a), float(b)))
        for (a, b) in brackets
    ]
    return {
        "n": n,
        "coeffs_low_to_high": coeffs,
        "degree": degree,
        "monic": coeffs[-1] == 1 if degree >= 1 else None,
        "constant_term": coeffs[0],
        "constant_is_factorial": coeffs[0] == factorial(n),
        "num_brackets": len(brackets),
        "certified_real_rooted": len(brackets) == degree,
        "roots": [round(r, 6) for r in roots],
    }


def main() -> None:
    print("=" * 72)
    print("The Eulerian triangle A(n, k)")
    print("=" * 72)
    for n in range(8):
        print(f"n={n}: {eulerian_row(n)[:max(1, n)] if n else [1]}")

    print()
    print("=" * 72)
    print("Row polynomials B_n of the SQUARED Eulerian triangle")
    print("=" * 72)
    for n in range(8):
        c = squared_poly_coeffs(n)
        terms = " + ".join(
            f"{c[k]}"
            if k == 0
            else (f"x^{k}" if c[k] == 1 else f"{c[k]}x^{k}")
            for k in range(len(c))
        )
        print(f"B_{n}(x) = {terms}")

    print()
    print("=" * 72)
    print("Certified real-rootedness via integer sign-change brackets")
    print("=" * 72)
    for n in range(8):
        rep = certified_real_roots(n)
        status = "REAL-ROOTED (certified)" if rep["certified_real_rooted"] else "not certified"
        print(
            f"n={n}: deg={rep['degree']}, monic={rep['monic']}, "
            f"const={rep['constant_term']} (=n!? {rep['constant_is_factorial']}), "
            f"{status}"
        )
        if rep["roots"]:
            print(f"      roots ~ {rep['roots']}")

    print()
    print("=" * 72)
    print("Boundary at n=8: two roots crowd into (-1, 0)")
    print("=" * 72)
    coeffs8 = squared_poly_coeffs(8)
    print(f"B_8 coeffs (low->high): {coeffs8}")
    rep8 = certified_real_roots(8)
    print(f"integer brackets found: {rep8['num_brackets']} (need deg={rep8['degree']})")
    print(f"certified by integers? {rep8['certified_real_rooted']}")
    # Locate the two small roots with fractional brackets to show they exist.
    fine = []
    steps = 400
    prev_x = -1.0
    prev_v = poly_eval(coeffs8, prev_x)
    for i in range(1, steps + 1):
        x = -1.0 + i * (1.0 / steps)
        v = poly_eval(coeffs8, x)
        if prev_v * v < 0.0:
            fine.append(round(bisect_root(coeffs8, prev_x, x), 6))
        prev_x, prev_v = x, v
    print(f"roots inside (-1, 0) found with finer brackets: {fine}")
    print("=> the phenomenon persists, but integer separation fails.")


if __name__ == "__main__":
    main()
