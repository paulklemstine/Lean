"""
The Apparition-Order Bridge -- numerical demonstrations.

This self-contained script illustrates the main results of the package:

  * Strong divisibility sequences (Fibonacci and b^n - 1).
  * The entry point (rank of apparition) of a prime.
  * The periodicity law: p | a(n)  <=>  entryPoint(a, p) | n.
  * The stalk reduction: p | b^n - 1  <=>  (b mod p)^n = 1.
  * The Apparition-Order Bridge: entryPoint(b^n - 1, p) = ord_p(b).
  * Fermat descent: entryPoint(b^n - 1, p) divides p - 1.
  * The Fibonacci specialization of the periodicity law.

No external dependencies; standard library only.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, Dict, List, Optional


# --------------------------------------------------------------------------
# Basic sequences (both are strong divisibility sequences)
# --------------------------------------------------------------------------

def fib(n: int) -> int:
    """The n-th Fibonacci number with fib(0)=0, fib(1)=1 (Mathlib convention)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne(b: int) -> Callable[[int], int]:
    """Return the Mersenne-type sequence n |-> b**n - 1."""
    def seq(n: int) -> int:
        return b ** n - 1
    return seq


# --------------------------------------------------------------------------
# Strong divisibility checks
# --------------------------------------------------------------------------

def is_strong_divisibility(seq: Callable[[int], int], bound: int = 12) -> bool:
    """Empirically verify a(gcd(m,n)) = gcd(a(m), a(n)) for 1 <= m,n <= bound."""
    for m in range(1, bound + 1):
        for n in range(1, bound + 1):
            if seq(gcd(m, n)) != gcd(seq(m), seq(n)):
                return False
    return True


# --------------------------------------------------------------------------
# Entry point (rank of apparition) -- the GLOBAL definition
# --------------------------------------------------------------------------

def entry_point_global(seq: Callable[[int], int], p: int,
                       search_bound: int = 5000) -> Optional[int]:
    """Least k > 0 with p | seq(k), found by direct search (the global def)."""
    for k in range(1, search_bound + 1):
        if seq(k) % p == 0:
            return k
    return None


# --------------------------------------------------------------------------
# Multiplicative order -- the LOCAL computation
# --------------------------------------------------------------------------

def mult_order(b: int, p: int) -> int:
    """Multiplicative order of b modulo prime p, with p not dividing b."""
    b %= p
    assert b != 0, "p must not divide b"
    k, cur = 1, b % p
    while cur != 1:
        cur = (cur * b) % p
        k += 1
    return k


def divisors(n: int) -> List[int]:
    """Sorted list of positive divisors of n."""
    ds = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            if d != n // d:
                ds.append(n // d)
        d += 1
    return sorted(ds)


def entry_point_bridge(b: int, p: int) -> int:
    """Entry point of p in b^n - 1 via the bridge (divisor search of p-1)."""
    n = p - 1
    for d in divisors(n):              # Fermat descent: answer divides p-1
        if pow(b, d, p) == 1:
            return d
    return n                           # guaranteed unreachable


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_strong_divisibility() -> None:
    print("=" * 70)
    print("1. STRONG DIVISIBILITY  a(gcd(m,n)) = gcd(a(m), a(n))")
    print("=" * 70)
    print(f"  Fibonacci is strong-divisibility:  {is_strong_divisibility(fib)}")
    for b in (2, 3, 10):
        ok = is_strong_divisibility(mersenne(b))
        print(f"  b^n - 1 (b={b}) is strong-divisibility: {ok}")
    # explicit witness
    m, n = 6, 9
    print(f"  Witness: F(gcd({m},{n}))=F({gcd(m,n)})={fib(gcd(m,n))}, "
          f"gcd(F{m},F{n})=gcd({fib(m)},{fib(n)})={gcd(fib(m), fib(n))}")
    print()


def demo_periodicity_fibonacci() -> None:
    print("=" * 70)
    print("2. PERIODICITY LAW (Fibonacci):  p | F(n)  <=>  e | n")
    print("=" * 70)
    for p in (2, 3, 5, 7, 11, 13):
        e = entry_point_global(fib, p)
        appear = [n for n in range(1, 41) if fib(n) % p == 0]
        multiples = [n for n in range(1, 41) if e and n % e == 0]
        match = appear == multiples
        print(f"  p={p:>3}: entry point e={e:>3} | "
              f"first appearances {appear[:6]}... | matches multiples: {match}")
    print()


def demo_bridge() -> None:
    print("=" * 70)
    print("3. APPARITION-ORDER BRIDGE:  entryPoint(b^n - 1, p) = ord_p(b)")
    print("=" * 70)
    for b in (2, 3, 5):
        print(f"  --- base b = {b} ---")
        for p in (3, 5, 7, 11, 13, 17, 19, 23):
            if p == b or b % p == 0:
                continue
            ep_global = entry_point_global(mersenne(b), p)
            order = mult_order(b, p)
            ep_bridge = entry_point_bridge(b, p)
            fermat = (p - 1) % order == 0
            ok = ep_global == order == ep_bridge
            print(f"    p={p:>3}: global={ep_global:>3}  ord={order:>3}  "
                  f"bridge={ep_bridge:>3}  | equal={ok}  | ord|(p-1)={fermat}")
    print()


def demo_stalk_reduction() -> None:
    print("=" * 70)
    print("4. STALK REDUCTION:  p | b^n - 1  <=>  (b mod p)^n = 1")
    print("=" * 70)
    b, p = 2, 11
    print(f"  base b={b}, prime p={p}")
    for n in range(1, 13):
        lhs = (b ** n - 1) % p == 0
        rhs = pow(b, n, p) == 1
        print(f"    n={n:>2}: p | {b}^{n}-1 = {lhs!s:>5}   "
              f"({b}^{n} mod {p} = {pow(b, n, p)}) -> {rhs!s:>5}  match={lhs == rhs}")
    print()


def demo_fermat_descent() -> None:
    print("=" * 70)
    print("5. FERMAT DESCENT:  entryPoint(b^n - 1, p) divides p - 1")
    print("=" * 70)
    b = 2
    table: Dict[int, int] = {}
    for p in (3, 5, 7, 11, 13, 17, 19, 23, 29, 31):
        e = mult_order(b, p)
        table[p] = e
        print(f"  p={p:>3}: entry point={e:>3}, p-1={p-1:>3}, "
              f"divides={(p-1) % e == 0}")
    print()


def main() -> None:
    demo_strong_divisibility()
    demo_periodicity_fibonacci()
    demo_bridge()
    demo_stalk_reduction()
    demo_fermat_descent()
    print("All demonstrations complete: the global entry point coincides")
    print("with the local multiplicative order, and Fermat descent holds.")


if __name__ == "__main__":
    main()
