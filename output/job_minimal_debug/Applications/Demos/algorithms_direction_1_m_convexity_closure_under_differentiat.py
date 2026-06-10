#!/usr/bin/env python3
"""
algorithms.py — Algorithms for M-convex support recognition,
contraction, and derivative-exchange analysis.

Implements:
  1. Exchange property checker (O(|S|² · n²))
  2. Support contraction (O(|S| · n))
  3. Exchange width computation (O(|S| · n))
  4. Full contraction hierarchy builder
  5. Mixed derivative support computation

All algorithms operate on sets of integer exponent vectors.
"""

from typing import Set, Tuple, List, Dict, Optional, FrozenSet
from itertools import combinations
from collections import defaultdict


# ============================================================
# Algorithm 1: Exchange Property Checker
# ============================================================

def satisfies_exchange(S: Set[tuple], n: int) -> bool:
    """
    Check the symmetric exchange property for S ⊆ ℕ^n.
    
    For all α, β ∈ S and all i with αᵢ > βᵢ, there must exist j
    with βⱼ > αⱼ such that (α - eᵢ + eⱼ) ∈ S and (β + eᵢ - eⱼ) ∈ S.
    
    Time:  O(|S|² · n²)
    Space: O(|S|) for the hash set
    
    Args:
        S: Set of exponent vectors (tuples of ints)
        n: Dimension (length of each vector)
    
    Returns:
        True if S satisfies symmetric exchange
    
    >>> satisfies_exchange({(1,0), (0,1)}, 2)
    True
    >>> satisfies_exchange({(2,0), (0,2)}, 2)
    False
    """
    for alpha in S:
        for beta in S:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j]:
                            s1 = tuple(
                                alpha[k] - (1 if k == i else 0) + (1 if k == j else 0)
                                for k in range(n)
                            )
                            s2 = tuple(
                                beta[k] + (1 if k == i else 0) - (1 if k == j else 0)
                                for k in range(n)
                            )
                            if s1 in S and s2 in S:
                                found = True
                                break
                    if not found:
                        return False
    return True


# ============================================================
# Algorithm 2: Support Contraction
# ============================================================

def support_contraction(S: Set[tuple], n: int, i: int) -> Set[tuple]:
    """
    Compute S/i = {m - eᵢ : m ∈ S, mᵢ > 0}.
    
    This is the support-level avatar of ∂/∂xᵢ.
    Equivalent to matroid contraction by element i.
    
    Time:  O(|S| · n)
    Space: O(|S|)
    
    Args:
        S: Set of exponent vectors
        n: Dimension
        i: Variable index to contract
    
    Returns:
        Contracted support set
    
    >>> support_contraction({(1,0), (0,1), (1,1)}, 2, 0)
    {(0, 0), (0, 1)}
    """
    return {
        tuple(m[k] - (1 if k == i else 0) for k in range(n))
        for m in S if m[i] > 0
    }


# ============================================================
# Algorithm 3: Exchange Width
# ============================================================

def exchange_width(S: Set[tuple], n: int) -> int:
    """
    Compute the exchange width: min over coordinates of (max - min).
    
    Measures how many contractions can be applied before some
    coordinate's range collapses to a point.
    
    Time:  O(|S| · n)
    Space: O(1)
    
    >>> exchange_width({(2,0), (1,1), (0,2)}, 2)
    2
    """
    if not S or n == 0:
        return 0
    return min(
        max(m[i] for m in S) - min(m[i] for m in S)
        for i in range(n)
    )


# ============================================================
# Algorithm 4: Mixed Derivative Support
# ============================================================

def mixed_derivative_support(
    S: Set[tuple], n: int, ks: List[int]
) -> Set[tuple]:
    """
    Compute the support of the mixed partial derivative
    ∂^{k₀+...+k_{n-1}} / (∂x₀^{k₀} ... ∂x_{n-1}^{k_{n-1}}).
    
    This is iterated contraction: contract by x_i exactly ks[i] times.
    
    Time:  O(sum(ks) · |S| · n)
    Space: O(|S|)
    
    Args:
        S: Original support set
        n: Dimension
        ks: List of derivative orders [k₀, ..., k_{n-1}]
    
    Returns:
        Support of the mixed derivative
    """
    current = S
    for i in range(n):
        for _ in range(ks[i]):
            current = support_contraction(current, n, i)
    return current


# ============================================================
# Algorithm 5: Contraction Hierarchy
# ============================================================

def contraction_hierarchy(
    S: Set[tuple], n: int, max_depth: int = 10
) -> Dict[tuple, Set[tuple]]:
    """
    Build the full contraction hierarchy of S.
    
    Returns a dictionary mapping contraction sequences (tuples of
    variable indices) to the resulting support sets.
    
    Time:  O(n^d · |S| · n) where d = max_depth
    Space: O(n^d · |S|)
    """
    hierarchy = {(): S}
    queue = [((), S)]
    
    while queue:
        path, current = queue.pop(0)
        if len(path) >= max_depth:
            continue
        for i in range(n):
            Si = support_contraction(current, n, i)
            new_path = path + (i,)
            if Si and frozenset(Si) not in {frozenset(v) for v in hierarchy.values()}:
                hierarchy[new_path] = Si
                queue.append((new_path, Si))
    
    return hierarchy


# ============================================================
# Algorithm 6: Exchange Depth
# ============================================================

def exchange_depth(S: Set[tuple], n: int) -> int:
    """
    Maximum total order of mixed differentiation that produces
    a nonempty support with exchange property.
    
    Computed by BFS over all contraction sequences.
    
    Time:  Exponential in the depth
    Space: Proportional to the number of distinct contracted supports
    """
    max_depth = 0
    queue = [(S, 0)]
    visited = {frozenset(S)}
    
    while queue:
        current, depth = queue.pop(0)
        if len(current) >= 2 and satisfies_exchange(current, n):
            max_depth = max(max_depth, depth)
        for i in range(n):
            Si = support_contraction(current, n, i)
            key = frozenset(Si)
            if Si and key not in visited:
                visited.add(key)
                queue.append((Si, depth + 1))
    
    return max_depth


# ============================================================
# Generators
# ============================================================

def homogeneous_support(n: int, d: int) -> Set[tuple]:
    """All monomials of degree d in n variables."""
    if n == 0:
        return {()} if d == 0 else set()
    result = set()
    def gen(rem, deg, cur):
        if rem == 1:
            result.add(tuple(cur + [deg]))
            return
        for k in range(deg + 1):
            gen(rem - 1, deg - k, cur + [k])
    gen(n, d, [])
    return result


def uniform_matroid_support(n: int, r: int) -> Set[tuple]:
    """Bases of U(r,n): 0-1 vectors of weight r."""
    result = set()
    for combo in combinations(range(n), r):
        vec = [0] * n
        for idx in combo:
            vec[idx] = 1
        result.add(tuple(vec))
    return result


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Uniform matroid U(2,4)
    n, r = 4, 2
    S = uniform_matroid_support(n, r)
    print(f"U({r},{n}) = {sorted(S)}")
    print(f"  Exchange: {satisfies_exchange(S, n)}")
    print(f"  Width: {exchange_width(S, n)}")
    print(f"  Depth: {exchange_depth(S, n)}")
    
    # Full simplex
    n, d = 3, 3
    S = homogeneous_support(n, d)
    print(f"\nSimplex({n},{d}): |S|={len(S)}")
    print(f"  Exchange: {satisfies_exchange(S, n)}")
    print(f"  Width: {exchange_width(S, n)}")
    
    # Mixed derivative
    ks = [1, 1, 0]
    Sd = mixed_derivative_support(S, n, ks)
    print(f"  After ∂²/∂x₀∂x₁: |S|={len(Sd)}, exchange: {satisfies_exchange(Sd, n)}")
    
    # Hierarchy
    hierarchy = contraction_hierarchy(uniform_matroid_support(3, 2), 3)
    print(f"\nContraction hierarchy of U(2,3): {len(hierarchy)} nodes")
    for path, Sp in sorted(hierarchy.items(), key=lambda x: len(x[0])):
        label = "S" + "".join(f"/{i}" for i in path) if path else "S"
        print(f"  {label}: {sorted(Sp)}")
