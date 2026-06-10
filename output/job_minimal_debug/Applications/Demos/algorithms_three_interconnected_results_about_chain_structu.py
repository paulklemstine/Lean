"""
Chain Invariants: Core Algorithms

Type-hinted implementations of the key algorithms used in the
Chain Invariants research on divisibility chains and the Anti-Escher property.
"""

from typing import List, Tuple, Optional, Dict, Set
from math import gcd, log2, prod
from functools import reduce


def prime_factorization(n: int) -> List[int]:
    """
    Compute the prime factorization of n as a sorted list of prime factors
    with multiplicity.
    
    Time complexity: O(√n)
    
    >>> prime_factorization(12)
    [2, 2, 3]
    >>> prime_factorization(1)
    []
    """
    if n <= 1:
        return []
    factors: List[int] = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def big_omega(n: int) -> int:
    """
    Compute Ω(n), the number of prime factors of n counted with multiplicity.
    
    Equivalent to the chain rank: the maximum length of a strictly ascending
    divisibility chain from 1 to n.
    
    Properties:
    - Ω(1) = 0
    - Ω(p) = 1 for prime p
    - Ω(p^k) = k
    - Ω(m*n) = Ω(m) + Ω(n) when gcd(m,n) = 1
    
    >>> big_omega(12)
    3
    >>> big_omega(1)
    0
    """
    return len(prime_factorization(n))


def sopfr(n: int) -> int:
    """
    Compute sopfr(n), the sum of prime factors with multiplicity.
    
    >>> sopfr(12)
    7
    >>> sopfr(30)
    10
    """
    return sum(prime_factorization(n))


def divisors_of(n: int) -> List[int]:
    """Return all divisors of n in sorted order."""
    divs: List[int] = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


def chain_rank(n: int) -> int:
    """
    Compute the chain rank of n: the maximum length of a strictly ascending
    divisibility chain from 1 to n.
    
    This is proven equal to Ω(n) = big_omega(n) in our Lean formalization.
    
    Algorithm: Direct dynamic programming on the divisor lattice.
    For each divisor d of n, compute the longest chain from 1 to d.
    
    Time complexity: O(d(n)²) where d(n) is the number of divisors.
    """
    divs = divisors_of(n)
    # dp[d] = length of longest chain from 1 to d
    dp: Dict[int, int] = {1: 0}
    
    for d in divs:
        if d == 1:
            continue
        best = 0
        for prev_d in divs:
            if prev_d < d and d % prev_d == 0 and prev_d in dp:
                best = max(best, dp[prev_d] + 1)
        dp[d] = best
    
    return dp.get(n, 0)


def chain_spectrum(chain: List[int]) -> List[int]:
    """
    Compute the chain spectrum: the sequence of quotient sizes along a chain.
    
    For a chain a₀ → a₁ → ... → aₖ, the spectrum is [a₁/a₀, a₂/a₁, ..., aₖ/aₖ₋₁].
    
    >>> chain_spectrum([1, 2, 4, 12])
    [2, 2, 3]
    """
    return [chain[i+1] // chain[i] for i in range(len(chain) - 1)]


def enumerate_maximal_chains(n: int) -> List[List[int]]:
    """
    Enumerate all maximal-length divisibility chains from 1 to n.
    
    A maximal chain has length Ω(n) + 1 (including endpoints).
    
    Returns:
        List of chains, each represented as a list of integers.
    """
    target_len = big_omega(n) + 1
    divs = divisors_of(n)
    
    results: List[List[int]] = []
    
    def dfs(current: int, chain: List[int]) -> None:
        if current == n:
            if len(chain) == target_len:
                results.append(chain[:])
            return
        if len(chain) >= target_len:
            return
        for d in divs:
            if d > current and d % current == 0:
                chain.append(d)
                dfs(d, chain)
                chain.pop()
    
    dfs(1, [1])
    return results


def verify_spectrum_sum_conjecture(n: int) -> Tuple[bool, int, int, int]:
    """
    Verify the spectrum sum minimality conjecture for a given n.
    
    Conjecture: For any maximal-length chain from 1 to n,
    spectrum_sum ≥ sopfr(n).
    
    Returns:
        (holds, sopfr_value, min_sum, max_sum)
    """
    chains = enumerate_maximal_chains(n)
    if not chains:
        return (True, sopfr(n), 0, 0)
    
    sums = [sum(chain_spectrum(c)) for c in chains]
    s = sopfr(n)
    return (min(sums) >= s, s, min(sums), max(sums))


def anti_escher_growth_bound(generators: List[int]) -> List[Tuple[int, int, bool]]:
    """
    Verify the Anti-Escher exponential growth bound for a chain of generators.
    
    For a strictly descending chain of principal ideals in ℤ with generators
    a₀, a₁, ..., the absolute values must satisfy |aₙ| ≥ 2ⁿ · |a₀|.
    
    Returns:
        List of (actual_value, lower_bound, satisfies_bound) triples.
    """
    if not generators:
        return []
    
    a0 = abs(generators[0])
    results: List[Tuple[int, int, bool]] = []
    
    for i, g in enumerate(generators):
        lower_bound = (2 ** i) * a0
        actual = abs(g)
        results.append((actual, lower_bound, actual >= lower_bound))
    
    return results


def chain_defect_simulation(
    chain_fn: callable,
    max_steps: int = 1000
) -> Optional[int]:
    """
    Simulate finding the chain defect (stabilization index) of a monotone chain.
    
    Args:
        chain_fn: Function from ℕ to sets (represented as frozensets).
        max_steps: Maximum number of steps to check.
    
    Returns:
        The chain defect (stabilization index), or None if not found within max_steps.
    """
    for n in range(max_steps):
        if chain_fn(n) == chain_fn(n + 1):
            # Check if it stays stable
            stable = True
            for k in range(n + 1, min(n + 10, max_steps)):
                if chain_fn(k) != chain_fn(n):
                    stable = False
                    break
            if stable:
                return n
    return None


if __name__ == "__main__":
    # Verify chain_rank equals big_omega for small values
    print("Verifying chain_rank(n) = Ω(n) for n = 1..100:")
    all_match = True
    for n in range(1, 101):
        cr = chain_rank(n)
        bo = big_omega(n)
        if cr != bo:
            print(f"  MISMATCH at n={n}: chain_rank={cr}, Ω={bo}")
            all_match = False
    if all_match:
        print("  All match ✓")
    
    # Verify spectrum sum conjecture
    print("\nVerifying spectrum sum conjecture for n = 2..100:")
    all_hold = True
    for n in range(2, 101):
        holds, s, min_s, max_s = verify_spectrum_sum_conjecture(n)
        if not holds:
            print(f"  COUNTEREXAMPLE at n={n}: sopfr={s}, min_sum={min_s}")
            all_hold = False
    if all_hold:
        print("  Conjecture holds for all tested values ✓")
