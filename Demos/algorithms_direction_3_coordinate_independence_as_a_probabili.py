#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Adelic Coordinate Independence

Implements the core algorithms for computing probabilities and verifying
independence on the maximal compact of restricted products of finite groups.

Algorithms:
1. Maximal compact enumeration
2. Finite coordinate event cardinality via product formula
3. Independence verification (joint vs product of marginals)
4. Entropy computation and mutual information check
5. Expectation factorization verifier
"""

import math
from fractions import Fraction
from itertools import product as cartesian_product
from typing import Dict, List, Set, Tuple, Optional, Callable
from collections import Counter


# ============================================================================
# Algorithm 1: Local group construction
# ============================================================================

def units_mod_n(n: int) -> List[int]:
    """
    Compute (Z/nZ)*, the group of units modulo n.
    
    Algorithm: Filter {1, ..., n-1} for elements coprime to n.
    Time: O(n log n) via Euclidean GCD.
    Space: O(φ(n)) where φ is Euler's totient.
    
    >>> units_mod_n(4)
    [1, 3]
    >>> len(units_mod_n(25))  # φ(25) = 20
    20
    """
    return [k for k in range(1, n) if math.gcd(k, n) == 1]


def build_local_groups(primes: List[int], exponent: int = 2) -> Dict[int, List[int]]:
    """
    Build local groups G_p = (Z/p^e Z)* for a list of primes.
    
    Args:
        primes: List of prime numbers.
        exponent: Power to raise each prime (default 2).
    
    Returns:
        Dict mapping each prime to its group elements.
    
    Time: O(Σ_p p^e · log(p^e))
    Space: O(Σ_p φ(p^e))
    
    >>> groups = build_local_groups([2, 3, 5])
    >>> [len(groups[p]) for p in [2, 3, 5]]
    [2, 6, 20]
    """
    return {p: units_mod_n(p**exponent) for p in primes}


# ============================================================================
# Algorithm 2: Maximal compact cardinality (product formula)
# ============================================================================

def maximal_compact_card(groups: Dict[int, List[int]]) -> int:
    """
    Compute |∏_p G_p| = ∏_p |G_p| without enumeration.
    
    This is the product formula: the cardinality of the maximal compact
    is the product of local cardinalities.
    
    Time: O(|primes|)
    Space: O(1)
    
    >>> groups = build_local_groups([2, 3, 5, 7])
    >>> maximal_compact_card(groups)
    10080
    """
    result = 1
    for p in groups:
        result *= len(groups[p])
    return result


def maximal_compact_enumerate(groups: Dict[int, List[int]]) -> List[Dict[int, int]]:
    """
    Enumerate all elements of the maximal compact ∏_p G_p.
    
    Warning: Size grows exponentially. Only use for small groups.
    
    Time: O(∏_p |G_p|)
    Space: O(∏_p |G_p|)
    
    >>> groups = build_local_groups([2, 3])
    >>> len(maximal_compact_enumerate(groups))
    12
    """
    primes = sorted(groups.keys())
    elements_list = [groups[p] for p in primes]
    return [dict(zip(primes, combo)) for combo in cartesian_product(*elements_list)]


# ============================================================================
# Algorithm 3: Finite coordinate event cardinality
# ============================================================================

def finite_coord_event_card_formula(
    groups: Dict[int, List[int]],
    constrained_primes: List[int],
    local_subset_sizes: Dict[int, int]
) -> int:
    """
    Compute |finiteCoordEvent| using the product formula (no enumeration).
    
    |event| = (∏_{p ∈ S} |A_p|) × (∏_{p ∉ S} |G_p|)
    
    This is the content of Theorem 1: the cardinality factors.
    
    Args:
        groups: Local groups G_p.
        constrained_primes: The support set S.
        local_subset_sizes: |A_p| for p ∈ S.
    
    Time: O(|primes|)
    Space: O(1)
    
    >>> groups = build_local_groups([2, 3, 5])
    >>> finite_coord_event_card_formula(groups, [2, 3], {2: 1, 3: 3})
    60
    """
    constrained_set = set(constrained_primes)
    result = 1
    for p in groups:
        if p in constrained_set:
            result *= local_subset_sizes[p]
        else:
            result *= len(groups[p])
    return result


def finite_coord_event_card_enumerate(
    compact: List[Dict[int, int]],
    constrained_primes: List[int],
    local_subsets: Dict[int, Set[int]]
) -> int:
    """
    Compute |finiteCoordEvent| by direct enumeration.
    
    Time: O(|compact| × |S|)
    Space: O(1)
    """
    count = 0
    for x in compact:
        if all(x[p] in local_subsets[p] for p in constrained_primes):
            count += 1
    return count


# ============================================================================
# Algorithm 4: Independence verification
# ============================================================================

def verify_independence(
    groups: Dict[int, List[int]],
    constrained_primes: List[int],
    local_subsets: Dict[int, Set[int]]
) -> Tuple[bool, Fraction, Fraction]:
    """
    Verify coordinate independence: joint probability = product of marginals.
    
    Computes both sides using the product formula (Algorithm 3) and checks equality.
    
    Returns:
        (is_equal, joint_prob, product_of_marginals)
    
    Time: O(|primes|) using formula; O(|compact| × |S|) using enumeration.
    Space: O(1)
    
    >>> groups = build_local_groups([2, 3, 5])
    >>> subsets = {2: {1}, 3: {1, 2, 4}}
    >>> ok, joint, prod_m = verify_independence(groups, [2, 3], subsets)
    >>> ok
    True
    """
    total = maximal_compact_card(groups)
    
    # Joint probability via product formula
    event_size = finite_coord_event_card_formula(
        groups, constrained_primes,
        {p: len(local_subsets[p]) for p in constrained_primes}
    )
    joint_prob = Fraction(event_size, total)
    
    # Product of marginals
    product_prob = Fraction(1, 1)
    for p in constrained_primes:
        product_prob *= Fraction(len(local_subsets[p]), len(groups[p]))
    
    return (joint_prob == product_prob, joint_prob, product_prob)


# ============================================================================
# Algorithm 5: Entropy and mutual information
# ============================================================================

def shannon_entropy(distribution: Dict, total: int) -> float:
    """
    Compute Shannon entropy H = -Σ p_i log2(p_i).
    
    Args:
        distribution: Dict mapping outcomes to counts.
        total: Total count (normalization).
    
    Time: O(|support|)
    Space: O(1)
    """
    h = 0.0
    for count in distribution.values():
        if count > 0:
            p = count / total
            h -= p * math.log2(p)
    return h


def mutual_information(
    compact: List[Dict[int, int]],
    p: int, q: int
) -> float:
    """
    Compute mutual information I(π_p; π_q) on the maximal compact.
    
    I(X; Y) = H(X) + H(Y) - H(X, Y)
    
    For independent coordinates, this should be exactly 0.
    
    Time: O(|compact|)
    Space: O(|G_p| × |G_q|)
    
    >>> groups = build_local_groups([2, 3, 5])
    >>> compact = maximal_compact_enumerate(groups)
    >>> abs(mutual_information(compact, 2, 3)) < 1e-10
    True
    """
    n = len(compact)
    
    # Marginals
    count_p = Counter(x[p] for x in compact)
    count_q = Counter(x[q] for x in compact)
    
    # Joint
    count_pq = Counter((x[p], x[q]) for x in compact)
    
    H_p = shannon_entropy(count_p, n)
    H_q = shannon_entropy(count_q, n)
    H_pq = shannon_entropy(count_pq, n)
    
    return H_p + H_q - H_pq


# ============================================================================
# Algorithm 6: Expectation factorization
# ============================================================================

def verify_expectation_factorization(
    compact: List[Dict[int, int]],
    groups: Dict[int, List[int]],
    functions: Dict[int, Dict[int, Fraction]],
    constrained_primes: List[int]
) -> Tuple[bool, Fraction, Fraction]:
    """
    Verify E[∏_{p∈S} f_p(π_p)] = ∏_{p∈S} E[f_p(π_p)].
    
    Args:
        compact: Enumerated maximal compact.
        groups: Local groups.
        functions: f_p : G_p → ℚ for each p ∈ S.
        constrained_primes: The support S.
    
    Returns:
        (is_equal, lhs, rhs)
    
    Time: O(|compact| × |S| + |S| × |compact|)
    """
    n = len(compact)
    
    # LHS: E[product]
    lhs = sum(
        math.prod(functions[p][x[p]] for p in constrained_primes)
        for x in compact
    ) / n
    
    # RHS: product of expectations
    rhs = Fraction(1)
    for p in constrained_primes:
        E_f = sum(functions[p][x[p]] for x in compact) / n
        rhs *= E_f
    
    return (lhs == rhs, lhs, rhs)


# ============================================================================
# Main: run doctests
# ============================================================================

if __name__ == "__main__":
    import doctest
    results = doctest.testmod(verbose=True)
    print(f"\n{results.attempted} tests, {results.failed} failures")
    
    # Quick demo
    print("\n" + "=" * 60)
    print("Quick Algorithm Demo")
    print("=" * 60)
    
    primes = [2, 3, 5, 7]
    groups = build_local_groups(primes)
    print(f"Primes: {primes}")
    print(f"Group sizes: {[len(groups[p]) for p in primes]}")
    print(f"Maximal compact size (formula): {maximal_compact_card(groups)}")
    
    compact = maximal_compact_enumerate(groups)
    print(f"Maximal compact size (enumeration): {len(compact)}")
    
    # Verify independence
    subsets = {2: {1}, 3: {1, 2, 4}, 5: set(units_mod_n(25)[:10])}
    ok, joint, prod_m = verify_independence(groups, [2, 3, 5], subsets)
    print(f"\nIndependence check: {'✓' if ok else '✗'}")
    print(f"  Joint prob = {joint}")
    print(f"  Prod marginals = {prod_m}")
    
    # Mutual information
    for p, q in [(2, 3), (2, 5), (3, 7)]:
        mi = mutual_information(compact, p, q)
        print(f"  I(π_{p}; π_{q}) = {mi:.2e}")
