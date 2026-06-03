#!/usr/bin/env python3
"""
Algorithms for Counterfactual Number Theory.

Implements the core computational tools for studying generator sets,
product collisions, and the Cramér random model.
"""

import math
import random
from typing import Set, List, Tuple, Dict, Optional, FrozenSet
from collections import defaultdict
from dataclasses import dataclass


@dataclass
class ProductCollision:
    """A product collision: a*b = c*d with {a,b} != {c,d}."""
    a: int
    b: int
    c: int
    d: int
    product: int
    
    def __repr__(self) -> str:
        return f"{self.a}×{self.b} = {self.product} = {self.c}×{self.d}"


@dataclass 
class FactorizationAnalysis:
    """Complete analysis of a generator set."""
    generator_set: Set[int]
    has_pmi: bool
    pmi_violations: List[Tuple[int, int, int]]  # (a, b, a*b)
    collisions: List[ProductCollision]
    has_uf: bool  # True only if no violations AND no collisions
    factorization_dimension: int  # min removals to restore UF


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes returning all primes up to n.
    
    Time: O(n log log n), Space: O(n)
    """
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def check_pmi(S: Set[int]) -> Tuple[bool, List[Tuple[int, int, int]]]:
    """Check Pairwise Multiplicative Independence.
    
    Returns (is_pmi, violations) where violations is a list of (a, b, a*b)
    with a, b ∈ S, a*b ∈ S, a,b ≥ 2.
    
    Time: O(|S|²), Space: O(|S|)
    """
    violations: List[Tuple[int, int, int]] = []
    S_sorted = sorted(s for s in S if s >= 2)
    
    for i, a in enumerate(S_sorted):
        for b in S_sorted[i:]:
            if a * b in S:
                violations.append((a, b, a * b))
    
    return (len(violations) == 0, violations)


def find_collisions(
    S: Set[int], 
    max_product: Optional[int] = None
) -> List[ProductCollision]:
    """Find all product collisions in a generator set.
    
    A product collision is (a, b, c, d) with a*b = c*d and {a,b} ≠ {c,d}.
    
    Algorithm:
    1. Compute all products a*b for a,b ∈ S with a ≤ b
    2. Group by product value
    3. For each group, find distinct pairs
    
    Time: O(|S|² log |S|), Space: O(|S|²)
    """
    products: Dict[int, List[Tuple[int, int]]] = defaultdict(list)
    S_sorted = sorted(S)
    
    for i, a in enumerate(S_sorted):
        for j in range(i, len(S_sorted)):
            b = S_sorted[j]
            p = a * b
            if max_product and p > max_product:
                break
            products[p].append((a, b))
    
    collisions: List[ProductCollision] = []
    for p, pairs in products.items():
        for i in range(len(pairs)):
            for j in range(i + 1, len(pairs)):
                a, b = pairs[i]
                c, d = pairs[j]
                if sorted([a, b]) != sorted([c, d]):
                    collisions.append(ProductCollision(a, b, c, d, p))
    
    return collisions


def analyze_generator_set(
    S: Set[int], 
    max_product: Optional[int] = None
) -> FactorizationAnalysis:
    """Complete factorization analysis of a generator set.
    
    Determines PMI status, finds collisions, and estimates
    the factorization dimension (minimum removals for UF).
    """
    has_pmi, pmi_violations = check_pmi(S)
    collisions = find_collisions(S, max_product)
    has_uf = has_pmi and len(collisions) == 0
    
    # Estimate factorization dimension via greedy removal
    fdim = compute_factorization_dimension(S, max_product)
    
    return FactorizationAnalysis(
        generator_set=S,
        has_pmi=has_pmi,
        pmi_violations=pmi_violations,
        collisions=collisions,
        has_uf=has_uf,
        factorization_dimension=fdim
    )


def compute_factorization_dimension(
    S: Set[int],
    max_product: Optional[int] = None
) -> int:
    """Estimate factorization dimension via greedy algorithm.
    
    Repeatedly removes the element involved in the most
    UF violations (PMI violations + collisions) until UF holds.
    
    This is a heuristic upper bound on the true factorization dimension.
    
    Time: O(|S|³) worst case
    """
    current = set(S)
    removals = 0
    
    while True:
        has_pmi, pmi_v = check_pmi(current)
        collisions = find_collisions(current, max_product)
        
        if has_pmi and len(collisions) == 0:
            break
        
        # Count involvement of each element
        involvement: Dict[int, int] = defaultdict(int)
        for a, b, p in pmi_v:
            involvement[a] += 1
            involvement[b] += 1
            involvement[p] += 1
        for col in collisions:
            involvement[col.a] += 1
            involvement[col.b] += 1
            involvement[col.c] += 1
            involvement[col.d] += 1
        
        if not involvement:
            break
        
        # Remove the most involved element
        worst = max(involvement, key=involvement.get)
        current.discard(worst)
        removals += 1
    
    return removals


def cramer_random_set(N: int, C: float = 1.0) -> Set[int]:
    """Generate a random set in the Cramér model.
    
    Each integer n ∈ [2, N] is included independently with
    probability C / log(n).
    
    Expected size: C · N / log(N) (matches prime density when C=1).
    """
    S: Set[int] = set()
    for n in range(2, N + 1):
        if random.random() < C / math.log(n):
            S.add(n)
    return S


def collision_density_estimate(N: int, trials: int = 100) -> Dict[str, float]:
    """Estimate collision density in the Cramér model.
    
    Returns statistics about collisions across multiple trials.
    """
    collision_counts = []
    sizes = []
    pmi_violation_counts = []
    
    for _ in range(trials):
        S = cramer_random_set(N)
        sizes.append(len(S))
        
        _, pmi_v = check_pmi(S)
        pmi_violation_counts.append(len(pmi_v))
        
        collisions = find_collisions(S, max_product=N)
        collision_counts.append(len(collisions))
    
    log_N = math.log(N)
    avg_collisions = sum(collision_counts) / trials
    
    return {
        "N": N,
        "trials": trials,
        "avg_size": sum(sizes) / trials,
        "expected_size": N / log_N,
        "avg_collisions": avg_collisions,
        "max_collisions": max(collision_counts),
        "pct_with_collision": sum(1 for c in collision_counts if c > 0) / trials,
        "avg_pmi_violations": sum(pmi_violation_counts) / trials,
        "normalized_collisions": avg_collisions * log_N**3 / N,
    }


def maximal_pmi_subset_greedy(S: Set[int]) -> Set[int]:
    """Find a large PMI subset of S using a greedy algorithm.
    
    Strategy: Process elements in increasing order. Add element
    if it doesn't create a PMI violation with existing elements.
    
    Time: O(|S|² log |S|)
    """
    result: Set[int] = set()
    
    for s in sorted(S):
        if s < 2:
            continue
        # Check if s creates a violation
        violation = False
        for r in result:
            if r >= 2:
                if s * r in result or (s != r and r * s in result):
                    violation = True
                    break
                # Also check if s = a*b for some a, b in result
                # s is a potential product
        
        # Check if s is a product of two existing elements
        if not violation:
            for r in result:
                if r >= 2 and s % r == 0 and s // r in result and s // r >= 2:
                    violation = True
                    break
        
        if not violation:
            result.add(s)
    
    return result


def find_smallest_collision_set() -> Set[int]:
    """Find the smallest set (by max element) with PMI but not UF.
    
    Searches for 4-element sets {a, b, c, d} where:
    - PMI holds (no product of two is in the set)
    - a*b = c*d for some pairing (product collision exists)
    """
    for max_val in range(6, 100):
        for a in range(2, max_val):
            for b in range(a, max_val):
                p = a * b
                # Find other factorizations of p
                for c in range(a + 1, max_val):
                    if p % c == 0:
                        d = p // c
                        if d >= c and d < max_val:
                            S = {a, b, c, d}
                            if len(S) == 4:  # All distinct
                                has_pmi, _ = check_pmi(S)
                                if has_pmi:
                                    if sorted([a, b]) != sorted([c, d]):
                                        return S
    return set()


if __name__ == "__main__":
    print("=== Smallest PMI set without UF ===")
    smallest = find_smallest_collision_set()
    print(f"Found: {sorted(smallest)}")
    analysis = analyze_generator_set(smallest)
    print(f"PMI: {analysis.has_pmi}")
    print(f"Collisions: {analysis.collisions}")
    
    print("\n=== Prime analysis ===")
    P = set(sieve_primes(1000))
    analysis = analyze_generator_set(P, max_product=1000)
    print(f"Primes up to 1000: {len(P)} elements")
    print(f"PMI: {analysis.has_pmi}")
    print(f"Collisions: {len(analysis.collisions)}")
    print(f"Has UF: {analysis.has_uf}")
    
    print("\n=== Cramér model collision density ===")
    for N in [1000, 5000]:
        stats = collision_density_estimate(N, trials=30)
        print(f"N={N}: avg_collisions={stats['avg_collisions']:.1f}, "
              f"normalized={stats['normalized_collisions']:.2f}")
