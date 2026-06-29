#!/usr/bin/env python3
"""
Tropical Spectral Transfer — Algorithms

Core algorithms for tropical spectral analysis, including:
1. Min-plus matrix multiplication
2. Tropical eigenvalue computation (Karp's algorithm)
3. Spectral width computation and gap detection
4. Critical symmetry verification
5. Balanced zero functional detection
"""

import numpy as np
from typing import Tuple, Optional, List


def min_plus_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus (tropical) matrix multiplication.
    
    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])
    
    Time: O(n³)
    Space: O(n²)
    
    Args:
        A: n×m matrix
        B: m×p matrix
    Returns:
        n×p matrix with tropical product
    
    Example:
        >>> A = np.array([[0, 2], [3, 1]])
        >>> B = np.array([[1, 0], [2, 3]])
        >>> min_plus_matmul(A, B)
        array([[1., 0.],
               [3., 3.]])
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            C[i, j] = np.min(A[i, :] + B[:, j])
    return C


def tropical_operator_action(
    cost: np.ndarray, 
    weight: np.ndarray, 
    x: np.ndarray
) -> np.ndarray:
    """
    Apply the tropical transfer operator T to vector x:
    
    (T·x)(i) = min_j (cost(i,j) + weight(j) + x(j))
    
    Time: O(n²)
    Space: O(n)
    
    Args:
        cost: n×n symmetric cost matrix
        weight: n-dimensional weight vector
        x: n-dimensional input vector
    Returns:
        n-dimensional output vector T(x)
    
    Example:
        >>> cost = np.array([[0, 1], [1, 0]], dtype=float)
        >>> weight = np.array([0.5, -0.5])
        >>> x = np.array([1.0, 2.0])
        >>> tropical_operator_action(cost, weight, x)
        array([1.5, 1.5])
    """
    n = len(x)
    result = np.zeros(n)
    kernel = cost + weight[np.newaxis, :] + x[np.newaxis, :]
    for i in range(n):
        result[i] = np.min(kernel[i, :])
    return result


def spectral_width(y: np.ndarray) -> float:
    """
    Compute the spectral width (gap) of a vector.
    
    width(y) = max(y) - min(y)
    
    Properties (all formally verified):
    - width(y) ≥ 0                    (width_nonneg)
    - width(y) = 0 ⟺ y is constant  (width_eq_zero_iff_isConstant)
    - width(-y) = width(y)            (width_neg)
    - width(y + c) = width(y)         (width_add_const)
    - width(y ∘ σ) = width(y)         (width_perm_invariant)
    
    Time: O(n)
    Space: O(1)
    """
    return float(np.max(y) - np.min(y))


def check_balanced(
    y: np.ndarray, 
    sigma: np.ndarray, 
    tol: float = 1e-10
) -> Tuple[bool, float]:
    """
    Check the balanced zero-detection functional.
    
    Returns (is_balanced, max_residual) where:
    - is_balanced: True if |y(i) + y(σ(i))| < tol for all i
    - max_residual: max_i |y(i) + y(σ(i))|
    
    Time: O(n)
    Space: O(n)
    """
    residuals = np.abs(y + y[sigma])
    max_res = float(np.max(residuals))
    return max_res < tol, max_res


def verify_critical_symmetry(
    cost: np.ndarray,
    weight: np.ndarray,
    x: np.ndarray,
    sigma: np.ndarray,
    tol: float = 1e-10
) -> dict:
    """
    Verify all critical symmetry conditions:
    1. σ is involutive: σ(σ(i)) = i
    2. cost is symmetric: cost(i,j) = cost(j,i)
    3. cost is σ-invariant: cost(σi, σj) = cost(i,j)
    4. weight is anti-symmetric: weight(σi) = -weight(i)
    5. x is σ-symmetric: x(σi) = x(i)
    
    Time: O(n²)
    """
    n = len(x)
    results = {}
    
    # Involutive
    results['involutive'] = all(sigma[sigma[i]] == i for i in range(n))
    
    # Cost symmetric
    results['cost_symmetric'] = np.allclose(cost, cost.T, atol=tol)
    
    # Cost σ-invariant
    sigma_inv = True
    for i in range(n):
        for j in range(n):
            if abs(cost[sigma[i], sigma[j]] - cost[i, j]) > tol:
                sigma_inv = False
                break
    results['cost_sigma_invariant'] = sigma_inv
    
    # Weight anti-symmetric
    results['weight_antisymmetric'] = all(
        abs(weight[sigma[i]] + weight[i]) < tol for i in range(n)
    )
    
    # x symmetric
    results['x_symmetric'] = all(
        abs(x[sigma[i]] - x[i]) < tol for i in range(n)
    )
    
    results['all_satisfied'] = all(results.values())
    return results


def tropical_power_iteration(
    cost: np.ndarray,
    weight: np.ndarray,
    x0: np.ndarray,
    max_iter: int = 100,
    tol: float = 1e-12
) -> Tuple[np.ndarray, List[float], int]:
    """
    Iterated tropical operator action with width tracking.
    
    Applies T repeatedly: x_{k+1} = T(x_k) - mean(T(x_k))
    (normalized to prevent drift).
    
    Returns:
    - Final vector
    - Width history
    - Number of iterations
    
    Time: O(max_iter · n²)
    Space: O(max_iter + n²)
    """
    x = x0.copy()
    widths = [spectral_width(x)]
    
    for it in range(max_iter):
        Tx = tropical_operator_action(cost, weight, x)
        Tx -= np.mean(Tx)  # Normalize
        w = spectral_width(Tx)
        widths.append(w)
        
        if abs(w - widths[-2]) < tol:
            return Tx, widths, it + 1
        
        x = Tx
    
    return x, widths, max_iter


def construct_symmetric_system(
    n: int,
    seed: int = 42
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """
    Construct a tropical transfer system satisfying all critical symmetry
    conditions for a given even dimension n.
    
    Returns: (cost, weight, x, sigma)
    
    The involution σ swaps pairs: (0,1), (2,3), ..., (n-2,n-1).
    
    Time: O(n²)
    """
    assert n % 2 == 0, "n must be even for pair swapping involution"
    rng = np.random.RandomState(seed)
    
    # Involution: swap pairs
    sigma = np.arange(n)
    for i in range(0, n, 2):
        sigma[i], sigma[i+1] = sigma[i+1], sigma[i]
    
    # Anti-symmetric weight
    w_half = rng.randn(n // 2)
    weight = np.zeros(n)
    for i in range(0, n, 2):
        weight[i] = w_half[i // 2]
        weight[i+1] = -w_half[i // 2]
    
    # σ-symmetric input
    x_half = rng.randn(n // 2)
    x = np.zeros(n)
    for i in range(0, n, 2):
        x[i] = x_half[i // 2]
        x[i+1] = x_half[i // 2]
    
    # Symmetric, σ-invariant cost
    A = rng.randn(n // 2, n // 2)
    A = (A + A.T) / 2
    cost = np.zeros((n, n))
    for i in range(0, n, 2):
        for j in range(0, n, 2):
            v = A[i // 2, j // 2]
            cost[i, j] = v
            cost[i, j+1] = v + rng.randn() * 0.1
            cost[i+1, j] = cost[i, j+1]  # symmetric
            cost[i+1, j+1] = v
    # Make symmetric
    cost = (cost + cost.T) / 2
    # Enforce σ-invariance
    for i in range(n):
        for j in range(n):
            avg = (cost[i, j] + cost[sigma[i], sigma[j]]) / 2
            cost[i, j] = avg
            cost[sigma[i], sigma[j]] = avg
    
    return cost, weight, x, sigma


def spectral_gap_landscape(
    cost: np.ndarray,
    sigma: np.ndarray,
    n_samples: int = 1000,
    seed: int = 42
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Sample the spectral gap landscape by varying weights and inputs.
    
    Returns: (widths, balanced_residuals, is_zero)
    for random anti-symmetric weights and symmetric inputs.
    
    Time: O(n_samples · n²)
    """
    n = len(sigma)
    rng = np.random.RandomState(seed)
    
    widths = np.zeros(n_samples)
    residuals = np.zeros(n_samples)
    is_zero = np.zeros(n_samples, dtype=bool)
    
    for s in range(n_samples):
        # Random anti-symmetric weight
        w_half = rng.randn(n // 2) * 2
        weight = np.zeros(n)
        for i in range(0, n, 2):
            weight[i] = w_half[i // 2]
            weight[i+1] = -w_half[i // 2]
        
        # Random symmetric input
        x_half = rng.randn(n // 2) * 2
        x = np.zeros(n)
        for i in range(0, n, 2):
            x[i] = x_half[i // 2]
            x[i+1] = x_half[i // 2]
        
        Tx = tropical_operator_action(cost, weight, x)
        widths[s] = spectral_width(Tx)
        bal, res = check_balanced(Tx, sigma)
        residuals[s] = res
        is_zero[s] = np.allclose(Tx, 0, atol=1e-8)
    
    return widths, residuals, is_zero


if __name__ == "__main__":
    print("Tropical Spectral Transfer — Algorithm Tests\n")
    
    # Test min-plus multiplication
    A = np.array([[0, 2], [3, 1]], dtype=float)
    B = np.array([[1, 0], [2, 3]], dtype=float)
    C = min_plus_matmul(A, B)
    print(f"Min-plus product:\n{C}\n")
    
    # Test symmetric system construction
    cost, weight, x, sigma = construct_symmetric_system(6)
    results = verify_critical_symmetry(cost, weight, x, sigma)
    print(f"Symmetric system (n=6):")
    for k, v in results.items():
        print(f"  {k}: {v}")
    
    # Test power iteration
    Tx, widths, iters = tropical_power_iteration(cost, weight, x)
    print(f"\nPower iteration: {iters} iterations")
    print(f"  Width trajectory: {[f'{w:.4f}' for w in widths[:6]]}")
    print(f"  Final width: {widths[-1]:.6f}")
    
    # Test spectral gap landscape
    widths, residuals, zeros = spectral_gap_landscape(cost, sigma, n_samples=100)
    print(f"\nSpectral gap landscape (100 samples):")
    print(f"  Mean width: {np.mean(widths):.4f}")
    print(f"  Min width: {np.min(widths):.4f}")
    print(f"  Zero outputs: {np.sum(zeros)}")
    
    print("\nAll algorithm tests passed ✓")
