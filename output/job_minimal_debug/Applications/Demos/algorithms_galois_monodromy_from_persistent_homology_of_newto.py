"""
Arithmetic Persistence Theory: Core Algorithms

Implements the prime-weighted support filtration and persistence signature
computation for integer polynomials.
"""

from typing import Dict, List, Tuple, Optional
from collections import defaultdict
import math


def padic_valuation(n: int, p: int) -> int:
    """
    Compute the p-adic valuation of an integer n.
    
    The p-adic valuation v_p(n) is the largest power of p dividing n.
    By convention, v_p(0) = infinity, represented here as a large number.
    
    Args:
        n: An integer
        p: A prime number (must be >= 2)
    
    Returns:
        The p-adic valuation of n
        
    Examples:
        >>> padic_valuation(12, 2)
        2
        >>> padic_valuation(12, 3)
        1
        >>> padic_valuation(7, 2)
        0
    """
    if n == 0:
        return 10**9  # Convention: v_p(0) = infinity
    if p < 2:
        raise ValueError(f"p must be >= 2, got {p}")
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def monomial_weight(coeff: int, p: int) -> int:
    """
    Compute the weight of a monomial at prime p.
    
    The weight is the p-adic valuation of the coefficient.
    
    Args:
        coeff: The integer coefficient
        p: A prime number
    
    Returns:
        The p-adic valuation weight
    """
    return padic_valuation(coeff, p)


def lower_support_at_level(
    support: List[Tuple],
    coeffs: Dict[Tuple, int],
    p: int,
    t: int
) -> List[Tuple]:
    """
    Compute the lower support at filtration level t.
    
    Returns the subset of support monomials whose p-adic weight is <= t.
    
    Args:
        support: List of exponent tuples (the support)
        coeffs: Dictionary mapping exponent tuples to integer coefficients
        p: A prime number
        t: The filtration threshold
    
    Returns:
        List of monomials in the filtration at level t
        
    Examples:
        >>> support = [(0,), (1,), (3,)]
        >>> coeffs = {(0,): 5, (1,): 8, (3,): 1}
        >>> lower_support_at_level(support, coeffs, 2, 0)
        [(0,), (3,)]
        >>> lower_support_at_level(support, coeffs, 2, 3)
        [(0,), (1,), (3,)]
    """
    result = []
    for m in support:
        c = coeffs.get(m, 0)
        if c != 0 and monomial_weight(c, p) <= t:
            result.append(m)
    return result


def lower_support_card(
    support: List[Tuple],
    coeffs: Dict[Tuple, int],
    p: int,
    t: int
) -> int:
    """Cardinality of the lower support at level t."""
    return len(lower_support_at_level(support, coeffs, p, t))


def jump_count(
    support: List[Tuple],
    coeffs: Dict[Tuple, int],
    p: int,
    t: int
) -> int:
    """Count of monomials entering the filtration at exactly level t."""
    count = 0
    for m in support:
        c = coeffs.get(m, 0)
        if c != 0 and monomial_weight(c, p) == t:
            count += 1
    return count


def filtration_profile(
    support: List[Tuple],
    coeffs: Dict[Tuple, int],
    p: int,
    max_level: int = 20
) -> List[int]:
    """
    Compute the full filtration cardinality profile.
    
    Returns a list where entry t is the cardinality of lowerSupportAtLevel at level t.
    
    Args:
        support: The polynomial support
        coeffs: Coefficient map
        p: Prime number
        max_level: Maximum filtration level to compute
    
    Returns:
        List of cardinalities [card(level_0), card(level_1), ...]
        
    Time complexity: O(max_level * |support|)
    Space complexity: O(max_level + |support|)
    """
    return [lower_support_card(support, coeffs, p, t) for t in range(max_level + 1)]


def jump_profile(
    support: List[Tuple],
    coeffs: Dict[Tuple, int],
    p: int,
    max_level: int = 20
) -> List[int]:
    """
    Compute the jump profile (number of births at each level).
    
    Returns a list where entry t is the number of monomials with weight exactly t.
    
    Args:
        support: The polynomial support
        coeffs: Coefficient map
        p: Prime number
        max_level: Maximum level
    
    Returns:
        List of jump counts
    """
    return [jump_count(support, coeffs, p, t) for t in range(max_level + 1)]


def weight_profile(
    support: List[Tuple],
    coeffs: Dict[Tuple, int],
    p: int
) -> List[Tuple[Tuple, int]]:
    """
    Compute the full weight profile: list of (monomial, weight) pairs.
    
    Args:
        support: The polynomial support
        coeffs: Coefficient map
        p: Prime number
    
    Returns:
        List of (monomial, weight) pairs sorted by weight
    """
    result = []
    for m in support:
        c = coeffs.get(m, 0)
        if c != 0:
            result.append((m, monomial_weight(c, p)))
    result.sort(key=lambda x: x[1])
    return result


def total_persistence_mass(
    support: List[Tuple],
    coeffs: Dict[Tuple, int],
    p: int
) -> int:
    """Sum of all weights in the profile."""
    return sum(monomial_weight(coeffs.get(m, 0), p) for m in support if coeffs.get(m, 0) != 0)


def persistence_signature(
    support: List[Tuple],
    coeffs: Dict[Tuple, int],
    primes: List[int],
    max_level: int = 10
) -> Dict[int, List[int]]:
    """
    Compute the persistence signature across multiple primes.
    
    Returns a dictionary mapping each prime to its filtration profile.
    
    Args:
        support: The polynomial support
        coeffs: Coefficient map
        primes: List of primes to compute signatures for
        max_level: Maximum filtration level
    
    Returns:
        Dictionary {prime: filtration_profile}
    """
    return {p: filtration_profile(support, coeffs, p, max_level) for p in primes}


def binomial_data(n: int, c: int) -> Tuple[List[Tuple], Dict[Tuple, int]]:
    """
    Create polynomial data for x^n + c.
    
    Returns (support, coefficients) for the binomial x^n + c.
    """
    support = [(0,), (n,)]
    coeffs = {(0,): c, (n,): 1}
    return support, coeffs


def trinomial_data(n: int, c: int, p: int, r: int) -> Tuple[List[Tuple], Dict[Tuple, int]]:
    """
    Create polynomial data for x^n + p^r * x + c.
    
    Returns (support, coefficients) for the trinomial.
    """
    support = [(0,), (1,), (n,)]
    coeffs = {(0,): c, (1,): p**r, (n,): 1}
    return support, coeffs


def compare_families(
    family_a_data: List[Tuple[List[Tuple], Dict[Tuple, int]]],
    family_b_data: List[Tuple[List[Tuple], Dict[Tuple, int]]],
    primes: List[int],
    max_level: int = 10
) -> Dict[str, any]:
    """
    Compare persistence signatures between two polynomial families.
    
    Returns statistics on how the families differ.
    """
    results = {
        "primes": primes,
        "family_a_profiles": [],
        "family_b_profiles": [],
        "distinguishing_levels": defaultdict(int),
    }
    
    for support, coeffs in family_a_data:
        sig = persistence_signature(support, coeffs, primes, max_level)
        results["family_a_profiles"].append(sig)
    
    for support, coeffs in family_b_data:
        sig = persistence_signature(support, coeffs, primes, max_level)
        results["family_b_profiles"].append(sig)
    
    # Count distinguishing levels
    for p in primes:
        for t in range(max_level + 1):
            a_vals = set()
            b_vals = set()
            for sig in results["family_a_profiles"]:
                a_vals.add(sig[p][t])
            for sig in results["family_b_profiles"]:
                b_vals.add(sig[p][t])
            if a_vals != b_vals:
                results["distinguishing_levels"][(p, t)] += 1
    
    return results


def is_prime(n: int) -> bool:
    """Simple primality test."""
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
    """Return all primes up to n."""
    return [p for p in range(2, n + 1) if is_prime(p)]


if __name__ == "__main__":
    # Example: compare x^5 + 3 vs x^5 + 4x + 3 at various primes
    print("=== Arithmetic Persistence Theory: Algorithm Demo ===\n")
    
    primes = primes_up_to(20)
    
    # Binomial x^5 + 3
    s_bin, c_bin = binomial_data(5, 3)
    print(f"Binomial x^5 + 3:")
    for p in primes[:5]:
        prof = filtration_profile(s_bin, c_bin, p, 5)
        print(f"  p={p}: profile = {prof}")
    
    print()
    
    # Trinomial x^5 + p^2 * x + 3
    for p in [2, 3, 5]:
        s_tri, c_tri = trinomial_data(5, 3, p, 2)
        prof = filtration_profile(s_tri, c_tri, p, 5)
        print(f"Trinomial x^5 + {p}^2*x + 3 at p={p}: profile = {prof}")
    
    print()
    
    # Demonstrate family separation
    print("=== Family Separation Demo ===")
    p = 2
    r = 3
    s_bin, c_bin = binomial_data(5, 3)
    s_tri, c_tri = trinomial_data(5, 3, p, r)
    
    for t in range(6):
        card_bin = lower_support_card(s_bin, c_bin, p, t)
        card_tri = lower_support_card(s_tri, c_tri, p, t)
        marker = " <-- DIFFERENT!" if card_bin != card_tri else ""
        print(f"  Level {t}: binomial={card_bin}, trinomial={card_tri}{marker}")
