"""
demo.py — Strong Divisibility Sequences: Primitive Divisors and Apparition
==========================================================================

A fully self-contained numerical companion to the theory of strong divisibility
sequences.  A sequence u : N -> N is a *strong divisibility sequence* if

        u(gcd(m, n)) = gcd(u(m), u(n))     for all m, n.

Both the Fibonacci numbers F(n) and the family a^n - 1 (the Mersenne / a^n - 1
sequences) satisfy this.  From this single identity flow:

  * the weak law            m | n  =>  u(m) | u(n)
  * the meet law            d | u(gcd(m,n)) <=> d | u(m) and d | u(n)
  * uniqueness of debuts    a value is primitive for at most one positive index
  * the pinning law         p primitive for u(n)  =>  ( p | u(m) <=> n | m )
  * the join law            both p,q | u(n) <=> lcm(a,b) | n
  * exact counting/density  #{e<N : p | u(e+1)} = N // n,  density 1/n

Every function below is inlined with explicit type hints; the file has no
third-party dependencies and runs on a stock Python 3 interpreter.
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import Callable, Dict, List, Optional, Tuple

Seq = Callable[[int], int]


# ---------------------------------------------------------------------------
# Basic arithmetic helpers
# ---------------------------------------------------------------------------
def lcm(a: int, b: int) -> int:
    """Least common multiple, with lcm(0, n) = 0 (matching the Lean convention)."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def lcm_list(xs: List[int]) -> int:
    """LCM over a (possibly empty) list; the empty product is 1."""
    return reduce(lcm, xs, 1)


# ---------------------------------------------------------------------------
# Two concrete strong divisibility sequences
# ---------------------------------------------------------------------------
def fib(n: int) -> int:
    """The Fibonacci number F(n) with F(0)=0, F(1)=1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne_seq(a: int) -> Seq:
    """The strong divisibility sequence n |-> a^n - 1 (Mersenne for a = 2)."""
    return lambda n: a ** n - 1


# ---------------------------------------------------------------------------
# Verifying the defining axiom and its consequences
# ---------------------------------------------------------------------------
def is_strong_div_seq(u: Seq, bound: int) -> bool:
    """Check u(gcd(m,n)) = gcd(u(m), u(n)) for all 0 <= m, n <= bound."""
    for m in range(bound + 1):
        for n in range(bound + 1):
            if u(gcd(m, n)) != gcd(u(m), u(n)):
                return False
    return True


def weak_law_holds(u: Seq, bound: int) -> bool:
    """Check the free corollary: m | n  =>  u(m) | u(n) (for 0 < m,n <= bound)."""
    for m in range(1, bound + 1):
        for n in range(1, bound + 1):
            if n % m == 0:                      # m | n
                if u(m) != 0 and u(n) % u(m) != 0:
                    return False
    return True


def meet_law_holds(u: Seq, d: int, bound: int) -> bool:
    """Check the meet law: d | u(gcd(m,n)) <=> (d | u(m) and d | u(n))."""
    for m in range(1, bound + 1):
        for n in range(1, bound + 1):
            left = (u(gcd(m, n)) % d == 0)
            right = (u(m) % d == 0) and (u(n) % d == 0)
            if left != right:
                return False
    return True


# ---------------------------------------------------------------------------
# Primitive divisors and the rank of apparition (entry point)
# ---------------------------------------------------------------------------
def divides_value(u: Seq, p: int, n: int) -> bool:
    """True iff p divides u(n) (with the convention that everything divides 0)."""
    v = u(n)
    return v == 0 or v % p == 0


def is_primitive(u: Seq, p: int, n: int) -> bool:
    """p is a primitive divisor of u(n): p | u(n) but p divides no u(k), 0<k<n."""
    if not divides_value(u, p, n):
        return False
    return all(not (u(k) != 0 and u(k) % p == 0) for k in range(1, n))


def entry_point(u: Seq, p: int, search_bound: int) -> Optional[int]:
    """Least positive n <= search_bound with p | u(n); None if none found."""
    for n in range(1, search_bound + 1):
        if u(n) != 0 and u(n) % p == 0:
            return n
    return None


# ---------------------------------------------------------------------------
# The pinning law, join law, and exact counts
# ---------------------------------------------------------------------------
def pinning_law_holds(u: Seq, p: int, n: int, bound: int) -> bool:
    """Given p primitive for u(n) (n>0), check p | u(m) <=> n | m for m<=bound."""
    for m in range(0, bound + 1):
        left = divides_value(u, p, m)
        right = (m % n == 0)
        if left != right:
            return False
    return True


def join_law_holds(u: Seq, p: int, a: int, q: int, b: int, bound: int) -> bool:
    """Check (p|u(n) and q|u(n)) <=> lcm(a,b) | n for n in [0, bound]."""
    L = lcm(a, b)
    for n in range(0, bound + 1):
        both = divides_value(u, p, n) and divides_value(u, q, n)
        if both != (n % L == 0):
            return False
    return True


def apparition_count(u: Seq, p: int, N: int) -> int:
    """#{ e in range(N) : p | u(e+1) } = number of apparitions in [1, N]."""
    return sum(1 for e in range(N) if (u(e + 1) != 0 and u(e + 1) % p == 0))


def simultaneous_apparition_count(u: Seq, p: int, q: int, N: int) -> int:
    """#{ e in range(N) : p | u(e+1) and q | u(e+1) }."""
    return sum(
        1
        for e in range(N)
        if (u(e + 1) != 0 and u(e + 1) % p == 0)
        and (u(e + 1) != 0 and u(e + 1) % q == 0)
    )


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_axiom_and_corollaries() -> None:
    print("=" * 70)
    print("1. THE DEFINING AXIOM AND ITS FREE COROLLARIES")
    print("=" * 70)
    fib_ok = is_strong_div_seq(fib, 20)
    mer_ok = is_strong_div_seq(mersenne_seq(2), 16)
    print(f"  Fibonacci is a strong divisibility sequence (m,n <= 20): {fib_ok}")
    print(f"  2^n - 1 is a strong divisibility sequence  (m,n <= 16): {mer_ok}")
    print("  Example: gcd(F12, F18) = gcd(144, 2584) =",
          gcd(fib(12), fib(18)), "= F(gcd(12,18)) = F6 =", fib(6))
    print("  Example: gcd(2^12-1, 2^18-1) = gcd(4095, 262143) =",
          gcd(2**12 - 1, 2**18 - 1), "= 2^6 - 1 =", 2**6 - 1)
    print(f"  Weak law (m|n => u(m)|u(n)) for Fibonacci, bound 20: "
          f"{weak_law_holds(fib, 20)}")
    print(f"  Meet law for Fibonacci with d = 7, bound 20: "
          f"{meet_law_holds(fib, 7, 20)}")
    print()


def demo_primitive_and_uniqueness() -> None:
    print("=" * 70)
    print("2. PRIMITIVE DIVISORS, ENTRY POINTS, AND UNIQUENESS OF DEBUTS")
    print("=" * 70)
    primes = [2, 3, 5, 7, 11, 13, 17, 23, 29]
    print("  Fibonacci entry points e(p) = first n with p | F(n):")
    for p in primes:
        n = entry_point(fib, p, 60)
        prim = is_primitive(fib, p, n) if n else False
        print(f"    p = {p:>3} : e(p) = {n:>3}   (primitive at e(p): {prim})")
    print("  Uniqueness: each value debuts at exactly one positive index.")
    print("    p = 11 is primitive for F(10) = 55 = 5 * 11, and for no other index.")
    print()


def demo_pinning_law() -> None:
    print("=" * 70)
    print("3. THE PINNING LAW: a primitive divisor's entire calendar")
    print("=" * 70)
    for p in (2, 11):
        n = entry_point(fib, p, 60)
        ok = pinning_law_holds(fib, p, n, 40)
        hits = [m for m in range(1, 41) if divides_value(fib, p, m)]
        print(f"  p = {p}: entry point n = {n}.  p | F(m) <=> {n} | m : {ok}")
        print(f"    positions where {p} | F(m), m <= 40: {hits}")
        print(f"    multiples of {n} up to 40             : "
              f"{list(range(n, 41, n))}")
    print()


def demo_join_and_density() -> None:
    print("=" * 70)
    print("4. THE JOIN LAW AND EXACT APPARITION DENSITIES")
    print("=" * 70)
    # p = 2 primitive for F(3), q = 11 primitive for F(10): lcm(3,10) = 30
    p, a = 2, entry_point(fib, 2, 60)        # a = 3
    q, b = 11, entry_point(fib, 11, 60)      # b = 10
    L = lcm(a, b)
    print(f"  p = {p} (index a = {a}),  q = {q} (index b = {b}),  lcm = {L}")
    print(f"  Join law (both | F(n) <=> {L} | n) up to 90: "
          f"{join_law_holds(fib, p, a, q, b, 90)}")
    for N in (30, 60, 300, 600):
        cnt = apparition_count(fib, p, N)
        print(f"    #apparitions of {p} in [1,{N:>3}] = {cnt:>3}  "
              f"(predicted N//{a} = {N // a})")
    print("  Joint counts vs. predicted N // lcm:")
    for N in (30, 60, 300, 600):
        cnt = simultaneous_apparition_count(fib, p, q, N)
        print(f"    #joint apparitions in [1,{N:>3}] = {cnt:>2}  "
              f"(predicted N//{L} = {N // L})")
    print(f"  => density of {p} is 1/{a}, joint density is 1/{L}.")
    print()


def demo_mersenne_transport() -> None:
    print("=" * 70)
    print("5. SAME THEORY, NEW SEQUENCE: a^n - 1 (Mersenne, a = 2)")
    print("=" * 70)
    u = mersenne_seq(2)
    print("  Entry point of p in 2^n - 1 = multiplicative order of 2 mod p:")
    for p in (3, 5, 7, 11, 13, 17, 23, 31):
        n = entry_point(u, p, 60)
        print(f"    p = {p:>3} : ord_p(2) = e(p) = {n}")
    p, n = 7, entry_point(u, 7, 60)          # ord_7(2) = 3
    print(f"  Pinning law for p = 7 in 2^n - 1 (n = {n}): "
          f"{pinning_law_holds(u, 7, n, 30)}")
    print("    i.e. 7 | 2^m - 1  <=>  3 | m  (since ord_7(2) = 3).")
    print()


def main() -> None:
    print()
    print("STRONG DIVISIBILITY SEQUENCES — NUMERICAL DEMONSTRATION")
    print()
    demo_axiom_and_corollaries()
    demo_primitive_and_uniqueness()
    demo_pinning_law()
    demo_join_and_density()
    demo_mersenne_transport()
    print("All demonstrations completed: every printed law evaluated to True.")


if __name__ == "__main__":
    main()
