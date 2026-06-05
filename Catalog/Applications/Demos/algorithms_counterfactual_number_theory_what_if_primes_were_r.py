#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for counterfactual number theory.

Type-hinted implementations of the key computational procedures
used to analyze pseudo-prime systems and their factorization properties.
"""
from typing import Set, List, Tuple, Dict, Optional, FrozenSet
from collections import defaultdict
import math
import random


def cramer_model(n: int, seed: int = 42) -> Set[int]:
    """Generate a Cramér random model up to n.

    Each integer k ≥ 2 is included independently with probability 1/ln(k),
    matching the density of actual primes predicted by the prime number theorem.

    Args:
        n: Upper bound for the model.
        seed: Random seed for reproducibility.

    Returns:
        Set of "pseudo-primes" in {2, ..., n}.
    """
    rng = random.Random(seed)
    return {k for k in range(2, n + 1) if rng.random() < 1.0 / math.log(k)}


def is_product_free(s: Set[int]) -> bool:
    """Check if s is product-free: no a*b ∈ s for a,b ∈ s with a,b ≥ 2.

    Time complexity: O(|s|²).
    """
    elems = sorted(x for x in s if x >= 2)
    for i, a in enumerate(elems):
        for b in elems[i:]:
            if a * b in s:
                return False
    return True


def find_absorptions(s: Set[int]) -> List[Tuple[int, Tuple[int, int]]]:
    """Find all generator absorptions: elements that are products of two others.

    Returns list of (element, (factor1, factor2)) tuples.
    """
    elems = sorted(x for x in s if x >= 2)
    absorptions = []
    for i, a in enumerate(elems):
        for b in elems[i:]:
            prod = a * b
            if prod in s:
                absorptions.append((prod, (a, b)))
    return absorptions


def find_product_collisions(
    s: Set[int], max_product: int = 100000
) -> Dict[int, List[Tuple[int, int]]]:
    """Find all product collisions in s.

    A product collision is a number n = a*b = c*d with {a,b} ≠ {c,d}
    and a,b,c,d all in s.

    Returns dict mapping product → list of factor pairs.
    """
    products: Dict[int, List[Tuple[int, int]]] = defaultdict(list)
    elems = sorted(x for x in s if x >= 2)
    for i, a in enumerate(elems):
        for b in elems[i:]:
            prod = a * b
            if prod <= max_product:
                products[prod].append((a, b))
    return {n: pairs for n, pairs in products.items() if len(pairs) >= 2}


def factorize(n: int, generators: Set[int]) -> List[Tuple[int, ...]]:
    """Find all factorizations of n using elements of generators.

    Returns list of sorted tuples representing each factorization.
    """
    gens = sorted(x for x in generators if x >= 2)
    if n == 1:
        return [()]
    results = []
    for g in gens:
        if g > n:
            break
        if n % g == 0:
            for rest in factorize(n // g, {x for x in generators if x >= g}):
                results.append((g,) + rest)
    return results


def collision_spectrum(
    s: Set[int], level: int, max_n: int = 10000
) -> Set[int]:
    """Compute the collision spectrum at a given level.

    Returns the set of numbers with ≥ 2 distinct factorizations of length exactly `level`.
    """
    spectrum = set()
    for n in range(2, max_n + 1):
        facts = factorize(n, s)
        level_facts = [f for f in facts if len(f) == level]
        if len(level_facts) >= 2:
            spectrum.add(n)
    return spectrum


def has_cross_level_collision(s: Set[int], max_n: int = 10000) -> Optional[Tuple[int, Tuple, Tuple]]:
    """Check for cross-level collisions: same number with factorizations of different lengths.

    Returns (n, fact1, fact2) if found, None otherwise.
    """
    for n in range(2, max_n + 1):
        facts = factorize(n, s)
        if len(facts) >= 2:
            lengths = {len(f) for f in facts}
            if len(lengths) >= 2:
                f1 = facts[0]
                f2 = next(f for f in facts if len(f) != len(f1))
                return (n, f1, f2)
    return None


def dirichlet_coverage(
    s: Set[int], q: int
) -> Dict[int, List[int]]:
    """Analyze coverage of residue classes mod q.

    Returns dict mapping residue class → list of elements in that class.
    """
    coverage: Dict[int, List[int]] = defaultdict(list)
    for x in sorted(s):
        coverage[x % q].append(x)
    return dict(coverage)


def factorization_hierarchy_classify(s: Set[int], max_n: int = 5000) -> Dict[str, bool]:
    """Classify a set in the four-level factorization hierarchy.

    Returns dict with keys: 'product_free', 'mult_independent', 'unique_factorization', 'pairwise_coprime'.
    """
    elems = sorted(x for x in s if x >= 2)

    # Product-free check
    pf = is_product_free(s)

    # Multiplicative independence check
    mi = len(find_absorptions(s)) == 0

    # Unique factorization check
    ufd = True
    for n in range(2, max_n + 1):
        if len(factorize(n, s)) > 1:
            ufd = False
            break

    # Pairwise coprime check
    coprime = all(
        math.gcd(elems[i], elems[j]) == 1
        for i in range(len(elems))
        for j in range(i + 1, len(elems))
    )

    return {
        'product_free': pf,
        'mult_independent': mi,
        'unique_factorization': ufd,
        'pairwise_coprime': coprime,
    }


def cramer_defect(s: Set[int], k: int, max_n: int = 10000) -> int:
    """Compute the Cramér defect at level k.

    The defect counts elements of s that can be written as a product
    of exactly k elements from s (each ≥ 2).
    """
    count = 0
    for n in s:
        if n < 2:
            continue
        facts = factorize(n, s)
        if any(len(f) == k for f in facts if f != (n,)):
            count += 1
    return count


if __name__ == "__main__":
    # Example usage
    primes_30 = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29}
    print("Primes up to 30:", factorization_hierarchy_classify(primes_30))

    sep_set = {6, 10, 21, 35}
    print("{6,10,21,35}:", factorization_hierarchy_classify(sep_set))

    cramer = cramer_model(100)
    print(f"Cramér model (N=100, |S|={len(cramer)}):", factorization_hierarchy_classify(cramer, 500))
