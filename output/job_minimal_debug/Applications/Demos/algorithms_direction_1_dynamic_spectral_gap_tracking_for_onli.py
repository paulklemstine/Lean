"""
Algorithms for Dynamic Spectral Gap Tracking

Implements the online gap update algorithm and certificate maintenance
for Lorentzian polynomials under rank-1 monomial updates.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from itertools import product
from math import comb, factorial


def enumerate_multiindices(n: int, total: int) -> List[Tuple[int, ...]]:
    """Enumerate all multiindices β ∈ ℕ^n with Σ β_i = total.

    Args:
        n: Number of variables
        total: Target sum of entries

    Returns:
        List of tuples (β_1, ..., β_n) with sum = total
    """
    if n == 0:
        return [()] if total == 0 else []
    if n == 1:
        return [(total,)]
    result = []
    for b0 in range(total + 1):
        for rest in enumerate_multiindices(n - 1, total - b0):
            result.append((b0,) + rest)
    return result


def affected_leaves(alpha: Tuple[int, ...], d: int) -> List[Tuple[int, ...]]:
    """Compute the set of affected (d-2)-leaves for a monomial update α.

    A leaf β is affected iff β ≤ α coordinatewise and |β| = d-2.

    Args:
        alpha: Exponent vector of the monomial update
        d: Degree of the polynomial

    Returns:
        List of affected leaf multiindices
    """
    n = len(alpha)
    target = d - 2
    if target < 0:
        return []

    all_leaves = enumerate_multiindices(n, target)
    return [beta for beta in all_leaves
            if all(beta[i] <= alpha[i] for i in range(n))]


def total_leaf_count(n: int, d: int) -> int:
    """Total number of (d-2)-leaf multiindices on n variables.

    This equals C(n + d - 3, d - 2) by stars-and-bars.

    Args:
        n: Number of variables
        d: Degree

    Returns:
        Total number of leaves
    """
    target = d - 2
    if target < 0 or n <= 0:
        return 0
    return comb(n + target - 1, target)


def affected_leaf_fraction(alpha: Tuple[int, ...], d: int) -> float:
    """Compute the fraction of leaves affected by a monomial update.

    Args:
        alpha: Exponent vector
        d: Degree

    Returns:
        Fraction in [0, 1]
    """
    n = len(alpha)
    total = total_leaf_count(n, d)
    if total == 0:
        return 0.0
    aff = len(affected_leaves(alpha, d))
    return aff / total


def gap_perturbation_constant(d: int, kappa: float) -> float:
    """Compute the perturbation constant K(d, κ) = 2κ.

    Args:
        d: Degree
        kappa: Uniform conditioning bound

    Returns:
        Perturbation constant
    """
    return 2 * kappa


def online_gap_update(current_gap: float, perturbation_bound: float) -> float:
    """Online gap update algorithm.

    Computes a new lower bound on the spectral gap after a perturbation.

    Args:
        current_gap: Current certified spectral gap lower bound
        perturbation_bound: Upper bound on the gap change

    Returns:
        Updated gap lower bound
    """
    return current_gap - perturbation_bound


def mixing_time_bound(n: int, d: int, gap: float) -> float:
    """Compute mixing time upper bound from spectral gap.

    τ_mix ≤ n^d / gap when gap > 0.

    Args:
        n: Number of variables
        d: Degree
        gap: Spectral gap lower bound

    Returns:
        Mixing time upper bound (inf if gap ≤ 0)
    """
    if gap <= 0:
        return float('inf')
    return n ** d / gap


def incremental_certificate_update(
    leaf_eigenvalues: Dict[Tuple[int, ...], float],
    alpha: Tuple[int, ...],
    d: int,
    new_eigenvalues: Dict[Tuple[int, ...], float],
    kappa: float
) -> Tuple[Dict[Tuple[int, ...], float], float]:
    """Incremental certificate update algorithm.

    Only recomputes eigenvalues at affected leaves.

    Args:
        leaf_eigenvalues: Current minimum eigenvalues at each leaf
        alpha: Exponent vector of the update
        d: Degree
        new_eigenvalues: Recomputed eigenvalues at affected leaves
        kappa: Conditioning bound

    Returns:
        (updated_eigenvalues, new_gap_lower_bound)
    """
    aff = affected_leaves(alpha, d)
    updated = dict(leaf_eigenvalues)

    for beta in aff:
        if beta in new_eigenvalues:
            updated[beta] = new_eigenvalues[beta]

    if updated:
        new_gap = min(updated.values())
    else:
        new_gap = 0.0

    return updated, new_gap


# --- Graphic Matroid Utilities ---

def spanning_trees_from_edges(n: int, edges: List[Tuple[int, int]]) -> List[frozenset]:
    """Find all spanning trees of a graph using brute force.

    Args:
        n: Number of vertices
        edges: List of edges as (u, v) pairs

    Returns:
        List of spanning trees (each as a frozenset of edge indices)
    """
    from itertools import combinations

    def is_connected(tree_edges: List[Tuple[int, int]], n: int) -> bool:
        if len(tree_edges) != n - 1:
            return False
        adj = {i: set() for i in range(n)}
        for u, v in tree_edges:
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        stack = [0]
        while stack:
            node = stack.pop()
            if node in visited:
                continue
            visited.add(node)
            for nb in adj[node]:
                if nb not in visited:
                    stack.append(nb)
        return len(visited) == n

    trees = []
    for combo in combinations(range(len(edges)), n - 1):
        tree_edges = [edges[i] for i in combo]
        if is_connected(tree_edges, n):
            trees.append(frozenset(combo))
    return trees


def edge_indicator(n_edges: int, edge_idx: int) -> Tuple[int, ...]:
    """Create an edge indicator vector for a graph polynomial.

    In the basis-generating polynomial, variable i corresponds to edge i.
    An edge insertion adds a monomial X_e.

    Args:
        n_edges: Total number of edges (variables)
        edge_idx: Index of the inserted edge

    Returns:
        Exponent vector with 1 at edge_idx, 0 elsewhere
    """
    alpha = [0] * n_edges
    alpha[edge_idx] = 1
    return tuple(alpha)


# Example usage
if __name__ == "__main__":
    print("=== Dynamic Spectral Gap Tracking ===\n")

    # Example: 4 variables, degree 4
    n, d = 4, 4
    alpha = (1, 1, 1, 1)  # Monomial x1*x2*x3*x4

    print(f"Parameters: n={n}, d={d}")
    print(f"Update monomial exponent: α = {alpha}")

    aff = affected_leaves(alpha, d)
    total = total_leaf_count(n, d)
    frac = affected_leaf_fraction(alpha, d)

    print(f"\nAffected (d-2)-leaves: {len(aff)} out of {total}")
    print(f"Affected fraction: {frac:.4f}")

    # Sparse update: only 2 nonzero entries
    alpha_sparse = (1, 1, 0, 0)
    aff_sparse = affected_leaves(alpha_sparse, d)
    total_sparse = total_leaf_count(n, d)
    frac_sparse = affected_leaf_fraction(alpha_sparse, d)

    print(f"\nSparse update α = {alpha_sparse}")
    print(f"Affected leaves: {len(aff_sparse)} out of {total_sparse}")
    print(f"Affected fraction: {frac_sparse:.4f}")
    print(f"Speedup over full recomputation: {total_sparse / max(1, len(aff_sparse)):.1f}x")

    # Online gap update
    current_gap = 0.5
    kappa = 2.0
    K = gap_perturbation_constant(d, kappa)
    new_gap = online_gap_update(current_gap, K)
    print(f"\nOnline gap update: {current_gap} → {new_gap}")
    print(f"Mixing time before: {mixing_time_bound(n, d, current_gap):.1f}")
    if new_gap > 0:
        print(f"Mixing time after:  {mixing_time_bound(n, d, new_gap):.1f}")
    else:
        print(f"Mixing time after:  ∞ (gap ≤ 0)")
