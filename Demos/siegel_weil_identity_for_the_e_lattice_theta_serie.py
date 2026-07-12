"""
Numerical demonstration of the Siegel-Weil identity for the E8 lattice theta
series: the number of E8 vectors of squared length 2n equals 240 * sigma_3(n),
where sigma_3(n) = sum of cubes of divisors of n.

This script verifies, purely arithmetically, the results of the accompanying
paper:

  1. Prime-power closed form:  sigma_3(p^r) = sum_{i=0}^r p^{3i}.
  2. Hecke three-term recurrence on prime powers.
  3. Multiplicativity of sigma_3 across coprime arguments.
  4. Global Hecke eigenform convolution identity.
  5. The E8 shell counts 240, 2160, 6720, 17520, 30240, ...

Run:  python demo.py
"""

from __future__ import annotations

from math import gcd
from typing import List


# --------------------------------------------------------------------------- #
# Core arithmetic
# --------------------------------------------------------------------------- #
def divisors(n: int) -> List[int]:
    """Return the sorted list of positive divisors of n >= 1."""
    if n < 1:
        raise ValueError("divisors requires n >= 1")
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
    """Divisor-power sum sigma_s(n) = sum_{d | n} d^s, with sigma_s(0) = 0."""
    if n == 0:
        return 0
    return sum(d ** s for d in divisors(n))


def sigma3(n: int) -> int:
    """Sum of cubes of divisors of n."""
    return sigma(3, n)


def rE8(n: int) -> int:
    """Siegel-Weil prediction for the number of E8 vectors of squared length 2n."""
    return 240 * sigma3(n)


def hecke_rhs(m: int, n: int) -> int:
    """The Hecke convolution sum_{d | gcd(m,n)} d^3 * sigma_3(m*n / d^2)."""
    if m == 0 or n == 0:
        return 0
    g = gcd(m, n)
    total = 0
    for d in divisors(g):
        total += d ** 3 * sigma3(m * n // (d * d))
    return total


# --------------------------------------------------------------------------- #
# Independent E8 vector count by brute force (small shells) for cross-check
# --------------------------------------------------------------------------- #
def e8_vector_count(n: int) -> int:
    """
    Count vectors of squared length 2n in the E8 lattice, realized as the set of
    points in Z^8 union (Z+1/2)^8 whose coordinate sum is even. We scale by 2 to
    work in integers: a vector has coordinates all-integer-doubled or all-odd,
    and we search a bounded box. Only intended for small n (say n <= 3).
    """
    target = 2 * n  # squared length
    # Represent E8 vectors with doubled coordinates y = 2x in Z^8, where either
    # all y_i even (integer point) or all y_i odd (half-integer point), and
    # (sum x_i) is even  <=>  (sum y_i) divisible by 4.
    # squared length = (sum y_i^2) / 4 = target  =>  sum y_i^2 = 4*target.
    s = 4 * target
    bound = int(s ** 0.5)
    count = 0

    def rec(idx: int, remaining: int, parity: int, coord_sum: int) -> None:
        nonlocal count
        if idx == 8:
            if remaining == 0 and coord_sum % 4 == 0:
                count += 1
            return
        lo = -bound
        hi = bound
        for y in range(lo, hi + 1):
            if y * y > remaining:
                continue
            if y % 2 != parity:
                continue
            rec(idx + 1, remaining - y * y, parity, coord_sum + y)

    # parity 0: all-even coordinates (integer points); parity 1: all-odd (half pts)
    rec(0, s, 0, 0)
    rec(0, s, 1, 0)
    return count


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_shell_counts() -> None:
    print("=== E8 shell counts  r(n) = 240 * sigma_3(n) ===")
    print(f"{'n':>3} | {'sigma_3(n)':>11} | {'r(n)':>10}")
    print("-" * 32)
    for n in range(1, 11):
        print(f"{n:>3} | {sigma3(n):>11} | {rE8(n):>10}")
    print()


def demo_prime_power_closed_form() -> None:
    print("=== Prime-power closed form  sigma_3(p^r) = sum p^(3i) ===")
    for p in (2, 3, 5):
        for r in range(0, 5):
            lhs = sigma3(p ** r)
            rhs = sum(p ** (3 * i) for i in range(r + 1))
            ok = "OK" if lhs == rhs else "FAIL"
            print(f"  sigma_3({p}^{r}) = {lhs:>10}  (geom sum {rhs:>10})  [{ok}]")
    print()


def demo_hecke_recurrence() -> None:
    print("=== Hecke recurrence: sigma_3(p^(r+2)) + p^3 sigma_3(p^r) "
          "= sigma_3(p) sigma_3(p^(r+1)) ===")
    for p in (2, 3, 5):
        for r in range(0, 4):
            lhs = sigma3(p ** (r + 2)) + p ** 3 * sigma3(p ** r)
            rhs = sigma3(p) * sigma3(p ** (r + 1))
            ok = "OK" if lhs == rhs else "FAIL"
            print(f"  p={p}, r={r}:  {lhs} == {rhs}  [{ok}]")
    print()


def demo_multiplicativity() -> None:
    print("=== Multiplicativity: sigma_3(mn) = sigma_3(m) sigma_3(n), gcd(m,n)=1 ===")
    for m, n in [(2, 3), (4, 9), (5, 7), (8, 27), (3, 25)]:
        assert gcd(m, n) == 1
        lhs = sigma3(m * n)
        rhs = sigma3(m) * sigma3(n)
        ok = "OK" if lhs == rhs else "FAIL"
        print(f"  m={m}, n={n}:  sigma_3({m*n})={lhs} == {rhs}  [{ok}]")
    print()


def demo_hecke_identity() -> None:
    print("=== Global Hecke eigenform identity: "
          "sigma_3(m) sigma_3(n) = sum_{d|gcd} d^3 sigma_3(mn/d^2) ===")
    fails = 0
    for m in range(1, 13):
        for n in range(1, 13):
            lhs = sigma3(m) * sigma3(n)
            rhs = hecke_rhs(m, n)
            if lhs != rhs:
                fails += 1
                print(f"  MISMATCH m={m}, n={n}: {lhs} != {rhs}")
    print(f"  checked all 1<=m,n<=12: {'ALL OK' if fails == 0 else f'{fails} FAILURES'}")
    print()


def demo_brute_force_cross_check() -> None:
    print("=== Cross-check: brute-force E8 vector count vs 240*sigma_3(n) ===")
    for n in range(1, 4):
        brute = e8_vector_count(n)
        pred = rE8(n)
        ok = "OK" if brute == pred else "FAIL"
        print(f"  n={n}: brute={brute}, predicted={pred}  [{ok}]")
    print()


def main() -> None:
    demo_shell_counts()
    demo_prime_power_closed_form()
    demo_hecke_recurrence()
    demo_multiplicativity()
    demo_hecke_identity()
    demo_brute_force_cross_check()


if __name__ == "__main__":
    main()
