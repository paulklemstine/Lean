"""
Numerical demonstrations for the Siegel-Weil identity of the E8 theta series.

Central identity (rank-8 Siegel-Weil):

    r(n) = 240 * sigma_3(n),     sigma_s(n) = sum_{d | n} d^s,

where r(n) is the number of E8 vectors of squared length 2n.

This script verifies, for the general divisor-power sum sigma_s and its E8
specialization s = 3, the three structural fingerprints:

  1. Division-free closed form:   sigma_s(p^r) * (p^s - 1) = p^(s(r+1)) - 1
  2. Moebius inversion:           n^s = sum_{d*e=n} mu(d) * sigma_s(e)
  3. Eigenform / Hecke defect:    sigma_s(p^2) + p^s = sigma_s(p)^2

All functions are self-contained with type hints.
"""

from __future__ import annotations

from typing import List, Tuple


# ---------------------------------------------------------------------------
# Elementary number-theoretic helpers
# ---------------------------------------------------------------------------

def divisors(n: int) -> List[int]:
    """Return the sorted list of positive divisors of n."""
    if n <= 0:
        raise ValueError("n must be positive")
    ds: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            if d != n // d:
                ds.append(n // d)
        d += 1
    return sorted(ds)


def sigma(s: int, n: int) -> int:
    """Divisor-power sum sigma_s(n) = sum_{d | n} d^s."""
    return sum(d ** s for d in divisors(n))


def is_prime(p: int) -> bool:
    """Simple primality test."""
    if p < 2:
        return False
    i = 2
    while i * i <= p:
        if p % i == 0:
            return False
        i += 1
    return True


def moebius(n: int) -> int:
    """Moebius function mu(n)."""
    if n == 1:
        return 1
    result = 1
    m = n
    p = 2
    while p * p <= m:
        if m % p == 0:
            m //= p
            if m % p == 0:
                return 0  # squared prime factor
            result = -result
        p += 1
    if m > 1:
        result = -result
    return result


def rE8(n: int) -> int:
    """Siegel-Weil / E4 prediction for E8 vector counts: 240 * sigma_3(n)."""
    return 240 * sigma(3, n)


# ---------------------------------------------------------------------------
# Demonstration 1: the Siegel-Weil identity against known shell counts
# ---------------------------------------------------------------------------

def demo_siegel_weil() -> None:
    known = {1: 240, 2: 2160, 3: 6720, 4: 17520, 5: 30240}
    print("== Siegel-Weil identity: r(n) = 240 * sigma_3(n) ==")
    for n, expected in known.items():
        got = rE8(n)
        status = "OK" if got == expected else "MISMATCH"
        print(f"  n={n}: sigma_3={sigma(3, n):>4}  r(n)={got:>6}  known={expected:>6}  [{status}]")
    print()


# ---------------------------------------------------------------------------
# Demonstration 2: division-free Euler-factor closed form
# ---------------------------------------------------------------------------

def demo_closed_form(s: int = 3, primes: Tuple[int, ...] = (2, 3, 5, 7),
                     rmax: int = 4) -> None:
    print("== Division-free closed form: sigma_s(p^r)*(p^s-1) = p^(s(r+1))-1 ==")
    for p in primes:
        for r in range(rmax + 1):
            lhs = sigma(s, p ** r) * (p ** s - 1)
            rhs = p ** (s * (r + 1)) - 1
            assert lhs == rhs, (p, r)
        print(f"  p={p}: verified for r=0..{rmax}  (s={s})")
    print()


# ---------------------------------------------------------------------------
# Demonstration 3: Moebius inversion recovering pure powers
# ---------------------------------------------------------------------------

def demo_moebius(s: int = 3, nmax: int = 12) -> None:
    print("== Moebius inversion: sum_{d*e=n} mu(d)*sigma_s(e) = n^s ==")
    for n in range(1, nmax + 1):
        total = sum(moebius(d) * sigma(s, n // d) for d in divisors(n))
        assert total == n ** s, (n, total)
        # E8 transport: sum mu(d) r(e) = 240 n^3  (when s == 3)
        if s == 3:
            e8 = sum(moebius(d) * rE8(n // d) for d in divisors(n))
            assert e8 == 240 * n ** 3, (n, e8)
        print(f"  n={n:>2}: sum = {total:>6} = {n}^{s}")
    print()


# ---------------------------------------------------------------------------
# Demonstration 4: eigenform / Hecke defect
# ---------------------------------------------------------------------------

def demo_eigenform_defect(s: int = 3, primes: Tuple[int, ...] = (2, 3, 5, 7, 11)) -> None:
    print("== Eigenform defect: sigma_s(p)^2 - sigma_s(p^2) = p^s  (> 0) ==")
    for p in primes:
        defect = sigma(s, p) ** 2 - sigma(s, p ** 2)
        assert defect == p ** s
        assert sigma(s, p ** 2) < sigma(s, p) ** 2
        print(f"  p={p:>2}: sigma_{s}(p)^2={sigma(s, p)**2:>7}  "
              f"sigma_{s}(p^2)={sigma(s, p**2):>7}  defect={defect:>6} = {p}^{s}")
    print()


def main() -> None:
    demo_siegel_weil()
    demo_closed_form()
    demo_moebius()
    demo_eigenform_defect()
    print("All structural identities verified.")


if __name__ == "__main__":
    main()
