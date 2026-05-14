"""
Tropical Attention: Algorithms

Implementations of core algorithms from the tropical attention theory,
including tropical matrix multiplication, certified robustness computation,
and spectral growth analysis.
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_matrix_multiply(X: np.ndarray, Y: np.ndarray) -> np.ndarray:
    """
    Max-plus tropical matrix product.

    (X ⊙ Y)_{ij} = max_k (X_{ik} + Y_{kj})

    Time complexity: O(m * n * p) for m×n and n×p matrices.
    Space complexity: O(m * p) for the result.

    Args:
        X: Matrix of shape (m, n)
        Y: Matrix of shape (n, p)

    Returns:
        Tropical product of shape (m, p)

    Example:
        >>> X = np.array([[1.0, 2.0], [3.0, 0.0]])
        >>> Y = np.array([[0.0, 1.0], [2.0, 0.0]])
        >>> tropical_matrix_multiply(X, Y)
        array([[4., 2.],
               [3., 4.]])
    """
    m, n = X.shape
    _, p = Y.shape
    # Vectorized: X[:, :, None] + Y[None, :, :] gives (m, n, p), max over axis 1
    return np.max(X[:, :, np.newaxis] + Y[np.newaxis, :, :], axis=1)


def lse_matrix_multiply(tau: float, X: np.ndarray, Y: np.ndarray) -> np.ndarray:
    """
    Log-sum-exp (soft tropical) matrix product at temperature τ.

    (LSE_τ(X, Y))_{ij} = τ * log(Σ_k exp((X_{ik} + Y_{kj}) / τ))

    Uses numerically stable log-sum-exp computation.

    Time complexity: O(m * n * p)
    Space complexity: O(m * p)

    Args:
        tau: Temperature parameter (> 0)
        X: Matrix of shape (m, n)
        Y: Matrix of shape (n, p)

    Returns:
        Soft tropical product of shape (m, p)

    Example:
        >>> X = np.array([[1.0, 2.0], [3.0, 0.0]])
        >>> Y = np.array([[0.0, 1.0], [2.0, 0.0]])
        >>> lse_matrix_multiply(0.01, X, Y)  # Close to tropical product
        array([[4.00..., 2.00...],
               [3.00..., 4.00...]])
    """
    sums = X[:, :, np.newaxis] + Y[np.newaxis, :, :]  # (m, n, p)
    max_vals = np.max(sums / tau, axis=1, keepdims=True)  # (m, 1, p)
    # Stable log-sum-exp
    shifted = sums / tau - max_vals
    result = tau * (max_vals.squeeze(1) + np.log(np.sum(np.exp(shifted), axis=1)))
    return result


def softmax_attention(
    Q: np.ndarray, K: np.ndarray, V: np.ndarray, tau: float = 1.0
) -> np.ndarray:
    """
    Softmax attention output at temperature τ.

    A_τ(Q, K, V) = softmax(Q K^T / τ) V

    Args:
        Q: Query matrix (n, d)
        K: Key matrix (n, d)
        V: Value matrix (n, d_v)
        tau: Temperature

    Returns:
        Attention output (n, d_v)
    """
    scores = Q @ K.T  # (n, n)
    # Numerically stable softmax
    shifted = scores / tau - np.max(scores / tau, axis=1, keepdims=True)
    weights = np.exp(shifted)
    weights = weights / weights.sum(axis=1, keepdims=True)
    return weights @ V


def tropical_attention(
    Q: np.ndarray, K: np.ndarray, V: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Tropical (zero-temperature) attention.

    Selects the value vector corresponding to the argmax of each row's scores.

    Args:
        Q: Query matrix (n, d)
        K: Key matrix (n, d)
        V: Value matrix (n, d_v)

    Returns:
        Tuple of (output, argmax_indices)
    """
    scores = Q @ K.T
    argmax_indices = np.argmax(scores, axis=1)
    output = V[argmax_indices]
    return output, argmax_indices


def compute_dominance_gap(scores: np.ndarray, j_star: int) -> float:
    """
    Compute the dominance gap δ for column j_star.

    δ = min_i (S_{i,j*} - max_{j≠j*} S_{ij})

    If δ > 0, column j_star is a tropical attention sink.

    Args:
        scores: Score matrix (n, n)
        j_star: Index of the candidate sink column

    Returns:
        Dominance gap (positive means j_star is dominant)
    """
    n = scores.shape[0]
    gaps = []
    for i in range(n):
        s_star = scores[i, j_star]
        max_other = max(scores[i, j] for j in range(n) if j != j_star)
        gaps.append(s_star - max_other)
    return min(gaps)


def certified_perturbation_radius(scores: np.ndarray, j_star: int) -> float:
    """
    Compute the certified perturbation radius for a dominant column.

    The tropical argmax is guaranteed stable under L∞ perturbations of
    magnitude < δ/4, where δ is the dominance gap.

    Args:
        scores: Score matrix (n, n)
        j_star: Index of the dominant column

    Returns:
        Certified radius (0 if column is not dominant)
    """
    gap = compute_dominance_gap(scores, j_star)
    if gap <= 0:
        return 0.0
    return gap / 4.0


def tropical_linear_iterate(
    A: np.ndarray, x: np.ndarray, t: int
) -> np.ndarray:
    """
    Compute the t-fold iterate of the tropical linear map T_A.

    T_A(x)_i = max_j (A_{ij} + x_j)

    Args:
        A: Matrix (n, n)
        x: Vector (n,)
        t: Number of iterations

    Returns:
        T_A^[t](x)
    """
    current = x.copy()
    for _ in range(t):
        current = np.array([np.max(A[i, :] + current) for i in range(A.shape[0])])
    return current


def tropical_spectral_bound(A: np.ndarray) -> float:
    """
    Compute the tropical spectral radius upper bound.

    ρ(A) ≤ max_{i,j} A_{ij}

    This bounds the growth rate of iterated tropical linear maps:
    sup(T_A^[t] x) ≤ sup(x) + t * ρ(A)

    Args:
        A: Matrix (n, n)

    Returns:
        Upper bound on tropical spectral radius
    """
    return np.max(A)


def multihead_tropical_attention(
    queries: List[np.ndarray],
    keys: List[np.ndarray],
    values: List[np.ndarray],
) -> List[Tuple[np.ndarray, np.ndarray]]:
    """
    Multi-head tropical attention.

    Computes tropical attention independently per head (product semiring semantics).

    Args:
        queries: List of query matrices, one per head
        keys: List of key matrices, one per head
        values: List of value matrices, one per head

    Returns:
        List of (output, argmax_indices) per head
    """
    return [tropical_attention(Q, K, V) for Q, K, V in zip(queries, keys, values)]


def lse_tropical_error_analysis(
    X: np.ndarray, Y: np.ndarray,
    tau_values: Optional[List[float]] = None
) -> dict:
    """
    Comprehensive error analysis of LSE vs tropical matrix product.

    For each temperature τ, computes the actual max error and theoretical bound.

    Args:
        X: Matrix (m, n)
        Y: Matrix (n, p)
        tau_values: List of temperatures to test

    Returns:
        Dictionary with analysis results
    """
    if tau_values is None:
        tau_values = [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.05, 0.01]

    n = X.shape[1]
    T = tropical_matrix_multiply(X, Y)
    theoretical_coeff = np.log(n)

    results = {
        'n': n,
        'log_n': theoretical_coeff,
        'tau_values': tau_values,
        'actual_errors': [],
        'theoretical_bounds': [],
        'ratios': [],
    }

    for tau in tau_values:
        L = lse_matrix_multiply(tau, X, Y)
        actual_error = np.max(np.abs(L - T))
        bound = tau * theoretical_coeff
        results['actual_errors'].append(actual_error)
        results['theoretical_bounds'].append(bound)
        results['ratios'].append(actual_error / bound if bound > 0 else 0)

    return results


if __name__ == "__main__":
    print("Testing tropical matrix multiply...")
    X = np.array([[1.0, 2.0], [3.0, 0.0]])
    Y = np.array([[0.0, 1.0], [2.0, 0.0]])
    T = tropical_matrix_multiply(X, Y)
    print(f"X ⊙ Y =\n{T}")
    assert np.allclose(T, np.array([[4., 2.], [3., 4.]])), "Tropical multiply failed"

    print("\nTesting LSE approximation...")
    L = lse_matrix_multiply(0.01, X, Y)
    print(f"LSE_{'{0.01}'}(X, Y) =\n{L}")
    assert np.allclose(L, T, atol=0.02), "LSE should approximate tropical at low τ"

    print("\nTesting dominance gap...")
    S = np.array([[5.0, 1.0, 2.0],
                  [4.0, 0.0, 1.0],
                  [6.0, 2.0, 3.0]])
    gap = compute_dominance_gap(S, 0)
    print(f"Dominance gap for column 0: {gap}")
    assert gap > 0, "Column 0 should be dominant"

    print("\nTesting certified radius...")
    radius = certified_perturbation_radius(S, 0)
    print(f"Certified radius: {radius}")
    assert radius > 0, "Should have positive certified radius"

    print("\nAll tests passed!")
