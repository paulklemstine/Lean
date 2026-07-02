"""Numerical demonstrations for Stern's diatomic sequence.

This self-contained script reproduces and checks the three main results:

  1. Coprimality of consecutive values:  gcd(s(n), s(n+1)) = 1.
  2. Counting along all-ones indices:     s(2**n - 1) = n,  and  s(2**n) = 1.
  3. The Stern-Fibonacci bridge:          s(J(n)) = F(2n),  s(2*J(n)+1) = F(2n+1),
                                          where  J(n) = (4**n - 1) // 3.

Stern's diatomic sequence s is defined by
    s(0) = 0, s(1) = 1,
    s(2n)   = s(n),
    s(2n+1) = s(n) + s(n+1).

Run with:  python demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List


# ---------------------------------------------------------------------------
# Core sequence
# ---------------------------------------------------------------------------

def stern_table(limit: int) -> List[int]:
    """Return [s(0), s(1), ..., s(limit)] by linear bottom-up tabulation."""
    s: List[int] = [0] * (limit + 1)
    if limit >= 1:
        s[1] = 1
    for k in range(1, limit // 2 + 1):
        if 2 * k <= limit:
            s[2 * k] = s[k]
        if 2 * k + 1 <= limit:
            s[2 * k + 1] = s[k] + s[k + 1]
    return s


def stern(n: int, memo: Dict[int, int] | None = None) -> int:
    """Evaluate s(n) directly by the defining recursion with memoization."""
    if memo is None:
        memo = {0: 0, 1: 1}
    if n in memo:
        return memo[n]
    if n % 2 == 0:
        value = stern(n // 2, memo)
    else:
        value = stern(n // 2, memo) + stern(n // 2 + 1, memo)
    memo[n] = value
    return value


def fibonacci(k: int) -> int:
    """Return F(k) with F(0)=0, F(1)=1."""
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


def jacobsthal(n: int) -> int:
    """Return J(n) = (4**n - 1) // 3, the base-4 alternating-bit index."""
    return (4 ** n - 1) // 3


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_prefix(limit: int = 19) -> None:
    s = stern_table(limit)
    print(f"First {limit + 1} values of Stern's sequence:")
    print("  " + ", ".join(map(str, s)))


def demo_coprimality(limit: int = 5000) -> None:
    s = stern_table(limit)
    ok = all(gcd(s[n], s[n + 1]) == 1 for n in range(limit))
    print(f"Coprimality gcd(s(n), s(n+1)) == 1 for 0 <= n < {limit}:  {ok}")


def demo_counting(depth: int = 12) -> None:
    ones = [stern(2 ** n - 1) for n in range(depth)]
    powers = [stern(2 ** n) for n in range(depth)]
    print(f"s(2**n - 1) for n=0..{depth-1}:  {ones}")
    print(f"   expected  n:                  {list(range(depth))}")
    print(f"s(2**n)     for n=0..{depth-1}:  {powers}")
    print(f"   expected  1:                  {[1] * depth}")
    assert ones == list(range(depth))
    assert powers == [1] * depth


def demo_fibonacci_bridge(depth: int = 8) -> None:
    a = [stern(jacobsthal(n)) for n in range(depth)]
    b = [stern(2 * jacobsthal(n) + 1) for n in range(depth)]
    fa = [fibonacci(2 * n) for n in range(depth)]
    fb = [fibonacci(2 * n + 1) for n in range(depth)]
    print(f"s(J(n))       = {a}")
    print(f"F(2n)         = {fa}")
    print(f"s(2*J(n)+1)   = {b}")
    print(f"F(2n+1)       = {fb}")
    assert a == fa and b == fb
    print("Stern-Fibonacci bridge verified:  s(J(n))=F(2n),  s(2J(n)+1)=F(2n+1).")


def demo_row_sums(depth: int = 8) -> None:
    print("Dyadic row sums (conjecture: sum over one level = 3**k):")
    for k in range(depth):
        total = sum(stern(2 ** k + i) for i in range(2 ** k))
        print(f"  k={k}:  sum = {total},  3**k = {3 ** k},  match = {total == 3 ** k}")


if __name__ == "__main__":
    demo_prefix()
    print()
    demo_coprimality()
    print()
    demo_counting()
    print()
    demo_fibonacci_bridge()
    print()
    demo_row_sums()
