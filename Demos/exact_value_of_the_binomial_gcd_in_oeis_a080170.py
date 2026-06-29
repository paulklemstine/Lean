"""Numerical demonstrations for OEIS A080170: the binomial GCD D(k).

This script demonstrates, with concrete numbers:

  * the definition  D(k) = gcd_{2 <= q <= k+1} C(q*k, k),
  * the disproof of Stephan's exact-value conjecture (first failure k = 11),
  * the prime-fibre exactness  v_p(D(p-1)) = 1  (so D(p-1) = p),
  * Kummer's carry theorem as the mechanism behind everything, and
  * the corrected carry-minimum closed form (matches D(k) for 2 <= k <= 201).

It is fully self-contained: every helper is inlined and type-hinted, and it
depends only on the Python standard library.
"""

from __future__ import annotations

from functools import reduce
from math import comb, gcd
from typing import Dict, List


# --------------------------------------------------------------------------- #
# Core definitions
# --------------------------------------------------------------------------- #
def binom_gcd(k: int) -> int:
    """D(k) = gcd over 2 <= q <= k+1 of C(q*k, k)  (OEIS A080170)."""
    if k < 2:
        raise ValueError("A080170 is indexed from k >= 2")
    return reduce(gcd, (comb(q * k, k) for q in range(2, k + 2)))


def factorize(n: int) -> Dict[int, int]:
    """Return the prime factorization of n >= 1 as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def stephan_P(n: int) -> int:
    """P(n) = max_{p | n} p^{v_p(n)}, the dominant prime power of n."""
    factors = factorize(n)
    return max((p ** a for p, a in factors.items()), default=1)


# --------------------------------------------------------------------------- #
# Kummer's theorem: valuation by carry counting
# --------------------------------------------------------------------------- #
def base_p_carries(a: int, b: int, p: int) -> int:
    """Number of carries when adding a and b in base p (Kummer's theorem)."""
    carries = 0
    carry = 0
    while a > 0 or b > 0 or carry > 0:
        s = (a % p) + (b % p) + carry
        carry = 1 if s >= p else 0
        carries += carry
        a //= p
        b //= p
    return carries


def kummer_valuation(k: int, q: int, p: int) -> int:
    """v_p( C(q*k, k) ) = carries adding k and (q-1)*k in base p."""
    return base_p_carries(k, (q - 1) * k, p)


def ilog(p: int, m: int) -> int:
    """Floor of log base p of m (with ilog(p, 0) = 0)."""
    if m < 1:
        return 0
    e = 0
    while p ** (e + 1) <= m:
        e += 1
    return e


def corrected_formula(k: int) -> int:
    """Corrected carry-minimum closed form (Conjecture C1)."""
    n = k + 1
    best = 1
    for p, a in factorize(n).items():
        m = n // (p ** a)
        exponent = max(0, a - ilog(p, m))
        best = max(best, p ** exponent)
    return best


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_first_values() -> None:
    print("=" * 64)
    print("D(k) for k = 2..20  (OEIS A080170)")
    print("=" * 64)
    for k in range(2, 21):
        print(f"  D({k:2d}) = {binom_gcd(k):3d}   P({k + 1}) = {stephan_P(k + 1)}")


def demo_disproof() -> None:
    print("\n" + "=" * 64)
    print("Disproof of Stephan's exact-value conjecture at k = 11")
    print("=" * 64)
    k = 11
    d = binom_gcd(k)
    P = stephan_P(k + 1)
    c = comb(5 * k, k)
    print(f"  k = {k},  n = k+1 = {k + 1} = 2^2 * 3")
    print(f"  Stephan predicts D(11) = P(12) = {P}")
    print(f"  Actual            D(11)         = {d}")
    print(f"  The gcd divides the q=5 term  C(55,11) = {c}")
    print(f"  C(55,11) mod 4 = {c % 4}  ->  4 does NOT divide C(55,11)")
    print(f"  Hence D(11) != 4.  Conjecture FALSE.  (predicted {P}, actual {d})")


def demo_prime_fibre() -> None:
    print("\n" + "=" * 64)
    print("Prime fibre is exact:  v_p(D(p-1)) = 1,  so D(p-1) = p")
    print("=" * 64)
    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        d = binom_gcd(p - 1)
        central = comb(2 * (p - 1), p - 1)
        v_central = kummer_valuation(p - 1, 2, p)
        print(
            f"  p={p:2d}: D(p-1)={d:3d}  central C({2*(p-1)},{p-1}) has "
            f"v_{p}={v_central}  (>=1 every term, =1 at q=2)"
        )


def demo_kummer() -> None:
    print("\n" + "=" * 64)
    print("Kummer carries explain the k=11 failure (prime p=2)")
    print("=" * 64)
    k = 11
    print(f"  q : v_2(C(11q,11)) by carry count")
    vmin = min(kummer_valuation(k, q, 2) for q in range(2, k + 2))
    for q in range(2, k + 2):
        v = kummer_valuation(k, q, 2)
        mark = "  <- minimum" if v == vmin else ""
        print(f"  {q:2d} : {v}{mark}")
    print(f"  min over q = {vmin}  ->  v_2(D(11)) = {vmin}, so 2-part is 2^{vmin}")


def demo_corrected_formula(limit: int = 201) -> None:
    print("\n" + "=" * 64)
    print(f"Corrected carry-minimum formula matches D(k) for 2..{limit}")
    print("=" * 64)
    mismatches: List[int] = [
        k for k in range(2, limit + 1) if corrected_formula(k) != binom_gcd(k)
    ]
    stephan_fails: List[int] = [
        k for k in range(2, 80) if stephan_P(k + 1) != binom_gcd(k)
    ]
    print(f"  corrected-formula mismatches in [2,{limit}]: {mismatches or 'NONE'}")
    print(f"  Stephan exact-value failures in [2,80):     {stephan_fails}")


if __name__ == "__main__":
    demo_first_values()
    demo_disproof()
    demo_prime_fibre()
    demo_kummer()
    demo_corrected_formula()
