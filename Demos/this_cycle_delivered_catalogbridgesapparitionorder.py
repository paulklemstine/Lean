"""
demo.py — Numerical demonstrations of the Apparition–Order Bridge.

The Apparition–Order Bridge states that for a base b and a prime p with
p ∤ b, the *entry point* (rank of apparition) of p in the Mersenne family
a(n) = b**n - 1 — the least n > 0 with p | b**n - 1 — equals the
multiplicative order of b modulo p.

This script verifies, with fully self-contained code (no external
dependencies), the following results from the paper:

  1. Stalk reduction:   p | b**n - 1  <=>  (b mod p)**n == 1  (mod p)
  2. The Bridge:        entry_point(b, p) == mult_order(b, p)
  3. Gluing:            { n<=N : p | b**n - 1 } == multiples of entry point
  4. Fermat descent:    entry_point(b, p) | (p - 1)
  5. Primitive prims:   p primitive divisor of b**n - 1  =>  p ≡ 1 (mod n)
  6. Fibonacci gluing:  Fibonacci apparition support is a progression.

Run:  python demo.py
"""

from __future__ import annotations

from typing import Dict, List, Optional


# ----------------------------------------------------------------------
# Basic number theory utilities (all inlined, no imports needed)
# ----------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
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


def gcd(a: int, b: int) -> int:
    """Greatest common divisor via the Euclidean algorithm."""
    while b:
        a, b = b, a % b
    return abs(a)


def lcm(a: int, b: int) -> int:
    """Least common multiple."""
    if a == 0 or b == 0:
        return 0
    return abs(a // gcd(a, b) * b)


def factorize(n: int) -> Dict[int, int]:
    """Return the prime factorization of n > 0 as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


# ----------------------------------------------------------------------
# The two sides of the Bridge
# ----------------------------------------------------------------------

def entry_point_naive(b: int, p: int, limit: int = 100000) -> Optional[int]:
    """
    GLOBAL side: the least n > 0 with p | b**n - 1, found by direct scan.

    This is the literal definition of the rank of apparition — an
    unbounded search (here capped at `limit`).
    """
    val = 1  # tracks b**n mod p, starting at b**0 = 1
    for n in range(1, limit + 1):
        val = (val * b) % p
        if (val - 1) % p == 0:  # p | b**n - 1
            return n
    return None


def mult_order(b: int, p: int) -> Optional[int]:
    """
    LOCAL side: the multiplicative order of b modulo p, computed by Fermat
    descent. Since order | p - 1, we factor p - 1 and strip prime factors.
    """
    b %= p
    if gcd(b, p) != 1:
        return None  # b is not a unit mod p
    order = p - 1
    for q in factorize(p - 1):
        while order % q == 0 and pow(b, order // q, p) == 1:
            order //= q
    return order


def stalk_reduction_holds(b: int, p: int, n: int) -> bool:
    """Verify (1): p | b**n - 1  <=>  (b mod p)**n == 1 (mod p)."""
    lhs = ((b ** n - 1) % p == 0)
    rhs = (pow(b % p, n, p) == 1)
    return lhs == rhs


def apparition_support(b: int, p: int, N: int) -> List[int]:
    """All n in 1..N with p | b**n - 1 (direct test)."""
    return [n for n in range(1, N + 1) if (pow(b % p, n, p) == 1)]


# ----------------------------------------------------------------------
# Fibonacci side
# ----------------------------------------------------------------------

def fib_mod(n: int, p: int) -> int:
    """F_n mod p (F_1 = F_2 = 1), fast doubling."""
    def _fib_pair(k: int) -> tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = _fib_pair(k >> 1)
        c = (a * ((2 * b - a) % p)) % p
        d = (a * a + b * b) % p
        if k & 1:
            return (d, (c + d) % p)
        return (c, d)
    return _fib_pair(n)[0]


def fib_entry_point(p: int, limit: int = 100000) -> Optional[int]:
    """Least n > 0 with p | F_n."""
    for n in range(1, limit + 1):
        if fib_mod(n, p) == 0:
            return n
    return None


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------

def demo_bridge(b: int, primes: List[int]) -> None:
    print(f"\n=== The Apparition-Order Bridge for b = {b} ===")
    print(f"{'p':>6} | {'entry point (global scan)':>26} | "
          f"{'order of b mod p (local)':>25} | match")
    print("-" * 76)
    for p in primes:
        if b % p == 0:
            continue
        e = entry_point_naive(b, p)
        o = mult_order(b, p)
        print(f"{p:>6} | {str(e):>26} | {str(o):>25} | {e == o}")


def demo_gluing(b: int, p: int, N: int) -> None:
    print(f"\n=== Gluing: support of {b}^n - 1 mod {p}, n <= {N} ===")
    e = mult_order(b, p)
    support = apparition_support(b, p, N)
    multiples = list(range(e, N + 1, e)) if e else []
    print(f"entry point e = {e}")
    print(f"support     = {support}")
    print(f"multiples   = {multiples}")
    print(f"equal?      = {support == multiples}")


def demo_fermat_descent(b: int, primes: List[int]) -> None:
    print(f"\n=== Fermat descent: entry point | (p - 1) for b = {b} ===")
    print(f"{'p':>6} | {'entry point':>12} | {'p - 1':>8} | divides?")
    print("-" * 46)
    for p in primes:
        if b % p == 0:
            continue
        e = mult_order(b, p)
        print(f"{p:>6} | {e:>12} | {p - 1:>8} | {(p - 1) % e == 0}")


def demo_primitive_divisors(b: int, n: int) -> None:
    print(f"\n=== Primitive divisors of {b}^{n} - 1 are = 1 (mod {n}) ===")
    value = b ** n - 1
    print(f"{b}^{n} - 1 = {value}")
    for p in sorted(factorize(value)):
        e = mult_order(b, p)
        primitive = (e == n)
        tag = "PRIMITIVE" if primitive else "earlier"
        cong = (p % n == 1)
        print(f"  prime {p:>6}: entry point {e:>3}  ({tag})"
              + (f"  ->  {p} = 1 (mod {n})? {cong}" if primitive else ""))


def demo_fibonacci(primes: List[int], N: int) -> None:
    print(f"\n=== Fibonacci apparition (rank of apparition) ===")
    print(f"{'p':>6} | {'entry point':>12} | support (n<=%d) is a progression?" % N)
    print("-" * 60)
    for p in primes:
        e = fib_entry_point(p)
        if e is None:
            continue
        support = [n for n in range(1, N + 1) if fib_mod(n, p) == 0]
        multiples = list(range(e, N + 1, e))
        print(f"{p:>6} | {e:>12} | {support == multiples}")


def main() -> None:
    primes = [p for p in range(3, 60) if is_prime(p)]

    demo_bridge(2, primes)
    demo_bridge(3, primes)

    demo_gluing(2, 7, 25)
    demo_gluing(3, 13, 30)

    demo_fermat_descent(2, primes)

    demo_primitive_divisors(2, 6)    # the famous Zsygmondy exception
    demo_primitive_divisors(2, 11)
    demo_primitive_divisors(3, 5)

    demo_fibonacci([2, 3, 5, 7, 11, 13, 17, 19], 60)

    # Sanity: stalk reduction over a grid.
    ok = all(stalk_reduction_holds(b, p, n)
             for b in (2, 3, 5) for p in primes for n in range(1, 12))
    print(f"\nStalk reduction verified on grid: {ok}")


if __name__ == "__main__":
    main()
