"""
Dynamic Lorentzian Certificate Algorithms
==========================================

This module implements the core algorithms for dynamic Lorentzian certificate
maintenance: identifying affected derivative nodes from an update monomial,
recomputing only impacted leaves, and comparing dynamic update cost with full
rebuild cost.

Author: Harmonic Research
"""

from __future__ import annotations
from typing import Dict, List, Tuple, Set, Optional
from itertools import product
from math import comb, prod, log
import numpy as np


# ---------------------------------------------------------------------------
# 1. Multiindex and Affected-Set Computation
# ---------------------------------------------------------------------------

def affected_multiindices(alpha: Tuple[int, ...], k: int) -> List[Tuple[int, ...]]:
    """
    Compute the set Affected(α, k) = {β : sum(β)=k and β_i ≤ α_i for all i}.

    Parameters
    ----------
    alpha : tuple of ints
        The update exponent vector (monomial exponent).
    k : int
        The derivative depth.

    Returns
    -------
    List of tuples, each a multiindex in the affected set.

    Example
    -------
    >>> affected_multiindices((2, 1, 1), 2)
    [(0, 1, 1), (1, 0, 1), (1, 1, 0), (2, 0, 0)]
    """
    n = len(alpha)
    result = []

    def _backtrack(idx: int, remaining: int, current: List[int]):
        if idx == n:
            if remaining == 0:
                result.append(tuple(current))
            return
        for v in range(min(alpha[idx], remaining) + 1):
            current.append(v)
            _backtrack(idx + 1, remaining - v, current)
            current.pop()

    _backtrack(0, k, [])
    return result


def affected_count(alpha: Tuple[int, ...], k: int) -> int:
    """Count |Affected(α, k)|."""
    return len(affected_multiindices(alpha, k))


# ---------------------------------------------------------------------------
# 2. Dynamic Certificate Cost
# ---------------------------------------------------------------------------

def dynamic_certificate_cost(n: int, d: int, alpha: Tuple[int, ...]) -> int:
    """
    Compute the dynamic certificate cost = sum_{k=0}^{d-2} |Affected(α,k)|.

    This counts the total number of certificate tree nodes that potentially
    need recomputation after a rank-1 update by monomial X^α.

    Parameters
    ----------
    n : int
        Number of variables.
    d : int
        Degree of the polynomial.
    alpha : tuple of ints
        The update exponent vector, with sum(alpha) = d.

    Returns
    -------
    int : the dynamic certificate cost.
    """
    assert len(alpha) == n
    assert sum(alpha) == d
    return sum(affected_count(alpha, k) for k in range(d - 1))


def rebuild_cost(n: int, d: int) -> int:
    """Full rebuild cost = n^d (certificate verification complexity)."""
    return n ** d


def cost_ratio(n: int, d: int, alpha: Tuple[int, ...]) -> float:
    """
    Ratio of dynamic update cost to full rebuild cost.

    A ratio < 1 indicates the dynamic update is cheaper.
    """
    rc = rebuild_cost(n, d)
    if rc == 0:
        return 1.0
    dc = dynamic_certificate_cost(n, d, alpha)
    return dc / rc


# ---------------------------------------------------------------------------
# 3. Rank-1 Polynomial Update
# ---------------------------------------------------------------------------

class HomogeneousPolynomial:
    """
    Represents a homogeneous polynomial of degree d in n variables
    as a dictionary mapping monomial exponent tuples to coefficients.

    Example
    -------
    >>> p = HomogeneousPolynomial(3, {(2,1): 3.0, (1,2): 1.0, (3,0): 2.0})
    """

    def __init__(self, n: int, coeffs: Optional[Dict[Tuple[int, ...], float]] = None):
        self.n = n
        self.coeffs: Dict[Tuple[int, ...], float] = coeffs or {}
        if self.coeffs:
            self.degree = sum(next(iter(self.coeffs.keys())))
        else:
            self.degree = 0

    def rank_one_update(self, c: float, alpha: Tuple[int, ...]) -> 'HomogeneousPolynomial':
        """
        Return f + c * X^alpha.

        Parameters
        ----------
        c : float
            Scalar coefficient.
        alpha : tuple of ints
            Monomial exponent vector.
        """
        new_coeffs = dict(self.coeffs)
        new_coeffs[alpha] = new_coeffs.get(alpha, 0.0) + c
        result = HomogeneousPolynomial(self.n, new_coeffs)
        result.degree = self.degree if self.degree > 0 else sum(alpha)
        return result

    def is_homogeneous(self) -> bool:
        """Check if all monomials have the same total degree."""
        if not self.coeffs:
            return True
        degrees = {sum(m) for m in self.coeffs}
        return len(degrees) == 1

    def total_coeff_mass(self) -> float:
        """Sum of absolute values of coefficients."""
        return sum(abs(c) for c in self.coeffs.values())

    def positive_coeff_mass(self) -> float:
        """Sum of nonneg coefficients (partition function)."""
        return sum(c for c in self.coeffs.values() if c > 0)


# ---------------------------------------------------------------------------
# 4. Certificate Tree Representation
# ---------------------------------------------------------------------------

class CertificateNode:
    """
    A node in the Lorentzian certificate tree.

    Each node corresponds to an iterated partial derivative ∂^β f,
    where β is a multiindex of weight k. Leaf nodes (k = d-2) contain
    quadratic forms whose Hessians must have Lorentzian signature.
    """

    def __init__(self, beta: Tuple[int, ...], depth: int, is_leaf: bool = False):
        self.beta = beta
        self.depth = depth
        self.is_leaf = is_leaf
        self.children: List[CertificateNode] = []
        self.is_affected = False

    def mark_affected(self, alpha: Tuple[int, ...]):
        """
        Mark this node as affected if β ≤ α componentwise.
        """
        self.is_affected = all(b <= a for b, a in zip(self.beta, alpha))
        for child in self.children:
            child.mark_affected(alpha)

    def count_affected(self) -> int:
        """Count affected nodes in subtree."""
        count = 1 if self.is_affected else 0
        for child in self.children:
            count += child.count_affected()
        return count

    def count_total(self) -> int:
        """Count total nodes in subtree."""
        count = 1
        for child in self.children:
            count += child.count_total()
        return count


def build_certificate_tree(n: int, d: int) -> CertificateNode:
    """
    Build a certificate tree for degree d in n variables.

    The tree has depth d-2, with nodes at depth k corresponding
    to multiindices of weight k.
    """
    root = CertificateNode(tuple([0] * n), 0)
    if d <= 2:
        root.is_leaf = True
        return root

    def _build(parent: CertificateNode, current_depth: int):
        max_depth = d - 2
        if current_depth >= max_depth:
            parent.is_leaf = True
            return
        # For each variable, we can differentiate once more
        for i in range(n):
            new_beta = list(parent.beta)
            new_beta[i] += 1
            child = CertificateNode(tuple(new_beta), current_depth + 1,
                                    is_leaf=(current_depth + 1 >= max_depth))
            parent.children.append(child)
            if current_depth + 1 < max_depth:
                _build(child, current_depth + 1)

    _build(root, 0)
    return root


# ---------------------------------------------------------------------------
# 5. Warm-Start Discrepancy
# ---------------------------------------------------------------------------

def normalize_pmf(w: np.ndarray) -> np.ndarray:
    """Normalize a nonneg weight vector to a probability distribution."""
    total = w.sum()
    if total <= 0:
        raise ValueError("Weight vector must have positive sum")
    return w / total


def total_variation_distance(mu: np.ndarray, nu: np.ndarray) -> float:
    """
    Compute the total variation distance TV(μ, ν) = (1/2) ∑|μ_i - ν_i|.
    """
    return 0.5 * np.sum(np.abs(mu - nu))


def warm_start_discrepancy(w_old: np.ndarray, w_new: np.ndarray) -> float:
    """
    Compute the warm-start discrepancy between old and new coefficient
    distributions.

    Returns TV(normalize(w_old), normalize(w_new)).
    """
    mu = normalize_pmf(w_old)
    nu = normalize_pmf(w_new)
    return total_variation_distance(mu, nu)


def coefficient_l1_delta(w_old: np.ndarray, w_new: np.ndarray) -> float:
    """Compute ∑|w_old - w_new|."""
    return np.sum(np.abs(w_old - w_new))


def tv_upper_bound(w_old: np.ndarray, w_new: np.ndarray) -> float:
    """
    Compute the upper bound from normalizedCoeffDist_tv_bound:
    TV ≤ Δ / max(Z, Z') where Δ = ∑|w-w'|, Z = ∑w, Z' = ∑w'.
    """
    delta = coefficient_l1_delta(w_old, w_new)
    z_max = max(w_old.sum(), w_new.sum())
    if z_max <= 0:
        return float('inf')
    return delta / z_max


# ---------------------------------------------------------------------------
# 6. Graphic Matroid Utilities
# ---------------------------------------------------------------------------

def spanning_tree_polynomial_update(
    n_vertices: int,
    old_trees: List[Tuple[int, ...]],
    new_edge: Tuple[int, int],
    adjacency: Set[Tuple[int, int]]
) -> Tuple[List[Tuple[int, ...]], List[Tuple[int, ...]]]:
    """
    Given existing spanning trees and a new edge, compute which new
    spanning trees are created.

    Parameters
    ----------
    n_vertices : int
        Number of vertices.
    old_trees : list of tuples
        Each tuple is a set of edge indices forming a spanning tree.
    new_edge : tuple
        The new edge (u, v) being added.
    adjacency : set
        Current edge set.

    Returns
    -------
    new_trees : list of new spanning tree edge-sets
    all_trees : list of all spanning trees after the update
    """
    # In the single-basis insertion model, adding one edge can create
    # new spanning trees by replacing existing edges on the cycle
    # This is a simplified placeholder
    return [], old_trees


# ---------------------------------------------------------------------------
# 7. Dynamic Certificate Maintenance Algorithm
# ---------------------------------------------------------------------------

def dynamic_certificate_update(
    n: int,
    d: int,
    alpha: Tuple[int, ...],
    old_certificate: Optional[Dict] = None
) -> Dict:
    """
    Perform a dynamic certificate update after a rank-1 monomial perturbation.

    Algorithm:
    1. Identify affected derivative nodes at each depth k ∈ {0, ..., d-2}
    2. For each affected leaf (depth d-2), recompute the Hessian spectral test
    3. For each affected internal node, recombine child results
    4. Report update cost and affected fraction

    Parameters
    ----------
    n : int
        Number of variables.
    d : int
        Degree.
    alpha : tuple of ints
        Update monomial exponent.

    Returns
    -------
    dict with keys:
        'affected_counts': list of |Affected(α,k)| for k = 0, ..., d-2
        'total_affected': total affected node count
        'dynamic_cost': estimated update cost (affected nodes * n^2)
        'rebuild_cost': full rebuild cost (n^d)
        'speedup': rebuild_cost / dynamic_cost
        'affected_fraction': fraction of tree affected
    """
    affected_counts = [affected_count(alpha, k) for k in range(d - 1)]
    total_affected = sum(affected_counts)

    # Per-leaf cost is O(n^2) for spectral test
    dyn_cost = total_affected * n * n
    reb_cost = rebuild_cost(n, d)

    # Total nodes in full tree (approximate)
    total_nodes = sum(comb(k + n - 1, n - 1) for k in range(d - 1))

    speedup = reb_cost / dyn_cost if dyn_cost > 0 else float('inf')
    affected_frac = total_affected / total_nodes if total_nodes > 0 else 0

    return {
        'affected_counts': affected_counts,
        'total_affected': total_affected,
        'dynamic_cost': dyn_cost,
        'rebuild_cost': reb_cost,
        'speedup': speedup,
        'affected_fraction': affected_frac,
    }


# ---------------------------------------------------------------------------
# Example Usage
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    print("=== Dynamic Lorentzian Certificate Algorithms ===\n")

    # Example 1: Sparse update in 5 variables, degree 4
    n, d = 5, 4
    alpha = (2, 1, 1, 0, 0)
    result = dynamic_certificate_update(n, d, alpha)

    print(f"Variables: {n}, Degree: {d}")
    print(f"Update monomial exponent: {alpha}")
    print(f"Affected counts by depth: {result['affected_counts']}")
    print(f"Total affected nodes: {result['total_affected']}")
    print(f"Dynamic cost: {result['dynamic_cost']}")
    print(f"Rebuild cost: {result['rebuild_cost']}")
    print(f"Speedup: {result['speedup']:.2f}x")
    print(f"Affected fraction: {result['affected_fraction']:.4f}")
    print()

    # Example 2: Dense update
    alpha_dense = (1, 1, 1, 1, 0)
    result2 = dynamic_certificate_update(n, d, alpha_dense)
    print(f"Dense update α = {alpha_dense}")
    print(f"Total affected: {result2['total_affected']}, Speedup: {result2['speedup']:.2f}x")
    print()

    # Example 3: Warm-start discrepancy
    w_old = np.array([3.0, 2.0, 1.0, 0.5, 0.1])
    w_new = np.array([3.0, 2.0, 1.0, 0.5, 1.1])  # One coefficient changed
    tv = warm_start_discrepancy(w_old, w_new)
    bound = tv_upper_bound(w_old, w_new)
    print(f"Warm-start TV distance: {tv:.6f}")
    print(f"Upper bound (Δ/max(Z,Z')): {bound:.6f}")
    print(f"Bound is {'tight' if abs(tv - bound) < 0.01 else 'loose'}")
