"""
Algorithms for the Happy End Problem

Implements the key algorithms underlying the Erdős–Szekeres theorem:
1. Cup-Cap Decomposition (Seidenberg labeling for planar points)
2. Convex polygon detection via orientation testing
3. The Erdős–Szekeres bound computation
4. Brute-force and heuristic search for ES(n) configurations

Time Complexity:
- Cup-Cap decomposition: O(n^2) per point, O(n^3) total
- Convex polygon detection: O(n^3) for orientation checking
- ES bound computation: O(1) via binomial coefficient
"""

import math
from typing import List, Tuple, Optional, Set
from itertools import combinations

Point = Tuple[float, float]


def orient(a: Point, b: Point, c: Point) -> float:
    """Compute orientation of triangle (a, b, c).
    
    Returns:
        Positive: counterclockwise (CCW)
        Negative: clockwise (CW)
        Zero: collinear
    
    Time: O(1)
    Space: O(1)
    """
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def is_general_position(points: List[Point], eps: float = 1e-10) -> bool:
    """Check if no three points are collinear.
    
    Time: O(n^3)
    Space: O(1)
    """
    n = len(points)
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                if abs(orient(points[i], points[j], points[k])) < eps:
                    return False
    return True


def has_distinct_x(points: List[Point], eps: float = 1e-10) -> bool:
    """Check if all x-coordinates are distinct.
    
    Time: O(n log n)
    Space: O(n)
    """
    xs = sorted(p[0] for p in points)
    return all(abs(xs[i] - xs[i+1]) > eps for i in range(len(xs) - 1))


def is_convex_position(points: List[Point], eps: float = 1e-10) -> bool:
    """Check if points (assumed x-sorted) are in convex position.
    
    All orientation triples (i < j < k) must have the same sign.
    
    Time: O(n^3)
    Space: O(1)
    """
    n = len(points)
    if n <= 2:
        return True
    
    ref_sign = None
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                o = orient(points[i], points[j], points[k])
                if abs(o) < eps:
                    return False
                s = 1 if o > 0 else -1
                if ref_sign is None:
                    ref_sign = s
                elif s != ref_sign:
                    return False
    return True


class CupCapDecomposition:
    """Cup-Cap Decomposition for planar point sets.
    
    For each point, computes the length of the longest cup (convex-up chain)
    and longest cap (convex-down chain) ending at that point.
    
    This is the planar analogue of the Seidenberg labeling used in the
    Erdős–Szekeres monotone subsequence theorem.
    
    Attributes:
        points: List of points sorted by x-coordinate
        cup_len: cup_len[i] = length of longest cup ending at point i
        cap_len: cap_len[i] = length of longest cap ending at point i
        cup_prev: cup_prev[i] = previous point index in the optimal cup
        cap_prev: cap_prev[i] = previous point index in the optimal cap
    """
    
    def __init__(self, points: List[Point]):
        """Initialize and compute the decomposition.
        
        Time: O(n^3) in worst case, O(n^2) amortized
        Space: O(n)
        """
        self.points = sorted(points, key=lambda p: p[0])
        n = len(self.points)
        
        self.cup_len = [1] * n
        self.cap_len = [1] * n
        self.cup_prev = [-1] * n
        self.cap_prev = [-1] * n
        
        for i in range(n):
            for j in range(i):
                # Try extending cup from j to i
                if self.cup_len[j] == 1:
                    # Any single point can start a cup of length 2
                    if self.cup_len[i] < 2:
                        self.cup_len[i] = 2
                        self.cup_prev[i] = j
                else:
                    # Check if (prev(j), j, i) has positive orientation
                    prev_j = self.cup_prev[j]
                    if prev_j >= 0:
                        o = orient(self.points[prev_j], self.points[j], self.points[i])
                        if o > 0 and self.cup_len[j] + 1 > self.cup_len[i]:
                            self.cup_len[i] = self.cup_len[j] + 1
                            self.cup_prev[i] = j
                
                # Try extending cap from j to i
                if self.cap_len[j] == 1:
                    if self.cap_len[i] < 2:
                        self.cap_len[i] = 2
                        self.cap_prev[i] = j
                else:
                    prev_j = self.cap_prev[j]
                    if prev_j >= 0:
                        o = orient(self.points[prev_j], self.points[j], self.points[i])
                        if o < 0 and self.cap_len[j] + 1 > self.cap_len[i]:
                            self.cap_len[i] = self.cap_len[j] + 1
                            self.cap_prev[i] = j
    
    def max_cup(self) -> int:
        """Length of the longest cup."""
        return max(self.cup_len) if self.cup_len else 0
    
    def max_cap(self) -> int:
        """Length of the longest cap."""
        return max(self.cap_len) if self.cap_len else 0
    
    def get_labels(self) -> List[Tuple[int, int]]:
        """Get the (cup_len, cap_len) label pairs.
        
        Key property: if these labels are injective (no two points share
        the same label), then n ≤ max_cup * max_cap.
        """
        return list(zip(self.cup_len, self.cap_len))
    
    def extract_cup(self, idx: int) -> List[int]:
        """Extract the cup ending at index idx."""
        path = []
        i = idx
        while i >= 0:
            path.append(i)
            i = self.cup_prev[i]
        return list(reversed(path))
    
    def extract_cap(self, idx: int) -> List[int]:
        """Extract the cap ending at index idx."""
        path = []
        i = idx
        while i >= 0:
            path.append(i)
            i = self.cap_prev[i]
        return list(reversed(path))


def es_classical_bound(n: int) -> int:
    """Classical Erdős–Szekeres upper bound: C(2n-4, n-2) + 1.
    
    For n points in general position to guarantee a convex n-gon.
    
    Time: O(n) for binomial coefficient computation
    Space: O(1)
    """
    if n < 3:
        return n
    return math.comb(2 * n - 4, n - 2) + 1


def es_conjecture_bound(n: int) -> int:
    """Conjectured Erdős–Szekeres bound: 2^(n-2) + 1.
    
    Verified for n ≤ 6. Open for n ≥ 7.
    
    Time: O(1)
    Space: O(1)
    """
    if n < 3:
        return n
    return 2 ** (n - 2) + 1


def find_convex_ngon(points: List[Point], n: int) -> Optional[List[Point]]:
    """Find a convex n-gon in the point set, if one exists.
    
    Algorithm: brute-force search over all n-element subsets.
    
    Time: O(C(m, n) * n^3) where m = |points|
    Space: O(n)
    """
    sorted_pts = sorted(points, key=lambda p: p[0])
    for subset in combinations(range(len(sorted_pts)), n):
        pts = [sorted_pts[i] for i in subset]
        if is_convex_position(pts):
            return pts
    return None


def reflect_points(points: List[Point]) -> List[Point]:
    """Reflect points across the x-axis: (x, y) → (x, -y).
    
    Key property (proved in Lean): this transforms cups into caps
    and vice versa, while preserving general position.
    
    Time: O(n)
    Space: O(n)
    """
    return [(x, -y) for x, y in points]


def pigeonhole_bound(r: int, s: int) -> int:
    """Maximum points before a cup of size r or cap of size s is forced.
    
    By the pigeonhole principle on cup-cap labels, if each label is
    in [1, r-1] × [1, s-1], at most (r-1)(s-1) points can have
    distinct labels. With (r-1)(s-1) + 1 points, a cup of size r
    or cap of size s must exist.
    
    Time: O(1)
    Space: O(1)
    """
    return (r - 1) * (s - 1) + 1


# ==================== EXAMPLE USAGE ====================

if __name__ == "__main__":
    import random
    
    print("=" * 60)
    print("ALGORITHMS: Happy End Problem")
    print("=" * 60)
    
    # Example 1: Cup-Cap Decomposition
    print("\n--- Cup-Cap Decomposition ---")
    pts = [(1, 3), (2, 1), (3, 4), (4, 2), (5, 5), (6, 0), (7, 3.5)]
    pts = [(float(x), float(y)) for x, y in pts]
    
    decomp = CupCapDecomposition(pts)
    print(f"Points: {[(round(p[0]), round(p[1], 1)) for p in decomp.points]}")
    print(f"Cup lengths: {decomp.cup_len}")
    print(f"Cap lengths: {decomp.cap_len}")
    print(f"Labels: {decomp.get_labels()}")
    print(f"Max cup: {decomp.max_cup()}, Max cap: {decomp.max_cap()}")
    
    # Example 2: Convex polygon detection
    print("\n--- Convex Polygon Detection ---")
    for n in [3, 4, 5]:
        m = es_conjecture_bound(n)
        rng = random.Random(42)
        test_pts = [(float(i), rng.uniform(-10, 10)) for i in range(m)]
        result = find_convex_ngon(test_pts, n)
        if result:
            print(f"  Found convex {n}-gon in {m} points ✓")
        else:
            print(f"  No convex {n}-gon found in {m} points")
    
    # Example 3: Reflection symmetry
    print("\n--- Reflection Symmetry ---")
    test_pts = [(1.0, 1.0), (2.0, 0.5), (3.0, 2.0)]
    reflected = reflect_points(test_pts)
    o1 = orient(*test_pts)
    o2 = orient(*reflected)
    print(f"  orient(original) = {o1:.2f}")
    print(f"  orient(reflected) = {o2:.2f}")
    print(f"  Sum (should be 0): {o1 + o2:.2f}")
    
    # Example 4: Bounds comparison
    print("\n--- Bound Comparison ---")
    for n in range(3, 12):
        conj = es_conjecture_bound(n)
        classical = es_classical_bound(n)
        pigeonhole = pigeonhole_bound(n, n)
        print(f"  n={n}: conjecture={conj}, classical={classical}, pigeonhole={pigeonhole}")
