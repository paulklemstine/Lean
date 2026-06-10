"""
Resolvent Geometry Algorithms — Certificate Checking and Hessian Analysis

This module implements the core computational algorithms for resolvent-compatible
polynomial geometry:
1. Log-Hessian computation at x=1 for various polynomial families
2. Conditional negative semidefiniteness verification on the zero-sum subspace
3. Laplacian certificate fitting
4. Resolvent formula computation for DPP kernels

All functions work with NumPy arrays for numerical linear algebra.
"""

import numpy as np
from typing import Optional, Tuple, Dict, List


def log_hessian_product_linear_forms(
    coefficients: np.ndarray
) -> np.ndarray:
    """Compute the log-Hessian at x=1 of a product of positive linear forms.

    For linear forms ℓ_r(x) = ∑_i a_{ri} x_i, the product p(x) = ∏_r ℓ_r(x)
    has log-Hessian at x=1:
        H_{ij} = -∑_r a_{ri} a_{rj} / (∑_k a_{rk})^2

    Args:
        coefficients: (m, n) array where row r gives coefficients of ℓ_r.
                      All entries should be nonneg and each row sum positive.

    Returns:
        (n, n) symmetric matrix H, the log-Hessian at x=1.

    Example:
        >>> a = np.array([[1.0, 2.0], [3.0, 1.0]])
        >>> H = log_hessian_product_linear_forms(a)
        >>> np.allclose(H, H.T)  # symmetric
        True
    """
    m, n = coefficients.shape
    row_sums = coefficients.sum(axis=1)  # S_r = ∑_k a_{rk}
    if np.any(row_sums <= 0):
        raise ValueError("All linear forms must have positive value at x=1")

    H = np.zeros((n, n))
    for r in range(m):
        s = row_sums[r]
        a_r = coefficients[r]
        H -= np.outer(a_r, a_r) / s**2
    return H


def dpp_resolvent_hessian(A: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Compute the DPP resolvent matrix L and Hessian H.

    Given a symmetric matrix A with (I+A) invertible:
        L = A @ (I+A)^{-1}  (resolvent / L-ensemble kernel)
        H_{ij} = -L_{ij}^2   (log-Hessian of det(I + diag(x)A) at x=1)

    Args:
        A: (n, n) symmetric real matrix with (I+A) invertible.

    Returns:
        Tuple (L, H) where L is the resolvent and H is the Hessian.

    Example:
        >>> A = np.array([[2.0, 0.5], [0.5, 1.0]])
        >>> L, H = dpp_resolvent_hessian(A)
        >>> np.allclose(L, L.T)  # L is symmetric
        True
        >>> np.all(np.diag(H) <= 0)  # diagonal entries nonpositive
        True
    """
    n = A.shape[0]
    I = np.eye(n)
    L = A @ np.linalg.inv(I + A)
    H = -(L ** 2)
    return L, H


def check_cond_neg_semidef(
    M: np.ndarray,
    tol: float = 1e-10
) -> Dict[str, object]:
    """Check if a matrix is conditionally negative semidefinite.

    A matrix M is CondNSD if v^T M v ≤ 0 for all v with ∑ v_i = 0.

    Algorithm:
    1. Project M onto the zero-sum subspace using projector P = I - (1/n) 11^T.
    2. Compute eigenvalues of P M P restricted to the zero-sum subspace.
    3. Check all eigenvalues are ≤ tol.

    Time complexity: O(n^3) for eigendecomposition.
    Space complexity: O(n^2).

    Args:
        M: (n, n) symmetric real matrix.
        tol: numerical tolerance for eigenvalue positivity.

    Returns:
        Dict with keys:
            'is_cond_nsd': bool, whether M is CondNSD
            'eigenvalues': eigenvalues on zero-sum subspace (n-1 values)
            'max_eigenvalue': largest eigenvalue on zero-sum subspace
            'violation_vector': if not CondNSD, a violating zero-sum vector
    """
    n = M.shape[0]
    ones = np.ones(n)

    # Orthonormal basis for zero-sum subspace: columns of Q
    # Use QR decomposition of [1; basis_complement]
    # Or simply: orthogonal complement of ones/sqrt(n)
    e = ones / np.sqrt(n)
    # Build basis for orthogonal complement
    Q = np.eye(n) - np.outer(e, e)  # projector onto zero-sum subspace
    # Restrict M to zero-sum subspace
    M_restricted = Q @ M @ Q

    eigenvalues, eigenvectors = np.linalg.eigh(M_restricted)

    # The smallest eigenvalue corresponds to the ones direction (≈0)
    # The remaining n-1 eigenvalues are the restricted spectrum
    # Sort and take the n-1 largest
    idx = np.argsort(np.abs(eigenvalues))
    zero_idx = idx[0]  # closest to zero (the ones direction)
    nonzero_idx = np.delete(idx, 0)

    restricted_evals = eigenvalues[nonzero_idx]
    max_eval = np.max(restricted_evals) if len(restricted_evals) > 0 else 0.0

    result = {
        'is_cond_nsd': bool(max_eval <= tol),
        'eigenvalues': np.sort(restricted_evals),
        'max_eigenvalue': float(max_eval),
        'violation_vector': None
    }

    if max_eval > tol:
        # Find the violating eigenvector
        viol_idx = nonzero_idx[np.argmax(eigenvalues[nonzero_idx])]
        v = eigenvectors[:, viol_idx]
        v = v - v.mean()  # project to zero-sum
        result['violation_vector'] = v

    return result


def fit_laplacian_certificate(
    M: np.ndarray,
    tol: float = 1e-10
) -> Optional[np.ndarray]:
    """Attempt to fit a Laplacian certificate for a CondNSD matrix.

    Given a matrix M, try to find nonneg symmetric weights w such that:
        M_{ij} = w_{ij}  for i ≠ j  (off-diagonal)
        M_{ii} = -∑_{j≠i} w_{ij}    (diagonal = neg row sum of off-diag)

    This succeeds if and only if:
    1. All off-diagonal entries are nonneg (for negative Laplacian form)
       OR all off-diagonal entries are nonpositive (for positive Laplacian form)
    2. Row sums are approximately zero.

    For the negative Laplacian (our convention): off-diagonal ≤ 0 in M means
    the matrix is a standard graph Laplacian, and we set w_{ij} = -M_{ij}.

    Actually, our convention is negLaplacian: off-diag = w (positive),
    diagonal = -∑ w. So for M to match, we need off-diag of M to be the weights.

    Args:
        M: (n, n) symmetric matrix to fit.
        tol: tolerance for row-sum check.

    Returns:
        w: (n, n) nonneg symmetric weight matrix if certificate exists, else None.
    """
    n = M.shape[0]

    # Check: off-diagonal entries should be the weights (nonneg for negLaplacian)
    # and diagonal should be -sum of off-diagonal
    w = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                w[i, j] = M[i, j]

    # Check nonnegativity
    if np.any(w < -tol):
        # Try the other sign convention
        w_alt = -w.copy()
        np.fill_diagonal(w_alt, 0)
        if np.any(w_alt < -tol):
            return None
        # Check row sums of -M
        for i in range(n):
            expected_diag = -np.sum(w_alt[i, :])
            if abs(-M[i, i] - expected_diag) > tol:
                return None
        return w_alt

    # Check row sums
    for i in range(n):
        expected_diag = -np.sum(w[i, :])
        if abs(M[i, i] - expected_diag) > tol:
            return None

    return w


def multilinear_coeff_hessian(
    coefficients: Dict[frozenset, float],
    n: int
) -> np.ndarray:
    """Compute the coefficient-level Hessian at x=1 for a multilinear polynomial.

    For p(x) = ∑_S μ(S) ∏_{i∈S} x_i, the second partial derivative at x=1:
        ∂²p/∂x_i∂x_j (1) = ∑_{S: i,j ∈ S} μ(S)   for i ≠ j
        ∂²p/∂x_i² (1) = 0   (multilinear, so no x_i² terms)
        ∂p/∂x_i (1) = ∑_{S: i ∈ S} μ(S)
        p(1) = ∑_S μ(S)

    The log-Hessian is then:
        H_{ij} = (∂²p/∂x_i∂x_j)(1) / p(1) - (∂p/∂x_i)(1)(∂p/∂x_j)(1) / p(1)²

    Args:
        coefficients: dict mapping frozenset S to coefficient μ(S).
        n: number of variables.

    Returns:
        (n, n) log-Hessian matrix at x=1.
    """
    p_val = sum(coefficients.values())
    if p_val <= 0:
        raise ValueError("p(1) must be positive")

    # First derivatives
    dp = np.zeros(n)
    for S, mu in coefficients.items():
        for i in S:
            dp[i] += mu

    # Second derivatives (i ≠ j only for multilinear)
    d2p = np.zeros((n, n))
    for S, mu in coefficients.items():
        S_list = list(S)
        for a in range(len(S_list)):
            for b in range(a + 1, len(S_list)):
                i, j = S_list[a], S_list[b]
                d2p[i, j] += mu
                d2p[j, i] += mu

    # Log-Hessian
    H = d2p / p_val - np.outer(dp, dp) / p_val**2
    return H


def spanning_tree_polynomial_coefficients(
    adjacency: np.ndarray
) -> Dict[frozenset, float]:
    """Compute spanning tree polynomial coefficients for a graph.

    Uses Kirchhoff's matrix tree theorem approach for small graphs.
    The basis generating polynomial is:
        B_G(x) = ∑_{T spanning tree} ∏_{e ∈ T} x_e

    For small graphs, we enumerate spanning trees by checking all
    (n-1)-subsets of edges for tree-ness.

    Args:
        adjacency: (n, n) adjacency matrix (0/1, symmetric, zero diagonal).

    Returns:
        Dict mapping edge subset (as frozenset of edge indices) to coefficient (1.0).
    """
    n = adjacency.shape[0]
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if adjacency[i, j] > 0:
                edges.append((i, j))

    num_edges = len(edges)
    if num_edges < n - 1:
        return {}

    from itertools import combinations

    coefficients = {}
    for subset in combinations(range(num_edges), n - 1):
        # Check if this subset forms a spanning tree
        edge_set = [edges[k] for k in subset]
        # Use union-find
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        is_tree = True
        for u, v in edge_set:
            pu, pv = find(u), find(v)
            if pu == pv:
                is_tree = False
                break
            parent[pu] = pv
        if is_tree:
            # Check connectivity
            roots = set(find(i) for i in range(n))
            if len(roots) == 1:
                coefficients[frozenset(subset)] = 1.0

    return coefficients


def analyze_polynomial(
    coefficients: Dict[frozenset, float],
    n: int,
    name: str = "polynomial"
) -> Dict[str, object]:
    """Full analysis pipeline for a multilinear polynomial.

    Computes log-Hessian, checks CondNSD, attempts Laplacian certificate fit.

    Args:
        coefficients: polynomial coefficients.
        n: number of variables.
        name: descriptive name for output.

    Returns:
        Analysis results dictionary.
    """
    H = multilinear_coeff_hessian(coefficients, n)
    cond_nsd = check_cond_neg_semidef(H)
    cert = fit_laplacian_certificate(H)

    return {
        'name': name,
        'hessian': H,
        'cond_nsd_result': cond_nsd,
        'has_laplacian_certificate': cert is not None,
        'laplacian_weights': cert,
        'p_at_one': sum(coefficients.values()),
        'num_terms': len(coefficients)
    }


if __name__ == "__main__":
    # Example: product of two linear forms in 3 variables
    a = np.array([[1.0, 2.0, 1.0], [2.0, 1.0, 3.0]])
    H = log_hessian_product_linear_forms(a)
    print("=== Product of Linear Forms ===")
    print(f"Coefficients:\n{a}")
    print(f"Log-Hessian at 1:\n{np.round(H, 6)}")
    result = check_cond_neg_semidef(H)
    print(f"Is CondNSD: {result['is_cond_nsd']}")
    print(f"Eigenvalues on zero-sum subspace: {np.round(result['eigenvalues'], 8)}")
    print()

    # Example: DPP with random PSD kernel
    np.random.seed(42)
    B = np.random.randn(4, 4)
    A = B @ B.T
    L, H_dpp = dpp_resolvent_hessian(A)
    print("=== DPP Resolvent Hessian ===")
    print(f"Kernel A diagonal: {np.round(np.diag(A), 4)}")
    print(f"Resolvent L diagonal: {np.round(np.diag(L), 4)}")
    print(f"Hessian H:\n{np.round(H_dpp, 6)}")
    result_dpp = check_cond_neg_semidef(H_dpp)
    print(f"Is CondNSD: {result_dpp['is_cond_nsd']}")
    print(f"Eigenvalues on zero-sum subspace: {np.round(result_dpp['eigenvalues'], 8)}")
