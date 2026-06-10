#!/usr/bin/env python3
"""
NTK Convergence Algorithms

Type-hinted implementations of the core algorithms from the NTK convergence theory.
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class NTKDynamics:
    """Kernel-driven dynamical system for NTK training.
    
    Attributes:
        kernel: (n, n) kernel matrix K
        learning_rate: η > 0
    """
    kernel: np.ndarray
    learning_rate: float
    
    def __post_init__(self) -> None:
        assert self.learning_rate > 0, "Learning rate must be positive"
        assert self.kernel.shape[0] == self.kernel.shape[1], "Kernel must be square"
    
    @property
    def n(self) -> int:
        """Number of training points."""
        return self.kernel.shape[0]
    
    @property
    def update_op(self) -> np.ndarray:
        """Update operator T = I - ηK."""
        return np.eye(self.n) - self.learning_rate * self.kernel
    
    def step(self, u: np.ndarray) -> np.ndarray:
        """One step of gradient descent: u_{t+1} = Tu_t."""
        return self.update_op @ u
    
    def residual(self, u0: np.ndarray, t: int) -> np.ndarray:
        """Residual after t steps: u(t) = T^t · u₀."""
        return np.linalg.matrix_power(self.update_op, t) @ u0
    
    def trajectory(self, u0: np.ndarray, T: int) -> np.ndarray:
        """Full trajectory of residuals for T steps."""
        traj = np.zeros((T + 1, self.n))
        traj[0] = u0
        u = u0.copy()
        for t in range(T):
            u = self.step(u)
            traj[t + 1] = u
        return traj
    
    def contraction_constant(self) -> float:
        """Compute the contraction constant c = max|1 - η·λ|."""
        eigenvalues = np.linalg.eigvalsh(self.kernel)
        return float(max(
            abs(1 - self.learning_rate * eigenvalues.min()),
            abs(1 - self.learning_rate * eigenvalues.max())
        ))
    
    def is_contractive(self) -> bool:
        """Check if the system is contractive (c < 1)."""
        return self.contraction_constant() < 1.0
    
    def optimal_learning_rate(self) -> float:
        """Compute the optimal learning rate η* = 2/(λ_min + λ_max)."""
        eigenvalues = np.linalg.eigvalsh(self.kernel)
        return 2.0 / (eigenvalues.min() + eigenvalues.max())
    
    def condition_number(self) -> float:
        """Condition number κ = λ_max / λ_min of the kernel."""
        eigenvalues = np.linalg.eigvalsh(self.kernel)
        if eigenvalues.min() <= 0:
            return float('inf')
        return float(eigenvalues.max() / eigenvalues.min())


def compute_ntk(
    grad_fn: callable,
    theta: np.ndarray,
    X: np.ndarray
) -> np.ndarray:
    """Compute the NTK matrix from a gradient function.
    
    Args:
        grad_fn: Function (theta, x) -> gradient vector of shape (p,)
        theta: Parameter vector of shape (p,)
        X: Training inputs of shape (n, d)
    
    Returns:
        K: NTK matrix of shape (n, n)
    """
    n = X.shape[0]
    grads = np.array([grad_fn(theta, X[i]) for i in range(n)])
    return grads @ grads.T


def two_layer_relu_ntk(
    W1: np.ndarray,
    W2: np.ndarray,
    X: np.ndarray
) -> np.ndarray:
    """Compute NTK for a two-layer ReLU network f(x) = W2 · ReLU(W1 · x).
    
    Args:
        W1: First layer weights, shape (m, d)
        W2: Second layer weights, shape (1, m) or (m,)
        X: Training inputs, shape (n, d)
    
    Returns:
        K: NTK matrix, shape (n, n)
    """
    m, d = W1.shape
    W2 = W2.flatten()
    n = X.shape[0]
    
    # Pre-activations: (n, m)
    pre = X @ W1.T
    # Activations: (n, m)  
    act = np.maximum(pre, 0)
    # Activation indicator: (n, m)
    indicator = (pre > 0).astype(float)
    
    # Jacobian w.r.t. W1: ∂f/∂W1[i,j] = W2[i] * indicator[x, i] * x[j]
    # Shape: (n, m*d) -- flatten W1 gradient
    J_W1 = np.zeros((n, m * d))
    for k in range(n):
        for i in range(m):
            if indicator[k, i] > 0:
                J_W1[k, i*d:(i+1)*d] = W2[i] * X[k]
    
    # Jacobian w.r.t. W2: ∂f/∂W2[i] = ReLU(W1[i] · x)
    J_W2 = act  # (n, m)
    
    # Full Jacobian
    J = np.hstack([J_W1, J_W2])
    
    return J @ J.T


def convergence_analysis(
    K: np.ndarray,
    u0: np.ndarray,
    eta: Optional[float] = None,
    T: int = 100
) -> dict:
    """Full convergence analysis of an NTK system.
    
    Args:
        K: Kernel matrix
        u0: Initial residual
        eta: Learning rate (if None, use optimal)
        T: Number of steps
    
    Returns:
        Dictionary with analysis results
    """
    eigenvalues = np.linalg.eigvalsh(K)
    
    if eta is None:
        eta = 2.0 / (eigenvalues.min() + eigenvalues.max())
    
    sys = NTKDynamics(kernel=K, learning_rate=eta)
    traj = sys.trajectory(u0, T)
    norms = np.linalg.norm(traj, axis=1)
    c = sys.contraction_constant()
    
    # Find convergence time (norm < 1e-10)
    converged_at = None
    for t in range(T + 1):
        if norms[t] < 1e-10:
            converged_at = t
            break
    
    return {
        'eigenvalues': eigenvalues,
        'learning_rate': eta,
        'contraction_constant': c,
        'condition_number': sys.condition_number(),
        'is_contractive': sys.is_contractive(),
        'trajectory_norms': norms,
        'converged_at': converged_at,
        'final_residual_norm': float(norms[-1]),
        'theoretical_bound': [c**t * norms[0] for t in range(T + 1)],
    }


def kernel_regression_solution(K: np.ndarray, y: np.ndarray, reg: float = 1e-10) -> np.ndarray:
    """Compute the kernel regression solution: f* = K(K + λI)^{-1} y.
    
    Args:
        K: Kernel matrix (n, n)
        y: Target values (n,)
        reg: Regularization parameter λ
    
    Returns:
        f*: Predicted values (n,)
    """
    n = K.shape[0]
    return K @ np.linalg.solve(K + reg * np.eye(n), y)


if __name__ == "__main__":
    np.random.seed(42)
    
    # Example: Two-layer ReLU network
    d, m, n = 5, 100, 10
    W1 = np.random.randn(m, d) / np.sqrt(d)
    W2 = np.random.randn(m) / np.sqrt(m)
    X = np.random.randn(n, d)
    
    K = two_layer_relu_ntk(W1, W2, X)
    u0 = np.random.randn(n)
    
    results = convergence_analysis(K, u0, T=200)
    
    print("NTK Convergence Analysis")
    print(f"  Eigenvalue range: [{results['eigenvalues'].min():.4f}, {results['eigenvalues'].max():.4f}]")
    print(f"  Condition number: {results['condition_number']:.2f}")
    print(f"  Learning rate: {results['learning_rate']:.6f}")
    print(f"  Contraction constant: {results['contraction_constant']:.6f}")
    print(f"  Convergent: {results['is_contractive']}")
    print(f"  Final residual: {results['final_residual_norm']:.2e}")
    if results['converged_at']:
        print(f"  Converged at step: {results['converged_at']}")
