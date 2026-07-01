"""
Digit Sum Formula for Prime Reciprocals with Half-Order Periods
===============================================================

Numerical demonstration of the theorem:

    For a prime p >= 3 and an integer b >= 2 with p not dividing b, if the
    multiplicative order of b modulo p is l = (p-1) / 2^m and p == 1 (mod 2^(m+1)),
    then the sum of the base-b digits in one full period of 1/p equals

        S = (b - 1) * (p - 1) / 2^(m+1)  =  (b - 1) * l / 2.

The repeating block of 1/p in base b is the base-b representation of
N = (b^l - 1) / p (padded with leading zeros to length l). Leading zeros do not
change the digit sum, so we work with the digit sum of N directly.

This script is self-contained: all functions are inlined and rely only on the
Python standard library.
"""

from __future__ import annotations

from typing import List, Optional, Tuple


# ---------------------------------------------------------------------------
# Elementary number theory
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (fine for demo-sized n)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def multiplicative_order(b: int, p: int) -> int:
    """Least l >= 1 with b^l == 1 (mod p). Requires gcd(b, p) == 1."""
    if p <= 1 or b % p == 0:
        raise ValueError("require p > 1 and p not dividing b")
    value = 1 % p
    for l in range(1, p):
        value = (value * b) % p
        if value == 1:
            return l
    raise ValueError("no order found (b not coprime to p?)")


# ---------------------------------------------------------------------------
# Base-b digits and digit sum
# ---------------------------------------------------------------------------

def digits_base(b: int, n: int) -> List[int]:
    """Base-b digit list of n, least significant first ([] for n == 0)."""
    if b < 2:
        raise ValueError("base must be >= 2")
    out: List[int] = []
    while n > 0:
        out.append(n % b)
        n //= b
    return out


def digit_sum(b: int, n: int) -> int:
    """Sum of the base-b digits of n."""
    return sum(digits_base(b, n))


# ---------------------------------------------------------------------------
# The period integer and the formula
# ---------------------------------------------------------------------------

def period_integer(b: int, p: int) -> Tuple[int, int]:
    """Return (l, N) where l = ord_p(b) and N = (b^l - 1) / p is the period."""
    l = multiplicative_order(b, p)
    N = (b ** l - 1) // p
    assert (b ** l - 1) % p == 0, "period integer must be exact"
    return l, N


def find_m(p: int, l: int) -> Optional[int]:
    """Return m >= 0 with l == (p-1) / 2^m, or None if no such integer m."""
    q, m = p - 1, 0
    while q % 2 == 0:
        if q == l:
            return m
        q //= 2
        m += 1
    return m if q == l else None


def is_admissible(p: int, b: int, m: int) -> bool:
    """True iff ord_p(b) == (p-1)/2^m and p == 1 (mod 2^(m+1))."""
    if not is_prime(p) or p < 3 or b < 2 or p % b == 0 and b % p == 0:
        pass
    if b % p == 0:
        return False
    l = multiplicative_order(b, p)
    if (p - 1) % (2 ** m) != 0 or l != (p - 1) // (2 ** m):
        return False
    return (p - 1) % (2 ** (m + 1)) == 0


def formula_digit_sum(b: int, p: int, m: int) -> int:
    """Closed-form prediction (b-1)(p-1)/2^(m+1)."""
    return (b - 1) * (p - 1) // (2 ** (m + 1))


def half_split(b: int, p: int) -> Tuple[int, int, int, int]:
    """Exhibit N = k*(b^h - 1) = (k-1)*b^h + (b^h - k). Requires even order.

    Returns (h, k, top, bottom) with top = k-1, bottom = b^h - k, the two
    complementary halves of the period.
    """
    l, N = period_integer(b, p)
    if l % 2 != 0:
        raise ValueError("order is odd; no two-halves split")
    h = l // 2
    k = (b ** h + 1) // p
    assert (b ** h + 1) % p == 0, "even order forces p | b^h + 1"
    top, bottom = k - 1, b ** h - k
    assert N == k * (b ** h - 1) == top * b ** h + bottom
    return h, k, top, bottom


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_examples() -> None:
    print("=" * 70)
    print("Digit-sum formula for prime reciprocals with half-order periods")
    print("=" * 70)
    cases: List[Tuple[int, int]] = [
        (10, 7), (10, 13), (10, 17), (10, 19), (10, 23),
        (2, 17), (2, 23), (3, 13), (7, 19),
    ]
    for b, p in cases:
        l, N = period_integer(b, p)
        m = find_m(p, l)
        direct = digit_sum(b, N)
        if l % 2 == 0 and m is not None and is_admissible(p, b, m):
            pred = formula_digit_sum(b, p, m)
            ok = "OK " if pred == direct == (b - 1) * l // 2 else "!! "
            print(f"{ok}b={b:<3} p={p:<4} l={l:<3} m={m}  "
                  f"digit_sum(N)={direct:<5} formula={pred:<5} (b-1)l/2={(b-1)*l//2}")
        else:
            print(f"--  b={b:<3} p={p:<4} l={l:<3} (odd order: theorem N/A)  "
                  f"digit_sum(N)={direct}")


def demo_halves() -> None:
    print("\n" + "=" * 70)
    print("Nines-complement structure of the two halves")
    print("=" * 70)
    for b, p in [(10, 7), (10, 13), (10, 17), (2, 17)]:
        h, k, top, bottom = half_split(b, p)
        top_d = "".join(str(d) for d in reversed(
            digits_base(b, top) or [0])).rjust(h, "0")
        bot_d = "".join(str(d) for d in reversed(
            digits_base(b, bottom) or [0])).rjust(h, "0")
        colsum = (b ** h - 1)
        print(f"b={b} p={p}: top={top_d} bottom={bot_d}  "
              f"top+bottom={top + bottom} = b^h - 1 = {colsum}")


def demo_odd_deficit() -> None:
    print("\n" + "=" * 70)
    print("Odd-order deficit: digit_sum(N) < (b-1)l/2 (theorem is sharp)")
    print("=" * 70)
    for b, p in [(2, 7), (10, 3), (2, 31), (3, 11)]:
        l, N = period_integer(b, p)
        if l % 2 == 1:
            naive = (b - 1) * l / 2
            print(f"b={b} p={p} l={l} (odd): digit_sum={digit_sum(b, N)}, "
                  f"(b-1)l/2={naive}, deficit={naive - digit_sum(b, N)}")


if __name__ == "__main__":
    demo_examples()
    demo_halves()
    demo_odd_deficit()
