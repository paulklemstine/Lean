#!/usr/bin/env python3
"""
Algorithms for Lorentzian polynomial analysis and M-convex exchange testing.

Implements:
1. Lorentzian polynomial recognition (quadratic and general degree)
2. M-convex exchange verification
3. Spectral decomposition H = vvᵀ - B
4. Newton support computation
"""

import numpy as np
from typing import Dict, Tuple, Set, List, Optional
from itertools import product


def degree_d_monomials(n: int, d: int) -> List[Tuple[int, ...]]:
    """Generate all monomials of total degree d in n variables.

    Args:
        n: Number of variables
        d: Total degree

    Returns:
        List of tuples representing exponent vectors

    Example:
        >>> degree_d_monomials(3, 2)
        [(2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)]
    """
    if n == 1:
        return [(d,)]
    result = []
    for i in range(d + 1):
        for rest in degree_d_monomials(n - 1, d - i):
            result.append((i,) + rest)
    return result


def build_hessian_matrix(
    coeffs: Dict[Tuple[int, ...], float], n: int
) -> np.ndarray:
    """Build the Hessian matrix of a degree-2 homogeneous polynomial.

    For f = Σ c_m x^m with |m| = 2:
      H(i,j) = c_{e_i + e_j} for i ≠ j
      H(i,i) = 2 · c_{2e_i}

    Args:
        coeffs: Dictionary mapping exponent tuples to coefficients
        n: Number of variables

    Returns:
        n×n numpy array representing the Hessian matrix

    Complexity: O(n²)
    """
    H = np.zeros((n, n))
    for i in range(n):
        m_diag = tuple(2 if k == i else 0 for k in range(n))
        H[i, i] = 2 * coeffs.get(m_diag, 0.0)
        for j in range(i + 1, n):
            m_off = tuple(1 if k in (i, j) else 0 for k in range(n))
            H[i, j] = coeffs.get(m_off, 0.0)
            H[j, i] = H[i, j]
    return H


def spectral_decomposition(
    H: np.ndarray,
) -> Tuple[np.ndarray, np.ndarray, int]:
    """Decompose H = vvᵀ - B where v ≥ 0 and B is PSD.

    Uses eigendecomposition: H = Σ λᵢ eᵢeᵢᵀ.
    Set v = √λ₁ · e₁ (Perron eigenvector) and B = Σᵢ≥₂ (-λᵢ) eᵢeᵢᵀ.

    Args:
        H: Symmetric matrix (n×n numpy array)

    Returns:
        (v, B, num_positive_eigenvalues)
        v: Perron vector (nonneg)
        B: PSD matrix
        num_pos: Number of positive eigenvalues

    Complexity: O(n³)
    """
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    n = H.shape[0]

    num_pos = int(np.sum(eigenvalues > 1e-10))

    if num_pos == 0:
        return np.zeros(n), -H, 0

    # Find the largest positive eigenvalue (Perron)
    idx = np.argmax(eigenvalues)
    lam = eigenvalues[idx]
    e = eigenvectors[:, idx]

    # Ensure nonneg (Perron-Frobenius for nonneg matrices)
    if np.sum(e) < 0:
        e = -e
    v = np.sqrt(max(lam, 0)) * e

    # B = vvᵀ - H
    B = np.outer(v, v) - H

    return v, B, num_pos


def is_lorentzian_quadratic(
    coeffs: Dict[Tuple[int, ...], float], n: int
) -> bool:
    """Test if a degree-2 homogeneous polynomial is Lorentzian.

    Checks:
    1. All coefficients ≥ 0
    2. Hessian has at most one positive eigenvalue

    Args:
        coeffs: Coefficient dictionary
        n: Number of variables

    Returns:
        True if the polynomial is Lorentzian

    Complexity: O(n³) for eigenvalue computation
    """
    if any(v < -1e-10 for v in coeffs.values()):
        return False
    H = build_hessian_matrix(coeffs, n)
    _, _, num_pos = spectral_decomposition(H)
    return num_pos <= 1


def partial_derivative(
    coeffs: Dict[Tuple[int, ...], float], n: int, var: int
) -> Dict[Tuple[int, ...], float]:
    """Compute the partial derivative of a polynomial w.r.t. variable var.

    d/dx_var (c · x^m) = c · m[var] · x^{m - e_var}

    Args:
        coeffs: Coefficient dictionary
        n: Number of variables
        var: Variable index (0-based)

    Returns:
        Coefficient dictionary of the derivative

    Complexity: O(|coeffs|)
    """
    result: Dict[Tuple[int, ...], float] = {}
    for m, c in coeffs.items():
        if m[var] > 0:
            new_m = list(m)
            factor = new_m[var]
            new_m[var] -= 1
            key = tuple(new_m)
            result[key] = result.get(key, 0.0) + c * factor
    return result


def is_lorentzian_general(
    coeffs: Dict[Tuple[int, ...], float], n: int, d: int,
    num_samples: int = 20
) -> bool:
    """Test if a degree-d homogeneous polynomial is Lorentzian.

    For d >= 3, checks that the Hessian matrix of f evaluated at
    random positive points has at most one positive eigenvalue.

    Args:
        coeffs: Coefficient dictionary
        n: Number of variables
        d: Degree
        num_samples: Number of random positive points to test

    Returns:
        True if the polynomial passes the Lorentzian test

    Complexity: O(num_samples * n^2 * |coeffs| + n^3)
    """
    if any(v < -1e-10 for v in coeffs.values()):
        return False
    if d < 2:
        return True
    if d == 2:
        return is_lorentzian_quadratic(coeffs, n)

    rng = np.random.RandomState(42)
    for _ in range(num_samples):
        x = rng.exponential(1.0, n) + 0.1
        H = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                deriv_ij = partial_derivative(
                    partial_derivative(coeffs, n, i), n, j
                )
                val = 0.0
                for m, c in deriv_ij.items():
                    term = c
                    for k in range(n):
                        term *= x[k] ** m[k]
                    val += term
                H[i, j] = val
        eigenvalues = np.linalg.eigvalsh(H)
        if np.sum(eigenvalues > 1e-10) > 1:
            return False
    return True


def newton_support(
    coeffs: Dict[Tuple[int, ...], float], tol: float = 1e-10
) -> Set[Tuple[int, ...]]:
    """Compute the Newton support of a polynomial.

    Args:
        coeffs: Coefficient dictionary
        tol: Tolerance for nonzero detection

    Returns:
        Set of exponent vectors with nonzero coefficients

    Complexity: O(|coeffs|)
    """
    return {m for m, c in coeffs.items() if abs(c) > tol}


def check_mconvex_exchange(
    support: Set[Tuple[int, ...]]
) -> Tuple[bool, Optional[str]]:
    """Verify the M-convex exchange property.

    For all α, β ∈ S and all i with α[i] > β[i], there must exist j
    with α[j] < β[j] such that α - eᵢ + eⱼ ∈ S.

    Args:
        support: Set of exponent vectors

    Returns:
        (is_mconvex, failure_message)

    Complexity: O(|S|² · n²)
    """
    if not support:
        return True, None

    n = len(next(iter(support)))

    for alpha in support:
        for beta in support:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in support:
                                found = True
                                break
                    if not found:
                        return (
                            False,
                            f"Exchange failed: α={alpha}, β={beta}, i={i}",
                        )
    return True, None


def find_exchange_witness(
    alpha: Tuple[int, ...],
    beta: Tuple[int, ...],
    i: int,
    support: Set[Tuple[int, ...]],
) -> Optional[int]:
    """Find the exchange index j for a specific α, β, i.

    Args:
        alpha, beta: Points in the support
        i: Index with alpha[i] > beta[i]
        support: The M-convex set

    Returns:
        Index j such that α - eᵢ + eⱼ ∈ support, or None
    """
    n = len(alpha)
    for j in range(n):
        if alpha[j] < beta[j]:
            exchanged = list(alpha)
            exchanged[i] -= 1
            exchanged[j] += 1
            if tuple(exchanged) in support:
                return j
    return None


if __name__ == "__main__":
    # Example usage
    print("Algorithms for Lorentzian polynomial analysis")
    print("=" * 50)

    # Test with (x+y+z)^2
    coeffs = {
        (2, 0, 0): 1.0, (0, 2, 0): 1.0, (0, 0, 2): 1.0,
        (1, 1, 0): 2.0, (1, 0, 1): 2.0, (0, 1, 1): 2.0,
    }
    print(f"Is Lorentzian: {is_lorentzian_quadratic(coeffs, 3)}")
    supp = newton_support(coeffs)
    print(f"Support: {sorted(supp)}")
    is_mc, _ = check_mconvex_exchange(supp)
    print(f"M-convex: {is_mc}")

    H = build_hessian_matrix(coeffs, 3)
    v, B, num_pos = spectral_decomposition(H)
    print(f"Perron vector: {v}")
    print(f"B matrix:\n{B}")
    print(f"Positive eigenvalues: {num_pos}")
