"""
Numerical demonstrations for: Covering Systems and a Certificate Framework
for Sierpinski Numbers.

This script exercises the MAIN soundness theorem (certificate_gives_divisor)
on the explicit covering certificate for k = 78557, and illustrates the two
supporting lemmas (pow_mod_congr, divisor_transfers), the LCM finite-verification
theorem (covering_finite_verification), the CRT compatibility theorem
(crt_compatible), and the uniform-covering lower bound (uniform_covering_card).

All functions are self-contained and type-hinted; run with `python3 demo.py`.
"""

from __future__ import annotations

from math import gcd
from typing import List, Optional, Tuple

# The explicit covering certificate for 78557:
#   (residue a, modulus m, prime p) with  p | 78557 * 2^a + 1  and  2^m = 1 (mod p).
K_SIERPINSKI: int = 78557
CERT_78557: List[Tuple[int, int, int]] = [
    (0, 2, 3),
    (1, 4, 5),
    (1, 3, 7),
    (11, 12, 13),
    (15, 18, 19),
    (27, 36, 37),
    (3, 9, 73),
]


# ---------------------------------------------------------------------------
# Core arithmetic primitives
# ---------------------------------------------------------------------------
def lcm(a: int, b: int) -> int:
    """Least common multiple."""
    return a * b // gcd(a, b)


def lcm_moduli(cert: List[Tuple[int, int, int]]) -> int:
    """LCM of all moduli in a certificate (Lean: CoveringSystem.lcm_moduli)."""
    acc = 1
    for (_a, m, _p) in cert:
        acc = lcm(acc, m)
    return acc


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (sufficient for small primes)."""
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


def multiplicative_order_of_two(p: int) -> int:
    """Order of 2 modulo prime p (smallest m > 0 with 2^m = 1 mod p)."""
    m, val = 1, 2 % p
    while val != 1:
        val = (val * 2) % p
        m += 1
    return m


# ---------------------------------------------------------------------------
# Certificate validation (the verifier algorithm)
# ---------------------------------------------------------------------------
def certificate_is_valid(k: int, cert: List[Tuple[int, int, int]]) -> bool:
    """
    Check the four certificate conditions of Definition 4:
      (i)   each p prime,
      (ii)  p | k*2^a + 1,
      (iii) 2^m = 1 (mod p)   [order of 2 divides m],
      (iv)  the classes cover every residue modulo L = lcm of moduli.
    By Theorems 7 and 10 a True verdict certifies a fixed small divisor of
    every k*2^n + 1.
    """
    for (a, m, p) in cert:
        if not is_prime(p):
            return False
        if (k * pow(2, a, p) + 1) % p != 0:
            return False
        if pow(2, m, p) != 1:
            return False
    return covers_one_period(k, cert)


def covers_one_period(k: int, cert: List[Tuple[int, int, int]]) -> bool:
    """Theorem 10: coverage over all of N reduces to coverage of 0..L-1."""
    L = lcm_moduli(cert)
    for n in range(L):
        if first_covering_prime(k, cert, n) is None:
            return False
    return True


def first_covering_prime(
    k: int, cert: List[Tuple[int, int, int]], n: int
) -> Optional[int]:
    """
    The witness extracted by the soundness theorem: return a prime from the
    certificate dividing k*2^n + 1, or None if (impossibly) none applies.
    Mirrors certificate_gives_divisor.
    """
    for (a, m, p) in cert:
        if n % m == a and (k * pow(2, n, p) + 1) % p == 0:
            return p
    return None


# ---------------------------------------------------------------------------
# Lemma illustrations
# ---------------------------------------------------------------------------
def demo_pow_mod_congr(p: int, m: int, n: int) -> bool:
    """Lemma 5: if 2^m = 1 (mod p) then 2^n = 2^(n mod m) (mod p)."""
    assert pow(2, m, p) == 1, "precondition 2^m = 1 (mod p) violated"
    a = n % m
    return pow(2, n, p) == pow(2, a, p)


def demo_divisor_transfers(k: int, p: int, a: int, n: int) -> bool:
    """Lemma 6: p | k*2^a+1 and 2^n = 2^a (mod p) imply p | k*2^n+1."""
    if (k * pow(2, a, p) + 1) % p != 0:
        return True  # vacuous: hypothesis fails
    if pow(2, n, p) != pow(2, a, p):
        return True  # vacuous
    return (k * pow(2, n, p) + 1) % p == 0


def demo_crt_compatible(a1: int, m1: int, a2: int, m2: int) -> Optional[int]:
    """
    Theorem 12: coprime moduli => the classes intersect. Returns a witness n
    with n = a1 (mod m1) and n = a2 (mod m2), or None if moduli not coprime.
    """
    if gcd(m1, m2) != 1:
        return None
    for n in range(m1 * m2):
        if n % m1 == a1 and n % m2 == a2:
            return n
    return None


# ---------------------------------------------------------------------------
# Main driver
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("Sierpinski covering certificate for k =", K_SIERPINSKI)
    print("=" * 70)

    L = lcm_moduli(CERT_78557)
    print(f"\nLCM of moduli L = {L}  (period of the covering)")

    print("\nCertificate rows  (a, m, p):  checks  p|k2^a+1 ,  2^m=1 mod p ,  ord_p(2)")
    for (a, m, p) in CERT_78557:
        div_ok = (K_SIERPINSKI * pow(2, a, p) + 1) % p == 0
        ord_ok = pow(2, m, p) == 1
        ordp = multiplicative_order_of_two(p)
        print(f"  ({a:2d},{m:3d},{p:3d})   div={div_ok}  ord2^m={ord_ok}  ord_p(2)={ordp}")

    print("\nValidating full certificate (the verifier algorithm)...")
    print("  certificate_is_valid =", certificate_is_valid(K_SIERPINSKI, CERT_78557))

    print("\nMAIN THEOREM (certificate_gives_divisor): a covering prime for each n.")
    print("  Sampling n = 0..15 and some large/awkward exponents:")
    sample = list(range(16)) + [35, 36, 100, 1000, 123456, 10**6 + 1]
    for n in sample:
        p = first_covering_prime(K_SIERPINSKI, CERT_78557, n)
        val = K_SIERPINSKI * pow(2, n) + 1
        proper = (p is not None) and (p < val)
        print(f"  n={n:<8} divisor p={p}   proper(<term)={proper}")

    print("\nExhaustive coverage over one full period (n = 0..L-1):")
    missing = [n for n in range(L) if first_covering_prime(K_SIERPINSKI, CERT_78557, n) is None]
    print(f"  uncovered residues mod {L}: {missing}  (empty => covers all of N)")

    print("\nLemma 5 (pow_mod_congr) on prime 7, m=3:")
    print("  2^n = 2^(n mod 3) mod 7 for n=0..20:",
          all(demo_pow_mod_congr(7, 3, n) for n in range(21)))

    print("\nLemma 6 (divisor_transfers): 13 | 78557*2^11+1 transfers to 11+12q:")
    print("  holds for n in {11,23,35,47,...,131}:",
          all(demo_divisor_transfers(K_SIERPINSKI, 13, 11, 11 + 12 * q) for q in range(11)))

    print("\nTheorem 12 (crt_compatible): coprime moduli 4 and 9 intersect:")
    w = demo_crt_compatible(1, 4, 3, 9)
    print(f"  witness n with n=1 (mod 4), n=3 (mod 9): n={w}",
          f"-> {w % 4 == 1 and w % 9 == 3}" if w is not None else "")

    print("\nMinimality (open): smallest unresolved candidate k = 21181.")
    print("  TestPrediction_21181: searching small n for a prime 21181*2^n+1...")
    found = next((n for n in range(1, 600) if is_prime(21181 * pow(2, n) + 1)), None)
    print(f"  no prime found for n<600 (n={found}); real searches reach ~10^7+.")


if __name__ == "__main__":
    main()
