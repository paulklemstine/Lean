#!/usr/bin/env python3
"""
Hypergraph Ramsey Theory: Core Algorithms

Type-hinted implementations of key algorithms for computing Ramsey bounds,
tower functions, and chromatic densities.
"""

from typing import Dict, List, Tuple, Set, Optional, FrozenSet
from itertools import combinations
import math


def tower(base: int, height: int) -> int:
    """
    Compute the tower function: iterated exponentiation.
    
    tower(b, 0) = 1
    tower(b, n+1) = b^tower(b, n)
    
    For base=2: 1, 2, 4, 16, 65536, 2^65536, ...
    """
    if height == 0:
        return 1
    return base ** tower(base, height - 1)


def counting_lower_bound(r: int, k: int) -> int:
    """
    Compute the probabilistic (counting) lower bound for R_r(k,k).
    
    Returns the largest n such that 2 * C(n,k) < 2^C(k,r).
    By the first moment method, R_r(k,k) > this value.
    
    Args:
        r: uniformity (r-element subsets)
        k: clique size
    
    Returns:
        Lower bound on R_r(k,k)
    """
    if r > k:
        return k  # trivial case
    
    threshold = 2 ** math.comb(k, r)
    n = k
    while 2 * math.comb(n, k) < threshold:
        n += 1
    return n - 1


def is_monochromatic(
    coloring: Dict[FrozenSet[int], int],
    vertices: List[int],
    r: int
) -> Optional[int]:
    """
    Check if a vertex set is monochromatic under a given coloring.
    
    Returns the color if monochromatic, None otherwise.
    """
    if len(vertices) < r:
        return 0  # vacuously monochromatic
    
    color: Optional[int] = None
    for subset in combinations(vertices, r):
        key = frozenset(subset)
        c = coloring.get(key, 0)
        if color is None:
            color = c
        elif c != color:
            return None
    return color


def chromatic_density(
    coloring: Dict[FrozenSet[int], int],
    vertices: List[int],
    r: int,
    target_color: int = 1
) -> float:
    """
    Compute the chromatic density: fraction of r-subsets with target color.
    """
    total = 0
    count = 0
    for subset in combinations(vertices, r):
        key = frozenset(subset)
        total += 1
        if coloring.get(key, 0) == target_color:
            count += 1
    return count / total if total > 0 else 0.5


def ramsey_spectrum_bounds(k: int, max_r: int = 5) -> Dict[int, Tuple[int, int]]:
    """
    Compute known bounds on R_r(k,k) for r = 2, ..., max_r.
    
    Returns dict mapping r -> (lower_bound, upper_bound_estimate).
    """
    bounds: Dict[int, Tuple[int, int]] = {}
    
    for r in range(2, max_r + 1):
        if math.comb(k, r) <= 60:  # avoid overflow
            lb = counting_lower_bound(r, k)
        else:
            lb = k  # trivial bound
        
        # Upper bound from stepping-up: very rough estimate
        if r == 2:
            # Graph Ramsey: roughly 4^k / sqrt(k)
            ub = min(4 ** k, 10**15)
        elif r - 2 >= 0 and r in bounds:
            prev_ub = bounds[r - 1][1]
            ub = min(2 ** prev_ub + prev_ub, 10**15)
        else:
            ub = min(tower(2, r - 1) * (4 ** k), 10**15)
        
        bounds[r] = (lb, ub)
    
    return bounds


def uniformity_gap(bounds: Dict[int, Tuple[int, int]], r: int) -> float:
    """
    Compute the uniformity gap ratio: log(UB(r+1)) / log(UB(r)).
    
    This measures how much faster Ramsey numbers grow when uniformity increases.
    """
    if r not in bounds or (r + 1) not in bounds:
        return 0.0
    
    ub_r = bounds[r][1]
    ub_r1 = bounds[r + 1][1]
    
    if ub_r <= 1 or ub_r1 <= 1:
        return 0.0
    
    return math.log(ub_r1) / math.log(ub_r)


def link_coloring(
    coloring: Dict[FrozenSet[int], int],
    vertex: int,
    n: int,
    r: int
) -> Dict[FrozenSet[int], int]:
    """
    Compute the link coloring at a vertex.
    
    The link of vertex v in an (r+1)-uniform coloring is the r-uniform
    coloring where color(S) = original_color(S ∪ {v}).
    """
    link: Dict[FrozenSet[int], int] = {}
    other_vertices = [i for i in range(n) if i != vertex]
    
    for subset in combinations(other_vertices, r):
        key_link = frozenset(subset)
        key_original = frozenset(subset) | {vertex}
        link[key_link] = coloring.get(key_original, 0)
    
    return link


def find_monochromatic_clique(
    coloring: Dict[FrozenSet[int], int],
    n: int,
    r: int,
    k: int,
    target_color: int = 1
) -> Optional[List[int]]:
    """
    Find a monochromatic k-clique of the given color, or return None.
    
    Brute force search over all k-element subsets.
    """
    for vertices in combinations(range(n), k):
        vlist = list(vertices)
        if is_monochromatic(coloring, vlist, r) == target_color:
            return vlist
    return None


if __name__ == "__main__":
    # Example: compute spectrum for k=4
    print("Ramsey Spectrum for k=4:")
    bounds = ramsey_spectrum_bounds(4, max_r=4)
    for r, (lb, ub) in sorted(bounds.items()):
        gap = uniformity_gap(bounds, r) if r + 1 in bounds else 0
        print(f"  r={r}: lower={lb}, upper≈{ub}, gap_ratio={gap:.2f}")
