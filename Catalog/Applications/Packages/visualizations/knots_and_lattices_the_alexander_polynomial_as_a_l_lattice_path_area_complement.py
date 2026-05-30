#!/usr/bin/env python3
"""
Algorithms for Knot Lattice Theory
===================================

Implements the core algorithms for computing lattice path properties,
area generating functions, and knot lattice structures.
"""

from itertools import combinations
from math import comb, factorial
from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict


# ============================================================
# Algorithm 1: Lattice Path Area Computation
# Time: O(m + n), Space: O(1)
# ============================================================

def compute_path_area(path: List[bool], start_height: int = 0) -> int:
    """Compute area under a lattice path.
    
    Algorithm: Linear scan maintaining running height.
    - East step (True): add current height to area
    - North step (False): increment height
    
    Time: O(len(path)), Space: O(1)
    
    Args:
        path: List of bools (True=East, False=North)
        start_height: Initial height (default 0)
    
    Returns:
        Area under the path
        
    Example:
        >>> compute_path_area([True, False, True, False])  # ENEN
        1
        >>> compute_path_area([False, True, False, True])  # NENE
        3
    """
    area = 0
    h = start_height
    for step in path:
        if step:
            area += h
        else:
            h += 1
    return area


# ============================================================
# Algorithm 2: Path Complement and Area Verification
# Time: O(m + n), Space: O(m + n)
# ============================================================

def compute_complement(path: List[bool]) -> List[bool]:
    """Compute the complement of a lattice path (swap E ↔ N).
    
    Time: O(len(path)), Space: O(len(path))
    """
    return [not s for s in path]


def verify_area_complement(path: List[bool]) -> Tuple[int, int, int, bool]:
    """Verify the Area Complement Theorem for a given path.
    
    Returns: (area, complement_area, m*n, is_valid)
    
    Example:
        >>> verify_area_complement([True, False, True, False])
        (1, 3, 4, True)
    """
    m = sum(1 for s in path if s)
    n = sum(1 for s in path if not s)
    a = compute_path_area(path)
    ac = compute_path_area(compute_complement(path))
    return (a, ac, m * n, a + ac == m * n)


# ============================================================
# Algorithm 3: Area Generating Function via Dynamic Programming
# Time: O(m * n * min(m, n)), Space: O(m * n)
# ============================================================

def area_gf_dp(m: int, n: int) -> Dict[int, int]:
    """Compute area generating function using dynamic programming.
    
    Uses the recurrence: the number of paths from (0,0) to (m,n)
    with area a equals the number from (0,0) to (m-1,n) with area a-n
    (last step East from height n) plus the number from (0,0) to (m,n-1)
    with area a (last step North, area unchanged).
    
    Time: O(m * n * min(m,n)), Space: O(m * n)
    
    Returns:
        Dict mapping area -> count of paths with that area
        
    Example:
        >>> area_gf_dp(2, 2)
        {0: 1, 1: 1, 2: 2, 3: 1, 4: 1}
    """
    # dp[i][j] = dict mapping area -> count for paths to (i,j)
    dp = [[{} for _ in range(n + 1)] for _ in range(m + 1)]
    dp[0][0] = {0: 1}
    
    for i in range(m + 1):
        for j in range(n + 1):
            if i == 0 and j == 0:
                continue
            current = {}
            # From (i-1, j) via East step: adds j to area
            if i > 0:
                for area, count in dp[i-1][j].items():
                    new_area = area + j
                    current[new_area] = current.get(new_area, 0) + count
            # From (i, j-1) via North step: area unchanged
            if j > 0:
                for area, count in dp[i][j-1].items():
                    current[area] = current.get(area, 0) + count
            dp[i][j] = current
    
    return dict(sorted(dp[m][n].items()))


# ============================================================
# Algorithm 4: Q-Binomial Coefficient
# Time: O(m * n), Space: O(m * n)  
# ============================================================

def q_binomial(m_plus_n: int, m: int, q: float = 2.0) -> float:
    """Compute the q-binomial coefficient [m+n choose m]_q.
    
    The q-binomial coefficient is the generating function of lattice
    paths weighted by area, evaluated at q.
    
    Uses the recurrence: [n choose k]_q = [n-1 choose k-1]_q + q^k * [n-1 choose k]_q
    
    Time: O(n * k), Space: O(n * k)
    
    Example:
        >>> q_binomial(4, 2, 1.0)  # Should equal C(4,2) = 6
        6.0
    """
    n = m_plus_n
    k = m
    if k < 0 or k > n:
        return 0.0
    
    # dp[i][j] = [i choose j]_q
    dp = [[0.0] * (k + 1) for _ in range(n + 1)]
    for i in range(n + 1):
        dp[i][0] = 1.0
    
    for i in range(1, n + 1):
        for j in range(1, min(i, k) + 1):
            dp[i][j] = dp[i-1][j-1] + (q ** j) * dp[i-1][j]
    
    return dp[n][k]


# ============================================================
# Algorithm 5: Knot Lattice Path Enumeration with Forbidden Regions
# Time: O(C(m+n, m) * (m+n)), Space: O(C(m+n, m))
# ============================================================

def enumerate_avoiding_paths(m: int, n: int, 
                              forbidden: Set[Tuple[int, int]]) -> List[List[bool]]:
    """Enumerate lattice paths from (0,0) to (m,n) avoiding forbidden points.
    
    Time: O(C(m+n,m) * (m+n))
    Space: O(C(m+n,m))
    
    Args:
        m: Number of East steps
        n: Number of North steps
        forbidden: Set of (x,y) points to avoid
        
    Returns:
        List of valid paths (as bool lists)
    """
    result = []
    
    def backtrack(x: int, y: int, path: List[bool]):
        if (x, y) in forbidden:
            return
        if x == m and y == n:
            result.append(path[:])
            return
        if x < m:
            path.append(True)
            backtrack(x + 1, y, path)
            path.pop()
        if y < n:
            path.append(False)
            backtrack(x, y + 1, path)
            path.pop()
    
    if (0, 0) not in forbidden:
        backtrack(0, 0, [])
    
    return result


def forbidden_region_gf(m: int, n: int,
                         forbidden: Set[Tuple[int, int]]) -> Dict[int, int]:
    """Area generating function for paths avoiding a forbidden region.
    
    Returns dict mapping area -> count.
    """
    paths = enumerate_avoiding_paths(m, n, forbidden)
    gf = {}
    for p in paths:
        a = compute_path_area(p)
        gf[a] = gf.get(a, 0) + 1
    return dict(sorted(gf.items()))


# ============================================================
# Algorithm 6: Alexander Polynomial Candidate from Knot Lattice
# Time: O(C(2n, n) * 2n), Space: O(C(2n, n))
# ============================================================

def alexander_candidate(n: int, signs: List[bool],
                        forbidden: Set[Tuple[int, int]]) -> Dict[int, int]:
    """Compute the Alexander polynomial candidate from a knot lattice.
    
    For an n-crossing knot with given signs and forbidden region,
    compute the area-weighted generating function of avoiding paths.
    
    The result is a dict mapping exponent -> coefficient, representing
    a Laurent polynomial centered at n*n/2.
    
    Args:
        n: Number of crossings
        signs: Sign of each crossing (True=positive, False=negative)
        forbidden: Forbidden region in the n×n grid
        
    Returns:
        Dict mapping area -> coefficient
    """
    return forbidden_region_gf(n, n, forbidden)


# ============================================================
# Main: Algorithm Demonstrations
# ============================================================

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)
    
    # Demo 1: Area computation
    print("\n1. Path Area Computation:")
    paths_demo = [
        ([True, True, False, False], "EENN"),
        ([True, False, True, False], "ENEN"),
        ([False, True, False, True], "NENE"),
        ([False, False, True, True], "NNEE"),
    ]
    for path, name in paths_demo:
        a, ac, mn, valid = verify_area_complement(path)
        print(f"   {name}: area={a}, complement_area={ac}, "
              f"sum={a+ac}, m*n={mn}, ✓={valid}")
    
    # Demo 2: DP generating function
    print("\n2. Area GF via Dynamic Programming:")
    for m, n in [(2, 2), (3, 3), (2, 3)]:
        gf = area_gf_dp(m, n)
        terms = " + ".join(f"{c}q^{a}" for a, c in gf.items())
        print(f"   [{m+n} choose {m}]_q = {terms}")
    
    # Demo 3: q-binomial
    print("\n3. Q-Binomial at q=1 (should equal binomial coefficient):")
    for m_n, m in [(4, 2), (6, 3), (8, 4)]:
        val = q_binomial(m_n, m, 1.0)
        print(f"   [{m_n} choose {m}]_1 = {val:.0f} = C({m_n},{m}) = {comb(m_n, m)}")
    
    # Demo 4: Forbidden region paths
    print("\n4. Paths avoiding forbidden regions:")
    for name, m, n, forbidden in [
        ("Trefoil", 3, 3, {(1, 1)}),
        ("Figure-8", 4, 4, {(1, 1), (2, 2)}),
    ]:
        gf = forbidden_region_gf(m, n, forbidden)
        total = sum(gf.values())
        terms = " + ".join(f"{c}q^{a}" for a, c in gf.items())
        print(f"   {name}: {total} paths, GF = {terms}")
