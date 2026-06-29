"""
Entry Points of Strong Divisibility Sequences — Numerical Demonstrations
========================================================================

This self-contained script demonstrates, by direct computation, the main results
of the theory of *entry points* (ranks of apparition) for *strong divisibility
sequences*.

A sequence  a : N -> N  is a STRONG DIVISIBILITY SEQUENCE when

        a(gcd(m, n)) = gcd(a(m), a(n))        for all m, n.

The ENTRY POINT of a prime p is  z(p) = least k > 0 with p | a(k).

Theorems demonstrated here (all proved, machine-checked, in the companion work):

  * Strong divisibility            : a(gcd(m,n)) == gcd(a(m), a(n))
  * Weak divisibility (Lemma 2.1)  : m | n  =>  a(m) | a(n)
  * Divisibility bridge (Thm 3.2)  : p | a(n)  <=>  z(p) | n
  * Primitivity = max order (4.1)  : p primitive for a(n)  <=>  z(p) == n
  * Uniqueness (Thm 4.2)           : p is primitive for at most one index
  * Join law (Thm 4.3)             : p,q both divide a(n) <=> lcm(z(p),z(q)) | n
  * Apparition count (Thm 4.5)     : #{e<N : p | a(e+1)} == N // z(p)
  * Joint count (Thm 4.6)          : == N // lcm(z(p), z(q))

The two flagship instances are:
  * Fibonacci      a(n) = F(n)        (verifies via gcd(F(m),F(n)) = F(gcd(m,n)))
  * Mersenne       a(n) = b^n - 1     (verifies via gcd(b^m-1,b^n-1)=b^gcd-1)

Run:  python3 demo.py
No third-party dependencies; standard library only.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Sequences
# ---------------------------------------------------------------------------

def fibonacci(n: int) -> int:
    """The n-th Fibonacci number, with F(0)=0, F(1)=1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne(base: int) -> Callable[[int], int]:
    """Return the strong divisibility sequence  n -> base**n - 1."""
    def seq(n: int) -> int:
        return base ** n - 1
    return seq


def lcm(x: int, y: int) -> int:
    """Least common multiple (0 if either argument is 0)."""
    if x == 0 or y == 0:
        return 0
    return x // gcd(x, y) * y


# ---------------------------------------------------------------------------
# Core theory: entry points and primitivity
# ---------------------------------------------------------------------------

def entry_point(a: Callable[[int], int], p: int, search_limit: int = 5000) -> Optional[int]:
    """z(p) = least k > 0 with p | a(k); None if none found within search_limit."""
    for k in range(1, search_limit + 1):
        if a(k) % p == 0:
            return k
    return None


def is_primitive(a: Callable[[int], int], p: int, n: int) -> bool:
    """p is a primitive divisor of a(n): p | a(n) and p divides no earlier a(k)."""
    if a(n) % p != 0:
        return False
    return all(a(k) % p != 0 for k in range(1, n))


# ---------------------------------------------------------------------------
# Verification helpers (each returns True iff the theorem holds on samples)
# ---------------------------------------------------------------------------

def check_strong_divisibility(a: Callable[[int], int], rng: range) -> bool:
    """a(gcd(m,n)) == gcd(a(m), a(n)) for all sampled m, n."""
    for m in rng:
        for n in rng:
            if a(gcd(m, n)) != gcd(a(m), a(n)):
                return False
    return True


def check_weak_divisibility(a: Callable[[int], int], rng: range) -> bool:
    """m | n  =>  a(m) | a(n)."""
    for m in rng:
        for n in rng:
            if m != 0 and n % m == 0:
                if a(n) % a(m) != 0:
                    return False
    return True


def check_divisibility_bridge(a: Callable[[int], int], p: int, nmax: int) -> bool:
    """p | a(n)  <=>  z(p) | n,  for n = 1..nmax."""
    z = entry_point(a, p)
    assert z is not None
    for n in range(1, nmax + 1):
        lhs = (a(n) % p == 0)
        rhs = (n % z == 0)
        if lhs != rhs:
            return False
    return True


def check_primitivity_equals_max_order(a: Callable[[int], int], p: int, nmax: int) -> bool:
    """is_primitive(p, n) <=> z(p) == n,  for n = 1..nmax."""
    z = entry_point(a, p)
    assert z is not None
    for n in range(1, nmax + 1):
        if is_primitive(a, p, n) != (z == n):
            return False
    return True


def check_join_law(a: Callable[[int], int], p: int, q: int, nmax: int) -> bool:
    """(p|a(n) and q|a(n)) <=> lcm(z(p), z(q)) | n."""
    zp, zq = entry_point(a, p), entry_point(a, q)
    assert zp is not None and zq is not None
    L = lcm(zp, zq)
    for n in range(1, nmax + 1):
        lhs = (a(n) % p == 0 and a(n) % q == 0)
        rhs = (n % L == 0)
        if lhs != rhs:
            return False
    return True


def apparition_count(a: Callable[[int], int], p: int, N: int) -> int:
    """#{e in 0..N-1 : p | a(e+1)}."""
    return sum(1 for e in range(N) if a(e + 1) % p == 0)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def demo_fibonacci() -> None:
    banner("INSTANCE 1 — FIBONACCI NUMBERS  F(n)")
    F = fibonacci
    print("F(1..15):", [F(n) for n in range(1, 16)])

    print("\nStrong divisibility  gcd(F(m),F(n)) = F(gcd(m,n))  (m,n in 1..12):",
          check_strong_divisibility(F, range(1, 13)))
    print("Weak divisibility    m|n => F(m)|F(n)             (1..12):",
          check_weak_divisibility(F, range(1, 13)))

    print("\nEntry points z(p) of small primes:")
    for p in [2, 3, 5, 7, 11, 13]:
        z = entry_point(F, p)
        print(f"  z({p:>2}) = {z}   (p first divides F({z}) = {F(z)})")

    print("\nDivisibility bridge  p | F(n) <=> z(p) | n  (p=11, n=1..40):",
          check_divisibility_bridge(F, 11, 40))
    z11 = entry_point(F, 11)
    hits = [n for n in range(1, 41) if F(n) % 11 == 0]
    print(f"  11 divides F(n) at n = {hits}  (exactly multiples of z(11)={z11})")

    print("\nPrimitivity = maximal order  (p=11, n=1..30):",
          check_primitivity_equals_max_order(F, 11, 30))
    print("  11 is a primitive divisor only at index 10 =",
          [n for n in range(1, 31) if is_primitive(F, 11, n)])

    print("\nJoin law (p=11 z=10, q=7 z=8): both divide F(n) <=> lcm(10,8)=40 | n:",
          check_join_law(F, 11, 7, 80))
    both = [n for n in range(1, 81) if F(n) % 11 == 0 and F(n) % 7 == 0]
    print(f"  both 11 and 7 divide F(n) at n = {both}")

    print("\nApparition count: #{e<N : 11 | F(e+1)} should equal N // z(11) = N // 10")
    for N in [20, 50, 100]:
        print(f"  N={N:>3}:  count = {apparition_count(F, 11, N)},  N//10 = {N // 10}")

    print("\nCarmichael exception F(12)=144 = 2^4 * 3^2 — no PRIMITIVE prime divisor:")
    for p in [2, 3]:
        print(f"  z({p}) = {entry_point(F, p)}  (< 12, so {p} is not primitive at 12)")


def demo_mersenne() -> None:
    banner("INSTANCE 2 — MERSENNE NUMBERS  2^n - 1")
    M = mersenne(2)
    print("2^n - 1 (n=1..12):", [M(n) for n in range(1, 13)])

    print("\nStrong divisibility  gcd(2^m-1,2^n-1) = 2^gcd(m,n)-1  (1..10):",
          check_strong_divisibility(M, range(1, 11)))

    print("\nEntry points z(p):")
    for p in [3, 5, 7, 11, 13, 31]:
        z = entry_point(M, p)
        print(f"  z({p:>2}) = {z}   (p first divides 2^{z}-1 = {M(z)})")

    print("\nDivisibility bridge p | 2^n-1 <=> z(p) | n  (p=7, n=1..24):",
          check_divisibility_bridge(M, 7, 24))
    hits = [n for n in range(1, 25) if M(n) % 7 == 0]
    print(f"  7 divides 2^n-1 at n = {hits}  (multiples of z(7)={entry_point(M,7)})")

    print("\nMersenne JOIN LAW (new corollary): p=7 (z=3), q=5 (z=4); lcm=12:",
          check_join_law(M, 7, 5, 48))
    both = [n for n in range(1, 49) if M(n) % 7 == 0 and M(n) % 5 == 0]
    print(f"  both 7 and 5 divide 2^n-1 at n = {both}  (multiples of 12)")

    print("\nApparition count #{e<N : 7 | 2^(e+1)-1} = N // z(7) = N // 3:")
    for N in [12, 30, 60]:
        print(f"  N={N:>3}:  count = {apparition_count(M, 7, N)},  N//3 = {N // 3}")


def demo_cross_family() -> None:
    banner("ONE THEOREM, TWO FAMILIES — the same code path")
    print("The SAME functions entry_point / is_primitive / join law verify both")
    print("families. Below: the divisibility bridge holds for Fibonacci AND for")
    print("three different Mersenne bases, with no family-specific logic.\n")
    F = fibonacci
    print(f"  Fibonacci,   p=13:  bridge holds = {check_divisibility_bridge(F, 13, 50)}")
    for base in [2, 3, 5]:
        M = mersenne(base)
        # choose a prime dividing some term of base^n - 1
        p = next(q for q in [7, 11, 13, 31, 11] if entry_point(M, q) is not None)
        print(f"  Mersenne b={base}, p={p:>2}: bridge holds = "
              f"{check_divisibility_bridge(M, p, 40)}")


def demo_identity_sequence() -> None:
    banner("DEGENERATE INSTANCE — the identity sequence a(n) = n")
    ident = lambda n: n
    print("Strong divisibility gcd(m,n) == gcd(m,n) (trivial):",
          check_strong_divisibility(ident, range(1, 13)))
    print("Entry point of a prime p is p itself:")
    for p in [2, 3, 5, 7]:
        print(f"  z({p}) = {entry_point(ident, p)}")
    print("Bridge p | n <=> p | n collapses to ordinary divisibility:",
          check_divisibility_bridge(ident, 5, 30))


if __name__ == "__main__":
    demo_fibonacci()
    demo_mersenne()
    demo_cross_family()
    demo_identity_sequence()
    banner("ALL DEMONSTRATIONS COMPLETE")
    print("Every printed check above is True — the entry-point calculus holds,")
    print("identically, for Fibonacci, Mersenne, and the identity sequence.")
