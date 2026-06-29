"""
demo.py — A computable primitive-divisor engine for strong divisibility sequences.

This script is a faithful, self-contained Python mirror of the mathematics in
`Catalog/Applications/StrongDivPrimitiveCriterion.lean`.  It demonstrates how a
SINGLE computable criterion — "the coprime part of u(n) exceeds 1" — simultaneously
discharges two classically distinct primitive-divisor theorems:

  * Carmichael's theorem (1913) for the Fibonacci numbers  F(n),
  * Bang's theorem (1886) for the Mersenne-like numbers     a^n - 1.

A *primitive prime divisor* of u(n) is a prime p that divides u(n) but divides no
earlier term u(k) with 0 < k < n.  The whole engine rests on one structural fact,
shared by every "strong divisibility sequence":

        gcd(u(m), u(n)) = u(gcd(m, n)).

No Fibonacci identity, no algebra of Mersenne numbers — only this gcd law.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Callable, Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# §1.  Two concrete strong divisibility sequences
# ---------------------------------------------------------------------------

def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0)=0, F(1)=1.  A strong divisibility sequence:
    gcd(F(m), F(n)) = F(gcd(m, n))."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne_base(a: int) -> Callable[[int], int]:
    """Return the sequence  n |-> a^n - 1.  For fixed base a this is a strong
    divisibility sequence: gcd(a^m - 1, a^n - 1) = a^gcd(m,n) - 1."""

    def u(n: int) -> int:
        return a ** n - 1

    return u


# ---------------------------------------------------------------------------
# §2.  The computable "coprime part" (sequence-agnostic integer bookkeeping)
# ---------------------------------------------------------------------------

def remove_primes_of(a: int, b: int) -> int:
    """Strip from `a` every prime it shares with `b`, by repeatedly dividing out
    gcd(a, b).  The result divides `a` and is coprime to `b` (for a > 0).

    Mirrors the Lean `removePrimesOf`."""
    if a == 0:
        return 0
    while True:
        g = gcd(a, b)
        if g <= 1:
            return a
        a //= g


def proper_divisors(n: int) -> List[int]:
    """All d with 0 < d < n and d | n.  (Lean filters List.range n.)"""
    return [d for d in range(1, n) if n % d == 0]


def coprime_part(u: Callable[[int], int], n: int) -> int:
    """Start from u(n); for every proper divisor d | n, strip out the primes shared
    with u(d).  Whatever survives is built only from *primitive* primes of u(n).

    Mirrors the Lean `coprimePart`."""
    acc = u(n)
    for d in proper_divisors(n):
        acc = remove_primes_of(acc, u(d))
    return acc


# ---------------------------------------------------------------------------
# §3.  The engine and an explicit primitive witness
# ---------------------------------------------------------------------------

def smallest_prime_factor(m: int) -> int:
    """Smallest prime factor of m > 1."""
    d = 2
    while d * d <= m:
        if m % d == 0:
            return d
        d += 1
    return m


def has_primitive_divisor(u: Callable[[int], int], n: int) -> bool:
    """The engine's verdict: u(n) has a primitive prime divisor whenever the
    computable coprime part exceeds 1.  (One direction of the Lean theorem
    `primitive_of_coprimePart_pos`; it is *sufficient*.)"""
    return coprime_part(u, n) > 1


def primitive_witness(u: Callable[[int], int], n: int) -> Optional[int]:
    """Return an explicit primitive prime divisor of u(n) if the engine fires.
    Any prime of the coprime part works."""
    cp = coprime_part(u, n)
    if cp <= 1:
        return None
    return smallest_prime_factor(cp)


def verify_primitive(u: Callable[[int], int], p: int, n: int) -> bool:
    """Directly check the *definition* of primitivity: p | u(n) and p does not
    divide any u(k), 0 < k < n.  Used to cross-check the engine's witness."""
    if u(n) % p != 0:
        return False
    return all(u(k) % p != 0 for k in range(1, n))


# ---------------------------------------------------------------------------
# §4.  Demonstrations
# ---------------------------------------------------------------------------

def demo_strong_divisibility(samples: List[Tuple[int, int]]) -> None:
    print("=" * 72)
    print(" The structural fact: gcd(F(m), F(n)) = F(gcd(m, n))")
    print("=" * 72)
    for m, n in samples:
        lhs = gcd(fib(m), fib(n))
        rhs = fib(gcd(m, n))
        ok = "OK" if lhs == rhs else "FAIL"
        print(f"  m={m:3d} n={n:3d} : gcd(F{m},F{n})={lhs:<12d} "
              f"F(gcd)={rhs:<12d} [{ok}]")
    print()


def demo_fibonacci_carmichael(hi: int = 40) -> None:
    print("=" * 72)
    print(" Carmichael's theorem for Fibonacci  (engine + explicit witness)")
    print("=" * 72)
    print(f" Claim: every F(n) with 13 <= n has a primitive prime divisor.")
    print(f" The classical exceptions are exactly n in {{1, 2, 6, 12}}.")
    print("-" * 72)
    print(f"  {'n':>3} {'F(n)':>14} {'coprimePart':>12} {'witness p':>10} {'verified'}")
    for n in range(1, hi + 1):
        cp = coprime_part(fib, n)
        p = primitive_witness(fib, n)
        if p is None:
            print(f"  {n:>3} {fib(n):>14} {cp:>12} {'--none--':>10}   (exception)")
        else:
            ok = verify_primitive(fib, p, n)
            print(f"  {n:>3} {fib(n):>14} {cp:>12} {p:>10}   {ok}")
    print()


def demo_mersenne_bang(base: int = 2, hi: int = 24) -> None:
    print("=" * 72)
    print(f" Bang's theorem for  {base}^n - 1  (same engine, no new math)")
    print("=" * 72)
    print(f" Claim: every {base}^n - 1 with 2 <= n has a primitive prime divisor,")
    print(f" with the unique Zsygmondy exception n = 6 (={base}^6-1={base**6-1}).")
    print("-" * 72)
    u = mersenne_base(base)
    print(f"  {'n':>3} {'a^n-1':>14} {'coprimePart':>12} {'witness p':>10} {'verified'}")
    for n in range(1, hi + 1):
        cp = coprime_part(u, n)
        p = primitive_witness(u, n)
        if p is None:
            print(f"  {n:>3} {u(n):>14} {cp:>12} {'--none--':>10}   (exception)")
        else:
            ok = verify_primitive(u, p, n)
            print(f"  {n:>3} {u(n):>14} {cp:>12} {p:>10}   {ok}")
    print()


def find_exceptions(u: Callable[[int], int], lo: int, hi: int) -> List[int]:
    """Indices in [lo, hi] where the engine reports NO primitive divisor."""
    return [n for n in range(lo, hi + 1) if not has_primitive_divisor(u, n)]


def demo_exception_sets() -> None:
    print("=" * 72)
    print(" Automatic discovery of the exceptional sets")
    print("=" * 72)
    fib_exc = find_exceptions(fib, 1, 200)
    mer_exc = find_exceptions(mersenne_base(2), 1, 120)
    print(f"  Fibonacci exceptions in [1,200]:   {fib_exc}")
    print(f"  Expected (Carmichael):             [1, 2, 6, 12]")
    print(f"  2^n - 1 exceptions in [1,120]:     {mer_exc}")
    print(f"  Expected (Bang/Zsygmondy):         [1, 6]")
    print()


def main() -> None:
    demo_strong_divisibility([(8, 12), (10, 15), (14, 21), (12, 18)])
    demo_fibonacci_carmichael(hi=30)
    demo_mersenne_bang(base=2, hi=20)
    demo_exception_sets()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


"""
visualize.py — Visualizing the primitive-divisor engine for strong divisibility sequences.

Produces a figure with two panels:
  (left)  Fibonacci F(n): the coprime part cp(F, n) on a log scale, with barren
          indices {1,2,6,12} highlighted in red.
  (right) Mersenne 2^n - 1: the coprime part cp(u, n) on a log scale, with the
          single barren index {6} highlighted in red.

Wherever cp > 1 a primitive prime divisor is guaranteed (Theorem
`primitive_of_coprimePart_pos`).  The red bars sit at height 1 — exactly the
classical exception sets of Carmichael (Fibonacci) and Bang (2^n - 1).

Requires: matplotlib, numpy.   Run:  python3 visualize.py
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List

import matplotlib.pyplot as plt
import numpy as np


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne(n: int, a: int = 2) -> int:
    return a ** n - 1


def remove_primes_of(a: int, b: int) -> int:
    if a == 0:
        return 0
    while True:
        g = gcd(a, b)
        if g <= 1:
            return a
        a //= g


def coprime_part(u: Callable[[int], int], n: int) -> int:
    acc = u(n)
    for d in range(1, n):
        if n % d == 0:
            acc = remove_primes_of(acc, u(d))
    return acc


def bars(u: Callable[[int], int], hi: int) -> List[float]:
    return [max(coprime_part(u, n), 1) for n in range(1, hi + 1)]


def main() -> None:
    hi_f, hi_m = 40, 30
    xs_f = np.arange(1, hi_f + 1)
    xs_m = np.arange(1, hi_m + 1)
    cp_f = bars(fib, hi_f)
    cp_m = bars(mersenne, hi_m)

    fib_exc = {1, 2, 6, 12}
    mer_exc = {1, 6}

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    col_f = ["#d62728" if n in fib_exc else "#1f77b4" for n in xs_f]
    ax1.bar(xs_f, cp_f, color=col_f, log=True)
    ax1.axhline(1, color="black", lw=0.8, ls="--")
    ax1.set_title("Fibonacci: coprime part cp(F, n)\n(red = barren, height 1)")
    ax1.set_xlabel("n")
    ax1.set_ylabel("cp(F, n)  (log scale)")

    col_m = ["#d62728" if n in mer_exc else "#2ca02c" for n in xs_m]
    ax2.bar(xs_m, cp_m, color=col_m, log=True)
    ax2.axhline(1, color="black", lw=0.8, ls="--")
    ax2.set_title("Mersenne 2^n - 1: coprime part cp(u, n)\n(red = barren, height 1)")
    ax2.set_xlabel("n")
    ax2.set_ylabel("cp(2^n - 1, n)  (log scale)")

    fig.suptitle(
        "One engine, two theorems: a coprime part > 1 certifies a primitive prime divisor",
        fontsize=13,
    )
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("coprime_part.png", dpi=140)
    print("Wrote coprime_part.png")


if __name__ == "__main__":
    main()
