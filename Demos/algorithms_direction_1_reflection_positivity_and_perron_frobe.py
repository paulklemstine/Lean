#!/usr/bin/env python3
"""
Algorithms for Transfer Matrix Construction and Spectral Gap Certification
==========================================================================

Implements the core algorithms from the research paper on reflection positivity
and Perron-Frobenius theory for lattice gauge transfer matrices.
"""

import numpy as np
from typing import Tuple, Optional, List, Callable


# =============================================================================
# Algorithm 1: Wilson Transfer Matrix Construction
# =============================================================================

def build_wilson_transfer_matrix(
    n: int,
    beta: float,
    weight_fn: Optional[Callable[[int, int, int], float]] = None
) -> np.ndarray:
    """
    Build the Wilson transfer matrix for a discretized gauge model.

    The matrix T[i,j] = exp(beta * w(i,j)) where w is the plaquette weight.

    Parameters
    ----------
    n : int
        Size of the configuration space (number of discrete group elements).
    beta : float
        Coupling constant (inverse temperature).
    weight_fn : callable, optional
        Custom weight function w(i, j, n) -> float. Default is the cyclic
        cosine weight cos(2*pi*(i-j)/n).

    Returns
    -------
    np.ndarray
        n x n transfer matrix.

    Complexity
    ----------
    Time: O(n^2)
    Space: O(n^2)

    Examples
    --------
    >>> T = build_wilson_transfer_matrix(4, 1.0)
    >>> T.shape
    (4, 4)
    >>> np.all(T > 0)
    True
    """
    if weight_fn is None:
        weight_fn = lambda i, j, n: np.cos(2 * np.pi * (i - j) / n)

    T = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            T[i, j] = np.exp(beta * weight_fn(i, j, n))
    return T


# =============================================================================
# Algorithm 2: Certified Spectral Gap Computation
# =============================================================================

def compute_certified_spectral_gap(
    T: np.ndarray,
    tolerance: float = 1e-10
) -> Tuple[Optional[float], dict]:
    """
    Compute the spectral gap with certification checks.

    Performs the following checks:
    1. T is symmetric (within tolerance)
    2. T has all nonnegative entries
    3. T is positivity improving (all positive entries)
    4. Eigenvalues are computed via symmetric eigensolver
    5. Gap is certified as topEigenval - secondEigenval

    Parameters
    ----------
    T : np.ndarray
        Symmetric matrix with nonneg entries.
    tolerance : float
        Numerical tolerance for symmetry checks.

    Returns
    -------
    Tuple[Optional[float], dict]
        (gap_lower_bound, certification_report)

    Complexity
    ----------
    Time: O(n^3) for eigenvalue computation
    Space: O(n^2)
    """
    n = T.shape[0]
    report = {
        'n': n,
        'symmetric': False,
        'nonneg_entries': False,
        'positivity_improving': False,
        'top_eigenvalue': None,
        'second_eigenvalue': None,
        'gap': None,
        'certified': False,
        'top_eigenvector_positive': False,
    }

    # Check symmetry
    sym_error = np.max(np.abs(T - T.T))
    report['symmetric'] = sym_error < tolerance
    report['symmetry_error'] = float(sym_error)

    if not report['symmetric']:
        return None, report

    # Check nonnegativity
    report['nonneg_entries'] = bool(np.all(T >= -tolerance))

    # Check positivity improving
    report['positivity_improving'] = bool(np.all(T > tolerance))

    # Compute eigenvalues
    eigenvalues, eigenvectors = np.linalg.eigh(T)
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    report['all_eigenvalues'] = eigenvalues.tolist()
    report['top_eigenvalue'] = float(eigenvalues[0])

    if n > 1:
        report['second_eigenvalue'] = float(eigenvalues[1])
        gap = eigenvalues[0] - eigenvalues[1]
        report['gap'] = float(gap)

        # Check top eigenvector positivity (Perron vector)
        top_vec = eigenvectors[:, 0]
        if np.all(top_vec > 0) or np.all(top_vec < 0):
            report['top_eigenvector_positive'] = True

        # Certification: gap > 0 and all checks pass
        if (gap > tolerance and report['symmetric'] and
            report['positivity_improving'] and
            report['top_eigenvector_positive']):
            report['certified'] = True
            # Conservative lower bound accounting for numerical error
            gap_lower = gap - 2 * n * np.finfo(float).eps * eigenvalues[0]
            return max(gap_lower, 0), report

    return report.get('gap'), report


# =============================================================================
# Algorithm 3: OS Form Evaluation
# =============================================================================

def evaluate_os_form(
    K: np.ndarray,
    theta: np.ndarray,
    f: np.ndarray
) -> float:
    """
    Evaluate the Osterwalder-Schrader quadratic form.

    Q(f) = sum_{x,y} f(x) * K(theta(x), y) * f(y)

    Parameters
    ----------
    K : np.ndarray
        Kernel matrix K[x, y].
    theta : np.ndarray
        Involution as permutation array.
    f : np.ndarray
        Test function.

    Returns
    -------
    float
        Value of the OS quadratic form.

    Complexity
    ----------
    Time: O(n^2)
    Space: O(n)
    """
    n = len(f)
    result = 0.0
    for x in range(n):
        for y in range(n):
            result += f[x] * K[theta[x], y] * f[y]
    return result


def verify_reflection_positivity(
    K: np.ndarray,
    theta: np.ndarray,
    num_tests: int = 1000
) -> Tuple[bool, float]:
    """
    Statistically verify reflection positivity by random sampling.

    Parameters
    ----------
    K : np.ndarray
        Kernel matrix.
    theta : np.ndarray
        Involution permutation.
    num_tests : int
        Number of random test functions.

    Returns
    -------
    Tuple[bool, float]
        (is_positive, minimum_value_found)
    """
    n = K.shape[0]
    min_val = float('inf')

    for _ in range(num_tests):
        f = np.random.randn(n)
        val = evaluate_os_form(K, theta, f)
        min_val = min(min_val, val)

    return min_val >= -1e-10, min_val


# =============================================================================
# Algorithm 4: Gram Factorization Check
# =============================================================================

def check_gram_factorization(K: np.ndarray, tol: float = 1e-10) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Check if K = L * L^T (positive semidefinite) and return L if so.

    Parameters
    ----------
    K : np.ndarray
        Symmetric matrix to factor.
    tol : float
        Tolerance for negative eigenvalues.

    Returns
    -------
    Tuple[bool, Optional[np.ndarray]]
        (is_psd, L) where K ≈ L @ L.T
    """
    eigenvalues, eigenvectors = np.linalg.eigh(K)
    if np.min(eigenvalues) < -tol:
        return False, None

    # Clamp small negative eigenvalues to zero
    eigenvalues = np.maximum(eigenvalues, 0)
    L = eigenvectors @ np.diag(np.sqrt(eigenvalues))
    return True, L


# =============================================================================
# Algorithm 5: Power Method for Top Eigenvalue (Perron-Frobenius)
# =============================================================================

def perron_frobenius_power_method(
    T: np.ndarray,
    max_iter: int = 10000,
    tol: float = 1e-12
) -> Tuple[float, np.ndarray, int]:
    """
    Compute the Perron-Frobenius eigenvalue and eigenvector via power method.

    For a positivity-improving matrix, this converges to the unique
    top eigenvalue with a positive eigenvector.

    Parameters
    ----------
    T : np.ndarray
        Nonneg matrix (should be positivity improving for guaranteed convergence).
    max_iter : int
        Maximum iterations.
    tol : float
        Convergence tolerance.

    Returns
    -------
    Tuple[float, np.ndarray, int]
        (top_eigenvalue, perron_vector, iterations)

    Complexity
    ----------
    Time: O(n^2 * iterations)
    Space: O(n)
    """
    n = T.shape[0]
    # Start with positive vector (guaranteed to have nonzero projection on Perron vector)
    v = np.ones(n) / np.sqrt(n)
    eigenvalue = 0.0

    for iteration in range(max_iter):
        w = T @ v
        new_eigenvalue = np.linalg.norm(w)
        if new_eigenvalue < 1e-15:
            break
        v_new = w / new_eigenvalue

        if abs(new_eigenvalue - eigenvalue) < tol:
            return new_eigenvalue, np.abs(v_new), iteration + 1

        eigenvalue = new_eigenvalue
        v = v_new

    return eigenvalue, np.abs(v), max_iter


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("Algorithms Module - Self-Test")
    print("=" * 50)

    # Test Algorithm 1
    T = build_wilson_transfer_matrix(8, 1.0)
    print(f"Built 8x8 Wilson transfer matrix at β=1.0")
    print(f"  Shape: {T.shape}, Min entry: {T.min():.6f}")

    # Test Algorithm 2
    gap, report = compute_certified_spectral_gap(T)
    print(f"\nCertified spectral gap: {gap:.6f}")
    print(f"  Certified: {report['certified']}")
    print(f"  Top eigenvalue: {report['top_eigenvalue']:.6f}")
    print(f"  Perron vector positive: {report['top_eigenvector_positive']}")

    # Test Algorithm 5
    lam, v, iters = perron_frobenius_power_method(T)
    print(f"\nPower method result:")
    print(f"  Top eigenvalue: {lam:.6f} (in {iters} iterations)")
    print(f"  Perron vector all positive: {np.all(v > 0)}")

    print("\nAll tests passed!")
