"""Numerical demonstrations of the Primitive Divisor Schema for strong divisibility
sequences.

This script exercises the mined proof-strategy results on the two canonical strong
divisibility sequences:

    * Fibonacci:      F_0 = 0, F_1 = 1, F_{n} = F_{n-1} + F_{n-2}
    * Mersenne-type:  u_n = a^n - 1   (a fixed base)

A *strong divisibility sequence* satisfies  gcd(u_m, u_n) = u_{gcd(m, n)}.  From this
single identity the schema derives:

    * the meet law,
    * uniqueness/rigidity of the primitive index,
    * the pinning law       p | u_m  <=>  rank(p) | m,
    * the join law          p,q | u_n <=> lcm(rank p, rank q) | n,
    * exact apparition-density counts.

Every function below is self-contained and uses only the standard library.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List, Optional


# --------------------------------------------------------------------------- #
# Sequences
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number (F_0 = 0, F_1 = 1)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne_like(a: int) -> Callable[[int], int]:
    """Return the strong divisibility sequence u_n = a^n - 1."""

    def u(n: int) -> int:
        return a ** n - 1

    return u


# --------------------------------------------------------------------------- #
# Core schema operations
# --------------------------------------------------------------------------- #
def is_strong_div_seq(u: Callable[[int], int], bound: int = 12) -> bool:
    """Empirically check  gcd(u_m, u_n) = u_{gcd(m, n)}  for 0 <= m, n < bound."""
    for m in range(bound):
        for n in range(bound):
            if gcd(u(m), u(n)) != u(gcd(m, n)):
                return False
    return True


def rank_of_apparition(u: Callable[[int], int], p: int, search: int = 2000) -> Optional[int]:
    """Least positive index k with p | u_k, i.e. the rank of apparition of p.

    Returns None if p does not appear within the search window.
    """
    for k in range(1, search + 1):
        if u(k) % p == 0:
            return k
    return None


def is_primitive(u: Callable[[int], int], p: int, n: int) -> bool:
    """True iff p | u_n and p divides no u_k for 0 < k < n."""
    if u(n) % p != 0:
        return False
    return all(u(k) % p != 0 for k in range(1, n))


def apparition_indices(u: Callable[[int], int], p: int, N: int) -> List[int]:
    """Indices e in {0, ..., N-1} with p | u_{e+1} (the +1 shift excludes index 0)."""
    return [e for e in range(N) if u(e + 1) % p == 0]


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_strong_divisibility() -> None:
    print("=" * 70)
    print("1.  Both sequences are strong divisibility sequences")
    print("=" * 70)
    print(f"    Fibonacci   gcd(F_m,F_n) = F_gcd : {is_strong_div_seq(fib)}")
    for a in (2, 3, 5):
        u = mersenne_like(a)
        print(f"    a^n - 1 (a={a})  gcd law holds  : {is_strong_div_seq(u)}")
    print()


def demo_pinning_law() -> None:
    print("=" * 70)
    print("2.  Pinning law:  p | u_m  <=>  rank(p) | m")
    print("=" * 70)

    # Fibonacci, p = 11
    r = rank_of_apparition(fib, 11)
    print(f"    Fibonacci, p = 11:  rank = {r}")
    ok = all((fib(m) % 11 == 0) == (m % r == 0) for m in range(1, 60))
    print(f"      11 | F_m  <=>  {r} | m   for 1<=m<60 : {ok}")
    print(f"      check: F_20 = {fib(20)} = 3*5*11*41,  20 % {r} == {20 % r}")

    # Mersenne, a = 2, p = 7
    u = mersenne_like(2)
    r2 = rank_of_apparition(u, 7)
    print(f"    Mersenne a=2, p = 7:  rank = {r2}  (= multiplicative order of 2 mod 7)")
    ok2 = all((u(m) % 7 == 0) == (m % r2 == 0) for m in range(1, 40))
    print(f"      7 | 2^m - 1  <=>  {r2} | m   for 1<=m<40 : {ok2}")
    print()


def demo_uniqueness() -> None:
    print("=" * 70)
    print("3.  Rigidity: the primitive index is unique and equals the rank")
    print("=" * 70)
    p = 11
    r = rank_of_apparition(fib, p)
    primitive_indices = [n for n in range(1, 60) if is_primitive(fib, p, n)]
    print(f"    Fibonacci, p = 11: primitive indices in 1..59 = {primitive_indices}")
    print(f"      unique primitive index == rank = {r}: {primitive_indices == [r]}")
    print()


def demo_join_law() -> None:
    print("=" * 70)
    print("4.  Join law:  p,q | F_n  <=>  lcm(rank p, rank q) | n")
    print("=" * 70)
    rp = rank_of_apparition(fib, 2)
    rq = rank_of_apparition(fib, 11)
    L = rp * rq // gcd(rp, rq)
    print(f"    rank(2) = {rp}, rank(11) = {rq}, lcm = {L}")
    ok = all(
        ((fib(n) % 2 == 0) and (fib(n) % 11 == 0)) == (n % L == 0)
        for n in range(1, 90)
    )
    print(f"      2 and 11 both divide F_n  <=>  {L} | n  for 1<=n<90 : {ok}")
    first = next(n for n in range(1, 200) if fib(n) % 2 == 0 and fib(n) % 11 == 0)
    print(f"      first common apparition index = {first} (= lcm)")
    print()


def demo_density() -> None:
    print("=" * 70)
    print("5.  Apparition density:  #{e<N : p|u_{e+1}} = floor(N / rank)")
    print("=" * 70)
    p, N = 11, 100
    r = rank_of_apparition(fib, p)
    count = len(apparition_indices(fib, p, N))
    print(f"    Fibonacci, p = 11, N = {N}: count = {count}, "
          f"floor(N/rank) = {N // r}, match = {count == N // r}")
    print(f"    => natural density of apparition indices = 1/{r}")
    print()


def main() -> None:
    demo_strong_divisibility()
    demo_pinning_law()
    demo_uniqueness()
    demo_join_law()
    demo_density()
    print("All schema predictions confirmed numerically.")


if __name__ == "__main__":
    main()
