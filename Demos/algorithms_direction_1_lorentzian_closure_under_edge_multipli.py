#!/usr/bin/env python3
"""
Algorithms for Lorentzian Certification of Partition Polynomials

Implements the key algorithms from the research paper:
1. Edge-factor partition polynomial construction
2. Bivariate Hessian computation (analytic)
3. Lorentzian certificate verification
4. Newton's inequality checker
5. Log-concavity sequence verification

All algorithms operate on the factored representation:
Z_G(z) = prod_{e={u,v}} (1 + w_e * z_u * z_v)
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class EdgeFactorGraph:
    """A graph represented by its edge factors for the partition polynomial.

    Attributes:
        n_vertices: Number of vertices
        edges: List of (u, v) pairs (0-indexed)
        couplings: Nonneg coupling strengths w_e for each edge
    """
    n_vertices: int
    edges: List[Tuple[int, int]]
    couplings: List[float]

    def __post_init__(self):
        assert all(w >= 0 for w in self.couplings), "All couplings must be nonneg"
        assert len(self.edges) == len(self.couplings)

    @classmethod
    def complete_graph(cls, n: int, coupling: float = 1.0) -> 'EdgeFactorGraph':
        """Construct the complete graph K_n with uniform coupling."""
        from itertools import combinations
        edges = list(combinations(range(n), 2))
        return cls(n, edges, [coupling] * len(edges))

    @classmethod
    def path_graph(cls, n: int, coupling: float = 1.0) -> 'EdgeFactorGraph':
        """Construct the path graph P_n with uniform coupling."""
        edges = [(i, i + 1) for i in range(n - 1)]
        return cls(n, edges, [coupling] * len(edges))

    @classmethod
    def cycle_graph(cls, n: int, coupling: float = 1.0) -> 'EdgeFactorGraph':
        """Construct the cycle graph C_n with uniform coupling."""
        edges = [(i, (i + 1) % n) for i in range(n)]
        return cls(n, edges, [coupling] * len(edges))


@dataclass
class LorentzianCertificate:
    """Certificate that a 2x2 Hessian slice is Lorentzian.

    Attributes:
        var_i, var_j: The two active variables
        hessian: The 2x2 Hessian matrix
        determinant: det(H) = a*d - b^2
        eigenvalues: Sorted eigenvalues
        is_lorentzian: True if det <= 0
    """
    var_i: int
    var_j: int
    hessian: np.ndarray
    determinant: float
    eigenvalues: np.ndarray
    is_lorentzian: bool


def evaluate_partition(graph: EdgeFactorGraph, z: np.ndarray) -> float:
    """Evaluate the partition polynomial at z.

    Z_G(z) = prod_e (1 + w_e * z_u * z_v)

    Time complexity: O(|E|)
    Space complexity: O(1)

    Args:
        graph: The edge-factor graph
        z: Variable values (length n_vertices)

    Returns:
        Value of the partition polynomial

    Example:
        >>> G = EdgeFactorGraph.complete_graph(3)
        >>> evaluate_partition(G, np.ones(3))
        8.0
    """
    result = 1.0
    for (u, v), w in zip(graph.edges, graph.couplings):
        result *= (1.0 + w * z[u] * z[v])
    return result


def compute_hessian_slice(
    graph: EdgeFactorGraph,
    var_i: int,
    var_j: int,
    z: np.ndarray
) -> np.ndarray:
    """Compute the 2x2 Hessian of Z restricted to variables (var_i, var_j).

    For multiaffine Z = prod_e (1 + w_e z_u z_v):
    - d²Z/dz_i² = 0 (multiaffinity)
    - d²Z/dz_j² = 0 (multiaffinity)
    - d²Z/dz_i dz_j = sum over edges e connecting i,j of w_e * prod_{f≠e} (1 + w_f z_u z_v)

    Time complexity: O(|E|²) in worst case, O(|E|) with prefix products
    Space complexity: O(|E|)

    Args:
        graph: The edge-factor graph
        var_i, var_j: The two active variables
        z: Fixed values for all variables

    Returns:
        2x2 numpy array (the Hessian)
    """
    # Precompute all edge factor values
    factors = np.array([
        1.0 + w * z[u] * z[v]
        for (u, v), w in zip(graph.edges, graph.couplings)
    ])

    # Total product
    total_product = np.prod(factors)

    # Mixed partial: sum over connecting edges of w_e * prod_other
    mixed_partial = 0.0
    for k, ((u, v), w) in enumerate(zip(graph.edges, graph.couplings)):
        if (u == var_i and v == var_j) or (u == var_j and v == var_i):
            if factors[k] != 0:
                prod_other = total_product / factors[k]
            else:
                # Recompute without this factor
                prod_other = np.prod([factors[m] for m in range(len(factors)) if m != k])
            mixed_partial += w * prod_other

    return np.array([[0.0, mixed_partial], [mixed_partial, 0.0]])


def verify_lorentzian(hessian: np.ndarray) -> Tuple[bool, float, np.ndarray]:
    """Verify the Lorentzian condition for a 2x2 symmetric matrix.

    A 2x2 matrix has at most one positive eigenvalue iff det(H) <= 0.

    Time complexity: O(1)

    Args:
        hessian: 2x2 symmetric numpy array

    Returns:
        (is_lorentzian, determinant, eigenvalues)

    Example:
        >>> H = np.array([[0, 1], [1, 0]])
        >>> verify_lorentzian(H)
        (True, -1.0, array([-1.,  1.]))
    """
    det = hessian[0, 0] * hessian[1, 1] - hessian[0, 1] ** 2
    eigenvalues = np.linalg.eigvalsh(hessian)
    is_lorentzian = det <= 1e-10
    return is_lorentzian, det, eigenvalues


def certify_graph(
    graph: EdgeFactorGraph,
    z: Optional[np.ndarray] = None,
    rng: Optional[np.random.Generator] = None
) -> List[LorentzianCertificate]:
    """Certify the Lorentzian condition for all variable pairs.

    Time complexity: O(n² · |E|)
    Space complexity: O(n²)

    Args:
        graph: The edge-factor graph
        z: Fixed variable values (random positive if None)
        rng: Random number generator

    Returns:
        List of LorentzianCertificate for each pair

    Example:
        >>> G = EdgeFactorGraph.complete_graph(3)
        >>> certs = certify_graph(G)
        >>> all(c.is_lorentzian for c in certs)
        True
    """
    if z is None:
        if rng is None:
            rng = np.random.default_rng(42)
        z = rng.uniform(0.5, 2.0, size=graph.n_vertices)

    certificates = []
    for i in range(graph.n_vertices):
        for j in range(i + 1, graph.n_vertices):
            H = compute_hessian_slice(graph, i, j, z)
            is_lor, det, eigs = verify_lorentzian(H)
            cert = LorentzianCertificate(
                var_i=i, var_j=j,
                hessian=H, determinant=det,
                eigenvalues=eigs, is_lorentzian=is_lor
            )
            certificates.append(cert)

    return certificates


def check_newton_inequality(a: float, b: float) -> Tuple[bool, float]:
    """Check Newton's inequality: (a + b)² >= 4ab.

    Time complexity: O(1)

    Args:
        a, b: Nonneg reals

    Returns:
        (holds, gap) where gap = (a+b)² - 4ab = (a-b)² >= 0

    Example:
        >>> check_newton_inequality(3.0, 5.0)
        (True, 4.0)
    """
    gap = (a - b) ** 2
    return gap >= -1e-10, gap


def check_log_concavity(seq: List[float]) -> Tuple[bool, List[float]]:
    """Check if a nonneg sequence is log-concave.

    A sequence (a_k) is log-concave if a_k² >= a_{k-1} * a_{k+1} for all k.

    Time complexity: O(n)

    Args:
        seq: Nonneg sequence

    Returns:
        (is_log_concave, gaps) where gaps[k] = a_k² - a_{k-1} * a_{k+1}

    Example:
        >>> check_log_concavity([1, 3, 3, 1])
        (True, [6.0, 6.0])
    """
    gaps = []
    for k in range(1, len(seq) - 1):
        gap = seq[k] ** 2 - seq[k - 1] * seq[k + 1]
        gaps.append(gap)
    is_log_concave = all(g >= -1e-10 for g in gaps)
    return is_log_concave, gaps


def univariate_specialization(
    graph: EdgeFactorGraph,
    active_var: int,
    z_fixed: np.ndarray
) -> List[float]:
    """Compute coefficients of the univariate specialization.

    Fix all variables except active_var to z_fixed values.
    The result is a polynomial in z_{active_var} of degree at most
    equal to the number of edges incident to active_var.

    Time complexity: O(2^d * |E|) where d = degree of active_var
    Space complexity: O(d)

    Args:
        graph: The edge-factor graph
        active_var: The variable to keep free
        z_fixed: Fixed values for other variables

    Returns:
        Coefficients [a_0, a_1, ..., a_d] of the univariate polynomial
    """
    # Separate edges into those incident to active_var and others
    incident_edges = []
    other_factor = 1.0

    for k, ((u, v), w) in enumerate(zip(graph.edges, graph.couplings)):
        if u == active_var or v == active_var:
            other_vertex = v if u == active_var else u
            incident_edges.append((w, z_fixed[other_vertex]))
        else:
            other_factor *= (1.0 + w * z_fixed[u] * z_fixed[v])

    # The polynomial in t = z_{active_var} is:
    # other_factor * prod_e (1 + w_e * z_{other} * t)
    # = other_factor * prod_e (1 + b_e * t) where b_e = w_e * z_{other}

    # Compute coefficients of prod (1 + b_e * t) using dynamic programming
    n_incident = len(incident_edges)
    b_values = [w * z_other for w, z_other in incident_edges]

    # coeffs[k] = e_k(b_1, ..., b_n) = k-th elementary symmetric polynomial
    coeffs = [0.0] * (n_incident + 1)
    coeffs[0] = 1.0
    for b in b_values:
        new_coeffs = [0.0] * (n_incident + 1)
        for k in range(n_incident + 1):
            new_coeffs[k] = coeffs[k]
            if k > 0:
                new_coeffs[k] += b * coeffs[k - 1]
        coeffs = new_coeffs

    # Multiply by other_factor
    return [c * other_factor for c in coeffs]


if __name__ == "__main__":
    print("=== Algorithms Demo ===\n")

    # Example 1: Complete graph K_4
    G = EdgeFactorGraph.complete_graph(4, coupling=1.0)
    z = np.array([1.0, 1.5, 2.0, 0.5])

    print(f"Graph: K_4 with uniform coupling 1.0")
    print(f"Z(z) = {evaluate_partition(G, z):.6f}")
    print()

    # Certify all pairs
    certs = certify_graph(G, z)
    print("Lorentzian certificates:")
    for c in certs:
        print(f"  ({c.var_i},{c.var_j}): det = {c.determinant:.6f}, "
              f"eigs = [{c.eigenvalues[0]:.4f}, {c.eigenvalues[1]:.4f}], "
              f"{'✓' if c.is_lorentzian else '✗'}")
    print()

    # Example 2: Univariate specialization and log-concavity
    coeffs = univariate_specialization(G, 0, z)
    is_lc, gaps = check_log_concavity(coeffs)
    print(f"Univariate specialization (active var 0):")
    print(f"  Coefficients: {[f'{c:.4f}' for c in coeffs]}")
    print(f"  Log-concave: {is_lc}")
    print(f"  Newton gaps: {[f'{g:.4f}' for g in gaps]}")
    print()

    # Example 3: Newton's inequality
    for a, b in [(1, 4), (2, 3), (5, 5), (0, 7)]:
        holds, gap = check_newton_inequality(a, b)
        print(f"  Newton({a},{b}): (a+b)²={int((a+b)**2)}, 4ab={int(4*a*b)}, "
              f"gap={(a-b)**2}, {'✓' if holds else '✗'}")
