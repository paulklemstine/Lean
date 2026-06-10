#!/usr/bin/env python3
"""
Algorithms for Perfect Number Theory

Implements verified algorithms arising from the formal theory:
- Efficient sigma computation via prime factorization
- Perfect number generation from Mersenne primes
- Abundancy index computation and classification
- Odd perfect number exclusion checks
"""

from math import gcd, isqrt, log2
from typing import Dict, List, Tuple, Optional
from fractions import Fraction


# =============================================================================
# Algorithm 1: Prime Factorization Engine
# =============================================================================

def trial_division(n: int) -> Dict[int, int]:
    """
    Factor n into prime powers via trial division.
    
    Returns dict {p: k} where n = ∏ p^k.
    
    Time complexity: O(√n)
    Space complexity: O(log n) for the factorization
    
    >>> trial_division(28)
    {2: 2, 7: 1}
    >>> trial_division(496)
    {2: 4, 31: 1}
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


def miller_rabin(n: int, witnesses: List[int] = None) -> bool:
    """
    Miller-Rabin primality test.
    
    Deterministic for n < 3.317×10^24 with the first 13 primes as witnesses.
    
    Time complexity: O(k · log²n) where k = number of witnesses
    """
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    
    if witnesses is None:
        witnesses = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]
    
    # Write n-1 = 2^r · d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    
    for a in witnesses:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


# =============================================================================
# Algorithm 2: Sigma via Multiplicative Factorization
# =============================================================================

def sigma_from_factorization(factors: Dict[int, int]) -> int:
    """
    Compute σ(n) from prime factorization using multiplicativity.
    
    σ(n) = ∏_{p^k || n} σ(p^k) = ∏_{p^k || n} (p^(k+1) - 1)/(p - 1)
    
    This is the key algorithm justified by our formal proof of:
    - sigma_mul_of_coprime: σ(ab) = σ(a)σ(b) when gcd(a,b) = 1
    - sigma_prime_pow_closed_form: (p-1)·σ(p^k) = p^(k+1) - 1
    
    Time complexity: O(∑ k_i · log p_i) for the powers
    Space complexity: O(1) beyond input
    
    >>> sigma_from_factorization({2: 2, 7: 1})  # σ(28)
    56
    >>> sigma_from_factorization({2: 4, 31: 1})  # σ(496)
    992
    """
    result = 1
    for p, k in factors.items():
        # σ(p^k) = (p^(k+1) - 1) / (p - 1)
        result *= (p ** (k + 1) - 1) // (p - 1)
    return result


def sigma_efficient(n: int) -> int:
    """
    Compute σ(n) efficiently by factoring first.
    
    For large n with small prime factors, this is much faster
    than naive divisor enumeration.
    
    >>> sigma_efficient(28)
    56
    >>> sigma_efficient(8128)
    16256
    """
    if n <= 0:
        return 0
    return sigma_from_factorization(trial_division(n))


# =============================================================================
# Algorithm 3: Perfect Number Generator
# =============================================================================

def generate_even_perfects(max_exponent: int = 30) -> List[Tuple[int, int, int]]:
    """
    Generate all even perfect numbers 2^(p-1) * (2^p - 1)
    for Mersenne primes with p ≤ max_exponent.
    
    Justified by the Euclid–Euler theorem:
    n is even and perfect ↔ n = 2^(p-1)(2^p - 1) with p, 2^p-1 both prime.
    
    Returns list of (p, mersenne_prime, perfect_number).
    
    >>> generate_even_perfects(10)
    [(2, 3, 6), (3, 7, 28), (5, 31, 496), (7, 127, 8128)]
    """
    results = []
    for p in range(2, max_exponent + 1):
        if not miller_rabin(p):
            continue
        m = (1 << p) - 1
        if miller_rabin(m):
            n = (1 << (p - 1)) * m
            results.append((p, m, n))
    return results


def verify_perfect(n: int) -> Tuple[bool, Optional[Dict]]:
    """
    Verify if n is perfect and return its Euclid–Euler decomposition if even.
    
    Returns (is_perfect, decomposition_info).
    
    >>> verify_perfect(28)
    (True, {'type': 'even', 'p': 3, 'mersenne': 7})
    """
    if n <= 0:
        return False, None
    
    s = sigma_efficient(n)
    if s != 2 * n:
        return False, None
    
    if n % 2 == 0:
        # Extract 2-adic valuation
        k = 0
        temp = n
        while temp % 2 == 0:
            k += 1
            temp //= 2
        m = temp
        p = k + 1
        if m == (1 << p) - 1 and miller_rabin(m) and miller_rabin(p):
            return True, {'type': 'even', 'p': p, 'mersenne': m}
        return True, {'type': 'even', 'decomposition_error': True}
    else:
        return True, {'type': 'odd', 'note': 'No odd perfect number is known!'}


# =============================================================================
# Algorithm 4: Abundancy Index Engine
# =============================================================================

def abundancy_index_exact(n: int) -> Fraction:
    """
    Compute the abundancy index I(n) = σ(n)/n as an exact rational number.
    
    Uses Fraction for exact arithmetic, avoiding floating-point errors.
    This is the computational counterpart of our formal AbundancyIndex definition.
    
    >>> abundancy_index_exact(6)
    Fraction(2, 1)
    >>> abundancy_index_exact(28)
    Fraction(2, 1)
    """
    if n <= 0:
        return Fraction(0)
    return Fraction(sigma_efficient(n), n)


def abundancy_from_factorization(factors: Dict[int, int]) -> Fraction:
    """
    Compute abundancy index from prime factorization using multiplicativity.
    
    I(n) = ∏_{p^k || n} I(p^k) = ∏_{p^k || n} (1 + 1/p + ... + 1/p^k)
    
    Justified by abundancyIndex_mul_of_coprime.
    
    >>> abundancy_from_factorization({2: 2, 7: 1})
    Fraction(2, 1)
    """
    result = Fraction(1)
    for p, k in factors.items():
        # I(p^k) = (p^(k+1) - 1) / (p^k * (p - 1))
        numerator = p ** (k + 1) - 1
        denominator = (p ** k) * (p - 1)
        result *= Fraction(numerator, denominator)
    return result


def classify_by_abundancy(n: int) -> str:
    """
    Classify n as deficient, perfect, or abundant.
    
    >>> classify_by_abundancy(6)
    'perfect'
    >>> classify_by_abundancy(12)
    'abundant'
    >>> classify_by_abundancy(7)
    'deficient'
    """
    idx = abundancy_index_exact(n)
    if idx < 2:
        return 'deficient'
    elif idx == 2:
        return 'perfect'
    else:
        return 'abundant'


# =============================================================================
# Algorithm 5: Odd Perfect Number Exclusion
# =============================================================================

def check_odd_perfect_obstructions(n: int) -> List[str]:
    """
    Check known structural obstructions for odd perfect numbers.
    
    Returns list of violated constraints (empty means no obstruction detected).
    
    Based on our formally proved theorems:
    - odd_perfect_gt_one: n > 1
    - odd_perfect_not_prime_power: n is not p^k
    - odd_perfect_has_at_least_two_distinct_prime_factors: ω(n) ≥ 2
    
    >>> check_odd_perfect_obstructions(9)  # 3^2, prime power
    ['Not perfect: σ(9) = 13 ≠ 18 = 2·9']
    """
    violations = []
    
    if n <= 0:
        violations.append("n must be positive")
        return violations
    
    if n % 2 == 0:
        violations.append("n is even, not an odd perfect candidate")
        return violations
    
    s = sigma_efficient(n)
    if s != 2 * n:
        violations.append(f"Not perfect: σ({n}) = {s} ≠ {2*n} = 2·{n}")
        return violations
    
    # Check obstructions
    factors = trial_division(n)
    
    if n <= 1:
        violations.append("n ≤ 1 (odd_perfect_gt_one violated)")
    
    if len(factors) <= 1:
        violations.append(f"Prime power (odd_perfect_not_prime_power violated): {factors}")
    
    if len(factors) < 2:
        violations.append(f"ω(n) = {len(factors)} < 2 (need at least 2 distinct prime factors)")
    
    return violations


def exhaustive_odd_perfect_search(bound: int) -> List[int]:
    """
    Exhaustively search for odd perfect numbers up to bound.
    
    Returns list of odd perfect numbers found (expected: empty).
    
    >>> exhaustive_odd_perfect_search(10000)
    []
    """
    results = []
    for n in range(1, bound + 1, 2):
        if sigma_efficient(n) == 2 * n and n > 0:
            results.append(n)
    return results


# =============================================================================
# Main: Run all algorithms with examples
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Algorithm Demonstrations")
    print("=" * 70)
    print()
    
    # Perfect number generation
    print("Even perfect numbers (Euclid–Euler generation):")
    for p, m, n in generate_even_perfects(25):
        print(f"  p={p:>3}: M_p = {m}, n = {n}")
    print()
    
    # Verification
    print("Verification of known perfect numbers:")
    for n in [6, 28, 496, 8128, 33550336]:
        ok, info = verify_perfect(n)
        print(f"  {n}: perfect={ok}, info={info}")
    print()
    
    # Abundancy classification
    print("Abundancy index classification:")
    for n in [1, 6, 7, 12, 28, 30, 496]:
        idx = abundancy_index_exact(n)
        cls = classify_by_abundancy(n)
        print(f"  I({n}) = {idx} = {float(idx):.4f}  →  {cls}")
    print()
    
    # Abundancy multiplicativity check
    print("Abundancy multiplicativity verification:")
    factors_28 = {2: 2, 7: 1}
    print(f"  28 = 2² × 7")
    print(f"  I(28) direct = {abundancy_index_exact(28)}")
    print(f"  I(28) from factors = {abundancy_from_factorization(factors_28)}")
    print(f"  I(4) × I(7) = {abundancy_index_exact(4)} × {abundancy_index_exact(7)} = {abundancy_index_exact(4) * abundancy_index_exact(7)}")
    print()
    
    # Odd perfect search
    print("Exhaustive odd perfect search up to 10^5:", exhaustive_odd_perfect_search(100_000))
    print()
    
    print("All algorithm demonstrations complete!")
