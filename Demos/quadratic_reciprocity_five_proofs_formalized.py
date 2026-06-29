"""
Numerical demonstrations of the Law of Quadratic Reciprocity.

This script exercises the two main theorems:

  * Theorem 1 (Eisenstein, geometric):
        (q/p)(p/q) = (-1)^( floor(p/2) * floor(q/2) )
    obtained from the lattice-point expansion
        (q/p) = (-1)^( sum_{x=1}^{(p-1)/2} floor(x*q/p) )
    and the rectangle identity
        S_{q,p} + S_{p,q} = (p-1)/2 * (q-1)/2.

  * Theorem 2 (Gauss sum, algebraic):
        the quadratic Gauss sum g = sum_x (x/p) * zeta^x satisfies
        g^2 = (-1)^((p-1)/2) * p,
    a square root of +/- p, from which the same reciprocity sign follows.

It also checks the two supplementary laws for (-1/p) and (2/p).

All functions are self-contained and type-hinted; no external dependencies
beyond the Python standard library (cmath/math).
"""

from __future__ import annotations

import cmath
import math
from typing import List, Tuple


# --------------------------------------------------------------------------
# Ground-truth oracle: Legendre symbol via Euler's criterion.
# --------------------------------------------------------------------------
def legendre_symbol(a: int, p: int) -> int:
    """Return the Legendre symbol (a/p) in {-1, 0, 1} via Euler's criterion.

    Uses (a/p) = a^((p-1)/2) mod p, normalized so that p-1 maps to -1.
    """
    a_mod: int = a % p
    if a_mod == 0:
        return 0
    result: int = pow(a_mod, (p - 1) // 2, p)
    return -1 if result == p - 1 else result


def is_odd_prime(n: int) -> bool:
    """Trial-division primality test; True iff n is an odd prime."""
    if n < 3 or n % 2 == 0:
        return False
    for d in range(3, int(math.isqrt(n)) + 1, 2):
        if n % d == 0:
            return False
    return True


# --------------------------------------------------------------------------
# Theorem 1 (Eisenstein): lattice-point counting.
# --------------------------------------------------------------------------
def eisenstein_floor_sum(q: int, p: int) -> int:
    """Compute S_{q,p} = sum_{x=1}^{(p-1)/2} floor(x*q/p)."""
    half: int = (p - 1) // 2
    return sum((x * q) // p for x in range(1, half + 1))


def legendre_via_eisenstein(q: int, p: int) -> int:
    """Compute (q/p) as (-1)^(S_{q,p}), the Eisenstein lattice-point expansion."""
    return -1 if eisenstein_floor_sum(q, p) % 2 == 1 else 1


def reciprocity_sign_eisenstein(p: int, q: int) -> Tuple[int, int, int]:
    """Return (lhs, rhs, S_qp + S_pq) for Eisenstein's proof.

    lhs = (q/p)*(p/q) computed via the floor-sum expansion;
    rhs = (-1)^( floor(p/2)*floor(q/2) ) the reciprocity sign;
    third entry is the combined exponent, which must equal
    floor(p/2)*floor(q/2) by the rectangle identity.
    """
    lhs: int = legendre_via_eisenstein(q, p) * legendre_via_eisenstein(p, q)
    exponent: int = (p // 2) * (q // 2)
    rhs: int = -1 if exponent % 2 == 1 else 1
    combined: int = eisenstein_floor_sum(q, p) + eisenstein_floor_sum(p, q)
    return lhs, rhs, combined


# --------------------------------------------------------------------------
# Theorem 2 (Gauss sum): g^2 = (-1)^((p-1)/2) * p.
# --------------------------------------------------------------------------
def quadratic_gauss_sum(p: int) -> complex:
    """Compute the quadratic Gauss sum g = sum_{x=0}^{p-1} (x/p) * zeta^x.

    Here zeta = exp(2*pi*i/p) is a primitive p-th root of unity.
    """
    total: complex = 0 + 0j
    for x in range(p):
        total += legendre_symbol(x, p) * cmath.exp(2j * cmath.pi * x / p)
    return total


def gauss_sum_square_check(p: int) -> Tuple[complex, complex]:
    """Return (g^2, predicted) where predicted = (-1)^((p-1)/2) * p."""
    g: complex = quadratic_gauss_sum(p)
    sign: int = -1 if ((p - 1) // 2) % 2 == 1 else 1
    return g * g, complex(sign * p, 0.0)


# --------------------------------------------------------------------------
# Supplementary laws.
# --------------------------------------------------------------------------
def supplementary_minus_one(p: int) -> Tuple[int, int]:
    """Return ((-1/p) via Euler, predicted by p mod 4)."""
    actual: int = legendre_symbol(-1, p)
    predicted: int = 1 if p % 4 == 1 else -1
    return actual, predicted


def supplementary_two(p: int) -> Tuple[int, int]:
    """Return ((2/p) via Euler, predicted by p mod 8)."""
    actual: int = legendre_symbol(2, p)
    predicted: int = 1 if p % 8 in (1, 7) else -1
    return actual, predicted


# --------------------------------------------------------------------------
# Driver.
# --------------------------------------------------------------------------
def odd_prime_pairs(limit: int) -> List[Tuple[int, int]]:
    """All ordered pairs (p, q) of distinct odd primes below `limit`."""
    primes: List[int] = [n for n in range(3, limit) if is_odd_prime(n)]
    return [(p, q) for p in primes for q in primes if p != q]


def main() -> None:
    print("=" * 72)
    print("THEOREM 1 (Eisenstein): reciprocity via lattice-point counting")
    print("=" * 72)
    print(f"{'p':>4} {'q':>4} | {'(q/p)(p/q)':>11} {'(-1)^e':>8} "
          f"{'S_qp+S_pq':>10} {'(p-1)/2*(q-1)/2':>16}  ok")
    failures: int = 0
    for p, q in odd_prime_pairs(20):
        lhs, rhs, combined = reciprocity_sign_eisenstein(p, q)
        rect: int = ((p - 1) // 2) * ((q - 1) // 2)
        ok: bool = (lhs == rhs) and (combined == rect)
        failures += 0 if ok else 1
        print(f"{p:>4} {q:>4} | {lhs:>11} {rhs:>8} {combined:>10} "
              f"{rect:>16}  {'YES' if ok else 'NO'}")
    print(f"\nEisenstein failures: {failures}\n")

    print("=" * 72)
    print("THEOREM 2 (Gauss sum): g^2 = (-1)^((p-1)/2) * p")
    print("=" * 72)
    print(f"{'p':>4} | {'g^2 (numeric)':>28} {'predicted':>14}  ok")
    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        g2, predicted = gauss_sum_square_check(p)
        ok = abs(g2 - predicted) < 1e-6
        print(f"{p:>4} | {f'{g2.real:+.4f}{g2.imag:+.4f}i':>28} "
              f"{f'{predicted.real:+.1f}':>14}  {'YES' if ok else 'NO'}")
    print()

    print("=" * 72)
    print("SUPPLEMENTARY LAWS")
    print("=" * 72)
    print(f"{'p':>4} | {'(-1/p)':>7} {'p%4':>4} | {'(2/p)':>6} {'p%8':>4}  ok")
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        m1_actual, m1_pred = supplementary_minus_one(p)
        t_actual, t_pred = supplementary_two(p)
        ok = (m1_actual == m1_pred) and (t_actual == t_pred)
        print(f"{p:>4} | {m1_actual:>7} {p % 4:>4} | {t_actual:>6} {p % 8:>4}  "
              f"{'YES' if ok else 'NO'}")

    print("\nA worked example from the article: p = 7, q = 5")
    print(f"  (5/7) = {legendre_symbol(5, 7)}, (7/5) = {legendre_symbol(7, 5)}, "
          f"product = {legendre_symbol(5, 7) * legendre_symbol(7, 5)}")
    print(f"  predicted (-1)^(3*2) = {(-1) ** (3 * 2)}  (both primes: 5 = 1 mod 4)")
    print("Another: p = 7, q = 3 (both 3 mod 4)")
    print(f"  (3/7) = {legendre_symbol(3, 7)}, (7/3) = {legendre_symbol(7, 3)}, "
          f"product = {legendre_symbol(3, 7) * legendre_symbol(7, 3)}")
    print(f"  predicted (-1)^(3*1) = {(-1) ** (3 * 1)}")


if __name__ == "__main__":
    main()
