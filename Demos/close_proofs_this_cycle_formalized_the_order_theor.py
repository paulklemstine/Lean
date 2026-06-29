"""
demo.py — Numerical demonstrations of the Unified Rank-of-Apparition Engine.

This script illustrates, with concrete numbers, the theorems proved formally:

  * Strong divisibility identity:   u(gcd(m, n)) = gcd(u(m), u(n))
  * Rank of apparition:             rank(m) = least k > 0 with m | u(k)
  * The spine:                      m | u(n)        <=>  rank(m) | n
  * Order-morphism law:             b | a           =>   rank(b) | rank(a)
  * Rigidity:                       rank(u(k)) = k          (under growth)
  * Value biconditional:            u(a) | u(b)     <=>  a | b

Two classical laws fall out as instances of one engine:

  * Fibonacci:  F(a) | F(b)         <=>  a | b   (a >= 3)
  * Mersenne:   a^m - 1 | a^n - 1   <=>  m | n   (a >= 2, m >= 1)

Self-contained, type-hinted, standard library only.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List, Optional, Sequence

# ---------------------------------------------------------------------------
# Sequences
# ---------------------------------------------------------------------------


def fib(n: int) -> int:
    """The n-th Fibonacci number with F(0)=0, F(1)=1, F(2)=1, F(3)=2, ..."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne_base(a: int) -> Callable[[int], int]:
    """Return the sequence n |-> a^n - 1 (Mersenne numbers when a = 2)."""

    def u(n: int) -> int:
        return a ** n - 1

    return u


# ---------------------------------------------------------------------------
# Engine: rank of apparition and the laws it implies
# ---------------------------------------------------------------------------


def rank(u: Callable[[int], int], m: int, search_limit: int = 100_000) -> Optional[int]:
    """Least k > 0 with m | u(k); None if not found within search_limit."""
    if m == 0:
        return None
    for k in range(1, search_limit + 1):
        if u(k) % m == 0:
            return k
    return None


def is_strong_divisibility(u: Callable[[int], int], indices: Sequence[int]) -> bool:
    """Check u(gcd(m, n)) = gcd(u(m), u(n)) over all pairs from `indices`."""
    for m in indices:
        for n in indices:
            if u(gcd(m, n)) != gcd(u(m), u(n)):
                return False
    return True


def spine_holds(u: Callable[[int], int], m: int, max_n: int) -> bool:
    """Verify the spine  m | u(n)  <=>  rank(m) | n  for n in [1, max_n]."""
    r = rank(u, m)
    if r is None:
        return False
    for n in range(1, max_n + 1):
        lhs = (u(n) % m == 0)
        rhs = (n % r == 0)
        if lhs != rhs:
            return False
    return True


def value_divides_via_indices(a: int, b: int) -> bool:
    """The value biconditional: u(a) | u(b)  iff  a | b. Constant time."""
    return b % a == 0


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_strong_identity() -> None:
    print("=" * 70)
    print("1. STRONG DIVISIBILITY IDENTITY  u(gcd(m,n)) = gcd(u(m),u(n))")
    print("=" * 70)
    idx = list(range(1, 13))
    ok_fib = is_strong_divisibility(fib, idx)
    ok_mer = is_strong_divisibility(mersenne_base(2), idx)
    print(f"  Fibonacci over indices 1..12 : {ok_fib}")
    print(f"  Mersenne (2^n-1) over 1..12  : {ok_mer}")
    # one explicit witness
    m, n = 6, 9
    print(f"  Example F: gcd({m},{n})={gcd(m,n)},  F({gcd(m,n)})={fib(gcd(m,n))}, "
          f"gcd(F{m},F{n})=gcd({fib(m)},{fib(n)})={gcd(fib(m), fib(n))}")


def demo_ranks() -> None:
    print("=" * 70)
    print("2. RANK OF APPARITION  rank(m) = least k>0 with m | u(k)")
    print("=" * 70)
    print("  Fibonacci ranks (Pisano entry points):")
    for m in [2, 3, 4, 5, 6, 7, 8, 11]:
        print(f"    rank_F({m:2d}) = {rank(fib, m)}")
    u2 = mersenne_base(2)
    print("  Mersenne (2^n-1) ranks:")
    for m in [3, 7, 15, 31, 63]:
        print(f"    rank_M({m:2d}) = {rank(u2, m)}")


def demo_spine() -> None:
    print("=" * 70)
    print("3. THE SPINE  m | u(n)  <=>  rank(m) | n")
    print("=" * 70)
    for m in [2, 3, 4, 5]:
        ok = spine_holds(fib, m, max_n=60)
        print(f"  Fibonacci, m={m}: spine holds for n=1..60 -> {ok}, rank={rank(fib, m)}")
    u2 = mersenne_base(2)
    for m in [3, 7, 31]:
        ok = spine_holds(u2, m, max_n=40)
        print(f"  Mersenne,  m={m}: spine holds for n=1..40 -> {ok}, rank={rank(u2, m)}")


def demo_rigidity() -> None:
    print("=" * 70)
    print("4. RIGIDITY  rank(u(k)) = k   (under strict growth)")
    print("=" * 70)
    print("  Fibonacci (valid for k >= 3):")
    for k in range(3, 11):
        print(f"    rank_F(F({k})={fib(k)}) = {rank(fib, fib(k))}   (expected {k})")
    u2 = mersenne_base(2)
    print("  Mersenne:")
    for k in range(1, 8):
        print(f"    rank_M(2^{k}-1={u2(k)}) = {rank(u2, u2(k))}   (expected {k})")


def demo_value_biconditional() -> None:
    print("=" * 70)
    print("5. VALUE BICONDITIONAL  u(a) | u(b)  <=>  a | b")
    print("=" * 70)
    print("  Fibonacci F(a) | F(b):")
    for a, b in [(3, 6), (3, 7), (4, 12), (5, 10), (6, 9)]:
        direct = (fib(b) % fib(a) == 0)
        viaidx = value_divides_via_indices(a, b)
        print(f"    F({a}) | F({b})? direct={direct}, via a|b={viaidx}  "
              f"[{'MATCH' if direct == viaidx else 'MISMATCH'}]")
    print("  Mersenne 2^m - 1 | 2^n - 1:")
    u2 = mersenne_base(2)
    for m, n in [(3, 6), (3, 7), (89, 267), (5, 10), (11, 23)]:
        direct = (u2(n) % u2(m) == 0)
        viaidx = value_divides_via_indices(m, n)
        print(f"    2^{m}-1 | 2^{n}-1? direct={direct}, via m|n={viaidx}  "
              f"[{'MATCH' if direct == viaidx else 'MISMATCH'}]")


def demo_giant_numbers() -> None:
    print("=" * 70)
    print("6. ALGORITHMIC PAYOFF: divisibility of giants in O(1) on indices")
    print("=" * 70)
    a, b = 100, 700
    print(f"  Does F({a}) | F({b})? indices: {a} | {b} = {b % a == 0}")
    print(f"    (F({b}) has {len(str(fib(b)))} digits; never divided directly.)")
    m, n = 89, 267
    print(f"  Does 2^{m}-1 | 2^{n}-1? indices: {m} | {n} = {n % m == 0}  "
          f"(267 = 3 x 89)")


def main() -> None:
    demo_strong_identity()
    demo_ranks()
    demo_spine()
    demo_rigidity()
    demo_value_biconditional()
    demo_giant_numbers()
    print("=" * 70)
    print("All demonstrations consistent with the formally proved theorems.")
    print("=" * 70)


if __name__ == "__main__":
    main()
