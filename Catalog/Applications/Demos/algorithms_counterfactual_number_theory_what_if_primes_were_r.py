#!/usr/bin/env python3
"""
Algorithms for Counterfactual Number Theory.

Provides type-hinted implementations of the core algorithms used in
the Cramér random model analysis.
"""

import math
import random
from typing import Optional
from collections import defaultdict


def cramer_model(N: int, seed: Optional[int] = None) -> set[int]:
    """Generate a Cramér random model up to N.
    
    Each integer n ∈ {2, ..., N} is included independently with
    probability 1/ln(n), matching the asymptotic density of primes.
    
    Args:
        N: Upper bound for the model
        seed: Random seed for reproducibility
    
    Returns:
        Set of "pseudo-primes" in {2, ..., N}
    """
    rng = random.Random(seed)
    return {n for n in range(2, N + 1) if rng.random() < 1.0 / math.log(n)}


def check_product_free(S: set[int]) -> tuple[bool, Optional[tuple[int, int, int]]]:
    """Check if S is product-free and return a witness if not.
    
    Args:
        S: Set of positive integers
    
    Returns:
        (True, None) if product-free, or (False, (a, b, a*b)) witness
    """
    elems = sorted(s for s in S if s >= 2)
    for i, a in enumerate(elems):
        for b in elems[i:]:
            if a * b in S:
                return False, (a, b, a * b)
    return True, None


def compute_cramer_defect(S: set[int], k: int, max_n: int = 10000) -> int:
    """Compute the Cramér defect at level k.
    
    The defect counts elements of S that are products of k elements of S.
    
    Args:
        S: The pseudo-prime set
        k: Product arity (k ≥ 2)
        max_n: Maximum product to consider
    
    Returns:
        Number of defect elements
    """
    if k < 2:
        return 0
    
    elems = sorted(s for s in S if s >= 2)
    defects: set[int] = set()
    
    def find_products(remaining: int, current_product: int, start_idx: int) -> None:
        if remaining == 0:
            if current_product in S:
                defects.add(current_product)
            return
        for i in range(start_idx, len(elems)):
            new_prod = current_product * elems[i]
            if new_prod > max_n:
                break
            find_products(remaining - 1, new_prod, i)
    
    find_products(k, 1, 0)
    return len(defects)


def find_all_factorizations(
    S: set[int], n: int, max_factors: int = 10
) -> list[list[int]]:
    """Find all S-factorizations of n.
    
    An S-factorization is a multiset of elements from S (each ≥ 2)
    whose product is n.
    
    Args:
        S: The pseudo-prime set
        n: Number to factorize
        max_factors: Maximum number of factors to consider
    
    Returns:
        List of factorizations (each a sorted list)
    """
    elems = sorted(s for s in S if s >= 2 and s <= n)
    results: list[list[int]] = []
    
    def search(remaining: int, min_factor: int, current: list[int]) -> None:
        if remaining == 1:
            if 1 in S:  # shouldn't happen for valid pseudo-prime systems
                return
            return
        if remaining in S and remaining >= min_factor:
            results.append(current + [remaining])
        if len(current) >= max_factors:
            return
        for e in elems:
            if e < min_factor:
                continue
            if e > remaining:
                break
            if remaining % e == 0:
                search(remaining // e, e, current + [e])
    
    search(n, 2, [])
    return results


def residue_class_coverage(S: set[int], q: int) -> dict[int, list[int]]:
    """Compute which elements of S fall in each residue class mod q.
    
    Args:
        S: Set of integers
        q: Modulus
    
    Returns:
        Dictionary mapping residue r → list of elements x ∈ S with x % q = r
    """
    coverage: dict[int, list[int]] = defaultdict(list)
    for x in sorted(S):
        coverage[x % q].append(x)
    return dict(coverage)


def estimate_product_free_probability(
    N: int, trials: int = 1000, seed: int = 42
) -> float:
    """Estimate the probability that a Cramér model up to N is product-free.
    
    Args:
        N: Upper bound for the model
        trials: Number of random trials
        seed: Base random seed
    
    Returns:
        Estimated probability
    """
    count = sum(
        1 for s in range(trials)
        if check_product_free(cramer_model(N, seed=seed + s))[0]
    )
    return count / trials


def k_product_free_level(S: set[int], max_k: int = 10, max_n: int = 50000) -> int:
    """Find the largest k for which S is k-product-free.
    
    Args:
        S: The pseudo-prime set
        max_k: Maximum k to test
        max_n: Maximum product to consider
    
    Returns:
        Largest k such that S is k-product-free (0 if not even 2-product-free)
    """
    for k in range(2, max_k + 1):
        if compute_cramer_defect(S, k, max_n) > 0:
            return k - 1
    return max_k


if __name__ == "__main__":
    # Quick demonstration
    N = 200
    S = cramer_model(N, seed=42)
    print(f"Cramér model up to {N}: {len(S)} elements")
    
    pf, witness = check_product_free(S)
    print(f"Product-free: {pf}")
    if witness:
        print(f"  Witness: {witness[0]} × {witness[1]} = {witness[2]}")
    
    for k in range(2, 5):
        d = compute_cramer_defect(S, k)
        print(f"  Cramér defect at level {k}: {d}")
    
    # Counterexample
    S_counter = {4, 6, 9}
    print(f"\nCounterexample S = {S_counter}")
    print(f"  Product-free: {check_product_free(S_counter)}")
    print(f"  Factorizations of 36: {find_all_factorizations(S_counter, 36)}")
