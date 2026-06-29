"""
Numerical demonstrations for:

    Inverse Sprugnoli Arrays with Closed-Form Coefficients,
    and the Odd-Indexed Fibonacci Row Sums of  C(n+k, 2k).

The Sprugnoli / Riordan array is

    T[n][k] = C(n + k, 2k),          array (1/(1-x), x/(1-x)^2).

This script verifies, with exact integer / rational arithmetic:

  1.  The closed-form inverse  S[n][k] = (-1)^(n+k) * (2k+1)/(2n+1) * C(2n+1, n-k)
      (the signed ballot numbers; first column = signed Catalan numbers).
  2.  Two-sided orthogonality  T*S = S*T = I  (Theorem `s_rec`-companion / inverse).
  3.  The crux signed Vandermonde identity
          sum_i (-1)^i C(p+i, i) C(p, m-i) = (-1)^m.
  4.  The row-sum recurrence  s(n+2) = 3 s(n+1) - s(n)   (lemma `s_rec`).
  5.  The generating function  G(x) = (1-x)/(1-3x+x^2)   (lemma `genfun_closed`).
  6.  The Fibonacci identification  s(n) = F(2n+1)        (lemma `s_eq_fib`).

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import List


# --------------------------------------------------------------------------
# 1. The array T and its closed-form inverse S
# --------------------------------------------------------------------------
def T(n: int, k: int) -> int:
    """Entry of the Sprugnoli array (1/(1-x), x/(1-x)^2):  C(n+k, 2k)."""
    if 0 <= k <= n:
        return comb(n + k, 2 * k)
    return 0


def S(n: int, k: int) -> Fraction:
    """Closed-form inverse entry: signed ballot number
       (-1)^(n+k) * (2k+1)/(2n+1) * C(2n+1, n-k)."""
    if 0 <= k <= n:
        sign = -1 if (n + k) % 2 else 1
        return sign * Fraction((2 * k + 1) * comb(2 * n + 1, n - k), 2 * n + 1)
    return Fraction(0)


def catalan(n: int) -> int:
    """Catalan number C_n = C(2n,n)/(n+1)."""
    return comb(2 * n, n) // (n + 1)


# --------------------------------------------------------------------------
# 2. Row sums and the recurrence / Fibonacci
# --------------------------------------------------------------------------
def s_direct(n: int) -> int:
    """Row sum s(n) = sum_{k=0}^n C(n+k, 2k)."""
    return sum(T(n, k) for k in range(n + 1))


def s_recurrence(n_max: int) -> List[int]:
    """Row sums via s(n+2) = 3 s(n+1) - s(n), s0=1, s1=2  (O(n))."""
    s = [1, 2]
    while len(s) <= n_max:
        s.append(3 * s[-1] - s[-2])
    return s[: n_max + 1]


def fib(n: int) -> int:
    """Fibonacci via fast doubling, F0=0, F1=1."""
    def _fd(m: int) -> tuple[int, int]:
        if m == 0:
            return (0, 1)
        a, b = _fd(m >> 1)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if (m & 1) else (c, d)
    return _fd(n)[0]


# --------------------------------------------------------------------------
# 3. Generating function coefficients of (1-x)/(1-3x+x^2)
# --------------------------------------------------------------------------
def gf_coeffs(n_max: int) -> List[int]:
    """Power-series coefficients of (1-x) * (1-3x+x^2)^{-1}."""
    a = [0] * (n_max + 1)          # numerator 1 - x
    a[0] = 1
    if n_max >= 1:
        a[1] = -1
    # denom = 1 - 3x + x^2 has constant term 1; convolution recurrence
    g = [0] * (n_max + 1)
    for n in range(n_max + 1):
        acc = a[n]
        if n >= 1:
            acc -= -3 * g[n - 1]
        if n >= 2:
            acc -= 1 * g[n - 2]
        g[n] = acc
    return g


# --------------------------------------------------------------------------
# Verifications
# --------------------------------------------------------------------------
def verify_orthogonality(N: int) -> bool:
    """Check T*S = I and S*T = I for indices < N."""
    for n in range(N):
        for m in range(N):
            ts = sum(T(n, j) * S(j, m) for j in range(N))
            st = sum(S(n, j) * T(j, m) for j in range(N))
            expected = Fraction(1 if n == m else 0)
            if ts != expected or st != expected:
                return False
    return True


def verify_vandermonde(P: int, M: int) -> bool:
    """sum_i (-1)^i C(p+i,i) C(p,m-i) = (-1)^m."""
    for p in range(P):
        for m in range(p + 1):
            total = sum((-1) ** i * comb(p + i, i) * comb(p, m - i)
                        for i in range(m + 1))
            if total != (-1) ** m:
                return False
    return True


def main() -> None:
    N = 13

    print("=" * 64)
    print("Sprugnoli array  T[n][k] = C(n+k, 2k)")
    print("=" * 64)
    for n in range(7):
        print(f"  n={n}: {[T(n, k) for k in range(n + 1)]}")

    print("\nClosed-form inverse  S[n][k] = (-1)^(n+k)(2k+1)/(2n+1) C(2n+1,n-k)")
    for n in range(7):
        print(f"  n={n}: {[int(S(n, k)) for k in range(n + 1)]}")

    print("\nFirst column of S vs signed Catalan numbers:")
    print("  S[n][0] :", [int(S(n, 0)) for n in range(8)])
    print("  (-1)^n C_n:", [(-1) ** n * catalan(n) for n in range(8)])

    print("\n[Check] every S[n][k] is an integer:",
          all(S(n, k).denominator == 1 for n in range(N) for k in range(N)))
    print("[Check] two-sided orthogonality T*S = S*T = I:",
          verify_orthogonality(N))
    print("[Check] signed Vandermonde sum_i (-1)^i C(p+i,i)C(p,m-i)=(-1)^m:",
          verify_vandermonde(N, N))

    print("\nAlternating row sums of S vs (-1)^n C(2n,n):")
    print("  alt sum :", [int(sum((-1) ** k * S(n, k) for k in range(n + 1)))
                          for n in range(8)])
    print("  (-1)^nC :", [(-1) ** n * comb(2 * n, n) for n in range(8)])

    print("\n" + "=" * 64)
    print("Row sums  s(n) = sum_k C(n+k, 2k)")
    print("=" * 64)
    direct = [s_direct(n) for n in range(N)]
    rec = s_recurrence(N - 1)
    gf = gf_coeffs(N - 1)
    fibs = [fib(2 * n + 1) for n in range(N)]
    print("  direct sum   :", direct)
    print("  recurrence   :", rec, "   (s(n+2)=3s(n+1)-s(n))")
    print("  gen. function:", gf, "   ((1-x)/(1-3x+x^2))")
    print("  F(2n+1)      :", fibs)
    print("\n[Check] all four agree:",
          direct == rec == gf == fibs)


if __name__ == "__main__":
    main()
