"""
Numerical demonstrations for the Siegel--Weil identity of the E8 lattice
theta series.

Central fact (the E8 mass formula / Siegel--Weil in rank 8):

    The number of vectors of squared length 2n in the E8 root lattice equals

        r_{E8}(n) = 240 * sigma_3(n),                            (*)

    where sigma_3(n) = sum over divisors d of n of d^3 is the sum-of-cubes
    divisor function. Equivalently, the theta series of E8 equals the
    normalized weight-4 Eisenstein series E_4.

This file demonstrates, purely by elementary computation, the structural
facts that accompany (*):

  1. The representation numbers r_{E8}(n) = 240 * sigma_3(n).
  2. The Hecke three-term recurrence at a prime p.
  3. Prime-power geometric closed form for sigma_3(p^a).
  4. Multiplicativity of sigma_3 on coprime arguments.
  5. The global Hecke convolution identity.
  6. The congruence sigma_3(n) = sigma_1(n)  (mod 6).
  7. The lower bounds n^3 <= sigma_3(n) and n^3 + 1 <= sigma_3(n) (n >= 2).
  8. The primality characterization sigma_3(n) = n^3 + 1  <=>  n prime.
  9. Two contrarian counterexamples: r_{E8} is not multiplicative, and the
     Hecke recurrence fails for a composite base.
 10. Numerical verification of the flagship open identity E_4^2 = E_8:
         sigma_7(n) = sigma_3(n) + 120 * sum_{m=1}^{n-1} sigma_3(m) sigma_3(n-m).

Run:  python demo.py
"""

from __future__ import annotations

from math import gcd
from typing import List


# --------------------------------------------------------------------------
# Core arithmetic functions
# --------------------------------------------------------------------------

def divisors(n: int) -> List[int]:
    """Return the sorted list of positive divisors of n >= 1."""
    if n < 1:
        raise ValueError("divisors requires n >= 1")
    ds: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            if d != n // d:
                ds.append(n // d)
        d += 1
    return sorted(ds)


def sigma(k: int, n: int) -> int:
    """Divisor power sum sigma_k(n) = sum_{d | n} d^k."""
    return sum(d ** k for d in divisors(n))


def rE8(n: int) -> int:
    """Number of E8 vectors of squared length 2n:  r_{E8}(n) = 240 * sigma_3(n)."""
    return 240 * sigma(3, n)


# --------------------------------------------------------------------------
# 1. Representation numbers of E8
# --------------------------------------------------------------------------

def demo_representation_numbers(limit: int = 10) -> None:
    print("=" * 70)
    print("1. E8 representation numbers  r_{E8}(n) = 240 * sigma_3(n)")
    print("=" * 70)
    print(f"{'n':>3} | {'sigma_3(n)':>12} | {'r_{E8}(n)':>14}")
    print("-" * 40)
    for n in range(1, limit + 1):
        print(f"{n:>3} | {sigma(3, n):>12} | {rE8(n):>14}")
    # The first nonzero shell: 240 vectors of squared length 2 (the E8 roots).
    assert rE8(1) == 240
    assert rE8(2) == 2160
    print("\nCheck: r_{E8}(1) = 240 (the 240 roots), r_{E8}(2) = 2160.  OK")
    print()


# --------------------------------------------------------------------------
# 2. Hecke three-term recurrence at a prime
# --------------------------------------------------------------------------

def demo_hecke_recurrence(p: int = 5, max_r: int = 4) -> None:
    print("=" * 70)
    print(f"2. Hecke three-term recurrence at prime p = {p}")
    print("   sigma_3(p^(r+2)) + p^3 * sigma_3(p^r) = sigma_3(p) * sigma_3(p^(r+1))")
    print("=" * 70)
    for r in range(max_r + 1):
        lhs = sigma(3, p ** (r + 2)) + p ** 3 * sigma(3, p ** r)
        rhs = sigma(3, p) * sigma(3, p ** (r + 1))
        ok = "OK" if lhs == rhs else "FAIL"
        print(f"  r={r}:  {lhs:>14} = {rhs:>14}   [{ok}]")
        assert lhs == rhs
    print()


# --------------------------------------------------------------------------
# 3. Prime-power geometric closed form
# --------------------------------------------------------------------------

def sigma3_prime_power_closed_form(p: int, a: int) -> int:
    """Closed form sigma_3(p^a) = (p^(3(a+1)) - 1) / (p^3 - 1)."""
    return (p ** (3 * (a + 1)) - 1) // (p ** 3 - 1)


def demo_prime_power(p: int = 3, max_a: int = 5) -> None:
    print("=" * 70)
    print(f"3. Prime-power geometric form  sigma_3(p^a) at p = {p}")
    print("   sigma_3(p^a) = (p^(3(a+1)) - 1) / (p^3 - 1)")
    print("=" * 70)
    for a in range(max_a + 1):
        direct = sigma(3, p ** a)
        closed = sigma3_prime_power_closed_form(p, a)
        ok = "OK" if direct == closed else "FAIL"
        print(f"  a={a}:  direct={direct:>14}  closed={closed:>14}  [{ok}]")
        assert direct == closed
    print()


# --------------------------------------------------------------------------
# 4. Multiplicativity of sigma_3
# --------------------------------------------------------------------------

def demo_multiplicativity(limit: int = 12) -> None:
    print("=" * 70)
    print("4. Multiplicativity:  gcd(m,n)=1  =>  sigma_3(mn) = sigma_3(m) sigma_3(n)")
    print("=" * 70)
    count = 0
    for m in range(1, limit + 1):
        for n in range(1, limit + 1):
            if gcd(m, n) == 1:
                assert sigma(3, m * n) == sigma(3, m) * sigma(3, n)
                count += 1
    print(f"  Verified for all coprime pairs (m,n), 1<=m,n<={limit}: "
          f"{count} pairs.  OK")
    print()


# --------------------------------------------------------------------------
# 5. Global Hecke convolution identity
# --------------------------------------------------------------------------

def hecke_rhs(m: int, n: int) -> int:
    """sum_{d | gcd(m,n)} d^3 * sigma_3(m*n / d^2)."""
    g = gcd(m, n)
    return sum(d ** 3 * sigma(3, (m * n) // (d * d)) for d in divisors(g))


def demo_global_hecke(limit: int = 8) -> None:
    print("=" * 70)
    print("5. Global Hecke identity:")
    print("   sigma_3(m) sigma_3(n) = sum_{d | gcd(m,n)} d^3 sigma_3(mn / d^2)")
    print("=" * 70)
    for m in range(1, limit + 1):
        for n in range(1, limit + 1):
            assert sigma(3, m) * sigma(3, n) == hecke_rhs(m, n)
    print(f"  Verified for all pairs (m,n), 1<=m,n<={limit}.  OK")
    # Show the diagonal m = n specialization.
    print("\n  Diagonal m=n:  sigma_3(n)^2 = sum_{d|n} d^3 sigma_3(n^2/d^2)")
    for n in range(1, 8):
        lhs = sigma(3, n) ** 2
        rhs = sum(d ** 3 * sigma(3, (n * n) // (d * d)) for d in divisors(n))
        assert lhs == rhs
        print(f"    n={n}:  {lhs:>12} = {rhs:>12}")
    print()


# --------------------------------------------------------------------------
# 6. Congruence  sigma_3(n) = sigma_1(n)  (mod 6)
# --------------------------------------------------------------------------

def demo_congruence(limit: int = 15) -> None:
    print("=" * 70)
    print("6. Hidden congruence:  sigma_3(n) = sigma_1(n)  (mod 6)")
    print("=" * 70)
    print(f"{'n':>3} | {'sigma_3':>10} | {'sigma_1':>8} | {'diff':>8} | 6 | diff?")
    print("-" * 50)
    for n in range(1, limit + 1):
        s3, s1 = sigma(3, n), sigma(1, n)
        diff = s3 - s1
        assert diff % 6 == 0
        print(f"{n:>3} | {s3:>10} | {s1:>8} | {diff:>8} | {'yes'}")
    print()


# --------------------------------------------------------------------------
# 7 & 8. Lower bounds and primality characterization
# --------------------------------------------------------------------------

def demo_lower_bounds_and_primality(limit: int = 20) -> None:
    print("=" * 70)
    print("7-8. Lower bounds and primality:  sigma_3(n) = n^3 + 1  <=>  n prime")
    print("=" * 70)
    print(f"{'n':>3} | {'sigma_3':>10} | {'n^3+1':>10} | {'equal?':>6} | prime?")
    print("-" * 55)
    for n in range(2, limit + 1):
        s3 = sigma(3, n)
        bound = n ** 3 + 1
        assert n ** 3 <= s3           # n^3 <= sigma_3(n)
        assert bound <= s3            # n^3 + 1 <= sigma_3(n)
        is_prime = all(n % d for d in range(2, int(n ** 0.5) + 1)) and n >= 2
        equal = (s3 == bound)
        assert equal == is_prime      # the characterization
        mark = "PRIME" if is_prime else ""
        print(f"{n:>3} | {s3:>10} | {bound:>10} | {str(equal):>6} | {mark}")
    print()


# --------------------------------------------------------------------------
# 9. Contrarian counterexamples
# --------------------------------------------------------------------------

def demo_counterexamples() -> None:
    print("=" * 70)
    print("9. Contrarian counterexamples")
    print("=" * 70)
    # (a) r_{E8} is not multiplicative.
    lhs = rE8(2 * 3)
    rhs = rE8(2) * rE8(3)
    print("  (a) r_{E8} not multiplicative:")
    print(f"      r_{{E8}}(6)      = {lhs}")
    print(f"      r_{{E8}}(2)*r_{{E8}}(3) = {rhs}")
    assert lhs != rhs
    print(f"      {lhs} != {rhs}  =>  r_{{E8}} is NOT multiplicative.  OK")
    # The correct coprime law carries a factor 240:
    #   240 * sigma_3(mn) = (1/240) * rE8(m) * rE8(n) for coprime m,n.
    assert 240 * sigma(3, 6) == 240 * (sigma(3, 2) * sigma(3, 3))
    print("      (correct law: 240*sigma_3(6) = 240*sigma_3(2)*sigma_3(3).)")

    # (b) Hecke recurrence fails at composite base p = 6, r = 0.
    p, r = 6, 0
    lhs = sigma(3, p ** (r + 2)) + p ** 3 * sigma(3, p ** r)
    rhs = sigma(3, p) * sigma(3, p ** (r + 1))
    print("\n  (b) Hecke recurrence fails at composite base p = 6 (r = 0):")
    print(f"      LHS = sigma_3(36) + 216*sigma_3(1) = {lhs}")
    print(f"      RHS = sigma_3(6) * sigma_3(6)       = {rhs}")
    assert lhs != rhs
    print(f"      {lhs} != {rhs}  =>  recurrence requires p prime.  OK")
    print()


# --------------------------------------------------------------------------
# 10. Flagship open identity  E_4^2 = E_8
# --------------------------------------------------------------------------

def demo_e4_squared(limit: int = 10) -> None:
    print("=" * 70)
    print("10. Flagship open identity  E_4^2 = E_8:")
    print("    sigma_7(n) = sigma_3(n) + 120 * sum_{m=1}^{n-1} sigma_3(m) sigma_3(n-m)")
    print("=" * 70)
    for n in range(1, limit + 1):
        lhs = sigma(7, n)
        conv = sum(sigma(3, m) * sigma(3, n - m) for m in range(1, n))
        rhs = sigma(3, n) + 120 * conv
        ok = "OK" if lhs == rhs else "FAIL"
        print(f"  n={n:>2}:  sigma_7={lhs:>12}  rhs={rhs:>12}   [{ok}]")
        assert lhs == rhs
    print("\n  Identity confirmed numerically (equivalent to dim M_8 = 1).")
    print()


def main() -> None:
    demo_representation_numbers()
    demo_hecke_recurrence()
    demo_prime_power()
    demo_multiplicativity()
    demo_global_hecke()
    demo_congruence()
    demo_lower_bounds_and_primality()
    demo_counterexamples()
    demo_e4_squared()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
