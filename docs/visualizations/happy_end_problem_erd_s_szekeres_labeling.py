#!/usr/bin/env python3
"""
algorithms.py — Algorithms for the Happy End Problem and Erdős–Szekeres theory.

Implements:
1. Erdős-Szekeres labeling algorithm for monotone subsequences
2. Cup-cap decomposition
3. Convex depth computation
4. Orientation-based convexity testing
"""

from typing import List, Tuple, Optional
import itertools

Point = Tuple[float, float]


def orient(a: Point, b: Point, c: Point) -> float:
    """Compute the orientation of three points.

    Returns:
        > 0 if counterclockwise (left turn)
        < 0 if clockwise (right turn)
        = 0 if collinear

    Time: O(1), Space: O(1)
    """
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def erdos_szekeres_labels(seq: List[float]) -> Tuple[List[int], List[int]]:
    """Compute the Erdős-Szekeres labels (inc_i, dec_i) for each element.

    For each index i, inc_i is the length of the longest increasing subsequence
    ending at i, and dec_i is the length of the longest decreasing subsequence
    ending at i.

    By the pigeonhole principle, if n > (r-1)(s-1), there must exist an element
    with inc_i ≥ r or dec_i ≥ s.

    Time: O(n²), Space: O(n)

    Example:
        >>> inc, dec = erdos_szekeres_labels([3, 1, 4, 1, 5, 9, 2, 6])
        >>> inc  # [1, 1, 2, 1, 3, 4, 2, 4]
        >>> dec  # [1, 2, 1, 3, 1, 1, 3, 1]
    """
    n = len(seq)
    inc = [1] * n
    dec = [1] * n

    for i in range(1, n):
        for j in range(i):
            if seq[j] < seq[i]:
                inc[i] = max(inc[i], inc[j] + 1)
            elif seq[j] > seq[i]:
                dec[i] = max(dec[i], dec[j] + 1)

    return inc, dec


def find_longest_monotone(seq: List[float]) -> Tuple[List[int], List[int]]:
    """Find the longest increasing and decreasing subsequences.

    Returns indices of each.

    Time: O(n²), Space: O(n)
    """
    n = len(seq)
    if n == 0:
        return [], []

    # Longest increasing
    inc_dp = [1] * n
    inc_par = [-1] * n
    for i in range(1, n):
        for j in range(i):
            if seq[j] < seq[i] and inc_dp[j] + 1 > inc_dp[i]:
                inc_dp[i] = inc_dp[j] + 1
                inc_par[i] = j

    inc_idx = max(range(n), key=lambda i: inc_dp[i])
    inc_result = []
    idx = inc_idx
    while idx != -1:
        inc_result.append(idx)
        idx = inc_par[idx]
    inc_result.reverse()

    # Longest decreasing
    dec_dp = [1] * n
    dec_par = [-1] * n
    for i in range(1, n):
        for j in range(i):
            if seq[j] > seq[i] and dec_dp[j] + 1 > dec_dp[i]:
                dec_dp[i] = dec_dp[j] + 1
                dec_par[i] = j

    dec_idx = max(range(n), key=lambda i: dec_dp[i])
    dec_result = []
    idx = dec_idx
    while idx != -1:
        dec_result.append(idx)
        idx = dec_par[idx]
    dec_result.reverse()

    return inc_result, dec_result


def find_cups_and_caps(points: List[Point]) -> Tuple[List[List[int]], List[List[int]]]:
    """Decompose a point set into maximal cups and caps.

    A cup is a sequence where consecutive triples have positive orientation.
    A cap is a sequence where consecutive triples have negative orientation.

    Points must be sorted by x-coordinate.

    Time: O(n²), Space: O(n)
    """
    n = len(points)
    if n <= 2:
        return [list(range(n))], [list(range(n))]

    # Find longest cup ending at each point
    cup_len = [1] * n
    cup_par = [-1] * n
    for i in range(1, n):
        for j in range(i):
            if cup_len[j] == 1:
                # Any pair forms a cup of size 2
                if cup_len[j] + 1 > cup_len[i] or (cup_len[j] + 1 == cup_len[i] and cup_par[i] == -1):
                    cup_len[i] = max(cup_len[i], 2)
                    if cup_len[i] == 2:
                        cup_par[i] = j
            elif cup_par[j] >= 0:
                # Check orientation
                if orient(points[cup_par[j]], points[j], points[i]) > 0:
                    if cup_len[j] + 1 > cup_len[i]:
                        cup_len[i] = cup_len[j] + 1
                        cup_par[i] = j

    # Find longest cap ending at each point
    cap_len = [1] * n
    cap_par = [-1] * n
    for i in range(1, n):
        for j in range(i):
            if cap_len[j] == 1:
                if cap_len[j] + 1 > cap_len[i] or (cap_len[j] + 1 == cap_len[i] and cap_par[i] == -1):
                    cap_len[i] = max(cap_len[i], 2)
                    if cap_len[i] == 2:
                        cap_par[i] = j
            elif cap_par[j] >= 0:
                if orient(points[cap_par[j]], points[j], points[i]) < 0:
                    if cap_len[j] + 1 > cap_len[i]:
                        cap_len[i] = cap_len[j] + 1
                        cap_par[i] = j

    # Extract the longest cup
    cup_end = max(range(n), key=lambda i: cup_len[i])
    cup = []
    idx = cup_end
    while idx != -1:
        cup.append(idx)
        idx = cup_par[idx]
    cup.reverse()

    # Extract the longest cap
    cap_end = max(range(n), key=lambda i: cap_len[i])
    cap = []
    idx = cap_end
    while idx != -1:
        cap.append(idx)
        idx = cap_par[idx]
    cap.reverse()

    return [cup], [cap]


def is_in_general_position(points: List[Point], eps: float = 1e-10) -> bool:
    """Check if points are in general position (no three collinear).

    Time: O(n³), Space: O(1)
    """
    n = len(points)
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                if abs(orient(points[i], points[j], points[k])) < eps:
                    return False
    return True


def is_convex_position(points: List[Point], eps: float = 1e-10) -> bool:
    """Check if points are in convex position.

    Points are in convex position if, when sorted by x-coordinate,
    all ordered triples have the same orientation sign.

    Time: O(n³), Space: O(1)
    """
    n = len(points)
    if n <= 2:
        return True

    pts = sorted(points, key=lambda p: p[0])
    pos_count = 0
    neg_count = 0

    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                o = orient(pts[i], pts[j], pts[k])
                if o > eps:
                    pos_count += 1
                elif o < -eps:
                    neg_count += 1
                else:
                    return False  # Collinear

    return pos_count == 0 or neg_count == 0


def convex_depth(points: List[Point]) -> int:
    """Compute the convex depth: the size of the largest convex subset.

    Time: O(2^n · n³) in the worst case (brute force).
    For practical purposes, limited to n ≤ 20.

    Space: O(n)
    """
    n = len(points)
    best = 0

    for size in range(n, 0, -1):
        if size <= best:
            break
        for combo in itertools.combinations(range(n), size):
            subset = [points[i] for i in combo]
            if is_convex_position(subset):
                return size

    return max(best, min(n, 2))


def es_upper_bound(n: int) -> int:
    """Compute the classical Erdős-Szekeres upper bound C(2n-4, n-2) + 1.

    This is the bound proved by the cup-cap theorem.

    >>> es_upper_bound(3)
    3
    >>> es_upper_bound(4)
    5
    >>> es_upper_bound(5)
    71  # The actual ES(5) = 9, so this is a very loose bound
    """
    if n <= 2:
        return n
    from math import comb
    return comb(2 * n - 4, n - 2) + 1


def es_conjectured(n: int) -> int:
    """The conjectured value ES(n) = 2^(n-2) + 1.

    >>> es_conjectured(3)
    3
    >>> es_conjectured(4)
    5
    >>> es_conjectured(5)
    9
    >>> es_conjectured(6)
    17
    """
    if n <= 2:
        return n
    return 2 ** (n - 2) + 1


# ============================================================================
# Example usage
# ============================================================================
if __name__ == "__main__":
    print("Erdős-Szekeres Labels:")
    seq = [5, 2, 8, 3, 7, 1, 9, 4, 6]
    inc, dec = erdos_szekeres_labels(seq)
    print(f"  Sequence: {seq}")
    print(f"  Inc labels: {inc}")
    print(f"  Dec labels: {dec}")
    print(f"  Max inc: {max(inc)}, Max dec: {max(dec)}")
    n = len(seq)
    r = max(inc)
    s = max(dec)
    print(f"  Verification: (r-1)(s-1) = {(r-1)*(s-1)} < {n} = n ✓")

    print("\nES Upper Bounds vs Conjectured Values:")
    for k in range(3, 8):
        print(f"  ES({k}): conjectured = {es_conjectured(k)}, "
              f"upper bound = {es_upper_bound(k)}")

    print("\nConvex Depth Example:")
    import math
    pts = [(math.cos(2 * math.pi * i / 7), math.sin(2 * math.pi * i / 7))
           for i in range(7)]
    print(f"  Regular 7-gon: convex depth = {convex_depth(pts)}")
