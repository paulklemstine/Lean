"""
The Fibonacci Law of Apparition as an Arithmetic-Height / Tropical Duality
==========================================================================

Self-contained numerical demonstrations of the results in the accompanying
article and research paper. No external dependencies (standard library only).

Central objects
---------------
* F(n)            : the n-th Fibonacci number, F(0)=0, F(1)=1.
* z(m) = fibRank  : the rank of apparition of m -- the least k>0 with m | F(k).

Headline results demonstrated
-----------------------------
1. Existence of z(m) for every m >= 1 (via the finite reversible state machine).
2. Duality / law of apparition:   m | F(n)  <=>  z(m) | n.
3. Join (lcm) law (exact):        z(lcm(a,b)) = lcm(z(a), z(b)).
4. Meet (gcd) bound + strictness: z(gcd(a,b)) | gcd(z(a), z(b)), strict at (4,6).
5. Strong divisibility:           F(m) | F(n)  <=>  m | n   (m >= 3).
6. p-adic height capstone:        |F(n)|_p < 1  <=>  z(p) | n   (p prime).
7. Height = exp(-v_p . log p):    |q|_p = exp(-v_p(q) * log p).
"""

from __future__ import annotations

from math import gcd, exp, log
from functools import reduce
from typing import Dict, List, Tuple


# ----------------------------------------------------------------------------
# Basic arithmetic
# ----------------------------------------------------------------------------

def fib(n: int) -> int:
    """Return the n-th Fibonacci number (F(0)=0, F(1)=1)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lcm(a: int, b: int) -> int:
    """Least common multiple of a and b."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


# ----------------------------------------------------------------------------
# The rank of apparition via the finite reversible state machine
# ----------------------------------------------------------------------------

def fib_rank(m: int) -> int:
    """Rank of apparition z(m): least k>0 with m | F(k).

    Iterates the state pair (F(k), F(k+1)) modulo m -- the affine shift
    T(a,b) = (b, a+b) -- until the Fibonacci coordinate vanishes. Because T is a
    bijection of the finite set (Z/mZ)^2, the orbit of (0,1) is purely periodic
    and must return to a state with a 0 Fibonacci coordinate, so the loop
    terminates. Runs in O(z(m)) modular steps, never forming a large Fibonacci
    number.
    """
    if m <= 0:
        raise ValueError("rank of apparition requires m >= 1")
    if m == 1:
        return 1
    a, b = 0 % m, 1 % m       # (F(0), F(1)) mod m
    k = 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k


def fib_state(m: int, n: int) -> Tuple[int, int]:
    """The Fibonacci state pair (F(n) mod m, F(n+1) mod m)."""
    a, b = 0 % m, 1 % m
    for _ in range(n):
        a, b = b, (a + b) % m
    return (a, b)


# ----------------------------------------------------------------------------
# p-adic valuation, absolute value, and the height identity
# ----------------------------------------------------------------------------

def p_adic_valuation(p: int, x: int) -> int:
    """v_p(x): the exponent of the prime p in the factorisation of x (x != 0)."""
    if x == 0:
        raise ValueError("v_p(0) is +infinity")
    v = 0
    x = abs(x)
    while x % p == 0:
        x //= p
        v += 1
    return v


def p_adic_norm(p: int, x: int) -> float:
    """|x|_p = p^{-v_p(x)} for x != 0, and |0|_p = 0."""
    if x == 0:
        return 0.0
    return float(p) ** (-p_adic_valuation(p, x))


def is_prime(n: int) -> bool:
    """Trial-division primality test."""
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_existence_and_table(limit: int = 16) -> None:
    print("=" * 70)
    print("1. Rank of apparition z(m) exists for every m >= 1")
    print("=" * 70)
    print(f"{'m':>3} | {'z(m)':>5} | {'F(z(m))':>10} | check m | F(z(m))")
    print("-" * 50)
    for m in range(1, limit + 1):
        z = fib_rank(m)
        fz = fib(z)
        ok = (fz % m == 0)
        print(f"{m:>3} | {z:>5} | {fz:>10} | {ok}")


def demo_duality(moduli: List[int], n_max: int = 30) -> None:
    print("\n" + "=" * 70)
    print("2. Duality:  m | F(n)  <=>  z(m) | n")
    print("=" * 70)
    for m in moduli:
        z = fib_rank(m)
        all_ok = True
        appearances = []
        for n in range(0, n_max + 1):
            lhs = (fib(n) % m == 0)
            rhs = (z != 0 and n % z == 0)
            if lhs != rhs:
                all_ok = False
            if lhs and n > 0:
                appearances.append(n)
        print(f"m = {m:>3}:  z(m) = {z:>3}   "
              f"indices where m | F(n): {appearances[:8]}"
              f"{' ...' if len(appearances) > 8 else ''}")
        print(f"          duality holds for all n <= {n_max}:  {all_ok}")


def demo_join_law(pairs: List[Tuple[int, int]]) -> None:
    print("\n" + "=" * 70)
    print("3. Join (lcm) law:  z(lcm(a,b)) = lcm(z(a), z(b))  -- EXACT")
    print("=" * 70)
    for a, b in pairs:
        za, zb = fib_rank(a), fib_rank(b)
        lhs = fib_rank(lcm(a, b))
        rhs = lcm(za, zb)
        print(f"a={a:>2}, b={b:>2}:  z(lcm={lcm(a,b):>3}) = {lhs:>3}   "
              f"lcm(z(a)={za}, z(b)={zb}) = {rhs:>3}   match: {lhs == rhs}")


def demo_meet_bound(pairs: List[Tuple[int, int]]) -> None:
    print("\n" + "=" * 70)
    print("4. Meet (gcd) bound:  z(gcd(a,b)) | gcd(z(a),z(b))  -- often STRICT")
    print("=" * 70)
    for a, b in pairs:
        za, zb = fib_rank(a), fib_rank(b)
        lhs = fib_rank(gcd(a, b))
        rhs = gcd(za, zb)
        divides = (rhs % lhs == 0)
        exact = (lhs == rhs)
        tag = "exact" if exact else "STRICT (proper divisor)"
        print(f"a={a:>2}, b={b:>2}:  z(gcd={gcd(a,b):>2}) = {lhs:>3} | "
              f"gcd(z(a)={za}, z(b)={zb}) = {rhs:>3}   "
              f"divides: {divides}   [{tag}]")


def demo_strong_divisibility(m_max: int = 12, n_max: int = 36) -> None:
    print("\n" + "=" * 70)
    print("5. Strong divisibility:  F(m) | F(n)  <=>  m | n   (m >= 3)")
    print("=" * 70)
    all_ok = True
    for m in range(3, m_max + 1):
        for n in range(0, n_max + 1):
            lhs = (fib(m) != 0 and fib(n) % fib(m) == 0)
            rhs = (n % m == 0)
            if lhs != rhs:
                all_ok = False
                print(f"  MISMATCH at m={m}, n={n}")
    print(f"  verified F(m)|F(n) <=> m|n for 3<=m<={m_max}, 0<=n<={n_max}: {all_ok}")
    # Strong divisibility identity gcd(F(m),F(n)) = F(gcd(m,n)).
    print("\n  gcd(F(m),F(n)) = F(gcd(m,n)):")
    for (m, n) in [(12, 18), (10, 15), (8, 12), (9, 6)]:
        left = gcd(fib(m), fib(n))
        right = fib(gcd(m, n))
        print(f"    gcd(F({m})={fib(m)}, F({n})={fib(n)}) = {left}"
              f"  ==  F(gcd({m},{n})={gcd(m,n)}) = {right}   {left == right}")


def demo_padic_capstone(primes: List[int], n_max: int = 30) -> None:
    print("\n" + "=" * 70)
    print("6. p-adic height capstone:  |F(n)|_p < 1  <=>  z(p) | n  (p prime)")
    print("=" * 70)
    for p in primes:
        assert is_prime(p)
        z = fib_rank(p)
        ok = True
        small_at = []
        for n in range(0, n_max + 1):
            norm = p_adic_norm(p, fib(n))
            lhs = (norm < 1.0)
            rhs = (n % z == 0)
            if lhs != rhs:
                ok = False
            if lhs and n > 0:
                small_at.append(n)
        print(f"p = {p:>3}:  z(p) = {z:>3}   "
              f"indices with |F(n)|_p < 1: {small_at[:8]}"
              f"{' ...' if len(small_at) > 8 else ''}   capstone holds: {ok}")


def demo_height_identity(primes: List[int], qs: List[int]) -> None:
    print("\n" + "=" * 70)
    print("7. Height as tropical valuation:  |q|_p = exp(-v_p(q) * log p)")
    print("=" * 70)
    for p in primes:
        for q in qs:
            if q == 0:
                continue
            direct = p_adic_norm(p, q)
            v = p_adic_valuation(p, q)
            via_exp = exp(-v * log(p))
            print(f"p={p}, q={q:>4}:  |q|_p = {direct:.6f}   "
                  f"exp(-v_p(q)={v} * log {p}) = {via_exp:.6f}   "
                  f"match: {abs(direct - via_exp) < 1e-12}")


def main() -> None:
    demo_existence_and_table(limit=16)
    demo_duality(moduli=[2, 3, 4, 5, 7, 11, 12, 144], n_max=30)
    demo_join_law(pairs=[(4, 6), (3, 5), (2, 9), (6, 10), (7, 11)])
    demo_meet_bound(pairs=[(4, 6), (12, 18), (6, 10), (8, 12), (3, 5)])
    demo_strong_divisibility(m_max=12, n_max=36)
    demo_padic_capstone(primes=[2, 3, 5, 7, 11, 13], n_max=30)
    demo_height_identity(primes=[2, 3, 5], qs=[12, 144, 13, 7])
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
