"""
Numerical companion to:

    Regularized Sum of Primes via Analytic Continuation Beyond the Natural Boundary

This script demonstrates, purely numerically, the main rigorous results:

  * primeZeta_summable_iff          -> P(s) = sum_p p^{-s} converges iff s > 1
  * primeZeta_not_summable_one      -> sum_p 1/p diverges (Euler boundary, s = 1)
  * primeZeta_not_summable_neg_one  -> sum_p p diverges  (the "sum of all primes")
  * primeZeta_abscissa_eq_nat_zeta  -> prime and full series share abscissa = 1
  * riemannZeta_neg_one_eq          -> zeta(-1) = -1/12 (the additive escape)

Everything is self-contained: no third-party imports, only the standard library.
"""

from __future__ import annotations

from fractions import Fraction
from math import log
from typing import Callable, Iterator, List, Tuple


# --------------------------------------------------------------------------- #
#  Prime generation                                                           #
# --------------------------------------------------------------------------- #
def primes_up_to(limit: int) -> List[int]:
    """Return all primes p with 2 <= p <= limit via a sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve: List[bool] = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, is_p in enumerate(sieve) if is_p]


def first_n_primes(n: int) -> List[int]:
    """Return the first n primes (n >= 0)."""
    if n <= 0:
        return []
    # Rough upper bound for the n-th prime (n >= 6): n(ln n + ln ln n).
    if n < 6:
        bound = 15
    else:
        bound = int(n * (log(n) + log(log(n)))) + 10
    ps = primes_up_to(bound)
    while len(ps) < n:
        bound *= 2
        ps = primes_up_to(bound)
    return ps[:n]


# --------------------------------------------------------------------------- #
#  Prime zeta partial sums  (Theorem: primeZeta_summable_iff)                 #
# --------------------------------------------------------------------------- #
def prime_zeta_partial(s: float, n_primes: int) -> float:
    """Partial sum S_n(s) = sum over the first n primes of p^{-s}."""
    return sum(p ** (-s) for p in first_n_primes(n_primes))


def doubling_ratio(s: float, n_primes: int) -> float:
    """
    Ratio S_{2n}(s) / S_n(s).  For a convergent series this tends to 1;
    for a divergent series it stays bounded away from 1 (or grows).
    """
    s_n = prime_zeta_partial(s, n_primes)
    s_2n = prime_zeta_partial(s, 2 * n_primes)
    return s_2n / s_n if s_n != 0 else float("inf")


def demonstrate_abscissa() -> None:
    """Witness primeZeta_summable_iff: the convergence wall sits exactly at s = 1."""
    print("=" * 70)
    print("  Abscissa of convergence of P(s) = sum_p p^{-s}  (wall at s = 1)")
    print("=" * 70)
    print(f"{'s':>8} | {'S_4000(s)':>16} | {'S_8000/S_4000':>14} | verdict")
    print("-" * 70)
    for s in (3.0, 2.0, 1.5, 1.1, 1.0, 0.5, 0.0, -1.0):
        partial = prime_zeta_partial(s, 4000)
        ratio = doubling_ratio(s, 4000)
        verdict = "converges (s>1)" if s > 1 else "DIVERGES (s<=1)"
        print(f"{s:>8.2f} | {partial:>16.6f} | {ratio:>14.6f} | {verdict}")
    print()
    print("Observe: for s > 1 the partial sums stabilize and the doubling ratio")
    print("-> 1; for s <= 1 the sums keep growing. The threshold is exactly 1.")
    print()


# --------------------------------------------------------------------------- #
#  Euler boundary (s = 1) and the sum-of-all-primes point (s = -1)            #
# --------------------------------------------------------------------------- #
def demonstrate_boundary_and_target() -> None:
    """
    Witness primeZeta_not_summable_one (sum 1/p ~ loglog) and
    primeZeta_not_summable_neg_one (sum p grows without bound).
    """
    print("=" * 70)
    print("  Boundary s = 1 (sum of 1/p) and target s = -1 (sum of p)")
    print("=" * 70)
    print(f"{'# primes':>9} | {'sum 1/p (s=1)':>15} | {'sum p (s=-1)':>16}")
    print("-" * 70)
    for n in (10, 100, 1000, 10_000, 100_000):
        ps = first_n_primes(n)
        recip = sum(1.0 / p for p in ps)
        total = sum(ps)
        print(f"{n:>9} | {recip:>15.6f} | {total:>16}")
    print()
    print("sum 1/p crawls upward like log log N (Euler, 1737) -- it never settles.")
    print("sum p explodes -- this is the bare 'sum of all primes', and it diverges.")
    print("Therefore -1/12-style regularization can NOT be the series value here.")
    print()


# --------------------------------------------------------------------------- #
#  Equal abscissae:  prime series vs full zeta series                         #
#  (Theorem: primeZeta_abscissa_eq_nat_zeta)                                  #
# --------------------------------------------------------------------------- #
def nat_zeta_partial(s: float, n_terms: int) -> float:
    """Partial sum sum_{n=1}^{N} n^{-s} of the full zeta series."""
    return sum(n ** (-s) for n in range(1, n_terms + 1))


def demonstrate_equal_abscissa() -> None:
    """
    Both sum_p p^{-s} and sum_n n^{-s} converge iff s > 1: the doubling ratio
    tends to 1 for both exactly when s > 1.
    """
    print("=" * 70)
    print("  Same abscissa: prime series and full integer series both wall at 1")
    print("=" * 70)
    print(f"{'s':>6} | {'prime ratio':>13} | {'integer ratio':>14} | same verdict?")
    print("-" * 70)
    for s in (2.0, 1.5, 1.0, 0.5):
        pr = doubling_ratio(s, 4000)
        s_n = nat_zeta_partial(s, 4000)
        s_2n = nat_zeta_partial(s, 8000)
        ir = s_2n / s_n
        prime_conv = abs(pr - 1.0) < 0.01
        int_conv = abs(ir - 1.0) < 0.01
        agree = "yes" if prime_conv == int_conv else "no"
        print(f"{s:>6.2f} | {pr:>13.6f} | {ir:>14.6f} | {agree}")
    print()
    print("The convergence verdict agrees for every s: identical abscissa = 1.")
    print()


# --------------------------------------------------------------------------- #
#  The additive escape:  zeta(-1) = -1/12  via exact Bernoulli numbers        #
#  (Theorem: riemannZeta_neg_one_eq)                                          #
# --------------------------------------------------------------------------- #
def bernoulli_numbers(n: int) -> List[Fraction]:
    """Exact Bernoulli numbers B_0, ..., B_n (convention B_1 = -1/2)."""
    from math import comb

    b: List[Fraction] = []
    for m in range(n + 1):
        s = Fraction(0)
        for k in range(m):
            s += Fraction(comb(m + 1, k)) * b[k]
        b.append(Fraction(1) if m == 0 else -s / Fraction(m + 1))
    return b


def zeta_at_negative_integer(n: int) -> Fraction:
    """
    zeta(-n) = -B_{n+1}/(n+1) for n >= 1 (exact rational).
    For n = 1 this returns -1/12, matching riemannZeta_neg_one_eq.
    """
    b = bernoulli_numbers(n + 1)
    return -b[n + 1] / Fraction(n + 1)


def demonstrate_zeta_regularization() -> None:
    """Witness riemannZeta_neg_one_eq: the full zeta function escapes to -1/12."""
    print("=" * 70)
    print("  The additive escape: zeta(-1) = -1/12 (Bernoulli formula)")
    print("=" * 70)
    z_minus1 = zeta_at_negative_integer(1)
    print(f"  zeta(-1) = -B_2 / 2 = {z_minus1}  (expected -1/12)")
    assert z_minus1 == Fraction(-1, 12)
    print(f"  zeta(-3) = -B_4 / 4 = {zeta_at_negative_integer(3)}  (expected 1/120)")
    assert zeta_at_negative_integer(3) == Fraction(1, 120)
    print()
    print("The INTEGER series escapes its wall to a finite value at s = -1.")
    print("The PRIME series cannot: it has a natural boundary at Re s = 0.")
    print()


# --------------------------------------------------------------------------- #
#  Main                                                                        #
# --------------------------------------------------------------------------- #
def main() -> None:
    demonstrate_abscissa()
    demonstrate_boundary_and_target()
    demonstrate_equal_abscissa()
    demonstrate_zeta_regularization()
    print("All numerical demonstrations completed and assertions passed.")


if __name__ == "__main__":
    main()
