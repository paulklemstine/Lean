"""
demo.py — The Fibonacci rank of apparition as one half of a Galois adjunction.

This self-contained script demonstrates, numerically, the results formalized in
`Catalog/Applications/FibonacciRankDuality.lean`:

  * fibRank(m): the least positive index k with m | F(k)  (the "rank of apparition").
  * The Law of Apparition / adjunction (★):  fibRank(m) | n  <=>  m | F(n).
  * The join law:        fibRank(lcm(a,b)) = lcm(fibRank(a), fibRank(b)).
  * The finite join law: fibRank(lcm_i a_i) = lcm_i fibRank(a_i).
  * Monotonicity:        a | b  =>  fibRank(a) | fibRank(b).
  * The meet sub-law:    fibRank(gcd(a,b)) | gcd(fibRank(a), fibRank(b)),
                         with the strictness witness (a,b) = (4,6).
  * Prime-index Carmichael: for prime p >= 3, every prime divisor of F(p) is primitive.

Run:  python3 demo.py
No third-party dependencies; pure standard library.
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import Dict, Iterable, List, Tuple


# --------------------------------------------------------------------------- #
# Fibonacci numbers and the rank of apparition
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0)=0, F(1)=1, F(n+2)=F(n+1)+F(n)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lcm(a: int, b: int) -> int:
    """Least common multiple (with lcm(0, x) = 0)."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def fib_rank(m: int) -> int:
    """
    fibRank(m): least positive k with m | F(k); returns 0 if m == 0.

    Implements RANK from the paper: advance the Fibonacci recurrence modulo m
    and stop at the first zero residue. Terminates within the Pisano period.
    """
    if m == 0:
        return 0
    if m == 1:
        return 1
    a, b = 0, 1  # (F(0) mod m, F(1) mod m)
    k = 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:  # a holds F(k) mod m
            return k


# --------------------------------------------------------------------------- #
# Factorization helpers (for primitive-divisor demonstrations)
# --------------------------------------------------------------------------- #
def factorize(n: int) -> Dict[int, int]:
    """Return the prime factorization of n >= 1 as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def prime_divisors(n: int) -> List[int]:
    """Sorted list of distinct prime divisors of n."""
    return sorted(factorize(n).keys()) if n > 1 else []


def is_prime(n: int) -> bool:
    return n >= 2 and len(factorize(n)) == 1 and next(iter(factorize(n).values())) == 1


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_rank_table(limit: int = 14) -> None:
    print("=" * 64)
    print(" Rank of apparition fibRank(m), and the index where m first appears")
    print("=" * 64)
    print(f"{'m':>3} | {'fibRank(m)':>10} | first F(fibRank(m))")
    print("-" * 64)
    for m in range(1, limit + 1):
        r = fib_rank(m)
        print(f"{m:>3} | {r:>10} | F({r}) = {fib(r)}  (divisible by {m}: {fib(r) % m == 0})")
    print()


def demo_law_of_apparition(m: int = 7, n_max: int = 40) -> None:
    print("=" * 64)
    print(f" Law of apparition (★):  m | F(n)  <=>  fibRank(m) | n   [m = {m}]")
    print("=" * 64)
    r = fib_rank(m)
    print(f"fibRank({m}) = {r}")
    ok = True
    hits = []
    for n in range(1, n_max + 1):
        lhs = fib(n) % m == 0          # m | F(n)
        rhs = (r != 0) and (n % r == 0)  # fibRank(m) | n
        if lhs:
            hits.append(n)
        ok = ok and (lhs == rhs)
    print(f"Indices n<= {n_max} with {m} | F(n): {hits}")
    print(f"Multiples of {r} up to {n_max}: {list(range(r, n_max + 1, r))}")
    print(f"Adjunction (★) verified for all n <= {n_max}: {ok}")
    print()


def demo_join_law(pairs: Iterable[Tuple[int, int]]) -> None:
    print("=" * 64)
    print(" Join law:  fibRank(lcm(a,b)) = lcm(fibRank(a), fibRank(b))")
    print("=" * 64)
    print(f"{'(a,b)':>10} | {'fibRank(lcm)':>12} | {'lcm(fibRank)':>12} | match")
    print("-" * 64)
    for a, b in pairs:
        left = fib_rank(lcm(a, b))
        right = lcm(fib_rank(a), fib_rank(b))
        print(f"{str((a, b)):>10} | {left:>12} | {right:>12} | {left == right}")
    print()


def demo_finite_join_law(family: List[int]) -> None:
    print("=" * 64)
    print(" Finite join law:  fibRank(lcm_i a_i) = lcm_i fibRank(a_i)")
    print("=" * 64)
    big_lcm = reduce(lcm, family)
    left = fib_rank(big_lcm)
    right = reduce(lcm, (fib_rank(a) for a in family))
    print(f"family               = {family}")
    print(f"lcm(family)          = {big_lcm}")
    print(f"fibRank(lcm family)  = {left}")
    print(f"lcm of fibRanks      = {right}")
    print(f"match                = {left == right}")
    print()


def demo_monotone_and_meet(pairs: Iterable[Tuple[int, int]]) -> None:
    print("=" * 64)
    print(" Monotonicity & meet sub-law")
    print("=" * 64)
    print("Monotone:  a | b  =>  fibRank(a) | fibRank(b)")
    for a, b in [(2, 6), (3, 12), (4, 8), (5, 20)]:
        assert b % a == 0
        rb, ra = fib_rank(b), fib_rank(a)
        print(f"  {a} | {b}: fibRank({a})={ra}, fibRank({b})={rb}, "
              f"{ra} | {rb} ? {rb % ra == 0}")
    print()
    print("Meet sub-law:  fibRank(gcd(a,b)) | gcd(fibRank(a), fibRank(b))")
    print(f"{'(a,b)':>10} | {'fR(gcd)':>8} | {'gcd(fR)':>8} | divides | equal")
    print("-" * 64)
    for a, b in pairs:
        left = fib_rank(gcd(a, b))
        right = gcd(fib_rank(a), fib_rank(b))
        divides = (right % left == 0) if left else False
        print(f"{str((a, b)):>10} | {left:>8} | {right:>8} | "
              f"{str(divides):>7} | {left == right}")
    print()
    print("Strictness witness (a,b)=(4,6): the meet law is NOT an equality.")
    a, b = 4, 6
    print(f"  gcd(4,6)=2, fibRank(2)={fib_rank(2)}")
    print(f"  gcd(fibRank(4),fibRank(6)) = gcd({fib_rank(4)},{fib_rank(6)}) "
          f"= {gcd(fib_rank(4), fib_rank(6))}")
    print(f"  {fib_rank(gcd(a,b))} divides {gcd(fib_rank(a), fib_rank(b))} but they differ.")
    print()


def demo_prime_index_carmichael(primes: List[int]) -> None:
    print("=" * 64)
    print(" Prime-index Carmichael: for prime p >= 3, every prime")
    print(" divisor of F(p) is primitive (fibRank(q) = p).")
    print("=" * 64)
    for p in primes:
        if not is_prime(p) or p < 3:
            continue
        fp = fib(p)
        qs = prime_divisors(fp)
        ranks = {q: fib_rank(q) for q in qs}
        all_primitive = all(r == p for r in ranks.values())
        print(f"p = {p}:  F({p}) = {fp}")
        print(f"   prime divisors and their ranks: {ranks}")
        print(f"   every prime divisor primitive (rank == {p})? {all_primitive}")
    print()


def main() -> None:
    demo_rank_table(limit=14)
    demo_law_of_apparition(m=7, n_max=40)
    demo_law_of_apparition(m=11, n_max=40)
    demo_join_law([(4, 11), (6, 10), (4, 6), (9, 14), (12, 35)])
    demo_finite_join_law([4, 6, 11])
    demo_monotone_and_meet([(4, 6), (6, 10), (8, 12), (15, 35)])
    demo_prime_index_carmichael([3, 5, 7, 11, 13, 17, 19, 23])
    print("All demonstrations complete. The Fibonacci numbers obey the adjunction.")


if __name__ == "__main__":
    main()
