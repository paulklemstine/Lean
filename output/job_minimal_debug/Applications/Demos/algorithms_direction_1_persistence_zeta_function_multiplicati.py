#!/usr/bin/env python3
"""
Algorithms for Persistence Zeta Function Multiplicativity

Implements certified computation of:
1. Persistence zeta functions (finite Euler products)
2. Overlap correction factors
3. Prime support analysis
4. Multiplicativity verification

All computations use exact rational arithmetic (fractions.Fraction)
to match the formally verified Lean definitions.
"""

from fractions import Fraction
from typing import Dict, List, Set, Tuple, Optional
import math


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: Prime Support Analysis
# ──────────────────────────────────────────────────────────────────

def prime_factorization(n: int) -> Dict[int, int]:
    """
    Compute the prime factorization of n.

    Returns:
        Dictionary mapping prime -> exponent.

    Complexity: O(√n) time, O(log n) space.

    >>> prime_factorization(60)
    {2: 2, 3: 1, 5: 1}
    >>> prime_factorization(1)
    {}
    """
    if n <= 1:
        return {}
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


def prime_support(n: int) -> Set[int]:
    """
    Compute the prime support of Z/nZ.

    The prime support is the set of primes dividing n, which
    correspond to the primes where p-primary torsion is nontrivial.

    Complexity: O(√n) time.

    >>> sorted(prime_support(60))
    [2, 3, 5]
    """
    return set(prime_factorization(n).keys())


def are_coprime_support(n1: int, n2: int) -> bool:
    """
    Check if Z/n₁Z and Z/n₂Z have coprime (disjoint) prime support.

    Complexity: O(√min(n1,n2)) time.

    >>> are_coprime_support(4, 9)
    True
    >>> are_coprime_support(6, 10)
    False
    """
    return math.gcd(n1, n2) == 1


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Persistence Zeta Function Computation
# ──────────────────────────────────────────────────────────────────

def compute_persistence_zeta(
    prime_data: Dict[int, int],
    s: int
) -> Fraction:
    """
    Compute the persistence zeta function from prime barcode data.

    Implements the finite Euler product:
        Z(D, s) = ∏_{p ∈ supp} (1 + ℓ_p / p^s)

    Args:
        prime_data: mapping prime p -> local barcode length ℓ_p
        s: the zeta parameter (positive integer)

    Returns:
        Exact rational value of Z(D, s).

    Complexity: O(|supp| · s) time (for exponentiation).

    >>> compute_persistence_zeta({2: 1, 3: 1}, 1)
    Fraction(2, 1)
    >>> compute_persistence_zeta({2: 2, 5: 1}, 2)
    Fraction(27, 25) * Fraction(3, 2)  # computed step by step
    """
    result = Fraction(1)
    for p, l in sorted(prime_data.items()):
        if l > 0:
            factor = Fraction(1) + Fraction(l, p ** s)
            result *= factor
    return result


def compute_persistence_zeta_factor(
    barcode_length: int,
    p: int,
    s: int
) -> Fraction:
    """
    Compute a single Euler factor: 1 + ℓ/p^s.

    Args:
        barcode_length: local barcode length ℓ_p
        p: prime
        s: zeta parameter

    Returns:
        Exact rational value of the local factor.

    >>> compute_persistence_zeta_factor(1, 2, 1)
    Fraction(3, 2)
    """
    return Fraction(1) + Fraction(barcode_length, p ** s)


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: Additive Product
# ──────────────────────────────────────────────────────────────────

def additive_product_data(
    data1: Dict[int, int],
    data2: Dict[int, int]
) -> Dict[int, int]:
    """
    Compute the additive product of two persistence data.

    Models the CRT decomposition: barcode lengths add pointwise.

    Args:
        data1, data2: prime barcode data for D₁, D₂

    Returns:
        Prime barcode data for D₁ · D₂.

    Complexity: O(|supp₁| + |supp₂|) time.

    >>> additive_product_data({2: 1}, {3: 1})
    {2: 1, 3: 1}
    >>> additive_product_data({2: 1, 3: 1}, {2: 2, 5: 1})
    {2: 3, 3: 1, 5: 1}
    """
    all_primes = set(data1.keys()) | set(data2.keys())
    return {p: data1.get(p, 0) + data2.get(p, 0) for p in all_primes}


# ──────────────────────────────────────────────────────────────────
# Algorithm 4: Overlap Correction Factor
# ──────────────────────────────────────────────────────────────────

def compute_overlap_correction(
    data1: Dict[int, int],
    data2: Dict[int, int],
    data_prod: Dict[int, int],
    s: int
) -> Fraction:
    """
    Compute the overlap correction factor.

    C(D₁, D₂, D_prod, s) = ∏_{p ∈ S₁ ∩ S₂}
        factor_prod(p) / (factor₁(p) · factor₂(p))

    Args:
        data1, data2: prime barcode data for D₁, D₂
        data_prod: prime barcode data for the product
        s: zeta parameter

    Returns:
        Exact rational value of the correction factor.

    Complexity: O(|S₁ ∩ S₂| · s) time.

    >>> compute_overlap_correction({2: 1}, {2: 1}, {2: 3}, 1)
    Fraction(10, 9)
    """
    shared = set(data1.keys()) & set(data2.keys())
    result = Fraction(1)
    for p in sorted(shared):
        f_prod = compute_persistence_zeta_factor(data_prod.get(p, 0), p, s)
        f1 = compute_persistence_zeta_factor(data1.get(p, 0), p, s)
        f2 = compute_persistence_zeta_factor(data2.get(p, 0), p, s)
        denom = f1 * f2
        if denom != 0:
            result *= f_prod / denom
    return result


# ──────────────────────────────────────────────────────────────────
# Algorithm 5: Multiplicativity Verification
# ──────────────────────────────────────────────────────────────────

def verify_multiplicativity(
    data1: Dict[int, int],
    data2: Dict[int, int],
    s: int
) -> Tuple[bool, Fraction, Fraction, Fraction]:
    """
    Verify the multiplicativity theorem for given persistence data.

    Returns:
        (is_multiplicative, z_prod, z1_times_z2, correction)

    If is_multiplicative is True, then z_prod == z1_times_z2.
    In all cases, z_prod == z1_times_z2 * correction (exact).

    Complexity: O((|S₁| + |S₂|) · s) time.

    >>> verify_multiplicativity({2: 1}, {3: 1}, 1)
    (True, Fraction(2, 1), Fraction(2, 1), Fraction(1, 1))
    """
    data_prod = additive_product_data(data1, data2)
    z_prod = compute_persistence_zeta(data_prod, s)
    z1 = compute_persistence_zeta(data1, s)
    z2 = compute_persistence_zeta(data2, s)
    z1z2 = z1 * z2
    correction = compute_overlap_correction(data1, data2, data_prod, s)

    is_mult = (z_prod == z1z2)
    return is_mult, z_prod, z1z2, correction


# ──────────────────────────────────────────────────────────────────
# Algorithm 6: Obstruction Localization
# ──────────────────────────────────────────────────────────────────

def localize_obstruction(
    data1: Dict[int, int],
    data2: Dict[int, int],
    s: int
) -> Optional[List[int]]:
    """
    If multiplicativity fails, return the list of obstruction primes.

    An obstruction prime is a shared prime where the local factor
    of the product differs from the product of local factors.

    Returns:
        None if multiplicativity holds.
        List of obstruction primes otherwise.

    Complexity: O((|S₁| + |S₂|) · s) time.

    >>> localize_obstruction({2: 1}, {3: 1}, 1) is None
    True
    >>> localize_obstruction({2: 1, 3: 1}, {2: 1, 3: 1}, 1)
    [2, 3]
    """
    data_prod = additive_product_data(data1, data2)
    z_prod = compute_persistence_zeta(data_prod, s)
    z1z2 = compute_persistence_zeta(data1, s) * compute_persistence_zeta(data2, s)

    if z_prod == z1z2:
        return None

    shared = set(data1.keys()) & set(data2.keys())
    obstructions = []
    for p in sorted(shared):
        l_prod = data_prod.get(p, 0)
        l1 = data1.get(p, 0)
        l2 = data2.get(p, 0)
        f_prod = compute_persistence_zeta_factor(l_prod, p, s)
        f1f2 = compute_persistence_zeta_factor(l1, p, s) * compute_persistence_zeta_factor(l2, p, s)
        if f_prod != f1f2:
            obstructions.append(p)

    return obstructions


# ──────────────────────────────────────────────────────────────────
# Algorithm 7: Correction Convergence Analysis
# ──────────────────────────────────────────────────────────────────

def correction_convergence_rate(
    data1: Dict[int, int],
    data2: Dict[int, int],
    max_s: int = 20
) -> List[Tuple[int, float]]:
    """
    Compute |C(s) - 1| for s = 1, ..., max_s to analyze convergence.

    The correction factor tends to 1 as s → ∞ because each local
    correction (1 + (a+b)/p^s) / ((1+a/p^s)(1+b/p^s)) → 1.

    Returns:
        List of (s, |C(s) - 1|) pairs.

    >>> rates = correction_convergence_rate({2: 1}, {2: 1})
    >>> all(r[1] >= 0 for r in rates)
    True
    >>> rates[-1][1] < rates[0][1]  # convergence
    True
    """
    data_prod = additive_product_data(data1, data2)
    results = []
    for s in range(1, max_s + 1):
        corr = compute_overlap_correction(data1, data2, data_prod, s)
        deviation = abs(float(corr) - 1.0)
        results.append((s, deviation))
    return results


# ──────────────────────────────────────────────────────────────────
# Main: Example usage
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Persistence Zeta Function — Algorithm Examples")
    print("=" * 50)

    # Example 1: Disjoint support
    print("\nExample 1: Z/4Z × Z/9Z (disjoint support)")
    d1, d2 = {2: 2}, {3: 2}
    is_mult, z_prod, z1z2, corr = verify_multiplicativity(d1, d2, 1)
    print(f"  Z(prod, 1) = {z_prod} = {float(z_prod):.4f}")
    print(f"  Z₁·Z₂     = {z1z2} = {float(z1z2):.4f}")
    print(f"  Multiplicative: {is_mult}")
    print(f"  Correction: {corr}")

    # Example 2: Overlapping support
    print("\nExample 2: Z/6Z × Z/10Z (overlapping at p=2)")
    d1, d2 = prime_factorization(6), prime_factorization(10)
    is_mult, z_prod, z1z2, corr = verify_multiplicativity(d1, d2, 1)
    print(f"  Z(prod, 1) = {z_prod} = {float(z_prod):.4f}")
    print(f"  Z₁·Z₂     = {z1z2} = {float(z1z2):.4f}")
    print(f"  Multiplicative: {is_mult}")
    print(f"  Correction: {corr} = {float(corr):.6f}")
    obs = localize_obstruction(d1, d2, 1)
    print(f"  Obstruction primes: {obs}")

    # Example 3: Convergence
    print("\nExample 3: Correction convergence for Z/6Z × Z/6Z")
    d1, d2 = prime_factorization(6), prime_factorization(6)
    rates = correction_convergence_rate(d1, d2, 10)
    for s, dev in rates:
        print(f"  s={s:2d}: |C-1| = {dev:.12f}")
