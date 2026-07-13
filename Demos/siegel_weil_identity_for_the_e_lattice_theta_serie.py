"""
Numerical demonstration of the E4^2 = E8 congruence shadow of the
rank-8 Siegel-Weil identity.

Key facts demonstrated:
  1. r(n) = 240 * sigma_3(n) is the E8 vector count at squared length 2n.
  2. Pointwise power congruence: d^7 == d^3 (mod 120) for every d.
  3. Divisor-sum congruence: sigma_7(n) == sigma_3(n) (mod 120).
  4. Exact convolution law (E4^2 = E8):
         sigma_7(n) = sigma_3(n) + 120 * sum_{i=1}^{n-1} sigma_3(i) sigma_3(n-i).
  5. Optimality: the congruence fails mod 240; sigma_7(2) - sigma_3(2) = 120.
  6. Lattice transport: 240*sigma_7(n) == 240*sigma_3(n) (mod 28800).

Self-contained: standard library only.
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import List


def divisors(n: int) -> List[int]:
    """Return the sorted list of positive divisors of n (n >= 1)."""
    ds: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            if d != n // d:
                ds.append(n // d)
        d += 1
    return sorted(ds)


def sigma(s: int, n: int) -> int:
    """Divisor-power sum sigma_s(n) = sum_{d|n} d^s, with sigma_s(0) = 0."""
    if n == 0:
        return 0
    return sum(d ** s for d in divisors(n))


def pow_congruence_mod120(d: int) -> bool:
    """Check the pointwise power congruence d^7 == d^3 (mod 120)."""
    return (d ** 7 - d ** 3) % 120 == 0


def convolution_correction(n: int) -> int:
    """Self-convolution sum_{i=1}^{n-1} sigma_3(i) sigma_3(n-i)."""
    return sum(sigma(3, i) * sigma(3, n - i) for i in range(1, n))


def r_E8(n: int) -> int:
    """Number of E8 vectors of squared length 2n: r(n) = 240 * sigma_3(n)."""
    return 240 * sigma(3, n)


def demo() -> None:
    print("=" * 68)
    print("Siegel-Weil E8 theta series: the E4^2 = E8 congruence shadow")
    print("=" * 68)

    print("\n[1] E8 vector counts r(n) = 240 * sigma_3(n)")
    print("    (r(1) = 240 = number of roots / kissing number of E8)")
    for n in range(1, 9):
        print(f"    n={n:2d}:  sigma_3(n)={sigma(3, n):6d}   r(n)={r_E8(n):8d}")

    print("\n[2] Pointwise power congruence d^7 == d^3 (mod 120)")
    ok = all(pow_congruence_mod120(d) for d in range(0, 200))
    print(f"    verified for d = 0..199:  {ok}")

    print("\n[3] Divisor-sum congruence sigma_7(n) == sigma_3(n) (mod 120)")
    for n in range(1, 12):
        s7, s3 = sigma(7, n), sigma(3, n)
        diff = s7 - s3
        print(f"    n={n:2d}:  sigma_7={s7:12d}  sigma_3={s3:6d}  "
              f"diff={diff:12d}  diff%120={diff % 120}")

    print("\n[4] Exact convolution law  sigma_7 = sigma_3 + 120*(sigma_3 * sigma_3)")
    all_eq = True
    for n in range(1, 12):
        lhs = sigma(7, n)
        rhs = sigma(3, n) + 120 * convolution_correction(n)
        all_eq &= (lhs == rhs)
        print(f"    n={n:2d}:  sigma_7={lhs:12d}   predicted={rhs:12d}   "
              f"match={lhs == rhs}")
    print(f"    all matched (n=1..11): {all_eq}")

    print("\n[5] Optimality: congruence holds mod 120 but FAILS mod 240")
    diff2 = sigma(7, 2) - sigma(3, 2)
    print(f"    sigma_7(2) - sigma_3(2) = 129 - 9 = {diff2}")
    print(f"    {diff2} % 120 = {diff2 % 120}   (holds)")
    print(f"    {diff2} % 240 = {diff2 % 240}   (fails => 120 is sharp)")
    g = reduce(gcd, (sigma(7, n) - sigma(3, n) for n in range(1, 200)))
    print(f"    gcd of sigma_7(n)-sigma_3(n) over n=1..199:  {g}")

    print("\n[6] Lattice transport: 240*sigma_7 == 240*sigma_3 (mod 28800)")
    for n in range(1, 8):
        s, r = 240 * sigma(7, n), r_E8(n)
        print(f"    n={n}:  s(n)-r(n)={s - r:12d}   %28800={(s - r) % 28800}")


if __name__ == "__main__":
    demo()
