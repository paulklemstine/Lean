"""
demo.py - Numerical demonstration of the Rank of Apparition spine theory.

This self-contained script illustrates the main results of
"The Rank of Apparition as the Spine of Fibonacci Primitive-Divisor Theory":

  * Existence of the rank of apparition for every positive modulus.
  * The SPINE:        m | F_n  <=>  rank(m) | n.
  * Order morphism:   b | a    =>   rank(b) | rank(a).
  * Fixed-point law:  rank(F_k) = k        (k >= 3).
  * Divisibility mirror:  F_a | F_b  <=>  a | b   (a >= 3).
  * Carmichael's prime case: for prime p >= 3, F_p has a primitive prime divisor.
  * Exact apparition density: #{n <= N : m | F_n} = floor(N / rank(m)).

Every function is inlined; no external dependencies beyond the standard library.
"""

from __future__ import annotations

from math import gcd, isqrt
from functools import lru_cache
from typing import Dict, Iterator, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Fibonacci numbers                                                           #
# --------------------------------------------------------------------------- #
@lru_cache(maxsize=None)
def fib(n: int) -> int:
    """Return the n-th Fibonacci number F_n with F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_mod(n: int, m: int) -> int:
    """Return F_n mod m, computed iteratively (cheap, avoids huge integers)."""
    if m == 1:
        return 0
    a, b = 0, 1
    for _ in range(n):
        a, b = b, (a + b) % m
    return a % m


# --------------------------------------------------------------------------- #
# Rank of apparition                                                          #
# --------------------------------------------------------------------------- #
def fib_rank(m: int, search_limit: int = 10 ** 6) -> int:
    """
    Return the rank of apparition of m: the least k > 0 with m | F_k.

    Existence is guaranteed for every m >= 1 (Theorem 3.3); search_limit is a
    safety bound (the rank never exceeds m^2 by the pigeonhole argument).
    """
    if m <= 0:
        raise ValueError("rank of apparition requires a positive modulus")
    limit = min(search_limit, m * m + 1)
    for k in range(1, limit + 1):
        if fib_mod(k, m) == 0:
            return k
    raise RuntimeError(f"no rank found below {limit} (should be impossible)")


# --------------------------------------------------------------------------- #
# Prime factorization helpers (for Carmichael's prime case)                   #
# --------------------------------------------------------------------------- #
def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    for d in range(3, isqrt(n) + 1, 2):
        if n % d == 0:
            return False
    return True


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


def primitive_prime_divisors(n: int) -> List[int]:
    """
    Return the primitive prime divisors of F_n: primes q with rank(q) = n,
    i.e. primes dividing F_n but no earlier Fibonacci number.
    """
    if n == 0:
        return []
    return [q for q in prime_factors(fib(n)) if fib_rank(q) == n]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_ranks_table() -> None:
    print("=" * 64)
    print("Rank of apparition  rank(m) = least k>0 with m | F_k")
    print("=" * 64)
    print(f"{'m':>4} | {'first F divisible':>20} | {'rank(m)':>8}")
    print("-" * 64)
    for m in [1, 2, 3, 4, 5, 6, 7, 8, 11, 13, 17, 100]:
        r = fib_rank(m)
        print(f"{m:>4} | F_{r:<2} = {fib(r):>14} | {r:>8}")
    print()


def demo_spine(moduli: List[int], n_max: int = 30) -> None:
    print("=" * 64)
    print("THE SPINE:  m | F_n  <=>  rank(m) | n   (verified for all n <= "
          f"{n_max})")
    print("=" * 64)
    for m in moduli:
        r = fib_rank(m)
        divides_fib = {n for n in range(1, n_max + 1) if fib_mod(n, m) == 0}
        multiples = {n for n in range(1, n_max + 1) if n % r == 0}
        ok = divides_fib == multiples
        print(f"  m={m:>3}  rank={r:>2}  "
              f"{{n : m|F_n}} = {sorted(divides_fib)}")
        print(f"          multiples of rank = {sorted(multiples)}   "
              f"--> {'MATCH' if ok else 'MISMATCH!'}")
    print()


def demo_order_morphism(pairs: List[Tuple[int, int]]) -> None:
    print("=" * 64)
    print("ORDER MORPHISM:  b | a  =>  rank(b) | rank(a)")
    print("=" * 64)
    for b, a in pairs:
        assert a % b == 0, "require b | a"
        rb, ra = fib_rank(b), fib_rank(a)
        ok = ra % rb == 0
        print(f"  b={b:>3} | a={a:>3}   rank(b)={rb:>3}  rank(a)={ra:>3}   "
              f"rank(b)|rank(a)? {'YES' if ok else 'NO'}")
    print()


def demo_fixed_point(k_max: int = 14) -> None:
    print("=" * 64)
    print("FIXED-POINT LAW:  rank(F_k) = k   for k >= 3")
    print("=" * 64)
    for k in range(3, k_max + 1):
        fk = fib(k)
        r = fib_rank(fk)
        print(f"  k={k:>2}  F_k={fk:>6}  rank(F_k)={r:>2}   "
              f"{'OK' if r == k else 'FAIL'}")
    print()


def demo_divisibility_mirror(a_max: int = 8, b_max: int = 24) -> None:
    print("=" * 64)
    print("DIVISIBILITY MIRROR:  F_a | F_b  <=>  a | b   (a >= 3)")
    print("=" * 64)
    all_ok = True
    for a in range(3, a_max + 1):
        fa = fib(a)
        for b in range(1, b_max + 1):
            lhs = (fib(b) % fa == 0)
            rhs = (b % a == 0)
            if lhs != rhs:
                all_ok = False
                print(f"  COUNTEREXAMPLE a={a} b={b}")
    print(f"  Checked all 3<=a<={a_max}, 1<=b<={b_max}:  "
          f"{'biconditional holds everywhere' if all_ok else 'FAILED'}")
    print()


def demo_carmichael_prime_case(p_list: List[int]) -> None:
    print("=" * 64)
    print("CARMICHAEL (prime index):  for prime p>=3, F_p has a primitive "
          "prime divisor")
    print("=" * 64)
    for p in p_list:
        assert is_prime(p) and p >= 3
        prims = primitive_prime_divisors(p)
        print(f"  p={p:>3}  F_p={fib(p):>10}  "
              f"primitive prime divisors (rank = p): {prims}")
    print()


def demo_density(m: int, n_max: int = 1000) -> None:
    print("=" * 64)
    print("EXACT APPARITION DENSITY:  #{n<=N : m|F_n} = floor(N / rank(m))")
    print("=" * 64)
    r = fib_rank(m)
    for N in [10, 50, 100, 500, n_max]:
        count = sum(1 for n in range(1, N + 1) if fib_mod(n, m) == 0)
        predicted = N // r
        print(f"  m={m} rank={r}  N={N:>5}  observed={count:>5}  "
              f"floor(N/rank)={predicted:>5}  density~={count / N:.5f}  "
              f"1/rank={1 / r:.5f}")
    print()


def demo_carmichael_exceptions() -> None:
    print("=" * 64)
    print("Carmichael exceptions: indices n with NO primitive prime divisor")
    print("=" * 64)
    for n in range(1, 16):
        prims = primitive_prime_divisors(n)
        tag = "  <-- exception (no primitive divisor)" if not prims else ""
        print(f"  n={n:>2}  F_n={fib(n):>5}  primitive divisors={prims}{tag}")
    print("  (The only exceptions are n = 1, 2, 6, 12, with F_12 = 144 the "
          "famous one.)")
    print()


def main() -> None:
    demo_ranks_table()
    demo_spine([2, 3, 4, 7, 11], n_max=30)
    demo_order_morphism([(2, 4), (2, 6), (3, 6), (2, 8), (5, 10), (4, 12)])
    demo_fixed_point(14)
    demo_divisibility_mirror(8, 24)
    demo_carmichael_prime_case([3, 5, 7, 11, 13, 17, 19])
    demo_density(7, 1000)
    demo_carmichael_exceptions()


if __name__ == "__main__":
    main()
