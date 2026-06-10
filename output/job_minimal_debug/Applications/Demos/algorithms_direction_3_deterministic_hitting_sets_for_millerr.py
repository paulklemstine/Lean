#!/usr/bin/env python3
"""
Algorithms for Deterministic Hitting Sets in Dense Set Families

Implements:
1. Greedy hitting set construction for dense families
2. Miller-Rabin witness computation
3. Hitting set verification
4. Density analysis tools

All algorithms correspond to formally verified theorems.
"""

import math
from typing import List, Set, Dict, Tuple, Optional, Callable
from collections import defaultdict


# ============================================================
# Algorithm 1: Generic Greedy Hitting Set for Dense Families
# ============================================================

def greedy_hitting_set_generic(
    universe: List[int],
    family: List[Set[int]],
    density_threshold: float = 0.75
) -> Tuple[List[int], List[int]]:
    """
    Generic greedy hitting set for a family of dense subsets.
    
    Given a universe U and family F of subsets of U where each
    member has density >= delta, repeatedly picks the element
    covering the most uncovered sets.
    
    Corresponds to the formal theorem `exists_hittingSet_of_dense_family`:
    if each S in F satisfies |S| >= (3/4)|U|, then there exists
    H subset U with |H| <= k and H intersects every S in F,
    where k satisfies |F| < 4^k.
    
    Args:
        universe: List of elements in U
        family: List of sets, each a subset of universe
        density_threshold: Minimum density (default 3/4)
    
    Returns:
        (hitting_set, coverage_order): The hitting set and order of coverage
    
    Complexity:
        Time: O(|U| * |F| * k) where k = O(log |F|)
        Space: O(|U| * |F|)
    """
    if not family:
        return [], []
    
    # Verify density
    u_size = len(universe)
    for i, s in enumerate(family):
        density = len(s) / u_size if u_size > 0 else 0
        if density < density_threshold:
            print(f"  Warning: Set {i} has density {density:.3f} < {density_threshold}")
    
    # Precompute: for each element, which sets contain it?
    element_to_sets: Dict[int, Set[int]] = defaultdict(set)
    for i, s in enumerate(family):
        for elem in s:
            element_to_sets[elem].add(i)
    
    uncovered = set(range(len(family)))
    hitting_set = []
    coverage_order = []
    
    while uncovered:
        # Pick element covering most uncovered sets (averaging lemma)
        best_elem = max(universe,
                       key=lambda e: len(element_to_sets[e] & uncovered))
        covered_count = len(element_to_sets[best_elem] & uncovered)
        
        if covered_count == 0:
            break
        
        hitting_set.append(best_elem)
        covered_now = element_to_sets[best_elem] & uncovered
        coverage_order.append(len(covered_now))
        uncovered -= covered_now
    
    return hitting_set, coverage_order


# ============================================================
# Algorithm 2: Miller-Rabin Witness Computation
# ============================================================

def is_prime(n: int) -> bool:
    """Deterministic primality test for reasonably sized integers."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def miller_rabin_decompose(n: int) -> Tuple[int, int]:
    """
    Decompose n-1 = 2^s * d where d is odd.
    
    Returns (s, d).
    """
    d = n - 1
    s = 0
    while d % 2 == 0:
        d //= 2
        s += 1
    return s, d


def is_miller_rabin_witness(a: int, n: int) -> bool:
    """
    Check if base a is a Miller-Rabin witness for n.
    
    A witness certifies that n is composite. Returns True if
    a witnesses compositeness of n.
    
    Corresponds to the formal definition `MRWitnessFor`.
    
    Algorithm:
        1. If gcd(a, n) > 1, a is a trivial witness.
        2. Write n-1 = 2^s * d.
        3. Compute x = a^d mod n.
        4. If x == 1 or x == n-1, a is not a witness.
        5. Square x repeatedly s-1 times; if any equals n-1, not a witness.
        6. Otherwise, a is a witness.
    
    Time: O(log n * log^2 n) using fast modular exponentiation.
    """
    if n < 2 or n % 2 == 0:
        return False
    
    g = math.gcd(a, n)
    if g > 1 and g < n:
        return True
    if g == n:
        return False
    
    s, d = miller_rabin_decompose(n)
    
    x = pow(a, d, n)
    if x == 1 or x == n - 1:
        return False
    
    for _ in range(s - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return False
    
    return True


def witness_set(n: int, B: int) -> Set[int]:
    """
    Compute W(n, B) = {a in {2,...,B} : a is MR witness for n}.
    
    Corresponds to formal definition `witnessSet`.
    """
    return {a for a in range(2, B + 1) if is_miller_rabin_witness(a, n)}


def liar_set(n: int, B: int) -> Set[int]:
    """
    Compute L(n, B) = {a in {2,...,B} : a is MR liar for n}.
    
    The complement of the witness set.
    """
    return {a for a in range(2, B + 1) if not is_miller_rabin_witness(a, n)}


def witness_density(n: int) -> float:
    """
    Compute the witness density for n among coprime bases.
    
    The Monier-Rabin theorem guarantees this is >= 3/4
    for odd composites n >= 9.
    """
    coprime_bases = [a for a in range(2, n) if math.gcd(a, n) == 1]
    if not coprime_bases:
        return 0.0
    witnesses = sum(1 for a in coprime_bases if is_miller_rabin_witness(a, n))
    return witnesses / len(coprime_bases)


# ============================================================
# Algorithm 3: Specialized MR Greedy Hitting Set
# ============================================================

def mr_greedy_hitting_set(
    N: int,
    max_base: int = 200
) -> Tuple[List[int], Dict[str, any]]:
    """
    Specialized greedy hitting set for Miller-Rabin.
    
    Finds a small set H of bases such that for every odd composite
    n <= N, some a in H is a witness for n.
    
    This corresponds to the formal theorem `exists_MR_hittingSet`.
    
    Args:
        N: Upper bound for composites to cover
        max_base: Maximum base to consider
    
    Returns:
        (hitting_set, stats): The hitting set and statistics dict
    
    Pseudocode:
        1. Enumerate odd composites C = {n <= N : n odd composite}
        2. For each candidate base a in {2,...,max_base}:
             Compute covers(a) = {n in C : a witnesses n}
        3. Greedy loop:
             While uncovered != empty:
               Pick a* = argmax_a |covers(a) ∩ uncovered|
               H = H ∪ {a*}
               uncovered = uncovered \ covers(a*)
        4. Return H
    """
    odd_composites = [n for n in range(9, N + 1, 2)
                      if not is_prime(n)]
    
    if not odd_composites:
        return [], {'composites': 0}
    
    # Use primes as candidates (most effective in practice)
    candidates = sorted([p for p in range(2, max_base + 1) if is_prime(p)])
    
    # Precompute coverage
    covers: Dict[int, Set[int]] = {}
    for a in candidates:
        covers[a] = {n for n in odd_composites if is_miller_rabin_witness(a, n)}
    
    uncovered = set(odd_composites)
    hitting_set = []
    step_info = []
    
    while uncovered:
        if not candidates:
            break
        
        best = max(candidates, key=lambda a: len(covers.get(a, set()) & uncovered))
        covered_count = len(covers.get(best, set()) & uncovered)
        
        if covered_count == 0:
            break
        
        hitting_set.append(best)
        covered_now = covers[best] & uncovered
        step_info.append({
            'base': best,
            'covered': covered_count,
            'remaining': len(uncovered) - covered_count
        })
        uncovered -= covered_now
    
    stats = {
        'composites': len(odd_composites),
        'uncovered': len(uncovered),
        'steps': step_info,
        'theoretical_bound': math.ceil(math.log(len(odd_composites) + 1) / math.log(4))
    }
    
    return hitting_set, stats


# ============================================================
# Algorithm 4: Hitting Set Verification
# ============================================================

def verify_mr_hitting_set(
    hitting_set: List[int],
    N: int
) -> Tuple[bool, List[int]]:
    """
    Verify that hitting_set witnesses all odd composites up to N.
    
    Returns (is_valid, failures) where failures lists any
    composites not caught.
    """
    failures = []
    for n in range(9, N + 1, 2):
        if not is_prime(n):
            if not any(is_miller_rabin_witness(a, n) for a in hitting_set):
                failures.append(n)
    
    return len(failures) == 0, failures


# ============================================================
# Algorithm 5: Transversal Number Estimation
# ============================================================

def estimate_transversal_number(
    N: int,
    max_base: int = 100
) -> Dict[str, any]:
    """
    Estimate the transversal number of the MR witness hypergraph.
    
    Corresponds to the formal definition `transversalNumber`.
    The formal theorem `transversalNumber_le_of_dense` bounds this
    by O(log |F|) for dense families.
    """
    hs, stats = mr_greedy_hitting_set(N, max_base)
    
    # Greedy gives an upper bound; optimal could be smaller
    return {
        'upper_bound': len(hs),
        'greedy_set': hs,
        'theoretical_upper': stats['theoretical_bound'],
        'N': N,
        'composites': stats['composites']
    }


# ============================================================
# Main: Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("HITTING SET ALGORITHMS - EXAMPLES")
    print("=" * 60)
    
    # Example 1: Generic dense family
    print("\n--- Generic Dense Family Example ---")
    U = list(range(20))
    # Create random dense subsets (each covering >= 75% of U)
    import random
    random.seed(42)
    F = []
    for _ in range(50):
        s = set(random.sample(U, k=random.randint(15, 20)))
        F.append(s)
    
    hs, order = greedy_hitting_set_generic(U, F)
    print(f"Universe size: {len(U)}")
    print(f"Family size: {len(F)}")
    print(f"Hitting set: {hs}")
    print(f"Hitting set size: {len(hs)}")
    print(f"Coverage per step: {order}")
    print(f"Theoretical bound (ceil(log4({len(F)}))): "
          f"{math.ceil(math.log(len(F)+1)/math.log(4))}")
    
    # Example 2: MR hitting set
    print("\n--- Miller-Rabin Hitting Set ---")
    for N in [1000, 5000, 10000]:
        hs, stats = mr_greedy_hitting_set(N)
        valid, failures = verify_mr_hitting_set(hs, N)
        print(f"N={N}: H={hs}, |H|={len(hs)}, "
              f"composites={stats['composites']}, valid={valid}")
    
    # Example 3: Transversal estimation
    print("\n--- Transversal Number Estimates ---")
    for N in [500, 1000, 5000]:
        est = estimate_transversal_number(N)
        print(f"N={N}: tau <= {est['upper_bound']} (greedy), "
              f"theory <= {est['theoretical_upper']}, "
              f"set={est['greedy_set']}")
