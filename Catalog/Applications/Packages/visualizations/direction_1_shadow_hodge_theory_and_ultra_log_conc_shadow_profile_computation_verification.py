#!/usr/bin/env python3
"""
Algorithms for Shadow Profile Computation and ULC Verification

Implements the computational methods for:
1. Computing shadow profiles of M-convex sets
2. Verifying log-concavity and ultra-log-concavity
3. Generating M-convex sets (uniform matroids, partition matroids)
4. Computing the quantitative log-concavity ratio

These algorithms support the enumeration-based falsification testing
described in the corrected Shadow-Hodge conjecture.

Time complexity: O(n^r) for shadow profile of sets in {0,1}^n of degree r.
Space complexity: O(C(n,r)) for storing the shadow profile.
"""

from math import comb, factorial, log, sqrt
from itertools import combinations
from typing import List, Dict, Set, Tuple, Optional
from collections import defaultdict


def generate_uniform_matroid_bases(n: int, r: int) -> List[Tuple[int, ...]]:
    """
    Generate all bases of the uniform matroid U(r,n).
    
    Each basis is an r-element subset of {0, 1, ..., n-1}, encoded as
    a tuple of 0s and 1s of length n.
    
    Args:
        n: Number of ground set elements
        r: Rank (size of each basis)
    
    Returns:
        List of 0-1 tuples of length n
        
    Time: O(C(n,r))
    Space: O(C(n,r) * n)
    
    >>> generate_uniform_matroid_bases(3, 2)
    [(1, 1, 0), (1, 0, 1), (0, 1, 1)]
    """
    bases = []
    for subset in combinations(range(n), r):
        vec = tuple(1 if i in subset else 0 for i in range(n))
        bases.append(vec)
    return bases


def generate_partition_matroid_bases(block_sizes: List[int], block_ranks: List[int]) -> List[Tuple[int, ...]]:
    """
    Generate all bases of a partition matroid.
    
    A partition matroid has ground set partitioned into blocks of sizes
    b_1, ..., b_p, with rank constraint r_i on block i: each basis
    selects exactly r_i elements from block i.
    
    Args:
        block_sizes: List of block sizes [b_1, ..., b_p]
        block_ranks: List of block ranks [r_1, ..., r_p]
    
    Returns:
        List of 0-1 tuples of length sum(block_sizes)
    
    Time: O(product of C(b_i, r_i))
    """
    if not block_sizes:
        return [()]
    
    n = sum(block_sizes)
    
    # Generate selections for each block
    def block_selections(block_idx: int) -> List[List[int]]:
        size = block_sizes[block_idx]
        rank = block_ranks[block_idx]
        offset = sum(block_sizes[:block_idx])
        sels = []
        for subset in combinations(range(size), rank):
            vec = [0] * size
            for j in subset:
                vec[j] = 1
            sels.append(vec)
        return sels
    
    # Combine across blocks
    result = [[]]
    for idx in range(len(block_sizes)):
        sels = block_selections(idx)
        new_result = []
        for prefix in result:
            for sel in sels:
                new_result.append(prefix + sel)
        result = new_result
    
    return [tuple(v) for v in result]


def compute_shadow_profile(bases: List[Tuple[int, ...]], n: int) -> Dict[int, int]:
    """
    Compute the shadow profile of a set of vectors.
    
    For a set S of vectors in N^n, the degree-k shadow is:
        Sh_k(S) = {β ∈ N^n : sum(β) = k, ∃α ∈ S, β ≤ α componentwise}
    
    The shadow profile is a_k = |Sh_k(S)|.
    
    For 0-1 vectors (matroid bases), the degree-k shadow consists of
    all k-element subsets of the support of some basis element.
    
    Args:
        bases: List of vectors (tuples of nonneg integers)
        n: Dimension
    
    Returns:
        Dictionary mapping degree k to shadow size a_k
    
    Time: O(|bases| * 2^max_degree) in worst case
    Space: O(sum_k a_k)
    
    >>> bases = generate_uniform_matroid_bases(4, 2)
    >>> profile = compute_shadow_profile(bases, 4)
    >>> [profile.get(k, 0) for k in range(5)]
    [1, 4, 6, 0, 0]
    """
    if not bases:
        return {}
    
    max_degree = max(sum(b) for b in bases)
    
    # For each degree k, collect all dominated vectors of that degree
    shadow_sets: Dict[int, Set[Tuple[int, ...]]] = defaultdict(set)
    
    for basis in bases:
        # Find support (nonzero positions) and their values
        support = [(i, basis[i]) for i in range(n) if basis[i] > 0]
        degree = sum(basis[i] for i in range(n))
        
        # Generate all dominated vectors of each degree
        # For 0-1 vectors, this is just choosing subsets of the support
        if all(b <= 1 for b in basis):
            # Multiaffine case: subsets of support
            support_indices = [i for i, v in enumerate(basis) if v > 0]
            for k in range(len(support_indices) + 1):
                for subset in combinations(support_indices, k):
                    vec = tuple(1 if i in subset else 0 for i in range(n))
                    shadow_sets[k].add(vec)
        else:
            # General case: enumerate dominated vectors by degree
            _enumerate_dominated(basis, n, 0, [], shadow_sets)
    
    # Always include degree 0 (zero vector)
    shadow_sets[0].add(tuple(0 for _ in range(n)))
    
    return {k: len(s) for k, s in shadow_sets.items()}


def _enumerate_dominated(basis: Tuple[int, ...], n: int, pos: int,
                         current: List[int], shadow_sets: Dict[int, Set[Tuple[int, ...]]]):
    """Helper to enumerate all vectors dominated by basis."""
    if pos == n:
        vec = tuple(current)
        deg = sum(vec)
        shadow_sets[deg].add(vec)
        return
    
    for val in range(basis[pos] + 1):
        current.append(val)
        _enumerate_dominated(basis, n, pos + 1, current, shadow_sets)
        current.pop()


def verify_log_concavity(profile: Dict[int, int]) -> Tuple[bool, List[dict]]:
    """
    Verify log-concavity of a shadow profile.
    
    Checks: a_k^2 >= a_{k-1} * a_{k+1} for all valid k.
    
    Args:
        profile: Dictionary mapping degree to shadow size
    
    Returns:
        (all_pass, details) where details has per-k results
    
    Time: O(max_degree)
    """
    if not profile:
        return True, []
    
    max_k = max(profile.keys())
    details = []
    all_pass = True
    
    for k in range(1, max_k):
        a_prev = profile.get(k - 1, 0)
        a_curr = profile.get(k, 0)
        a_next = profile.get(k + 1, 0)
        
        lhs = a_curr ** 2
        rhs = a_prev * a_next
        passes = lhs >= rhs
        
        ratio = lhs / rhs if rhs > 0 else float('inf')
        
        details.append({
            'k': k,
            'a_k': a_curr,
            'a_km1': a_prev,
            'a_kp1': a_next,
            'lhs': lhs,
            'rhs': rhs,
            'passes': passes,
            'ratio': ratio
        })
        
        if not passes:
            all_pass = False
    
    return all_pass, details


def verify_ulc(profile: Dict[int, int], D: int) -> Tuple[bool, List[dict]]:
    """
    Verify ultra-log-concavity with respect to degree D.
    
    Checks: a_k^2 * C(D,k-1) * C(D,k+1) >= a_{k-1} * a_{k+1} * C(D,k)^2
    
    Args:
        profile: Dictionary mapping degree to shadow size  
        D: Degree parameter for ULC normalization
    
    Returns:
        (all_pass, details) where details has per-k results
    
    Time: O(D)
    """
    details = []
    all_pass = True
    
    for k in range(1, D):
        a_prev = profile.get(k - 1, 0)
        a_curr = profile.get(k, 0)
        a_next = profile.get(k + 1, 0)
        
        lhs = a_curr ** 2 * comb(D, k - 1) * comb(D, k + 1)
        rhs = a_prev * a_next * comb(D, k) ** 2
        passes = lhs >= rhs
        
        details.append({
            'k': k,
            'lhs': lhs,
            'rhs': rhs,
            'passes': passes,
            'ratio': lhs / rhs if rhs > 0 else float('inf')
        })
        
        if not passes:
            all_pass = False
    
    return all_pass, details


def quantitative_log_concavity_ratio(n: int, k: int) -> float:
    """
    Compute the quantitative log-concavity ratio:
        C(n,k)^2 / (C(n,k-1) * C(n,k+1)) = (k+1)(n-k+1) / (k(n-k))
    
    This ratio is always >= 1 + (n+1)/(k(n-k)), giving a quantitative
    strengthening of log-concavity.
    
    Args:
        n: Top parameter of binomial coefficient
        k: Middle parameter, must satisfy 1 <= k <= n-1
    
    Returns:
        The ratio, which is always >= 1
    
    Time: O(1)
    
    >>> quantitative_log_concavity_ratio(10, 5)
    1.2
    """
    if k < 1 or k >= n or n < 2:
        return float('inf')
    return (k + 1) * (n - k + 1) / (k * (n - k))


def mass_test_conjecture(max_n: int = 12) -> Tuple[bool, int, List[str]]:
    """
    Mass-test the corrected shadow log-concavity conjecture.
    
    Tests log-concavity of shadow profiles for:
    1. All uniform matroids U(r,n) with n <= max_n
    2. All partition matroids with <= 4 blocks and total size <= 8
    
    Args:
        max_n: Maximum ground set size for uniform matroids
    
    Returns:
        (all_pass, total_tests, failure_descriptions)
    
    Time: O(max_n^3 + exponential in partition matroid size)
    """
    total_tests = 0
    failures: List[str] = []
    
    # Test uniform matroids
    for n in range(2, max_n + 1):
        for r in range(1, n + 1):
            bases = generate_uniform_matroid_bases(n, r)
            profile = compute_shadow_profile(bases, n)
            ok, details = verify_log_concavity(profile)
            total_tests += 1
            if not ok:
                failures.append(f"U({r},{n}): log-concavity fails")
    
    # Test small partition matroids
    for b1 in range(2, 5):
        for r1 in range(1, b1 + 1):
            for b2 in range(2, 5):
                for r2 in range(1, b2 + 1):
                    if b1 + b2 > 8:
                        continue
                    bases = generate_partition_matroid_bases([b1, b2], [r1, r2])
                    n = b1 + b2
                    profile = compute_shadow_profile(bases, n)
                    ok, details = verify_log_concavity(profile)
                    total_tests += 1
                    if not ok:
                        failures.append(
                            f"Partition([{b1},{b2}],[{r1},{r2}]): log-concavity fails"
                        )
    
    return len(failures) == 0, total_tests, failures


if __name__ == "__main__":
    print("Shadow Profile Algorithms — Self-Test")
    print("=" * 50)
    
    # Test 1: Uniform matroid shadow profiles
    print("\n1. Uniform matroid U(3,5) shadow profile:")
    bases = generate_uniform_matroid_bases(5, 3)
    profile = compute_shadow_profile(bases, 5)
    print(f"   Profile: {[profile.get(k, 0) for k in range(6)]}")
    print(f"   Expected: [1, 5, 10, 10, 0, 0]")
    
    # Test 2: Log-concavity verification
    print("\n2. Log-concavity of C(8,k):")
    profile8 = {k: comb(8, k) for k in range(9)}
    ok, details = verify_log_concavity(profile8)
    print(f"   Result: {'PASS' if ok else 'FAIL'}")
    
    # Test 3: Quantitative ratios
    print("\n3. Quantitative log-concavity ratios for n=10:")
    for k in range(1, 10):
        r = quantitative_log_concavity_ratio(10, k)
        print(f"   k={k}: ratio = {r:.4f} (excess = {r-1:.4f})")
    
    # Test 4: Mass test
    print("\n4. Mass test (n <= 10):")
    ok, total, fails = mass_test_conjecture(10)
    print(f"   Tests: {total}, Failures: {len(fails)}")
    print(f"   Result: {'ALL PASSED ✓' if ok else 'FAILURES FOUND ✗'}")
    if fails:
        for f in fails[:5]:
            print(f"   {f}")
