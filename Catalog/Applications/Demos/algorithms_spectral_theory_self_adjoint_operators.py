#!/usr/bin/env python3
"""
Spectral Theory Algorithms
==========================
Implementations of key algorithms from spectral theory:
- Power iteration for dominant eigenvalue
- Rayleigh quotient iteration
- Functional calculus via diagonalization
- Lanczos algorithm sketch
"""

import numpy as np
from numpy.linalg import eigh, norm, solve
from typing import Tuple, Optional, Callable


def power_iteration(
    A: np.ndarray,
    max_iter: int = 1000,
    tol: float = 1e-12,
    x0: Optional[np.ndarray] = None
) -> Tuple[float, np.ndarray, int]:
    """
    Power iteration to find the dominant eigenvalue and eigenvector.

    Parameters
    ----------
    A : np.ndarray
        Square Hermitian matrix (n x n).
    max_iter : int
        Maximum number of iterations.
    tol : float
        Convergence tolerance.
    x0 : np.ndarray, optional
        Initial vector. Random if not provided.

    Returns
    -------
    eigenvalue : float
        The dominant eigenvalue (largest in absolute value).
    eigenvector : np.ndarray
        Corresponding unit eigenvector.
    iterations : int
        Number of iterations performed.

    Complexity
    ----------
    Time: O(n² × iterations) per iteration (matrix-vector multiply).
    Space: O(n²) for the matrix, O(n) working space.
    Convergence: Linear, rate |λ₂/λ₁| per iteration.
    """
    n = A.shape[0]
    if x0 is None:
        x = np.random.randn(n) + 1j * np.random.randn(n)
    else:
        x = x0.copy().astype(complex)
    x /= norm(x)

    eigenvalue = 0.0
    for i in range(max_iter):
        Ax = A @ x
        eigenvalue_new = np.real(x.conj() @ Ax)
        x_new = Ax / norm(Ax)

        if abs(eigenvalue_new - eigenvalue) < tol:
            return eigenvalue_new, x_new, i + 1

        eigenvalue = eigenvalue_new
        x = x_new

    return eigenvalue, x, max_iter


def rayleigh_quotient_iteration(
    A: np.ndarray,
    max_iter: int = 100,
    tol: float = 1e-14,
    x0: Optional[np.ndarray] = None,
    sigma0: Optional[float] = None
) -> Tuple[float, np.ndarray, int]:
    """
    Rayleigh quotient iteration for finding an eigenvalue with cubic convergence.

    Parameters
    ----------
    A : np.ndarray
        Square Hermitian matrix (n x n).
    max_iter : int
        Maximum number of iterations.
    tol : float
        Convergence tolerance.
    x0 : np.ndarray, optional
        Initial vector.
    sigma0 : float, optional
        Initial shift (Rayleigh quotient of x0 if not provided).

    Returns
    -------
    eigenvalue : float
        Converged eigenvalue.
    eigenvector : np.ndarray
        Corresponding unit eigenvector.
    iterations : int
        Number of iterations performed.

    Complexity
    ----------
    Time: O(n³) per iteration (solve linear system).
    Space: O(n²).
    Convergence: Cubic for Hermitian matrices!
    """
    n = A.shape[0]
    if x0 is None:
        x = np.random.randn(n) + 1j * np.random.randn(n)
    else:
        x = x0.copy().astype(complex)
    x /= norm(x)

    if sigma0 is not None:
        sigma = sigma0
    else:
        sigma = np.real(x.conj() @ A @ x)

    for i in range(max_iter):
        try:
            y = solve(A - sigma * np.eye(n), x)
        except np.linalg.LinAlgError:
            return sigma, x, i + 1

        x_new = y / norm(y)
        sigma_new = np.real(x_new.conj() @ A @ x_new)

        if abs(sigma_new - sigma) < tol:
            return sigma_new, x_new, i + 1

        sigma = sigma_new
        x = x_new

    return sigma, x, max_iter


def functional_calculus(
    A: np.ndarray,
    f: Callable[[float], complex]
) -> np.ndarray:
    """
    Apply f to a Hermitian matrix via spectral decomposition: f(A) = U f(D) U^*.

    Parameters
    ----------
    A : np.ndarray
        Hermitian matrix (n x n).
    f : callable
        Function ℝ → ℂ to apply to eigenvalues.

    Returns
    -------
    f_A : np.ndarray
        The matrix f(A).

    Complexity
    ----------
    Time: O(n³) for eigendecomposition + O(n²) for reconstruction.
    Space: O(n²).
    """
    eigenvalues, U = eigh(A)
    f_eigenvalues = np.array([f(lam) for lam in eigenvalues])
    return U @ np.diag(f_eigenvalues) @ U.conj().T


def matrix_sqrt(A: np.ndarray) -> np.ndarray:
    """
    Compute the positive semidefinite square root of a PSD matrix.

    Uses the functional calculus: sqrt(A) = U sqrt(D) U^*.

    Parameters
    ----------
    A : np.ndarray
        Positive semidefinite Hermitian matrix.

    Returns
    -------
    sqrt_A : np.ndarray
        Matrix S such that S @ S = A and S is PSD.
    """
    eigenvalues, U = eigh(A)
    eigenvalues = np.maximum(eigenvalues, 0)  # Clip numerical noise
    return U @ np.diag(np.sqrt(eigenvalues)) @ U.conj().T


def matrix_exp(A: np.ndarray) -> np.ndarray:
    """Compute matrix exponential of a Hermitian matrix via functional calculus."""
    return functional_calculus(A, np.exp)


def courant_fischer_verify(
    A: np.ndarray,
    k: int,
    num_samples: int = 10000
) -> Tuple[float, float]:
    """
    Numerically verify the Courant-Fischer min-max characterization:
    λ_k = min_{dim(S)=k} max_{x ∈ S, ‖x‖=1} x^* A x.

    Returns the k-th eigenvalue and the best min-max estimate from random sampling.
    """
    n = A.shape[0]
    eigenvalues = np.sort(np.linalg.eigvalsh(A))

    best_max_rq = float('inf')

    for _ in range(num_samples):
        # Random k-dimensional subspace
        V = np.random.randn(n, k) + 1j * np.random.randn(n, k)
        V, _ = np.linalg.qr(V)  # Orthonormalize

        # Project A onto this subspace
        A_proj = V.conj().T @ A @ V
        sub_eigenvalues = np.linalg.eigvalsh(A_proj)
        max_rq = sub_eigenvalues[-1]  # Max Rayleigh quotient in subspace

        best_max_rq = min(best_max_rq, max_rq)

    return eigenvalues[k - 1], best_max_rq


# Example usage and verification
if __name__ == '__main__':
    print("Spectral Theory Algorithms - Verification")
    print("=" * 50)

    n = 6
    B = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    A = (B + B.conj().T) / 2

    exact_eigenvalues = np.sort(np.linalg.eigvalsh(A))

    # Power iteration
    ev, vec, iters = power_iteration(A)
    print(f"\nPower iteration:")
    print(f"  Dominant eigenvalue: {ev:.10f} (exact: {exact_eigenvalues[-1]:.10f})")
    print(f"  Iterations: {iters}")

    # Rayleigh quotient iteration
    ev_rqi, vec_rqi, iters_rqi = rayleigh_quotient_iteration(A)
    print(f"\nRayleigh quotient iteration:")
    print(f"  Eigenvalue: {ev_rqi:.10f}")
    closest = exact_eigenvalues[np.argmin(np.abs(exact_eigenvalues - ev_rqi))]
    print(f"  Closest exact: {closest:.10f}")
    print(f"  Iterations: {iters_rqi} (cubic convergence!)")

    # Functional calculus
    sqrt_A = matrix_sqrt(A @ A.conj().T)  # A A^* is PSD
    print(f"\nMatrix square root:")
    print(f"  ‖sqrt(AA^*)² - AA^*‖ = {norm(sqrt_A @ sqrt_A - A @ A.conj().T):.2e}")

    exp_A = matrix_exp(A)
    print(f"\nMatrix exponential:")
    print(f"  exp(A) is Hermitian? Max dev: {np.max(np.abs(exp_A - exp_A.conj().T)):.2e}")

    # Courant-Fischer
    print(f"\nCourant-Fischer verification:")
    for k in [1, 2, 3]:
        exact_k, estimate_k = courant_fischer_verify(A, k, num_samples=5000)
        print(f"  λ_{k}: exact={exact_k:.4f}, min-max estimate={estimate_k:.4f}")
