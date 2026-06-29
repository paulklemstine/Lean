"""
algorithms.py — Core algorithms for M-Convex Shadow Compression Theory

Implements the key computational objects from the Universal M-Convex 
Compression Theorem: Newton supports, M-convex shadows, dominating fibers, 
quadratic leaf counts, and exchange property verification.

Author: Harmonic Research
"""

from itertools import combinations, product
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Optional
import numpy as np


# Type aliases
ExponentVector = Tuple[int, ...]


def total_degree(alpha: ExponentVector) -> int:
    """Total degree of a multi-index: sum of all coordinates."""
    return sum(alpha)


def dominates(alpha: ExponentVector, beta: ExponentVector) -> bool:
    """Check if alpha ≤ beta coordinatewise."""
    return all(a <= b for a, b in zip(alpha, beta))


def newton_support(coefficients: Dict[ExponentVector, float]) -> Set[ExponentVector]:
    """
    Compute the Newton support of a polynomial.
    
    The Newton support is the set of exponent vectors with nonzero coefficient.
    
    Args:
        coefficients: Dictionary mapping exponent vectors to coefficients.
    
    Returns:
        Set of exponent vectors with nonzero coefficient.
    """
    return {alpha for alpha, c in coefficients.items() if abs(c) > 1e-12}


def support_shadow(S: Set[ExponentVector]) -> Set[ExponentVector]:
    """
    Compute the full support shadow: all exponent vectors dominated
    by some element of S.
    
    Warning: This can be very large. Use degree_shadow for bounded computation.
    """
    shadow = set()
    for beta in S:
        # Generate all alpha ≤ beta
        ranges = [range(b + 1) for b in beta]
        for alpha in product(*ranges):
            shadow.add(alpha)
    return shadow


def degree_shadow(S: Set[ExponentVector], k: int) -> Set[ExponentVector]:
    """
    Compute the degree-k shadow of S: all exponent vectors of total
    degree k that are coordinatewise dominated by some element of S.
    
    This is the central object of the compression theorem.
    
    Args:
        S: Set of support exponent vectors.
        k: Target total degree.
    
    Returns:
        Set of degree-k shadow elements.
    
    Complexity: O(|S| * max_coord^n) where n is the dimension.
    """
    shadow = set()
    for beta in S:
        _generate_dominated(beta, k, 0, [], shadow)
    return shadow


def _generate_dominated(beta: ExponentVector, target_deg: int, 
                         idx: int, current: list, result: Set):
    """Recursively generate all alpha ≤ beta with total_degree = target_deg."""
    n = len(beta)
    remaining = target_deg - sum(current)
    
    if idx == n:
        if remaining == 0:
            result.add(tuple(current))
        return
    
    max_val = min(beta[idx], remaining)
    remaining_coords = n - idx - 1
    
    for val in range(max_val + 1):
        new_remaining = remaining - val
        if new_remaining >= 0 and new_remaining <= sum(beta[idx+1:]):
            current.append(val)
            _generate_dominated(beta, target_deg, idx + 1, current, result)
            current.pop()


def dominating_fiber(S: Set[ExponentVector], alpha: ExponentVector) -> Set[ExponentVector]:
    """
    Compute the dominating fiber of alpha in S:
    all beta in S such that alpha ≤ beta coordinatewise.
    """
    return {beta for beta in S if dominates(alpha, beta)}


def quadratic_leaf_fiber(S: Set[ExponentVector], alpha: ExponentVector) -> Set[ExponentVector]:
    """
    Compute the quadratic leaf fiber: support elements dominating alpha
    with total degree exactly total_degree(alpha) + 2.
    """
    target = total_degree(alpha) + 2
    return {beta for beta in S 
            if dominates(alpha, beta) and total_degree(beta) == target}


def deriv_weight(alpha: ExponentVector, beta: ExponentVector) -> int:
    """
    Compute the multinomial derivative weight: product of descending factorials.
    
    When differentiating x^beta by ∂^alpha, the coefficient picks up
    a factor of prod_i (beta_i)! / (beta_i - alpha_i)! = prod_i descFactorial(beta_i, alpha_i).
    """
    weight = 1
    for a, b in zip(alpha, beta):
        # descFactorial(b, a) = b * (b-1) * ... * (b-a+1)
        for k in range(a):
            weight *= (b - k)
    return weight


def quadratic_leaf_count(S: Set[ExponentVector], r: int) -> int:
    """
    Count nonzero quadratic leaves: the number of degree-(r-2) shadow elements.
    
    This is the main quantity the compression theorem characterizes.
    """
    return len(degree_shadow(S, r - 2))


def is_homogeneous_support(S: Set[ExponentVector], r: int) -> bool:
    """Check if all elements of S have total degree r."""
    return all(total_degree(beta) == r for beta in S)


def verify_mconvex_exchange(S: Set[ExponentVector]) -> Tuple[bool, Optional[str]]:
    """
    Verify the M-convex symmetric exchange property for S.
    
    For all alpha, beta in S, for all i with alpha_i > beta_i,
    there must exist j with alpha_j < beta_j such that
    alpha - e_i + e_j is in S.
    
    Returns:
        (is_valid, error_message)
    """
    S_list = list(S)
    n = len(S_list[0]) if S_list else 0
    
    for alpha in S_list:
        for beta in S_list:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in S:
                                found = True
                                break
                    if not found:
                        return False, (
                            f"Exchange fails: alpha={alpha}, beta={beta}, "
                            f"i={i}: no valid j found"
                        )
    return True, None


def active_coordinates(S: Set[ExponentVector]) -> Set[int]:
    """Return the set of coordinate indices that are nonzero in some support element."""
    active = set()
    for beta in S:
        for i, val in enumerate(beta):
            if val > 0:
                active.add(i)
    return active


def exchange_visible_shadow(S: Set[ExponentVector], k: int,
                              coefficients: Optional[Dict[ExponentVector, float]] = None
                              ) -> Set[ExponentVector]:
    """
    Compute the exchange-visible shadow: degree-k shadow elements where
    the quadratic leaf fiber is nonempty and no cancellation occurs.
    
    For nonneg coefficients, this equals the full degree-k shadow.
    """
    shadow = degree_shadow(S, k)
    if coefficients is None:
        return shadow
    
    visible = set()
    for alpha in shadow:
        fiber = quadratic_leaf_fiber(S, alpha)
        if fiber:
            # Check no-cancellation: all fiber coefficients are nonneg
            all_nonneg = all(coefficients.get(beta, 0) >= 0 for beta in fiber)
            if all_nonneg:
                visible.add(alpha)
    return visible


# ─── Matroid Basis Support ───

def matroid_basis_support(bases: List[Set[int]], n: int) -> Set[ExponentVector]:
    """
    Convert matroid bases to multiaffine support vectors.
    
    Each basis B ⊆ [n] becomes the indicator vector with 1s at positions in B.
    """
    support = set()
    for basis in bases:
        vec = tuple(1 if i in basis else 0 for i in range(n))
        support.add(vec)
    return support


def uniform_matroid_bases(n: int, r: int) -> List[Set[int]]:
    """Generate all bases of the uniform matroid U_{r,n}."""
    return [set(combo) for combo in combinations(range(n), r)]


# ─── Flow Polytope Support ───

def flow_polytope_support(
    incidence: np.ndarray,  # m x k matrix
    capacities: np.ndarray,  # m-vector
    demand: np.ndarray  # k-vector
) -> Set[ExponentVector]:
    """
    Enumerate all feasible integer flows on a network.
    
    Args:
        incidence: m x k incidence matrix (edges x nodes).
        capacities: Upper bound on each edge.
        demand: Net demand at each node.
    
    Returns:
        Set of feasible flow vectors as ExponentVectors.
    """
    m = len(capacities)
    k = incidence.shape[1] if len(incidence.shape) > 1 else 0
    
    flows = set()
    ranges = [range(int(cap) + 1) for cap in capacities]
    
    for flow_vals in product(*ranges):
        flow = np.array(flow_vals)
        # Check conservation: incidence^T * flow = demand
        if k > 0:
            net_flow = incidence.T @ flow
            if np.allclose(net_flow, demand):
                flows.add(tuple(int(v) for v in flow_vals))
        else:
            flows.add(tuple(int(v) for v in flow_vals))
    
    return flows


# ─── Analysis Functions ───

def analyze_support(S: Set[ExponentVector], name: str = "Support") -> dict:
    """
    Comprehensive analysis of a support set.
    
    Returns a dictionary with all key computed quantities.
    """
    if not S:
        return {"name": name, "empty": True}
    
    n = len(next(iter(S)))
    degrees = {total_degree(beta) for beta in S}
    
    result = {
        "name": name,
        "dimension": n,
        "support_size": len(S),
        "degrees": sorted(degrees),
        "is_homogeneous": len(degrees) == 1,
        "active_coords": sorted(active_coordinates(S)),
        "num_active_coords": len(active_coordinates(S)),
    }
    
    if len(degrees) == 1:
        r = degrees.pop()
        result["degree"] = r
        
        is_mc, msg = verify_mconvex_exchange(S)
        result["is_mconvex"] = is_mc
        if not is_mc:
            result["mconvex_failure"] = msg
        
        if r >= 2:
            shadow = degree_shadow(S, r - 2)
            result["shadow_size"] = len(shadow)
            result["quadratic_leaf_count"] = len(shadow)
            
            # Analyze fiber sizes
            fiber_sizes = {}
            for alpha in shadow:
                fiber = quadratic_leaf_fiber(S, alpha)
                sz = len(fiber)
                fiber_sizes[sz] = fiber_sizes.get(sz, 0) + 1
            result["fiber_size_distribution"] = fiber_sizes
    
    return result


def compare_shadow_and_leaves(S: Set[ExponentVector], 
                                coefficients: Dict[ExponentVector, float],
                                r: int) -> dict:
    """
    Compare the degree-(r-2) shadow cardinality with the actual
    number of nonzero quadratic derivatives.
    
    For nonneg coefficients, these should be equal (the compression theorem).
    """
    shadow = degree_shadow(S, r - 2)
    visible = exchange_visible_shadow(S, r - 2, coefficients)
    
    return {
        "shadow_size": len(shadow),
        "visible_shadow_size": len(visible),
        "are_equal": len(shadow) == len(visible),
        "all_coeffs_nonneg": all(c >= 0 for c in coefficients.values()),
    }


if __name__ == "__main__":
    # Quick demonstration
    print("=== M-Convex Shadow Compression Algorithms ===\n")
    
    # Example 1: Uniform matroid U_{3,5}
    bases = uniform_matroid_bases(5, 3)
    S = matroid_basis_support(bases, 5)
    result = analyze_support(S, "U_{3,5}")
    print(f"Uniform matroid U_{{3,5}}:")
    print(f"  Support size: {result['support_size']}")
    print(f"  Is M-convex: {result['is_mconvex']}")
    print(f"  Shadow size (degree 1): {result.get('shadow_size', 'N/A')}")
    print(f"  Quadratic leaf count: {result.get('quadratic_leaf_count', 'N/A')}")
    print(f"  Fiber distribution: {result.get('fiber_size_distribution', 'N/A')}")
    print()
    
    # Example 2: Non-matroidal M-convex set
    S2 = {(2, 0, 0), (1, 1, 0), (1, 0, 1), (0, 2, 0), (0, 1, 1), (0, 0, 2)}
    result2 = analyze_support(S2, "Full degree-2")
    print(f"Full degree-2 simplex:")
    print(f"  Support size: {result2['support_size']}")
    print(f"  Is M-convex: {result2['is_mconvex']}")
    print(f"  Shadow size: {result2.get('shadow_size', 'N/A')}")
    print()
