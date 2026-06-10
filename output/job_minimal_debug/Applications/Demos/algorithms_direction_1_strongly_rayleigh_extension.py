#!/usr/bin/env python3
"""
Algorithms for computing Lorentzian Certificate Matrices for Strongly Rayleigh Polynomials.

This module implements the core computational methods for the intrinsic Hessian certificate
theory. Given a multiaffine polynomial g with nonneg coefficients (represented as a dictionary
from support sets to coefficients), the algorithms compute:

1. g(x) — polynomial evaluation at a positive point
2. ∇g(x) — the gradient vector
3. Hess(g)(x) — the Hessian matrix
4. M_g(x) = g(x)·Hess(g)(x) - ∇g(x)·∇g(x)^T — the certificate matrix
5. Eigenvalue analysis and conditional NSD verification

Complexity: For a multiaffine polynomial with s nonzero terms in n variables,
    - Evaluation: O(s·n) time
    - Gradient: O(s·n²) time
    - Hessian: O(s·n³) time
    - Certificate matrix: O(n² + s·n³) time
    - Eigenvalue decomposition: O(n³) time

Total: O(s·n³ + n³) time, O(n²) space for the certificate matrix.
"""

import numpy as np
from typing import Dict, List, Optional, Tuple
from itertools import combinations


class MultiaffinePolynomial:
    """
    A multiaffine polynomial in n variables with real coefficients.

    Represented as a dictionary mapping frozensets of variable indices to coefficients.
    Multiaffine means each variable appears with degree at most 1.

    Attributes:
        n: Number of variables.
        coeffs: Dictionary {frozenset of indices: coefficient}.
    """

    def __init__(self, n: int, coeffs: Dict[frozenset, float]):
        """
        Initialize a multiaffine polynomial.

        Args:
            n: Number of variables.
            coeffs: Dictionary mapping frozensets of variable indices to coefficients.
        """
        self.n = n
        self.coeffs = {k: v for k, v in coeffs.items() if abs(v) > 1e-15}

    @classmethod
    def from_tuples(cls, n: int, coeffs: Dict[tuple, float]) -> 'MultiaffinePolynomial':
        """Create from a dictionary with tuple keys."""
        return cls(n, {frozenset(k): v for k, v in coeffs.items()})

    def eval(self, x: np.ndarray) -> float:
        """
        Evaluate g(x).

        Args:
            x: Point in R^n.
        Returns:
            g(x).

        Time complexity: O(s*d) where s = number of terms, d = max degree.
        """
        val = 0.0
        for support, coeff in self.coeffs.items():
            term = coeff
            for i in support:
                term *= x[i]
            val += term
        return val

    def gradient(self, x: np.ndarray) -> np.ndarray:
        """
        Compute ∇g(x).

        Args:
            x: Point in R^n.
        Returns:
            Gradient vector of shape (n,).

        Time complexity: O(s*n*d).
        """
        grad = np.zeros(self.n)
        for i in range(self.n):
            for support, coeff in self.coeffs.items():
                if i in support:
                    remaining = support - {i}
                    term = coeff
                    for j in remaining:
                        term *= x[j]
                    grad[i] += term
        return grad

    def hessian(self, x: np.ndarray) -> np.ndarray:
        """
        Compute Hess(g)(x).

        For multiaffine polynomials, diagonal entries are always 0
        (since ∂²g/∂x_i² = 0 for multiaffine g).

        Args:
            x: Point in R^n.
        Returns:
            Hessian matrix of shape (n, n).

        Time complexity: O(s*n²*d).
        """
        H = np.zeros((self.n, self.n))
        for i in range(self.n):
            for j in range(self.n):
                if i != j:
                    for support, coeff in self.coeffs.items():
                        if i in support and j in support:
                            remaining = support - {i, j}
                            term = coeff
                            for k in remaining:
                                term *= x[k]
                            H[i, j] += term
        return H

    def certificate_matrix(self, x: np.ndarray) -> np.ndarray:
        """
        Compute the Lorentzian certificate matrix:
        M_g(x) = g(x) * Hess(g)(x) - ∇g(x) * ∇g(x)^T

        Args:
            x: Point in R^n.
        Returns:
            Certificate matrix of shape (n, n).

        Time complexity: O(s*n² + n²).
        """
        g_val = self.eval(x)
        grad = self.gradient(x)
        hess = self.hessian(x)
        return g_val * hess - np.outer(grad, grad)


class CertificateAnalyzer:
    """
    Analyzes the spectral properties of Lorentzian certificate matrices.

    Given a multiaffine polynomial and an evaluation point, computes and
    analyzes the certificate matrix M_g(x).
    """

    def __init__(self, poly: MultiaffinePolynomial):
        """
        Args:
            poly: The multiaffine polynomial to analyze.
        """
        self.poly = poly

    def analyze(self, x: np.ndarray, tol: float = 1e-10) -> dict:
        """
        Full certificate analysis at point x.

        Args:
            x: Positive point in R^n.
            tol: Tolerance for eigenvalue positivity.

        Returns:
            Dictionary with analysis results:
                - g_val: g(x)
                - gradient: ∇g(x)
                - hessian: Hess(g)(x)
                - certificate: M_g(x)
                - eigenvalues: sorted eigenvalues of M_g(x)
                - n_positive: number of positive eigenvalues
                - is_nsd: whether M_g(x) is NSD
                - is_conditional_nsd: whether M_g(x) is NSD on grad⊥
                - directional_rayleigh_holds: whether (D_u g)² ≥ g·D²_u g for random u
        """
        g_val = self.poly.eval(x)
        grad = self.poly.gradient(x)
        hess = self.poly.hessian(x)
        M = self.poly.certificate_matrix(x)

        eigenvalues = np.sort(np.linalg.eigvalsh(M))[::-1]
        n_positive = int(np.sum(eigenvalues > tol))

        # Check directional Rayleigh for random directions
        dr_holds = True
        for _ in range(1000):
            u = np.random.randn(self.poly.n)
            du_g = u @ grad
            d2u_g = u @ hess @ u
            if g_val * d2u_g > du_g ** 2 + tol:
                dr_holds = False
                break

        return {
            'g_val': g_val,
            'gradient': grad,
            'hessian': hess,
            'certificate': M,
            'eigenvalues': eigenvalues,
            'n_positive': n_positive,
            'is_nsd': n_positive == 0,
            'is_conditional_nsd': n_positive <= 1,
            'directional_rayleigh_holds': dr_holds,
        }


# ============================================================
# Factory functions for common polynomial families
# ============================================================

def dpp_polynomial(K: np.ndarray) -> MultiaffinePolynomial:
    """
    Create the DPP generating polynomial det(I + diag(z)*K).

    Args:
        K: PSD kernel matrix of shape (n, n).
    Returns:
        MultiaffinePolynomial for the DPP.

    Time complexity: O(2^n * n^3) — exponential in n.
    """
    n = K.shape[0]
    coeffs = {}
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            fs = frozenset(subset)
            if len(subset) == 0:
                coeffs[fs] = 1.0
            else:
                sub_K = K[np.ix_(list(subset), list(subset))]
                coeffs[fs] = float(np.linalg.det(sub_K))
    return MultiaffinePolynomial(n, coeffs)


def uniform_matroid_polynomial(n: int, r: int) -> MultiaffinePolynomial:
    """
    Create the basis generating polynomial of U_{r,n}.

    Args:
        n: Ground set size.
        r: Rank.
    Returns:
        MultiaffinePolynomial for the uniform matroid.

    Time complexity: O(C(n,r)).
    """
    coeffs = {}
    for subset in combinations(range(n), r):
        coeffs[frozenset(subset)] = 1.0
    return MultiaffinePolynomial(n, coeffs)


def graphic_matroid_polynomial(adjacency: List[Tuple[int, int]]) -> MultiaffinePolynomial:
    """
    Create the basis generating polynomial for a graphic matroid.

    Args:
        adjacency: List of edges (i, j) with i < j.
    Returns:
        MultiaffinePolynomial for the graphic matroid.

    Time complexity: O(2^m * n) where m = number of edges, n = number of vertices.
    """
    n_vertices = max(max(e) for e in adjacency) + 1
    m = len(adjacency)

    coeffs = {}
    for subset_idx in combinations(range(m), n_vertices - 1):
        # Check if these edges form a spanning tree
        adj = {v: set() for v in range(n_vertices)}
        for idx in subset_idx:
            u, v = adjacency[idx]
            adj[u].add(v)
            adj[v].add(u)

        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == n_vertices:
            coeffs[frozenset(subset_idx)] = 1.0

    return MultiaffinePolynomial(m, coeffs)


if __name__ == "__main__":
    # Example usage
    print("=== Algorithms Module: Example Usage ===\n")

    # DPP example
    K = np.array([[1.0, 0.5], [0.5, 1.0]])
    poly = dpp_polynomial(K)
    analyzer = CertificateAnalyzer(poly)
    x = np.array([1.0, 1.0])
    result = analyzer.analyze(x)

    print(f"DPP with K = [[1, 0.5], [0.5, 1]]")
    print(f"  g(1,1) = {result['g_val']:.4f}")
    print(f"  Eigenvalues of M_g: {result['eigenvalues']}")
    print(f"  NSD: {result['is_nsd']}")
    print(f"  Directional Rayleigh: {result['directional_rayleigh_holds']}")

    # Uniform matroid example
    poly = uniform_matroid_polynomial(4, 2)
    analyzer = CertificateAnalyzer(poly)
    x = np.ones(4)
    result = analyzer.analyze(x)

    print(f"\nUniform matroid U_{{2,4}}")
    print(f"  g(1,...,1) = {result['g_val']:.4f}")
    print(f"  Eigenvalues of M_g: {result['eigenvalues']}")
    print(f"  NSD: {result['is_nsd']}")
