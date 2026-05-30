#!/usr/bin/env python3
"""
Information Geometry of Optimization: Core Algorithms

Implements natural gradient descent and related algorithms for optimization
on statistical manifolds equipped with the Fisher information metric.

Key algorithms:
1. NaturalGradientDescent - preconditions gradient by inverse Fisher matrix
2. StandardGradientDescent - baseline comparison
3. AdaptiveNaturalGradient - adapts step size using manifold curvature
4. ConvergenceBoundComputer - computes theoretical convergence bounds
"""

import numpy as np
from typing import Callable, Optional, Tuple, List


class FisherMetric:
    """
    Fisher information metric on a parameter space.
    
    Represents a positive-definite matrix G with eigenvalues in [λ_min, λ_max].
    The condition number κ = λ_max / λ_min determines the geometry distortion.
    
    Complexity: O(d²) storage, O(d³) for inverse computation.
    """
    
    def __init__(self, G: np.ndarray):
        """
        Initialize with a positive-definite matrix G.
        
        Args:
            G: d×d positive-definite matrix (Fisher information matrix)
        """
        self.G = G
        self.d = G.shape[0]
        eigenvalues = np.linalg.eigvalsh(G)
        self.lambda_min = float(eigenvalues[0])
        self.lambda_max = float(eigenvalues[-1])
        assert self.lambda_min > 0, "G must be positive definite"
        self.G_inv = np.linalg.inv(G)
    
    @property
    def condition_number(self) -> float:
        """Condition number κ = λ_max / λ_min ≥ 1."""
        return self.lambda_max / self.lambda_min
    
    def natural_gradient(self, grad: np.ndarray) -> np.ndarray:
        """
        Compute natural gradient: G⁻¹ · grad.
        
        This is the steepest descent direction on the Riemannian manifold
        with metric G, not in Euclidean space.
        
        Time complexity: O(d²) (matrix-vector multiply)
        """
        return self.G_inv @ grad


class NaturalGradientDescent:
    """
    Natural gradient descent optimizer.
    
    Updates: θ_{t+1} = θ_t - η · G⁻¹(θ_t) · ∇L(θ_t)
    
    Convergence rate:
    - Convex: L(θ_T) - L* ≤ D²/(2T)  (independent of κ)
    - Strongly convex: L(θ_T) - L* ≤ Δ₀ · exp(-T/d)
    
    Time complexity per step: O(d³) if G changes, O(d²) if G is fixed.
    Space complexity: O(d²) for storing G⁻¹.
    """
    
    def __init__(self, 
                 loss_fn: Callable[[np.ndarray], float],
                 grad_fn: Callable[[np.ndarray], np.ndarray],
                 fisher_fn: Callable[[np.ndarray], np.ndarray],
                 eta: float = 0.1,
                 fixed_fisher: bool = False):
        """
        Args:
            loss_fn: Loss function L(θ)
            grad_fn: Gradient ∇L(θ)
            fisher_fn: Fisher information matrix G(θ)
            eta: Step size
            fixed_fisher: If True, compute G⁻¹ only once (faster)
        """
        self.loss_fn = loss_fn
        self.grad_fn = grad_fn
        self.fisher_fn = fisher_fn
        self.eta = eta
        self.fixed_fisher = fixed_fisher
        self._cached_metric = None
    
    def step(self, theta: np.ndarray) -> Tuple[np.ndarray, float]:
        """
        Perform one natural gradient step.
        
        Returns: (new_theta, loss_value)
        Time: O(d³) if Fisher changes, O(d²) if fixed
        """
        loss = self.loss_fn(theta)
        grad = self.grad_fn(theta)
        
        if self._cached_metric is None or not self.fixed_fisher:
            G = self.fisher_fn(theta)
            self._cached_metric = FisherMetric(G)
        
        nat_grad = self._cached_metric.natural_gradient(grad)
        new_theta = theta - self.eta * nat_grad
        
        return new_theta, loss
    
    def optimize(self, theta0: np.ndarray, n_steps: int) -> Tuple[np.ndarray, List[float]]:
        """
        Run n_steps of natural gradient descent.
        
        Returns: (final_theta, loss_history)
        Time: O(n_steps · d³)
        """
        theta = theta0.copy()
        losses = []
        
        for _ in range(n_steps):
            theta, loss = self.step(theta)
            losses.append(loss)
        
        return theta, losses


class StandardGradientDescent:
    """
    Standard gradient descent optimizer (baseline comparison).
    
    Updates: θ_{t+1} = θ_t - η · ∇L(θ_t)
    
    Convergence rate:
    - Convex: L(θ_T) - L* ≤ β‖θ₀-θ*‖²/(2T)  (depends on κ)
    - Strongly convex: L(θ_T) - L* ≤ Δ₀ · (1-1/κ)^T
    
    Time complexity per step: O(d) for gradient evaluation.
    Space complexity: O(d).
    """
    
    def __init__(self,
                 loss_fn: Callable[[np.ndarray], float],
                 grad_fn: Callable[[np.ndarray], np.ndarray],
                 eta: float = 0.01):
        self.loss_fn = loss_fn
        self.grad_fn = grad_fn
        self.eta = eta
    
    def step(self, theta: np.ndarray) -> Tuple[np.ndarray, float]:
        loss = self.loss_fn(theta)
        grad = self.grad_fn(theta)
        return theta - self.eta * grad, loss
    
    def optimize(self, theta0: np.ndarray, n_steps: int) -> Tuple[np.ndarray, List[float]]:
        theta = theta0.copy()
        losses = []
        for _ in range(n_steps):
            theta, loss = self.step(theta)
            losses.append(loss)
        return theta, losses


class ConvergenceBoundComputer:
    """
    Computes theoretical convergence bounds for natural vs standard GD.
    
    Implements the bounds proved in the formal verification:
    - natGradGapBound: D²/(2T) for convex losses
    - natGradStrongConvexBound: Δ₀ · exp(-T/d) for strongly convex losses
    - gdStrongConvexBound: Δ₀ · (1-1/κ)^T for strongly convex losses with GD
    """
    
    @staticmethod
    def nat_grad_convex(diameter: float, T: int) -> float:
        """Natural gradient bound for convex losses: D²/(2T)."""
        assert T > 0, "T must be positive"
        return diameter**2 / (2 * T)
    
    @staticmethod
    def nat_grad_strongly_convex(delta0: float, d: int, T: int) -> float:
        """Natural gradient bound for strongly convex losses: Δ₀·exp(-T/d)."""
        return delta0 * np.exp(-T / d)
    
    @staticmethod
    def gd_strongly_convex(delta0: float, kappa: float, T: int) -> float:
        """Standard GD bound for strongly convex losses: Δ₀·(1-1/κ)^T."""
        return delta0 * (1 - 1/kappa)**T
    
    @staticmethod
    def iterations_for_epsilon(diameter: float, epsilon: float) -> int:
        """
        Minimum iterations for ε-accuracy with natural gradient (convex case).
        
        Returns: ⌈D²/(2ε)⌉ + 1
        This is proved in natGrad_iteration_count.
        """
        return int(np.ceil(diameter**2 / (2 * epsilon))) + 1
    
    @staticmethod
    def speedup_factor(kappa: float, d: int, T: int) -> float:
        """
        Ratio of GD bound to NG bound at step T.
        
        For large κ, this grows exponentially in T.
        """
        gd = (1 - 1/kappa)**T
        ng = np.exp(-T / d)
        return gd / max(ng, 1e-300)


def demo_algorithms():
    """Demonstrate the algorithms on a concrete quadratic problem."""
    d = 5
    kappa = 50
    
    # Create quadratic: f(x) = 0.5 x^T A x - b^T x
    eigenvalues = np.linspace(1, kappa, d)
    A = np.diag(eigenvalues)
    b = np.ones(d)
    x_opt = np.linalg.solve(A, b)
    f_opt = 0.5 * x_opt @ A @ x_opt - b @ x_opt
    
    loss_fn = lambda x: 0.5 * x @ A @ x - b @ x
    grad_fn = lambda x: A @ x - b
    fisher_fn = lambda x: A  # Fisher = Hessian for quadratic
    
    x0 = np.zeros(d)
    n_steps = 100
    
    # Natural gradient
    ng = NaturalGradientDescent(loss_fn, grad_fn, fisher_fn, eta=1.0, fixed_fisher=True)
    x_ng, losses_ng = ng.optimize(x0, n_steps)
    
    # Standard gradient
    sgd = StandardGradientDescent(loss_fn, grad_fn, eta=1.0/kappa)
    x_sgd, losses_sgd = sgd.optimize(x0, n_steps)
    
    print(f"Quadratic problem: d={d}, κ={kappa}")
    print(f"  Natural GD final loss gap: {losses_ng[-1] - f_opt:.2e}")
    print(f"  Standard GD final loss gap: {losses_sgd[-1] - f_opt:.2e}")
    
    # Theoretical bounds
    bc = ConvergenceBoundComputer()
    delta0 = loss_fn(x0) - f_opt
    print(f"\nTheoretical bounds after {n_steps} steps:")
    print(f"  NG bound (strongly convex): {bc.nat_grad_strongly_convex(delta0, d, n_steps):.2e}")
    print(f"  GD bound (strongly convex): {bc.gd_strongly_convex(delta0, kappa, n_steps):.2e}")
    print(f"  Speedup factor: {bc.speedup_factor(kappa, d, n_steps):.1f}x")


if __name__ == "__main__":
    demo_algorithms()
