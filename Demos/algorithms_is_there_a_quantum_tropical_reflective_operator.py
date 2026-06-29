"""
Quantum Tropical Dynamics: Core Algorithms

Implements the key algorithms from the quantum tropical dynamics framework:
1. Log-sum-exp (numerically stable soft minimum)
2. Quantum tropical matrix-vector product
3. Perron-Frobenius eigenvector computation
4. Normalized power iteration for eigenvector
5. Entropy-regularized shortest path (soft Bellman)
"""

import numpy as np
from typing import Tuple, List, Optional


def log_sum_exp(x: np.ndarray, beta: float) -> float:
    """Numerically stable log-sum-exp computation.
    
    Computes -(1/β) * log(∑_i exp(-β * x_i))
    
    Uses the max-shift trick for numerical stability:
    log(∑ exp(a_i)) = m + log(∑ exp(a_i - m)) where m = max(a_i)
    
    Args:
        x: Input vector of real values
        beta: Inverse temperature parameter (β > 0)
    
    Returns:
        The soft minimum value
        
    Complexity: O(n) time, O(1) space
    
    Example:
        >>> log_sum_exp(np.array([1.0, 2.0, 3.0]), beta=10.0)
        1.0000453...  # ≈ min(1, 2, 3) = 1
    """
    if beta <= 0:
        raise ValueError("β must be positive")
    m = np.min(x)
    return m - (1.0/beta) * np.log(np.sum(np.exp(-beta * (x - m))))


def qtrop_map(beta: float, A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Quantum tropical matrix-vector product.
    
    Computes (T_{β,A} x)(i) = -(1/β) * log(∑_j exp(-β * (A_{ij} + x_j)))
    
    This is the soft min-plus analogue of the tropical linear map
    (T_A x)(i) = min_j(A_{ij} + x_j).
    
    Args:
        beta: Inverse temperature (β > 0)
        A: Weight matrix (n × n)
        x: State vector (length n)
    
    Returns:
        Transformed state vector (length n)
    
    Complexity: O(n²) time, O(n) space
    """
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = log_sum_exp(A[i, :] + x, beta)
    return result


def normalize0(x: np.ndarray) -> np.ndarray:
    """Normalize by subtracting the 0-th coordinate.
    
    Projects onto the hyperplane {x | x_0 = 0}, quotienting out
    the additive gauge symmetry.
    
    Args:
        x: Input vector
    
    Returns:
        Normalized vector with x[0] = 0
    """
    return x - x[0]


def perron_eigenvector(A: np.ndarray, beta: float, 
                       tol: float = 1e-12, 
                       max_iter: int = 1000) -> Tuple[np.ndarray, float]:
    """Compute the quantum tropical eigenvector via Perron-Frobenius.
    
    Reduces the nonlinear eigenvector equation T_{β,A}(x) = x + λ
    to the linear eigenvalue problem M u = μ u where:
        M_{ij} = exp(-β * A_{ij})  (entrywise exponential)
        u_j = exp(-β * x_j)       (exponential change of variable)
        μ = exp(-β * λ)           (exponential eigenvalue)
    
    Uses power iteration on M for numerical stability.
    
    Args:
        A: Weight matrix (n × n)
        beta: Inverse temperature (β > 0)
        tol: Convergence tolerance
        max_iter: Maximum iterations
    
    Returns:
        (x, eigval): Eigenvector and eigenvalue satisfying T(x) ≈ x + eigval
    
    Complexity: O(n² · max_iter) time, O(n²) space
    
    Algorithm:
        1. Form M = exp(-β A) (entrywise)
        2. Power iteration: u ← M u / ‖M u‖₁
        3. Extract eigenvalue: μ = (M u)_0 / u_0
        4. Convert back: x = -(1/β) log(u), λ = -(1/β) log(μ)
    """
    n = A.shape[0]
    M = np.exp(-beta * A)
    
    # Power iteration
    u = np.ones(n) / n
    for k in range(max_iter):
        Mu = M @ u
        mu = np.sum(Mu)  # L1 norm for normalization
        u_new = Mu / mu
        if np.max(np.abs(u_new - u)) < tol:
            break
        u = u_new
    
    # Extract Perron eigenvalue
    Mu = M @ u
    mu = Mu[0] / u[0]  # Perron eigenvalue
    
    # Convert to quantum tropical eigenvector
    x = -(1.0/beta) * np.log(u)
    eigval = -(1.0/beta) * np.log(mu)
    
    return x, eigval


def normalized_fixed_point(A: np.ndarray, beta: float,
                           tol: float = 1e-12,
                           max_iter: int = 1000) -> Tuple[np.ndarray, float, int]:
    """Find the normalized fixed point by direct iteration.
    
    Iterates x ← normalize0(T_{β,A}(x)) until convergence.
    
    Args:
        A: Weight matrix (n × n)
        beta: Inverse temperature (β > 0)
        tol: Convergence tolerance
        max_iter: Maximum iterations
    
    Returns:
        (x, eigval, iters): Fixed point, eigenvalue, iteration count
    
    Complexity: O(n² · iters) time
    """
    n = A.shape[0]
    x = np.zeros(n)
    
    for k in range(max_iter):
        Tx = qtrop_map(beta, A, x)
        x_new = normalize0(Tx)
        if np.max(np.abs(x_new - x)) < tol:
            eigval = Tx[0]  # Since x[0] = 0, eigval = T(x)[0]
            return x_new, eigval, k + 1
        x = x_new
    
    eigval = qtrop_map(beta, A, x)[0]
    return x, eigval, max_iter


def soft_bellman_iteration(A: np.ndarray, beta: float,
                           discount: float = 0.9,
                           reward: Optional[np.ndarray] = None,
                           tol: float = 1e-10,
                           max_iter: int = 1000) -> Tuple[np.ndarray, int]:
    """Entropy-regularized value iteration (soft Bellman operator).
    
    Solves the fixed-point equation:
        V(i) = r(i) + γ · qmin_β(A_i + V)
    
    where r is the reward vector, γ is the discount factor.
    
    This is the entropy-regularized version of the standard
    Bellman equation in dynamic programming / reinforcement learning.
    
    Args:
        A: Transition cost matrix (n × n)
        beta: Inverse temperature (β > 0)
        discount: Discount factor γ ∈ (0, 1)
        reward: Reward vector (default: zeros)
        tol: Convergence tolerance
        max_iter: Maximum iterations
    
    Returns:
        (V, iters): Value function and iteration count
    
    Complexity: O(n² · iters)
    """
    n = A.shape[0]
    if reward is None:
        reward = np.zeros(n)
    
    V = np.zeros(n)
    for k in range(max_iter):
        V_new = reward + discount * qtrop_map(beta, A, V)
        if np.max(np.abs(V_new - V)) < tol:
            return V_new, k + 1
        V = V_new
    
    return V, max_iter


def tropical_approximation_error(A: np.ndarray, x: np.ndarray, 
                                  beta: float) -> Tuple[np.ndarray, float]:
    """Compute the coordinatewise error between quantum and hard tropical maps.
    
    For each i, computes:
        error_i = |T_{β,A}(x)_i - T_A^{min}(x)_i|
    
    By the sandwich theorem, 0 ≤ error_i ≤ log(n)/β.
    
    Args:
        A: Weight matrix
        x: State vector
        beta: Inverse temperature
    
    Returns:
        (errors, max_error): Per-coordinate and maximum errors
    """
    Tx_soft = qtrop_map(beta, A, x)
    Tx_hard = np.array([np.min(A[i, :] + x) for i in range(A.shape[0])])
    errors = np.abs(Tx_soft - Tx_hard)
    return errors, np.max(errors)


# ==================== Example Usage ====================
if __name__ == "__main__":
    np.random.seed(42)
    n = 5
    A = np.random.randn(n, n)
    
    print("Quantum Tropical Dynamics - Algorithm Demonstrations")
    print("=" * 60)
    
    # Perron-Frobenius eigenvector
    print("\n1. Perron-Frobenius Eigenvector")
    x_eig, eigval = perron_eigenvector(A, beta=3.0)
    Tx = qtrop_map(3.0, A, x_eig)
    print(f"   Eigenvalue: {eigval:.8f}")
    print(f"   Residual:   {np.max(np.abs(Tx - (x_eig + eigval))):.2e}")
    
    # Normalized fixed point
    print("\n2. Normalized Fixed Point")
    x_fp, eigval_fp, iters = normalized_fixed_point(A, beta=3.0)
    print(f"   Eigenvalue: {eigval_fp:.8f}")
    print(f"   Iterations: {iters}")
    residual = np.max(np.abs(normalize0(qtrop_map(3.0, A, x_fp)) - x_fp))
    print(f"   Residual:   {residual:.2e}")
    
    # Soft Bellman
    print("\n3. Soft Bellman Iteration")
    V, iters = soft_bellman_iteration(A, beta=5.0, discount=0.9)
    print(f"   Value function: {V}")
    print(f"   Iterations:     {iters}")
    
    # Tropical approximation
    print("\n4. Tropical Approximation Error")
    for beta in [1.0, 5.0, 20.0, 100.0]:
        _, max_err = tropical_approximation_error(A, np.zeros(n), beta)
        bound = np.log(n) / beta
        print(f"   β={beta:6.1f}: max_error={max_err:.6f}, bound=log(n)/β={bound:.6f}")
