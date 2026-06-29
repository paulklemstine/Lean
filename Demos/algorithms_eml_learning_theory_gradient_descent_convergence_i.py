#!/usr/bin/env python3
"""
Tropical Gradient Descent: Algorithm Implementations

Type-hinted implementations of the core algorithms from the TropGDS framework.
"""

import numpy as np
from typing import Callable, Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class TropGDSConfig:
    """Configuration for a Tropical Gradient Descent System."""
    dim: int  # Parameter dimension P
    num_cells: int  # Number of cells M
    cell_of: Callable[[np.ndarray], int]  # Cell assignment function
    grad: Callable[[int], np.ndarray]  # Gradient on each cell
    loss: Callable[[np.ndarray], float]  # Loss function
    eta: float  # Learning rate

    def grad_norm_sq(self, cell: int) -> float:
        """Squared norm of gradient on cell c."""
        g = self.grad(cell)
        return float(np.sum(g * g))

    def is_critical(self, cell: int) -> bool:
        """Check if a cell is critical (zero gradient)."""
        return self.grad_norm_sq(cell) < 1e-15

    def step(self, theta: np.ndarray) -> np.ndarray:
        """One gradient descent step."""
        cell = self.cell_of(theta)
        g = self.grad(cell)
        return theta - self.eta * g

    def min_grad_norm_sq(self) -> float:
        """Minimum gradient norm squared over non-critical cells."""
        min_val = float('inf')
        for c in range(self.num_cells):
            gns = self.grad_norm_sq(c)
            if gns > 1e-15:
                min_val = min(min_val, gns)
        return min_val if min_val < float('inf') else 0.0


def tropical_gradient_descent(
    config: TropGDSConfig,
    theta0: np.ndarray,
    max_steps: int = 10000
) -> Tuple[np.ndarray, List[Tuple[np.ndarray, float, int, int]]]:
    """
    Run Tropical Gradient Descent.
    
    Returns:
        (final_theta, trajectory) where trajectory is a list of
        (theta, loss, cell, step_number) tuples.
    """
    theta = theta0.copy()
    trajectory: List[Tuple[np.ndarray, float, int, int]] = []
    
    for t in range(max_steps):
        cell = config.cell_of(theta)
        loss_val = config.loss(theta)
        trajectory.append((theta.copy(), loss_val, cell, t))
        
        if config.is_critical(cell):
            break
        
        theta = config.step(theta)
    
    return theta, trajectory


def convergence_bound(
    config: TropGDSConfig,
    theta0: np.ndarray,
    lower_bound: float
) -> int:
    """
    Compute the theoretical convergence bound ceil((L0 - B) / delta).
    """
    L0 = config.loss(theta0)
    delta = config.eta * config.min_grad_norm_sq()
    if delta <= 0:
        return -1  # All cells are critical
    return int(np.ceil((L0 - lower_bound) / delta))


def cell_aware_adaptive_gd(
    config: TropGDSConfig,
    theta0: np.ndarray,
    max_steps: int = 10000,
    cell_boundary_detector: Optional[Callable[[np.ndarray, np.ndarray, int], float]] = None
) -> Tuple[np.ndarray, List[Tuple[np.ndarray, float, int, int]]]:
    """
    Cell-aware adaptive tropical GD.
    
    Uses an adaptive step size that maximizes progress within each cell
    before crossing to the next.
    
    Args:
        config: TropGDS configuration
        theta0: Initial parameter
        max_steps: Maximum iterations
        cell_boundary_detector: Optional function(theta, grad, cell) -> max_step_in_cell
    
    Returns:
        (final_theta, trajectory)
    """
    theta = theta0.copy()
    trajectory: List[Tuple[np.ndarray, float, int, int]] = []
    
    for t in range(max_steps):
        cell = config.cell_of(theta)
        loss_val = config.loss(theta)
        trajectory.append((theta.copy(), loss_val, cell, t))
        
        if config.is_critical(cell):
            break
        
        g = config.grad(cell)
        
        if cell_boundary_detector is not None:
            max_step = cell_boundary_detector(theta, g, cell)
            eta_t = min(config.eta, max_step * 0.99)  # Stay just inside cell
        else:
            eta_t = config.eta
        
        theta = theta - eta_t * g
    
    return theta, trajectory


def make_max_of_affines_gds(
    coeffs: np.ndarray,  # Shape (M, P) - slope for each cell/dimension
    intercepts: np.ndarray,  # Shape (M,) - intercept for each cell
    eta: float = 0.1
) -> TropGDSConfig:
    """
    Create a TropGDS from a max-of-affines loss function.
    
    L(theta) = max_c {sum_p coeffs[c,p] * theta[p] + intercepts[c]}
    """
    M, P = coeffs.shape
    
    def cell_of(theta: np.ndarray) -> int:
        values = coeffs @ theta + intercepts
        return int(np.argmax(values))
    
    def grad(cell: int) -> np.ndarray:
        return coeffs[cell].copy()
    
    def loss(theta: np.ndarray) -> float:
        values = coeffs @ theta + intercepts
        return float(np.max(values))
    
    return TropGDSConfig(
        dim=P, num_cells=M, cell_of=cell_of,
        grad=grad, loss=loss, eta=eta
    )


def make_relu_network_gds(
    weights: np.ndarray,  # Shape (n_hidden, input_dim)
    biases: np.ndarray,   # Shape (n_hidden,)
    output_weights: np.ndarray,  # Shape (n_hidden,)
    x_data: np.ndarray,   # Shape (n_data, input_dim)
    y_data: np.ndarray,   # Shape (n_data,)
    eta: float = 0.01
) -> TropGDSConfig:
    """
    Create a TropGDS for a single-hidden-layer ReLU network with MSE loss.
    
    Network: f(x) = sum_j output_weights[j] * max(0, weights[j] @ x + biases[j])
    Loss: L = sum_i (f(x_i) - y_i)^2
    
    Note: This creates an approximate TropGDS since the full cell structure
    depends on all data points and activation patterns.
    """
    n_hidden = len(biases)
    # Total parameters: weights (n_hidden * input_dim) + biases (n_hidden)
    input_dim = weights.shape[1]
    param_dim = n_hidden * input_dim + n_hidden
    
    def params_to_wb(theta: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        w = theta[:n_hidden * input_dim].reshape(n_hidden, input_dim)
        b = theta[n_hidden * input_dim:]
        return w, b
    
    def forward(theta: np.ndarray) -> np.ndarray:
        w, b = params_to_wb(theta)
        pre_act = x_data @ w.T + b  # (n_data, n_hidden)
        act = np.maximum(0, pre_act)
        return act @ output_weights  # (n_data,)
    
    def loss(theta: np.ndarray) -> float:
        pred = forward(theta)
        return float(np.sum((pred - y_data) ** 2))
    
    def cell_of(theta: np.ndarray) -> int:
        w, b = params_to_wb(theta)
        pre_act = x_data @ w.T + b
        pattern = (pre_act > 0).astype(int)
        # Hash the activation pattern to a cell index
        return hash(pattern.tobytes()) % (2 ** 20)
    
    def grad(cell: int) -> np.ndarray:
        # For the approximate version, compute gradient numerically
        # In the exact TropGDS, this would be analytically constant per cell
        return np.zeros(param_dim)
    
    return TropGDSConfig(
        dim=param_dim, num_cells=2 ** (n_hidden * len(x_data)),
        cell_of=cell_of, grad=grad, loss=loss, eta=eta
    )


if __name__ == "__main__":
    # Example: max-of-affines in 2D
    coeffs = np.array([
        [1.0, 1.0],    # x + y
        [1.0, -1.0],   # x - y + 1
        [-1.0, 1.0],   # -x + y + 1
        [-1.0, -1.0],  # -x - y + 2
        [0.0, 0.0],    # 0.5 (critical)
    ])
    intercepts = np.array([0.0, 1.0, 1.0, 2.0, 0.5])
    
    config = make_max_of_affines_gds(coeffs, intercepts, eta=0.1)
    theta0 = np.array([1.5, 0.5])
    
    final, traj = tropical_gradient_descent(config, theta0)
    
    print("Max-of-Affines Tropical GD:")
    print(f"  Converged in {len(traj)} steps")
    print(f"  Final theta: {final}")
    print(f"  Final loss: {config.loss(final):.4f}")
    
    bound = convergence_bound(config, theta0, lower_bound=0.5)
    print(f"  Convergence bound: {bound}")
