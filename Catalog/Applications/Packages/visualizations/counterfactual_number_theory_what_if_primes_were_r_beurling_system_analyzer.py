#!/usr/bin/env python3
"""
Algorithms for Counterfactual Number Theory

Type-hinted implementations of key algorithms for analyzing
Beurling generalized prime systems.
"""

from typing import List, Set, Tuple, Optional, Dict
import math
import random


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes returning all primes up to n.
    
    Args:
        n: Upper bound
    Returns:
        Sorted list of primes in [2, n]
    """
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def random_beurling_generators(n: int, seed: int = 42) -> List[int]:
    """Generate a random subset of {2,...,n} with prime-like density.
    
    Each k ∈ {2,...,n} is included independently with probability 1/log(k).
    
    Args:
        n: Upper bound for generators
        seed: Random seed for reproducibility
    Returns:
        Sorted list of selected generators
    """
    rng = random.Random(seed)
    gens: List[int] = []
    for k in range(2, n + 1):
        prob = 1.0 / max(math.log(k), 0.01)
        if rng.random() < min(prob, 1.0):
            gens.append(k)
    return gens


def find_product_collisions(generators: List[int]) -> List[Tuple[int, int, int]]:
    """Find all triple collisions (a, b, a*b) in a generator set.
    
    A triple collision is a triple (a, b, c) where a, b, c are all generators
    and a * b = c. These are certificates that unique factorization fails.
    
    Args:
        generators: List of generators (elements ≥ 2)
    Returns:
        List of (a, b, c) triples with a*b = c, all in generators
    """
    gen_set: Set[int] = set(generators)
    collisions: List[Tuple[int, int, int]] = []
    for a in generators:
        for b in generators:
            if a <= b and a * b in gen_set:
                collisions.append((a, b, a * b))
    return collisions


def is_product_free(generators: List[int]) -> bool:
    """Check if a generator set is product-free.
    
    A set S is product-free if for all a, b ∈ S, a*b ∉ S.
    Product-freeness is necessary for unique factorization.
    
    Args:
        generators: List of generators
    Returns:
        True if the set is product-free
    """
    gen_set: Set[int] = set(generators)
    for a in generators:
        for b in generators:
            if a * b in gen_set:
                return False
    return True


def is_prime_separated(generators: List[int]) -> bool:
    """Check if a generator set is prime-separated (no generator divides another).
    
    Args:
        generators: List of generators
    Returns:
        True if no generator properly divides another
    """
    for a in generators:
        for b in generators:
            if a != b and b % a == 0:
                return False
    return True


def collision_density(n: int, trials: int = 1000) -> float:
    """Estimate the probability that a random Beurling system has collisions.
    
    Generates `trials` random generator sets with prime-like density up to n,
    and returns the fraction that have at least one product collision.
    
    Args:
        n: Upper bound for generators
        trials: Number of Monte Carlo trials
    Returns:
        Estimated probability of collision
    """
    collision_count = 0
    for seed in range(trials):
        gens = random_beurling_generators(n, seed=seed)
        if not is_product_free(gens):
            collision_count += 1
    return collision_count / trials


def beurling_integers(generators: List[int], bound: int) -> List[int]:
    """Enumerate Beurling integers up to a bound.
    
    Returns all products of multisets of generators that are ≤ bound,
    plus 1.
    
    Args:
        generators: List of generators (≥ 2)
        bound: Upper bound for enumeration
    Returns:
        Sorted list of Beurling integers in [1, bound]
    """
    result: Set[int] = {1}
    # BFS-style enumeration
    frontier: Set[int] = {1}
    while frontier:
        new_frontier: Set[int] = set()
        for n in frontier:
            for g in generators:
                prod = n * g
                if prod <= bound and prod not in result:
                    result.add(prod)
                    new_frontier.add(prod)
        frontier = new_frontier
    return sorted(result)


def factorization_count(n: int, generators: List[int]) -> int:
    """Count the number of distinct factorizations of n over a generator set.
    
    Uses dynamic programming. A factorization is an ordered sequence
    of generators whose product is n (we count unordered by using
    the constraint that factors are non-decreasing).
    
    Args:
        n: Target number
        generators: List of generators
    Returns:
        Number of distinct unordered factorizations
    """
    gens = sorted(generators)
    memo: Dict[Tuple[int, int], int] = {}
    
    def count(target: int, min_gen_idx: int) -> int:
        if target == 1:
            return 1
        if (target, min_gen_idx) in memo:
            return memo[(target, min_gen_idx)]
        
        total = 0
        for i in range(min_gen_idx, len(gens)):
            g = gens[i]
            if g > target:
                break
            if target % g == 0:
                total += count(target // g, i)
        
        memo[(target, min_gen_idx)] = total
        return total
    
    return count(n, 0)


def contamination_cascade(primes: List[int], composite: int) -> Dict[str, object]:
    """Analyze what happens when a composite is added to a prime generator set.
    
    Args:
        primes: List of prime generators
        composite: Composite number to add
    Returns:
        Dictionary with analysis results
    """
    contaminated = sorted(set(primes + [composite]))
    collisions = find_product_collisions(contaminated)
    
    return {
        "original_size": len(primes),
        "contaminated_size": len(contaminated),
        "composite_added": composite,
        "product_free_before": True,  # Primes are always product-free
        "product_free_after": is_product_free(contaminated),
        "num_collisions": len(collisions),
        "collisions": collisions[:10],
    }


if __name__ == "__main__":
    # Quick self-test
    primes = sieve_primes(100)
    print(f"Primes up to 100: {len(primes)} primes")
    print(f"Product-free: {is_product_free(primes)}")
    
    gens = random_beurling_generators(100, seed=0)
    print(f"\nRandom generators up to 100: {len(gens)} generators")
    print(f"Product-free: {is_product_free(gens)}")
    print(f"Collisions: {find_product_collisions(gens)[:5]}")
    
    print(f"\nCollision density (n=100): {collision_density(100):.2%}")
    
    # Factorization count demo
    gens_236 = [2, 3, 6]
    print(f"\nFactorizations of 12 over {{2,3,6}}: {factorization_count(12, gens_236)}")
    print(f"  (12 = 6*2 = 2*2*3 → at least 2 factorizations)")
