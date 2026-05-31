"""
Langlands Correspondence for GL₂ over ℚ: Algorithms

Type-hinted implementations of key algorithms from the Langlands program,
including Hecke operator computation, L-function evaluation, and
Sato-Tate distribution testing.
"""

from typing import List, Tuple, Dict, Optional, Callable
import math


def is_prime(n: int) -> bool:
    """Miller-Rabin primality test for small numbers."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def hecke_eigenvalue_recursion(
    a_p: float, weight: int, p: int, max_power: int
) -> List[float]:
    """
    Compute Hecke eigenvalues a(p^r) for r = 0, 1, ..., max_power
    using the recursion:
        a(p^0) = 1
        a(p^1) = a_p
        a(p^(r+1)) = a_p * a(p^r) - p^(k-1) * a(p^(r-1))

    Args:
        a_p: The Hecke eigenvalue at prime p
        weight: The modular form weight k
        p: The prime
        max_power: Maximum power to compute

    Returns:
        List of a(p^r) for r = 0, ..., max_power
    """
    if max_power < 0:
        return []

    coeffs = [1.0]  # a(p^0) = 1
    if max_power == 0:
        return coeffs

    coeffs.append(a_p)  # a(p^1) = a_p
    pk = float(p ** (weight - 1))

    for r in range(1, max_power):
        # a(p^(r+1)) = a_p * a(p^r) - p^(k-1) * a(p^(r-1))
        next_val = a_p * coeffs[r] - pk * coeffs[r - 1]
        coeffs.append(next_val)

    return coeffs


def frobenius_characteristic_polynomial(
    a_p: float, weight: int, p: int
) -> Tuple[float, float, float]:
    """
    Returns coefficients (1, -a_p, p^(k-1)) of the Frobenius
    characteristic polynomial X² - a_p·X + p^(k-1).
    """
    return (1.0, -a_p, float(p ** (weight - 1)))


def frobenius_discriminant(a_p: float, weight: int, p: int) -> float:
    """
    Compute the discriminant Δ = a_p² - 4·p^(k-1).
    Δ ≤ 0 iff the Ramanujan-Petersson bound holds at p.
    """
    return a_p ** 2 - 4.0 * p ** (weight - 1)


def ramanujan_bound(weight: int, p: int) -> float:
    """
    The Ramanujan-Petersson bound: 2·p^((k-1)/2).
    """
    return 2.0 * p ** ((weight - 1) / 2.0)


def partial_l_function(
    coeffs: Callable[[int], float], s: float, N: int
) -> float:
    """
    Compute the partial L-function sum:
        L(f, s) ≈ Σ_{n=1}^{N} a(n) / n^s

    Args:
        coeffs: Function n -> a(n) giving Fourier coefficients
        s: The complex variable (real part)
        N: Truncation bound

    Returns:
        Partial sum approximation to L(f, s)
    """
    total = 0.0
    for n in range(1, N + 1):
        total += coeffs(n) / n**s
    return total


def euler_product_factor(a_p: float, weight: int, p: int, s: float) -> float:
    """
    Local Euler factor at prime p:
        (1 - a_p · p^{-s} + p^{k-1-2s})^{-1}
    """
    denom = 1.0 - a_p * p**(-s) + p**(weight - 1) * p**(-2 * s)
    if abs(denom) < 1e-15:
        return float('inf')
    return 1.0 / denom


def sato_tate_second_moment(
    eigenvalues: Dict[int, float], weight: int, X: int
) -> float:
    """
    Compute the Sato-Tate second moment prediction:
        (1/π(X)) · Σ_{p≤X} a_p² / p^(k-1)

    Should converge to 1 for non-CM forms (Sato-Tate conjecture).
    """
    ps = [p for p in primes_up_to(X) if p in eigenvalues]
    if not ps:
        return 0.0
    total = sum(eigenvalues[p]**2 / p**(weight - 1) for p in ps)
    return total / len(ps)


def point_count(a_p: float, p: int) -> int:
    """
    For a weight-2 eigenform / elliptic curve:
        #E(F_p) = p + 1 - a_p
    """
    return round(p + 1 - a_p)


def analytic_conductor(weight: int, level: int) -> float:
    """
    Analytic conductor: N · (k / (2π))²
    """
    return level * (weight / (2 * math.pi)) ** 2


# ============================================================
# Ramanujan tau function (weight 12, level 1)
# ============================================================

def ramanujan_tau(n: int) -> int:
    """
    Compute τ(n) using the product formula for Δ(q).
    τ(n) is defined by: Δ(q) = q·∏_{m=1}^∞ (1-q^m)^24 = Σ τ(n)q^n
    """
    if n <= 0:
        return 0
    # Use the recursion via divisor sums
    # τ(n) can be computed using Ramanujan's congruences and recursion
    # Here we use direct power series expansion
    coeffs = [0] * (n + 1)
    # Product (1-q^m)^24 up to m terms
    prod_coeffs = [0] * (n + 1)
    prod_coeffs[0] = 1

    for m in range(1, n + 1):
        # Multiply by (1 - q^m)^24
        # Use binomial expansion for small powers
        new_coeffs = prod_coeffs[:]
        for exp in range(1, 25):  # (1-q^m)^24, expand binomially
            sign = (-1) ** exp
            binom = 1
            for j in range(exp):
                binom = binom * (24 - j) // (j + 1)
            coeff = sign * binom
            for i in range(n, m * exp - 1, -1):
                if i - m * exp >= 0:
                    new_coeffs[i] += coeff * prod_coeffs[i - m * exp]
        prod_coeffs = new_coeffs

    # Δ(q) = q · prod, so τ(n) = prod_coeffs[n-1]
    if n - 1 < len(prod_coeffs):
        return prod_coeffs[n - 1]
    return 0


def verify_hecke_recursion_tau(p: int, max_r: int = 5) -> List[Tuple[int, int, int, bool]]:
    """
    Verify the Hecke recursion for the Ramanujan tau function at prime p:
        τ(p^(r+1)) = τ(p)·τ(p^r) - p^11·τ(p^(r-1))

    Returns list of (r, τ(p^r), predicted, match) tuples.
    """
    results = []
    tau_p = ramanujan_tau(p)
    for r in range(2, max_r + 1):
        actual = ramanujan_tau(p**r)
        predicted = tau_p * ramanujan_tau(p**(r-1)) - p**11 * ramanujan_tau(p**(r-2))
        results.append((r, actual, predicted, actual == predicted))
    return results


if __name__ == "__main__":
    # Quick test
    print("Ramanujan tau values:")
    for n in range(1, 13):
        print(f"  τ({n}) = {ramanujan_tau(n)}")

    print("\nHecke recursion verification at p=2:")
    for r, actual, predicted, ok in verify_hecke_recursion_tau(2):
        print(f"  τ(2^{r}) = {actual}, predicted = {predicted}, {'✓' if ok else '✗'}")
