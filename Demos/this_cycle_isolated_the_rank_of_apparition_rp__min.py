"""
Numerical demonstrations for:

    The Rank of Apparition for Strong Divisibility Sequences,
    and its Identification with the Multiplicative Order.

This script is fully self-contained (standard library only) and illustrates,
with concrete numbers, the four headline results:

  * Strong divisibility law          u(gcd(m,n)) = gcd(u(m), u(n))
  * The spine                        m | u(n)  <=>  seqRank(u, m) | n
  * Primitivity characterization     IsPrimitive(u, p, n)  <=>  seqRank(u, p) = n
  * The Mersenne order bridge        seqRank(n -> a^n - 1, m) = ord_m(a)

Run:  python demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List, Optional


# --------------------------------------------------------------------------- #
# Sequences
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0)=0, F(1)=1 (n >= 0)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne(a: int) -> Callable[[int], int]:
    """The Mersenne-type sequence n -> a^n - 1 for a fixed base a."""
    return lambda n: a ** n - 1


# --------------------------------------------------------------------------- #
# Core invariants
# --------------------------------------------------------------------------- #
def seq_rank(u: Callable[[int], int], m: int, bound: int = 5000) -> Optional[int]:
    """
    Rank of apparition: least k > 0 with m | u(k), searched up to `bound`.
    Returns None if no such k <= bound exists (m has no rank in range).
    """
    if m == 0:
        return None
    for k in range(1, bound + 1):
        if u(k) % m == 0:
            return k
    return None


def is_primitive(u: Callable[[int], int], p: int, n: int) -> bool:
    """p is a primitive divisor of u(n): divides u(n) but no earlier term."""
    if u(n) % p != 0:
        return False
    return all(u(k) % p != 0 for k in range(1, n))


def multiplicative_order(a: int, m: int) -> Optional[int]:
    """Least k > 0 with a^k = 1 (mod m); requires gcd(a, m) = 1, m > 1."""
    if m <= 1 or gcd(a, m) != 1:
        return None
    x, k = a % m, 1
    while x != 1:
        x = (x * a) % m
        k += 1
        if k > m:  # safety; order always divides phi(m) <= m
            return None
    return k


def prime_factors(n: int) -> List[int]:
    """Distinct prime factors of n (n >= 1)."""
    factors: List[int] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_strong_divisibility() -> None:
    print("=" * 70)
    print("1. STRONG DIVISIBILITY LAW   u(gcd(m,n)) = gcd(u(m), u(n))")
    print("=" * 70)
    pairs = [(12, 18), (10, 15), (9, 6), (14, 21)]
    print("\nFibonacci  F(gcd(m,n)) =?= gcd(F(m), F(n)):")
    for m, n in pairs:
        lhs = fib(gcd(m, n))
        rhs = gcd(fib(m), fib(n))
        print(f"  m={m:>2}, n={n:>2}:  F({gcd(m,n)})={lhs:<6}  gcd(F{m},F{n})={rhs:<6}  {'OK' if lhs==rhs else 'FAIL'}")
    a = 2
    u = mersenne(a)
    print(f"\nMersenne (a={a})  u(gcd) =?= gcd(u(m), u(n)):")
    for m, n in pairs:
        lhs = u(gcd(m, n))
        rhs = gcd(u(m), u(n))
        print(f"  m={m:>2}, n={n:>2}:  u({gcd(m,n)})={lhs:<8}  gcd={rhs:<8}  {'OK' if lhs==rhs else 'FAIL'}")


def demo_spine() -> None:
    print("\n" + "=" * 70)
    print("2. THE SPINE   m | F(n)  <=>  r(m) | n")
    print("=" * 70)
    for m in [7, 11, 4, 5, 8]:
        r = seq_rank(fib, m)
        print(f"\n  m = {m}:  rank of apparition r({m}) = {r}")
        ok = True
        for n in range(1, 25):
            divides = (fib(n) % m == 0)
            rank_divides = (n % r == 0)
            if divides != rank_divides:
                ok = False
        hits = [n for n in range(1, 25) if fib(n) % m == 0]
        print(f"     indices n<=24 with m|F(n): {hits}")
        print(f"     multiples of r({m}) up to 24: {[n for n in range(1,25) if n % r == 0]}")
        print(f"     spine holds for n<=24: {'YES' if ok else 'NO'}")


def demo_primitivity() -> None:
    print("\n" + "=" * 70)
    print("3. PRIMITIVITY  <=>  rank = index   (primitive prime divisors of F(n))")
    print("=" * 70)
    for n in range(3, 19):
        fn = fib(n)
        primitives = [p for p in prime_factors(fn) if seq_rank(fib, p) == n]
        verified = all(is_primitive(fib, p, n) for p in primitives)
        flag = "" if primitives else "   <-- no primitive divisor (n in {6,12} are the exceptions)"
        print(f"  F({n:>2}) = {fn:<8}  primitive primes {primitives}"
              f"  (rank==index verified: {verified}){flag}")


def demo_order_bridge() -> None:
    print("\n" + "=" * 70)
    print("4. THE BRIDGE   seqRank(n -> a^n - 1, m) = ord_m(a)")
    print("=" * 70)
    cases = [(2, 7), (2, 9), (2, 11), (3, 7), (3, 10), (5, 12), (10, 13)]
    print(f"\n  {'a':>3} {'m':>3} {'seqRank(a^n-1, m)':>18} {'ord_m(a)':>10}   match")
    print("  " + "-" * 50)
    for a, m in cases:
        if gcd(a, m) != 1:
            continue
        r = seq_rank(mersenne(a), m)
        o = multiplicative_order(a, m)
        print(f"  {a:>3} {m:>3} {str(r):>18} {str(o):>10}   {'OK' if r == o else 'FAIL'}")
    print("\n  Corollary check: ord_m(a) divides Euler phi(m).")
    def euler_phi(m: int) -> int:
        return sum(1 for k in range(1, m + 1) if gcd(k, m) == 1)
    for a, m in cases:
        if gcd(a, m) != 1:
            continue
        o = multiplicative_order(a, m)
        ph = euler_phi(m)
        print(f"    a={a}, m={m}:  ord={o}, phi(m)={ph}, ord | phi: {'YES' if ph % o == 0 else 'NO'}")


def main() -> None:
    demo_strong_divisibility()
    demo_spine()
    demo_primitivity()
    demo_order_bridge()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
