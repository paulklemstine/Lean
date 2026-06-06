#!/usr/bin/env python3
"""
Algorithms for Counterfactual Number Theory

Type-hinted implementations of core algorithms from the research.
"""

import math
import random
from typing import Optional


def cramer_random_set(n: int, seed: int = 42) -> set[int]:
    """
    Generate a Cramér random prime model: each integer k in [2, n]
    is included with probability 1/log(k).

    This is the standard probabilistic model for studying what properties
    of the primes are "generic" (hold for any set of this density) versus
    "special" (require the specific multiplicative structure of primes).

    Args:
        n: Upper bound for the set
        seed: Random seed for reproducibility

    Returns:
        A random subset of [2, n] with approximately n/log(n) elements
    """
    rng = random.Random(seed)
    return {k for k in range(2, n + 1) if rng.random() < 1.0 / math.log(k)}


def is_product_free(s: set[int]) -> tuple[bool, Optional[tuple[int, int, int]]]:
    """
    Check whether a set S ⊆ ℕ is product-free.

    A set is product-free if for all a, b ∈ S, a·b ∉ S.
    This is the key structural property that separates primes from
    generic dense subsets of ℕ.

    Complexity: O(|S|² log(max(S))) using hash set lookup.

    Args:
        s: A finite set of positive integers

    Returns:
        (True, None) if product-free, (False, (a, b, a*b)) otherwise
    """
    sorted_s = sorted(s)
    max_val = max(s) if s else 0
    for i, a in enumerate(sorted_s):
        for b in sorted_s[i:]:
            prod = a * b
            if prod > max_val:
                break
            if prod in s:
                return False, (a, b, prod)
    return True, None


def s_factorizations(s: set[int], n: int, max_depth: int = 20) -> list[tuple[int, ...]]:
    """
    Enumerate all S-factorizations of n: multisets of elements from S
    whose product equals n.

    This is the core operation for studying unique factorization in
    counterfactual number theories. For primes, each n has exactly
    one factorization. For generic dense sets, the count explodes.

    Args:
        s: Generator set (elements ≥ 2)
        n: Number to factorize
        max_depth: Maximum number of factors to prevent infinite recursion

    Returns:
        List of factorizations, each as a sorted tuple
    """
    candidates = sorted(x for x in s if 2 <= x <= n)
    results: list[tuple[int, ...]] = []

    def backtrack(remaining: int, min_factor: int, current: list[int]) -> None:
        if remaining == 1:
            results.append(tuple(current))
            return
        if len(current) >= max_depth:
            return
        for c in candidates:
            if c < min_factor:
                continue
            if c > remaining:
                break
            if remaining % c == 0:
                backtrack(remaining // c, c, current + [c])

    backtrack(n, 2, [])
    return results


def factorization_count_ratio(s: set[int], n_range: int) -> dict[int, int]:
    """
    For each number up to n_range, count how many S-factorizations it has.

    Returns a histogram: {count: how_many_numbers_have_that_count}
    """
    histogram: dict[int, int] = {}
    for n in range(2, n_range + 1):
        count = len(s_factorizations(s, n))
        histogram[count] = histogram.get(count, 0) + 1
    return histogram


def product_free_density_bound(n: int, trials: int = 100) -> float:
    """
    Estimate the maximum density (as fraction of n/log(n)) achievable
    by a product-free subset of [2, n], using random search.

    This explores the tension between density and product-freeness:
    the primes achieve density factor ~1.0 while being product-free,
    which our theorems show is exceptional.

    Args:
        n: Upper bound
        trials: Number of random trials

    Returns:
        Best density factor found (relative to n/log(n))
    """
    target_density = n / math.log(n) if n > 1 else 1
    best_ratio = 0.0

    for trial in range(trials):
        rng = random.Random(trial)
        # Start with all elements, greedily remove collisions
        elements = list(range(2, n + 1))
        rng.shuffle(elements)
        s: set[int] = set()
        for x in elements:
            # Add x if it doesn't create a collision
            can_add = True
            for a in s:
                if a * x in s or x * a in s:
                    can_add = False
                    break
                # Also check if x completes a collision: ∃ b ∈ S with b*x ∈ S
                for b in s:
                    if b * x == a or x * b == a:
                        can_add = False
                        break
                if not can_add:
                    break
            if can_add:
                s.add(x)

        ratio = len(s) / target_density if target_density > 0 else 0
        best_ratio = max(best_ratio, ratio)

    return best_ratio


def collision_probability(n: int, density_factor: float = 1.0,
                          trials: int = 1000) -> float:
    """
    Estimate the probability that a random subset of [2, n] with
    density ~ density_factor / log(k) contains a multiplicative collision.

    Args:
        n: Upper bound
        density_factor: Multiplier for the base density 1/log(k)
        trials: Number of Monte Carlo trials

    Returns:
        Estimated probability of containing at least one collision
    """
    collisions = 0
    for trial in range(trials):
        rng = random.Random(trial)
        s = {k for k in range(2, n + 1)
             if rng.random() < density_factor / math.log(k)}
        is_free, _ = is_product_free(s)
        if not is_free:
            collisions += 1
    return collisions / trials


if __name__ == "__main__":
    # Quick demonstration
    print("=== Cramér Random Set ===")
    S = cramer_random_set(100)
    print(f"Random set up to 100: {sorted(S)}")
    print(f"Size: {len(S)}, expected ~100/log(100) ≈ {100/math.log(100):.1f}")

    free, counter = is_product_free(S)
    print(f"Product-free: {free}")
    if counter:
        print(f"  Collision: {counter[0]} × {counter[1]} = {counter[2]}")

    print()
    print("=== Factorizations of 12 ===")
    for label, gen_set in [("Primes", {2, 3, 5, 7, 11}),
                            ("Primes ∪ {6}", {2, 3, 5, 6, 7, 11}),
                            ("[2,12]", set(range(2, 13)))]:
        facts = s_factorizations(gen_set, 12)
        print(f"  {label}: {len(facts)} factorization(s)")
        for f in facts:
            print(f"    {'×'.join(map(str, f))}")
