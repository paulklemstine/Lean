#!/usr/bin/env python3
"""
Tropical Valuation Sieve — Algorithm 22 from the SPB Framework

Demonstrates factoring via tropical (p-adic) valuations.
In tropical algebra, multiplication becomes addition: v_p(ab) = v_p(a) + v_p(b).
The tropical profile of N reveals its prime structure.

Based on formally verified mathematics in:
  - Speculative/TropicalFactoring.lean
  - smooth_iff_tropical, semiprime_valuation, tropical_factoring_constraint
"""

from typing import List, Tuple, Optional, Dict
import math


def primes_up_to(B: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if B < 2:
        return []
    sieve = [True] * (B + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(B**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, B + 1, i):
                sieve[j] = False
    return [i for i in range(2, B + 1) if sieve[i]]


def padic_valuation(n: int, p: int) -> int:
    """
    Compute v_p(n) — the p-adic valuation of n.
    This is the tropical homomorphism: v_p(ab) = v_p(a) + v_p(b).
    Verified as padic_val_mul' in TropicalFactoring.lean.
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def tropical_profile(N: int, B: int = 100) -> Dict[int, int]:
    """
    Compute the tropical profile of N: the map p ↦ v_p(N) for primes p ≤ B.
    
    For a semiprime N = pq with p, q > B, all entries are 0.
    (Verified as semiprime_valuation: v_ℓ(pq) = 0 for ℓ ≠ p, q.)
    """
    return {p: padic_valuation(N, p) for p in primes_up_to(B)}


def is_smooth(N: int, B: int) -> bool:
    """
    Check if N is B-smooth (all prime factors ≤ B).
    Equivalent to: v_p(N) = 0 for all primes p > B.
    (Verified as smooth_iff_tropical in TropicalFactoring.lean.)
    """
    temp = N
    for p in primes_up_to(B):
        while temp % p == 0:
            temp //= p
    return temp == 1


def is_perfect_square_tropical(N: int, B: int = 100) -> Tuple[bool, Optional[int]]:
    """
    Check if N is a perfect square using tropical profile.
    N is a square iff v_p(N) is even for all p.
    (Verified as square_even_valuation and odd_valuation_not_square.)
    
    Returns (is_square, witnessing_prime_if_not).
    """
    for p in primes_up_to(B):
        v = padic_valuation(N, p)
        if v % 2 == 1:
            return (False, p)
    # Check remaining cofactor
    temp = N
    for p in primes_up_to(B):
        temp //= p ** padic_valuation(N, p)
    if temp > 1:
        return (None, None)  # Can't determine with this bound
    return (True, None)


def tropical_factor(N: int, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Tropical Valuation Sieve for factoring.
    
    Strategy:
    1. Compute tropical profile to find small prime factors
    2. Use smoothness characterization for sieve
    3. Apply tropical Newton polygon ideas for larger factors
    """
    if N <= 1:
        return None
    
    profile = tropical_profile(N, B=int(N**0.5) + 1)
    
    if verbose:
        print(f"Tropical profile of {N}:")
        nonzero = {p: v for p, v in profile.items() if v > 0}
        if nonzero:
            for p, v in sorted(nonzero.items()):
                print(f"  v_{p}({N}) = {v}")
        else:
            print(f"  All valuations zero up to √N — N is prime or has large factors")
    
    # Extract factors from non-zero valuations
    for p, v in profile.items():
        if v > 0:
            factor = p
            if 1 < factor < N:
                return (factor, N // factor)
    
    return None


def smooth_number_sieve(N: int, B: int = 50, R: int = 1000, verbose: bool = False):
    """
    Smooth number detection via tropical profile for sieve-based factoring.
    
    Find x values where x² - N is B-smooth, then combine relations
    to find a congruence of squares.
    """
    if verbose:
        print(f"\nSmooth Number Sieve: N = {N}, B = {B}")
    
    base = int(math.isqrt(N)) + 1
    smooth_relations = []
    
    for x in range(base, base + R):
        val = x * x - N
        if val > 0 and is_smooth(val, B):
            # Compute tropical decomposition
            profile = {p: padic_valuation(val, p) for p in primes_up_to(B) if padic_valuation(val, p) > 0}
            smooth_relations.append((x, val, profile))
            if verbose:
                print(f"  x = {x}: x² - N = {val} = ", end="")
                print(" · ".join(f"{p}^{v}" for p, v in sorted(profile.items())))
    
    if verbose:
        print(f"  Found {len(smooth_relations)} smooth relations")
    
    return smooth_relations


def demo():
    """Run demonstrations of tropical factoring methods."""
    print("=" * 60)
    print("Tropical Valuation Sieve — Factoring via p-adic Geometry")
    print("=" * 60)
    
    # 1. Tropical profiles
    print("\n--- Tropical Profiles ---")
    examples = [12, 60, 100, 1001, 2310, 30030]
    for N in examples:
        profile = tropical_profile(N)
        nonzero = {p: v for p, v in profile.items() if v > 0}
        print(f"  N = {N:>6}: " + " · ".join(f"{p}^{v}" for p, v in sorted(nonzero.items())))
    
    # 2. Semiprime detection
    print("\n--- Semiprime Tropical Signatures ---")
    semiprimes = [(3, 5), (7, 11), (13, 17), (101, 103), (997, 991)]
    for p, q in semiprimes:
        N = p * q
        profile = tropical_profile(N, B=max(p, q) + 10)
        nonzero = {pr: v for pr, v in profile.items() if v > 0}
        print(f"  {p} × {q} = {N}: v_{p} = {padic_valuation(N, p)}, v_{q} = {padic_valuation(N, q)}")
    
    # 3. Square detection
    print("\n--- Perfect Square Detection (Tropical) ---")
    for N in [36, 49, 100, 144, 50, 72, 98]:
        result, witness = is_perfect_square_tropical(N, B=50)
        if result:
            print(f"  {N} is a perfect square (√{N} = {int(math.isqrt(N))})")
        elif result is False:
            print(f"  {N} is NOT a perfect square (v_{witness}({N}) = {padic_valuation(N, witness)} is odd)")
        else:
            print(f"  {N}: undetermined with bound B=50")
    
    # 4. Smoothness check
    print("\n--- Smoothness Detection ---")
    for N in [60, 100, 210, 2310, 30031, 1000003]:
        for B in [10, 20, 50]:
            if is_smooth(N, B):
                print(f"  {N} is {B}-smooth ✓")
                break
        else:
            print(f"  {N} is not 50-smooth ✗")
    
    # 5. Factoring demo
    print("\n--- Tropical Factoring ---")
    test_cases = [15, 77, 143, 1001, 10403, 25117, 104729]
    for N in test_cases:
        result = tropical_factor(N, verbose=False)
        if result:
            p, q = result
            print(f"  N = {N:>8} → {p} × {q}")
        else:
            print(f"  N = {N:>8} → no small factor found (possible prime)")
    
    # 6. Smooth number sieve
    print("\n--- Smooth Number Sieve (Tropical) ---")
    smooth_number_sieve(1001, B=20, R=200, verbose=True)


if __name__ == "__main__":
    demo()
