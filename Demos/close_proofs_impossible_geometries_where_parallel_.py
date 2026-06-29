"""
demo.py -- Impossible Geometries: Where Parallel Lines Converge AND Diverge
==========================================================================

A self-contained numerical companion to the "Fibonacci Apparition Lattice"
results.  Every function is inlined; the script depends only on the Python
standard library.

The central object is the *rank of apparition* (entry point)

    alpha(m) = least k > 0 such that m divides F(k),

where F is the Fibonacci sequence F(1) = F(2) = 1, F(n+2) = F(n+1) + F(n).

The "divisibility line" of a modulus m is

    L(m) = { k >= 0 : m | F(k) }.

The Law of Apparition states  m | F(k)  <=>  alpha(m) | k, hence

    L(m) = alpha(m) * N   (a principal ideal / arithmetic progression).

This script demonstrates, purely numerically:

  1. The Law of Apparition.
  2. DIVERGENCE: each line is evenly spaced with gap exactly alpha(m).
  3. CONVERGENCE: any two lines re-intersect, and  L(a) cap L(b) = L(lcm(a,b)).
  4. The JOIN (lcm) law:  alpha(lcm(a,b)) = lcm(alpha(a), alpha(b)).
  5. MONOTONICITY:  a | b  =>  alpha(a) | alpha(b).
  6. The MEET bound and its STRICTNESS (a=4, b=6): alpha is a join-morphism
     but NOT a meet-morphism -- the asymmetry between converging and diverging.
  7. The Pythagorean (3,4,5) apparition profile (4, 6, 5).
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Core arithmetic                                                             #
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number with F(0) = 0, F(1) = 1, F(2) = 1, ..."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lcm(a: int, b: int) -> int:
    """Least common multiple of two non-negative integers."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def alpha(m: int) -> int:
    """Rank of apparition: least k > 0 with m | F(k).  Defined for m >= 1."""
    if m <= 0:
        raise ValueError("alpha is defined for positive moduli only")
    k = 1
    while fib(k) % m != 0:
        k += 1
    return k


def divisibility_line(m: int, bound: int) -> List[int]:
    """L(m) cap [0, bound] = { k in [0, bound] : m | F(k) }."""
    return [k for k in range(0, bound + 1) if fib(k) % m == 0]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_law_of_apparition(moduli: List[int], bound: int) -> None:
    print("=" * 70)
    print("1. LAW OF APPARITION:  m | F(k)  <=>  alpha(m) | k")
    print("=" * 70)
    for m in moduli:
        a = alpha(m)
        ok = all(((fib(k) % m == 0) == (k % a == 0)) for k in range(0, bound + 1))
        print(f"  m={m:>3}  alpha(m)={a:>3}   verified for k in [0,{bound}]: {ok}")
    print()


def demo_divergence(moduli: List[int], bound: int) -> None:
    print("=" * 70)
    print("2. DIVERGENCE (Euclidean face): each line is evenly spaced by alpha(m)")
    print("=" * 70)
    for m in moduli:
        line = divisibility_line(m, bound)
        gaps = [line[i + 1] - line[i] for i in range(len(line) - 1)]
        even = len(set(gaps)) <= 1
        print(f"  L({m:>3}) = {line[:8]}...   gap = {alpha(m):>3}   uniform spacing: {even}")
    print()


def demo_convergence(pairs: List[Tuple[int, int]], bound: int) -> None:
    print("=" * 70)
    print("3. CONVERGENCE (elliptic face): parallel lines re-meet")
    print("    L(a) cap L(b) = L(lcm(a,b)) = lcm(alpha a, alpha b) * N")
    print("=" * 70)
    for a, b in pairs:
        La = set(divisibility_line(a, bound))
        Lb = set(divisibility_line(b, bound))
        inter = sorted(La & Lb)
        L_lcm = divisibility_line(lcm(a, b), bound)
        step = lcm(alpha(a), alpha(b))
        print(f"  a={a}, b={b}:  L(a) cap L(b) = {inter[:6]}...")
        print(f"      L(lcm({a},{b})={lcm(a,b)}) = {L_lcm[:6]}...   match: {inter == L_lcm}")
        print(f"      meeting gap lcm(alpha {a}, alpha {b}) = {step}   "
              f"alpha(lcm) = {alpha(lcm(a, b))}\n")


def demo_join_law(pairs: List[Tuple[int, int]]) -> None:
    print("=" * 70)
    print("4. JOIN (lcm) LAW:  alpha(lcm(a,b)) = lcm(alpha(a), alpha(b))")
    print("=" * 70)
    for a, b in pairs:
        lhs = alpha(lcm(a, b))
        rhs = lcm(alpha(a), alpha(b))
        print(f"  a={a:>3}, b={b:>3}:  alpha(lcm)={lhs:>4}  vs  lcm(alpha,alpha)={rhs:>4}"
              f"   equal: {lhs == rhs}")
    print()


def demo_monotone(pairs: List[Tuple[int, int]]) -> None:
    print("=" * 70)
    print("5. MONOTONICITY:  a | b  =>  alpha(a) | alpha(b)")
    print("=" * 70)
    for a, b in pairs:
        if b % a == 0:
            ok = alpha(b) % alpha(a) == 0
            print(f"  {a} | {b}:  alpha({a})={alpha(a)} | alpha({b})={alpha(b)}  -> {ok}")
    print()


def demo_meet_strict() -> None:
    print("=" * 70)
    print("6. MEET bound and its STRICTNESS (join-morphism but NOT meet-morphism)")
    print("=" * 70)
    a, b = 4, 6
    g = gcd(a, b)
    lhs = alpha(g)
    rhs = gcd(alpha(a), alpha(b))
    print(f"  a={a}, b={b}:  gcd(a,b)={g}")
    print(f"  alpha(gcd) = alpha({g}) = {lhs}")
    print(f"  gcd(alpha {a}, alpha {b}) = gcd({alpha(a)},{alpha(b)}) = {rhs}")
    print(f"  alpha(gcd) | gcd(alpha,alpha): {rhs % lhs == 0}   (the meet BOUND holds)")
    print(f"  equality? {lhs == rhs}   <-- FALSE: the bound is STRICT")
    print()


def demo_pythagorean_profile() -> None:
    print("=" * 70)
    print("7. The Pythagorean (3,4,5) apparition profile")
    print("=" * 70)
    for m in (3, 4, 5):
        print(f"  alpha({m}) = {alpha(m)}   (F({alpha(m)}) = {fib(alpha(m))})")
    print(f"  profile (alpha 3, alpha 4, alpha 5) = "
          f"({alpha(3)}, {alpha(4)}, {alpha(5)})")
    print()


def build_alpha_table(limit: int) -> Dict[int, int]:
    """Return {m: alpha(m)} for 1 <= m <= limit."""
    return {m: alpha(m) for m in range(1, limit + 1)}


def main() -> None:
    moduli = [2, 3, 4, 5, 6, 7, 8, 11]
    bound = 60
    demo_law_of_apparition(moduli, bound)
    demo_divergence(moduli, bound)
    demo_convergence([(3, 4), (4, 5), (3, 5), (2, 3)], bound)
    demo_join_law([(3, 4), (4, 6), (6, 10), (5, 7)])
    demo_monotone([(2, 4), (2, 6), (3, 6), (4, 8), (5, 10)])
    demo_meet_strict()
    demo_pythagorean_profile()

    print("=" * 70)
    print("Apparition table alpha(m) for m = 1..20")
    print("=" * 70)
    table = build_alpha_table(20)
    print("  " + "  ".join(f"{m}->{a}" for m, a in table.items()))


if __name__ == "__main__":
    main()
