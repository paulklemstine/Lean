"""
Deep Holes of Binary Lattices — numerical companion
===================================================

Exact rational demonstrations of the rank-two packing/covering theory of a
positive-definite binary quadratic form

        Q(x, y) = a x^2 + b x y + c y^2,    0 <= b <= a <= c   (reduced),

acting on the lattice L = Z^2.  All arithmetic is exact (fractions.Fraction),
all functions are self-contained and type-hinted.

What is demonstrated
--------------------
1.  Gauss reduction: every positive-definite integral binary form is
    equivalent to a reduced one, and then a = lambda_1 is the homogeneous
    minimum (shortest nonzero lattice energy).
2.  The covering weight enumerator W(Q) = {0, a, c, a + c - b}: the multiset
    of four times the coset minima of Q on the four classes of L/2L.
3.  W determines (a, |b|, c), hence is a complete isometry invariant in
    rank two.
4.  The exact covering radius squared

        mu(Q) = a c (a - b + c) / (4 a c - b^2),

    attained at the deep hole (circumcentre of the Delaunay triangle
    {0, e1, e2})

        h = ( c(2a - b)/D , a(2c - b)/D ),      D = 4 a c - b^2,

    checked against exhaustive search over lattice points and a fine grid
    of shifts.
5.  The quantitative strictness identity mu - lambda_1/4 = a (2c - b)^2 / (4 D),
    the rectangularity criterion (a 2-torsion shift is a deepest hole iff
    b = 0), and the sharp packing/covering inequality mu >= lambda_1 / 3 with
    equality exactly for the hexagonal form a(x^2 + x y + y^2).
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Dict, Iterable, List, Sequence, Tuple

Rat = Fraction
Triple = Tuple[Rat, Rat, Rat]


# ----------------------------------------------------------------------
# 1.  The form, its reduction, and its homogeneous minimum
# ----------------------------------------------------------------------

def bq(a: Rat, b: Rat, c: Rat, x: Rat, y: Rat) -> Rat:
    """Value a x^2 + b x y + c y^2 of the binary form at (x, y)."""
    return a * x * x + b * x * y + c * y * y


def is_reduced(a: Rat, b: Rat, c: Rat) -> bool:
    """Reduction domain 0 < a, |b| <= a <= c (we normalise to 0 <= b)."""
    return a > 0 and abs(b) <= a <= c


def discriminant(a: Rat, b: Rat, c: Rat) -> Rat:
    """D = 4ac - b^2 = 4 det(Gram).  Positive exactly for definite forms."""
    return 4 * a * c - b * b


def gauss_reduce(a: Rat, b: Rat, c: Rat) -> Triple:
    """Gauss reduction: return an equivalent reduced triple with 0 <= b <= a <= c.

    Each step is a change of lattice basis (an element of GL_2(Z)):
    swapping a and c is (x, y) -> (y, x); the shear replaces the second
    basis vector by w + k v.  Terminates because a + c strictly decreases.
    """
    a, b, c = Rat(a), Rat(b), Rat(c)
    while True:
        if c < a:
            a, c = c, a
        if abs(b) > a:
            # shear the second basis vector: b -> b + 2 k a, c -> Q(w + k v)
            k = -round(Fraction(b, 2 * a))
            c = a * k * k + b * k + c
            b = b + 2 * k * a
            continue
        break
    if b < 0:  # sign flip y -> -y, an isometry of Z^2
        b = -b
    return a, b, c


def homogeneous_minimum(a: Rat, b: Rat, c: Rat, bound: int = 8) -> Rat:
    """lambda_1 = min over nonzero integer points of Q.  Exhaustive search."""
    best: Rat | None = None
    for p, q in product(range(-bound, bound + 1), repeat=2):
        if p == 0 and q == 0:
            continue
        v = bq(a, b, c, Rat(p), Rat(q))
        if best is None or v < best:
            best = v
    assert best is not None
    return best


# ----------------------------------------------------------------------
# 2.  Coset minima and the covering weight enumerator
# ----------------------------------------------------------------------

def coset_minimum(a: Rat, b: Rat, c: Rat, v: Tuple[int, int], bound: int = 8) -> Rat:
    """min { Q(u) : u in v + 2 L }, the coset minimum of the class of v in L/2L."""
    best: Rat | None = None
    for p, q in product(range(-bound, bound + 1), repeat=2):
        x, y = v[0] + 2 * p, v[1] + 2 * q
        val = bq(a, b, c, Rat(x), Rat(y))
        if best is None or val < best:
            best = val
    assert best is not None
    return best


def cover_enumerator_bruteforce(a: Rat, b: Rat, c: Rat, bound: int = 8) -> List[Rat]:
    """The multiset {4 * mu(v/2) : v in L/2L} obtained by exhaustive search."""
    return sorted(coset_minimum(a, b, c, v, bound) for v in [(0, 0), (1, 0), (0, 1), (1, 1)])


def cover_enumerator_formula(a: Rat, b: Rat, c: Rat) -> List[Rat]:
    """The closed form W(Q) = {0, a, c, a + c - |b|} for a reduced triple."""
    return sorted([Rat(0), a, c, a + c - abs(b)])


def recover_triple(w: Sequence[Rat]) -> Triple:
    """Recover (a, |b|, c) from the enumerator, using only min, max and the sum.

    a   = smallest nonzero entry
    M   = largest entry = a + c - |b|
    S   = sum of entries = 2a + 2c - |b|
    hence c = S - M - a and |b| = a + c - M.
    """
    entries = list(w)
    a = min(x for x in entries if x != 0)
    biggest = max(entries)
    total = sum(entries, Rat(0))
    c = total - biggest - a
    babs = a + c - biggest
    return a, babs, c


# ----------------------------------------------------------------------
# 3.  The deep hole and the exact covering radius
# ----------------------------------------------------------------------

def deep_hole(a: Rat, b: Rat, c: Rat) -> Tuple[Rat, Rat]:
    """Circumcentre of the Delaunay triangle {0, e1, e2}, in basis coordinates."""
    d = discriminant(a, b, c)
    return (c * (2 * a - b) / d, a * (2 * c - b) / d)


def cover_radius_formula(a: Rat, b: Rat, c: Rat) -> Rat:
    """mu(Q) = a c (a - b + c) / (4 a c - b^2), the covering radius squared."""
    return a * c * (a - b + c) / discriminant(a, b, c)


def gap(a: Rat, b: Rat, c: Rat, t: Tuple[Rat, Rat], bound: int = 6) -> Rat:
    """mu(t) = min over lattice points m of Q(t - m):  squared distance to L."""
    best: Rat | None = None
    for p, q in product(range(-bound, bound + 1), repeat=2):
        val = bq(a, b, c, t[0] - p, t[1] - q)
        if best is None or val < best:
            best = val
    assert best is not None
    return best


def cover_radius_grid(a: Rat, b: Rat, c: Rat, n: int = 24) -> Rat:
    """Largest gap over an n x n grid of shifts in the unit cell (a lower bound)."""
    best = Rat(0)
    for i, j in product(range(n), repeat=2):
        t = (Rat(i, n), Rat(j, n))
        best = max(best, gap(a, b, c, t))
    return best


# ----------------------------------------------------------------------
# 4.  Reporting
# ----------------------------------------------------------------------

TEST_FORMS: List[Tuple[int, int, int]] = [
    (1, 0, 1),    # square lattice Z^2
    (1, 1, 1),    # hexagonal lattice A_2
    (2, 1, 3),
    (1, 0, 5),
    (3, 2, 7),
    (5, 4, 9),
    (2, 2, 3),
    (1, 1, 2),
    (3, 3, 3),    # hexagonal, scaled by 3
]


def report_form(a0: int, b0: int, c0: int) -> Dict[str, object]:
    """Full exact report for one integral binary form."""
    a, b, c = gauss_reduce(Rat(a0), Rat(b0), Rat(c0))
    lam = homogeneous_minimum(a, b, c)
    w_formula = cover_enumerator_formula(a, b, c)
    w_brute = cover_enumerator_bruteforce(a, b, c)
    mu = cover_radius_formula(a, b, c)
    h = deep_hole(a, b, c)
    hole_gap = gap(a, b, c, h)
    grid = cover_radius_grid(a, b, c)
    return {
        "input": (a0, b0, c0),
        "reduced": (a, b, c),
        "lambda1": lam,
        "W_formula": w_formula,
        "W_bruteforce": w_brute,
        "deep_hole": h,
        "mu_formula": mu,
        "mu_at_deep_hole": hole_gap,
        "mu_grid_lower_bound": grid,
        "mu_minus_quarter": mu - lam / 4,
        "identity_rhs": a * (2 * c - b) ** 2 / (4 * discriminant(a, b, c)),
        "two_torsion_top": (a - b + c) / 4,
        "rectangular": b == 0,
        "mu_over_lambda1": mu / lam,
    }


def fmt(x: object) -> str:
    if isinstance(x, Fraction):
        return str(x) if x.denominator != 1 else str(x.numerator)
    if isinstance(x, (list, tuple)):
        return "(" + ", ".join(fmt(y) for y in x) + ")"
    return str(x)


def main() -> None:
    print("=" * 78)
    print("DEEP HOLES OF BINARY LATTICES — exact rational demonstrations")
    print("=" * 78)

    for a0, b0, c0 in TEST_FORMS:
        r = report_form(a0, b0, c0)
        a, b, c = r["reduced"]  # type: ignore[misc]
        print()
        print(f"Form  {a0}x^2 + {b0}xy + {c0}y^2   ->  reduced (a,b,c) = {fmt(r['reduced'])}")
        print(f"  homogeneous minimum  lambda_1 = {fmt(r['lambda1'])}   (equals a: "
              f"{r['lambda1'] == a})")
        print(f"  covering weight enumerator  W = {fmt(r['W_formula'])}")
        print(f"     brute-force coset minima  = {fmt(r['W_bruteforce'])}   "
              f"match: {r['W_formula'] == r['W_bruteforce']}")
        rec = recover_triple(r["W_formula"])  # type: ignore[arg-type]
        print(f"     (a,|b|,c) recovered from W = {fmt(rec)}   "
              f"match: {rec == (a, abs(b), c)}")
        print(f"  deep hole  h = {fmt(r['deep_hole'])}")
        print(f"  covering radius^2  mu = {fmt(r['mu_formula'])}"
              f"   gap at h = {fmt(r['mu_at_deep_hole'])}   "
              f"match: {r['mu_formula'] == r['mu_at_deep_hole']}")
        print(f"     grid maximum (lower bound) = {fmt(r['mu_grid_lower_bound'])}   "
              f"<= mu: {r['mu_grid_lower_bound'] <= r['mu_formula']}")
        print(f"  mu - lambda_1/4 = {fmt(r['mu_minus_quarter'])} = a(2c-b)^2/(4D) = "
              f"{fmt(r['identity_rhs'])}   "
              f"match: {r['mu_minus_quarter'] == r['identity_rhs']}")
        print(f"  top 2-torsion value (a-b+c)/4 = {fmt(r['two_torsion_top'])}   "
              f"equals mu: {r['two_torsion_top'] == r['mu_formula']}   "
              f"rectangular (b=0): {r['rectangular']}")
        print(f"  mu / lambda_1 = {fmt(r['mu_over_lambda1'])}   "
              f">= 1/3: {r['mu_over_lambda1'] >= Rat(1, 3)}   "
              f"equality: {r['mu_over_lambda1'] == Rat(1, 3)}")

    print()
    print("-" * 78)
    print("Sharp packing/covering constant in rank two:  min over lattices of mu/lambda_1")
    print("-" * 78)
    worst: Tuple[Rat, Triple] | None = None
    for a in range(1, 7):
        for b in range(0, a + 1):
            for c in range(a, 13):
                A, B, C = Rat(a), Rat(b), Rat(c)
                ratio = cover_radius_formula(A, B, C) / A
                if worst is None or ratio < worst[0]:
                    worst = (ratio, (A, B, C))
    assert worst is not None
    print(f"  minimum ratio {fmt(worst[0])} attained at (a,b,c) = {fmt(worst[1])} "
          f"(hexagonal: b = a = c is {worst[1][0] == worst[1][1] == worst[1][2]})")

    print()
    print("-" * 78)
    print("Isospectral-style check: can two inequivalent reduced forms share W?")
    print("-" * 78)
    seen: Dict[Tuple[Rat, ...], Triple] = {}
    clash = 0
    for a in range(1, 9):
        for b in range(0, a + 1):
            for c in range(a, 15):
                A, B, C = Rat(a), Rat(b), Rat(c)
                key = tuple(cover_enumerator_formula(A, B, C))
                if key in seen and seen[key] != (A, B, C):
                    clash += 1
                seen[key] = (A, B, C)
    print(f"  reduced forms scanned: {len(seen)} distinct enumerators, collisions: {clash}")
    print("  (zero collisions: the enumerator is a complete invariant in rank two)")

    print()
    print("-" * 78)
    print("The hexagonal obstruction: no 2-torsion shift is a deepest hole")
    print("-" * 78)
    A, B, C = Rat(1), Rat(1), Rat(1)
    for v in [(1, 0), (0, 1), (1, 1)]:
        t = (Rat(v[0], 2), Rat(v[1], 2))
        print(f"  half-point {fmt(t)}: gap = {fmt(gap(A, B, C, t))}  (= lambda_1/4 = 1/4)")
    third = (Rat(1, 3), Rat(1, 3))
    print(f"  third-point {fmt(third)}: gap = {fmt(gap(A, B, C, third))}  "
          f"(= mu = {fmt(cover_radius_formula(A, B, C))})")


if __name__ == "__main__":
    main()
