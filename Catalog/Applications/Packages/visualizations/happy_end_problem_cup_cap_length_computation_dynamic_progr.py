#!/usr/bin/env python3
"""
Algorithms for the Erdős–Szekeres Happy End Problem.

Implements:
1. Dynamic programming for cup/cap lengths (O(n²) time, O(n) space)
2. Convex chain signature computation
3. Convex polygon witness extraction
4. Cups-caps forcing verification
"""

from typing import List, Tuple, Optional, Dict
from itertools import combinations
import math

Point = Tuple[float, float]


def orient(a: Point, b: Point, c: Point) -> float:
    """Compute orientation of triple (a, b, c).

    Returns positive for counterclockwise, negative for clockwise,
    zero for collinear.

    Time: O(1), Space: O(1)
    """
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def compute_cup_cap_lengths(points: List[Point]) -> List[Tuple[int, int]]:
    """Compute (maxCupLen, maxCapLen) at each point using dynamic programming.

    Algorithm:
    - For each point j (left to right), examine all earlier points i.
    - If the cup ending at i can be extended by j (orient > 0), update cupLen[j].
    - If the cap ending at i can be extended by j (orient < 0), update capLen[j].

    Time: O(n²), Space: O(n)

    Args:
        points: List of points sorted by x-coordinate.

    Returns:
        List of (cupLen, capLen) pairs, one per point.
    """
    n = len(points)
    cup_len = [1] * n
    cap_len = [1] * n
    cup_pred = [-1] * n  # index of second-to-last in best cup
    cap_pred = [-1] * n  # index of second-to-last in best cap

    for j in range(1, n):
        best_cup = 1
        best_cup_pred = -1
        best_cap = 1
        best_cap_pred = -1

        for i in range(j):
            # Try extending cup at i by j
            if cup_len[i] == 1:
                # Any single point extends to a 2-cup with j
                if 2 > best_cup:
                    best_cup = 2
                    best_cup_pred = i
            elif cup_pred[i] >= 0:
                o = orient(points[cup_pred[i]], points[i], points[j])
                if o > 0 and cup_len[i] + 1 > best_cup:
                    best_cup = cup_len[i] + 1
                    best_cup_pred = i

            # Try extending cap at i by j
            if cap_len[i] == 1:
                if 2 > best_cap:
                    best_cap = 2
                    best_cap_pred = i
            elif cap_pred[i] >= 0:
                o = orient(points[cap_pred[i]], points[i], points[j])
                if o < 0 and cap_len[i] + 1 > best_cap:
                    best_cap = cap_len[i] + 1
                    best_cap_pred = i

        cup_len[j] = best_cup
        cup_pred[j] = best_cup_pred
        cap_len[j] = best_cap
        cap_pred[j] = best_cap_pred

    return list(zip(cup_len, cap_len))


def extract_cup_witness(points: List[Point], target_len: int) -> Optional[List[int]]:
    """Extract a cup of at least target_len points.

    Uses DP to find the longest cup, then backtracks to reconstruct it.

    Time: O(n²), Space: O(n)

    Args:
        points: X-sorted points in general position.
        target_len: Minimum cup length desired.

    Returns:
        List of indices forming a cup, or None if not found.
    """
    n = len(points)
    dp = [1] * n
    prev = [-1] * n
    pred = [-1] * n  # second-to-last in the best cup ending at each index

    for j in range(1, n):
        for i in range(j):
            if dp[i] == 1:
                if 2 > dp[j]:
                    dp[j] = 2
                    prev[j] = i
                    pred[j] = i
            elif pred[i] >= 0:
                if orient(points[pred[i]], points[i], points[j]) > 0:
                    if dp[i] + 1 > dp[j]:
                        dp[j] = dp[i] + 1
                        prev[j] = i
                        pred[j] = i

    # Find best endpoint
    best_idx = max(range(n), key=lambda i: dp[i])
    if dp[best_idx] < target_len:
        return None

    # Backtrack
    chain = []
    idx = best_idx
    while idx >= 0:
        chain.append(idx)
        idx = prev[idx]
    chain.reverse()
    return chain


def extract_cap_witness(points: List[Point], target_len: int) -> Optional[List[int]]:
    """Extract a cap of at least target_len points. Same algorithm but orient < 0."""
    n = len(points)
    dp = [1] * n
    prev = [-1] * n
    pred = [-1] * n

    for j in range(1, n):
        for i in range(j):
            if dp[i] == 1:
                if 2 > dp[j]:
                    dp[j] = 2
                    prev[j] = i
                    pred[j] = i
            elif pred[i] >= 0:
                if orient(points[pred[i]], points[i], points[j]) < 0:
                    if dp[i] + 1 > dp[j]:
                        dp[j] = dp[i] + 1
                        prev[j] = i
                        pred[j] = i

    best_idx = max(range(n), key=lambda i: dp[i])
    if dp[best_idx] < target_len:
        return None

    chain = []
    idx = best_idx
    while idx >= 0:
        chain.append(idx)
        idx = prev[idx]
    chain.reverse()
    return chain


def find_convex_polygon(points: List[Point], n: int) -> Optional[Tuple[str, List[int]]]:
    """Find an ordered convex n-gon (n-cup or n-cap) in the point set.

    Time: O(N²) where N = len(points)
    Space: O(N)

    Args:
        points: X-sorted points in general position.
        n: Desired polygon size.

    Returns:
        Tuple of ("cup" or "cap", list of indices), or None.
    """
    cup = extract_cup_witness(points, n)
    if cup is not None:
        return ("cup", cup[:n])
    cap = extract_cap_witness(points, n)
    if cap is not None:
        return ("cap", cap[:n])
    return None


def verify_cup(points: List[Point], indices: List[int]) -> bool:
    """Verify that the given indices form a valid cup."""
    if len(indices) < 3:
        return True
    pts = [points[i] for i in indices]
    for k in range(len(pts) - 2):
        if orient(pts[k], pts[k+1], pts[k+2]) <= 0:
            return False
    return True


def verify_cap(points: List[Point], indices: List[int]) -> bool:
    """Verify that the given indices form a valid cap."""
    if len(indices) < 3:
        return True
    pts = [points[i] for i in indices]
    for k in range(len(pts) - 2):
        if orient(pts[k], pts[k+1], pts[k+2]) >= 0:
            return False
    return True


def cups_caps_bound(r: int, s: int) -> int:
    """The tight cups-caps extremal bound: C(r+s-4, r-2) + 1.

    This is the minimum number of x-sorted GP points that guarantees
    either an r-cup or an s-cap.

    Time: O(r + s), Space: O(1)
    """
    if r < 2 or s < 2:
        return 2
    return math.comb(r + s - 4, r - 2) + 1


def happy_end_bound(n: int) -> int:
    """Upper bound on ES(n) via cups-caps: C(2n-4, n-2) + 1."""
    if n < 3:
        return n
    return math.comb(2 * n - 4, n - 2) + 1


# Example usage
if __name__ == "__main__":
    import random

    print("Algorithms for the Happy End Problem")
    print("=" * 50)

    # Generate test points
    random.seed(42)
    N = 15
    pts = sorted(
        [(random.uniform(-10, 10), random.uniform(-10, 10)) for _ in range(N)],
        key=lambda p: p[0]
    )

    print(f"\n{N} random points (x-sorted):")
    sigs = compute_cup_cap_lengths(pts)
    for i, ((c, d), p) in enumerate(zip(sigs, pts)):
        print(f"  [{i}] ({p[0]:+.2f}, {p[1]:+.2f})  cup={c} cap={d}")

    print(f"\nMax cup length: {max(c for c, d in sigs)}")
    print(f"Max cap length: {max(d for c, d in sigs)}")

    # Try to find convex polygons
    for target in [3, 4, 5]:
        result = find_convex_polygon(pts, target)
        if result:
            ctype, indices = result
            print(f"\nFound {target}-{ctype}: {indices}")
            if ctype == "cup":
                print(f"  Valid cup: {verify_cup(pts, indices)}")
            else:
                print(f"  Valid cap: {verify_cap(pts, indices)}")
        else:
            print(f"\nNo ordered convex {target}-gon found")

    # Print bounds table
    print("\nCups-caps bounds f(r,s):")
    print("     ", "  ".join(f"s={s}" for s in range(2, 7)))
    for r in range(2, 7):
        vals = [str(cups_caps_bound(r, s)).rjust(4) for s in range(2, 7)]
        print(f"r={r}:", "  ".join(vals))

    print("\nHappy End bounds:")
    for n in range(3, 9):
        print(f"  ES({n}) ≤ {happy_end_bound(n)}")
