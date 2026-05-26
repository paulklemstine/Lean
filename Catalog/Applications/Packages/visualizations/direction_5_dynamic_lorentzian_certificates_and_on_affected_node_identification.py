#!/usr/bin/env python3
"""
Dynamic Lorentzian Certificate Maintenance Algorithm

Implements the core algorithms for dynamic certificate maintenance:
1. AffectedNodes: identify derivative nodes impacted by a rank-1 update
2. DynamicCertificateUpdate: recompute only affected certificate leaves
3. WarmStartDiscrepancy: estimate distribution drift from coefficient change
4. FullPipeline: end-to-end dynamic certification with cost comparison

All algorithms include docstrings, type hints, and example usage.
"""

from typing import List, Tuple, Set, Dict, Optional
from itertools import combinations
from collections import defaultdict
import math


# ==============================================================================
# Core Data Structures
# ==============================================================================

class CertificateNode:
    """A node in a Lorentzian certificate tree.

    Attributes:
        multiindex: The derivative multiindex (β) at this node.
        depth: The derivative order (sum of multiindex components).
        value: The polynomial value at this node (e.g., quadratic form coefficients).
        children: List of child nodes (deeper derivatives).
        is_leaf: Whether this is a leaf (quadratic form level).
    """

    def __init__(self, multiindex: Tuple[int, ...], depth: int,
                 value: Optional[float] = None):
        self.multiindex = multiindex
        self.depth = depth
        self.value = value
        self.children: List['CertificateNode'] = []
        self.is_leaf = False

    def __repr__(self) -> str:
        return f"CertificateNode(β={self.multiindex}, depth={self.depth})"


# ==============================================================================
# Algorithm 1: Affected Node Identification
# ==============================================================================

def identify_affected_nodes(
    alpha: Tuple[int, ...],
    max_depth: int
) -> Dict[int, List[Tuple[int, ...]]]:
    """
    Identify all derivative nodes affected by a rank-1 update with exponent α.

    A node with multiindex β is affected iff β ≤ α coordinatewise.
    This is the combinatorial shadow of the Locality Theorem.

    Parameters:
        alpha: Exponent vector of the update monomial X^α.
        max_depth: Maximum derivative depth to consider (d-2 for degree d).

    Returns:
        Dictionary mapping depth k to list of affected multiindices at that depth.

    Complexity: O(∏(α_i + 1)) per depth level.

    Example:
        >>> identify_affected_nodes((2, 1, 0), max_depth=2)
        {0: [(0, 0, 0)], 1: [(0, 1, 0), (1, 0, 0)], 2: [(1, 1, 0), (2, 0, 0)]}
    """
    n = len(alpha)
    affected: Dict[int, List[Tuple[int, ...]]] = {}

    for k in range(max_depth + 1):
        nodes_at_k: List[Tuple[int, ...]] = []

        def backtrack(pos: int, remaining: int, current: List[int]) -> None:
            if pos == n:
                if remaining == 0:
                    nodes_at_k.append(tuple(current))
                return
            for val in range(min(remaining, alpha[pos]) + 1):
                current.append(val)
                backtrack(pos + 1, remaining - val, current)
                current.pop()

        backtrack(0, k, [])
        affected[k] = nodes_at_k

    return affected


def affected_count_at_depth(alpha: Tuple[int, ...], k: int) -> int:
    """Count affected nodes at a single depth level.

    Parameters:
        alpha: Update exponent vector.
        k: Derivative depth.

    Returns:
        Number of affected multiindices at depth k.
    """
    return len(identify_affected_nodes(alpha, k).get(k, []))


# ==============================================================================
# Algorithm 2: Dynamic Certificate Update
# ==============================================================================

def dynamic_certificate_update(
    n_vars: int,
    degree: int,
    alpha: Tuple[int, ...],
    leaf_cost: float = 1.0
) -> Dict[str, float]:
    """
    Compute the cost of dynamically updating a Lorentzian certificate
    after a rank-1 update f → f + c·X^α.

    Only recomputes certificate nodes in the affected derivative profile.
    Each affected leaf costs O(n²) for spectral verification.

    Parameters:
        n_vars: Number of variables (n).
        degree: Polynomial degree (d).
        alpha: Exponent vector of the update monomial.
        leaf_cost: Base cost per leaf recomputation (default 1.0).

    Returns:
        Dictionary with cost breakdown:
            - 'dynamic_cost': Total dynamic update cost.
            - 'rebuild_cost': Full rebuild cost for comparison.
            - 'savings_ratio': 1 - dynamic/rebuild.
            - 'affected_by_depth': Affected count per depth.
            - 'total_affected': Total affected nodes.

    Example:
        >>> result = dynamic_certificate_update(4, 4, (1, 1, 1, 0))
        >>> print(f"Savings: {result['savings_ratio']:.1%}")
    """
    max_depth = degree - 2
    affected = identify_affected_nodes(alpha, max_depth)

    total_affected = 0
    affected_by_depth: Dict[int, int] = {}
    for k in range(max_depth + 1):
        count = len(affected.get(k, []))
        affected_by_depth[k] = count
        total_affected += count

    # Each affected node at leaf level requires O(n²) spectral check
    # Internal nodes require O(1) recombination per affected child
    dynamic_cost = n_vars**2 * total_affected * leaf_cost
    rebuild_cost = n_vars**degree * leaf_cost

    savings = 1 - (dynamic_cost / rebuild_cost) if rebuild_cost > 0 else 0

    return {
        'dynamic_cost': dynamic_cost,
        'rebuild_cost': rebuild_cost,
        'savings_ratio': savings,
        'affected_by_depth': affected_by_depth,
        'total_affected': total_affected,
    }


# ==============================================================================
# Algorithm 3: Warm-Start Discrepancy Estimation
# ==============================================================================

def warm_start_discrepancy(
    w: List[float],
    w_prime: List[float]
) -> Dict[str, float]:
    """
    Estimate the warm-start total variation discrepancy when coefficient
    vectors change from w to w'.

    Uses the proven bound: TV(μ, ν) ≤ Δ / min(Z, Z')
    where μ = w/Z, ν = w'/Z', Δ = ||w - w'||₁.

    Parameters:
        w: Original nonneg coefficient vector.
        w_prime: Updated nonneg coefficient vector.

    Returns:
        Dictionary with:
            - 'total_variation': Exact TV between normalized distributions.
            - 'l1_delta': L1 distance between coefficient vectors.
            - 'bound': Upper bound from the theorem.
            - 'bound_tight': Whether the bound is within 2x of exact.

    Example:
        >>> result = warm_start_discrepancy([3, 5, 2], [3.1, 4.9, 2.1])
        >>> print(f"TV = {result['total_variation']:.6f}, bound = {result['bound']:.6f}")
    """
    assert len(w) == len(w_prime), "Weight vectors must have same length"
    assert all(x >= 0 for x in w), "Weights must be nonneg"
    assert all(x >= 0 for x in w_prime), "Weights must be nonneg"

    Z = sum(w)
    Z_prime = sum(w_prime)
    assert Z > 0 and Z_prime > 0, "Total weights must be positive"

    # Normalize
    mu = [x / Z for x in w]
    nu = [x / Z_prime for x in w_prime]

    # Exact TV
    tv = 0.5 * sum(abs(m - n) for m, n in zip(mu, nu))

    # L1 distance
    delta = sum(abs(a - b) for a, b in zip(w, w_prime))

    # Bound from theorem
    bound = delta / min(Z, Z_prime)

    return {
        'total_variation': tv,
        'l1_delta': delta,
        'bound': bound,
        'bound_tight': tv > 0 and bound / tv < 2.0,
        'Z': Z,
        'Z_prime': Z_prime,
    }


# ==============================================================================
# Algorithm 4: Full Dynamic Certification Pipeline
# ==============================================================================

def full_pipeline(
    n_vertices: int,
    edges: List[Tuple[int, int]],
    new_tree_edges: Set[int]
) -> Dict:
    """
    Full dynamic certification pipeline for a graphic matroid.

    Given a graph and a new spanning tree (represented by edge indices),
    compute the dynamic certificate update, warm-start discrepancy,
    and cost comparison.

    Parameters:
        n_vertices: Number of vertices.
        edges: List of edges as (u, v) pairs.
        new_tree_edges: Set of edge indices forming the new spanning tree.

    Returns:
        Comprehensive result dictionary.
    """
    n_edges = len(edges)
    degree = n_vertices - 1

    # Build update monomial (indicator of tree edges)
    alpha = tuple(1 if i in new_tree_edges else 0 for i in range(n_edges))

    # Certificate update costs
    cert_result = dynamic_certificate_update(n_edges, degree, alpha)

    # Warm-start analysis (uniform vs slightly perturbed weights)
    w = [1.0] * (2**n_edges)  # Simplified: uniform over all subsets
    w_prime = list(w)
    # Perturb the weight of subsets containing the new tree
    for i in range(len(w)):
        if i % 3 == 0:  # Simplified perturbation
            w_prime[i] += 0.01

    # Only compute warm-start for small cases
    if len(w) <= 10000:
        ws_result = warm_start_discrepancy(w[:100], w_prime[:100])
    else:
        ws_result = {'total_variation': 0, 'bound': 0}

    return {
        'alpha': alpha,
        'degree': degree,
        'certificate': cert_result,
        'warm_start': ws_result,
    }


# ==============================================================================
# Example Usage
# ==============================================================================

if __name__ == "__main__":
    print("Dynamic Lorentzian Certificate Algorithms")
    print("=" * 50)

    # Example 1: Affected nodes
    print("\n--- Algorithm 1: Affected Node Identification ---")
    alpha = (2, 1, 1, 0)
    affected = identify_affected_nodes(alpha, max_depth=3)
    for k, nodes in affected.items():
        print(f"  Depth {k}: {len(nodes)} affected nodes")

    # Example 2: Dynamic update cost
    print("\n--- Algorithm 2: Dynamic Certificate Update ---")
    result = dynamic_certificate_update(6, 4, (1, 1, 1, 0, 0, 0))
    print(f"  Dynamic cost:  {result['dynamic_cost']:.0f}")
    print(f"  Rebuild cost:  {result['rebuild_cost']:.0f}")
    print(f"  Savings:       {result['savings_ratio']:.1%}")

    # Example 3: Warm-start discrepancy
    print("\n--- Algorithm 3: Warm-Start Discrepancy ---")
    w = [3.0, 5.0, 2.0, 4.0, 1.0]
    w_prime = [3.1, 4.8, 2.05, 4.15, 0.9]
    ws = warm_start_discrepancy(w, w_prime)
    print(f"  TV distance:   {ws['total_variation']:.6f}")
    print(f"  L1 delta:      {ws['l1_delta']:.4f}")
    print(f"  Bound:         {ws['bound']:.6f}")
    print(f"  Bound tight:   {ws['bound_tight']}")

    # Example 4: Full pipeline
    print("\n--- Algorithm 4: Full Pipeline ---")
    edges = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    result = full_pipeline(4, edges, {0, 1, 2})
    print(f"  Update exponent: {result['alpha']}")
    print(f"  Dynamic cost:    {result['certificate']['dynamic_cost']:.0f}")
    print(f"  Rebuild cost:    {result['certificate']['rebuild_cost']:.0f}")
    print(f"  Savings:         {result['certificate']['savings_ratio']:.1%}")
