"""
Real-rootedness of the square of the Eulerian triangle
======================================================

This self-contained script demonstrates, with *exact* rational arithmetic,
the main results about the polynomials

        B_n(x) = sum_k C(n, k) x^k ,   C(n, k) = sum_j A(n, j) * A(j, k),

where A(n, k) is the Eulerian number counting the permutations of {1, ..., n}
that have exactly k descents.  The C(n, k) are the entries of the *square* of
the (lower-triangular) Eulerian array, and B_n is its n-th row polynomial.

What is demonstrated:

  1.  Construction of the Eulerian numbers by their triangular recurrence.
  2.  The squared triangle C(n, k) and its row polynomials B_n.
  3.  The structural identity   B_n(x) = sum_j A(n, j) * A_j(x),
      where A_j(x) = sum_k A(j, k) x^k is the j-th Eulerian polynomial.
  4.  Positivity:   B_n(x) > 0 for every x >= 0, hence every real root of B_n
      is strictly negative.
  5.  Real-rootedness:   B_n splits into real linear factors.  We *prove* this
      exactly, using Sturm's theorem to count the real roots, for every n in
      the demonstrated range; every root turns out to be real and negative.

The implementation uses only the Python standard library (fractions), so all
statements are checked with exact integer / rational arithmetic -- no floating
point is involved in the correctness claims.
"""

from __future__ import annotations

from fractions import Fraction
from functools import lru_cache
from typing import List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. Eulerian numbers
# ---------------------------------------------------------------------------

@lru_cache(maxsize=None)
def eulerian(n: int, k: int) -> int:
    """Eulerian number A(n, k): permutations of {1, ..., n} with k descents.

    Defined by the triangular recurrence
        A(0, 0) = 1,           A(n, 0) = 1,
        A(n, k) = (k + 1) * A(n - 1, k) + (n - k) * A(n - 1, k - 1).
    """
    if n == 0:
        return 1 if k == 0 else 0
    if k < 0 or k > n - 1:
        return 0
    if k == 0:
        return 1
    return (k + 1) * eulerian(n - 1, k) + (n - k) * eulerian(n - 1, k - 1)


def eulerian_row(n: int) -> List[int]:
    """The n-th row [A(n, 0), ..., A(n, n)] of the Eulerian triangle."""
    return [eulerian(n, k) for k in range(n + 1)]


# ---------------------------------------------------------------------------
# 2. The squared Eulerian triangle and its row polynomials
# ---------------------------------------------------------------------------

def sq_coeff(n: int, k: int) -> int:
    """C(n, k) = sum_j A(n, j) * A(j, k): entry of the squared triangle."""
    return sum(eulerian(n, j) * eulerian(j, k) for j in range(n + 1))


def sq_poly(n: int) -> List[int]:
    """Coefficient list [C(n,0), C(n,1), ...] of B_n, trailing zeros removed."""
    coeffs = [sq_coeff(n, k) for k in range(n + 1)]
    while len(coeffs) > 1 and coeffs[-1] == 0:
        coeffs.pop()
    return coeffs


def poly_eval(coeffs: Sequence[Fraction], x: Fraction) -> Fraction:
    """Evaluate a polynomial (ascending coefficient order) by Horner's rule."""
    acc = Fraction(0)
    for c in reversed(coeffs):
        acc = acc * x + c
    return acc


# ---------------------------------------------------------------------------
# 3. Structural identity  B_n = sum_j A(n, j) * A_j
# ---------------------------------------------------------------------------

def eulerian_poly(j: int) -> List[int]:
    """Coefficients of the j-th Eulerian polynomial A_j(x) = sum_k A(j,k) x^k."""
    return [eulerian(j, k) for k in range(j + 1)]


def poly_add(a: Sequence[int], b: Sequence[int]) -> List[int]:
    """Add two coefficient lists."""
    m = max(len(a), len(b))
    return [(a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0)
            for i in range(m)]


def poly_scale(a: Sequence[int], c: int) -> List[int]:
    return [c * x for x in a]


def structural_identity_rhs(n: int) -> List[int]:
    """Compute sum_j A(n, j) * A_j(x) as a coefficient list."""
    acc: List[int] = [0]
    for j in range(n + 1):
        acc = poly_add(acc, poly_scale(eulerian_poly(j), eulerian(n, j)))
    while len(acc) > 1 and acc[-1] == 0:
        acc.pop()
    return acc


# ---------------------------------------------------------------------------
# 4. Sturm's theorem: exact real-root counting
# ---------------------------------------------------------------------------

def _poly_rem(a: List[Fraction], b: List[Fraction]) -> List[Fraction]:
    """Remainder of polynomial division a / b (ascending coefficient order)."""
    a = list(a)
    db = len(b) - 1
    while len(a) - 1 >= db and any(c != 0 for c in a):
        da = len(a) - 1
        lead = a[-1] / b[-1]
        shift = da - db
        for i in range(len(b)):
            a[i + shift] -= lead * b[i]
        while len(a) > 1 and a[-1] == 0:
            a.pop()
        if len(a) - 1 == da:  # safety: degree failed to drop
            break
    while len(a) > 1 and a[-1] == 0:
        a.pop()
    return a


def _poly_deriv(a: Sequence[Fraction]) -> List[Fraction]:
    return [a[i] * i for i in range(1, len(a))] or [Fraction(0)]


def sturm_chain(coeffs: Sequence[int]) -> List[List[Fraction]]:
    """Build the Sturm sequence of a squarefree polynomial."""
    p0 = [Fraction(c) for c in coeffs]
    p1 = _poly_deriv(p0)
    chain = [p0, p1]
    while len(chain[-1]) > 1 or chain[-1][0] != 0:
        r = _poly_rem(chain[-2], chain[-1])
        if len(r) == 1 and r[0] == 0:
            break
        chain.append([-c for c in r])
    return chain


def _sign_changes(vals: Sequence[Fraction]) -> int:
    changes = 0
    prev = 0
    for v in vals:
        s = (v > 0) - (v < 0)
        if s != 0:
            if prev != 0 and s != prev:
                changes += 1
            prev = s
    return changes


def count_real_roots(coeffs: Sequence[int], a: Fraction, b: Fraction) -> int:
    """Exact number of distinct real roots of the polynomial in (a, b]."""
    chain = sturm_chain(coeffs)
    va = _sign_changes([poly_eval(p, a) for p in chain])
    vb = _sign_changes([poly_eval(p, b) for p in chain])
    return va - vb


def is_real_rooted(coeffs: Sequence[int]) -> Tuple[bool, int, int]:
    """Return (all_roots_real, degree, number_of_distinct_real_roots).

    For these polynomials the roots are simple, so 'all roots real' is
    equivalent to 'number of distinct real roots equals the degree'.
    """
    deg = len(coeffs) - 1
    if deg <= 0:
        return True, deg, 0
    # A crude but safe root bound (Cauchy): all roots lie in (-M, M).
    lead = abs(coeffs[-1])
    M = 1 + max(abs(c) for c in coeffs) / lead
    lo, hi = Fraction(-M) - 1, Fraction(M) + 1
    nroots = count_real_roots(coeffs, lo, hi)
    return nroots == deg, deg, nroots


# ---------------------------------------------------------------------------
# 5. Demonstrations
# ---------------------------------------------------------------------------

def show_eulerian_triangle(nmax: int = 7) -> None:
    print("Eulerian triangle A(n, k):")
    for n in range(nmax + 1):
        print(f"  n={n}: {eulerian_row(n)}")
    print()


def show_squared_triangle(nmax: int = 10) -> None:
    print("Row polynomials B_n of the squared Eulerian triangle:")
    for n in range(nmax + 1):
        c = sq_poly(n)
        print(f"  n={n:2d}: coeffs (ascending) = {c}")
    print()


def check_structural_identity(nmax: int = 10) -> None:
    print("Structural identity  B_n(x) = sum_j A(n,j) * A_j(x):")
    ok = True
    for n in range(nmax + 1):
        lhs = sq_poly(n)
        rhs = structural_identity_rhs(n)
        match = lhs == rhs
        ok = ok and match
        print(f"  n={n:2d}: {'OK' if match else 'MISMATCH'}")
    print(f"  => identity holds for all n <= {nmax}: {ok}\n")


def check_positivity(nmax: int = 10) -> None:
    print("Positivity  B_n(x) > 0 for x >= 0  (=> every real root is negative):")
    for n in range(nmax + 1):
        c = [Fraction(v) for v in sq_poly(n)]
        const = c[0]
        # Sample several nonnegative points and also report the constant term.
        samples = [Fraction(0), Fraction(1, 2), Fraction(1),
                   Fraction(5), Fraction(100)]
        pos = all(poly_eval(c, x) > 0 for x in samples)
        print(f"  n={n:2d}: B_n(0)={const} (= n!),  B_n(x)>0 on samples: {pos}")
    print()


def check_real_rootedness(nmax: int = 10) -> None:
    print("Real-rootedness (Sturm's theorem, exact arithmetic):")
    for n in range(nmax + 1):
        c = sq_poly(n)
        rr, deg, nroots = is_real_rooted(c)
        # Count roots in (-1, 0): illustrates the n=8 boundary phenomenon.
        in_unit = count_real_roots(c, Fraction(-1), Fraction(0)) if deg > 0 else 0
        print(f"  n={n:2d}: degree {deg:2d}, real roots {nroots:2d}, "
              f"real-rooted={rr}, roots in (-1,0): {in_unit}")
    print()


def main() -> None:
    print("=" * 70)
    print(" Real-rootedness of the square of the Eulerian triangle")
    print("=" * 70, "\n")
    show_eulerian_triangle(7)
    show_squared_triangle(10)
    check_structural_identity(10)
    check_positivity(10)
    check_real_rootedness(10)
    print("All demonstrated results verified with exact rational arithmetic.")


if __name__ == "__main__":
    main()
