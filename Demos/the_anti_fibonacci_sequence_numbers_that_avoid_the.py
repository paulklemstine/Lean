#!/usr/bin/env python3
"""
The Anti-Fibonacci Sequence: numerical demonstration of every main result.

The anti-Fibonacci sequence is

    a(0) = 1,      a(n+1) = a(n) + n,

equivalently a(n) = n(n-1)/2 + 1, the "lazy caterer" numbers.  Everything about
its arithmetic follows from the master identity

    8 * a(n) = (2n - 1)^2 + 7,

which turns questions about the sequence into questions about the binary
quadratic form x^2 + 7 of discriminant -7.

This script verifies, numerically and from scratch:

  1.  the closed form and the master identity;
  2.  the absence of the golden ratio (a(n+1)/a(n) -> 1, not 1.618...);
  3.  the constant-time counting formula, the bounds sqrt(2N) <= C(N) <= sqrt(2N)+3,
      the asymptotic C(N) ~ sqrt(2N), and natural density zero;
  4.  the one-square-root membership test;
  5.  the Pell classification of square terms (infinitely many);
  6.  the correspondence "three-term progressions <-> Pythagorean triples",
      the explicit family a(k^2) + a((k+1)^2) = 2 a(k^2+k+1), and the
      square-pyramidal common difference;
  7.  the two-squares criterion for sums of two terms and the mod-9 obstruction
      giving lower density >= 2/9 for the non-representable set;
  8.  the additive-basis-of-order-4 theorem;
  9.  the prime divisor law (p = 7 or p = 1, 2, 4 mod 7);
 10.  the residue spectrum of size (p+1)/2 modulo an odd prime;
 11.  the minimal period mod m (m if m odd, 2m if m even);
 12.  the exact gcd law gcd(a(n), a(n+1)) = 2 iff n = 2 mod 4.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from math import gcd, isqrt
from typing import Iterator


# ---------------------------------------------------------------------------
# 1.  The sequence itself
# ---------------------------------------------------------------------------

def anti_fib(n: int) -> int:
    """The n-th anti-Fibonacci number, a(n) = n(n-1)/2 + 1."""
    return n * (n - 1) // 2 + 1


def anti_fib_recursive(n: int) -> int:
    """Same value, computed from the defining recurrence a(k+1) = a(k) + k."""
    value = 1
    for k in range(n):
        value += k
    return value


def check_closed_form(limit: int = 2000) -> bool:
    """Verify a(n) = n(n-1)/2 + 1, 2a(n) + n = n^2 + 2, and 8a(n) = (2n-1)^2 + 7."""
    for n in range(limit):
        a = anti_fib(n)
        if a != anti_fib_recursive(n):
            return False
        if 2 * a + n != n * n + 2:
            return False
        if 8 * a != (2 * n - 1) ** 2 + 7:
            return False
    return True


# ---------------------------------------------------------------------------
# 2.  No golden ratio
# ---------------------------------------------------------------------------

def ratio_table(indices: list[int]) -> list[tuple[int, float]]:
    """Consecutive ratios a(n+1)/a(n); these tend to 1, never to phi."""
    return [(n, anti_fib(n + 1) / anti_fib(n)) for n in indices]


# ---------------------------------------------------------------------------
# 3.  Counting function, bounds, density
# ---------------------------------------------------------------------------

def count_closed(N: int) -> int:
    """C(N) = #{k : a(k) <= N}, computed with one integer square root."""
    if N < 1:
        return 0
    return (isqrt(8 * N - 7) + 1) // 2 + 1


def count_naive(N: int) -> int:
    """C(N) by brute-force scan; O(sqrt N) terms are generated."""
    c, k = 0, 0
    while anti_fib(k) <= N:
        c += 1
        k += 1
    return c


def count_bounds_hold(N: int) -> bool:
    """Check 2N + C <= C^2 + 1, C^2 + 4 <= 2N + 3C, sqrt(2N) <= C <= sqrt(2N)+3."""
    c = count_closed(N)
    integer_ok = (2 * N + c <= c * c + 1) and (c * c + 4 <= 2 * N + 3 * c)
    real_ok = math.sqrt(2 * N) <= c <= math.sqrt(2 * N) + 3
    return integer_ok and real_ok


# ---------------------------------------------------------------------------
# 4.  Constant-time membership test
# ---------------------------------------------------------------------------

def is_anti_fib(m: int) -> bool:
    """m is an anti-Fibonacci number  <=>  8m - 7 is a perfect square."""
    if m < 1:
        return False
    t = 8 * m - 7
    s = isqrt(t)
    return s * s == t


def index_of(m: int) -> int | None:
    """The index n with a(n) = m, if it exists (the larger of the two for m = 1)."""
    if not is_anti_fib(m):
        return None
    return (isqrt(8 * m - 7) + 1) // 2


# ---------------------------------------------------------------------------
# 5.  Square terms via the Pell equation x^2 + 7 = 8 y^2
# ---------------------------------------------------------------------------

def pell_orbit(x0: int, y0: int, steps: int) -> Iterator[tuple[int, int]]:
    """Orbit of (x0, y0) under the automorphism (x, y) -> (3x + 8y, x + 3y)."""
    x, y = x0, y0
    for _ in range(steps):
        yield x, y
        x, y = 3 * x + 8 * y, x + 3 * y


def square_terms(steps: int = 8) -> list[tuple[int, int, int]]:
    """All (index n, a(n), sqrt(a(n))) with a(n) a perfect square, in increasing order."""
    pairs = list(pell_orbit(1, 1, steps)) + list(pell_orbit(5, 2, steps))
    out = []
    for x, y in sorted(pairs):
        n = (x + 1) // 2
        out.append((n, anti_fib(n), y))
    return out


def square_terms_bruteforce(limit: int) -> list[int]:
    """Indices n < limit with a(n) a perfect square, found by direct search."""
    return [n for n in range(1, limit) if isqrt(anti_fib(n)) ** 2 == anti_fib(n)]


# ---------------------------------------------------------------------------
# 6.  Arithmetic progressions and Pythagorean triples
# ---------------------------------------------------------------------------

def ap_triples_bruteforce(limit: int) -> list[tuple[int, int, int]]:
    """All indices 1 <= a < b < c < limit with a(a) + a(c) = 2 a(b)."""
    out = []
    for a in range(1, limit):
        for b in range(a + 1, limit):
            target = 2 * anti_fib(b) - anti_fib(a)
            if target < 1 or not is_anti_fib(target):
                continue
            c = index_of(target)
            if c is not None and c > b:
                out.append((a, b, c))
    return out


def ap_to_pythagorean(a: int, b: int, c: int) -> tuple[int, int, int]:
    """The Pythagorean triple attached to a progression a(a) + a(c) = 2 a(b)."""
    return (abs(a + c - 1), abs(c - a), abs(2 * b - 1))


def pyramidal(k: int) -> int:
    """1^2 + 2^2 + ... + k^2, the k-th square-pyramidal number."""
    return k * (k + 1) * (2 * k + 1) // 6


# ---------------------------------------------------------------------------
# 7.  Sums of two anti-Fibonacci numbers
# ---------------------------------------------------------------------------

def is_sum_of_two_squares(n: int) -> bool:
    """True iff n is a sum of two squares (trial division on the form 8m-14 sizes here)."""
    if n < 0:
        return False
    m = n
    q = 2
    while q * q <= m:
        if m % q == 0:
            e = 0
            while m % q == 0:
                m //= q
                e += 1
            if q % 4 == 3 and e % 2 == 1:
                return False
        q += 1
    return not (m % 4 == 3)


def sum_of_two_criterion(m: int) -> bool:
    """m >= 2 is a sum of two anti-Fibonacci numbers <=> 8m - 14 is a sum of two squares."""
    if m < 2:
        return False
    return is_sum_of_two_squares(8 * m - 14)


def sum_of_two_bruteforce(m: int) -> bool:
    """Direct search for a(i) + a(j) = m."""
    i = 0
    while anti_fib(i) <= m:
        rest = m - anti_fib(i)
        if rest >= 1 and is_anti_fib(rest):
            return True
        i += 1
    return False


# ---------------------------------------------------------------------------
# 8.  Additive basis of order four
# ---------------------------------------------------------------------------

def four_odd_squares(target: int) -> tuple[int, int, int, int] | None:
    """Write target = 8k + 4 as a sum of four odd squares (search)."""
    r = isqrt(target)
    for x in range(1, r + 1, 2):
        rx = target - x * x
        for y in range(1, isqrt(rx) + 1, 2):
            ry = rx - y * y
            for z in range(1, isqrt(ry) + 1, 2):
                rz = ry - z * z
                w = isqrt(rz)
                if w * w == rz and w % 2 == 1:
                    return (x, y, z, w)
    return None


def four_summand_decomposition(m: int) -> tuple[int, int, int, int] | None:
    """Indices (p,q,r,s) with a(p)+a(q)+a(r)+a(s) = m, for m >= 4."""
    if m < 4:
        return None
    sq = four_odd_squares(8 * (m - 4) + 4)
    if sq is None:
        return None
    return tuple((v + 1) // 2 for v in sq)  # type: ignore[return-value]


# ---------------------------------------------------------------------------
# 9-10.  Divisibility and residue spectrum
# ---------------------------------------------------------------------------

def primes_upto(n: int) -> list[int]:
    sieve = [True] * (n + 1)
    sieve[0:2] = [False, False]
    for p in range(2, isqrt(n) + 1):
        if sieve[p]:
            for q in range(p * p, n + 1, p):
                sieve[q] = False
    return [p for p in range(n + 1) if sieve[p]]


def divides_some_term(p: int) -> bool:
    """Brute force: does p divide a(n) for some n?  (The period mod p is <= 2p.)"""
    return any(anti_fib(n) % p == 0 for n in range(2 * p + 2))


def divisor_law(p: int) -> bool:
    """Predicted answer: p = 7 or p = 1, 2, 4 (mod 7)."""
    return p == 7 or p % 7 in (1, 2, 4)


def spectrum(p: int) -> list[int]:
    """The residues attained by the anti-Fibonacci sequence modulo p."""
    return sorted({anti_fib(n) % p for n in range(2 * p + 2)})


# ---------------------------------------------------------------------------
# 11.  Minimal period modulo m
# ---------------------------------------------------------------------------

def is_period(m: int, p: int) -> bool:
    """Is p a period of the sequence mod m?  (Equivalently m | p and a(p) = 1 mod m.)"""
    return p > 0 and all(anti_fib(n + p) % m == anti_fib(n) % m for n in range(3 * m + 5))


def minimal_period_bruteforce(m: int) -> int:
    p = 1
    while not is_period(m, p):
        p += 1
    return p


def pisano_anti(m: int) -> int:
    """Predicted minimal period: m if m is odd, 2m if m is even."""
    return m if m % 2 == 1 else 2 * m


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def main() -> None:
    rule("1.  The sequence and the master identity  8 a(n) = (2n-1)^2 + 7")
    print("  a(0..14) =", [anti_fib(n) for n in range(15)])
    print("  closed form / recurrence / master identity agree for n < 2000:",
          check_closed_form(2000))
    for n in (5, 10, 100):
        print(f"    n={n:4d}:  a(n)={anti_fib(n):7d},  8a(n)={8*anti_fib(n):8d}"
              f" = {(2*n-1)}^2 + 7 = {(2*n-1)**2 + 7}")

    rule("2.  There is no golden ratio:  a(n+1)/a(n) -> 1")
    print("  golden ratio phi = 1.6180339887...")
    for n, r in ratio_table([2, 5, 10, 50, 200, 1000, 10000]):
        print(f"    n={n:6d}:  a(n+1)/a(n) = {r:.10f}")
    print("  and a(n)/n^2 -> 1/2 = 0.5 :",
          ", ".join(f"n={n}: {anti_fib(n)/n**2:.6f}" for n in (10, 100, 10**4, 10**6)))

    rule("3.  Counting function  C(N) = floor((floor(sqrt(8N-7))+1)/2) + 1")
    print("      N       C(N) closed   C(N) naive   sqrt(2N)     C - sqrt(2N)")
    for N in (1, 4, 10, 100, 10**4, 10**6, 10**9):
        c = count_closed(N)
        naive = count_naive(N) if N <= 10**6 else None
        s = math.sqrt(2 * N)
        naive_str = f"{naive:>10d}" if naive is not None else f"{'-':>10}"
        print(f"  {N:>9d}   {c:>10d}   {naive_str}   {s:>12.4f}   {c - s:>10.4f}")
    print("  bounds  sqrt(2N) <= C(N) <= sqrt(2N)+3  and the two integer")
    print("  inequalities hold for every N in 1..20000:",
          all(count_bounds_hold(N) for N in range(1, 20001)))
    print("  the upper inequality C^2 + 4 <= 2N + 3C is an equality exactly when N is a term:")
    print("    equality set below 60:",
          [N for N in range(1, 60)
           if count_closed(N) ** 2 + 4 == 2 * N + 3 * count_closed(N)])
    print("    (compare the sequence itself:", [anti_fib(n) for n in range(1, 11)], ")")
    print("  density: C(N)/N =",
          ", ".join(f"{count_closed(N)/N:.2e} (N=10^{int(math.log10(N))})"
                    for N in (10**3, 10**6, 10**9, 10**12)), "-> 0")

    rule("4.  Constant-time membership test:  m in the sequence <=> 8m-7 a square")
    values = {anti_fib(n) for n in range(200)}
    ok = all(is_anti_fib(m) == (m in values) for m in range(1, anti_fib(199)))
    print("  test agrees with brute force on every m < a(199) =", anti_fib(199), ":", ok)
    for m in (46, 47, 4096, 4097):
        print(f"    m={m:6d}:  8m-7 = {8*m-7:7d}, member = {is_anti_fib(m)},"
              f" index = {index_of(m)}")

    rule("5.  Perfect squares in the sequence (Pell equation x^2 + 7 = 8 y^2)")
    print("  index n      a(n)     sqrt(a(n))")
    for n, a, y in square_terms(5):
        print(f"  {n:8d}  {a:12d}   {y:10d}")
    print("  brute-force square indices below 2000:", square_terms_bruteforce(2000))
    print("  (Fibonacci, by contrast, contains only the squares 0, 1 and 144.)")

    rule("6.  Three-term progressions  <->  Pythagorean triples with odd hypotenuse")
    print("  brute-force progressions with indices < 40, and their triples:")
    for (a, b, c) in ap_triples_bruteforce(40)[:10]:
        x, y, z = ap_to_pythagorean(a, b, c)
        print(f"    a({a}) + a({c}) = {anti_fib(a)} + {anti_fib(c)}"
              f" = 2*{anti_fib(b)} = 2 a({b})   <->   {x}^2 + {y}^2 = {z}^2"
              f"  ({x*x + y*y == z*z})")
    print("  the explicit family  a(k^2) + a((k+1)^2) = 2 a(k^2+k+1):")
    for k in range(1, 7):
        lhs = anti_fib(k * k) + anti_fib((k + 1) ** 2)
        rhs = 2 * anti_fib(k * k + k + 1)
        diff = anti_fib(k * k + k + 1) - anti_fib(k * k)
        print(f"    k={k}:  indices ({k*k}, {k*k+k+1}, {(k+1)**2}),"
              f"  {lhs} = {rhs} ({lhs == rhs}),"
              f"  common difference {diff} = 3 * {pyramidal(k)}"
              f" ({diff == 3 * pyramidal(k)})")

    rule("7.  Sums of two terms:  m <-> 8m - 14 a sum of two squares")
    agree = all(sum_of_two_criterion(m) == sum_of_two_bruteforce(m) for m in range(2, 400))
    print("  criterion agrees with brute force for 2 <= m < 400:", agree)
    bad = [m for m in range(2, 120) if not sum_of_two_criterion(m)]
    print("  non-representable m < 120:", bad)
    print("  of these, the ones with m = 1 or 7 (mod 9) are forced:",
          [m for m in bad if m % 9 in (1, 7)])
    print("  every m = 1 or 7 (mod 9) below 500 is non-representable:",
          all(not sum_of_two_criterion(m) for m in range(2, 500) if m % 9 in (1, 7)))
    K = 50
    cnt = sum(1 for m in range(9 * K + 10) if not sum_of_two_criterion(max(m, 2)))
    print(f"  K={K}: at least 2K = {2*K} non-representable below {9*K+10};"
          f" actual count = {cnt}  (density {cnt/(9*K+10):.3f} >= 2/9 = 0.222)")

    rule("8.  Additive basis of order four:  m is a sum of four terms iff m >= 4")
    print("  m  ->  indices (p,q,r,s) with a(p)+a(q)+a(r)+a(s) = m")
    for m in (4, 5, 7, 10, 19, 46, 100):
        idx = four_summand_decomposition(m)
        total = sum(anti_fib(i) for i in idx) if idx else None
        print(f"   {m:4d}  ->  {idx}   sum = {total}  ({total == m})")
    print("  m = 0,1,2,3 have no such representation:",
          [four_summand_decomposition(m) for m in range(4)])
    print("  order two is insufficient: m = 10, 19, 28 are sums of four but of no two:",
          [(m, sum_of_two_criterion(m)) for m in (10, 19, 28)])

    rule("9.  Prime divisor law:  p divides some term iff p = 7 or p = 1,2,4 (mod 7)")
    ps = primes_upto(120)
    ok = all(divides_some_term(p) == divisor_law(p) for p in ps)
    print("  law verified for all primes below 120:", ok)
    print("  divisors    :", [p for p in ps if divisor_law(p)])
    print("  non-divisors:", [p for p in ps if not divisor_law(p)])
    print("  (For the Fibonacci sequence every prime divides some term.)")

    rule("10.  Residue spectrum modulo an odd prime has exactly (p+1)/2 classes")
    for p in (3, 5, 7, 11, 13, 17, 19):
        s = spectrum(p)
        print(f"   p={p:3d}:  spectrum {s}  size {len(s)}  = (p+1)/2 = {(p+1)//2}"
              f"  ({len(s) == (p+1)//2})   omitted: "
              f"{[r for r in range(p) if r not in s]}")

    rule("11.  Minimal period modulo m:  m if m is odd, 2m if m is even")
    ok = all(minimal_period_bruteforce(m) == pisano_anti(m) for m in range(1, 26))
    print("  verified for 1 <= m <= 25:", ok)
    print("   m :", " ".join(f"{m:4d}" for m in range(1, 15)))
    print("  pi :", " ".join(f"{pisano_anti(m):4d}" for m in range(1, 15)))
    print("  multiplicative on coprime moduli, e.g. pi(3*4)=%d = pi(3)*pi(4)=%d;"
          % (pisano_anti(12), pisano_anti(3) * pisano_anti(4)))
    print("  but pi(2*2)=%d != pi(2)*pi(2)=%d, so coprimality is needed."
          % (pisano_anti(4), pisano_anti(2) ** 2))

    rule("12.  Exact gcd law:  gcd(a(n), a(n+1)) = 2 iff n = 2 (mod 4), else 1")
    gs = [gcd(anti_fib(n), anti_fib(n + 1)) for n in range(20)]
    print("  gcds for n = 0..19:", gs)
    ok = all(gcd(anti_fib(n), anti_fib(n + 1)) == (2 if n % 4 == 2 else 1)
             for n in range(5000))
    print("  law verified for n < 5000:", ok)
    print("  first failure of coprimality: gcd(a(2), a(3)) = gcd(2, 4) = 2,")
    print("  whereas consecutive Fibonacci numbers are always coprime.")

    rule("Summary")
    print("  Every claim above was checked numerically against brute force.")
    print("  All of them descend from one identity:  8 a(n) = (2n-1)^2 + 7.")


if __name__ == "__main__":
    main()
