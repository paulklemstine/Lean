"""
Information Geometry of Optimization: Algorithms

Type-hinted implementations of natural gradient descent, mirror descent,
and Bregman divergence computations.
"""

from typing import Callable, List, Tuple
import numpy as np
from numpy.typing import NDArray


Vector = NDArray[np.float64]
Matrix = NDArray[np.float64]


def fisher_information_gaussian(mu: float, sigma: float) -> Matrix:
    """Fisher information matrix for 1D Gaussian N(mu, sigma^2).

    G = [[1/sigma^2, 0], [0, 2/sigma^2]]
    """
    return np.array([
        [1.0 / sigma**2, 0.0],
        [0.0, 2.0 / sigma**2]
    ])


def natural_gradient(
    grad: Vector,
    fisher: Matrix
) -> Vector:
    """Compute natural gradient: G^{-1} @ grad.

    Args:
        grad: Euclidean gradient ∇L(θ)
        fisher: Fisher information matrix G(θ)

    Returns:
        Natural gradient g̃ = G⁻¹ ∇L
    """
    return np.linalg.solve(fisher, grad)


def natural_gradient_descent(
    loss_fn: Callable[[Vector], float],
    grad_fn: Callable[[Vector], Vector],
    fisher_fn: Callable[[Vector], Matrix],
    theta0: Vector,
    step_sizes: List[float],
    max_iter: int = 1000
) -> Tuple[List[Vector], List[float]]:
    """Natural gradient descent on a statistical manifold.

    θ_{t+1} = θ_t - η_t · G(θ_t)⁻¹ · ∇L(θ_t)

    Args:
        loss_fn: Loss function L(θ)
        grad_fn: Gradient function ∇L(θ)
        fisher_fn: Fisher information matrix G(θ)
        theta0: Initial parameters
        step_sizes: List of step sizes η_t
        max_iter: Maximum iterations

    Returns:
        (trajectory, losses): parameter trajectory and loss values
    """
    theta = theta0.copy()
    trajectory = [theta.copy()]
    losses = [loss_fn(theta)]

    for t in range(min(max_iter, len(step_sizes))):
        grad = grad_fn(theta)
        fisher = fisher_fn(theta)
        nat_grad = natural_gradient(grad, fisher)
        theta = theta - step_sizes[t] * nat_grad
        trajectory.append(theta.copy())
        losses.append(loss_fn(theta))

    return trajectory, losses


def standard_gradient_descent(
    loss_fn: Callable[[Vector], float],
    grad_fn: Callable[[Vector], Vector],
    theta0: Vector,
    step_sizes: List[float],
    max_iter: int = 1000
) -> Tuple[List[Vector], List[float]]:
    """Standard gradient descent (Euclidean).

    θ_{t+1} = θ_t - η_t · ∇L(θ_t)

    Args:
        loss_fn: Loss function L(θ)
        grad_fn: Gradient function ∇L(θ)
        theta0: Initial parameters
        step_sizes: List of step sizes η_t
        max_iter: Maximum iterations

    Returns:
        (trajectory, losses): parameter trajectory and loss values
    """
    theta = theta0.copy()
    trajectory = [theta.copy()]
    losses = [loss_fn(theta)]

    for t in range(min(max_iter, len(step_sizes))):
        grad = grad_fn(theta)
        theta = theta - step_sizes[t] * grad
        trajectory.append(theta.copy())
        losses.append(loss_fn(theta))

    return trajectory, losses


def bregman_divergence(
    phi: Callable[[Vector], float],
    grad_phi: Callable[[Vector], Vector],
    x: Vector,
    y: Vector
) -> float:
    """Compute Bregman divergence D_φ(x, y) = φ(x) - φ(y) - ⟨∇φ(y), x - y⟩.

    Args:
        phi: Strictly convex generating function φ
        grad_phi: Gradient of φ
        x, y: Points in parameter space

    Returns:
        D_φ(x, y)
    """
    return phi(x) - phi(y) - np.dot(grad_phi(y), x - y)


def mirror_descent(
    loss_fn: Callable[[Vector], float],
    grad_loss: Callable[[Vector], Vector],
    grad_phi: Callable[[Vector], Vector],
    grad_phi_inv: Callable[[Vector], Vector],
    theta0: Vector,
    step_sizes: List[float],
    max_iter: int = 1000
) -> Tuple[List[Vector], List[float]]:
    """Mirror descent with Bregman divergence.

    Dual update: η̃_{t+1} = ∇φ(θ_t) - η_t · ∇L(θ_t)
    Primal recovery: θ_{t+1} = (∇φ)⁻¹(η̃_{t+1})

    Args:
        loss_fn: Loss function
        grad_loss: Gradient of loss
        grad_phi: Gradient of generating function
        grad_phi_inv: Inverse of grad_phi (maps dual to primal)
        theta0: Initial parameters
        step_sizes: Step sizes
        max_iter: Maximum iterations

    Returns:
        (trajectory, losses)
    """
    theta = theta0.copy()
    trajectory = [theta.copy()]
    losses = [loss_fn(theta)]

    for t in range(min(max_iter, len(step_sizes))):
        dual = grad_phi(theta)
        g = grad_loss(theta)
        dual_next = dual - step_sizes[t] * g
        theta = grad_phi_inv(dual_next)
        trajectory.append(theta.copy())
        losses.append(loss_fn(theta))

    return trajectory, losses


def condition_number(matrix: Matrix) -> float:
    """Compute condition number κ = λ_max / λ_min."""
    eigenvalues = np.linalg.eigvalsh(matrix)
    return float(eigenvalues[-1] / eigenvalues[0])


def alpha_divergence(p: Vector, q: Vector, alpha: float) -> float:
    """Compute α-divergence D_α(p || q).

    D_α(p||q) = (4/(1-α²)) (1 - ∫ p^{(1+α)/2} q^{(1-α)/2})

    For discrete distributions (probability vectors).
    """
    if abs(alpha - 1.0) < 1e-10:
        # KL divergence
        mask = p > 0
        return float(np.sum(p[mask] * np.log(p[mask] / q[mask])))
    elif abs(alpha + 1.0) < 1e-10:
        # Reverse KL
        mask = q > 0
        return float(np.sum(q[mask] * np.log(q[mask] / p[mask])))
    else:
        a = (1 + alpha) / 2
        b = (1 - alpha) / 2
        integral = np.sum(p**a * q**b)
        return float(4.0 / (1.0 - alpha**2) * (1.0 - integral))


if __name__ == "__main__":
    # Quick test: natural gradient on a 2D quadratic with bad conditioning
    A = np.array([[100.0, 0.0], [0.0, 1.0]])  # condition number 100

    def loss(theta: Vector) -> float:
        return 0.5 * theta @ A @ theta

    def grad(theta: Vector) -> Vector:
        return A @ theta

    def fisher(theta: Vector) -> Matrix:
        return A  # For quadratic, Fisher = Hessian

    theta0 = np.array([1.0, 1.0])

    # Natural gradient: should converge in 1 step (since G=A, G^{-1}A = I)
    eta = [1.0] * 10
    traj_nat, losses_nat = natural_gradient_descent(loss, grad, fisher, theta0, eta, 10)

    # Standard GD: slow due to condition number
    eta_std = [0.005] * 200  # small step size needed for stability
    traj_std, losses_std = standard_gradient_descent(loss, grad, theta0, eta_std, 200)

    print("=== Natural Gradient vs Standard GD ===")
    print(f"Initial loss: {losses_nat[0]:.4f}")
    print(f"Natural GD after 1 step: {losses_nat[1]:.6f}")
    print(f"Standard GD after 10 steps: {losses_std[10]:.4f}")
    print(f"Standard GD after 100 steps: {losses_std[100]:.4f}")
    print(f"Condition number: {condition_number(A):.0f}")
