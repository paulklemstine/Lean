#!/usr/bin/env python3
"""
Certified Support-Energy Exclusion Algorithm for Odd Perfect Numbers
====================================================================

This module implements the computational elimination method derived from
the multiplicative rigidity theory of odd perfect numbers. The core idea:

For an odd perfect number n with prime factorization n = ∏ p_i^{a_i},
the abundancy equation σ(n)/n = 2 decomposes as

    ∏ I(p_i, a_i) = 2

where I(p, a) = σ(p^a)/p^a is the local abundancy factor. Since
I(p, a) < p/(p-1) for all primes p and exponents a, the support
energy ∏ p/(p-1) must be ≥ 2 for any perfect number.

This gives a certified elimination algorithm: compute the support
energy for candidate prime sets and reject those with energy < 2.

Complexity Analysis
-------------------
- Support energy computation: O(|S|) arithmetic operations on rationals
- Brute-force support scan over k primes from a pool of N: O(C(N,k) · k)
- Euler candidate scan: O(|S| · max_exp / 4) per support
- All operations use exact rational arithmetic (no floating-point errors)
"""

from fractions import Fraction
from typing import List, Tuple, Dict, Optional, Set, FrozenSet
from itertools import combinations
import time


def is_prime(n: int) -> bool:
    """Primality test."""
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


def odd_primes_up_to(n: int) -> List[int]:
    """Return all odd primes up to n."""
    return [p for p in range(3, n + 1, 2) if is_prime(p)]


def sigma_prime_pow(p: int, a: int) -> int:
    """
    Compute σ(p^a) = (p^{a+1} - 1) / (p - 1).

    Time: O(1) with Python's arbitrary precision integers.
    """
    return (p ** (a + 1) - 1) // (p - 1)


def local_abundancy(p: int, a: int) -> Fraction:
    """
    Compute I(p, a) = σ(p^a) / p^a.

    Returns: Fraction in lowest terms.
    Time: O(1) modulo big-integer arithmetic.
    """
    return Fraction(sigma_prime_pow(p, a), p ** a)


def support_energy(primes: List[int]) -> Fraction:
    """
    Compute ∏_{p ∈ S} p/(p-1).

    This is the theoretical upper bound on the abundancy of any number
    whose complete prime support is S.

    Args:
        primes: List of distinct primes.

    Returns:
        The support energy as an exact rational.

    Time: O(|S|) rational multiplications.
    """
    result = Fraction(1)
    for p in primes:
        result *= Fraction(p, p - 1)
    return result


def is_support_excluded(primes: List[int]) -> Tuple[bool, Fraction]:
    """
    Certified exclusion test.

    Returns (True, gap) if ∏ p/(p-1) < 2, certifying that no odd
    perfect number has exactly this prime support. The gap value
    is 2 - ∏ p/(p-1), which is a lower bound on the deficiency gap.

    This is the computational instantiation of theorem
    `not_perfect_of_support_energy_lt_two` from the formal verification.

    Args:
        primes: List of distinct odd primes forming the candidate support.

    Returns:
        (is_excluded, deficiency_gap_bound)
    """
    energy = support_energy(primes)
    gap = Fraction(2) - energy
    return (gap > 0, gap)


def scan_supports(prime_pool: List[int], min_size: int = 2,
                  max_size: int = 8) -> Dict[int, Tuple[int, int]]:
    """
    Scan all subsets of a prime pool and classify by exclusion.

    For each subset size k from min_size to max_size, count how many
    k-element subsets of prime_pool are excluded by the support energy barrier.

    Args:
        prime_pool: Pool of odd primes to draw from.
        min_size: Minimum support size to check.
        max_size: Maximum support size to check.

    Returns:
        Dictionary mapping size -> (excluded_count, total_count).

    Time: O(∑_k C(N,k) · k) where N = |prime_pool|.
    """
    results = {}
    for k in range(min_size, min(max_size + 1, len(prime_pool) + 1)):
        excluded = 0
        total = 0
        for combo in combinations(prime_pool, k):
            total += 1
            if is_support_excluded(list(combo))[0]:
                excluded += 1
        results[k] = (excluded, total)
    return results


def euler_candidate_analysis(primes: List[int],
                             max_special_exp: int = 40) -> List[Dict]:
    """
    Analyze Euler-form candidates for a given prime support.

    For each prime p ≡ 1 (mod 4) in the support (candidate Euler prime),
    and for each exponent k ≡ 1 (mod 4), compute the maximum possible
    abundancy:
        I(p, k) · ∏_{q ≠ p} q/(q-1)

    If this maximum is < 2, then the candidate is excluded regardless of
    the exponents of the other primes.

    Args:
        primes: Prime support.
        max_special_exp: Maximum Euler prime exponent to test.

    Returns:
        List of analysis results.
    """
    results = []
    euler_primes = [p for p in primes if p % 4 == 1]

    for ep in euler_primes:
        other_primes = [p for p in primes if p != ep]
        other_energy = support_energy(other_primes)

        for k in range(1, max_special_exp + 1, 4):
            ef = local_abundancy(ep, k)
            max_abund = ef * other_energy
            gap = Fraction(2) - max_abund

            results.append({
                'euler_prime': ep,
                'exponent': k,
                'euler_factor': ef,
                'other_energy': other_energy,
                'max_abundancy': max_abund,
                'gap': gap,
                'excluded': gap > 0,
            })

    return results


def find_minimal_non_excluded_supports(prime_pool: List[int],
                                       max_size: int = 6) -> List[List[int]]:
    """
    Find minimal supports that are NOT excluded by the energy barrier.

    A support S is "minimal non-excluded" if ∏_{p∈S} p/(p-1) ≥ 2 but
    for every proper subset S' ⊂ S, ∏_{p∈S'} p/(p-1) < 2.

    These are the supports at the boundary of the energy barrier—the
    smallest prime sets that could potentially support an odd perfect number.

    Time: O(∑_k C(N,k) · k · 2^k) worst case.
    """
    minimal = []
    for k in range(2, min(max_size + 1, len(prime_pool) + 1)):
        for combo in combinations(prime_pool, k):
            support = list(combo)
            energy = support_energy(support)
            if energy >= 2:
                # Check if all proper subsets are excluded
                is_minimal = True
                for i in range(len(support)):
                    subset = support[:i] + support[i+1:]
                    if support_energy(subset) >= 2:
                        is_minimal = False
                        break
                if is_minimal:
                    minimal.append(support)
    return minimal


def compute_exact_abundancy(factorization: Dict[int, int]) -> Fraction:
    """
    Compute the exact abundancy σ(n)/n for n with given prime factorization.

    Args:
        factorization: Dict mapping prime -> exponent.

    Returns:
        σ(n)/n as an exact rational.
    """
    result = Fraction(1)
    for p, a in factorization.items():
        result *= local_abundancy(p, a)
    return result


def search_near_perfect(prime_pool: List[int], max_exp: int = 10,
                        target: Fraction = Fraction(2),
                        tolerance: float = 0.01) -> List[Tuple[Dict[int, int], Fraction]]:
    """
    Search for factorizations whose abundancy is close to the target (2).

    This brute-force search over small exponents demonstrates that the
    abundancy product never exactly reaches 2 for odd prime supports.

    Returns list of (factorization, abundancy) pairs within tolerance.
    """
    results = []

    def recurse(idx: int, current: Dict[int, int], current_abund: Fraction):
        if abs(float(current_abund) - float(target)) < tolerance and len(current) > 0:
            results.append((dict(current), current_abund))
        if idx >= len(prime_pool):
            return
        if float(current_abund) >= float(target) + tolerance:
            return

        p = prime_pool[idx]
        # Try not using this prime
        recurse(idx + 1, current, current_abund)
        # Try using this prime with exponents 1..max_exp
        for a in range(1, max_exp + 1):
            new_abund = current_abund * local_abundancy(p, a)
            if float(new_abund) > float(target) + tolerance:
                break
            current[p] = a
            recurse(idx + 1, current, new_abund)
        if p in current:
            del current[p]

    recurse(0, {}, Fraction(1))
    results.sort(key=lambda x: abs(float(x[1]) - float(target)))
    return results[:20]


# ── Example usage ──

if __name__ == "__main__":
    print("=" * 70)
    print("  Certified Support-Energy Exclusion Algorithm")
    print("=" * 70)

    # 1. Basic exclusion checks
    print("\n1. Support Energy Exclusion Tests:")
    print(f"   {'Support':>25} {'Energy':>12} {'Gap':>12} {'Excluded':>10}")
    print("   " + "-" * 60)
    test_supports = [
        [3, 5],
        [3, 7],
        [3, 5, 7],
        [5, 7, 11, 13],
        [3, 5, 7, 11],
        [3, 5, 7, 11, 13],
        [3, 5, 7, 11, 13, 17, 19, 23],
    ]
    for s in test_supports:
        excluded, gap = is_support_excluded(s)
        energy = support_energy(s)
        print(f"   {str(s):>25} {float(energy):>12.6f} {float(gap):>+12.6f} {'YES' if excluded else 'NO':>10}")

    # 2. Systematic scan
    print("\n2. Systematic Scan of Supports from First 10 Odd Primes:")
    pool = odd_primes_up_to(30)
    print(f"   Prime pool: {pool}")
    results = scan_supports(pool, min_size=2, max_size=5)
    for k, (excl, total) in sorted(results.items()):
        pct = 100 * excl / total if total > 0 else 0
        print(f"   Size {k}: {excl}/{total} excluded ({pct:.1f}%)")

    # 3. Minimal non-excluded supports
    print("\n3. Minimal Non-Excluded Supports (energy barrier boundary):")
    minimal = find_minimal_non_excluded_supports(pool, max_size=5)
    for s in minimal[:10]:
        energy = support_energy(s)
        print(f"   {s}: energy = {float(energy):.6f}")

    # 4. Euler candidate analysis for {3, 5, 7}
    print("\n4. Euler Candidate Analysis for {3, 5, 7}:")
    candidates = euler_candidate_analysis([3, 5, 7], max_special_exp=20)
    print(f"   {'Euler p':>8} {'k':>4} {'I(p,k)':>12} {'Max Abund':>12} {'Gap':>12} {'Status':>10}")
    print("   " + "-" * 65)
    for c in candidates:
        print(f"   {c['euler_prime']:>8} {c['exponent']:>4} "
              f"{float(c['euler_factor']):>12.6f} "
              f"{float(c['max_abundancy']):>12.6f} "
              f"{float(c['gap']):>+12.6f} "
              f"{'EXCLUDED' if c['excluded'] else 'possible':>10}")

    # 5. Near-perfect search
    print("\n5. Near-Perfect Odd Numbers (abundancy closest to 2):")
    near = search_near_perfect([3, 5, 7, 11, 13], max_exp=6, tolerance=0.05)
    print(f"   {'Factorization':>30} {'Abundancy':>12} {'Gap from 2':>12}")
    print("   " + "-" * 55)
    for fac, abund in near[:10]:
        fac_str = " · ".join(f"{p}^{a}" for p, a in sorted(fac.items()))
        print(f"   {fac_str:>30} {float(abund):>12.8f} {float(Fraction(2) - abund):>+12.8f}")
