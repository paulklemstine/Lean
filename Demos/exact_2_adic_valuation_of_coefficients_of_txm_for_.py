"""Numerical demonstrations for the 2-adic valuations of the coefficients of T(x)^m.

Let T(x) = prod_{k>=0} (1 - x^{2^k}) be the Thue-Morse generating function, and
write T(x)^m = sum_n t_m(n) x^n. This script demonstrates:

  1. Two independent generators of the coefficients t_m(n) (direct convolution of
     the Thue-Morse signs, and the doubling recursion for m = 5) and their
     agreement.
  2. The refutation of the universal m = 1 (mod 4) valuation formula, with the
     smallest witness t_9(8) = 2376, nu_2 = 3 (not 6).
  3. The exact m = 5 law  nu_2(t_5(4q+j)) = 2*nu_2(q+1) + (nu_2(q+1) mod 2).
  4. The proved ground layer: t_5(n) is odd iff floor(n/4) is even.
  5. The distinct m = 9 law and the breakdown of block-constancy at m = 13.

Run:  python demo.py
"""

from __future__ import annotations

from typing import List


def thue_morse_sign(n: int) -> int:
    """The Thue-Morse sign epsilon(n) = (-1)^(number of 1 bits of n)."""
    return -1 if (bin(n).count("1") & 1) else 1


def v2(a: int) -> int:
    """2-adic valuation: largest e with 2^e | a. Returns a large sentinel for 0."""
    if a == 0:
        return 10**9
    a = abs(a)
    e = 0
    while a % 2 == 0:
        a //= 2
        e += 1
    return e


def tmpow_convolution(m: int, length: int) -> List[int]:
    """Coefficients t_m(0..length-1) of T(x)^m by m-fold Cauchy convolution.

    This is the *definitional* coefficient sequence and serves as ground truth.
    """
    coeff: List[int] = [thue_morse_sign(n) for n in range(length)]
    res: List[int] = [1] + [0] * (length - 1)  # T(x)^0 = 1
    for _ in range(m):
        new: List[int] = [0] * length
        for i in range(length):
            ri = res[i]
            if ri == 0:
                continue
            for j in range(length - i):
                new[i + j] += ri * coeff[j]
        res = new
    return res


def t5_recursion(length: int) -> List[int]:
    """Coefficients t_5(0..length-1) via the doubling recursion from
    T(x)^5 = (1-x)^5 * T(x^2)^5:

        t5(2s)   =  t5(s) + 10 t5(s-1) + 5 t5(s-2)
        t5(2s+1) = -(5 t5(s) + 10 t5(s-1) + t5(s-2)),   t5(0)=1, t5(k<0)=0.
    """
    t: List[int] = [0] * length

    def get(k: int) -> int:
        return t[k] if 0 <= k < length else 0

    if length > 0:
        t[0] = 1
    for n in range(1, length):
        s = n // 2
        if n % 2 == 0:
            t[n] = get(s) + 10 * get(s - 1) + 5 * get(s - 2)
        else:
            t[n] = -(5 * get(s) + 10 * get(s - 1) + get(s - 2))
    return t


def universal_formula(m: int, n: int) -> int:
    """The (refuted) universal prediction for nu_2(t_m((m-1)n+j))."""
    v = v2(n + 1)
    return (m - 1) * ((v + 1) // 2) - ((m - 1) // 4) * (v % 2)


def m5_law(q: int) -> int:
    """The corrected m=5 law: nu_2(t_5(4q+j)) = 2*v2(q+1) + (v2(q+1) mod 2)."""
    v = v2(q + 1)
    return 2 * v + (v % 2)


def m9_law(n: int) -> int:
    """The observed m=9 law: floor((5 v + (v mod 2)) / 2), v = v2(n+1)."""
    v = v2(n + 1)
    return (5 * v + (v % 2)) // 2


def demo_faithfulness(length: int = 40) -> None:
    print("=" * 70)
    print("1. Faithfulness: doubling recursion for m=5 == direct convolution")
    conv = tmpow_convolution(5, length)
    rec = t5_recursion(length)
    agree = all(conv[n] == rec[n] for n in range(length))
    print(f"   t5 (first 16): {rec[:16]}")
    print(f"   agree on 0 <= n < {length}: {agree}")


def demo_refutation() -> None:
    print("=" * 70)
    print("2. Refutation of the universal formula at m=9, n=1, j=0 (index 8)")
    t9 = tmpow_convolution(9, 20)
    val = t9[8]
    print(f"   t_9(8) = {val} = 2^{v2(val)} * {val // 2**v2(val)}")
    print(f"   true nu_2(t_9(8))          = {v2(val)}")
    print(f"   universal formula predicts = {universal_formula(9, 1)}")
    print(f"   => formula is FALSE (3 != 6)")


def demo_m5_law(length: int = 400) -> None:
    print("=" * 70)
    print("3. The exact m=5 law  nu_2(t_5(4q+j)) = 2 v2(q+1) + (v2(q+1) mod 2)")
    t5 = t5_recursion(length)
    ok = True
    for q in range(length // 4):
        pred = m5_law(q)
        for j in range(4):
            idx = 4 * q + j
            if idx < length and v2(t5[idx]) != pred:
                ok = False
    print(f"   verified for all blocks with 4q+3 < {length}: {ok}")
    print("   sample (q, predicted nu_2, actual nu_2 across j=0..3):")
    for q in [0, 1, 2, 3, 4, 7, 15]:
        actual = [v2(t5[4 * q + j]) for j in range(4)]
        print(f"     q={q:2d}  pred={m5_law(q)}  actual={actual}")


def demo_ground_layer(length: int = 400) -> None:
    print("=" * 70)
    print("4. Proved ground layer: t_5(n) is odd  <=>  floor(n/4) is even")
    t5 = t5_recursion(length)
    ok = all((t5[n] % 2 == 1) == ((n // 4) % 2 == 0) for n in range(length))
    print(f"   verified for 0 <= n < {length}: {ok}")
    print(f"   parities of t5(0..15): {[t5[n] & 1 for n in range(16)]}")


def demo_m9_and_m13(length: int = 400) -> None:
    print("=" * 70)
    print("5. Distinct m=9 law, and breakdown of block-constancy at m=13")
    t9 = tmpow_convolution(9, length)
    ok9 = True
    for n in range(length // 8):
        pred = m9_law(n)
        for j in range(8):
            idx = 8 * n + j
            if idx < length and v2(t9[idx]) != pred:
                ok9 = False
    print(f"   m=9 law floor((5v+(v mod 2))/2) holds: {ok9}")
    t13 = tmpow_convolution(13, length)
    print("   m=13 valuations across the 12 offsets (NOT constant):")
    for n in [1, 2, 3]:
        vals = [v2(t13[12 * n + j]) for j in range(12)]
        print(f"     n={n}: {vals}")


def main() -> None:
    demo_faithfulness()
    demo_refutation()
    demo_m5_law()
    demo_ground_layer()
    demo_m9_and_m13()
    print("=" * 70)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
