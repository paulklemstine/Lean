#!/usr/bin/env python3
"""
Algorithms for Taxicab Number Theory

Type-hinted implementations of the core algorithms used in computing
and analyzing taxicab numbers and their structural properties.
"""

from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict
import math
import heapq


def find_cube_representations(n: int) -> List[Tuple[int, int]]:
    """
    Find all representations of n as a³ + b³ with 0 < a ≤ b.
    
    Algorithm: Iterate a from 1 upward. For each a, compute b³ = n - a³
    and check if b³ is a perfect cube with b ≥ a.
    
    Time complexity: O(n^{1/3})
    
    Args:
        n: Positive integer to decompose
        
    Returns:
        List of (a, b) pairs with a ≤ b and a³ + b³ = n
    """
    reps: List[Tuple[int, int]] = []
    a = 1
    while 2 * a ** 3 <= n:
        remainder = n - a ** 3
        b = round(remainder ** (1/3))
        # Check neighborhood due to floating point
        for candidate in range(max(a, b - 1), b + 2):
            if candidate ** 3 == remainder:
                reps.append((a, candidate))
                break
        a += 1
    return reps


def taxicab_order(n: int) -> int:
    """
    Compute τ(n), the taxicab order of n.
    
    This is the number of distinct representations of n as a³ + b³
    with 0 < a ≤ b.
    
    Args:
        n: Positive integer
        
    Returns:
        Number of distinct cube representations
    """
    return len(find_cube_representations(n))


def cube_rep_signature(n: int) -> List[int]:
    """
    Compute the Cube Representation Signature Sig(n).
    
    Sig(n) = {a + b : a³ + b³ = n, 0 < a ≤ b}
    
    By the Same-Sum Uniqueness Theorem, this is a complete invariant:
    |Sig(n)| = τ(n), and knowing Sig(n) determines all representations.
    
    Args:
        n: Positive integer
        
    Returns:
        Sorted list of pair-sums
    """
    reps = find_cube_representations(n)
    return sorted(a + b for a, b in reps)


def find_taxicab_numbers(k: int, limit: int) -> List[Tuple[int, List[Tuple[int, int]]]]:
    """
    Find all k-taxicab numbers up to limit.
    
    Algorithm: Enumerate all sums a³ + b³ ≤ limit, group by sum,
    and filter for groups of size ≥ k.
    
    Time complexity: O(limit^{2/3})
    Space complexity: O(limit^{2/3})
    
    Args:
        k: Minimum number of representations required
        limit: Upper bound on search
        
    Returns:
        List of (n, representations) sorted by n
    """
    sums: Dict[int, List[Tuple[int, int]]] = defaultdict(list)
    
    a = 1
    while a ** 3 < limit:
        b = a
        while a ** 3 + b ** 3 <= limit:
            s = a ** 3 + b ** 3
            sums[s].append((a, b))
            b += 1
        a += 1
    
    results = [(s, reps) for s, reps in sums.items() if len(reps) >= k]
    results.sort()
    return results


def find_smallest_taxicab(k: int, limit: int = 10**9) -> Optional[int]:
    """
    Find Ta(k), the smallest k-taxicab number.
    
    Args:
        k: Order of taxicab number
        limit: Search bound
        
    Returns:
        The smallest k-taxicab number, or None if not found within limit
    """
    results = find_taxicab_numbers(k, limit)
    return results[0][0] if results else None


def euler_parametric_family(alpha: int, beta: int) -> Tuple[int, Tuple[int, int]]:
    """
    Generate a sum-of-cubes decomposition using Euler's parametric identity.
    
    For integers α, β, the identity gives:
    (α·Q)³ + (β·Q)³ = (α³ + β³)·Q³
    where Q = α² + αβ + β².
    
    Args:
        alpha: First parameter
        beta: Second parameter
        
    Returns:
        (N, (a, b)) where N = a³ + b³
    """
    Q = alpha ** 2 + alpha * beta + beta ** 2
    a = abs(alpha * Q)
    b = abs(beta * Q)
    if a > b:
        a, b = b, a
    N = a ** 3 + b ** 3
    return N, (a, b)


def scaling_family(n: int, reps: List[Tuple[int, int]], 
                   m: int) -> Tuple[int, List[Tuple[int, int]]]:
    """
    Apply the Scaling Lemma to generate a new taxicab number.
    
    If n = a³ + b³ in multiple ways, then n·m³ = (am)³ + (bm)³.
    
    Args:
        n: Original taxicab number
        reps: Representations of n
        m: Scaling factor
        
    Returns:
        (n·m³, scaled_representations)
    """
    new_n = n * m ** 3
    new_reps = [(a * m, b * m) for a, b in reps]
    return new_n, new_reps


def verify_cubic_lower_bound(k: int, n: int) -> bool:
    """
    Verify the cubic lower bound: if n is a k-taxicab number, then n > k³.
    
    Args:
        k: Order
        n: Candidate taxicab number
        
    Returns:
        True if the bound is satisfied
    """
    reps = find_cube_representations(n)
    if len(reps) < k:
        return False
    return n > k ** 3


def verify_pair_sum_uniqueness(n: int) -> bool:
    """
    Verify the Same-Sum Uniqueness Theorem for a specific n.
    
    Checks that all cube representations of n have distinct pair-sums.
    
    Args:
        n: Number to verify
        
    Returns:
        True if all pair-sums are distinct (theorem holds)
    """
    reps = find_cube_representations(n)
    pair_sums = [a + b for a, b in reps]
    return len(pair_sums) == len(set(pair_sums))


def priority_queue_taxicab_search(k: int, count: int = 10) -> List[Tuple[int, List[Tuple[int, int]]]]:
    """
    Memory-efficient taxicab search using a priority queue.
    
    Uses a min-heap to generate sums a³ + b³ in sorted order,
    detecting collisions efficiently.
    
    Algorithm:
    1. Initialize heap with entries (a³ + a³, a, a) for a = 1, 2, ...
    2. Pop minimum, push (a³ + (b+1)³, a, b+1)
    3. Track consecutive equal values for k-way matches
    
    Args:
        k: Minimum number of representations
        count: Number of results to find
        
    Returns:
        List of (n, representations) for the first `count` k-taxicab numbers
    """
    # Initialize heap
    heap: List[Tuple[int, int, int]] = []
    max_a = 10000  # Adjustable bound
    
    for a in range(1, max_a + 1):
        heapq.heappush(heap, (2 * a ** 3, a, a))
    
    results: List[Tuple[int, List[Tuple[int, int]]]] = []
    current_value = -1
    current_reps: List[Tuple[int, int]] = []
    
    while heap and len(results) < count:
        val, a, b = heapq.heappop(heap)
        
        # Push next entry
        if b + 1 <= max_a * 2:
            heapq.heappush(heap, (a ** 3 + (b + 1) ** 3, a, b + 1))
        
        if val == current_value:
            current_reps.append((a, b))
        else:
            if len(current_reps) >= k:
                results.append((current_value, current_reps[:]))
            current_value = val
            current_reps = [(a, b)]
    
    # Check last group
    if len(current_reps) >= k:
        results.append((current_value, current_reps[:]))
    
    return results


def analyze_taxicab_statistics(limit: int = 10**6) -> Dict[str, any]:
    """
    Compute statistics about taxicab numbers below a limit.
    
    Args:
        limit: Upper bound for search
        
    Returns:
        Dictionary with statistics
    """
    all_taxicabs = find_taxicab_numbers(2, limit)
    
    stats = {
        "limit": limit,
        "count_2way": len(all_taxicabs),
        "count_3way": sum(1 for _, reps in all_taxicabs if len(reps) >= 3),
        "smallest_2way": all_taxicabs[0][0] if all_taxicabs else None,
        "largest_2way": all_taxicabs[-1][0] if all_taxicabs else None,
        "signatures": [(n, [a+b for a, b in reps]) for n, reps in all_taxicabs[:10]],
    }
    
    # Verify modular signature conjecture
    mod6_violations = 0
    for n, reps in all_taxicabs:
        mods = set((a + b) % 6 for a, b in reps)
        if len(mods) > 1:
            mod6_violations += 1
    stats["mod6_violations"] = mod6_violations
    
    return stats


if __name__ == "__main__":
    # Quick demonstration
    print("Finding 2-way taxicab numbers below 1,000,000:")
    results = find_taxicab_numbers(2, 1_000_000)
    for n, reps in results[:10]:
        sig = [a + b for a, b in reps]
        print(f"  {n:>10,} = " + " = ".join(f"{a}³+{b}³" for a, b in reps) + f"  Sig={sig}")
    print(f"  ... ({len(results)} total)")
    
    print(f"\nStatistics:")
    stats = analyze_taxicab_statistics(1_000_000)
    print(f"  2-way taxicab numbers below 1M: {stats['count_2way']}")
    print(f"  3-way taxicab numbers below 1M: {stats['count_3way']}")
    print(f"  Mod-6 signature violations: {stats['mod6_violations']}")
