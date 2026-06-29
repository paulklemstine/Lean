"""
Numerical demonstration of binary digit-reversal invariance of Cusick densities.

Cusick's density for a shift t is
    c_t = lim_{N->inf} (1/N) * #{0 <= n < N : s2(n+t) >= s2(n)}
where s2(n) is the binary digit sum (popcount) of n.

Verified Lean results (ground truth):
    cusick_density_19_eq_25 : cusickCount 19 (256*m) = cusickCount 25 (256*m)
        => c_19 = c_25 = 164/256 = 41/64
    cusick_density_23_eq_29 : cusickCount 23 (512*m) = cusickCount 29 (512*m)
        => c_23 = c_29 = 300/512 = 75/128

This script reproduces every count behind those theorems and checks the
reversal symmetry, the period scaling, and consistency with the
Drmota-Kauers-Spiegelhofer (DKS) bias bound c_t >= 1/2 + 2^{-(2*s2(t)+1)}.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List


def s2(n: int) -> int:
    """Binary digit sum (number of 1-bits) of a nonnegative integer n."""
    return bin(n).count("1")


def bit_length_binary(t: int) -> int:
    """Number of binary digits L of t (so that t < 2^L), matching Nat.digits."""
    return t.bit_length()


def binary_reverse(t: int) -> int:
    """Reverse the binary digits of t within its bit length L = t.bit_length()."""
    L: int = bit_length_binary(t)
    out: int = 0
    for i in range(L):
        bit: int = (t >> i) & 1
        out |= bit << (L - 1 - i)
    return out


def cusick_count(t: int, N: int) -> int:
    """#{0 <= n < N : s2(n) <= s2(n+t)} -- the finite Cusick count."""
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))


def cusick_period(t: int) -> int:
    """Fundamental period 2^{L + s2(t)} of the Cusick predicate for shift t."""
    return 2 ** (bit_length_binary(t) + s2(t))


def cusick_density(t: int) -> Fraction:
    """Exact c_t = cusickCount(t, period) / period (a dyadic rational)."""
    P: int = cusick_period(t)
    return Fraction(cusick_count(t, P), P)


def dks_lower_bound(t: int) -> Fraction:
    """The DKS bias lower bound 1/2 + 2^{-(2*s2(t)+1)} for c_t."""
    return Fraction(1, 2) + Fraction(1, 2 ** (2 * s2(t) + 1))


def demo_reversal_pair(a: int, b: int) -> None:
    """Print a full report verifying c_a = c_b for a reversal pair (a, b)."""
    print(f"--- Reversal pair ({a}, {b}) ---")
    print(f"  {a} = {a:b}_2,  s2 = {s2(a)},  rev = {binary_reverse(a)}")
    print(f"  {b} = {b:b}_2,  s2 = {s2(b)},  rev = {binary_reverse(b)}")
    assert binary_reverse(a) == b and binary_reverse(b) == a, "not a reversal pair"
    Pa, Pb = cusick_period(a), cusick_period(b)
    print(f"  periods: P_{a} = {Pa},  P_{b} = {Pb}  (equal: {Pa == Pb})")
    base_a, base_b = cusick_count(a, Pa), cusick_count(b, Pb)
    print(f"  per-period counts: cusickCount({a},{Pa}) = {base_a}, "
          f"cusickCount({b},{Pb}) = {base_b}")
    ca, cb = cusick_density(a), cusick_density(b)
    print(f"  c_{a} = {base_a}/{Pa} = {ca} = {float(ca):.6f}")
    print(f"  c_{b} = {base_b}/{Pb} = {cb} = {float(cb):.6f}")
    print(f"  EQUAL densities (reversal invariance): {ca == cb}")
    bound = dks_lower_bound(a)
    print(f"  DKS bound: c >= 1/2 + 2^-(2*{s2(a)}+1) = {bound} = {float(bound):.6f}")
    print(f"  c_{a} exceeds DKS bound: {ca >= bound}")
    print()


def demo_period_scaling(t: int, ms: List[int]) -> None:
    """Verify cusickCount(t, P*m) = m * cusickCount(t, P) for several m."""
    P: int = cusick_period(t)
    base: int = cusick_count(t, P)
    print(f"--- Period scaling for t = {t} (period {P}, base count {base}) ---")
    for m in ms:
        actual: int = cusick_count(t, P * m)
        print(f"  cusickCount({t}, {P}*{m}={P*m}) = {actual}  "
              f"(predicted {base}*{m} = {base*m})  ok={actual == base*m}")
    print()


def main() -> None:
    print("Binary digit-reversal invariance of Cusick densities\n")
    demo_reversal_pair(19, 25)
    demo_reversal_pair(23, 29)
    print("Exact rational densities:")
    print(f"  c_19 = c_25 = {cusick_density(19)} (= 41/64)")
    print(f"  c_23 = c_29 = {cusick_density(23)} (= 75/128)\n")
    demo_period_scaling(19, [1, 2, 3, 4])
    demo_period_scaling(23, [1, 2, 3])
    # A few more observed reversal pairs (motivating the general conjecture):
    print("Further observed reversal pairs (conjecture c_t = c_rev(t)):")
    for a, b in [(11, 13), (35, 49)]:
        ca, cb = cusick_density(a), cusick_density(b)
        print(f"  c_{a} = {ca}, c_{b} = {cb}, equal = {ca == cb}")


if __name__ == "__main__":
    main()
