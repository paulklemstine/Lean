#!/usr/bin/env python3
"""
Algorithms for Support-Compressed Lorentzian Certificate Counting

Implements the verified algorithms from the research paper:
1. Support-compressed quadratic leaf counting
2. Independence oracle via basis enumeration
3. Active variable analysis
4. Compression ratio computation

All algorithms operate on matroid basis families, avoiding
polynomial differentiation entirely.
"""

import itertools
from math import comb
from typing import Set, FrozenSet, List, Tuple, Optional, Dict


class BasisFamily:
    """
    A matroid represented by its collection of bases.
    
    Each basis is a frozenset of integers from {0, 1, ..., n-1}.
    All bases have the same cardinality r (the rank).
    
    Attributes:
        n: Size of the ground set [n] = {0, 1, ..., n-1}
        r: Rank (common cardinality of all bases)
        bases: Set of bases, each a frozenset of integers
    """
    
    def __init__(self, n: int, r: int, bases: Set[FrozenSet[int]]):
        """
        Initialize a basis family.
        
        Args:
            n: Ground set size
            r: Rank
            bases: Collection of bases (r-element subsets)
            
        Raises:
            ValueError: If bases is empty or contains sets of wrong size
        """
        if not bases:
            raise ValueError("Basis family must be nonempty")
        for B in bases:
            if len(B) != r:
                raise ValueError(f"Basis {B} has size {len(B)}, expected {r}")
            if not all(0 <= x < n for x in B):
                raise ValueError(f"Basis {B} contains elements outside [0, {n})")
        self.n = n
        self.r = r
        self.bases = bases
    
    def is_independent(self, I: FrozenSet[int]) -> bool:
        """
        Test if a set is independent (contained in some basis).
        
        Time complexity: O(|bases| * |I|)
        
        Args:
            I: Subset to test
            
        Returns:
            True if I ⊆ B for some basis B
        """
        return any(I <= B for B in self.bases)
    
    def independent_sets_of_size(self, k: int) -> List[FrozenSet[int]]:
        """
        Enumerate all independent sets of a given size.
        
        Time complexity: O(C(n, k) * |bases| * k)
        
        Args:
            k: Size of independent sets to enumerate
            
        Returns:
            List of independent k-sets
        """
        ground = list(range(self.n))
        return [frozenset(S) for S in itertools.combinations(ground, k)
                if self.is_independent(frozenset(S))]
    
    def count_independent_sets(self, k: int) -> int:
        """
        Count independent sets of size k.
        
        This is the core algorithm: replaces polynomial differentiation
        with a purely combinatorial enumeration.
        
        Time complexity: O(C(n, k) * |bases| * k)
        Space complexity: O(1) (streaming count)
        
        Args:
            k: Size of sets to count
            
        Returns:
            Number of independent k-element subsets of the ground set
        """
        ground = list(range(self.n))
        return sum(1 for S in itertools.combinations(ground, k)
                   if self.is_independent(frozenset(S)))
    
    def active_variables(self) -> Set[int]:
        """
        Compute the set of active variables (appearing in some basis).
        
        Time complexity: O(|bases| * r)
        
        Returns:
            Set of ground set elements appearing in at least one basis
        """
        return set().union(*self.bases)
    
    def active_variable_count(self) -> int:
        """Count of active variables."""
        return len(self.active_variables())


def count_nonzero_quadratic_leaves(M: BasisFamily) -> int:
    """
    Count nonzero quadratic derivative leaves of the basis generating
    polynomial using support geometry, without differentiating.
    
    This is the main verified algorithm. By the Support Criterion Theorem,
    a derivative ∂^α B_M is nonzero iff supp(α) is independent in M.
    For |α| = r-2, this counts independent (r-2)-sets.
    
    Algorithm:
        1. Enumerate all (r-2)-element subsets of [n]
        2. For each, test independence (is it ⊆ some basis?)
        3. Count those that pass
    
    Correctness: Proved as `countNonzeroQuadraticLeaves_correct` in Lean.
    
    Time complexity: O(C(n, r-2) * |bases| * r)
    Space complexity: O(1)
    
    Args:
        M: A matroid given by its basis family
        
    Returns:
        Number of nonzero quadratic derivative leaves
    """
    if M.r < 2:
        return 1
    return M.count_independent_sets(M.r - 2)


def naive_ambient_leaf_count(n: int, r: int) -> int:
    """
    Naive worst-case leaf count for multiaffine polynomials.
    
    For a multiaffine polynomial of degree r in n variables,
    the maximum number of quadratic derivative leaves is C(n, r-2).
    
    Args:
        n: Number of variables
        r: Degree
        
    Returns:
        C(n, r-2)
    """
    if r < 2:
        return 1
    return comb(n, r - 2)


def active_variable_bound(M: BasisFamily) -> int:
    """
    Compute the support compression bound C(ω, r-2) where ω = |active vars|.
    
    By Theorem 4, the number of nonzero quadratic leaves is at most
    C(ω, r-2), which can be much smaller than C(n, r-2) when ω << n.
    
    Args:
        M: A matroid given by its basis family
        
    Returns:
        C(|active variables|, r-2)
    """
    if M.r < 2:
        return 1
    return comb(M.active_variable_count(), M.r - 2)


def compression_ratio(M: BasisFamily) -> float:
    """
    Compute the compression ratio: actual / ambient.
    
    A ratio of 1.0 means no compression (uniform matroid).
    A ratio close to 0 means excellent compression (sparse matroid).
    
    Args:
        M: A matroid given by its basis family
        
    Returns:
        Ratio of actual leaf count to ambient worst-case
    """
    ambient = naive_ambient_leaf_count(M.n, M.r)
    if ambient == 0:
        return 0.0
    actual = count_nonzero_quadratic_leaves(M)
    return actual / ambient


def full_analysis(M: BasisFamily, name: str = "Matroid") -> Dict:
    """
    Perform full compression analysis on a matroid.
    
    Args:
        M: A matroid given by its basis family
        name: Descriptive name for the matroid
        
    Returns:
        Dictionary with analysis results
    """
    actual = count_nonzero_quadratic_leaves(M)
    ambient = naive_ambient_leaf_count(M.n, M.r)
    active = M.active_variable_count()
    active_bd = active_variable_bound(M)
    
    return {
        "name": name,
        "n": M.n,
        "r": M.r,
        "num_bases": len(M.bases),
        "actual_leaves": actual,
        "ambient_bound": ambient,
        "active_vars": active,
        "active_bound": active_bd,
        "compression_ratio": actual / ambient if ambient > 0 else 0,
        "active_compression": actual / active_bd if active_bd > 0 else 0,
    }


# ─── Matroid Constructors ────────────────────────────────────────────────

def uniform_matroid(n: int, r: int) -> BasisFamily:
    """Uniform matroid U_{r,n}: all r-subsets are bases."""
    bases = {frozenset(S) for S in itertools.combinations(range(n), r)}
    return BasisFamily(n, r, bases)


def graphic_matroid(n_vertices: int, edges: List[Tuple[int, int]]) -> BasisFamily:
    """
    Graphic matroid of a graph.
    Ground set = edges. Bases = spanning forests of max size.
    """
    m = len(edges)
    
    def is_forest(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for i in edge_indices:
            u, v = edges[i]
            pu, pv = find(u), find(v)
            if pu == pv:
                return False
            parent[pu] = pv
        return True
    
    def count_components(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            parent[find(x)] = find(y)
        for i in edge_indices:
            u, v = edges[i]
            union(u, v)
        return len(set(find(i) for i in range(n_vertices)))
    
    n_comp = count_components(range(m))
    r = n_vertices - n_comp
    
    bases = set()
    for S in itertools.combinations(range(m), r):
        if is_forest(S):
            bases.add(frozenset(S))
    
    if not bases:
        bases = {frozenset()}
        r = 0
    
    return BasisFamily(m, r, bases)


# ─── Example Usage ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Support-Compressed Lorentzian Certificates")
    print("=" * 60)
    
    # Uniform matroid example
    M = uniform_matroid(6, 4)
    result = full_analysis(M, "U_{4,6}")
    print(f"\n{result['name']}:")
    for k, v in result.items():
        if k != "name":
            print(f"  {k}: {v}")
    
    # Graphic matroid example: cycle C5
    edges = [(0,1), (1,2), (2,3), (3,4), (4,0)]
    M = graphic_matroid(5, edges)
    result = full_analysis(M, "Graphic(C5)")
    print(f"\n{result['name']}:")
    for k, v in result.items():
        if k != "name":
            print(f"  {k}: {v}")
    
    # Graphic matroid example: path P5
    edges = [(0,1), (1,2), (2,3), (3,4)]
    M = graphic_matroid(5, edges)
    result = full_analysis(M, "Graphic(P5)")
    print(f"\n{result['name']}:")
    for k, v in result.items():
        if k != "name":
            print(f"  {k}: {v}")
