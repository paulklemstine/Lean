#!/usr/bin/env python3
"""
algorithms.py — Natural Gradient Optimization Algorithms

Implements the core optimization algorithms from the formal convergence theory:

1. NaturalGradientDescent: Natural gradient with arbitrary step schedules
2. AcceleratedDualNGD: Nesterov-accelerated natural gradient in dual coordinates
3. MirrorDescent: Generic mirror descent with Bregman divergence
4. ExponentialFamilyModel: Base class for finite exponential families

Each algorithm includes convergence monitoring and Bregman Lyapunov tracking.

Complexity Analysis:
- Per-iteration cost: O(d^2) for Fisher matrix computation, O(d^3) for inversion
- Memory: O(d^2) for Fisher matrix storage
- Convergence: O(log(t)/t) for NGD with harmonic steps (proved formally)
"""

import numpy as np
from abc import ABC, abstractmethod
from typing import Callable, Optional, Tuple, List, Dict
from dataclasses import dataclass


@dataclass
class OptimizationResult:
    """Result of an optimization run."""
    thetas: List[np.ndarray]
    losses: List[float]
    bregman_divs: List[float]
    excess_losses: List[float]
    convergence_exponent: float
    num_iterations: int


class ExponentialFamilyModel(ABC):
    """Abstract base class for finite exponential families.
    
    An exponential family has the form:
        p_theta(omega) = exp(<theta, T(omega)> - psi(theta) + k(omega))
    where:
        - theta: natural parameters
        - T: sufficient statistics
        - psi: log-partition function (convex)
        - k: base measure log-density
    """
    
    @abstractmethod
    def log_partition(self, theta: np.ndarray) -> float:
        """Log-partition function psi(theta)."""
        pass
    
    @abstractmethod
    def grad_log_partition(self, theta: np.ndarray) -> np.ndarray:
        """Gradient of psi = expectation parameters eta."""
        pass
    
    @abstractmethod
    def fisher_matrix(self, theta: np.ndarray) -> np.ndarray:
        """Fisher information matrix I(theta) = Hess psi(theta)."""
        pass
    
    def bregman_divergence(self, theta_star: np.ndarray, theta: np.ndarray) -> float:
        """Bregman divergence D_psi(theta_star, theta).
        
        D_psi(x, y) = psi(x) - psi(y) - <grad psi(y), x - y>
        """
        psi_star = self.log_partition(theta_star)
        psi = self.log_partition(theta)
        grad_psi = self.grad_log_partition(theta)
        return psi_star - psi - grad_psi @ (theta_star - theta)
    
    @property
    @abstractmethod
    def dim(self) -> int:
        """Dimension of the natural parameter space."""
        pass


class MultinomialFamily(ExponentialFamilyModel):
    """Multinomial (categorical) exponential family on K categories.
    
    Natural parameters: theta in R^{K-1}
    Sufficient statistics: T(omega) = e_{omega} for omega < K, 0 for omega = K
    Log-partition: psi(theta) = log(sum_{j<K} exp(theta_j) + 1)
    
    Args:
        K: Number of categories (dimension = K-1)
    """
    
    def __init__(self, K: int = 3):
        self.K = K
        self._dim = K - 1
    
    @property
    def dim(self) -> int:
        return self._dim
    
    def log_partition(self, theta: np.ndarray) -> float:
        m = max(np.max(theta), 0.0)
        return m + np.log(np.sum(np.exp(theta - m)) + np.exp(-m))
    
    def grad_log_partition(self, theta: np.ndarray) -> np.ndarray:
        return self._softmax(theta)
    
    def fisher_matrix(self, theta: np.ndarray) -> np.ndarray:
        p = self._softmax(theta)
        return np.diag(p) - np.outer(p, p)
    
    def _softmax(self, theta: np.ndarray) -> np.ndarray:
        log_unnorm = np.concatenate([theta, [0.0]])
        log_unnorm -= log_unnorm.max()
        unnorm = np.exp(log_unnorm)
        probs = unnorm / unnorm.sum()
        return probs[:self._dim]
    
    def full_probs(self, theta: np.ndarray) -> np.ndarray:
        """Full probability vector including last category."""
        log_unnorm = np.concatenate([theta, [0.0]])
        log_unnorm -= log_unnorm.max()
        unnorm = np.exp(log_unnorm)
        return unnorm / unnorm.sum()


class NaturalGradientDescent:
    """Natural gradient descent with configurable step schedule.
    
    Update rule:
        theta_{t+1} = theta_t - alpha_t * I(theta_t)^{-1} * grad_L(theta_t)
    
    Convergence guarantee (formally proved):
        With alpha_t = 1/(t+1) and relative smoothness constant A:
            t * (L(theta_t) - L*) <= B + A * H(t)
        where H(t) = sum_{k=1}^{t} 1/k ~ ln(t).
    
    Args:
        model: Exponential family model
        loss_fn: Loss function theta -> R
        grad_loss_fn: Gradient of loss in natural coordinates
        step_schedule: Function t -> alpha_t (default: harmonic 1/(t+1))
    """
    
    def __init__(self,
                 model: ExponentialFamilyModel,
                 loss_fn: Callable[[np.ndarray], float],
                 grad_loss_fn: Callable[[np.ndarray], np.ndarray],
                 step_schedule: Optional[Callable[[int], float]] = None):
        self.model = model
        self.loss_fn = loss_fn
        self.grad_loss_fn = grad_loss_fn
        self.step_schedule = step_schedule or (lambda t: 1.0 / (t + 1))
    
    def optimize(self, theta0: np.ndarray, T: int,
                 theta_star: Optional[np.ndarray] = None) -> OptimizationResult:
        """Run T iterations of natural gradient descent.
        
        Time complexity: O(T * d^3) where d = model.dim
        Space complexity: O(T * d) for storing trajectory
        """
        theta = theta0.copy()
        thetas = [theta.copy()]
        losses = [self.loss_fn(theta)]
        
        L_star = self.loss_fn(theta_star) if theta_star is not None else 0.0
        bregman_divs = [self.model.bregman_divergence(theta_star, theta)
                        if theta_star is not None else 0.0]
        
        for t in range(T):
            alpha = self.step_schedule(t)
            F = self.model.fisher_matrix(theta)
            g = self.grad_loss_fn(theta)
            
            try:
                nat_grad = np.linalg.solve(F, g)
            except np.linalg.LinAlgError:
                nat_grad = np.linalg.lstsq(F, g, rcond=None)[0]
            
            theta = theta - alpha * nat_grad
            thetas.append(theta.copy())
            losses.append(self.loss_fn(theta))
            
            if theta_star is not None:
                bregman_divs.append(self.model.bregman_divergence(theta_star, theta))
        
        excess = [l - L_star for l in losses]
        gamma = self._estimate_exponent(excess)
        
        return OptimizationResult(
            thetas=thetas, losses=losses, bregman_divs=bregman_divs,
            excess_losses=excess, convergence_exponent=gamma,
            num_iterations=T
        )
    
    @staticmethod
    def _estimate_exponent(excess: List[float], start: int = 10) -> float:
        arr = np.array(excess[start:])
        arr = np.maximum(arr, 1e-15)
        ts = np.arange(start, start + len(arr), dtype=float)
        mask = arr > 1e-14
        if mask.sum() < 5:
            return float('inf')
        log_t = np.log(ts[mask])
        log_l = np.log(arr[mask])
        A = np.vstack([log_t, np.ones_like(log_t)]).T
        slope = np.linalg.lstsq(A, log_l, rcond=None)[0][0]
        return -slope


class AcceleratedDualNGD:
    """Accelerated natural gradient in dual (expectation) coordinates.
    
    This implements Nesterov-type acceleration in the η-coordinate system,
    exploiting the dually flat structure of exponential families.
    
    Update rule:
        eta_{t+1} = y_t - alpha_t * grad_eta L_eta(y_t)
        y_{t+1} = eta_{t+1} + beta_t * (eta_{t+1} - eta_t)
    
    where alpha_t and beta_t are chosen for O(1/t^2) convergence.
    
    Args:
        model: Multinomial exponential family
        dual_loss_fn: Loss in eta coordinates
        dual_grad_fn: Gradient of loss in eta coordinates
    """
    
    def __init__(self,
                 model: MultinomialFamily,
                 dual_loss_fn: Callable[[np.ndarray], float],
                 dual_grad_fn: Callable[[np.ndarray], np.ndarray]):
        self.model = model
        self.dual_loss_fn = dual_loss_fn
        self.dual_grad_fn = dual_grad_fn
    
    def optimize(self, theta0: np.ndarray, T: int,
                 theta_star: Optional[np.ndarray] = None) -> OptimizationResult:
        """Run T iterations of accelerated dual NGD.
        
        Time complexity: O(T * d)
        Space complexity: O(T * d)
        """
        eta = self.model.grad_log_partition(theta0)
        etas = [eta.copy()]
        y = eta.copy()
        eta_prev = eta.copy()
        
        L_star = (self.dual_loss_fn(self.model.grad_log_partition(theta_star))
                  if theta_star is not None else 0.0)
        losses = [self.dual_loss_fn(eta)]
        bregman_divs = [self.model.bregman_divergence(theta_star, theta0)
                        if theta_star is not None else 0.0]
        thetas = [theta0.copy()]
        
        for t in range(T):
            alpha = 2.0 / (t + 2)
            beta = t / (t + 3.0)
            
            g = self.dual_grad_fn(y)
            eta_new = y - alpha * g
            
            # Project to valid domain
            eta_new = np.clip(eta_new, 1e-10, None)
            if eta_new.sum() >= 1 - 1e-10:
                eta_new *= (1 - 2e-10) / eta_new.sum()
            
            y = eta_new + beta * (eta_new - eta_prev)
            y = np.clip(y, 1e-10, None)
            if y.sum() >= 1 - 1e-10:
                y *= (1 - 2e-10) / y.sum()
            
            eta_prev = eta_new.copy()
            etas.append(eta_new.copy())
            losses.append(self.dual_loss_fn(eta_new))
            
            # Reconstruct theta
            p_last = max(1 - eta_new.sum(), 1e-10)
            theta_rec = np.log(eta_new / p_last)
            thetas.append(theta_rec.copy())
            
            if theta_star is not None:
                bregman_divs.append(self.model.bregman_divergence(theta_star, theta_rec))
        
        excess = [l - L_star for l in losses]
        gamma = NaturalGradientDescent._estimate_exponent(excess)
        
        return OptimizationResult(
            thetas=thetas, losses=losses, bregman_divs=bregman_divs,
            excess_losses=excess, convergence_exponent=gamma,
            num_iterations=T
        )


class MirrorDescent:
    """Generic mirror descent with Bregman divergence.
    
    Update:
        theta_{t+1} = argmin_theta { alpha_t * <g_t, theta> + D_psi(theta, theta_t) }
    
    Equivalent to: eta_{t+1} = eta_t - alpha_t * g_t in dual coordinates.
    
    Args:
        model: Exponential family (defines Bregman geometry)
        loss_fn: Loss function
        grad_loss_fn: Gradient of loss
        step_schedule: Step sizes
    """
    
    def __init__(self,
                 model: ExponentialFamilyModel,
                 loss_fn: Callable[[np.ndarray], float],
                 grad_loss_fn: Callable[[np.ndarray], np.ndarray],
                 step_schedule: Optional[Callable[[int], float]] = None):
        self.model = model
        self.loss_fn = loss_fn
        self.grad_loss_fn = grad_loss_fn
        self.step_schedule = step_schedule or (lambda t: 1.0 / (t + 1))
    
    def optimize(self, theta0: np.ndarray, T: int,
                 theta_star: Optional[np.ndarray] = None) -> OptimizationResult:
        """Run mirror descent.
        
        For exponential families, this is implemented via the dual update:
            eta_{t+1} = eta_t - alpha_t * grad_theta L(theta_t)
        then mapping back: theta_{t+1} = (grad psi)^{-1}(eta_{t+1}).
        """
        theta = theta0.copy()
        eta = self.model.grad_log_partition(theta)
        
        thetas = [theta.copy()]
        losses = [self.loss_fn(theta)]
        L_star = self.loss_fn(theta_star) if theta_star is not None else 0.0
        bregman_divs = [self.model.bregman_divergence(theta_star, theta)
                        if theta_star is not None else 0.0]
        
        for t in range(T):
            alpha = self.step_schedule(t)
            g = self.grad_loss_fn(theta)
            
            # Mirror descent update in dual coordinates
            eta = eta - alpha * g
            
            # Map back to primal (for multinomial)
            eta_clipped = np.clip(eta, 1e-10, None)
            if eta_clipped.sum() >= 1 - 1e-10:
                eta_clipped *= (1 - 2e-10) / eta_clipped.sum()
            
            p_last = max(1 - eta_clipped.sum(), 1e-10)
            theta = np.log(eta_clipped / p_last)
            eta = self.model.grad_log_partition(theta)
            
            thetas.append(theta.copy())
            losses.append(self.loss_fn(theta))
            if theta_star is not None:
                bregman_divs.append(self.model.bregman_divergence(theta_star, theta))
        
        excess = [l - L_star for l in losses]
        gamma = NaturalGradientDescent._estimate_exponent(excess)
        
        return OptimizationResult(
            thetas=thetas, losses=losses, bregman_divs=bregman_divs,
            excess_losses=excess, convergence_exponent=gamma,
            num_iterations=T
        )


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("Algorithms module — example usage\n")
    
    model = MultinomialFamily(K=3)
    
    theta_star = np.array([0.3, -0.2])
    eta_star = model.grad_log_partition(theta_star)
    
    loss = lambda th: 0.5 * np.sum((model.grad_log_partition(th) - eta_star)**2)
    grad_loss = lambda th: model.fisher_matrix(th) @ (model.grad_log_partition(th) - eta_star)
    dual_loss = lambda eta: 0.5 * np.sum((eta - eta_star)**2)
    dual_grad = lambda eta: eta - eta_star
    
    theta0 = np.array([1.0, -1.0])
    T = 200
    
    ngd = NaturalGradientDescent(model, loss, grad_loss)
    result_ngd = ngd.optimize(theta0, T, theta_star)
    print(f"Natural GD:      γ = {result_ngd.convergence_exponent:.3f}, "
          f"final excess = {result_ngd.excess_losses[-1]:.2e}")
    
    acc = AcceleratedDualNGD(model, dual_loss, dual_grad)
    result_acc = acc.optimize(theta0, T, theta_star)
    print(f"Accelerated NGD: γ = {result_acc.convergence_exponent:.3f}, "
          f"final excess = {result_acc.excess_losses[-1]:.2e}")
    
    md = MirrorDescent(model, loss, grad_loss)
    result_md = md.optimize(theta0, T, theta_star)
    print(f"Mirror Descent:  γ = {result_md.convergence_exponent:.3f}, "
          f"final excess = {result_md.excess_losses[-1]:.2e}")
