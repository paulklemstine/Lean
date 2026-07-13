"""
Numerical demonstrations for the Siegel--Weil identity of the E8 theta series
and its generalization to divisor-power sums.

Central facts illustrated here
------------------------------
Let sigma_s(n) = sum of d**s over all positive divisors d of n.

1.  E8 representation numbers.  For the even unimodular lattice E8 of rank 8,
    the number r(n) of lattice vectors of squared length 2n equals
        r(n) = 240 * sigma_3(n).
    We verify this against a direct vector count in the standard coordinate
    model of E8.

2.  Prime-power geometric form.  sigma_s(p**r) = sum_{i=0}^{r} p**(s*i).

3.  Three-term Hecke recurrence at a prime power.
        sigma_s(p**(r+2)) + p**s * sigma_s(p**r) = sigma_s(p) * sigma_s(p**(r+1)).

4.  Global Hecke eigenform identity (the arithmetic backbone of E8 = E4).
        sigma_s(m) * sigma_s(n) = sum_{d | gcd(m,n)} d**s * sigma_s(m*n/d**2).

5.  Hecke operator T_p eigenvalue relation, valid for every n.
        sigma_s(p) * sigma_s(n) = sigma_s(p*n) + [p | n] * p**s * sigma_s(n/p).

6.  The elementary growth bound n**s <= sigma_s(n), transported to E8 counts as
    240 * n**3 <= r(n).

Everything below is self-contained standard-library Python.
"""

from __future__ import annotations

from itertools import product
from math import gcd, isqrt
from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# Divisor-power sums
# ---------------------------------------------------------------------------
def divisors(n: int) -> List[int]:
    """Return the sorted list of positive divisors of n >= 1."""
    if n < 1:
        raise ValueError("divisors requires n >= 1")
    small: List[int] = []
    large: List[int] = []
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
    return small + large[::-1]


def sigma(s: int, n: int) -> int:
    """The divisor-power sum sigma_s(n) = sum_{d | n} d**s (with sigma_s(0)=0)."""
    if n == 0:
        return 0
    return sum(d ** s for d in divisors(n))


# ---------------------------------------------------------------------------
# 1. E8 representation numbers r(n) = 240 * sigma_3(n)
# ---------------------------------------------------------------------------
def e8_vectors_of_squared_length(sq_len: int) -> int:
    """
    Count vectors of squared length `sq_len` in the D8+ coordinate model of E8.

    E8 consists of all v in (1/2 Z)^8 whose coordinates are either all integers
    or all half-integers, and whose coordinate sum is an even integer.

    Integer part: integer coordinates with even sum, sum of squares = sq_len.
    Half-integer part: use doubled coordinates y = 2x (odd integers); then
    sum(y**2) = 4*sq_len and the even-sum constraint becomes sum(y) = 0 (mod 4).
    """
    count = 0

    # Integer part.
    R = isqrt(sq_len)

    def rec_int(idx: int, remaining: int, coord_sum: int) -> int:
        if idx == 8:
            return 1 if remaining == 0 and coord_sum % 2 == 0 else 0
        total = 0
        for x in range(-R, R + 1):
            sq = x * x
            if sq <= remaining:
                total += rec_int(idx + 1, remaining - sq, coord_sum + x)
        return total

    count += rec_int(0, sq_len, 0)

    # Half-integer part via doubled coordinates y (odd), sum(y**2) = 4*sq_len.
    target = 4 * sq_len
    Ry = isqrt(target)
    odd_range = [y for y in range(-Ry, Ry + 1) if y % 2 != 0]

    def rec_half(idx: int, remaining: int, ysum: int) -> int:
        if idx == 8:
            return 1 if remaining == 0 and ysum % 4 == 0 else 0
        total = 0
        for y in odd_range:
            sq = y * y
            if sq <= remaining:
                total += rec_half(idx + 1, remaining - sq, ysum + y)
        return total

    count += rec_half(0, target, 0)
    return count


def demo_e8_counts(nmax: int = 4) -> None:
    print("=== 1. E8 representation numbers: r(n) = 240 * sigma_3(n) ===")
    print(f"{'n':>3} | {'direct count':>13} | {'240*sigma_3(n)':>15} | match")
    print("-" * 48)
    for n in range(1, nmax + 1):
        direct = e8_vectors_of_squared_length(2 * n)
        formula = 240 * sigma(3, n)
        print(f"{n:>3} | {direct:>13} | {formula:>15} | {direct == formula}")
    print()


# ---------------------------------------------------------------------------
# 2. Prime-power geometric form
# ---------------------------------------------------------------------------
def demo_prime_power(s: int = 3) -> None:
    print(f"=== 2. Prime-power form: sigma_{s}(p^r) = sum_i p^(s*i) ===")
    for p, r in [(2, 4), (3, 3), (5, 2)]:
        lhs = sigma(s, p ** r)
        rhs = sum(p ** (s * i) for i in range(r + 1))
        print(f"  sigma_{s}({p}^{r}) = {lhs}, geometric sum = {rhs}, match = {lhs == rhs}")
    print()


# ---------------------------------------------------------------------------
# 3. Three-term Hecke recurrence at prime powers
# ---------------------------------------------------------------------------
def demo_hecke_recurrence(s: int = 3) -> None:
    print(f"=== 3. Hecke recurrence: sigma_{s}(p^(r+2)) + p^{s}*sigma_{s}(p^r) "
          f"= sigma_{s}(p)*sigma_{s}(p^(r+1)) ===")
    for p, r in [(2, 3), (3, 2), (7, 1)]:
        lhs = sigma(s, p ** (r + 2)) + p ** s * sigma(s, p ** r)
        rhs = sigma(s, p) * sigma(s, p ** (r + 1))
        print(f"  p={p}, r={r}: LHS={lhs}, RHS={rhs}, match={lhs == rhs}")
    print()


# ---------------------------------------------------------------------------
# 4. Global Hecke eigenform (convolution) identity
# ---------------------------------------------------------------------------
def hecke_convolution(s: int, m: int, n: int) -> int:
    """sum_{d | gcd(m,n)} d**s * sigma_s(m*n/d**2)."""
    g = gcd(m, n)
    return sum(d ** s * sigma(s, (m * n) // (d * d)) for d in divisors(g))


def demo_convolution(s: int = 3) -> None:
    print(f"=== 4. Global identity: sigma_{s}(m)*sigma_{s}(n) "
          f"= sum_(d|gcd) d^{s}*sigma_{s}(mn/d^2) ===")
    pairs: List[Tuple[int, int]] = [(4, 6), (12, 18), (36, 24), (7, 7)]
    for m, n in pairs:
        lhs = sigma(s, m) * sigma(s, n)
        rhs = hecke_convolution(s, m, n)
        print(f"  m={m:>3}, n={n:>3}: sigma*sigma={lhs:>10}, "
              f"convolution={rhs:>10}, match={lhs == rhs}")
    print()


# ---------------------------------------------------------------------------
# 5. Hecke operator T_p eigenvalue relation for all n
# ---------------------------------------------------------------------------
def demo_tp_relation(s: int = 3) -> None:
    print(f"=== 5. T_p relation: sigma_{s}(p)*sigma_{s}(n) "
          f"= sigma_{s}(pn) + [p|n]*p^{s}*sigma_{s}(n/p) ===")
    for p, n in [(2, 12), (3, 45), (5, 7), (2, 5)]:
        lhs = sigma(s, p) * sigma(s, n)
        corr = p ** s * sigma(s, n // p) if n % p == 0 else 0
        rhs = sigma(s, p * n) + corr
        print(f"  p={p}, n={n:>3}: LHS={lhs:>10}, RHS={rhs:>10}, match={lhs == rhs}")
    print()


# ---------------------------------------------------------------------------
# 6. Growth bound
# ---------------------------------------------------------------------------
def demo_growth_bound(s: int = 3) -> None:
    print(f"=== 6. Growth bound: n^{s} <= sigma_{s}(n), and 240*n^3 <= r(n) ===")
    for n in range(1, 9):
        print(f"  n={n}: n^{s}={n**s:>6} <= sigma_{s}(n)={sigma(s, n):>7}; "
              f"240*n^3={240*n**3:>8} <= r(n)={240*sigma(3, n):>8}")
    print()


# ---------------------------------------------------------------------------
# General-weight showcase
# ---------------------------------------------------------------------------
def demo_general_weight() -> None:
    print("=== 7. The identity holds for EVERY exponent s (not just s=3) ===")
    m, n = 12, 18
    for s in range(0, 6):
        lhs = sigma(s, m) * sigma(s, n)
        rhs = hecke_convolution(s, m, n)
        print(f"  s={s}: sigma_{s}({m})*sigma_{s}({n})={lhs:>14}, "
              f"convolution={rhs:>14}, match={lhs == rhs}")
    print()


def main() -> None:
    demo_e8_counts(4)
    demo_prime_power(3)
    demo_hecke_recurrence(3)
    demo_convolution(3)
    demo_tp_relation(3)
    demo_growth_bound(3)
    demo_general_weight()


if __name__ == "__main__":
    main()
