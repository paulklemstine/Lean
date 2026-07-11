"""
Counterfactual Number Theory: What If Primes Were Different?

A fully self-contained numerical exploration of the Hilbert monoid

    H = { n in N : n = 1 (mod 4) } = {1, 5, 9, 13, 17, 21, 25, 29, ...}

and its "counterfactual primes" (the H-irreducible elements).

We demonstrate the three headline results:

  1. Multiplicative closure SURVIVES: H is a submonoid of (N, *).
  2. Infinitude of primes SURVIVES: rational primes p = 1 (mod 4) are
     H-irreducible, and there are infinitely many of them (Dirichlet).
  3. Unique factorization COLLAPSES: 441 = 9 * 49 = 21 * 21, with
     9, 21, 49 all H-irreducible and {9, 49} != {21, 21}.

Run:  python demo.py
"""

from __future__ import annotations

from collections import Counter
from typing import Iterator


# ---------------------------------------------------------------------------
# Core predicates
# ---------------------------------------------------------------------------

def in_H(n: int) -> bool:
    """Membership in the Hilbert monoid H = {n : n = 1 (mod 4)}."""
    return n % 4 == 1


def is_prime(n: int) -> bool:
    """Ordinary primality test by trial division."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def is_H_irreducible(n: int) -> bool:
    """
    An H-irreducible (counterfactual prime): n >= 2, n in H, and n admits no
    nontrivial factorization a*b = n with BOTH a, b in H (a, b > 1).
    """
    if n < 2 or not in_H(n):
        return False
    a = 1
    while a * a <= n:
        if n % a == 0:
            b = n // a
            if a > 1 and b > 1 and in_H(a) and in_H(b):
                return False
        a += 1
    return True


# ---------------------------------------------------------------------------
# Factorization into H-irreducibles
# ---------------------------------------------------------------------------

def H_factorizations(n: int) -> list[tuple[int, ...]]:
    """
    Return all factorizations of n (in H) into H-irreducibles, as sorted
    tuples, de-duplicated so that reorderings count once.
    """
    irr = [m for m in range(2, n + 1) if is_H_irreducible(m)]
    results: set[tuple[int, ...]] = set()

    def rec(rem: int, start: int, acc: list[int]) -> None:
        if rem == 1:
            if acc:
                results.add(tuple(sorted(acc)))
            return
        for p in irr:
            if p < start:
                continue
            if p > rem:
                break
            if rem % p == 0:
                acc.append(p)
                rec(rem // p, p, acc)
                acc.pop()

    rec(n, 2, [])
    return sorted(results)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_closure(limit: int = 200) -> None:
    """Result 1: H is closed under multiplication (checked exhaustively)."""
    print("=" * 70)
    print("RESULT 1  -  Multiplicative structure SURVIVES")
    print("=" * 70)
    members = [n for n in range(1, limit) if in_H(n)]
    print(f"H below {limit}: {members[:15]} ...")
    print(f"1 in H? {in_H(1)}")
    ok = all(in_H(a * b) for a in members for b in members if a * b < limit * limit)
    print(f"Closure a,b in H  =>  a*b in H : verified = {ok}")
    print()


def demo_infinitude(limit: int = 100) -> None:
    """Result 2: rational primes = 1 (mod 4) are counterfactual primes."""
    print("=" * 70)
    print("RESULT 2  -  Infinitude of primes SURVIVES (via Dirichlet)")
    print("=" * 70)
    dirichlet = [p for p in range(2, limit) if is_prime(p) and p % 4 == 1]
    print(f"Rational primes = 1 (mod 4) below {limit}:")
    print(f"  {dirichlet}")
    all_irr = all(is_H_irreducible(p) for p in dirichlet)
    print(f"Each is H-irreducible: {all_irr}")
    counter_primes = [n for n in range(2, limit) if is_H_irreducible(n)]
    print(f"All counterfactual primes below {limit}:")
    print(f"  {counter_primes}")
    print("(Note 9, 21, 25, 49, ... are promoted despite being composite.)")
    print()


def demo_unique_factorization_fails() -> None:
    """Result 3: unique factorization collapses at 441."""
    print("=" * 70)
    print("RESULT 3  -  Unique factorization COLLAPSES")
    print("=" * 70)
    for n in (9, 21, 49):
        print(f"  {n} is H-irreducible: {is_H_irreducible(n)}   "
              f"(ordinary factorization forbidden: 3, 7 = 3 mod 4)")
    print(f"  9 * 49 = {9 * 49},   21 * 21 = {21 * 21}")
    facs = H_factorizations(441)
    print(f"  Factorizations of 441 into counterfactual primes: {facs}")
    ms1, ms2 = Counter([9, 49]), Counter([21, 21])
    print(f"  Multisets differ: {{9,49}} != {{21,21}}  ->  {ms1 != ms2}")
    print(f"  Fundamental Theorem of Arithmetic FAILS in H: "
          f"{len(facs) >= 2}")
    print()


def demo_search_smallest_witness(limit: int = 600) -> None:
    """Confirm 441 is the SMALLEST element of H with non-unique factorization."""
    print("=" * 70)
    print("RESULT 3b  -  441 is the minimal witness")
    print("=" * 70)
    witnesses: list[int] = []
    for n in range(5, limit + 1):
        if in_H(n) and len(H_factorizations(n)) >= 2:
            witnesses.append(n)
    print(f"Elements of H below {limit} with >= 2 factorizations:")
    print(f"  {witnesses[:10]}")
    if witnesses:
        print(f"Smallest witness: {witnesses[0]}")
    print()


def main() -> None:
    print("\nCOUNTERFACTUAL NUMBER THEORY  -  the Hilbert monoid H = {n = 1 mod 4}\n")
    demo_closure()
    demo_infinitude()
    demo_unique_factorization_fails()
    demo_search_smallest_witness()
    print("Summary: closure survives, infinitude survives, uniqueness collapses.")


if __name__ == "__main__":
    main()
