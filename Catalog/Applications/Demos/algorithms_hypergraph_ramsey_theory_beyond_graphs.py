#!/usr/bin/env python3
"""
Algorithms for Hypergraph Ramsey Theory

Type-hinted implementations of the key algorithms used in hypergraph
Ramsey number computation and analysis.
"""

from itertools import combinations
from math import comb, log2, ceil, floor
from typing import Dict, List, Tuple, Set, Optional, FrozenSet


# Type aliases
Vertex = int
Hyperedge = FrozenSet[Vertex]
Coloring = Dict[Hyperedge, bool]  # True = red, False = blue


def tower(height: int) -> int:
    """
    Compute the iterated exponential tower function.
    
    tower(0) = 1
    tower(h+1) = 2^tower(h)
    
    This is the fundamental growth rate function in hypergraph Ramsey theory.
    """
    if height <= 0:
        return 1
    return 2 ** tower(height - 1)


def generate_hyperedges(n: int, r: int) -> List[Hyperedge]:
    """Generate all r-element subsets of {0, 1, ..., n-1}."""
    return [frozenset(s) for s in combinations(range(n), r)]


def is_monochromatic_clique(
    coloring: Coloring,
    vertices: Set[Vertex],
    r: int,
    color: bool
) -> bool:
    """
    Check if a set of vertices forms a monochromatic clique.
    
    A set S is monochromatic of color c if all C(|S|, r) r-element
    subsets of S have color c.
    """
    for edge in combinations(sorted(vertices), r):
        key = frozenset(edge)
        if key not in coloring or coloring[key] != color:
            return False
    return True


def find_monochromatic_clique(
    coloring: Coloring,
    n: int,
    r: int,
    k: int
) -> Optional[Tuple[Set[Vertex], bool]]:
    """
    Find a monochromatic k-clique in the given coloring, if one exists.
    
    Returns (vertices, color) or None.
    """
    for subset in combinations(range(n), k):
        vertices = set(subset)
        for color in [True, False]:
            if is_monochromatic_clique(coloring, vertices, r, color):
                return (vertices, color)
    return None


def verify_ramsey_property(n: int, r: int, k: int) -> bool:
    """
    Verify HyperRamseyProp r n k k by exhaustive enumeration.
    
    Checks ALL 2-colorings of C(n,r) hyperedges to confirm that
    every coloring contains a monochromatic K_k^{(r)}.
    
    Complexity: O(2^{C(n,r)} * C(n,k) * C(k,r))
    Only feasible for very small parameters.
    """
    edges = generate_hyperedges(n, r)
    num_edges = len(edges)
    
    if num_edges > 25:
        raise ValueError(f"Too many edges ({num_edges}), would need 2^{num_edges} iterations")
    
    for bits in range(2 ** num_edges):
        coloring: Coloring = {}
        for i, edge in enumerate(edges):
            coloring[edge] = bool((bits >> i) & 1)
        
        result = find_monochromatic_clique(coloring, n, r, k)
        if result is None:
            return False
    
    return True


def find_ramsey_witness(n: int, r: int, k: int) -> Optional[Coloring]:
    """
    Find a 2-coloring of r-subsets of [n] with NO monochromatic K_k^{(r)}.
    
    Returns a witness coloring if one exists (proving ¬HyperRamseyProp r n k k),
    or None if every coloring contains a monochromatic clique.
    """
    edges = generate_hyperedges(n, r)
    num_edges = len(edges)
    
    if num_edges > 30:
        raise ValueError(f"Too many edges ({num_edges})")
    
    for bits in range(2 ** num_edges):
        coloring: Coloring = {}
        for i, edge in enumerate(edges):
            coloring[edge] = bool((bits >> i) & 1)
        
        if find_monochromatic_clique(coloring, n, r, k) is None:
            return coloring
    
    return None


def probabilistic_lower_bound(r: int, k: int) -> int:
    """
    Compute the Erdős probabilistic lower bound for R_r(k,k).
    
    The first moment method shows: if 2 * C(n, k) < 2^{C(k, r) - 1},
    then there exists a coloring with no monochromatic k-clique.
    
    Returns the largest such n (so R_r(k,k) >= n + 1).
    
    Algorithm:
    1. Compute C(k, r) = number of r-subsets in a k-clique
    2. Binary search for max n where 2*C(n,k) < 2^{C(k,r)-1}
    """
    binom_kr: int = comb(k, r)
    if binom_kr <= 1:
        return k
    
    threshold: int = 2 ** (binom_kr - 1)
    
    # Binary search
    lo: int = k
    hi: int = min(10**15, 2 ** (binom_kr // k) + 1000)
    
    while lo < hi:
        mid: int = (lo + hi + 1) // 2
        if 2 * comb(mid, k) < threshold:
            lo = mid
        else:
            hi = mid - 1
    
    return lo


def stepping_up_bound(
    r: int,
    graph_ramsey_bound: int
) -> int:
    """
    Apply the stepping-up lemma iteratively.
    
    Given R_2(s, t) <= graph_ramsey_bound, compute the upper bound
    for R_r(s + r - 2, t + r - 2) via (r-2) applications of the
    stepping-up lemma.
    
    Each application: N -> 2^N + 1
    
    So the final bound is tower_{r-2}(graph_ramsey_bound) approximately.
    """
    bound: int = graph_ramsey_bound
    for _ in range(r - 2):
        if bound > 1000:  # Prevent memory issues
            return -1  # Indicates "too large to compute"
        bound = 2 ** bound + 1
    return bound


def growth_rate_analysis(
    max_k: int = 8
) -> Dict[str, List[Tuple[int, float]]]:
    """
    Analyze the growth rate of hypergraph Ramsey lower bounds.
    
    Returns a dictionary mapping uniformity r to lists of (k, log2(lower_bound)).
    """
    results: Dict[str, List[Tuple[int, float]]] = {}
    
    for r in [2, 3, 4]:
        data: List[Tuple[int, float]] = []
        for k in range(r + 1, max_k + 1):
            lb = probabilistic_lower_bound(r, k)
            if lb > 1:
                data.append((k, log2(lb)))
            else:
                data.append((k, 0.0))
        results[f"r={r}"] = data
    
    return results


def count_monochromatic_cliques(
    coloring: Coloring,
    n: int,
    r: int,
    k: int
) -> Dict[bool, int]:
    """
    Count the number of monochromatic k-cliques for each color.
    
    Returns {True: red_count, False: blue_count}.
    """
    counts: Dict[bool, int] = {True: 0, False: 0}
    
    for subset in combinations(range(n), k):
        vertices = set(subset)
        for color in [True, False]:
            if is_monochromatic_clique(coloring, vertices, r, color):
                counts[color] += 1
    
    return counts


if __name__ == "__main__":
    # Example usage
    print("Probabilistic lower bounds:")
    for r in [2, 3]:
        for k in range(r + 1, r + 5):
            lb = probabilistic_lower_bound(r, k)
            print(f"  R_{r}({k},{k}) >= {lb + 1}")
    
    print("\nStepping-up bounds (from R_2(k,k)):")
    for k, rb in [(3, 6), (4, 18), (5, 48)]:
        for r in [3, 4]:
            su = stepping_up_bound(r, rb)
            if su > 0:
                print(f"  R_{r}({k+r-2},{k+r-2}) <= {su}")
            else:
                print(f"  R_{r}({k+r-2},{k+r-2}) <= (too large)")
    
    print("\nGrowth rate analysis:")
    analysis = growth_rate_analysis(8)
    for key, data in analysis.items():
        print(f"  {key}: {data}")
