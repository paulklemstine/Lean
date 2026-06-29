"""Numerical demonstrations of the rank-of-apparition primitive-divisor criterion.

A strong divisibility sequence u : N -> N satisfies
    u(gcd(m, n)) = gcd(u(m), u(n))    for all m, n.
The Fibonacci sequence and every sequence u(n) = a**n - 1 are examples.

For a divisor p that appears in u, the *rank of apparition* is the least
positive index k with p | u(k):
    rank(u, p) = min { k > 0 : p | u(k) }.

This script demonstrates the four main results:
  * rank is the unique primitive index            (rank_primitive / isPrimitive_iff_eq_rank)
  * the criterion        p | u(m)  <=>  rank | m   (dvd_iff_rank_dvd)
  * the join law  (p|u(n) and q|u(n)) <=> lcm(rank p, rank q) | n
  * specializations to Fibonacci and to a**n - 1, and rank = multiplicative order.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List, Optional, Tuple


# ----------------------------------------------------------------------
# Strong divisibility sequences
# ----------------------------------------------------------------------

def fib(n: int) -> int:
    """The n-th Fibonacci number (fib(0) = 0, fib(1) = 1)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne_base(a: int) -> Callable[[int], int]:
    """Return the sequence n |-> a**n - 1 (a strong divisibility sequence)."""
    def u(n: int) -> int:
        return a ** n - 1
    return u


def lcm(a: int, b: int) -> int:
    """Least common multiple, with lcm(0, b) = 0."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


# ----------------------------------------------------------------------
# Core engine: appearance, rank, primitivity, the criterion
# ----------------------------------------------------------------------

def appears(u: Callable[[int], int], p: int, search_bound: int = 2000) -> bool:
    """Does p divide some u(k) for a positive k <= search_bound?"""
    return any(p != 0 and u(k) % p == 0 for k in range(1, search_bound + 1))


def rank(u: Callable[[int], int], p: int, search_bound: int = 2000) -> Optional[int]:
    """Rank of apparition: least positive k with p | u(k), or None if not found."""
    for k in range(1, search_bound + 1):
        if p != 0 and u(k) % p == 0:
            return k
    return None


def is_primitive(u: Callable[[int], int], p: int, n: int) -> bool:
    """p | u(n) and p divides none of u(1), ..., u(n-1)."""
    if n <= 0 or u(n) % p != 0:
        return False
    return all(u(k) % p != 0 for k in range(1, n))


def divides_criterion(u: Callable[[int], int], p: int, m: int,
                      search_bound: int = 2000) -> Optional[bool]:
    """Predict whether p | u(m) using ONLY the index m and rank(u, p).

    By the criterion p | u(m) <=> rank(u, p) | m, so we never compute u(m)."""
    r = rank(u, p, search_bound)
    if r is None:
        return None
    return m % r == 0


def joint_divides(u: Callable[[int], int], p: int, q: int, n: int,
                  search_bound: int = 2000) -> Optional[bool]:
    """Predict whether p | u(n) and q | u(n) using lcm of ranks (the join law)."""
    rp = rank(u, p, search_bound)
    rq = rank(u, q, search_bound)
    if rp is None or rq is None:
        return None
    return n % lcm(rp, rq) == 0


def multiplicative_order(a: int, p: int) -> Optional[int]:
    """Least k > 0 with a**k = 1 (mod p), for gcd(a, p) = 1; else None."""
    if gcd(a, p) != 1 or p <= 1:
        return None
    x, k = a % p, 1
    while x != 1:
        x = (x * a) % p
        k += 1
        if k > p:
            return None
    return k


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------

def demo_fibonacci_ranks() -> None:
    print("=" * 64)
    print("Fibonacci ranks of apparition and the criterion p | F_m <=> rank | m")
    print("=" * 64)
    for p in [2, 3, 5, 7, 11, 13, 17]:
        r = rank(fib, p)
        print(f"  rank(F, {p:2d}) = {r}  "
              f"(F_{r} = {fib(r)} = ... , {p} | F_{r}: {fib(r) % p == 0})")
        assert is_primitive(fib, p, r), "rank must be a primitive index"
    print()
    # Verify the criterion against brute force.
    print("  Verifying p | F_m  <=>  rank | m  for p in {7, 11}, m up to 40:")
    for p in [7, 11]:
        r = rank(fib, p)
        mismatches = [m for m in range(1, 41)
                      if (fib(m) % p == 0) != (m % r == 0)]
        print(f"    p = {p:2d}, rank = {r}: mismatches = {mismatches} "
              f"({'OK' if not mismatches else 'FAIL'})")
    print()


def demo_join_law() -> None:
    print("=" * 64)
    print("Join law: (p | F_n and q | F_n)  <=>  lcm(rank p, rank q) | n")
    print("=" * 64)
    pairs: List[Tuple[int, int]] = [(7, 11), (2, 3), (5, 13)]
    for p, q in pairs:
        rp, rq = rank(fib, p), rank(fib, q)
        L = lcm(rp, rq)
        first = next((n for n in range(1, 500)
                      if fib(n) % p == 0 and fib(n) % q == 0), None)
        print(f"  p={p:2d} (rank {rp}), q={q:2d} (rank {rq}): "
              f"lcm = {L}, first common index = {first}")
        assert first == L
        mismatches = [n for n in range(1, 200)
                      if (fib(n) % p == 0 and fib(n) % q == 0) != (n % L == 0)]
        print(f"    verified up to 200, mismatches = {mismatches}")
    print()


def demo_mersenne_and_order() -> None:
    print("=" * 64)
    print("Sequence a**n - 1: rank of apparition = multiplicative order of a mod p")
    print("=" * 64)
    a = 2
    u = mersenne_base(a)
    for p in [3, 5, 7, 11, 13, 17, 31]:
        r = rank(u, p)
        ordp = multiplicative_order(a, p)
        flag = "OK" if r == ordp else "FAIL"
        print(f"  rank(2^n - 1, {p:2d}) = {r}, ord_{p}(2) = {ordp}  [{flag}]")
        assert r == ordp
    print()
    # The criterion for 2^n - 1.
    print("  Criterion  7 | 2^m - 1  <=>  3 | m:")
    for m in range(1, 13):
        lhs = (2 ** m - 1) % 7 == 0
        rhs = m % 3 == 0
        print(f"    m={m:2d}: 7 | 2^m-1 = {str(lhs):5s}  3 | m = {str(rhs):5s}  "
              f"{'OK' if lhs == rhs else 'FAIL'}")
    print()


def demo_criterion_saves_work() -> None:
    print("=" * 64)
    print("The criterion replaces a huge computation by a tiny one")
    print("=" * 64)
    p, m = 7, 800  # F_800 has 167 digits
    predicted = divides_criterion(fib, p, m)
    actual = fib(m) % p == 0
    print(f"  Does {p} divide F_{m}?")
    print(f"    via criterion (rank {rank(fib, p)} | {m}): {predicted}")
    print(f"    via direct check on the {len(str(fib(m)))}-digit number: {actual}")
    assert predicted == actual
    print()


if __name__ == "__main__":
    demo_fibonacci_ranks()
    demo_join_law()
    demo_mersenne_and_order()
    demo_criterion_saves_work()
    print("All demonstrations passed.")
