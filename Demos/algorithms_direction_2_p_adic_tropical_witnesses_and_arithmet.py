#!/usr/bin/env python3
"""
algorithms.py — Arithmetic Tropical Witness Algorithms

Implements the core algorithms for computing p-adic tropical witnesses,
prime support analysis, and conjecture testing.

All algorithms correspond to formally verified definitions in
Catalog/Pythagorean/PadicTropicalWitness.lean.
"""

import math
from fractions import Fraction
from typing import Dict, List, Set, Tuple, Optional


# ─── Algorithm 1: p-Adic Valuation ──────────────────────────────────────────

def padic_valuation(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n) for integer n.
    
    The p-adic valuation is the largest power of p dividing n.
    
    Time complexity: O(log_p(n))
    Space complexity: O(1)
    
    Corresponds to: padicValNat in Mathlib
    
    Examples:
        >>> padic_valuation(2, 24)
        3
        >>> padic_valuation(3, 24)
        1
        >>> padic_valuation(5, 24)
        0
        >>> padic_valuation(2, 0)
        0
    """
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_valuation_rat(p: int, c: Fraction) -> int:
    """Compute the p-adic valuation v_p(c) for rational c.
    
    For c = a/b in lowest terms: v_p(c) = v_p(a) - v_p(b).
    
    Time complexity: O(log_p(max(|a|, b)))
    Space complexity: O(1)
    
    Corresponds to: padicValRat in Mathlib
    
    Examples:
        >>> padic_valuation_rat(2, Fraction(12, 5))
        2
        >>> padic_valuation_rat(5, Fraction(12, 5))
        -1
        >>> padic_valuation_rat(3, Fraction(12, 5))
        1
    """
    if c == 0:
        return 0
    return padic_valuation(p, c.numerator) - padic_valuation(p, c.denominator)


# ─── Algorithm 2: p-Adic Coefficient Weight ─────────────────────────────────

def padic_coeff_weight(p: int, c: Fraction) -> int:
    """Compute |v_p(c)|, the p-adic coefficient weight.
    
    This is the absolute value of the p-adic valuation, measuring
    how far c is from being a p-adic unit.
    
    Time complexity: O(log_p(max(|num|, den)))
    Space complexity: O(1)
    
    Corresponds to: padicCoeffWeight in PadicTropicalWitness.lean
    
    Properties (formally verified):
    - padicCoeffWeight(q, 0) = 0
    - padicCoeffWeight(q, 1) = 0
    - padicCoeffWeight(q, a*b) ≤ padicCoeffWeight(q, a) + padicCoeffWeight(q, b)
    
    Examples:
        >>> padic_coeff_weight(2, Fraction(8, 3))
        3
        >>> padic_coeff_weight(3, Fraction(8, 3))
        1
        >>> padic_coeff_weight(5, Fraction(8, 3))
        0
    """
    return abs(padic_valuation_rat(p, c))


# ─── Algorithm 3: Prime Support ─────────────────────────────────────────────

def prime_factorization(n: int) -> Dict[int, int]:
    """Compute the prime factorization of |n|.
    
    Time complexity: O(sqrt(n))
    Space complexity: O(log(n))
    
    Examples:
        >>> prime_factorization(360)
        {2: 3, 3: 2, 5: 1}
    """
    if n == 0:
        return {}
    n = abs(n)
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = 1
    return factors


def prime_support_of_rat(c: Fraction) -> Set[int]:
    """Compute the prime support of a rational number.
    
    Returns the set of primes dividing either the numerator or denominator.
    
    Corresponds to: primeSupportOfRat in PadicTropicalWitness.lean
    
    Time complexity: O(sqrt(max(|num|, den)))
    Space complexity: O(log(max(|num|, den)))
    
    Examples:
        >>> sorted(prime_support_of_rat(Fraction(12, 35)))
        [2, 3, 5, 7]
    """
    return set(prime_factorization(c.numerator).keys()) | \
           set(prime_factorization(c.denominator).keys())


# ─── Algorithm 4: Polynomial Tropical Witness ───────────────────────────────

class RatPoly:
    """Multivariate polynomial with rational coefficients.
    
    Coefficients are stored as a dict mapping exponent tuples to Fraction values.
    Only nonzero coefficients are stored (sparse representation).
    """
    
    def __init__(self, coeffs: Optional[Dict[tuple, Fraction]] = None):
        """Initialize polynomial from coefficient dictionary.
        
        Args:
            coeffs: Dict mapping exponent tuples to rational coefficients.
        """
        self.coeffs: Dict[tuple, Fraction] = {}
        if coeffs:
            for exp, c in coeffs.items():
                c = Fraction(c)
                if c != 0:
                    self.coeffs[exp] = c
    
    @property
    def support(self) -> Set[tuple]:
        """The support: set of exponent vectors with nonzero coefficients."""
        return set(self.coeffs.keys())
    
    @property
    def support_size(self) -> int:
        """Number of monomials with nonzero coefficients."""
        return len(self.coeffs)
    
    def coeff(self, exp: tuple) -> Fraction:
        """Get the coefficient of monomial x^exp."""
        return self.coeffs.get(exp, Fraction(0))


def padic_trop_support_weight(p: int, poly: RatPoly) -> int:
    """Compute the q-adic tropical support weight of a polynomial.
    
    W^(q)_coeff(poly) = sum_{alpha in supp} |v_q(c_alpha)|
    
    Corresponds to: padicTropSupportWeight in PadicTropicalWitness.lean
    
    Time complexity: O(|supp| * log_p(max coefficient size))
    Space complexity: O(1)
    
    Examples:
        >>> p = RatPoly({(1,0): Fraction(4,9), (0,1): Fraction(3,8)})
        >>> padic_trop_support_weight(2, p)
        5
        >>> padic_trop_support_weight(3, p)
        3
    """
    return sum(padic_coeff_weight(p, c) for c in poly.coeffs.values())


def padic_trop_witness(p: int, family: List[RatPoly]) -> int:
    """Compute the arithmetic tropical witness for a polynomial family.
    
    W^(q)(A) = sum_{f in family} W^(q)_coeff(f)
    
    Corresponds to: padicTropWitness in PadicTropicalWitness.lean
    
    Time complexity: O(sum of support sizes * log_p(max coeff))
    Space complexity: O(1)
    """
    return sum(padic_trop_support_weight(p, f) for f in family)


def prime_aggregated_witness(primes: List[int], family: List[RatPoly]) -> int:
    """Compute the prime-aggregated witness: max over primes.
    
    W^max(A; S) = max_{q in S} W^(q)(A)
    
    Corresponds to: primeAggregatedWitness in PadicTropicalWitness.lean
    
    Time complexity: O(|S| * sum of support sizes * log(max coeff))
    Space complexity: O(1)
    """
    if not primes:
        return 0
    return max(padic_trop_witness(p, family) for p in primes)


def prime_support(poly: RatPoly) -> Set[int]:
    """Compute the prime support of a polynomial.
    
    Union of prime supports of all nonzero coefficients.
    
    Corresponds to: primeSupport in PadicTropicalWitness.lean
    
    Time complexity: O(|supp| * sqrt(max coeff))
    Space complexity: O(number of distinct primes)
    """
    result = set()
    for c in poly.coeffs.values():
        result |= prime_support_of_rat(c)
    return result


def coeff_height(poly: RatPoly) -> float:
    """Compute the coefficient height of a polynomial.
    
    H(p) = sum_{alpha in supp} log(max(|num(c_alpha)|, den(c_alpha)))
    
    Corresponds to: coeffHeight in PadicTropicalWitness.lean
    
    Time complexity: O(|supp|)
    Space complexity: O(1)
    """
    return sum(
        math.log(max(abs(c.numerator), c.denominator))
        for c in poly.coeffs.values()
    )


# ─── Algorithm 5: Full Witness Profile ──────────────────────────────────────

def compute_full_witness_profile(
    poly: RatPoly,
    test_primes: Optional[List[int]] = None
) -> Dict:
    """Compute the complete arithmetic tropical witness profile.
    
    Returns a dictionary with:
    - prime_support: set of primes in the support
    - primewise_weights: dict mapping each prime to its weight
    - max_weight: maximum weight over test primes
    - coeff_height: the coefficient height
    - support_size: number of monomials
    
    Time complexity: O(|S| * |supp| * log(max coeff) + |supp| * sqrt(max coeff))
    Space complexity: O(|S| + number of primes)
    """
    if test_primes is None:
        test_primes = [2, 3, 5, 7, 11]
    
    ps = prime_support(poly)
    all_primes = sorted(ps | set(test_primes))
    
    weights = {p: padic_trop_support_weight(p, poly) for p in all_primes}
    
    return {
        "prime_support": ps,
        "primewise_weights": weights,
        "max_weight": max(weights.values()) if weights else 0,
        "coeff_height": coeff_height(poly),
        "support_size": poly.support_size,
    }


# ─── Algorithm 6: Conjecture Tester ─────────────────────────────────────────

def test_arithmetic_tropical_conjecture(
    family: List[RatPoly],
    test_primes: List[int] = None,
    C: float = 2.0,
) -> Dict:
    """Test the Arithmetic Tropical Witness Conjecture on a polynomial family.
    
    Tests: log|W_spec(p,A)| ≤ C · max_{q ∈ S} W^(q)(p,A)
    
    Returns a dict with test results, the required C, and diagnostic info.
    
    Args:
        family: list of polynomials (the family F)
        test_primes: list of primes to test (default [2,3,5,7,11])
        C: constant to test against
    
    Returns:
        Dict with keys: passes, log_spectral, max_witness, C_required, witnesses
    """
    if test_primes is None:
        test_primes = [2, 3, 5, 7, 11]
    
    # Spectral witness proxy: sum of |c| over all polynomials
    spec = sum(
        sum(float(abs(c)) for c in f.coeffs.values())
        for f in family
    )
    log_spec = math.log(max(spec, 1e-300))
    
    witnesses = {p: padic_trop_witness(p, family) for p in test_primes}
    max_wit = max(witnesses.values()) if witnesses else 0
    
    passes = log_spec <= C * max_wit if max_wit > 0 else log_spec <= 0
    c_required = log_spec / max_wit if max_wit > 0 else float('inf')
    
    return {
        "passes": passes,
        "log_spectral": log_spec,
        "max_witness": max_wit,
        "C_required": c_required,
        "witnesses": witnesses,
    }


# ─── Example Usage ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: compute witness profile
    p = RatPoly({
        (1, 0, 0): Fraction(4, 9),
        (0, 1, 0): Fraction(3, 8),
        (0, 0, 1): Fraction(7, 25),
        (1, 1, 0): Fraction(1, 6),
    })
    
    profile = compute_full_witness_profile(p)
    print("Witness profile:")
    for key, val in profile.items():
        print(f"  {key}: {val}")
    
    print("\nConjecture test:")
    result = test_arithmetic_tropical_conjecture([p])
    for key, val in result.items():
        print(f"  {key}: {val}")
