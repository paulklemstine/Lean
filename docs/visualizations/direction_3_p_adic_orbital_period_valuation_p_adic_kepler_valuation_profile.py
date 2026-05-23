#!/usr/bin/env python3
"""
Algorithms for P-adic Orbital Period Valuation

Implements the core algorithms from the research paper:
1. P-adic valuation computation for rationals
2. Kepler period valuation profile computation
3. Rationality criterion testing
4. Tropical curve vertex computation
5. Arithmetic equivalence class enumeration

All algorithms have verified correctness theorems in Lean 4.
"""

from fractions import Fraction
from typing import Optional
from collections import defaultdict
import math


# ──────────────────────────────────────────────────────────────
# Algorithm 1: P-adic Valuation
# ──────────────────────────────────────────────────────────────

def padic_valuation(n: int, p: int) -> int:
    """Compute v_p(n), the p-adic valuation of integer n.
    
    Time complexity: O(log_p(n))
    Space complexity: O(1)
    
    Args:
        n: A nonzero integer
        p: A prime number
    
    Returns:
        The largest k such that p^k divides n
    
    Raises:
        ValueError: If n is 0 or p < 2
    
    Examples:
        >>> padic_valuation(12, 2)
        2
        >>> padic_valuation(12, 3)
        1
        >>> padic_valuation(7, 2)
        0
    """
    if n == 0:
        raise ValueError("p-adic valuation of 0 is undefined (infinity)")
    if p < 2:
        raise ValueError(f"p must be prime, got {p}")
    
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_valuation_rational(r: Fraction, p: int) -> int:
    """Compute v_p(r) for a nonzero rational r.
    
    v_p(a/b) = v_p(a) - v_p(b) for coprime a, b.
    
    Time complexity: O(log_p(max(|num|, den)))
    Space complexity: O(1)
    
    Args:
        r: A nonzero rational number
        p: A prime number
    
    Returns:
        The p-adic valuation of r
    
    Examples:
        >>> padic_valuation_rational(Fraction(12, 5), 2)
        2
        >>> padic_valuation_rational(Fraction(12, 5), 5)
        -1
    """
    if r == 0:
        raise ValueError("p-adic valuation of 0 is undefined")
    return padic_valuation(r.numerator, p) - padic_valuation(r.denominator, p)


# ──────────────────────────────────────────────────────────────
# Algorithm 2: Kepler Period Valuation Profile
# ──────────────────────────────────────────────────────────────

def kepler_valuation_at(a: Fraction, mu: Fraction, p: int) -> Optional[int]:
    """Compute v_p(q) where q is the Kepler period ratio satisfying q²·μ = a³.
    
    By the Kepler Period Valuation Formula (Theorem 2):
        v_p(q) = (3·v_p(a) - v_p(μ)) / 2
    
    This is well-defined iff 3·v_p(a) - v_p(μ) is even at prime p.
    
    Time complexity: O(log_p(max(|a|, |μ|)))
    Space complexity: O(1)
    
    Args:
        a: Semi-major axis (positive rational)
        mu: Gravitational parameter (positive rational)
        p: A prime number
    
    Returns:
        v_p(q) if the numerator is even, None otherwise
    """
    val_a = padic_valuation_rational(a, p)
    val_mu = padic_valuation_rational(mu, p)
    diff = 3 * val_a - val_mu
    if diff % 2 != 0:
        return None
    return diff // 2


def kepler_valuation_profile(
    a: Fraction, mu: Fraction, primes: list[int] = None
) -> Optional[dict[int, int]]:
    """Compute the full p-adic valuation profile of a Kepler orbit.
    
    The profile is the function p ↦ v_p(q) for all relevant primes.
    Returns None if the period ratio is irrational (detected at some prime).
    
    Time complexity: O(|primes| · log(max(|a|, |μ|)))
    Space complexity: O(|primes|)
    
    Args:
        a: Semi-major axis (positive rational)
        mu: Gravitational parameter (positive rational)  
        primes: Primes to check (default: primes dividing a³/μ plus 2,3,5)
    
    Returns:
        Dict mapping prime → valuation, or None if period is irrational
    """
    if primes is None:
        primes = list(relevant_primes(a, mu))
    
    profile = {}
    for p in primes:
        val = kepler_valuation_at(a, mu, p)
        if val is None:
            return None
        profile[p] = val
    return profile


def relevant_primes(a: Fraction, mu: Fraction) -> set[int]:
    """Find all primes that appear in the factorization of a or μ.
    
    These are the only primes where the valuation profile can be nonzero.
    
    Time complexity: O(√max(|a|, |μ|))
    """
    primes = set()
    for r in [a, mu]:
        for n in [abs(r.numerator), r.denominator]:
            if n <= 1:
                continue
            temp = n
            p = 2
            while p * p <= temp:
                if temp % p == 0:
                    primes.add(p)
                    while temp % p == 0:
                        temp //= p
                p += 1
            if temp > 1:
                primes.add(temp)
    return primes


# ──────────────────────────────────────────────────────────────
# Algorithm 3: Rationality Criterion
# ──────────────────────────────────────────────────────────────

def is_kepler_period_rational(a: Fraction, mu: Fraction) -> bool:
    """Test whether the Kepler period ratio q = √(a³/μ) is rational.
    
    By the Rationality Criterion (Theorem 3):
        q ∈ ℚ  ⟺  3·v_p(a) - v_p(μ) is even for all primes p
    
    We only need to check primes dividing the numerator or denominator
    of a³/μ, since the valuation is 0 at all other primes.
    
    Time complexity: O(√max(|a|, |μ|))
    Space complexity: O(number of prime factors)
    
    Args:
        a: Semi-major axis (positive rational)
        mu: Gravitational parameter (positive rational)
    
    Returns:
        True iff q is rational
    
    Examples:
        >>> is_kepler_period_rational(Fraction(4), Fraction(1))
        True
        >>> is_kepler_period_rational(Fraction(4), Fraction(8))
        False
    """
    for p in relevant_primes(a, mu):
        val_a = padic_valuation_rational(a, p)
        val_mu = padic_valuation_rational(mu, p)
        if (3 * val_a - val_mu) % 2 != 0:
            return False
    return True


def rationality_obstruction(a: Fraction, mu: Fraction) -> Optional[int]:
    """Find a prime obstructing rationality of the period ratio.
    
    Returns the smallest prime p where 3·v_p(a) - v_p(μ) is odd,
    or None if the period is rational.
    """
    for p in sorted(relevant_primes(a, mu)):
        val_a = padic_valuation_rational(a, p)
        val_mu = padic_valuation_rational(mu, p)
        if (3 * val_a - val_mu) % 2 != 0:
            return p
    return None


# ──────────────────────────────────────────────────────────────
# Algorithm 4: Tropical Vertex Computation
# ──────────────────────────────────────────────────────────────

def tropical_kepler_vertex(a: Fraction, mu: Fraction, p: int) -> tuple[float, float]:
    """Compute the vertex of the tropical Kepler curve over Q_p.
    
    The tropicalization of q²·μ = a³ gives two monomials:
        L₁(X) = 2X + v_p(μ)    (from q²·μ)
        L₂     = 3·v_p(a)       (from a³)
    
    The vertex (balancing point) is where L₁(X) = L₂:
        X_vertex = (3·v_p(a) - v_p(μ)) / 2
    
    By the Vertex-Valuation Correspondence, this equals v_p(q).
    
    Time complexity: O(log_p(max(|a|, |μ|)))
    
    Returns:
        (X_vertex, Y_vertex) where Y_vertex = L₁(X_vertex) = L₂
    """
    val_a = padic_valuation_rational(a, p)
    val_mu = padic_valuation_rational(mu, p)
    
    x_vertex = (3 * val_a - val_mu) / 2
    y_vertex = 3 * val_a
    
    return (x_vertex, y_vertex)


def tropical_curve_evaluate(x: float, val_mu: int, val_a3: int) -> float:
    """Evaluate the tropical Kepler curve at point x.
    
    trop(x) = max(2x + v_p(μ), 3·v_p(a))
    """
    return max(2 * x + val_mu, val_a3)


# ──────────────────────────────────────────────────────────────
# Algorithm 5: Arithmetic Equivalence Classes
# ──────────────────────────────────────────────────────────────

def classify_orbits(
    max_num: int = 10, max_den: int = 5, primes: list[int] = None
) -> dict[tuple, list[tuple[Fraction, Fraction]]]:
    """Enumerate Kepler orbits and classify by arithmetic equivalence.
    
    Two orbits (a₁, μ₁) and (a₂, μ₂) are arithmetically equivalent iff
    they have the same p-adic valuation profile at every prime.
    
    Time complexity: O(max_num² · max_den² · |primes| · log(max_num · max_den))
    
    Args:
        max_num: Maximum numerator for a and μ
        max_den: Maximum denominator for a and μ
        primes: Primes defining the equivalence (default: [2,3,5,7])
    
    Returns:
        Dictionary mapping profile tuple to list of orbits
    """
    if primes is None:
        primes = [2, 3, 5, 7]
    
    classes = defaultdict(list)
    
    for an in range(1, max_num + 1):
        for ad in range(1, max_den + 1):
            for mn in range(1, max_num + 1):
                for md in range(1, max_den + 1):
                    a = Fraction(an, ad)
                    mu = Fraction(mn, md)
                    
                    profile = kepler_valuation_profile(a, mu, primes)
                    if profile is not None:
                        key = tuple(profile[p] for p in primes)
                        classes[key].append((a, mu))
    
    return dict(classes)


# ──────────────────────────────────────────────────────────────
# Algorithm 6: Period Ratio Reconstruction
# ──────────────────────────────────────────────────────────────

def reconstruct_period_ratio(a: Fraction, mu: Fraction) -> Optional[Fraction]:
    """Reconstruct the period ratio q from orbital parameters.
    
    If q²·μ = a³ has a rational solution, compute q = √(a³/μ).
    
    Time complexity: O(√(a³/μ))
    """
    ratio = a ** 3 / mu
    if ratio <= 0:
        return None
    
    n = ratio.numerator
    d = ratio.denominator
    
    sn = int(math.isqrt(n))
    sd = int(math.isqrt(d))
    
    if sn * sn == n and sd * sd == d:
        return Fraction(sn, sd)
    return None


# ──────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("P-adic Orbital Valuation — Algorithm Examples")
    print("=" * 50)
    
    # Example 1: Basic valuation
    a = Fraction(4)
    mu = Fraction(1)
    print(f"\nOrbit: a={a}, μ={mu}")
    print(f"  Rational period: {is_kepler_period_rational(a, mu)}")
    print(f"  Period ratio q = {reconstruct_period_ratio(a, mu)}")
    print(f"  Profile: {kepler_valuation_profile(a, mu)}")
    
    # Example 2: Irrational period
    a = Fraction(4)
    mu = Fraction(8)
    print(f"\nOrbit: a={a}, μ={mu}")
    print(f"  Rational period: {is_kepler_period_rational(a, mu)}")
    print(f"  Obstruction at p={rationality_obstruction(a, mu)}")
    
    # Example 3: Tropical vertex
    a = Fraction(12)
    mu = Fraction(3)
    print(f"\nOrbit: a={a}, μ={mu}")
    for p in [2, 3]:
        vx, vy = tropical_kepler_vertex(a, mu, p)
        print(f"  Tropical vertex over Q_{p}: ({vx}, {vy})")
    
    # Example 4: Equivalence classes
    print(f"\nArithmetic equivalence classes (small orbits):")
    classes = classify_orbits(max_num=6, max_den=3)
    print(f"  {len(classes)} distinct classes found")
    
    largest = max(classes.items(), key=lambda x: len(x[1]))
    print(f"  Largest class has profile {largest[0]}: {len(largest[1])} orbits")
