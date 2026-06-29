"""
Numerical demonstrations for "The Parity Shadow of Thue-Morse Convolution Powers".

Objects
-------
  tmsign(n) = (-1)^(popcount(n))                 Thue-Morse sign sequence
  f(x)      = sum_n tmsign(n) x^n = prod_k (1 - x^(2^k))
  t_m(n)    = [x^n] f(x)^m                        m-fold convolution coefficients

This script verifies, by direct computation, the formally proved results:

  tmsign_zmod2      : tmsign(n) is odd (== 1 mod 2)          for all n
  tconv_succ_zmod2  : t_{m+1}(n) == C(n+m, m)  (mod 2)       for all m, n
  t1_odd            : t_1(n) is odd                          for all n
  t2_parity         : t_2(n) == n + 1  (mod 2)               for all n
  t2_odd_iff_even   : t_2(n) is odd  <=>  n is even          for all n

It also illustrates the sharp m=2 Mersenne valuation law t_2(2^k - 1) = (-2)^k
that the parity shadow refines, and renders the Sierpinski (Pascal mod 2) pattern.
"""

from __future__ import annotations

from math import comb
from typing import List


def popcount(n: int) -> int:
    """Number of 1-bits in the binary expansion of n (= base-2 digit sum)."""
    return bin(n).count("1")


def tmsign(n: int) -> int:
    """Thue-Morse sign: (-1) raised to the number of binary 1-bits of n."""
    return -1 if popcount(n) & 1 else 1


def tconv(m: int, bound: int) -> List[int]:
    """
    Return [t_m(0), t_m(1), ..., t_m(bound)], the coefficients of f(x)^m.

    Implemented by iterating the defining recurrence
        t_0(n)     = [n == 0]
        t_{m+1}(n) = sum_{k=0}^{n} t_m(k) * tmsign(n - k).
    Cost: O(m * bound^2) integer operations.
    """
    signs: List[int] = [tmsign(j) for j in range(bound + 1)]
    cur: List[int] = [1] + [0] * bound  # t_0
    for _ in range(m):
        nxt: List[int] = [0] * (bound + 1)
        for n in range(bound + 1):
            nxt[n] = sum(cur[k] * signs[n - k] for k in range(n + 1))
        cur = nxt
    return cur


def nu2(value: int) -> float:
    """2-adic valuation: number of times 2 divides value; infinity for 0."""
    if value == 0:
        return float("inf")
    count = 0
    while value % 2 == 0:
        value //= 2
        count += 1
    return count


def demo_sign_collapse(bound: int = 40) -> None:
    print("== tmsign_zmod2 : every Thue-Morse sign is odd (== 1 mod 2) ==")
    ok = all(tmsign(n) % 2 == 1 for n in range(bound + 1))
    print(f"  checked n = 0..{bound}: all tmsign(n) odd  ->  {ok}\n")


def demo_parity_shadow(max_m: int = 6, bound: int = 60) -> None:
    print("== tconv_succ_zmod2 : t_{m+1}(n) == C(n+m, m)  (mod 2) ==")
    all_ok = True
    for m in range(0, max_m + 1):
        coeffs = tconv(m + 1, bound)
        ok = all((coeffs[n] - comb(n + m, m)) % 2 == 0 for n in range(bound + 1))
        all_ok &= ok
        print(f"  m = {m}: t_{m + 1}(n) == C(n+{m},{m}) mod 2 for n=0..{bound}  ->  {ok}")
    print(f"  overall: {all_ok}\n")


def demo_low_powers(bound: int = 30) -> None:
    print("== t1_odd, t2_parity, t2_odd_iff_even ==")
    t1 = tconv(1, bound)
    t2 = tconv(2, bound)
    print(f"  t1_odd          : {all(t1[n] % 2 == 1 for n in range(bound + 1))}")
    print(f"  t2_parity       : {all(t2[n] % 2 == (n + 1) % 2 for n in range(bound + 1))}")
    print(f"  t2_odd_iff_even : "
          f"{all((t2[n] % 2 == 1) == (n % 2 == 0) for n in range(bound + 1))}")
    print("  first coefficients of f(x)^2:")
    print(f"    n      : {[n for n in range(12)]}")
    print(f"    t_2(n) : {[t2[n] for n in range(12)]}")
    print(f"    parity : {[t2[n] % 2 for n in range(12)]}  (1 exactly at even n)\n")


def demo_mersenne_valuation(kmax: int = 8) -> None:
    print("== Sharp m=2 Mersenne law: t_2(2^k - 1) = (-2)^k,  nu_2 = k ==")
    bound = (1 << kmax) - 1
    t2 = tconv(2, bound)
    print("   k   n=2^k-1     t_2(n)        (-2)^k     nu_2(t_2(n))")
    for k in range(1, kmax + 1):
        n = (1 << k) - 1
        val = t2[n]
        predicted = (-2) ** k
        print(f"  {k:2d}  {n:8d}  {val:11d}  {predicted:11d}  {nu2(val):>6}")
    print()


def demo_sierpinski(rows: int = 16) -> None:
    print("== Parity pattern of C(N, r) mod 2 is the Sierpinski triangle ==")
    for N in range(rows):
        line = " " * (rows - N)
        line += " ".join("#" if comb(N, r) % 2 else "." for r in range(N + 1))
        print("  " + line)
    print("  (By tconv_succ_zmod2, the parity of t_{m+1}(n) is one entry of this pattern.)\n")


if __name__ == "__main__":
    demo_sign_collapse()
    demo_parity_shadow()
    demo_low_powers()
    demo_mersenne_valuation()
    demo_sierpinski()
