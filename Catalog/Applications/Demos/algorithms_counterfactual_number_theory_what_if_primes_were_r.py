#!/usr/bin/env python3
"""
Algorithms for Counterfactual Number Theory

Type-hinted implementations of the core algorithms from the research.
"""

from math import sqrt, log, gcd
from itertools import combinations_with_replacement
from collections import defaultdict
from typing import Optional


def is_product_free(S: set[int]) -> bool:
    """
    Check if a set S ⊆ ℕ is product-free.
    
    A set is product-free if for all a, b ∈ S with a, b ≥ 2,
    the product a*b ∉ S.
    
    Time: O(|S|²)
    """
    S_ge2 = {s for s in S if s >= 2}
    for a in S_ge2:
        for b in S_ge2:
            if a * b in S_ge2:
                return False
    return True


def check_multiplicative_independence(
    S: set[int], 
    max_card: int = 6
) -> tuple[bool, Optional[tuple[tuple[int, ...], tuple[int, ...]]]]:
    """
    Check if S is multiplicatively independent up to multisets of given max cardinality.
    
    S is MI if for all multisets m₁, m₂ over S: prod(m₁) = prod(m₂) → m₁ = m₂.
    
    Returns:
        (True, None) if MI up to max_card
        (False, (m₁, m₂)) if a counterexample is found
    
    Time: O(|S|^max_card) — exponential but exact for small sets
    """
    elements = sorted(s for s in S if s >= 2)
    if not elements:
        return True, None
    
    products: dict[int, list[tuple[int, ...]]] = defaultdict(list)
    for card in range(1, max_card + 1):
        for combo in combinations_with_replacement(elements, card):
            prod_val = 1
            for x in combo:
                prod_val *= x
            products[prod_val].append(combo)
    
    for prod_val, factorizations in products.items():
        if len(factorizations) > 1:
            return False, (factorizations[0], factorizations[1])
    
    return True, None


def collision_index(S: set[int]) -> int:
    """
    Compute the collision index of a finite set S.
    
    The collision index counts ordered pairs (a,b) ∈ S×S with a,b ≥ 2
    and a*b ∈ S. This measures how far S is from being prime-like.
    
    For actual primes: collision_index = 0
    For dense random sets: collision_index ~ |S|²/N
    
    Time: O(|S|²)
    """
    count = 0
    S_ge2 = {s for s in S if s >= 2}
    for a in S_ge2:
        for b in S_ge2:
            if a * b in S_ge2:
                count += 1
    return count


def factorization_spectrum(
    S: set[int], 
    n: int, 
    max_depth: int = 10
) -> list[tuple[int, ...]]:
    """
    Compute the factorization spectrum σ_S(n): all S-factorizations of n.
    
    An S-factorization of n is a sorted tuple (a₁, ..., aₖ) with each aᵢ ∈ S,
    aᵢ ≥ 2, and a₁ × ... × aₖ = n.
    
    Returns a list of sorted tuples (multisets as sorted tuples).
    
    For MI sets: len(result) ≤ 1 for all n
    For non-MI sets: len(result) can grow without bound
    
    Time: Exponential in log(n) / log(min(S))
    """
    elements = sorted(s for s in S if 2 <= s <= n)
    results: list[tuple[int, ...]] = []
    
    def search(remaining: int, min_elem: int, current: list[int]) -> None:
        if remaining == 1:
            results.append(tuple(current))
            return
        for e in elements:
            if e < min_elem:
                continue
            if e > remaining:
                break
            if remaining % e == 0 and len(current) < max_depth:
                current.append(e)
                search(remaining // e, e, current)
                current.pop()
    
    search(n, 2, [])
    return results


def find_product_triples(S: set[int]) -> list[tuple[int, int, int]]:
    """
    Find all product triples (a, b, c) in S with a*b = c, a,b ≥ 2.
    
    Product triples are the minimal obstruction to multiplicative independence.
    
    Time: O(|S|²)
    """
    triples: list[tuple[int, int, int]] = []
    S_ge2 = sorted(s for s in S if s >= 2)
    for a in S_ge2:
        for b in S_ge2:
            if b >= a and a * b in S:
                triples.append((a, b, a * b))
    return triples


def find_divisibility_chains(S: set[int], max_length: int = 10) -> list[list[int]]:
    """
    Find all maximal divisibility chains in S.
    
    A divisibility chain is a sequence a₁ | a₂ | ... | aₖ with all aᵢ ∈ S,
    aᵢ ≥ 2, and each aᵢ strictly dividing aᵢ₊₁.
    
    Time: O(|S|² × max_length)
    """
    elements = sorted(s for s in S if s >= 2)
    chains: list[list[int]] = []
    
    def extend_chain(chain: list[int]) -> None:
        last = chain[-1]
        extended = False
        for e in elements:
            if e > last and e % last == 0 and len(chain) < max_length:
                chain.append(e)
                extend_chain(chain)
                chain.pop()
                extended = True
        if not extended:
            if len(chain) >= 2:
                chains.append(list(chain))
    
    for e in elements:
        extend_chain([e])
    
    return chains


def cramer_random_model(N: int, seed: int = 42) -> set[int]:
    """
    Generate a Cramér random model: each n ∈ [2, N] is included
    independently with probability 1/ln(n).
    
    This models primes probabilistically: the Prime Number Theorem says
    π(N) ≈ N/ln(N), so each number has "probability" 1/ln(n) of being prime.
    """
    import random
    rng = random.Random(seed)
    S: set[int] = set()
    for n in range(2, N + 1):
        if rng.random() < 1.0 / log(n):
            S.add(n)
    return S


def compare_prime_vs_random(N: int, num_trials: int = 10) -> dict:
    """
    Compare actual primes with Cramér random models on key properties.
    
    For each property, reports the value for actual primes and the
    average over random trials.
    """
    # Actual primes
    primes: set[int] = set()
    for n in range(2, N + 1):
        if all(n % i != 0 for i in range(2, int(sqrt(n)) + 1)):
            primes.add(n)
    
    prime_stats = {
        "count": len(primes),
        "product_free": is_product_free(primes),
        "collision_index": collision_index(primes),
        "MI": check_multiplicative_independence(primes, max_card=3)[0],
    }
    
    # Random models
    random_stats: dict[str, list] = {
        "count": [], "product_free": [], "collision_index": [], "MI": []
    }
    for seed in range(num_trials):
        model = cramer_random_model(N, seed=seed)
        random_stats["count"].append(len(model))
        random_stats["product_free"].append(is_product_free(model))
        random_stats["collision_index"].append(collision_index(model))
        random_stats["MI"].append(check_multiplicative_independence(model, max_card=3)[0])
    
    return {
        "N": N,
        "primes": prime_stats,
        "random_avg": {
            "count": sum(random_stats["count"]) / num_trials,
            "product_free_rate": sum(random_stats["product_free"]) / num_trials,
            "avg_collision_index": sum(random_stats["collision_index"]) / num_trials,
            "MI_rate": sum(random_stats["MI"]) / num_trials,
        }
    }


if __name__ == "__main__":
    print("Comparing primes vs Cramér random models:")
    for N in [50, 100, 200]:
        result = compare_prime_vs_random(N, num_trials=20)
        print(f"\n  N = {N}:")
        print(f"    Primes: {result['primes']}")
        print(f"    Random: {result['random_avg']}")
