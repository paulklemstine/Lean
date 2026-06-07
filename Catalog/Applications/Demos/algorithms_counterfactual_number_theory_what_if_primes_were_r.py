#!/usr/bin/env python3
"""
Algorithms for Counterfactual Number Theory

Type-hinted implementations of the core algorithms for analyzing
generator sets and their factorization properties.
"""

from collections import defaultdict
from math import gcd, log, sqrt
from typing import FrozenSet, List, Optional, Set, Tuple, Dict


# ============================================================
# Core Data Structures
# ============================================================

Multiset = Tuple[int, ...]  # sorted tuple representing a multiset
GeneratorSet = Set[int]


def normalize_multiset(elements: List[int]) -> Multiset:
    """Convert a list to a canonical multiset representation (sorted tuple)."""
    return tuple(sorted(elements))


# ============================================================
# Algorithm 1: Product-Freeness Test
# ============================================================

def is_product_free(S: GeneratorSet) -> Tuple[bool, Optional[Tuple[int, int, int]]]:
    """
    Test whether S is product-free.

    Returns (True, None) if product-free, or (False, (a, b, a*b))
    witnessing the violation.

    Time complexity: O(|S|^2 * lookup)
    """
    S2 = {x for x in S if x >= 2}
    for a in sorted(S2):
        for b in sorted(S2):
            if a * b in S2:
                return False, (a, b, a * b)
    return True, None


# ============================================================
# Algorithm 2: Product Collision Detection
# ============================================================

def find_product_collisions(
    S: GeneratorSet,
) -> List[Tuple[int, int, int, int, int]]:
    """
    Find all product collisions in S.

    A product collision is (a, b, c, d, n) where a*b = c*d = n
    and {a,b} ≠ {c,d}.

    Time complexity: O(|S|^2 * log|S|)
    """
    S2 = sorted(x for x in S if x >= 2)
    products: Dict[int, List[Tuple[int, int]]] = defaultdict(list)

    for i, a in enumerate(S2):
        for j in range(i, len(S2)):
            b = S2[j]
            products[a * b].append((a, b))

    collisions = []
    for n, pairs in products.items():
        for i in range(len(pairs)):
            for j in range(i + 1, len(pairs)):
                a, b = pairs[i]
                c, d = pairs[j]
                if normalize_multiset([a, b]) != normalize_multiset([c, d]):
                    collisions.append((a, b, c, d, n))

    return collisions


# ============================================================
# Algorithm 3: S-Factorization Enumeration
# ============================================================

def enumerate_factorizations(
    S: GeneratorSet, n: int, max_depth: int = 20
) -> List[Multiset]:
    """
    Enumerate all S-factorizations of n.

    An S-factorization is a multiset of elements from S (all ≥ 2)
    whose product equals n.

    Uses depth-limited backtracking with monotonicity pruning.

    Time complexity: O(|S|^d) where d = max factorization depth
    """
    S2 = sorted(x for x in S if x >= 2)
    if not S2:
        return []

    results: List[Multiset] = []

    def backtrack(remaining: int, min_val: int, current: List[int], depth: int) -> None:
        if remaining == 1:
            if current:
                results.append(normalize_multiset(current))
            return
        if depth >= max_depth:
            return
        for s in S2:
            if s < min_val:
                continue
            if s > remaining:
                break
            if remaining % s == 0:
                backtrack(remaining // s, s, current + [s], depth + 1)

    backtrack(n, S2[0], [], 0)
    return list(set(results))  # deduplicate


# ============================================================
# Algorithm 4: Factorization Diamond Classifier
# ============================================================

def classify_generator_set(
    S: GeneratorSet, test_range: int = 500
) -> Dict[str, bool]:
    """
    Classify a generator set according to the Factorization Diamond.

    Returns a dictionary with keys:
    - 'product_free': True iff S is product-free
    - 'collision_free': True iff S has no product collisions
    - 'unique_factorization': True iff S has UF up to test_range

    The Factorization Diamond Theorem guarantees:
    - UF ⟹ collision_free AND product_free
    - collision_free ⟹̸ product_free
    - product_free ⟹̸ collision_free
    - collision_free AND product_free ⟹̸ UF
    """
    pf, _ = is_product_free(S)
    collisions = find_product_collisions(S)
    cf = len(collisions) == 0

    uf = True
    counterexample = None
    for n in range(2, test_range + 1):
        facts = enumerate_factorizations(S, n)
        if len(facts) > 1:
            uf = False
            counterexample = (n, facts)
            break

    return {
        'product_free': pf,
        'collision_free': cf,
        'unique_factorization': uf,
        'counterexample': counterexample,
    }


# ============================================================
# Algorithm 5: Coprime Basis Verifier
# ============================================================

def is_pairwise_coprime(S: GeneratorSet) -> bool:
    """Check if all pairs of distinct elements in S are coprime."""
    elems = sorted(S)
    for i in range(len(elems)):
        for j in range(i + 1, len(elems)):
            if gcd(elems[i], elems[j]) != 1:
                return False
    return True


def verify_coprime_basis_theorem(S: GeneratorSet, test_range: int = 500) -> bool:
    """
    Verify the Coprime Basis Theorem: for pairwise coprime S,
    UF ↔ product-free.

    Returns True if the theorem holds for the given set and range.
    """
    if not is_pairwise_coprime(S):
        return True  # theorem vacuously holds

    pf, _ = is_product_free(S)
    result = classify_generator_set(S, test_range)
    uf = result['unique_factorization']

    return uf == pf


# ============================================================
# Algorithm 6: Cramér Random Model Generator
# ============================================================

def cramer_random_set(
    N: int, seed: Optional[int] = None
) -> GeneratorSet:
    """
    Generate a Cramér random model up to N.

    Each integer n ∈ [2, N] is included independently with
    probability 1/ln(n), matching the prime density from PNT.
    """
    import random
    if seed is not None:
        random.seed(seed)

    S: GeneratorSet = set()
    for n in range(2, N + 1):
        if random.random() < 1.0 / log(n):
            S.add(n)
    return S


# ============================================================
# Algorithm 7: Factorization Depth Computer
# ============================================================

def factorization_depth(S: GeneratorSet, n: int) -> int:
    """
    Compute the factorization depth: the maximum length of any
    S-factorization of n.
    """
    facts = enumerate_factorizations(S, n)
    if not facts:
        return 0
    return max(len(f) for f in facts)


def factorization_width(S: GeneratorSet, n: int) -> int:
    """
    Compute the factorization width: the number of distinct
    S-factorizations of n.
    """
    return len(enumerate_factorizations(S, n))


# ============================================================
# Main: Verification Suite
# ============================================================

if __name__ == "__main__":
    print("Factorization Diamond Verification Suite")
    print("=" * 50)

    # Verify all four separating examples
    examples = [
        ({2, 3, 5, 7, 11, 13}, "Primes (UF)"),
        ({2, 3, 6}, "CF ∧ ¬PF"),
        ({6, 10, 21, 35}, "PF ∧ ¬CF"),
        ({2, 8}, "CF ∧ PF ∧ ¬UF"),
    ]

    for S, label in examples:
        result = classify_generator_set(S)
        print(f"\n{label}: {sorted(S)}")
        print(f"  PF={result['product_free']}, CF={result['collision_free']}, UF={result['unique_factorization']}")

    # Verify coprime basis theorem
    print("\n\nCoprime Basis Theorem Verification")
    print("-" * 40)
    coprime_sets = [
        {2, 3, 5, 7},
        {4, 9, 25, 49},
        {6, 35, 143},
        {2, 3, 5, 30},  # not product-free
    ]
    for S in coprime_sets:
        ok = verify_coprime_basis_theorem(S)
        print(f"  {sorted(S)}: theorem holds = {ok}")

    # Test random models
    print("\n\nCramér Random Model Statistics")
    print("-" * 40)
    for N in [50, 100, 200]:
        n_pf = 0
        n_cf = 0
        n_trials = 20
        for trial in range(n_trials):
            S = cramer_random_set(N, seed=42 + trial)
            pf, _ = is_product_free(S)
            cf = len(find_product_collisions(S)) == 0
            if pf:
                n_pf += 1
            if cf:
                n_cf += 1
        print(f"  N={N}: product-free {n_pf}/{n_trials}, collision-free {n_cf}/{n_trials}")
