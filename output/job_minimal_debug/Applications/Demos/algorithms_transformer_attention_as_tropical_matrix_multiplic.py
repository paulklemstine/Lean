#!/usr/bin/env python3
"""
Tropical Attention Theory: Core Algorithms

Implements the key algorithms from the tropical attention framework:
1. Max-plus tropical matrix multiplication
2. Temperature-scaled log-sum-exp multiplication
3. Tropical attention operator
4. Tropical linear iterate
5. Tropical spectral radius estimation (maximum cycle mean)
6. Maslov dequantization (binary and n-ary)
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_max_plus_multiply(
    A: np.ndarray, B: np.ndarray
) -> np.ndarray:
    """
    Max-plus tropical matrix multiplication.
    
    C[i,k] = max_j (A[i,j] + B[j,k])
    
    This is the fundamental operation in the max-plus (tropical) semiring.
    
    Time complexity: O(m * n * p) where A is m×n and B is n×p
    Space complexity: O(m * p)
    
    Args:
        A: Matrix of shape (m, n)
        B: Matrix of shape (n, p)
    
    Returns:
        Matrix of shape (m, p) — the max-plus product
    
    Example:
        >>> A = np.array([[1, 3], [4, 0]])
        >>> B = np.array([[2, 1], [0, 3]])
        >>> tropical_max_plus_multiply(A, B)
        array([[3., 6.],
               [6., 5.]])
    """
    m, n = A.shape
    _, p = B.shape
    C = np.full((m, p), -np.inf)
    for i in range(m):
        for k in range(p):
            for j in range(n):
                C[i, k] = max(C[i, k], A[i, j] + B[j, k])
    return C


def lse_multiply(
    A: np.ndarray, B: np.ndarray, tau: float
) -> np.ndarray:
    """
    Log-sum-exp matrix multiplication at temperature τ.
    
    C[i,k] = τ * log(Σ_j exp((A[i,j] + B[j,k]) / τ))
    
    This is the finite-temperature deformation of tropical multiplication.
    As τ → 0⁺, this converges to tropical_max_plus_multiply(A, B).
    
    Uses numerically stable log-sum-exp computation.
    
    Time complexity: O(m * n * p)
    Space complexity: O(m * p)
    
    Args:
        A: Matrix of shape (m, n)
        B: Matrix of shape (n, p) 
        tau: Temperature parameter (> 0)
    
    Returns:
        Matrix of shape (m, p)
    """
    m, n = A.shape
    _, p = B.shape
    C = np.zeros((m, p))
    for i in range(m):
        for k in range(p):
            vals = A[i, :] + B[:, k]
            # Numerically stable LSE
            max_val = np.max(vals)
            C[i, k] = max_val + tau * np.log(np.sum(np.exp((vals - max_val) / tau)))
    return C


def tropical_attention_operator(
    A: np.ndarray, x: np.ndarray
) -> np.ndarray:
    """
    Tropical attention operator with row normalization.
    
    T_A(x)_i = max_j(A[i,j] + x[j]) - max_j(A[i,j])
    
    Properties (proved in Lean):
    - T_A(0) = 0 (zero is always a fixed point)
    - T_A(x + c) = T_A(x) + c (additive homogeneity)
    - T_A is monotone (x ≤ y ⟹ T_A(x) ≤ T_A(y))
    
    Time complexity: O(n²)
    Space complexity: O(n)
    
    Args:
        A: Square matrix of shape (n, n)
        x: Vector of shape (n,)
    
    Returns:
        Vector of shape (n,)
    """
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.max(A[i, :] + x) - np.max(A[i, :])
    return result


def tropical_linear_map(
    A: np.ndarray, x: np.ndarray
) -> np.ndarray:
    """
    Tropical linear map (without normalization).
    
    (T_A x)_i = max_j(A[i,j] + x[j])
    
    Time complexity: O(n²)
    Space complexity: O(n)
    """
    n = A.shape[0]
    return np.array([np.max(A[i, :] + x) for i in range(n)])


def tropical_linear_iterate(
    A: np.ndarray, x: np.ndarray, t: int
) -> np.ndarray:
    """
    Iterate the tropical linear map t times.
    
    Computes T_A^[t](x) = T_A(T_A(...T_A(x)...)) (t applications).
    
    Growth bound (proved in Lean):
        sup(T_A^[t] x) ≤ sup(x) + t * maxEntry(A)
    
    Time complexity: O(t * n²)
    Space complexity: O(n)
    """
    result = x.copy()
    for _ in range(t):
        result = tropical_linear_map(A, result)
    return result


def maximum_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the maximum cycle mean (tropical spectral radius) of a square matrix.
    
    ρ_t(A) = max over all cycles γ of (weight(γ) / length(γ))
    
    Uses Karp's algorithm: O(n³) time.
    
    The maximum cycle mean controls the asymptotic growth rate:
        T_A^[t](x) ≈ t * ρ_t(A) + O(1) as t → ∞ (under irreducibility).
    
    Args:
        A: Square matrix of shape (n, n). Use -inf for absent edges.
    
    Returns:
        Maximum cycle mean (tropical spectral radius)
    """
    n = A.shape[0]
    # Karp's algorithm
    # D[k][i] = max weight of a path of length k ending at i
    D = np.full((n + 1, n), -np.inf)
    D[0, :] = 0.0
    
    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                if D[k-1][j] > -np.inf and A[j][i] > -np.inf:
                    D[k][i] = max(D[k][i], D[k-1][j] + A[j][i])
    
    # ρ = max_i min_k (D[n][i] - D[k][i]) / (n - k)
    rho = -np.inf
    for i in range(n):
        if D[n][i] == -np.inf:
            continue
        min_val = np.inf
        for k in range(n):
            if D[k][i] > -np.inf:
                val = (D[n][i] - D[k][i]) / (n - k)
                min_val = min(min_val, val)
        rho = max(rho, min_val)
    
    return rho


def maslov_dequantize_binary(a: float, b: float, tau: float) -> float:
    """
    Maslov dequantization of binary max: a ⊕_τ b = τ * log(exp(a/τ) + exp(b/τ)).
    
    As τ → 0⁺, this converges to max(a, b).
    
    This is the fundamental deformation connecting classical and tropical algebra.
    """
    m = max(a, b)
    return m + tau * np.log(np.exp((a - m) / tau) + np.exp((b - m) / tau))


def maslov_dequantize_nary(vals: np.ndarray, tau: float) -> float:
    """
    n-ary Maslov dequantization: τ * log(Σ exp(aᵢ/τ)).
    
    Converges to max(vals) as τ → 0⁺.
    """
    m = np.max(vals)
    return m + tau * np.log(np.sum(np.exp((vals - m) / tau)))


def detect_sink_token(
    A: np.ndarray, threshold: float = 0.0
) -> Optional[int]:
    """
    Detect a sink token (dominant column) in a score matrix.
    
    A column s is dominant with gap δ if A[i,s] ≥ A[i,j] + δ for all i, j≠s.
    
    Returns the index of the dominant column, or None if no dominant column exists.
    
    Args:
        A: Square matrix of shape (n, n)
        threshold: Minimum gap δ required
    
    Returns:
        Index of dominant column, or None
    """
    n = A.shape[0]
    for s in range(n):
        is_dominant = True
        for i in range(n):
            for j in range(n):
                if j != s and A[i, s] < A[i, j] + threshold:
                    is_dominant = False
                    break
            if not is_dominant:
                break
        if is_dominant:
            return s
    return None


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Tropical Attention Algorithms")
    print("=" * 50)
    
    # Example: tropical matrix multiplication
    A = np.array([[1, 3, 2], [4, 0, 1], [2, 2, 5]])
    B = np.array([[3, 1, 0], [0, 4, 2], [1, 0, 3]])
    
    C_trop = tropical_max_plus_multiply(A, B)
    C_lse = lse_multiply(A, B, tau=0.01)
    
    print("\nA =", A.tolist())
    print("B =", B.tolist())
    print("A ⊗_max B =", C_trop.tolist())
    print("LSE(A,B,τ=0.01) =", np.round(C_lse, 4).tolist())
    print("Max error:", np.max(np.abs(C_trop - C_lse)))
    
    # Example: maximum cycle mean
    A_cyc = np.array([[0, 3, -np.inf], [1, 0, 2], [-np.inf, 4, 0]])
    rho = maximum_cycle_mean(A_cyc)
    print(f"\nMaximum cycle mean of A_cyc: {rho:.4f}")
    
    # Example: sink detection
    A_sink = np.array([[2, 5, 1], [1, 6, 0], [3, 7, 2]])
    sink = detect_sink_token(A_sink)
    print(f"\nSink token in A_sink: column {sink}")
    
    # Example: iterate growth
    x0 = np.array([1.0, 0.0, -1.0])
    A_it = np.array([[1, 2, 0], [3, -1, 1], [0, 2, 4]])
    for t in range(6):
        xt = tropical_linear_iterate(A_it, x0, t)
        print(f"  T^{t}(x) sup = {np.max(xt):.2f}, bound = {np.max(x0) + t * np.max(A_it):.2f}")
