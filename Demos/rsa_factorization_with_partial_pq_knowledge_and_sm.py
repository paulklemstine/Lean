"""
Modified Wiener Attack on RSA with Partial Knowledge of p + q.

This self-contained script demonstrates the complete chain formalized in the
companion Lean development:

    arithmetic engine  ->  convergent criterion  ->  unique recovery of d
                       ->  totient recovery       ->  closed-form factorization.

Every function is inlined and type-hinted. Running the module executes a series
of numerical demonstrations that mirror the formal theorems, including the
worked example (p = 17, q = 11, n = 187).

The mathematics
---------------
For an RSA modulus n = p*q (p > q) with public/private exponents e, d obeying
the key equation  e*d = k*phi(n) + 1,  with phi(n) = (p-1)(q-1):

  * Corrected modulus:        n_tilde = n + 1 - s,  where s estimates p+q.
  * Exact approximation:      e/n_tilde - k/d = (1 - k*((p+q) - s)) / (n_tilde*d).
  * Convergent criterion:     if 2*d*(k*Delta + 1) < n_tilde  (Delta >= |p+q - s|),
                              then |e/n_tilde - k/d| < 1/(2*d^2)  (Legendre threshold),
                              so k/d is a continued-fraction convergent of e/n_tilde.
  * Recovery (Farey):         the convergent with denominator <= d is unique, and
                              under gcd(k,d)=1 its denominator equals d exactly.
  * Factorization:            phi(n) = (e*d - 1)/k,  S = n - phi(n) + 1 = p + q,
                              discriminant S^2 - 4n = (p - q)^2 is a PERFECT SQUARE,
                              so  p, q = (S +/- sqrt(S^2 - 4n)) / 2  exactly.
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, isqrt
from typing import List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Core arithmetic engine (mirrors WienerPartialKnowledge.lean)
# --------------------------------------------------------------------------- #

def phi_semiprime(p: int, q: int) -> int:
    """Euler totient of the semiprime n = p*q, as (p-1)*(q-1)."""
    return (p - 1) * (q - 1)


def corrected_modulus(p: int, q: int, s: int) -> int:
    """Corrected modulus n_tilde = n + 1 - s with s an estimate of p + q."""
    return p * q + 1 - s


def approx_error(p: int, q: int, e: int, d: int, k: int, s: int) -> Fraction:
    """Exact rational approximation error e/n_tilde - k/d."""
    n_tilde = corrected_modulus(p, q, s)
    return Fraction(e, n_tilde) - Fraction(k, d)


def legendre_threshold(d: int) -> Fraction:
    """The Legendre convergent threshold 1/(2*d^2)."""
    return Fraction(1, 2 * d * d)


def smallness_condition(d: int, k: int, delta: int, n_tilde: int) -> bool:
    """Partial-knowledge smallness condition 2*d*(k*Delta + 1) < n_tilde."""
    return 2 * d * (k * delta + 1) < n_tilde


# --------------------------------------------------------------------------- #
# Continued fractions and convergents
# --------------------------------------------------------------------------- #

def continued_fraction(num: int, den: int) -> List[int]:
    """Continued-fraction expansion [a0; a1, a2, ...] of num/den."""
    coeffs: List[int] = []
    while den != 0:
        a = num // den
        coeffs.append(a)
        num, den = den, num - a * den
    return coeffs


def convergents(coeffs: List[int]) -> List[Tuple[int, int]]:
    """All convergents (h_i, k_i) of a continued fraction."""
    result: List[Tuple[int, int]] = []
    h_prev, h_cur = 1, coeffs[0] if coeffs else 0
    k_prev, k_cur = 0, 1
    result.append((h_cur, k_cur))
    for a in coeffs[1:]:
        h_prev, h_cur = h_cur, a * h_cur + h_prev
        k_prev, k_cur = k_cur, a * k_cur + k_prev
        result.append((h_cur, k_cur))
    return result


# --------------------------------------------------------------------------- #
# Factorization (mirrors WienerFactorization.lean)
# --------------------------------------------------------------------------- #

def discriminant(p_plus_q: int, n: int) -> int:
    """Discriminant (p+q)^2 - 4n; equals (p-q)^2, a perfect square."""
    return p_plus_q * p_plus_q - 4 * n


def factor_from_sum_product(s_sum: int, n: int) -> Optional[Tuple[int, int]]:
    """Recover (p, q) from S = p+q and N = n = p*q via the quadratic formula.

    Returns None if the discriminant is not a perfect square (invalid candidate).
    """
    disc = discriminant(s_sum, n)
    if disc < 0:
        return None
    root = isqrt(disc)
    if root * root != disc:
        return None
    p = (s_sum + root) // 2
    q = (s_sum - root) // 2
    if p * q != n or p <= q:
        return None
    return p, q


def wiener_factor(n: int, e: int, s: int, delta: int) -> Optional[Tuple[int, int]]:
    """Full modified-Wiener attack.

    Given the public key (n, e), an estimate s of p+q, and a residual bound
    delta with |p+q - s| <= delta, attempt to factor n by testing the
    continued-fraction convergents of e/n_tilde.
    """
    n_tilde = corrected_modulus_from_n(n, s)
    for (k_cand, d_cand) in convergents(continued_fraction(e, n_tilde)):
        if k_cand <= 0 or d_cand <= 0:
            continue
        if (e * d_cand - 1) % k_cand != 0:
            continue
        phi = (e * d_cand - 1) // k_cand
        s_sum = n - phi + 1
        factors = factor_from_sum_product(s_sum, n)
        if factors is not None:
            return factors
    return None


def corrected_modulus_from_n(n: int, s: int) -> int:
    """Corrected modulus n_tilde = n + 1 - s, expressed directly from n."""
    return n + 1 - s


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_worked_example() -> None:
    """Worked example p=17, q=11, n=187 — mirrors the formal worked_example_*."""
    p, q = 17, 11
    n, e, d, k = p * q, 7, 23, 1
    s = p + q  # perfect estimate
    print("=== Worked example (p=17, q=11, n=187) ===")
    print(f"n = {n}, phi(n) = {phi_semiprime(p, q)}, e = {e}, d = {d}, k = {k}")
    n_tilde = corrected_modulus(p, q, s)
    err = approx_error(p, q, e, d, k, s)
    thr = legendre_threshold(d)
    print(f"corrected modulus n_tilde = {n_tilde}")
    print(f"e/n_tilde - k/d = {err}  (= 1/3680)")
    print(f"Legendre threshold 1/(2d^2) = {thr}  (= 1/1058)")
    print(f"below threshold? {err < thr}")
    disc = discriminant(s, n)
    print(f"discriminant {s}^2 - 4*{n} = {disc} = {isqrt(disc)}^2 (perfect square)")
    print(f"recovered factors: {factor_from_sum_product(s, n)}")
    print()


def demo_full_attack() -> None:
    """Run the full attack on several moduli with a perfect estimate s = p+q."""
    print("=== Full attack (perfect estimate s = p+q) ===")
    cases: List[Tuple[int, int, int]] = [
        (17, 11, 7),
        (61, 53, 17),
        (101, 89, 53),
        (1009, 997, 65537),
    ]
    for p, q, e in cases:
        n = p * q
        phi = phi_semiprime(p, q)
        if gcd(e, phi) != 1:
            continue
        d = pow(e, -1, phi)
        s = p + q
        result = wiener_factor(n, e, s, delta=0)
        print(f"p={p:5d} q={q:5d} n={n:8d} e={e:6d} d={d:8d} -> factors {result}")
    print()


def demo_smallness_tradeoff() -> None:
    """Show how more known bits of p+q (smaller Delta) admit a larger d."""
    print("=== Smallness condition: Delta vs largest admissible d ===")
    p, q = 1009, 997
    n = p * q
    n_tilde = n + 1 - (p + q)  # = phi(n), perfect estimate baseline
    k = 1
    print(f"n = {n}, n_tilde (perfect) = {n_tilde}")
    for delta in [0, 1, 10, 100, 1000]:
        # largest d with 2*d*(k*delta+1) < n_tilde
        max_d = (n_tilde - 1) // (2 * (k * delta + 1))
        ok = smallness_condition(max_d, k, delta, n_tilde)
        print(f"Delta = {delta:5d}  ->  largest admissible d ~ {max_d:6d}  "
              f"(condition holds: {ok})")
    print()


def demo_farey_separation() -> None:
    """Illustrate the Farey separation bound, attained with equality."""
    print("=== Farey separation |1/23 - 7/160| = 1/(23*160) ===")
    a, b, c, e = 1, 23, 7, 160
    sep = abs(Fraction(a, b) - Fraction(c, e))
    bound = Fraction(1, b * e)
    print(f"|1/23 - 7/160| = {sep}")
    print(f"1/(23*160)     = {bound}")
    print(f"equality attained? {sep == bound}")
    print()


def main() -> None:
    demo_worked_example()
    demo_full_attack()
    demo_smallness_tradeoff()
    demo_farey_separation()


if __name__ == "__main__":
    main()
