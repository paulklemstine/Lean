"""
demo.py — Numerical demonstrations of the order type of the p-degrees.

This script illustrates, with concrete numbers, the structural facts proved
about the Cook-Reckhow p-simulation order over the natural numbers:

  * the polynomial blow-up class and its closure properties,
  * Fibonacci growth is super-polynomial (2^n <= F(2n+1)),
  * "exponential beats polynomial" (for each a,k there is m with (2m+a)^k < 2^m),
  * the domination reduction: simulation <-> polynomial domination of costs,
  * a least degree (zeroSys) below the linear system,
  * infinite width: spike systems from the 2-adic valuation are incomparable,
  * density: an intermediate system strictly between linear and Fibonacci.

Everything is self-contained: no external dependencies beyond the standard
library.  Run with:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Basic growth-class machinery
# ---------------------------------------------------------------------------

def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0)=0, F(1)=1, F(2)=1, ..."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def poly_bound(n: int, k: int) -> int:
    """The canonical polynomial bound (n+2)^k used in PolyBounded."""
    return (n + 2) ** k


def is_poly_bounded_upto(f: Callable[[int], int], k: int, N: int) -> bool:
    """Check f(n)+1 <= (n+2)^k for all n < N (a finite witness check)."""
    return all(f(n) + 1 <= poly_bound(n, k) for n in range(N))


# ---------------------------------------------------------------------------
# Fact 1: Fibonacci growth is super-polynomial:  2^n <= F(2n+1)
# ---------------------------------------------------------------------------

def check_two_pow_le_fib(N: int) -> List[Tuple[int, int, int, bool]]:
    """Return rows (n, 2^n, F(2n+1), 2^n <= F(2n+1)) for n < N."""
    rows = []
    for n in range(N):
        lhs = 2 ** n
        rhs = fib(2 * n + 1)
        rows.append((n, lhs, rhs, lhs <= rhs))
    return rows


# ---------------------------------------------------------------------------
# Fact 2: exponential beats polynomial:  for each a,k, some m has (2m+a)^k < 2^m
# ---------------------------------------------------------------------------

def first_exp_dominates_poly(a: int, k: int, search: int = 100000) -> Optional[int]:
    """Smallest m with (2m+a)^k < 2^m, or None if not found below `search`."""
    for m in range(search):
        if (2 * m + a) ** k < 2 ** m:
            return m
    return None


# ---------------------------------------------------------------------------
# Fact 3: Fibonacci escapes every polynomial bound
# ---------------------------------------------------------------------------

def fib_breaks_poly_bound(k: int, search: int = 100000) -> Optional[int]:
    """Smallest n with F(n)+1 > (n+2)^k, witnessing that fib is not poly-bounded
    with exponent k."""
    for n in range(search):
        if fib(n) + 1 > poly_bound(n, k):
            return n
    return None


# ---------------------------------------------------------------------------
# Domination reduction: simulation of sysOfSize(a) by sysOfSize(b)
# is "exists monotone poly-bounded f with a(n) <= f(b(n)) for all n".
#
# Below we test the *necessary* condition a(n) <= f(b(n)) on a finite range
# for a candidate blow-up f, and search for the smallest poly exponent that
# could serve.  This is a finite numerical witness, not a proof.
# ---------------------------------------------------------------------------

def dominates_with_shift(
    a: Callable[[int], int],
    b: Callable[[int], int],
    shift: int,
    N: int,
) -> bool:
    """Check a(n) <= b(n) + shift for all n < N (a simple linear blow-up test)."""
    return all(a(n) <= b(n) + shift for n in range(N))


# ---------------------------------------------------------------------------
# 2-adic valuation and the spike systems (infinite width)
# ---------------------------------------------------------------------------

def v2(n: int) -> int:
    """2-adic valuation: multiplicity of the prime 2 in n (v2(0) := 0 here)."""
    if n == 0:
        return 0
    c = 0
    while n % 2 == 0:
        n //= 2
        c += 1
    return c


def spike_cost(i: int, n: int) -> int:
    """Cost function of spikeSys i: 2^n on {n : v2(n)=i}, else 0."""
    return 2 ** n if v2(n) == i else 0


def spike_support(i: int, N: int) -> List[int]:
    """The first elements (< N) of the support {n : v2(n)=i}."""
    return [n for n in range(1, N) if v2(n) == i]


def spike_incomparable_witness(i: int, j: int, f0: int) -> int:
    """A theorem n in the support of spikeSys i with n > f0 (so that the
    unbounded spike 2^n there defeats any blow-up pinned at f(0)=f0).
    Uses n = 2^i * (2*(f0+1)+1), which has v2(n) = i."""
    return (2 ** i) * (2 * (f0 + 1) + 1)


# ---------------------------------------------------------------------------
# Density: the intermediate system between linear and Fibonacci
# ---------------------------------------------------------------------------

def lin_cost(n: int) -> int:
    """linSystem cost: the identity."""
    return n


def fib_cost(n: int) -> int:
    """fibSystem cost: Fibonacci."""
    return fib(n)


def inter_cost(n: int) -> int:
    """interSys cost: Fibonacci on even n, linear on odd n."""
    return fib(n) if n % 2 == 0 else n


# ---------------------------------------------------------------------------
# Pretty-printing the demonstrations
# ---------------------------------------------------------------------------

def section(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def main() -> None:
    section("1. Fibonacci is super-polynomial:  2^n <= F(2n+1)")
    print(f"{'n':>3} | {'2^n':>12} | {'F(2n+1)':>14} | holds")
    print("-" * 44)
    for n, lhs, rhs, ok in check_two_pow_le_fib(12):
        print(f"{n:>3} | {lhs:>12} | {rhs:>14} | {ok}")

    section("2. Exponential beats polynomial: smallest m with (2m+a)^k < 2^m")
    print(f"{'a':>3} {'k':>3} | smallest m")
    print("-" * 24)
    for a in (3, 4):
        for k in (1, 2, 3, 4):
            m = first_exp_dominates_poly(a, k)
            print(f"{a:>3} {k:>3} | {m}")

    section("3. Fibonacci escapes every polynomial bound (n+2)^k")
    print(f"{'k':>3} | smallest n with F(n)+1 > (n+2)^k")
    print("-" * 44)
    for k in range(1, 7):
        n = fib_breaks_poly_bound(k)
        print(f"{k:>3} | {n}")

    section("4. A least degree: zeroSys (cost 0) is below linSystem")
    print("zeroSys cost(n) = 0 for all n; linSystem cost(n) = n.")
    print("zeroSys simulates linSystem with identity blow-up: 0 <= id(n).")
    print("linSystem CANNOT simulate zeroSys: a blow-up of constant 0 is the")
    print("constant f(0); but linSystem needs unbounded sizes. So zeroSys < lin.")
    print(f"  example: lin cost at n=10^6 is {lin_cost(10**6)}, exceeding any fixed f(0).")

    section("5. Infinite width: spike systems are pairwise incomparable")
    for i in (0, 1, 2, 3):
        print(f"  support of spikeSys {i} (first elements): {spike_support(i, 40)}")
    print("\nThese supports are disjoint and infinite (n = 2^i*(2k+1) has v2=i).")
    print("Incomparability of spikeSys i and spikeSys j (i != j):")
    for (i, j) in [(0, 1), (1, 2), (0, 3)]:
        f0 = 1000  # any candidate blow-up value f(0)
        n = spike_incomparable_witness(i, j, f0)
        print(f"  i={i}, j={j}: witness n={n}, v2(n)={v2(n)}=i, n>f0={n > f0}, "
              f"spike cost 2^n > f0  =>  no simulation.")

    section("6. Density: linSystem < interSys < fibSystem")
    print(f"{'n':>3} | {'lin':>6} | {'inter':>8} | {'fib':>10} | parity")
    print("-" * 46)
    for n in range(12):
        parity = "even" if n % 2 == 0 else "odd"
        print(f"{n:>3} | {lin_cost(n):>6} | {inter_cost(n):>8} | "
              f"{fib_cost(n):>10} | {parity}")
    print("\ninterSys equals fib on evens (super-poly: above linSystem),")
    print("but only linear on odds (too thin: strictly below fibSystem).")

    section("Summary")
    print("The p-degrees over N form a partial order that is:")
    print("  * bottomed (zeroSys is least),")
    print("  * of infinite height with no top,")
    print("  * of infinite width (the spike antichain),")
    print("  * dense at the Fibonacci separation (interSys in the middle).")


if __name__ == "__main__":
    main()
