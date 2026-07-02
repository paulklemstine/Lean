"""
Numerical demonstrations for:

    Fermat's Little Theorem at p = 5, and the sharp strengthening 30 | a^5 - a.

Main facts demonstrated:
  * 5  | a^5 - a           for every integer a   (Fermat's Little Theorem, p = 5)
  * 30 | a^5 - a           for every integer a   (sharp strengthening; 30 is optimal)
  * a^5 - a = a(a-1)(a+1)(a^2+1)                  (elementary factorisation)
  * a^5 ≡ a (mod 5)                               (congruence form)
  * 5  | sum_{k<n} (k^5 - k)                       (summed form)
  * The universal divisor gcd_a (a^n - a) = product of primes p with (p-1)|(n-1)

Self-contained: run `python demo.py`.  Standard library only.
"""

from __future__ import annotations

from math import gcd, prod
from functools import reduce


# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------

def pow_sub(a: int, n: int = 5) -> int:
    """Return a^n - a."""
    return a ** n - a


def factorised_pow_five_sub(a: int) -> int:
    """Return a(a-1)(a+1)(a^2+1), the factorisation of a^5 - a."""
    return a * (a - 1) * (a + 1) * (a ** 2 + 1)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_divisible_by_five(lo: int = -6, hi: int = 12) -> None:
    """Show that 5 divides a^5 - a for a range of integers a."""
    print("=== Fermat's Little Theorem for p = 5:  5 | a^5 - a ===")
    for a in range(lo, hi + 1):
        v = pow_sub(a, 5)
        assert v % 5 == 0, f"FAILED at a={a}"
        print(f"  a={a:>3}:  a^5 - a = {v:>8}   (v/5 = {v // 5})")
    print("  All values divisible by 5.\n")


def demo_divisible_by_thirty(lo: int = -6, hi: int = 12) -> None:
    """Show the sharp strengthening: 30 divides a^5 - a."""
    print("=== Sharp strengthening:  30 | a^5 - a ===")
    for a in range(lo, hi + 1):
        v = pow_sub(a, 5)
        assert v % 30 == 0, f"FAILED at a={a}"
        print(f"  a={a:>3}:  a^5 - a = {v:>8}   (v/30 = {v // 30})")
    print("  All values divisible by 30.\n")


def demo_factorisation(lo: int = -6, hi: int = 12) -> None:
    """Verify a^5 - a = a(a-1)(a+1)(a^2+1)."""
    print("=== Factorisation:  a^5 - a = a(a-1)(a+1)(a^2+1) ===")
    for a in range(lo, hi + 1):
        lhs, rhs = pow_sub(a, 5), factorised_pow_five_sub(a)
        assert lhs == rhs, f"FAILED at a={a}"
    print("  Identity verified for all tested a.\n")


def demo_congruence(lo: int = -6, hi: int = 12) -> None:
    """Verify the congruence form a^5 ≡ a (mod 5)."""
    print("=== Congruence form:  a^5 mod 5 = a mod 5 ===")
    for a in range(lo, hi + 1):
        assert (a ** 5) % 5 == a % 5, f"FAILED at a={a}"
        print(f"  a={a:>3}:  a^5 mod 5 = {(a ** 5) % 5},  a mod 5 = {a % 5}")
    print("  Congruence holds for all tested a.\n")


def demo_summed_form(max_n: int = 10) -> None:
    """Verify 5 | sum_{k<n} (k^5 - k) for n = 0..max_n."""
    print("=== Summed form:  5 | sum_{k<n} (k^5 - k) ===")
    for n in range(max_n + 1):
        s = sum(pow_sub(k, 5) for k in range(n))
        assert s % 5 == 0, f"FAILED at n={n}"
        print(f"  n={n:>3}:  sum = {s:>10}   (sum/5 = {s // 5})")
    print("  Every partial sum divisible by 5.\n")


def demo_optimality() -> None:
    """Show 30 is the LARGEST universal divisor of a^5 - a (witnessed at a=2)."""
    print("=== Optimality of 30 ===")
    values = [pow_sub(a, 5) for a in range(2, 40)]
    g = reduce(gcd, values)
    print(f"  gcd over a=2..39 of (a^5 - a) = {g}")
    print(f"  2^5 - 2 = {pow_sub(2, 5)}  (the extremal witness)")
    assert g == 30
    print("  Confirmed: 30 is optimal.\n")


# ----------------------------------------------------------------------------
# The general universal divisor M(n)
# ----------------------------------------------------------------------------

def primes_up_to(limit: int) -> list[int]:
    """Sieve of Eratosthenes: all primes <= limit."""
    sieve = [True] * (limit + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, is_p in enumerate(sieve) if is_p]


def universal_divisor_formula(n: int, prime_bound: int = 200) -> int:
    """
    Conjectured universal divisor M(n) = product of primes p with (p-1) | (n-1).
    """
    return prod(p for p in primes_up_to(prime_bound) if (n - 1) % (p - 1) == 0)


def universal_divisor_empirical(n: int, lo: int = 2, hi: int = 60) -> int:
    """M(n) computed empirically as gcd of a^n - a over a range of a."""
    return reduce(gcd, (a ** n - a for a in range(lo, hi + 1)))


def demo_universal_divisor(max_n: int = 12) -> None:
    """Compare the formula for M(n) against the empirical gcd."""
    print("=== Universal divisor M(n) = prod{ p : (p-1) | (n-1) } ===")
    print("   n   formula   empirical   match")
    for n in range(2, max_n + 1):
        f = universal_divisor_formula(n)
        e = universal_divisor_empirical(n)
        match = "OK" if f == e else "MISMATCH"
        print(f"  {n:>3}   {f:>7}   {e:>9}   {match}")
        assert f == e, f"formula/empirical mismatch at n={n}"
    print("  M(5) = 30, as proved.\n")


def main() -> None:
    demo_divisible_by_five()
    demo_divisible_by_thirty()
    demo_factorisation()
    demo_congruence()
    demo_summed_form()
    demo_optimality()
    demo_universal_divisor()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
