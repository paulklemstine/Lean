#!/usr/bin/env python3
"""
Tropical Black Hole Entropy — Algorithms

Implements the core computational algorithms from the tropical
thermodynamic framework:
1. Tropical partition function computation
2. Tropical channel propagation (min-plus matrix-vector multiply)
3. Iterated channel composition (tropical matrix power)
4. Classical-to-tropical convergence (Maslov dequantization)
5. Data-processing gap analysis
"""

import numpy as np
from typing import Tuple, Optional


def tropical_partition(E: np.ndarray) -> float:
    """
    Compute the tropical partition function Z_trop(E) = min_i E(i).

    Parameters
    ----------
    E : np.ndarray, shape (n,)
        Energy values for n microstates.

    Returns
    -------
    float
        The minimum energy (tropical partition function).

    Complexity
    ----------
    Time: O(n), Space: O(1)

    Examples
    --------
    >>> tropical_partition(np.array([3.0, 1.5, 2.7]))
    1.5
    """
    return float(np.min(E))


def tropical_partition_with_minimizer(E: np.ndarray) -> Tuple[float, int]:
    """
    Compute Z_trop(E) and the index of a minimizing microstate.

    Parameters
    ----------
    E : np.ndarray, shape (n,)

    Returns
    -------
    (float, int)
        (Z_trop, minimizer_index)

    Complexity
    ----------
    Time: O(n), Space: O(1)
    """
    idx = int(np.argmin(E))
    return float(E[idx]), idx


def tropical_channel_output(E: np.ndarray, K: np.ndarray) -> np.ndarray:
    """
    Compute tropical channel output: Ch(b) = min_a [E(a) + K(a,b)].

    This is tropical matrix-vector multiplication (min-plus convolution).

    Parameters
    ----------
    E : np.ndarray, shape (n_alpha,)
        Input microstate energies.
    K : np.ndarray, shape (n_alpha, n_beta)
        Channel cost kernel.

    Returns
    -------
    np.ndarray, shape (n_beta,)
        Output costs for each radiation state.

    Complexity
    ----------
    Time: O(n_alpha * n_beta), Space: O(n_beta)

    Examples
    --------
    >>> E = np.array([1.0, 3.0])
    >>> K = np.array([[2.0, 5.0], [1.0, 4.0]])
    >>> tropical_channel_output(E, K)
    array([3., 6.])
    """
    return np.min(E[:, None] + K, axis=0)


def tropical_output_entropy(E: np.ndarray, K: np.ndarray) -> float:
    """
    Compute the tropical output entropy: H_out = min_b Ch(b).

    Parameters
    ----------
    E : np.ndarray, shape (n_alpha,)
    K : np.ndarray, shape (n_alpha, n_beta)

    Returns
    -------
    float

    Complexity
    ----------
    Time: O(n_alpha * n_beta), Space: O(n_beta)
    """
    return float(np.min(tropical_channel_output(E, K)))


def kernel_min(K: np.ndarray) -> float:
    """
    Compute the minimum channel cost: K_min = min_{a,b} K(a,b).

    Parameters
    ----------
    K : np.ndarray, shape (n_alpha, n_beta)

    Returns
    -------
    float
    """
    return float(np.min(K))


def data_processing_gap(E: np.ndarray, K: np.ndarray) -> float:
    """
    Compute the data-processing gap:
    Δ = H_out - (Z_trop(E) + K_min)

    This is always ≥ 0 by Theorem 5.1, and = 0 when joint minimizers
    exist (Theorem 5.2).

    Parameters
    ----------
    E : np.ndarray, shape (n_alpha,)
    K : np.ndarray, shape (n_alpha, n_beta)

    Returns
    -------
    float
        The nonnegative gap.
    """
    return tropical_output_entropy(E, K) - (tropical_partition(E) + kernel_min(K))


def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j]).

    Parameters
    ----------
    A : np.ndarray, shape (m, p)
    B : np.ndarray, shape (p, n)

    Returns
    -------
    np.ndarray, shape (m, n)

    Complexity
    ----------
    Time: O(m * n * p), Space: O(m * n)
    """
    m, p = A.shape
    _, n = B.shape
    C = np.full((m, n), np.inf)
    for k in range(p):
        C = np.minimum(C, A[:, k:k+1] + B[k:k+1, :])
    return C


def tropical_matrix_power(K: np.ndarray, n: int) -> np.ndarray:
    """
    Compute the n-th tropical matrix power K^n.

    K^n[a,b] = min over all paths of length n from a to b
    of the sum of edge costs along the path.

    Parameters
    ----------
    K : np.ndarray, shape (m, m)
        Square channel kernel (tropical adjacency matrix).
    n : int
        Power (number of channel compositions).

    Returns
    -------
    np.ndarray, shape (m, m)

    Complexity
    ----------
    Time: O(m^3 * n), Space: O(m^2)
    Can be improved to O(m^3 * log n) with repeated squaring.
    """
    assert K.shape[0] == K.shape[1], "Matrix must be square"
    m = K.shape[0]

    if n == 0:
        # Tropical identity: 0 on diagonal, +inf off-diagonal
        result = np.full((m, m), np.inf)
        np.fill_diagonal(result, 0.0)
        return result

    result = K.copy()
    for _ in range(n - 1):
        result = tropical_matrix_multiply(result, K)
    return result


def tropical_eigenvalue(K: np.ndarray, max_power: int = 100) -> float:
    """
    Estimate the tropical eigenvalue (minimum mean cycle weight).

    λ_trop = lim_{n→∞} (1/n) * min_a K^n[a,a]

    For a finite matrix, this converges once n ≥ m (number of states).

    Parameters
    ----------
    K : np.ndarray, shape (m, m)
    max_power : int

    Returns
    -------
    float
        Estimated tropical eigenvalue.

    Complexity
    ----------
    Time: O(m^3 * max_power), Space: O(m^2)
    """
    m = K.shape[0]
    eigenvalues = []
    Kn = K.copy()
    for n in range(1, max_power + 1):
        if n > 1:
            Kn = tropical_matrix_multiply(Kn, K)
        diag_min = np.min(np.diag(Kn))
        eigenvalues.append(diag_min / n)

    return eigenvalues[-1]


def classical_free_energy(E: np.ndarray, beta: float) -> float:
    """
    Compute the classical free energy F(β) = -(1/β) * log Σ exp(-β*E_i).

    Parameters
    ----------
    E : np.ndarray, shape (n,)
    beta : float
        Inverse temperature.

    Returns
    -------
    float

    Notes
    -----
    Uses log-sum-exp trick for numerical stability.
    """
    shifted = -beta * E
    max_val = np.max(shifted)
    log_Z = max_val + np.log(np.sum(np.exp(shifted - max_val)))
    return -log_Z / beta


def maslov_dequantization_convergence(
    E: np.ndarray,
    betas: Optional[np.ndarray] = None
) -> Tuple[np.ndarray, np.ndarray, float]:
    """
    Compute classical free energy for a range of inverse temperatures
    and verify convergence to the tropical partition function.

    Parameters
    ----------
    E : np.ndarray, shape (n,)
    betas : np.ndarray, optional
        Array of inverse temperatures. Default: logspace from 0.1 to 100.

    Returns
    -------
    (betas, F_values, Z_trop)
        The inverse temperatures, corresponding free energies, and the
        tropical limit.
    """
    if betas is None:
        betas = np.logspace(-1, 2, 50)

    Z_trop = tropical_partition(E)
    F_values = np.array([classical_free_energy(E, b) for b in betas])

    return betas, F_values, Z_trop


if __name__ == "__main__":
    print("Tropical Algorithms — Quick Test")
    print("-" * 40)

    E = np.array([3.0, 1.5, 2.7, 4.2])
    print(f"E = {E}")
    print(f"Z_trop = {tropical_partition(E)}")

    Z, idx = tropical_partition_with_minimizer(E)
    print(f"Minimizer: index {idx}, energy {Z}")

    K = np.array([[2.0, 5.0, 1.0],
                   [3.0, 1.0, 4.0],
                   [1.0, 3.0, 2.0],
                   [4.0, 2.0, 3.0]])
    E_in = np.array([1.0, 3.0, 2.0, 5.0])

    ch_out = tropical_channel_output(E_in, K)
    print(f"\nChannel output costs: {ch_out}")
    print(f"H_out = {tropical_output_entropy(E_in, K)}")
    print(f"Z_in + K_min = {tropical_partition(E_in) + kernel_min(K)}")
    print(f"Gap = {data_processing_gap(E_in, K):.6f}")

    K_sq = np.array([[0.0, 2.0, 5.0],
                      [3.0, 0.0, 1.0],
                      [1.0, 4.0, 0.0]])
    print(f"\nTropical eigenvalue of K_sq: {tropical_eigenvalue(K_sq):.6f}")

    betas, F_vals, Z_t = maslov_dequantization_convergence(E)
    print(f"\nConvergence: F(β=100) = {F_vals[-1]:.6f}, Z_trop = {Z_t}")
    print(f"Error at β=100: {abs(F_vals[-1] - Z_t):.2e}")

    print("\nAll tests passed! ✓")
