"""
Tropical Gradient Flow: Algorithms
===================================

Type-hinted implementations of the core algorithms from the research.
"""

from typing import List, Tuple, Optional, Callable
import numpy as np


# ============================================================
# Core Definitions
# ============================================================

def maslov_soft_max(t: float, a: float, b: float) -> float:
    """
    Maslov soft maximum: (1/t) * log(exp(ta) + exp(tb)).
    
    Converges to max(a, b) as t → ∞ with error ≤ log(2)/t.
    Uses numerically stable computation.
    
    Args:
        t: Temperature parameter (t > 0)
        a: First value
        b: Second value
    Returns:
        Soft maximum approximation
    """
    m = max(a, b)
    return m + (1.0 / t) * np.log(np.exp(t * (a - m)) + np.exp(t * (b - m)))


def tropical_neuron(a: float, b: float, x: float) -> float:
    """
    Tropical neuron: max(a+x, 0) - max(b+x, 0).
    
    This is the tropical limit of the EML neuron exp(w₁x+b₁) - log(w₂x+b₂).
    Piecewise-linear with at most 3 linear regions.
    
    Properties:
        - Lipschitz in x with constant 2
        - Lipschitz in a with constant 1
        - Antisymmetric: f(x; a, b) = -f(x; b, a)
    """
    return max(a + x, 0.0) - max(b + x, 0.0)


def softplus(x: float) -> float:
    """
    Softplus function: log(1 + exp(x)).
    
    Smooth approximation to ReLU with:
        - max(x, 0) ≤ softplus(x) ≤ max(x, 0) + log(2)
    """
    if x > 20:
        return x  # Avoid overflow
    if x < -20:
        return np.exp(x)  # Avoid underflow
    return np.log(1.0 + np.exp(x))


def tropical_l1_loss(
    data: List[Tuple[float, float]],
    a: float
) -> float:
    """
    Tropical L₁ loss for single-parameter model f(x; a) = max(a+x, 0).
    
    L(a) = Σᵢ |max(a + xᵢ, 0) - yᵢ|
    
    Properties:
        - Always ≥ 0
        - Lipschitz with constant n (number of data points)
        - Piecewise-linear in a
    """
    return sum(abs(max(a + x, 0.0) - y) for x, y in data)


# ============================================================
# Tropical Subgradient Flow System
# ============================================================

class TropicalSubgradientFlowSystem:
    """
    The Tropical Subgradient Flow System (TSFS).
    
    A discrete dynamical system for optimizing piecewise-linear convex
    objectives. The trajectory is piecewise-linear and visits at most
    one new cell of the breakpoint arrangement per step.
    
    Attributes:
        slopes: List of slopes of affine pieces
        intercepts: List of intercepts of affine pieces
        step_size: Learning rate η > 0
    """
    
    def __init__(
        self,
        slopes: List[float],
        intercepts: List[float],
        step_size: float
    ):
        assert len(slopes) == len(intercepts), "Must have equal slopes and intercepts"
        assert len(slopes) > 0, "Must have at least one piece"
        assert step_size > 0, "Step size must be positive"
        self.slopes = slopes
        self.intercepts = intercepts
        self.step_size = step_size
    
    def eval(self, x: float) -> float:
        """Evaluate the PL convex loss at x."""
        return max(m * x + c for m, c in zip(self.slopes, self.intercepts))
    
    def subgradient(self, x: float) -> float:
        """Compute the subgradient at x (slope of maximally active piece)."""
        best_val = float('-inf')
        best_slope = self.slopes[0]
        for m, c in zip(self.slopes, self.intercepts):
            val = m * x + c
            if val > best_val:
                best_val = val
                best_slope = m
        return best_slope
    
    def step(self, x: float) -> float:
        """One step of subgradient descent."""
        return x - self.step_size * self.subgradient(x)
    
    def trajectory(self, x0: float, n_steps: int) -> List[float]:
        """Generate the trajectory from x0 for n_steps."""
        traj = [x0]
        x = x0
        for _ in range(n_steps):
            x = self.step(x)
            traj.append(x)
        return traj


# ============================================================
# Tropical Subgradient Descent Algorithm
# ============================================================

def tropical_subgradient_descent(
    data: List[Tuple[float, float]],
    a0: float,
    step_size: float,
    max_steps: int = 1000,
    tol: float = 1e-10
) -> Tuple[float, float, List[float]]:
    """
    Tropical subgradient descent for L₁ loss minimization.
    
    Algorithm:
        1. Compute breakpoints B = {-x₁, ..., -xₙ}
        2. For each step:
           a. Compute subgradient
           b. Update: a_{k+1} = a_k - η * g_k
           c. Stop if g_k = 0
    
    Args:
        data: List of (x, y) data points
        a0: Initial parameter value
        step_size: Learning rate η
        max_steps: Maximum number of iterations
        tol: Convergence tolerance
    
    Returns:
        Tuple of (optimal a, optimal loss, loss history)
    """
    a = a0
    loss_history = []
    
    for step in range(max_steps):
        loss = tropical_l1_loss(data, a)
        loss_history.append(loss)
        
        # Compute subgradient
        g = 0.0
        for x, y in data:
            val = max(a + x, 0.0)
            if a + x <= 0:
                # In the flat region of ReLU
                g += 0.0 if y == 0 else (-1.0 if y > 0 else 1.0)
            else:
                # In the active region
                g += 1.0 if val >= y else -1.0
        
        if abs(g) < tol:
            break
        
        a = a - step_size * g
    
    return a, tropical_l1_loss(data, a), loss_history


def compute_breakpoints(data: List[Tuple[float, float]]) -> List[float]:
    """
    Compute breakpoints of the tropical L₁ loss.
    
    Breakpoints occur at a = -xᵢ for each data point (xᵢ, yᵢ).
    """
    return sorted([-x for x, _ in data])


def maslov_dequantization_error(t: float) -> float:
    """
    Maximum error of Maslov dequantization at temperature t.
    
    Theorem: |MSM(t, a, b) - max(a, b)| ≤ log(2)/t for all a, b.
    """
    return np.log(2) / t


# ============================================================
# Scaled Softplus Approximation
# ============================================================

def scaled_softplus(t: float, x: float) -> float:
    """
    Scaled softplus: (1/t) * softplus(t * x).
    
    Approximates max(x, 0) with error ≤ log(2)/t.
    """
    return (1.0 / t) * softplus(t * x)


def relu(x: float) -> float:
    """ReLU: max(x, 0)."""
    return max(x, 0.0)


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    # Example: optimize a tropical neuron on 3 data points
    data = [(-1.0, 0.5), (0.0, 1.0), (1.0, 2.0)]
    
    print("Tropical Subgradient Descent")
    print(f"Data: {data}")
    print(f"Breakpoints: {compute_breakpoints(data)}")
    
    a_opt, loss_opt, history = tropical_subgradient_descent(
        data, a0=-3.0, step_size=0.1
    )
    
    print(f"Optimal a: {a_opt:.6f}")
    print(f"Optimal loss: {loss_opt:.6f}")
    print(f"Converged in {len(history)} steps")
    
    # Verify Maslov dequantization
    print(f"\nMaslov dequantization error bounds:")
    for t in [1, 10, 100, 1000]:
        print(f"  t={t}: guaranteed error ≤ {maslov_dequantization_error(t):.6f}")
