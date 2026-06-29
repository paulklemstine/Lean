"""
demo.py — The Fibonacci Rank of Apparition as a Local-to-Global Sheaf
=====================================================================

Self-contained numerical demonstrations of the four headline results:

  1. Law of apparition:        m | F(n)  <=>  rank(m) | n           (m > 0)
  2. Primitivity bridge:       IsPrimitive(m, n)  <=>  rank(m) = n  (m, n > 0)
  3. Coprime gluing law:       rank(a*b) = lcm(rank a, rank b)      (gcd(a,b)=1)
  4. Local-to-global:          rank(n) = lcm over prime powers p^e || n of rank(p^e)

Everything is inlined; standard library only. Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import Dict, Iterator, List, Tuple


# --------------------------------------------------------------------------
# Core arithmetic
# --------------------------------------------------------------------------

def lcm(a: int, b: int) -> int:
    """Least common multiple (with lcm(0, x) = 0)."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def lcm_list(xs: List[int]) -> int:
    """LCM of a list; the empty list has lcm 1 (the identity)."""
    return reduce(lcm, xs, 1)


def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0)=0, F(1)=1 (fast doubling)."""
    def _fd(k: int) -> Tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = _fd(k >> 1)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if (k & 1) else (c, d)
    return _fd(n)[0]


# --------------------------------------------------------------------------
# Rank of apparition: the shift-permutation walk (the constructive proof)
# --------------------------------------------------------------------------

def fib_rank_direct(m: int) -> int:
    """
    rank(m): least k > 0 with m | F(k), computed by iterating the Fibonacci
    shift  (a, b) -> (b, a + b)  modulo m, starting from (0, 1).

    This mirrors the existence proof: the shift is a permutation of the finite
    set (Z/mZ)^2, so the orbit of (0, 1) must return; the first return of the
    first coordinate to 0 is the rank.
    """
    if m <= 0:
        raise ValueError("modulus must be positive")
    if m == 1:
        return 1
    a, b = 0 % m, 1 % m
    k = 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k


def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n >= 1 as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def fib_rank_factored(n: int) -> int:
    """
    rank(n) via local-to-global reconstruction:
        rank(n) = lcm over prime powers p^e exactly dividing n of rank(p^e).
    """
    if n == 1:
        return 1
    return lcm_list([fib_rank_direct(p ** e) for p, e in factorize(n).items()])


def is_primitive(m: int, n: int) -> bool:
    """
    Naive definition: m | F(n) and m divides no earlier positive-index F(k).
    """
    if m <= 0 or n <= 0:
        return False
    if fib(n) % m != 0:
        return False
    return all(fib(k) % m != 0 for k in range(1, n))


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_law_of_apparition(moduli: List[int], n_max: int) -> None:
    print("=" * 70)
    print("1. LAW OF APPARITION:  m | F(n)  <=>  rank(m) | n")
    print("=" * 70)
    for m in moduli:
        r = fib_rank_direct(m)
        divides = [n for n in range(1, n_max + 1) if fib(n) % m == 0]
        predicted = [n for n in range(1, n_max + 1) if n % r == 0]
        ok = divides == predicted
        print(f"  m={m:>3}  rank={r:>3}  "
              f"{{n<= {n_max}: m|F(n)}} = {divides}")
        print(f"            multiples of rank          = {predicted}   "
              f"[{'OK' if ok else 'MISMATCH'}]")
    print()


def demo_primitivity_bridge(n_max: int) -> None:
    print("=" * 70)
    print("2. PRIMITIVITY BRIDGE:  IsPrimitive(m, n)  <=>  rank(m) = n")
    print("=" * 70)
    checked = 0
    for n in range(1, n_max + 1):
        for m in range(2, fib(n) + 1):
            if fib(n) % m != 0:
                continue
            naive = is_primitive(m, n)
            bridge = (fib_rank_direct(m) == n)
            assert naive == bridge, (m, n, naive, bridge)
            checked += 1
    print(f"  Verified IsPrimitive(m,n) == (rank(m)==n) for all divisors m")
    print(f"  of F(n), for n = 1..{n_max}   ({checked} (m,n) pairs)  [OK]")
    # Show the primitive divisors born at each index.
    print("  Primitive prime divisors born at F(n):")
    for n in range(1, n_max + 1):
        prims = [p for p in factorize(fib(n)) if fib_rank_direct(p) == n] \
            if fib(n) > 1 else []
        tag = "" if prims else "   <- exceptional (no new prime)"
        print(f"    F({n:>2}) = {fib(n):>6}   primitive primes: {prims}{tag}")
    print()


def demo_gluing_law(pairs: List[Tuple[int, int]]) -> None:
    print("=" * 70)
    print("3. COPRIME GLUING LAW:  rank(a*b) = lcm(rank a, rank b)")
    print("=" * 70)
    for a, b in pairs:
        assert gcd(a, b) == 1, f"{a},{b} not coprime"
        ra, rb = fib_rank_direct(a), fib_rank_direct(b)
        lhs = fib_rank_direct(a * b)
        rhs = lcm(ra, rb)
        print(f"  a={a:>2} b={b:>2}  rank(a)={ra:>3} rank(b)={rb:>3}  "
              f"rank(a*b)={lhs:>3}  lcm={rhs:>3}  "
              f"[{'OK' if lhs == rhs else 'MISMATCH'}]")
    print()


def demo_local_to_global(numbers: List[int]) -> None:
    print("=" * 70)
    print("4. LOCAL-TO-GLOBAL:  rank(n) = lcm of prime-power stalk ranks")
    print("=" * 70)
    for n in numbers:
        direct = fib_rank_direct(n)
        recon = fib_rank_factored(n)
        parts = {f"{p}^{e}": fib_rank_direct(p ** e)
                 for p, e in factorize(n).items()}
        print(f"  n={n:>4}={dict(factorize(n))}  stalk ranks={parts}")
        print(f"       direct rank={direct:>4}  reconstructed={recon:>4}  "
              f"[{'OK' if direct == recon else 'MISMATCH'}]")
    print()


def demo_meet_obstruction(pairs: List[Tuple[int, int]]) -> None:
    print("=" * 70)
    print("5. THE MEET (gcd) OBSTRUCTION:  rank(gcd) | gcd(ranks), often strict")
    print("=" * 70)
    for a, b in pairs:
        g = gcd(a, b)
        rg = fib_rank_direct(g) if g > 0 else 0
        gr = gcd(fib_rank_direct(a), fib_rank_direct(b))
        defect = gr // rg if rg else 0
        status = "exact" if defect == 1 else f"STRICT (defect delta={defect})"
        print(f"  a={a:>2} b={b:>2}  rank(gcd)={rg:>3}  gcd(ranks)={gr:>3}  "
              f"rank(gcd)|gcd(ranks)? {gr % rg == 0}   {status}")
    print()


def main() -> None:
    print("\nFIBONACCI RANK OF APPARITION — NUMERICAL DEMONSTRATIONS\n")
    demo_law_of_apparition(moduli=[2, 3, 4, 5, 7, 11, 13], n_max=40)
    demo_primitivity_bridge(n_max=15)
    demo_gluing_law(pairs=[(4, 9), (8, 25), (3, 7), (4, 5), (9, 11)])
    demo_local_to_global(numbers=[36, 60, 100, 360, 1000])
    demo_meet_obstruction(pairs=[(4, 6), (4, 9), (6, 10), (8, 12)])
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
