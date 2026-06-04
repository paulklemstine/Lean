#!/usr/bin/env python3
"""
Algorithms for Counterfactual Number Theory

Type-hinted implementations of the key algorithms used in the research.
"""

from typing import Set, List, Tuple, Dict, Optional
import math
import random


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Standard sieve of Eratosthenes.
    
    Returns list of primes up to n.
    Time: O(n log log n), Space: O(n)
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def generate_random_prime_analog(n: int, seed: Optional[int] = None) -> Set[int]:
    """Generate a random subset of {2,...,N} with density matching π(x)/x.
    
    Each integer k is included independently with probability 1/log(k),
    giving expected count ∑_{k=2}^{N} 1/log(k) ≈ N/log(N) = π(N).
    
    Args:
        n: Upper bound
        seed: Random seed for reproducibility
        
    Returns:
        Set of "random primes"
    """
    rng = random.Random(seed)
    return {k for k in range(2, n + 1) if rng.random() < 1.0 / math.log(k)}


def find_product_collisions(s: Set[int], max_product: int) -> List[Tuple[int, int, int]]:
    """Find all (a, b, a*b) with a, b, a*b ∈ S and a ≤ b.
    
    These are the "multiplicative collisions" that cause UFD collapse.
    
    Pseudocode:
        for each a in S (sorted):
            for each b in S with b >= a:
                if a * b > max_product: break
                if a * b in S: yield (a, b, a*b)
    
    Time: O(|S|² · lookup) where lookup is O(1) for hash sets
    """
    sorted_s = sorted(x for x in s if x >= 2)
    collisions: List[Tuple[int, int, int]] = []
    for i, a in enumerate(sorted_s):
        for b in sorted_s[i:]:
            product = a * b
            if product > max_product:
                break
            if product in s:
                collisions.append((a, b, product))
    return collisions


def is_product_free(s: Set[int], bound: int) -> bool:
    """Check whether S ∩ {2,...,bound} is product-free.
    
    A set is product-free if no product of two elements is in the set.
    The primes are product-free; random sets with prime-like density are not.
    
    Time: O(|S|²)
    """
    return len(find_product_collisions(s, bound)) == 0


def count_s_factorizations(n: int, s: Set[int]) -> int:
    """Count the number of ordered S-factorizations of n.
    
    An S-factorization is a list [a₁, ..., aₖ] with all aᵢ ∈ S, aᵢ ≥ 2,
    and ∏aᵢ = n. We count ordered factorizations (non-decreasing sequences)
    to get the multiset count.
    
    Uses dynamic programming with memoization.
    
    Pseudocode:
        def count(target, min_idx):
            if target == 1: return 1
            result = 0
            for each s_i in S with s_i >= S[min_idx] and s_i | target:
                result += count(target / s_i, i)
            return result
    
    Time: O(n · |S| · d(n)) where d(n) is the number of divisors
    """
    sorted_s = sorted(x for x in s if 2 <= x <= n)
    memo: Dict[Tuple[int, int], int] = {}
    
    def helper(target: int, min_idx: int) -> int:
        if target == 1:
            return 1
        key = (target, min_idx)
        if key in memo:
            return memo[key]
        total = 0
        for i in range(min_idx, len(sorted_s)):
            factor = sorted_s[i]
            if factor > target:
                break
            if target % factor == 0:
                total += helper(target // factor, i)
        memo[key] = total
        return total
    
    return helper(n, 0)


def factorization_entropy(n: int, s: Set[int]) -> float:
    """Compute the factorization entropy H_S(n) = log₂(#factorizations).
    
    For actual primes, H(n) = 0 for all n (unique factorization).
    For random sets, H(n) > 0 indicates non-unique factorization.
    """
    count = count_s_factorizations(n, s)
    return math.log2(count) if count > 0 else 0.0


def sumset(a: Set[int]) -> Set[int]:
    """Compute A + A = {x + y : x, y ∈ A}.
    
    Time: O(|A|²)
    """
    return {x + y for x in a for y in a}


def sumset_card_lower_bound(card_a: int) -> int:
    """Theoretical lower bound: |A + A| ≥ 2|A| - 1.
    
    This is tight for arithmetic progressions.
    """
    return max(2 * card_a - 1, 0)


def counting_function_error(s: Set[int], x: int) -> float:
    """Compute π_S(x) - x/log(x), the error in the PNT analog.
    
    For actual primes, RH predicts this is O(√x · log x).
    For random sets, CLT gives fluctuations ~√(x/log x).
    """
    pi_s_x = sum(1 for elem in s if elem <= x)
    return pi_s_x - x / math.log(x) if x >= 2 else 0.0


def rh_failure_metric(s: Set[int], x: int) -> float:
    """Normalized error: |π_S(x) - x/log(x)| / √(x/log(x)).
    
    Under RH for actual primes, this is O(√(log x)).
    For random sets, this is O(1) by CLT.
    """
    error = abs(counting_function_error(s, x))
    normalization = math.sqrt(x / math.log(x)) if x >= 3 else 1.0
    return error / normalization


if __name__ == "__main__":
    # Quick demo
    N = 1000
    primes = set(sieve_of_eratosthenes(N))
    random_set = generate_random_prime_analog(N, seed=42)
    
    print(f"N = {N}")
    print(f"Primes: {len(primes)}, Random: {len(random_set)}")
    print(f"Primes product-free: {is_product_free(primes, N)}")
    print(f"Random product-free: {is_product_free(random_set, N)}")
    
    collisions = find_product_collisions(random_set, N)
    print(f"Random collisions: {len(collisions)}")
    
    if collisions:
        a, b, c = collisions[0]
        print(f"Example: {a} × {b} = {c}, all in S → UFD collapse!")
        print(f"  Factorization 1: [{c}]")
        print(f"  Factorization 2: [{a}, {b}]")
