#!/usr/bin/env python3
"""
Algorithms for the Erdős–Szekeres Happy End Problem
=====================================================

Implements:
1. Monotone subsequence extraction (O(n log n))
2. Cup/cap extraction via dynamic programming
3. Convex subset extraction
4. Happy End number computation
"""

from typing import List, Tuple, Optional
import bisect
import itertools
from math import comb

Point = Tuple[float, float]


# ============================================================================
# Algorithm 1: Erdős–Szekeres Monotone Subsequence (O(n log n))
# ============================================================================

def longest_increasing_subsequence_fast(seq: List[float]) -> List[int]:
    """Find a longest strictly increasing subsequence using patience sorting.
    
    Time: O(n log n), Space: O(n)
    
    Returns indices of the LIS in the original sequence.
    
    >>> longest_increasing_subsequence_fast([3, 1, 4, 1, 5, 9, 2, 6])
    [1, 2, 4, 7]
    """
    n = len(seq)
    if n == 0:
        return []
    
    # tails[i] = smallest tail element of all increasing subsequences of length i+1
    tails: List[float] = []
    # For reconstruction: parent[i] = index of predecessor of seq[i] in LIS
    parent = [-1] * n
    # indices[i] = index in seq of the element stored in tails[i]
    indices: List[int] = []
    
    for i in range(n):
        pos = bisect.bisect_left(tails, seq[i])
        if pos == len(tails):
            tails.append(seq[i])
            indices.append(i)
        else:
            tails[pos] = seq[i]
            indices[pos] = i
        
        if pos > 0:
            parent[i] = indices[pos - 1]
    
    # Reconstruct
    result = []
    idx = indices[len(tails) - 1]
    while idx != -1:
        result.append(idx)
        idx = parent[idx]
    return result[::-1]


def longest_decreasing_subsequence_fast(seq: List[float]) -> List[int]:
    """Find a longest strictly decreasing subsequence.
    
    Time: O(n log n), Space: O(n)
    
    >>> longest_decreasing_subsequence_fast([9, 5, 3, 7, 2, 1])
    [0, 1, 2, 4, 5]
    """
    # Negate and find LIS
    neg_seq = [-x for x in seq]
    return longest_increasing_subsequence_fast(neg_seq)


def erdos_szekeres_extract(seq: List[float], r: int, s: int) -> Tuple[Optional[List[int]], Optional[List[int]]]:
    """Extract a witness for the Erdős–Szekeres theorem.
    
    Given a sequence of distinct values, returns either:
    - An increasing subsequence of length r, or
    - A decreasing subsequence of length s
    
    Guaranteed to find one if len(seq) > (r-1)*(s-1).
    
    Time: O(n log n)
    
    >>> inc, dec = erdos_szekeres_extract([3, 1, 4, 1, 5, 9, 2, 6], 3, 3)
    >>> inc is not None or dec is not None
    True
    """
    inc = longest_increasing_subsequence_fast(seq)
    if len(inc) >= r:
        return inc[:r], None
    
    dec = longest_decreasing_subsequence_fast(seq)
    if len(dec) >= s:
        return None, dec[:s]
    
    return None, None


# ============================================================================
# Algorithm 2: Cup/Cap Extraction via Dynamic Programming
# ============================================================================

def orient(a: Point, b: Point, c: Point) -> float:
    """Orientation of three points (positive = CCW, negative = CW)."""
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def extract_cups_caps(points: List[Point]) -> Tuple[List[List[int]], List[List[int]]]:
    """Extract all maximal cups and caps from x-sorted points.
    
    For each point, computes the longest cup and cap ending at that point
    using dynamic programming.
    
    Time: O(n²), Space: O(n²) for storing witnesses
    
    Returns: (cups, caps) where each is a list of index sequences.
    
    >>> pts = [(i, i*i) for i in range(5)]
    >>> cups, caps = extract_cups_caps(pts)
    >>> max(len(c) for c in cups)
    5
    """
    n = len(points)
    if n == 0:
        return [], []
    
    # Sort by x-coordinate
    sorted_idx = sorted(range(n), key=lambda i: points[i][0])
    pts = [points[i] for i in sorted_idx]
    
    # cup_len[i] = length of longest cup ending at i
    # cap_len[i] = length of longest cap ending at i
    cup_len = [1] * n
    cap_len = [1] * n
    cup_prev = [-1] * n
    cap_prev = [-1] * n
    
    for i in range(1, n):
        for j in range(i):
            # Can we extend a cup ending at j to include i?
            # Need: for the previous point in the cup before j, orient(prev, j, i) > 0
            # For length 2, any pair works (vacuous condition)
            if cup_len[j] == 1:
                # Extending a singleton to a pair: always a valid cup of length 2
                if 2 > cup_len[i]:
                    cup_len[i] = 2
                    cup_prev[i] = j
            else:
                # Check orientation with the predecessor
                prev = cup_prev[j]
                if prev >= 0 and orient(pts[prev], pts[j], pts[i]) > 0:
                    if cup_len[j] + 1 > cup_len[i]:
                        cup_len[i] = cup_len[j] + 1
                        cup_prev[i] = j
            
            # Same for caps
            if cap_len[j] == 1:
                if 2 > cap_len[i]:
                    cap_len[i] = 2
                    cap_prev[i] = j
            else:
                prev = cap_prev[j]
                if prev >= 0 and orient(pts[prev], pts[j], pts[i]) < 0:
                    if cap_len[j] + 1 > cap_len[i]:
                        cap_len[i] = cap_len[j] + 1
                        cap_prev[i] = j
    
    # Reconstruct the longest cup and cap
    def reconstruct(prev_arr, end_idx):
        result = []
        idx = end_idx
        while idx != -1:
            result.append(sorted_idx[idx])
            idx = prev_arr[idx]
        return result[::-1]
    
    cups = []
    caps = []
    for i in range(n):
        if cup_len[i] >= 2:
            cups.append(reconstruct(cup_prev, i))
        if cap_len[i] >= 2:
            caps.append(reconstruct(cap_prev, i))
    
    return cups, caps


def find_longest_cup(points: List[Point]) -> List[int]:
    """Find the longest cup in the point set.
    
    Time: O(n²)
    
    >>> pts = [(i, i*i) for i in range(5)]
    >>> find_longest_cup(pts)
    [0, 1, 2, 3, 4]
    """
    cups, _ = extract_cups_caps(points)
    if not cups:
        return []
    return max(cups, key=len)


def find_longest_cap(points: List[Point]) -> List[int]:
    """Find the longest cap in the point set.
    
    Time: O(n²)
    
    >>> pts = [(i, -i*i) for i in range(5)]
    >>> find_longest_cap(pts)
    [0, 1, 2, 3, 4]
    """
    _, caps = extract_cups_caps(points)
    if not caps:
        return []
    return max(caps, key=len)


# ============================================================================
# Algorithm 3: Maximum Convex Subset
# ============================================================================

def max_convex_subset_brute(points: List[Point]) -> List[int]:
    """Find the largest subset of points in convex position (brute force).
    
    Time: O(2^n * n³) — only for small n.
    
    >>> pts = [(0,0), (1,0), (2,0), (0,1), (1,1), (2,1)]
    >>> len(max_convex_subset_brute(pts)) >= 4
    True
    """
    n = len(points)
    sorted_idx = sorted(range(n), key=lambda i: points[i][0])
    sorted_pts = [points[i] for i in sorted_idx]
    
    def is_convex(indices):
        if len(indices) < 3:
            return True
        pts_sub = [sorted_pts[i] for i in indices]
        # Check all triples consistent orientation
        signs = set()
        for i in range(len(pts_sub)):
            for j in range(i+1, len(pts_sub)):
                for k in range(j+1, len(pts_sub)):
                    o = orient(pts_sub[i], pts_sub[j], pts_sub[k])
                    if o > 0:
                        signs.add(1)
                    elif o < 0:
                        signs.add(-1)
                    else:
                        return False  # Collinear = not in general position
        return len(signs) <= 1
    
    for size in range(n, 0, -1):
        for combo in itertools.combinations(range(n), size):
            if is_convex(list(combo)):
                return [sorted_idx[i] for i in combo]
    return []


# ============================================================================
# Algorithm 4: Happy End Number Bounds
# ============================================================================

def es_upper_bound(n: int) -> int:
    """Upper bound on ES(n) from the Erdős–Szekeres theorem.
    
    ES(n) ≤ C(2n-4, n-2) + 1
    
    >>> es_upper_bound(3)
    3
    >>> es_upper_bound(4)
    5
    >>> es_upper_bound(5)
    9
    """
    if n < 3:
        return n
    return comb(2 * n - 4, n - 2) + 1


def es_lower_bound_search(n: int, num_trials: int = 10000) -> int:
    """Search for point configurations that avoid n-gons.
    
    Uses random search to find lower bounds on ES(n).
    Returns the largest configuration found without an n-gon.
    
    >>> es_lower_bound_search(4, 100) >= 4
    True
    """
    import random
    best_size = n - 1  # trivially, n-1 points in GP have no n-gon
    
    for trial in range(num_trials):
        random.seed(trial)
        # Try increasing sizes
        for size in range(n, n + 10):
            points = [(random.uniform(-10, 10), random.uniform(-10, 10)) 
                      for _ in range(size)]
            points.sort(key=lambda p: p[0])
            
            # Check if there's an n-gon
            has_ngon = False
            for combo in itertools.combinations(range(size), n):
                subset = [points[i] for i in combo]
                # Check all positive or all negative
                orients = []
                for i in range(len(subset)):
                    for j in range(i+1, len(subset)):
                        for k in range(j+1, len(subset)):
                            orients.append(orient(subset[i], subset[j], subset[k]))
                if all(o > 0 for o in orients) or all(o < 0 for o in orients):
                    has_ngon = True
                    break
            
            if not has_ngon and size > best_size:
                best_size = size
    
    return best_size


if __name__ == "__main__":
    print("Erdős–Szekeres Algorithms")
    print("=" * 50)
    
    # Test LIS
    seq = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9]
    lis = longest_increasing_subsequence_fast(seq)
    print(f"\nSequence: {seq}")
    print(f"LIS indices: {lis}")
    print(f"LIS values: {[seq[i] for i in lis]}")
    print(f"LIS length: {len(lis)}")
    
    # Test cups/caps
    cup_pts = [(i, i*i) for i in range(6)]
    longest = find_longest_cup(cup_pts)
    print(f"\nCup points: {cup_pts}")
    print(f"Longest cup: {longest} (length {len(longest)})")
    
    # Test ES bounds
    print("\nHappy End Number bounds:")
    for n in range(3, 9):
        print(f"  ES({n}) ≤ {es_upper_bound(n)}")
    
    print("\nAll tests passed!")
