"""Numerical demonstrations of the strong divisibility sequence theory.

A *strong divisibility sequence* is a sequence u : N -> N satisfying the single
identity

    u(gcd(m, n)) = gcd(u(m), u(n))    for all m, n.

This one axiom is the complete structural foundation of primitive-divisor and
rank-of-apparition theory. This script demonstrates, with concrete numbers, every
theorem of the abstract theory for two instances:

    * the Fibonacci sequence              F(n)
    * the Mersenne-type family u(n) = a^n - 1

All functions are inlined and fully type-hinted. Run with:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Sequence constructors                                                       #
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0) = 0, F(1) = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne_base(a: int) -> Callable[[int], int]:
    """Return the strong divisibility sequence n |-> a^n - 1."""

    def u(n: int) -> int:
        return a ** n - 1

    return u


# --------------------------------------------------------------------------- #
# Core utilities derived from the abstract theory                            #
# --------------------------------------------------------------------------- #
def lcm(a: int, b: int) -> int:
    """Least common multiple of two natural numbers."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def is_strong_div_seq(u: Callable[[int], int], bound: int) -> bool:
    """Check u(gcd(m,n)) == gcd(u(m), u(n)) for all 1 <= m, n <= bound."""
    for m in range(1, bound + 1):
        for n in range(1, bound + 1):
            if u(gcd(m, n)) != gcd(u(m), u(n)):
                return False
    return True


def rank_of_apparition(u: Callable[[int], int], p: int, search: int = 5000) -> Optional[int]:
    """Least n > 0 with p | u(n): the rank of apparition (primitive index).

    Returns None if no such index is found within `search` terms.
    """
    for n in range(1, search + 1):
        if u(n) % p == 0:
            return n
    return None


def is_primitive(u: Callable[[int], int], p: int, n: int) -> bool:
    """p | u(n) but p does not divide any u(k) for 0 < k < n."""
    if u(n) % p != 0:
        return False
    return all(u(k) % p != 0 for k in range(1, n))


def apparition_count(n: int, N: int) -> int:
    """Theorem 6.3: # of e in {1..N} with rank-n divisor present  =  floor(N/n)."""
    return N // n


def joint_apparition_count(a: int, b: int, N: int) -> int:
    """Theorem 6.4: joint count  =  floor(N / lcm(a, b))."""
    return N // lcm(a, b)


# --------------------------------------------------------------------------- #
# Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_strong_axiom() -> None:
    print("=" * 70)
    print("1. THE STRONG-DIVISIBILITY AXIOM  u(gcd(m,n)) = gcd(u(m), u(n))")
    print("=" * 70)
    print(f"  Fibonacci is a strong divisibility sequence (m,n <= 20): "
          f"{is_strong_div_seq(fib, 20)}")
    for a in (2, 3, 5):
        u = mersenne_base(a)
        print(f"  u(n)=a^n-1 with a={a} is a strong divisibility sequence "
              f"(m,n <= 12): {is_strong_div_seq(u, 12)}")
    print()
    print("  Worked examples of gcd(u(m), u(n)) = u(gcd(m,n)):")
    for (m, n) in [(12, 18), (10, 15), (14, 21)]:
        g = gcd(m, n)
        print(f"    Fibonacci : gcd(F_{m}={fib(m)}, F_{n}={fib(n)}) = "
              f"{gcd(fib(m), fib(n))} = F_{g} = {fib(g)}")
    u2 = mersenne_base(2)
    for (m, n) in [(12, 18), (10, 15)]:
        g = gcd(m, n)
        print(f"    Mersenne  : gcd(2^{m}-1={u2(m)}, 2^{n}-1={u2(n)}) = "
              f"{gcd(u2(m), u2(n))} = 2^{g}-1 = {u2(g)}")
    print()


def demo_weak_law() -> None:
    print("=" * 70)
    print("2. WEAK DIVISIBILITY LAW (Thm 3.1):  m | n  =>  u(m) | u(n)")
    print("=" * 70)
    for (m, n) in [(4, 8), (5, 10), (3, 12)]:
        print(f"    Fibonacci : F_{m}={fib(m)} divides F_{n}={fib(n)}?  "
              f"{fib(n) % fib(m) == 0}")
    u2 = mersenne_base(2)
    for (m, n) in [(3, 6), (4, 12)]:
        print(f"    Mersenne  : 2^{m}-1={u2(m)} divides 2^{n}-1={u2(n)}?  "
              f"{u2(n) % u2(m) == 0}")
    print()


def demo_rank_and_pinning() -> None:
    print("=" * 70)
    print("3. RANK OF APPARITION & PINNING LAW (Thm 5.1):  p | u(m) <=> rank | m")
    print("=" * 70)
    print("  Fibonacci ranks of apparition of small primes:")
    for p in (2, 3, 5, 7, 11, 13, 17, 19):
        n = rank_of_apparition(fib, p)
        primitive = is_primitive(fib, p, n) if n else False
        print(f"    prime {p:>3}: first appears at F_{n}  (primitive: {primitive})")
    print()
    print("  Verifying the pinning law for p=11 (rank 10): 11 | F_m  <=>  10 | m")
    n11 = rank_of_apparition(fib, 11)
    ok = True
    for m in range(1, 41):
        lhs = (fib(m) % 11 == 0)
        rhs = (m % n11 == 0)
        if lhs != rhs:
            ok = False
    print(f"    holds for all m in 1..40:  {ok}")
    print(f"    11 divides F_m exactly for m in "
          f"{[m for m in range(1, 41) if fib(m) % 11 == 0]}")
    print()


def demo_join_law() -> None:
    print("=" * 70)
    print("4. JOIN LAW (Thm 6.1): p,q co-appear  <=>  lcm(rank_p, rank_q) | n")
    print("=" * 70)
    pairs: List[Tuple[int, int]] = [(11, 13), (3, 7), (2, 5)]
    for (p, q) in pairs:
        a = rank_of_apparition(fib, p)
        b = rank_of_apparition(fib, q)
        L = lcm(a, b)
        first_joint = next(m for m in range(1, 10 * L + 1)
                           if fib(m) % p == 0 and fib(m) % q == 0)
        print(f"    primes {p},{q}: ranks {a},{b} -> lcm = {L}; "
              f"first joint apparition at F_{first_joint}  "
              f"(matches lcm: {first_joint == L})")
    print()


def demo_counting() -> None:
    print("=" * 70)
    print("5. COUNTING / DENSITY (Thms 6.3-6.4): density 1/n and 1/lcm(a,b)")
    print("=" * 70)
    N = 1000
    for p in (11, 13, 7):
        n = rank_of_apparition(fib, p)
        actual = sum(1 for e in range(N) if fib(e + 1) % p == 0)
        predicted = apparition_count(n, N)
        print(f"    prime {p:>3} (rank {n:>2}): count of m<= {N} with {p}|F_m = "
              f"{actual}  predicted floor({N}/{n}) = {predicted}  "
              f"(density ~ {actual / N:.4f}, 1/n = {1 / n:.4f})")
    print()
    p, q = 11, 13
    a, b = rank_of_apparition(fib, p), rank_of_apparition(fib, q)
    actual = sum(1 for e in range(N) if fib(e + 1) % p == 0 and fib(e + 1) % q == 0)
    predicted = joint_apparition_count(a, b, N)
    print(f"    joint {p},{q}: count = {actual}  predicted "
          f"floor({N}/lcm({a},{b})={lcm(a, b)}) = {predicted}")
    print()


def main() -> None:
    print()
    print("STRONG DIVISIBILITY SEQUENCES — NUMERICAL DEMONSTRATIONS")
    print("One axiom unifies Fibonacci and Mersenne primitive-divisor theory.")
    print()
    demo_strong_axiom()
    demo_weak_law()
    demo_rank_and_pinning()
    demo_join_law()
    demo_counting()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
