"""
Numerical companion to
"Head Coefficients of Monstrous Products: Stable-Range Additivity,
 Frame-Shape Formulas, and a Finite Reduction".

Everything here is exact integer arithmetic on truncated power series.
Run with:  python3 demo.py

Contents
--------
1.  Truncated integer power series arithmetic.
2.  Eta quotients attached to a frame shape, expanded two independent ways
    (direct product of factors, and the logarithmic-derivative recursion).
3.  The closed formulas for the first three head coefficients
        c(1) = a1(a1+3)/2 + a2,
        c(2) = ( b1(b1+1)(b1+2) + 6 b1 b2 + 6 b3 ) / 6,
        c(3) = ( 6 s4 + 6 b1 s3 + 3 (b1^2 + b1 + 2 b2) s2 + b1 * 6 c(2) ) / 24,
    checked against the expansions.
4.  Stable-range additivity for products of series congruent to 1 mod q^d,
    its sharpness at degree k = 2d, and the second-elementary-symmetric
    correction on the boundary.
5.  The eight balanced frame shapes 1^(-e) n^(e) with e (n - 1) = 24:
    the head columns 359, -2099, and the boundary value 35514.
6.  A 194-row demonstration of the finite reduction: the analytic
    coefficient of the Monster-sized product in degree -192 is the plain
    integer sum of the 194 head coefficients.
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------
# 1. Truncated integer power series
# ----------------------------------------------------------------------

Series = List[int]  # coefficients of q^0, q^1, ..., q^(N-1)


def ps_one(n: int) -> Series:
    """The constant series 1, truncated to n terms."""
    s = [0] * n
    s[0] = 1
    return s


def ps_mul(f: Series, g: Series, n: int) -> Series:
    """Product of two series, truncated to n terms."""
    out = [0] * n
    for i, fi in enumerate(f[:n]):
        if fi == 0:
            continue
        for j, gj in enumerate(g[: n - i]):
            if gj:
                out[i + j] += fi * gj
    return out


def ps_inv(f: Series, n: int) -> Series:
    """Inverse of a series with constant term 1, truncated to n terms."""
    assert f[0] == 1, "inversion requires constant term 1"
    out = [0] * n
    out[0] = 1
    for k in range(1, n):
        out[k] = -sum(f[j] * out[k - j] for j in range(1, k + 1) if j < len(f))
    return out


def ps_pow_int(f: Series, e: int, n: int) -> Series:
    """f ** e for an arbitrary integer exponent e (f[0] must be 1)."""
    if e < 0:
        return ps_pow_int(ps_inv(f, n), -e, n)
    out = ps_one(n)
    base = f[:n] + [0] * max(0, n - len(f))
    while e:
        if e & 1:
            out = ps_mul(out, base, n)
        base = ps_mul(base, base, n)
        e >>= 1
    return out


def one_minus_q_pow(m: int, n: int) -> Series:
    """The series 1 - q^m, truncated to n terms."""
    s = ps_one(n)
    if m < n:
        s[m] -= 1
    return s


# ----------------------------------------------------------------------
# 2. Frame shapes and eta quotients
# ----------------------------------------------------------------------

FrameShape = Dict[int, int]  # k -> a_k, finitely supported, sum k*a_k = 24


def divisors(m: int) -> List[int]:
    return [d for d in range(1, m + 1) if m % d == 0]


def div_sum(a: FrameShape, m: int) -> int:
    """b_m = sum over divisors k of m of a_k."""
    return sum(a.get(k, 0) for k in divisors(m))


def sigma_frame(a: FrameShape, r: int) -> int:
    """sigma_a(r) = sum over divisors d of r of d * b_d."""
    return sum(d * div_sum(a, d) for d in divisors(r))


def is_balanced(a: FrameShape) -> bool:
    return sum(k * v for k, v in a.items()) == 24


def eta_quotient_series(a: FrameShape, n: int) -> Series:
    """
    Expansion of q * (1 / eta_a) = prod_{m >= 1} (1 - q^m) ** (-b_m),
    truncated to n terms, computed as an explicit product of factors.
    """
    out = ps_one(n)
    for m in range(1, n):
        b = div_sum(a, m)
        if b:
            out = ps_mul(out, ps_pow_int(one_minus_q_pow(m, n), -b, n), n)
    return out


def eta_quotient_by_recursion(a: FrameShape, n: int) -> Series:
    """
    The same expansion via the Newton recursion  r c_r = sum_{k<r} c_k sigma_a(r-k),
    which follows from the logarithmic-derivative identity q F' = F * L with
    L = sum_{r >= 1} sigma_a(r) q^r.
    """
    c = [0] * n
    c[0] = 1
    for r in range(1, n):
        acc = sum(c[k] * sigma_frame(a, r - k) for k in range(r))
        assert acc % r == 0, "recursion must produce integers"
        c[r] = acc // r
    return c


# ----------------------------------------------------------------------
# 3. Closed formulas for the head coefficients
# ----------------------------------------------------------------------

def head_coeff(a: FrameShape) -> int:
    """c(1) = a_1 (a_1 + 3) / 2 + a_2, the coefficient of q^2 of the eta quotient."""
    a1, a2 = a.get(1, 0), a.get(2, 0)
    num = a1 * (a1 + 3)
    assert num % 2 == 0
    return num // 2 + a2


def second_head_coeff(a: FrameShape) -> int:
    """c(2) = ( b1(b1+1)(b1+2) + 6 b1 b2 + 6 b3 ) / 6, the coefficient of q^3."""
    b1, b2, b3 = div_sum(a, 1), div_sum(a, 2), div_sum(a, 3)
    num = b1 * (b1 + 1) * (b1 + 2) + 6 * b1 * b2 + 6 * b3
    assert num % 6 == 0
    return num // 6


def third_head_coeff(a: FrameShape) -> int:
    """c(3), the coefficient of q^4, from the degree-4 instance of the recursion."""
    b1, b2 = div_sum(a, 1), div_sum(a, 2)
    s2, s3, s4 = sigma_frame(a, 2), sigma_frame(a, 3), sigma_frame(a, 4)
    num = (
        6 * s4
        + 6 * b1 * s3
        + 3 * (b1 * b1 + b1 + 2 * b2) * s2
        + b1 * (b1 * (b1 + 1) * (b1 + 2) + 6 * b1 * b2 + 6 * div_sum(a, 3))
    )
    assert num % 24 == 0
    return num // 24


# ----------------------------------------------------------------------
# 4. Stable-range additivity
# ----------------------------------------------------------------------

def is_one_mod(f: Series, d: int) -> bool:
    """f = 1 mod q^d : constant term 1 and vanishing coefficients in 1..d-1."""
    return f[0] == 1 and all(f[j] == 0 for j in range(1, min(d, len(f))))


def prod_series(fs: Sequence[Series], n: int) -> Series:
    out = ps_one(n)
    for f in fs:
        out = ps_mul(out, f, n)
    return out


def e2(values: Sequence[int]) -> int:
    """Second elementary symmetric function, written as ((sum)^2 - sum of squares)/2."""
    s = sum(values)
    return (s * s - sum(v * v for v in values)) // 2


# ----------------------------------------------------------------------
# 5. The eight balanced frame shapes 1^(-e) n^(e)
# ----------------------------------------------------------------------

PM_DATA: List[Tuple[int, int]] = [
    (2, 24), (3, 12), (4, 8), (5, 6), (7, 4), (9, 3), (13, 2), (25, 1),
]


def pm_frame(n: int, e: int) -> FrameShape:
    """The frame shape 1^(-e) n^(e); balanced exactly when e (n - 1) = 24."""
    if n == 1:
        return {1: 0}
    return {1: -e, n: e}


# ----------------------------------------------------------------------
# 6. Laurent products (pole of order m, head coefficients)
# ----------------------------------------------------------------------

def laurent_product_head(rows: Sequence[Sequence[int]], depth: int) -> Dict[int, int]:
    """
    Given m rows c_i(0), c_i(1), ... of moonshine-normalized coefficients
    (c_i(0) = 0), form T_i = q^{-1} + sum_{j>=0} c_i(j) q^j and return the
    Laurent coefficients of the product in degrees -m, ..., -m + depth.

    Implementation: q * T_i is an ordinary power series with constant term 1,
    so the product of the m Laurent series equals q^{-m} times the product of
    the m power series.
    """
    m = len(rows)
    n = depth + 1
    factors = []
    for row in rows:
        f = [0] * n
        f[0] = 1
        for j in range(1, n):
            f[j] = row[j - 1] if j - 1 < len(row) else 0
        factors.append(f)
    p = prod_series(factors, n)
    return {-m + k: p[k] for k in range(n)}


# ----------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------

def banner(text: str) -> None:
    print()
    print("=" * 72)
    print(text)
    print("=" * 72)


def demo_frame_shapes() -> None:
    banner("1. The eight balanced frame shapes 1^(-e) n^(e) with e (n-1) = 24")
    print(f"{'n':>3} {'e':>3} | {'c0':>3} {'c1':>5} {'c2':>6} {'c3':>7} {'c4':>7}"
          "   (coefficients of q*(1/eta))")
    col1, col2, col3 = [], [], []
    for n, e in PM_DATA:
        a = pm_frame(n, e)
        assert is_balanced(a), "frame shape must be balanced"
        s = eta_quotient_series(a, 5)
        r = eta_quotient_by_recursion(a, 5)
        assert s == r, "product expansion and recursion must agree"
        assert s[2] == head_coeff(a)
        assert s[3] == second_head_coeff(a)
        assert s[4] == third_head_coeff(a)
        col1.append(s[2])
        col2.append(s[3])
        col3.append(s[4])
        print(f"{n:>3} {e:>3} | {s[0]:>3} {s[1]:>5} {s[2]:>6} {s[3]:>7} {s[4]:>7}")
    print()
    print(f"  head column   c(1): {col1}   sum = {sum(col1)}")
    print(f"  second column c(2): {col2}   sum = {sum(col2)}")
    print(f"  third column  c(3): {col3}   sum = {sum(col3)}")
    print(f"  sum of squares of the head column: {sum(v * v for v in col1)}")
    assert sum(col1) == 359 and sum(col2) == -2099 and sum(col3) == 10863
    assert sum(v * v for v in col1) == 79579


def demo_closed_formula() -> None:
    banner("2. The closed formula c(1) = a1(a1+3)/2 + a2 on random balanced shapes")
    shapes: List[FrameShape] = [
        {1: -24, 2: 24}, {1: 4, 2: 4, 3: 4}, {1: -2, 2: 1, 3: 8},
        {1: 12, 2: -6, 4: 6}, {1: 0, 3: 8}, {1: 6, 2: -3, 3: 8},
    ]
    print(f"{'frame shape':>28} | {'a1':>4} {'a2':>4} | {'formula':>9} {'expansion':>10}")
    for a in shapes:
        s = eta_quotient_series(a, 3)
        shape_txt = " ".join(f"{k}^({v})" for k, v in sorted(a.items()) if v)
        print(f"{shape_txt:>28} | {a.get(1,0):>4} {a.get(2,0):>4} |"
              f" {head_coeff(a):>9} {s[2]:>10}")
        assert head_coeff(a) == s[2]
    print("\n  all agree.")


def demo_stable_range() -> None:
    banner("3. Stable-range additivity, and its sharpness at k = 2d")
    d, n = 3, 9
    fs = [
        [1, 0, 0, 2, -1, 5, 3, 0, 1],
        [1, 0, 0, -4, 7, 0, 2, 1, 0],
        [1, 0, 0, 11, 0, -2, 0, 4, 6],
    ]
    for f in fs:
        assert is_one_mod(f, d)
    p = prod_series(fs, n)
    print(f"  three series congruent to 1 mod q^{d}; additivity must hold for k < {2*d}")
    for k in range(1, n):
        summed = sum(f[k] for f in fs)
        mark = "additive" if p[k] == summed else "CORRECTED"
        print(f"    k = {k}: coeff of product = {p[k]:>6},"
              f"  sum of coefficients = {summed:>6}   [{mark}]")
    for k in range(1, 2 * d):
        assert p[k] == sum(f[k] for f in fs)
    print()
    print("  boundary degree k = 2d = 6: correction is the second elementary")
    print("  symmetric function of the degree-d coefficients:")
    corr = e2([f[d] for f in fs])
    print(f"    e2(c_i(d)) = {corr},  sum + e2 = {sum(f[2*d] for f in fs) + corr},"
          f"  product coefficient = {p[2 * d]}")
    assert p[2 * d] == sum(f[2 * d] for f in fs) + corr

    print()
    print("  sharpness: f = g = 1 + q^2 are congruent to 1 mod q^2, yet")
    f = [1, 0, 1, 0, 0]
    prod = ps_mul(f, f, 5)
    print(f"    coeff_4(f*g) = {prod[4]} but coeff_4 f + coeff_4 g = {f[4] + f[4]}")
    assert prod[4] == 1 and f[4] + f[4] == 0


def demo_eight_fold_product() -> None:
    banner("4. The eight-fold product of the eta-quotient classes")
    rows = []
    for n, e in PM_DATA:
        a = pm_frame(n, e)
        s = eta_quotient_series(a, 6)
        # moonshine normalization: T = q^{-1} + 0 + c(1) q + c(2) q^2 + ...
        rows.append([0] + s[2:])
    head = laurent_product_head(rows, depth=5)
    for deg in sorted(head):
        print(f"    coefficient in degree {deg:>3} : {head[deg]}")
    print()
    print("  predicted by the reduction:")
    c1 = [r[1] for r in rows]
    c3 = [r[3] for r in rows]
    print("    degree -8 (pole)        :      1")
    print("    degree -7 (subleading)  :      0                = sum of c_i(0)")
    print(f"    degree -6               : {sum(c1):>6}                = sum of c_i(1)")
    print(f"    degree -5               : {sum(r[2] for r in rows):>6}"
          "                = sum of c_i(2)")
    print(f"    degree -4 (boundary)    : {sum(c3) + e2(c1):>6}"
          f"                = sum of c_i(3) + e2(c_i(1)) = {sum(c3)} + {e2(c1)}")
    assert head[-8] == 1
    assert head[-7] == 0
    assert head[-6] == sum(c1) == 359
    assert head[-5] == sum(r[2] for r in rows) == -2099
    assert head[-4] == sum(c3) + e2(c1) == 35514


def demo_monster_reduction() -> None:
    banner("5. The 194-fold reduction: analytic coefficient = finite integer sum")
    # A synthetic but structurally faithful table: 194 moonshine-normalized rows.
    # Only the property c_g(0) = 0 is used by the reduction; the head entries are
    # arbitrary integers here, since the theorem is uniform in the table.
    rows = []
    for g in range(194):
        c1 = (g * g * 7 + 13 * g - 5) % 1001 - 500
        c2 = (g * 31 + 17) % 997 - 500
        c3 = (g * g * g + 5) % 809 - 400
        rows.append([0, c1, c2, c3])
    head = laurent_product_head(rows, depth=4)
    total1 = sum(r[1] for r in rows)
    total2 = sum(r[2] for r in rows)
    total3 = sum(r[3] for r in rows)
    corr = e2([r[1] for r in rows])
    print(f"    pole order                          : 194 (coefficient of q^-194 is 1)")
    print(f"    coefficient in degree -193          : {head[-193]}  (always 0)")
    print(f"    coefficient in degree -192          : {head[-192]}")
    print(f"    sum of the 194 head values c_g(1)   : {total1}")
    print(f"    coefficient in degree -191          : {head[-191]}")
    print(f"    sum of the 194 values c_g(2)        : {total2}")
    print(f"    coefficient in degree -190          : {head[-190]}")
    print(f"    sum c_g(3) + e2(c_g(1))             : {total3 + corr}")
    assert head[-193] == 0
    assert head[-192] == total1
    assert head[-191] == total2
    assert head[-190] == total3 + corr
    print()
    print("  The identity in degree -192 is a statement about a product of 194")
    print("  complex Laurent series; it has collapsed to the addition of 194")
    print("  integers, hence is decidable by inspection of the table.")


def demo_bounds() -> None:
    banner("6. The uniform lower bound c(1) >= -1 for the shapes 1^(-e) n^(e)")
    print(f"{'e':>4} {'n>2: e(e-3)/2':>16} {'n=2: e(e-3)/2 + e':>20}")
    for e in range(-4, 13):
        v_general = (e * (e - 3)) // 2
        v_two = v_general + e
        flag = "" if v_general >= -1 else "  <-- violates bound"
        print(f"{e:>4} {v_general:>16} {v_two:>20}{flag}")
        assert v_general >= -1
        assert v_two >= 0
    print("\n  the bound -1 is attained exactly at e = 1 and e = 2 (n = 25, n = 13).")


def main() -> None:
    demo_frame_shapes()
    demo_closed_formula()
    demo_stable_range()
    demo_eight_fold_product()
    demo_monster_reduction()
    demo_bounds()
    print()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
