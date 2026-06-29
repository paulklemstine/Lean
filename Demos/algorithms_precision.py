#!/usr/bin/env python3
"""
Algorithms for Finite-Temperature Tropical Mathematics

Implements the core algorithms from the research paper:
1. Numerically stable log-sum-exp computation
2. Tropical and soft-tropical matrix multiplication
3. Finite-temperature Bellman iteration
4. Temperature annealing for tropical approximation
"""

import numpy as np
from typing import Tuple, Optional, List


def logsumexp_stable(beta: float, values: np.ndarray) -> float:
    """
    Numerically stable log-sum-exp computation.
    
    Computes (1/β) log(Σ exp(β·z_i)) using the shift-by-max trick.
    
    Args:
        beta: Inverse temperature parameter (β > 0)
        values: Array of real values
        
    Returns:
        The log-sum-exp value
        
    Complexity: O(n) time, O(1) extra space
    
    Example:
        >>> logsumexp_stable(1.0, np.array([1.0, 2.0, 3.0]))
        3.4076059644443806
    """
    if len(values) == 0:
        return -np.inf
    m = np.max(values)
    shifted_sum = np.sum(np.exp(beta * (values - m)))
    return m + np.log(shifted_sum) / beta


def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication: C_ij = max_k (A_ik + B_kj).
    
    Args:
        A: Matrix of shape (m, p)
        B: Matrix of shape (p, n)
        
    Returns:
        Tropical product of shape (m, n)
        
    Complexity: O(m·n·p) time
    
    Example:
        >>> A = np.array([[1, 2], [3, 0]])
        >>> B = np.array([[0, 1], [2, 0]])
        >>> tropical_matmul(A, B)
        array([[4., 2.],
               [3., 4.]])
    """
    m, p = A.shape
    _, n = B.shape
    C = np.zeros((m, n))
    for i in range(m):
        for j in range(n):
            C[i, j] = np.max(A[i, :] + B[:, j])
    return C


def soft_tropical_matmul(A: np.ndarray, B: np.ndarray, beta: float) -> np.ndarray:
    """
    Soft tropical matrix multiplication using log-sum-exp.
    
    C_ij = (1/β) log Σ_k exp(β(A_ik + B_kj))
    
    Args:
        A: Matrix of shape (m, p)
        B: Matrix of shape (p, n)
        beta: Inverse temperature (β > 0)
        
    Returns:
        Soft tropical product of shape (m, n)
        
    Complexity: O(m·n·p) time
    """
    m, p = A.shape
    _, n = B.shape
    C = np.zeros((m, n))
    for i in range(m):
        for j in range(n):
            vals = A[i, :] + B[:, j]
            C[i, j] = logsumexp_stable(beta, vals)
    return C


def tropical_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical matrix-vector product: y_i = max_j (A_ij + x_j).
    
    Args:
        A: Matrix of shape (n, n)
        x: Vector of shape (n,)
        
    Returns:
        Tropical product vector of shape (n,)
    """
    n = A.shape[0]
    y = np.zeros(n)
    for i in range(n):
        y[i] = np.max(A[i, :] + x)
    return y


def soft_tropical_matvec(A: np.ndarray, x: np.ndarray, beta: float) -> np.ndarray:
    """
    Soft tropical matrix-vector product.
    
    y_i = (1/β) log Σ_j exp(β(A_ij + x_j))
    
    Args:
        A: Matrix of shape (n, n)
        x: Vector of shape (n,)
        beta: Inverse temperature (β > 0)
        
    Returns:
        Soft product vector of shape (n,)
    """
    n = A.shape[0]
    y = np.zeros(n)
    for i in range(n):
        y[i] = logsumexp_stable(beta, A[i, :] + x)
    return y


def bellman_iteration(
    A: np.ndarray, 
    x0: np.ndarray, 
    beta: float, 
    max_iter: int = 1000, 
    tol: float = 1e-10
) -> Tuple[np.ndarray, float, int]:
    """
    Entropy-regularized Bellman iteration.
    
    Iterates x_{k+1} = T_{A,β}(x_k) - λ_k, where λ_k normalizes the vector
    (subtracting the max to prevent divergence).
    
    Args:
        A: Transition matrix of shape (n, n)
        x0: Initial vector of shape (n,)
        beta: Inverse temperature (β > 0)
        max_iter: Maximum iterations
        tol: Convergence tolerance
        
    Returns:
        Tuple of (eigenvector, eigenvalue, iterations)
        
    Complexity: O(max_iter · n²) time
    
    Example:
        >>> A = np.array([[0, 1], [2, 0]])
        >>> v, lam, iters = bellman_iteration(A, np.zeros(2), beta=10.0)
        >>> print(f"eigenvalue ≈ {lam:.4f}, converged in {iters} iterations")
    """
    x = x0.copy()
    eigenvalue = 0.0
    
    for k in range(max_iter):
        y = soft_tropical_matvec(A, x, beta)
        lam = np.max(y)
        y_normalized = y - lam
        
        if np.max(np.abs(y_normalized - x)) < tol:
            eigenvalue = lam
            return y_normalized, eigenvalue, k + 1
        
        x = y_normalized
        eigenvalue = lam
    
    return x, eigenvalue, max_iter


def tropical_bellman_iteration(
    A: np.ndarray, 
    x0: np.ndarray, 
    max_iter: int = 1000, 
    tol: float = 1e-10
) -> Tuple[np.ndarray, float, int]:
    """
    Standard tropical Bellman iteration (zero temperature).
    
    Iterates x_{k+1} = T_A(x_k) - max(T_A(x_k)).
    
    Args:
        A: Transition matrix of shape (n, n)
        x0: Initial vector of shape (n,)
        max_iter: Maximum iterations
        tol: Convergence tolerance
        
    Returns:
        Tuple of (eigenvector, eigenvalue, iterations)
    """
    x = x0.copy()
    eigenvalue = 0.0
    
    for k in range(max_iter):
        y = tropical_matvec(A, x)
        lam = np.max(y)
        y_normalized = y - lam
        
        if np.max(np.abs(y_normalized - x)) < tol:
            eigenvalue = lam
            return y_normalized, eigenvalue, k + 1
        
        x = y_normalized
        eigenvalue = lam
    
    return x, eigenvalue, max_iter


def temperature_annealing(
    A: np.ndarray,
    x0: np.ndarray,
    beta_schedule: List[float],
    inner_iter: int = 100
) -> List[Tuple[float, np.ndarray, float]]:
    """
    Temperature annealing: gradually increase β to approach tropical solution.
    
    At each temperature, runs Bellman iteration to convergence, then uses
    the result as initialization for the next (colder) temperature.
    
    Args:
        A: Transition matrix
        x0: Initial vector
        beta_schedule: Increasing sequence of β values
        inner_iter: Max iterations per temperature
        
    Returns:
        List of (beta, eigenvector, eigenvalue) at each temperature
        
    Example:
        >>> A = np.array([[0, 3, 1], [2, 0, 4], [1, 2, 0]])
        >>> schedule = [0.1, 0.5, 1.0, 5.0, 10.0, 50.0, 100.0]
        >>> results = temperature_annealing(A, np.zeros(3), schedule)
    """
    results = []
    x = x0.copy()
    
    for beta in beta_schedule:
        x, lam, _ = bellman_iteration(A, x, beta, max_iter=inner_iter)
        results.append((beta, x.copy(), lam))
    
    return results


def approximation_error_bound(n: int, beta: float) -> float:
    """
    Theoretical bound on ‖T_{A,β}x - T_A x‖_∞.
    
    Returns log(n)/β.
    
    Args:
        n: Dimension (number of states)
        beta: Inverse temperature
        
    Returns:
        The error bound log(n)/β
    """
    return np.log(n) / beta


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Demo 1: Tropical vs soft matrix multiplication
    print("1. Tropical vs Soft Matrix Multiplication")
    A = np.array([[1.0, 2.0], [3.0, 0.0]])
    B = np.array([[0.0, 1.0], [2.0, 0.0]])
    
    C_trop = tropical_matmul(A, B)
    print(f"   Tropical A⊗B = \n{C_trop}")
    
    for beta in [1.0, 10.0, 100.0]:
        C_soft = soft_tropical_matmul(A, B, beta)
        err = np.max(np.abs(C_soft - C_trop))
        bound = approximation_error_bound(2, beta)
        print(f"   β={beta:6.1f}: ‖soft-trop‖∞ = {err:.6f}, bound = {bound:.6f}")
    
    # Demo 2: Bellman iteration convergence
    print("\n2. Bellman Iteration: Soft vs Tropical")
    A = np.array([[0.0, 3.0, 1.0], [2.0, 0.0, 4.0], [1.0, 2.0, 0.0]])
    x0 = np.zeros(3)
    
    v_trop, lam_trop, iters_trop = tropical_bellman_iteration(A, x0)
    print(f"   Tropical: λ = {lam_trop:.6f}, converged in {iters_trop} iters")
    print(f"   Tropical eigenvector: {np.round(v_trop, 4)}")
    
    for beta in [1.0, 5.0, 10.0, 50.0]:
        v_soft, lam_soft, iters = bellman_iteration(A, x0, beta)
        err = np.max(np.abs(v_soft - v_trop))
        print(f"   β={beta:5.1f}: λ={lam_soft:.6f}, ‖v_β-v_trop‖∞={err:.6f}, iters={iters}")
    
    # Demo 3: Temperature annealing
    print("\n3. Temperature Annealing")
    schedule = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]
    results = temperature_annealing(A, x0, schedule)
    
    print(f"   {'β':>8s} {'eigenvalue':>12s} {'‖v_β-v_trop‖∞':>16s}")
    for beta, v, lam in results:
        err = np.max(np.abs(v - v_trop))
        print(f"   {beta:8.1f} {lam:12.6f} {err:16.6f}")
