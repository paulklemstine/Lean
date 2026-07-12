"""
demo.py -- Numerical demonstrations for the Atkin-Lehner Genus-Zero Criterion.

This self-contained script demonstrates the elementary algebraic backbone of the
Atkin-Lehner theory underlying the Giampietro-Darmon factorization program:

  * the Atkin-Lehner composition law   d * e = d * e / gcd(d, e)^2
  * the Realization Theorem: on divisors of a squarefree N, the composition law
    equals symmetric difference of prime supports
  * the divisor-subset bijection and the order formula |AL(N)| = 2^omega(N)
  * the 2-torsion (elementary abelian) property
  * the Moebius parity characterization: mu(N) = 1 iff omega(N) is even
  * the classical genus-zero levels {6, 10, 22}

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import gcd, prod
from typing import Dict, FrozenSet, List, Set, Tuple


# ---------------------------------------------------------------------------
# Basic number theory helpers
# ---------------------------------------------------------------------------

def prime_factors(n: int) -> Set[int]:
    """Return the set of distinct prime factors of n (n >= 1)."""
    factors: Set[int] = set()
    d = 2
    m = n
    while d * d <= m:
        while m % d == 0:
            factors.add(d)
            m //= d
        d += 1
    if m > 1:
        factors.add(m)
    return factors


def is_squarefree(n: int) -> bool:
    """True iff no prime divides n twice."""
    m = n
    d = 2
    while d * d <= m:
        if m % (d * d) == 0:
            return False
        while m % d == 0:
            m //= d
        d += 1
    return True


def omega(n: int) -> int:
    """Number of distinct prime factors of n."""
    return len(prime_factors(n))


def moebius(n: int) -> int:
    """The Moebius function mu(n)."""
    if n == 1:
        return 1
    if not is_squarefree(n):
        return 0
    return (-1) ** omega(n)


def divisors(n: int) -> List[int]:
    """All positive divisors of n, sorted."""
    return sorted(d for d in range(1, n + 1) if n % d == 0)


# ---------------------------------------------------------------------------
# The Atkin-Lehner composition law
# ---------------------------------------------------------------------------

def al_mul(d: int, e: int) -> int:
    """The Atkin-Lehner composition law  d * e = d*e / gcd(d,e)^2."""
    g = gcd(d, e)
    return d * e // (g * g)


def symm_diff(a: Set[int], b: Set[int]) -> Set[int]:
    """Symmetric difference of two sets."""
    return (a - b) | (b - a)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_realization_theorem(N: int) -> None:
    """Verify: for all divisors d, e of squarefree N,
       primeFactors(d * e) = symmDiff(primeFactors(d), primeFactors(e))
       and d * e is again a divisor of N (closure)."""
    assert is_squarefree(N), "N must be squarefree"
    print(f"\n=== Realization Theorem for N = {N} (prime factors {sorted(prime_factors(N))}) ===")
    divs = divisors(N)
    all_ok = True
    for d in divs:
        for e in divs:
            prod_de = al_mul(d, e)
            lhs = prime_factors(prod_de)
            rhs = symm_diff(prime_factors(d), prime_factors(e))
            closed = (N % prod_de == 0)
            ok = (lhs == rhs) and closed
            all_ok = all_ok and ok
    print(f"  Checked all {len(divs)}x{len(divs)} pairs of divisors.")
    print(f"  Composition law realizes symmetric difference AND stays within divisors: {all_ok}")

    # A vivid single example with cancellation, when available.
    if 6 in divs and 15 in divs:
        print(f"  Example: 6 * 15 = {al_mul(6, 15)}  (shared prime 3 cancels: "
              f"{sorted(prime_factors(6))} triangle {sorted(prime_factors(15))} "
              f"= {sorted(symm_diff(prime_factors(6), prime_factors(15)))})")


def demo_group_structure(N: int) -> None:
    """Show the divisors of squarefree N form (Z/2)^omega(N) under the AL law."""
    assert is_squarefree(N)
    print(f"\n=== Group structure of AL({N}) ===")
    divs = divisors(N)
    print(f"  |AL(N)| = number of divisors = {len(divs)},  2^omega(N) = {2 ** omega(N)}")
    assert len(divs) == 2 ** omega(N)

    # Identity is 1.
    assert all(al_mul(d, 1) == d for d in divs)
    print("  Identity element w_1 = 1 verified (d * 1 = d for all d).")

    # 2-torsion: every element is its own inverse.
    two_torsion = all(al_mul(d, d) == 1 for d in divs)
    print(f"  2-torsion (d * d = 1 for all d): {two_torsion}")

    # Commutativity.
    comm = all(al_mul(d, e) == al_mul(e, d) for d in divs for e in divs)
    print(f"  Commutativity (d * e = e * d): {comm}")

    # Associativity.
    assoc = all(
        al_mul(al_mul(d, e), f) == al_mul(d, al_mul(e, f))
        for d in divs for e in divs for f in divs
    )
    print(f"  Associativity: {assoc}")


def demo_divisor_subset_bijection(N: int) -> None:
    """Print the explicit divisor <-> subset-of-primes bijection."""
    assert is_squarefree(N)
    print(f"\n=== Divisor-subset bijection for N = {N} ===")
    primes = sorted(prime_factors(N))
    # Enumerate all subsets, map to product, check inverse.
    all_subsets: List[FrozenSet[int]] = []
    for r in range(len(primes) + 1):
        for combo in combinations(primes, r):
            all_subsets.append(frozenset(combo))
    print(f"  {'subset of primes':<24} {'-> product (divisor)':<22} {'-> back to primeFactors'}")
    for s in all_subsets:
        p = prod(s) if s else 1
        back = prime_factors(p)
        assert back == set(s)
        print(f"  {str(sorted(s)):<24} {p:<22} {sorted(back)}")


def demo_moebius_parity(limit: int = 30) -> None:
    """Verify mu(N) = 1 iff N squarefree with an even number of prime factors."""
    print(f"\n=== Moebius parity characterization (N up to {limit}) ===")
    print(f"  {'N':>3}  {'squarefree':>10}  {'omega(N)':>8}  {'mu(N)':>6}  "
          f"{'mu==1 <=> even omega':>22}")
    for n in range(2, limit + 1):
        sf = is_squarefree(n)
        w = omega(n)
        mu = moebius(n)
        if sf:
            consistent = (mu == 1) == (w % 2 == 0)
            print(f"  {n:>3}  {str(sf):>10}  {w:>8}  {mu:>6}  {str(consistent):>22}")


def demo_genus_zero_levels() -> None:
    """The classical genus-zero levels {6, 10, 22}."""
    print("\n=== Classical genus-zero levels {6, 10, 22} ===")
    for N in (6, 10, 22):
        print(f"  N = {N:>2} = {' * '.join(map(str, sorted(prime_factors(N))))}: "
              f"squarefree={is_squarefree(N)}, omega={omega(N)} (even), mu={moebius(N)}")
    print("  These are exactly the squarefree even-omega levels where X_N itself has genus 0,")
    print("  the operative hypothesis of the ORIGINAL Giampietro-Darmon conjecture.")


def cayley_table(N: int) -> None:
    """Print the Cayley (multiplication) table of AL(N) under the composition law."""
    assert is_squarefree(N)
    print(f"\n=== Cayley table of AL({N}) under the Atkin-Lehner law ===")
    divs = divisors(N)
    header = "     " + "".join(f"{e:>5}" for e in divs)
    print(header)
    for d in divs:
        row = f"{d:>4} " + "".join(f"{al_mul(d, e):>5}" for e in divs)
        print(row)


def main() -> None:
    print("=" * 74)
    print("Atkin-Lehner Genus-Zero Criterion for Giampietro-Darmon Factorization")
    print("Numerical demonstrations")
    print("=" * 74)

    demo_realization_theorem(30)          # 2*3*5, has divisors 6 and 15
    demo_group_structure(30)
    demo_divisor_subset_bijection(6)
    cayley_table(6)
    demo_moebius_parity(30)
    demo_genus_zero_levels()

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
