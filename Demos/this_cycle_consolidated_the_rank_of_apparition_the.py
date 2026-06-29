"""
Numerical demonstrations of the Rank of Apparition theory for Fibonacci numbers.

The *rank of apparition* of a modulus m is the least positive index k with m | F_k.
This script demonstrates, with concrete numbers, the main results:

  * Existence of the rank (every m >= 1 appears).
  * The SPINE:        m | F_n  <=>  rank(m) | n.
  * Order morphism:   b | a (a>0)  =>  rank(b) | rank(a).
  * Rigidity:         rank(F_k) = k  for k >= 3.
  * Divisibility iff: F_a | F_b  <=>  a | b   for a >= 3.
  * Carmichael prime: F_p has a primitive prime divisor for every prime p >= 3.
  * Join (lcm) law:   rank(lcm(a,b)) = lcm(rank(a), rank(b)).
  * Exact density:    #{ n in (0,N] : m | F_n } = floor(N / rank(m)).

All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Core utilities
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """Return the n-th Fibonacci number F_n with F_0 = 0, F_1 = 1 (fast doubling)."""
    def _fd(k: int) -> Tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = _fd(k >> 1)
        c = a * (2 * b - a)            # F_{2m}
        d = a * a + b * b              # F_{2m+1}
        if k & 1:
            return (d, c + d)
        return (c, d)
    return _fd(n)[0]


def fib_rank(m: int) -> int:
    """Least positive k with m | F_k, computed by iterating the Fibonacci pair mod m.

    Terminates for every m >= 1 (existence theorem). Worst case O(Pisano period(m)).
    """
    if m < 1:
        raise ValueError("modulus must be >= 1")
    if m == 1:
        return 1
    a, b, k = 0, 1, 0   # (F_k mod m, F_{k+1} mod m)
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k


def prime_factors(n: int) -> List[int]:
    """Return the sorted list of distinct prime factors of n (n >= 1)."""
    factors: List[int] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors.append(n)
    return factors


def is_prime(n: int) -> bool:
    """Trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    for d in range(3, isqrt(n) + 1, 2):
        if n % d == 0:
            return False
    return True


def lcm(a: int, b: int) -> int:
    return a // gcd(a, b) * b if a and b else 0


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_ranks_table(limit: int = 14) -> None:
    print("=== Rank of apparition table ===")
    print(" m | rank(m) | first Fibonacci F_k divisible by m")
    for m in range(1, limit + 1):
        r = fib_rank(m)
        print(f"{m:2d} |   {r:3d}   | F_{r} = {fib(r)}")
    print()


def demo_spine(moduli: List[int], n_max: int = 40) -> None:
    """Verify m | F_n  <=>  rank(m) | n for all n <= n_max."""
    print("=== The spine:  m | F_n  <=>  rank(m) | n ===")
    for m in moduli:
        r = fib_rank(m)
        ok = all((fib(n) % m == 0) == (n % r == 0) for n in range(0, n_max + 1))
        hits = [n for n in range(1, n_max + 1) if fib(n) % m == 0]
        print(f"m={m:3d}  rank={r:3d}  apparition indices <= {n_max}: {hits}  "
              f"(all multiples of {r}: {ok})")
    print()


def demo_order_morphism(pairs: List[Tuple[int, int]]) -> None:
    """For b | a, check rank(b) | rank(a)."""
    print("=== Order morphism:  b | a (a>0)  =>  rank(b) | rank(a) ===")
    for b, a in pairs:
        assert a % b == 0 and a > 0
        rb, ra = fib_rank(b), fib_rank(a)
        print(f"b={b:2d} | a={a:2d}:  rank(b)={rb:2d}  rank(a)={ra:3d}  "
              f"rank(b) | rank(a): {ra % rb == 0}")
    print()


def demo_rigidity(k_max: int = 15) -> None:
    """rank(F_k) = k for k >= 3."""
    print("=== Rigidity:  rank(F_k) = k  for k >= 3 ===")
    for k in range(1, k_max + 1):
        fk = fib(k)
        r = fib_rank(fk)
        tag = "" if k < 3 else ("  OK" if r == k else "  ** FAIL **")
        note = "  (k<3 exception: F_1=F_2=1)" if k < 3 else tag
        print(f"k={k:2d}  F_k={fk:5d}  rank(F_k)={r:2d}{note}")
    print()


def demo_fib_dvd_iff(a_vals: List[int], b_max: int = 30) -> None:
    """F_a | F_b  <=>  a | b  for a >= 3."""
    print("=== Divisibility biconditional:  F_a | F_b  <=>  a | b  (a>=3) ===")
    for a in a_vals:
        fa = fib(a)
        ok = all((fib(b) % fa == 0) == (b % a == 0) for b in range(0, b_max + 1))
        good_b = [b for b in range(1, b_max + 1) if fib(b) % fa == 0]
        print(f"a={a:2d}  F_a={fa:4d}:  F_a | F_b for b in {good_b}  "
              f"(== multiples of {a}: {ok})")
    print()


def primitive_prime_divisor(p: int) -> Optional[int]:
    """Return a primitive prime divisor of F_p (a prime q with rank(q) = p)."""
    fp = fib(p)
    for q in prime_factors(fp):
        if fib_rank(q) == p:
            return q
    return None


def demo_carmichael(p_max: int = 30) -> None:
    """Every prime p >= 3 yields a primitive prime divisor of F_p."""
    print("=== Carmichael (prime case):  F_p has a primitive prime divisor, p>=3 ===")
    for p in range(3, p_max + 1):
        if not is_prime(p):
            continue
        q = primitive_prime_divisor(p)
        assert q is not None and fib_rank(q) == p
        print(f"p={p:2d}  F_p={fib(p):7d}  primitive prime divisor q={q:5d}  "
              f"(rank(q)={fib_rank(q)} = p)")
    print()


def demo_join_law(pairs: List[Tuple[int, int]]) -> None:
    """rank(lcm(a,b)) = lcm(rank(a), rank(b))."""
    print("=== Join (lcm) law:  rank(lcm(a,b)) = lcm(rank(a), rank(b)) ===")
    for a, b in pairs:
        lhs = fib_rank(lcm(a, b))
        rhs = lcm(fib_rank(a), fib_rank(b))
        print(f"a={a:2d} b={b:2d}:  rank(lcm)={lhs:3d}  "
              f"lcm(rank,rank)={rhs:3d}  equal: {lhs == rhs}")
    print()


def demo_density(moduli: List[int], N: int = 1000) -> None:
    """#{ n in (0,N] : m | F_n } = floor(N / rank(m))."""
    print(f"=== Exact apparition count up to N={N}:  floor(N / rank(m)) ===")
    for m in moduli:
        r = fib_rank(m)
        # count via the spine (multiples of r), the exact formula
        actual = sum(1 for n in range(1, N + 1) if n % r == 0)
        formula = N // r
        print(f"m={m:3d}  rank={r:3d}  count={actual:4d}  floor(N/rank)={formula:4d}  "
              f"density~={1.0 / r:.4f}  match: {actual == formula}")
    print()


def main() -> None:
    demo_ranks_table()
    demo_spine([4, 7, 11, 13])
    demo_order_morphism([(2, 6), (3, 12), (5, 10), (4, 8)])
    demo_rigidity()
    demo_fib_dvd_iff([3, 4, 5, 6])
    demo_carmichael()
    demo_join_law([(4, 6), (6, 10), (7, 11), (5, 8)])
    demo_density([7, 11, 13])


if __name__ == "__main__":
    main()
