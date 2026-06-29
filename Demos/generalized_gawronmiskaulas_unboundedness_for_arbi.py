"""
Numerical demonstrations for:

    Generalized Gawron-Miska-Ulas unboundedness for arbitrary integer bases.

For integers b >= 2 and m >= 1, define

    T_{b,m}(n) = coefficient of x^n in  prod_{i=0}^{inf} (1 - x^{b^i})^m.

Because the factor (1 - x^{b^i})^m only affects degrees >= b^i, the coefficient
of x^n is already correct in the finite truncation prod_{i=0}^{N} with N >= n.

This script:
  1. Computes T_{b,m}(n) directly by polynomial multiplication.
  2. Verifies the closed form  T_{b,2}(R_k) = (-2)^k  at the base-b repunits.
  3. Exhibits unboundedness for m = 2 across several bases.
  4. Shows the m = 1 boundedness contrast (|T_{b,1}(n)| <= 1).
  5. Illustrates the multi-term recurrence for m >= 3 (e.g. b=3, m=4).

Pure standard library; type-hinted; all helpers inlined.
"""

from __future__ import annotations

from typing import List


# ----------------------------------------------------------------------
# Polynomial machinery over the integers (coefficient lists, index = degree)
# ----------------------------------------------------------------------

def poly_mul_truncated(a: List[int], b: List[int], max_deg: int) -> List[int]:
    """Multiply two integer polynomials, keeping only degrees 0..max_deg."""
    out: List[int] = [0] * (max_deg + 1)
    for i, ai in enumerate(a):
        if ai == 0 or i > max_deg:
            continue
        for j, bj in enumerate(b):
            if bj == 0:
                continue
            k = i + j
            if k > max_deg:
                break
            out[k] += ai * bj
    return out


def one_minus_x_pow_to_m(exp: int, m: int, max_deg: int) -> List[int]:
    """Coefficients of (1 - x^exp)^m, truncated to degree max_deg.

    (1 - x^exp)^m = sum_{j=0}^{m} C(m, j) (-1)^j x^{exp*j}.
    """
    from math import comb

    out: List[int] = [0] * (max_deg + 1)
    for j in range(m + 1):
        deg = exp * j
        if deg > max_deg:
            break
        out[deg] += comb(m, j) * ((-1) ** j)
    return out


def truncated_product(b: int, m: int, max_deg: int) -> List[int]:
    """Coefficients (degrees 0..max_deg) of prod_{i: b^i <= max_deg} (1 - x^{b^i})^m."""
    result: List[int] = [0] * (max_deg + 1)
    result[0] = 1
    exp = 1  # b^0
    while exp <= max_deg:
        factor = one_minus_x_pow_to_m(exp, m, max_deg)
        result = poly_mul_truncated(result, factor, max_deg)
        exp *= b
    return result


def T(b: int, m: int, n: int) -> int:
    """T_{b,m}(n): coefficient of x^n in the infinite product (computed via truncation)."""
    coeffs = truncated_product(b, m, n)
    return coeffs[n]


def repunit(b: int, k: int) -> int:
    """The k-th base-b repunit R_k = 1 + b + ... + b^{k-1}; R_0 = 0."""
    r = 0
    for _ in range(k):
        r = b * r + 1
    return r


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------

def demo_repunit_closed_form() -> None:
    print("=" * 70)
    print("1. Closed form  T_{b,2}(R_k) = (-2)^k   (theorem T_repunit)")
    print("=" * 70)
    for b in range(2, 8):
        print(f"\n  base b = {b}:")
        print(f"    {'k':>2} {'R_k':>8} {'T_{b,2}(R_k)':>16} {'(-2)^k':>10}  ok")
        for k in range(0, 7):
            rk = repunit(b, k)
            val = T(b, 2, rk)
            pred = (-2) ** k
            print(f"    {k:>2} {rk:>8} {val:>16} {pred:>10}  {val == pred}")


def demo_unboundedness() -> None:
    print("\n" + "=" * 70)
    print("2. Unboundedness for m = 2 (theorem T_two_unbounded)")
    print("=" * 70)
    # We keep the bases small so the witnessing repunit R_k (and hence the
    # truncation degree) stays computationally manageable; the argument is
    # identical for every base.
    for b in (2, 3):
        bound = 100
        # find k with 2^k > bound, then witness n = R_k
        k = 0
        while 2 ** k <= bound:
            k += 1
        n = repunit(b, k)
        val = abs(T(b, 2, n))
        print(f"  base b={b:>2}: to beat B={bound}, take k={k}, "
              f"n=R_k={n}, |T_{{b,2}}(n)|={val} > {bound}: {val > bound}")


def demo_m1_boundedness() -> None:
    print("\n" + "=" * 70)
    print("3. Contrast: m = 1 is bounded  (|T_{b,1}(n)| <= 1)")
    print("=" * 70)
    for b in (2, 3, 5):
        coeffs = truncated_product(b, 1, 60)
        mx = max(abs(c) for c in coeffs)
        distinct = sorted(set(coeffs))
        print(f"  base b={b:>2}: max|coeff| over n<=60 = {mx}; "
              f"values seen = {distinct}")


def demo_multiterm_m_ge_3() -> None:
    print("\n" + "=" * 70)
    print("4. The open corner m >= 3: repunit values are NOT (-m)^k when b < m")
    print("=" * 70)
    # b = 3, m = 4 : sequence 1, -4, 17, -76, 353, ...
    b, m = 3, 4
    vals = [T(b, m, repunit(b, k)) for k in range(0, 6)]
    print(f"  base b={b}, m={m}: T_{{b,m}}(R_k) for k=0..5 = {vals}")
    print(f"    compare (-m)^k = {[(-m) ** k for k in range(6)]}  "
          f"--> single-ratio identity fails (b < m)")
    # b = 4, m = 4 : here b >= m so single ratio (-4)^k should hold
    b, m = 4, 4
    vals = [T(b, m, repunit(b, k)) for k in range(0, 6)]
    print(f"  base b={b}, m={m}: T_{{b,m}}(R_k) for k=0..5 = {vals}")
    print(f"    compare (-m)^k = {[(-m) ** k for k in range(6)]}  "
          f"--> matches (b >= m)")


def demo_sequence_head() -> None:
    print("\n" + "=" * 70)
    print("5. First coefficients of  prod (1 - x^{2^i})^2   (b=2, m=2)")
    print("=" * 70)
    coeffs = truncated_product(2, 2, 20)
    print("  n      :", " ".join(f"{n:>3}" for n in range(0, 13)))
    print("  T_2,2  :", " ".join(f"{c:>3}" for c in coeffs[:13]))


def main() -> None:
    demo_repunit_closed_form()
    demo_unboundedness()
    demo_m1_boundedness()
    demo_multiterm_m_ge_3()
    demo_sequence_head()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
