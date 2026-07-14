"""
Numerical demonstrations of the arithmetic residue of the identity E_4^2 = E_8.

Central facts demonstrated:
  * sigma_7(n) - sigma_3(n) is always divisible by 120         (weight-8 congruence)
  * sigma_5(n) - sigma_3(n) is always divisible by 24          (weight-6 congruence)
  * 120 is the SHARP (greatest) modulus for sigma_7 vs sigma_3, witnessed at n = 2
  * 24  is the SHARP (greatest) modulus for sigma_5 vs sigma_3, witnessed at n = 2
  * the pointwise laws 120 | d^7 - d^3 and 24 | d^5 - d^3
  * the exact convolution law  sigma_7(n) = sigma_3(n) + 120 * (sigma_3 * sigma_3)(n)
  * the E_8-normalized congruence  28800 | 240*sigma_7(n) - 240*sigma_3(n)

Self-contained: standard library only.
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import List


def divisors(n: int) -> List[int]:
    """Return the sorted list of positive divisors of n."""
    if n <= 0:
        raise ValueError("n must be a positive integer")
    ds: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            if d != n // d:
                ds.append(n // d)
        d += 1
    return sorted(ds)


def sigma(k: int, n: int) -> int:
    """Divisor power sum sigma_k(n) = sum over d | n of d^k."""
    return sum(d ** k for d in divisors(n))


def self_convolution_sigma3(n: int) -> int:
    """(sigma_3 * sigma_3)(n) = sum_{i=1}^{n-1} sigma_3(i) * sigma_3(n-i)."""
    return sum(sigma(3, i) * sigma(3, n - i) for i in range(1, n))


def demo_divisor_sum_congruence(limit: int = 20) -> None:
    """Verify sigma_7(n) = sigma_3(n) (mod 120) and sigma_5(n) = sigma_3(n) (mod 24)."""
    print("=" * 72)
    print("Divisor-sum congruences")
    print("=" * 72)
    print(f"{'n':>3} | {'s3':>8} {'s5':>10} {'s7':>12} | s7-s3 mod120 | s5-s3 mod24")
    print("-" * 72)
    ok = True
    for n in range(1, limit + 1):
        s3, s5, s7 = sigma(3, n), sigma(5, n), sigma(7, n)
        r7 = (s7 - s3) % 120
        r5 = (s5 - s3) % 24
        ok = ok and r7 == 0 and r5 == 0
        print(f"{n:>3} | {s3:>8} {s5:>10} {s7:>12} | {r7:>12} | {r5:>11}")
    print("-" * 72)
    print(f"All residues zero up to n = {limit}: {ok}\n")


def demo_pointwise_power_residues(limit: int = 15) -> None:
    """Verify 120 | d^7 - d^3 and 24 | d^5 - d^3 for a range of integers."""
    print("=" * 72)
    print("Pointwise power-residue laws")
    print("=" * 72)
    ok = True
    for d in range(-limit, limit + 1):
        a = (d ** 7 - d ** 3) % 120
        b = (d ** 5 - d ** 3) % 24
        ok = ok and a == 0 and b == 0
    print(f"120 | d^7 - d^3  and  24 | d^5 - d^3  for all d in [-{limit},{limit}]: {ok}")
    print(f"  witness d=2:  2^7 - 2^3 = {2**7 - 2**3},   2^5 - 2^3 = {2**5 - 2**3}\n")


def optimal_modulus(j: int, k: int, sample: int = 60) -> int:
    """
    Compute gcd over a of (a^j - a^k), the SHARP modulus for the congruence
    sigma_j = sigma_k. Sampling a = 2..sample+1 stabilises quickly to the true gcd.
    """
    vals = [a ** j - a ** k for a in range(2, sample + 2)]
    return reduce(gcd, vals)


def demo_sharpness() -> None:
    """Show that 120 and 24 are the greatest admissible moduli, witnessed at n = 2."""
    print("=" * 72)
    print("Sharpness of the moduli (greatest admissible modulus)")
    print("=" * 72)
    m73 = optimal_modulus(7, 3)
    m53 = optimal_modulus(5, 3)
    print(f"gcd_a (a^7 - a^3) = {m73}   (matches 120: {m73 == 120})")
    print(f"gcd_a (a^5 - a^3) = {m53}   (matches  24: {m53 == 24})")
    print(f"witness n=2:  sigma_7(2)-sigma_3(2) = {sigma(7,2)-sigma(3,2)}"
          f"   sigma_5(2)-sigma_3(2) = {sigma(5,2)-sigma(3,2)}\n")


def demo_convolution_law(limit: int = 11) -> None:
    """Verify the exact convolution law sigma_7(n) = sigma_3(n) + 120*(sigma_3 * sigma_3)(n)."""
    print("=" * 72)
    print("Exact convolution law:  sigma_7(n) = sigma_3(n) + 120 * conv(n)")
    print("=" * 72)
    print(f"{'n':>3} | {'sigma_3':>8} {'conv':>8} {'predicted':>14} {'sigma_7':>14} {'match':>6}")
    print("-" * 72)
    ok = True
    for n in range(1, limit + 1):
        s3 = sigma(3, n)
        conv = self_convolution_sigma3(n)
        predicted = s3 + 120 * conv
        actual = sigma(7, n)
        match = predicted == actual
        ok = ok and match
        print(f"{n:>3} | {s3:>8} {conv:>8} {predicted:>14} {actual:>14} {str(match):>6}")
    print("-" * 72)
    print(f"Convolution law holds up to n = {limit}: {ok}\n")


def demo_e8_normalized(limit: int = 12) -> None:
    """Verify the E_8-normalized congruence 28800 | 240*sigma_7(n) - 240*sigma_3(n)."""
    print("=" * 72)
    print("E_8-normalized congruence:  28800 | 240*sigma_7(n) - 240*sigma_3(n)")
    print("=" * 72)
    ok = True
    for n in range(1, limit + 1):
        diff = 240 * sigma(7, n) - 240 * sigma(3, n)
        r = diff % 28800
        ok = ok and r == 0
    print(f"All residues mod 28800 vanish up to n = {limit}: {ok}\n")


def main() -> None:
    demo_pointwise_power_residues()
    demo_divisor_sum_congruence()
    demo_sharpness()
    demo_convolution_law()
    demo_e8_normalized()


if __name__ == "__main__":
    main()
