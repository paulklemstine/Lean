"""
demo.py — The rank of apparition as a join-semilattice morphism.

This script demonstrates, numerically, the main results of the package:

  * the rank of apparition for strong divisibility sequences (Fibonacci and
    the Mersenne-type sequence n -> a^n - 1),
  * the spine biconditional   m | u(n)  <=>  rank(m) | n,
  * the JOIN LAW              rank(lcm(a,b)) = lcm(rank(a), rank(b)),
  * the coprime law           rank(a*b) = lcm(rank(a), rank(b)),
  * the FAILURE of the dual meet law for gcd.

All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List, Optional, Tuple


# --------------------------------------------------------------------------- #
#  Strong divisibility sequences
# --------------------------------------------------------------------------- #
def fib(k: int) -> int:
    """The k-th Fibonacci number (F(0)=0, F(1)=1, F(2)=1, ...)."""
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


def mersenne_seq(a: int) -> Callable[[int], int]:
    """Return the strong divisibility sequence  k -> a^k - 1  (a >= 2)."""
    def u(k: int) -> int:
        return a**k - 1
    return u


def lcm(a: int, b: int) -> int:
    """Least common multiple of two natural numbers (lcm(0, b) = 0)."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


# --------------------------------------------------------------------------- #
#  Rank of apparition
# --------------------------------------------------------------------------- #
def rank(u: Callable[[int], int], m: int, limit: int = 100_000) -> Optional[int]:
    """
    The rank of apparition of m in the sequence u:
    the least k > 0 with m | u(k), or None if none is found below `limit`.
    """
    if m == 0:
        return None
    for k in range(1, limit + 1):
        if u(k) % m == 0:
            return k
    return None


# --------------------------------------------------------------------------- #
#  Verification helpers
# --------------------------------------------------------------------------- #
def check_spine(u: Callable[[int], int], m: int, n_max: int = 60) -> bool:
    """Verify the spine:  m | u(n)  <=>  rank(m) | n,  for 0 <= n <= n_max."""
    r = rank(u, m)
    assert r is not None
    for n in range(n_max + 1):
        lhs = (u(n) % m == 0)
        rhs = (n % r == 0)
        if lhs != rhs:
            return False
    return True


def check_join_law(u: Callable[[int], int], a: int, b: int) -> Tuple[int, int, int, int, bool]:
    """
    Return (rank a, rank b, rank(lcm a b), lcm(rank a, rank b), equal?)
    verifying  rank(lcm(a,b)) = lcm(rank(a), rank(b)).
    """
    ra = rank(u, a)
    rb = rank(u, b)
    r_lcm = rank(u, lcm(a, b))
    assert ra is not None and rb is not None and r_lcm is not None
    predicted = lcm(ra, rb)
    return ra, rb, r_lcm, predicted, r_lcm == predicted


def check_meet_law(u: Callable[[int], int], a: int, b: int) -> Tuple[int, int, bool]:
    """
    Compare rank(gcd(a,b)) with gcd(rank a, rank b).
    Returns (rank(gcd a b), gcd(rank a, rank b), equal?).
    The dual MEET law is expected to FAIL in general.
    """
    ra = rank(u, a)
    rb = rank(u, b)
    r_gcd = rank(u, gcd(a, b))
    assert ra is not None and rb is not None and r_gcd is not None
    return r_gcd, gcd(ra, rb), r_gcd == gcd(ra, rb)


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_fibonacci_ranks() -> None:
    print("=" * 70)
    print("Fibonacci ranks of apparition  rank(m) = least k>0 with m | F(k)")
    print("=" * 70)
    print(f"{'m':>4} | {'rank(m)':>8} | first Fibonacci multiple F(rank)")
    print("-" * 70)
    for m in range(1, 16):
        r = rank(fib, m)
        print(f"{m:>4} | {r:>8} | F({r}) = {fib(r)}")
    print()


def demo_spine() -> None:
    print("=" * 70)
    print("The SPINE:   m | F(n)  <=>  rank(m) | n")
    print("=" * 70)
    for m in [2, 3, 5, 7, 12]:
        ok = check_spine(fib, m)
        r = rank(fib, m)
        print(f"  m = {m:>2}:  rank = {r:>2}   spine holds for n in [0,60]: {ok}")
    print()


def demo_join_law_fibonacci() -> None:
    print("=" * 70)
    print("JOIN LAW (Fibonacci):  rank(lcm(a,b)) = lcm(rank(a), rank(b))")
    print("=" * 70)
    pairs = [(2, 3), (2, 5), (3, 4), (4, 6), (6, 10), (7, 11), (8, 9)]
    print(f"{'a':>3} {'b':>3} | {'rk a':>5} {'rk b':>5} | "
          f"{'rk(lcm)':>8} {'lcm(rk)':>8} | match")
    print("-" * 70)
    for a, b in pairs:
        ra, rb, r_lcm, pred, ok = check_join_law(fib, a, b)
        print(f"{a:>3} {b:>3} | {ra:>5} {rb:>5} | {r_lcm:>8} {pred:>8} | {ok}")
    print()


def demo_coprime_law() -> None:
    print("=" * 70)
    print("COPRIME LAW (Fibonacci):  rank(a*b) = lcm(rank a, rank b),  gcd(a,b)=1")
    print("=" * 70)
    pairs = [(2, 3), (2, 5), (3, 5), (4, 9), (5, 7)]
    for a, b in pairs:
        ra = rank(fib, a)
        rb = rank(fib, b)
        r_prod = rank(fib, a * b)
        pred = lcm(ra, rb)
        print(f"  a={a}, b={b}: rank({a*b}) = {r_prod}, "
              f"lcm({ra},{rb}) = {pred}  ->  {r_prod == pred}")
    print()


def demo_mersenne_join() -> None:
    print("=" * 70)
    print("JOIN LAW (Mersenne-type, a=2):  rank(lcm(2^m-1, 2^n-1)) = lcm(m, n)")
    print("=" * 70)
    u = mersenne_seq(2)
    pairs = [(2, 3), (3, 4), (4, 6), (6, 9), (2, 5)]
    print(f"{'m':>3} {'n':>3} | {'2^m-1':>8} {'2^n-1':>8} | "
          f"{'rk(lcm)':>8} {'lcm(m,n)':>8} | match")
    print("-" * 70)
    for m, n in pairs:
        A = 2**m - 1
        B = 2**n - 1
        r_lcm = rank(u, lcm(A, B))
        expected = lcm(m, n)
        print(f"{m:>3} {n:>3} | {A:>8} {B:>8} | "
              f"{r_lcm:>8} {expected:>8} | {r_lcm == expected}")
    print()


def demo_meet_failure() -> None:
    print("=" * 70)
    print("MEET LAW FAILS:  rank(gcd(a,b)) =? gcd(rank a, rank b)")
    print("=" * 70)
    pairs = [(2, 4), (3, 6), (4, 8), (6, 12), (4, 6)]
    print(f"{'a':>3} {'b':>3} | {'gcd(a,b)':>8} | "
          f"{'rk(gcd)':>8} {'gcd(rk)':>8} | equal?")
    print("-" * 70)
    any_fail = False
    for a, b in pairs:
        r_gcd, gcd_rk, eq = check_meet_law(fib, a, b)
        any_fail = any_fail or (not eq)
        print(f"{a:>3} {b:>3} | {gcd(a,b):>8} | "
              f"{r_gcd:>8} {gcd_rk:>8} | {eq}")
    print()
    print(f"  At least one meet failure observed: {any_fail}")
    print("  (Confirms rank preserves JOINS but not MEETS.)")
    print()


def main() -> None:
    demo_fibonacci_ranks()
    demo_spine()
    demo_join_law_fibonacci()
    demo_coprime_law()
    demo_mersenne_join()
    demo_meet_failure()


if __name__ == "__main__":
    main()
