"""
Algorithms for the Multiplicative Independence Hierarchy.

Provides type-hinted implementations for:
1. k-product-free testing
2. Failure level computation
3. S-factorization enumeration
4. Product shadow computation
5. Cramér random model generation
"""

from itertools import combinations_with_replacement
from typing import FrozenSet, List, Set, Tuple
from math import log, prod
import random


def is_k_product_free(S: Set[int], k: int) -> bool:
    """Test whether set S is k-product-free.

    A set is k-product-free if no multiset of k elements (each >= 2)
    from S has a product that lands back in S.

    Args:
        S: Set of positive integers (each >= 2).
        k: Level of product-freeness to test.

    Returns:
        True if S is k-product-free, False otherwise.
    """
    S_list = sorted(S)
    for combo in combinations_with_replacement(S_list, k):
        p = prod(combo)
        if p in S:
            return False
    return True


def find_violation(S: Set[int], k: int) -> Tuple[int, ...] | None:
    """Find a k-product violation if one exists.

    Returns:
        A tuple of k elements from S whose product is in S, or None.
    """
    S_list = sorted(S)
    for combo in combinations_with_replacement(S_list, k):
        p = prod(combo)
        if p in S:
            return combo
    return None


def failure_level(S: Set[int], max_k: int = 20) -> int | None:
    """Compute the failure level of a set S.

    The failure level is the smallest k >= 2 at which S fails
    k-product-freeness. Returns None if S passes all levels up to max_k.

    Args:
        S: Set of positive integers (each >= 2).
        max_k: Maximum level to check.

    Returns:
        The failure level, or None if all levels pass.
    """
    for k in range(2, max_k + 1):
        if not is_k_product_free(S, k):
            return k
    return None


def product_shadow(S: Set[int]) -> Set[int]:
    """Compute the product shadow of S: all pairwise products.

    Args:
        S: Set of positive integers.

    Returns:
        Set of all products a*b where a, b in S.
    """
    shadow = set()
    S_list = sorted(S)
    for a in S_list:
        for b in S_list:
            shadow.add(a * b)
    return shadow


def count_factorizations(S: Set[int], n: int, max_depth: int = 50) -> int:
    """Count the number of distinct S-factorizations of n.

    An S-factorization is a multiset of elements from S (each >= 2)
    whose product equals n.

    Args:
        S: Set of positive integers (each >= 2).
        n: Number to factorize.
        max_depth: Maximum factorization depth.

    Returns:
        Number of distinct S-factorizations.
    """
    S_sorted = sorted(s for s in S if s >= 2)

    def _count(target: int, min_elem: int, depth: int) -> int:
        if target == 1:
            return 1
        if depth <= 0:
            return 0
        total = 0
        for s in S_sorted:
            if s < min_elem:
                continue
            if s > target:
                break
            if target % s == 0:
                total += _count(target // s, s, depth - 1)
        return total

    return _count(n, min(S_sorted) if S_sorted else 2, max_depth)


def multiplicative_independence_spectrum(
    S: Set[int], max_k: int = 10
) -> dict[int, bool]:
    """Compute the multiplicative independence spectrum of S.

    Returns:
        Dictionary mapping k -> is_k_product_free(S, k) for k = 2..max_k.
    """
    return {k: is_k_product_free(S, k) for k in range(2, max_k + 1)}


def generate_cramer_model(N: int) -> Set[int]:
    """Generate a Cramér random model up to N.

    Each integer n in {2, ..., N} is included independently with
    probability 1/ln(n).

    Args:
        N: Upper bound.

    Returns:
        Random subset of {2, ..., N}.
    """
    S = set()
    for n in range(2, N + 1):
        if random.random() < 1.0 / log(n):
            S.add(n)
    return S


def hierarchy_witness(k: int) -> Set[int]:
    """Construct the conjectured witness for hierarchy level k.

    S_k = {2, 3, 2^(k-1) * 3}.

    Args:
        k: Hierarchy level (>= 2).

    Returns:
        The witness set.
    """
    return {2, 3, 2 ** (k - 1) * 3}


def verify_hierarchy_witness(k: int) -> dict:
    """Verify the hierarchy witness at level k.

    Checks that S_k is j-product-free for all 2 <= j < k
    and not k-product-free.

    Args:
        k: Hierarchy level (>= 2).

    Returns:
        Dictionary with verification results.
    """
    S = hierarchy_witness(k)
    results = {
        "k": k,
        "set": sorted(S),
        "levels_below": {},
        "fails_at_k": False,
        "violation": None,
    }

    for j in range(2, k):
        results["levels_below"][j] = is_k_product_free(S, j)

    results["fails_at_k"] = not is_k_product_free(S, k)
    results["violation"] = find_violation(S, k)

    return results


def is_power_independent(S: Set[int]) -> bool:
    """Check if elements of S are pairwise multiplicatively independent.

    Two integers a, b are multiplicatively dependent if there exist
    positive integers m, n such that a^m = b^n.

    Args:
        S: Set of positive integers.

    Returns:
        True if all pairs are multiplicatively independent.
    """
    from math import gcd

    def base_and_exp(n: int) -> Tuple[int, int]:
        """Find the smallest base b and largest exponent e with b^e = n."""
        for e in range(63, 0, -1):
            b = round(n ** (1.0 / e))
            for candidate in [b - 1, b, b + 1]:
                if candidate >= 2 and candidate**e == n:
                    return (candidate, e)
        return (n, 1)

    elements = sorted(S)
    bases = {s: base_and_exp(s) for s in elements}

    for i in range(len(elements)):
        for j in range(i + 1, len(elements)):
            a, b = elements[i], elements[j]
            ba, ea = bases[a]
            bb, eb = bases[b]
            if ba == bb:  # Same base -> multiplicatively dependent
                return False
    return True


if __name__ == "__main__":
    # Demonstrate key results
    print("=== Hierarchy Witnesses ===")
    for k in range(2, 8):
        result = verify_hierarchy_witness(k)
        print(f"k={k}: S={result['set']}")
        for j, pf in result["levels_below"].items():
            print(f"  {j}-product-free: {pf}")
        print(f"  Fails at {k}: {result['fails_at_k']}")
        if result["violation"]:
            print(f"  Violation: {result['violation']}")
        print()

    print("=== {4, 8} Counterexample ===")
    S = {4, 8}
    print(f"Set: {S}")
    print(f"Spectrum: {multiplicative_independence_spectrum(S)}")
    print(f"Factorizations of 64: {count_factorizations(S, 64)}")
    print(f"Power-independent: {is_power_independent(S)}")
    print()

    print("=== Cramér Model Defects ===")
    for N in [100, 1000, 10000]:
        violations = []
        for _ in range(100):
            model = generate_cramer_model(N)
            v = find_violation(model, 2)
            violations.append(1 if v else 0)
        print(
            f"N={N}: {sum(violations)}% of models have 2-product violations"
        )
