#!/usr/bin/env python3
"""
Neural Network Training as Renormalization Group Flow — Algorithms

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import Callable, List, Tuple, Optional
import numpy as np


# ═══════════════════════════════════════════════════════════════════════════════
# Core Data Structures
# ═══════════════════════════════════════════════════════════════════════════════

class NeuralRGFlow:
    """A discrete RG flow on parameter space."""

    def __init__(self, step: Callable[[np.ndarray], np.ndarray], scale: float):
        assert scale > 0, "Scale (learning rate) must be positive"
        self.step = step
        self.scale = scale

    def iterate(self, theta: np.ndarray, k: int) -> np.ndarray:
        """Apply k steps of the RG flow."""
        for _ in range(k):
            theta = self.step(theta)
        return theta

    def beta_function(self, theta: np.ndarray) -> np.ndarray:
        """Compute the beta function β(θ) = step(θ) - θ."""
        return self.step(theta) - theta

    def is_fixed_point(self, theta: np.ndarray, tol: float = 1e-10) -> bool:
        """Check if θ is a fixed point (β(θ) ≈ 0)."""
        return float(np.max(np.abs(self.beta_function(theta)))) < tol


class QuadraticLoss1D:
    """1D quadratic loss L(w) = (1/2)a·w² - b·w with a > 0."""

    def __init__(self, a: float, b: float):
        assert a > 0, "Hessian coefficient must be positive"
        self.a = a
        self.b = b

    @property
    def fixed_point(self) -> float:
        """The unique fixed point w* = b/a."""
        return self.b / self.a

    def gradient(self, w: float) -> float:
        """∇L(w) = aw - b."""
        return self.a * w - self.b

    def sgd_step(self, eta: float, w: float) -> float:
        """One SGD step: w ↦ w - η(aw - b) = (1-ηa)w + ηb."""
        return w - eta * self.gradient(w)

    def contraction_factor(self, eta: float) -> float:
        """The contraction factor |1 - ηa|."""
        return abs(1 - eta * self.a)

    def spectral_gap(self, eta: float) -> float:
        """Spectral gap = contraction factor."""
        return self.contraction_factor(eta)

    def critical_exponent(self, eta: float) -> float:
        """Critical exponent ν = -1/log|1 - ηa|."""
        gap = self.spectral_gap(eta)
        if gap <= 0 or gap >= 1:
            return float('inf')
        return -1.0 / np.log(gap)

    def optimal_learning_rate(self) -> float:
        """Optimal η* = 1/a for one-step convergence."""
        return 1.0 / self.a

    def trajectory(self, eta: float, w0: float, n_steps: int) -> List[float]:
        """Run SGD for n_steps and return full trajectory."""
        traj = [w0]
        w = w0
        for _ in range(n_steps):
            w = self.sgd_step(eta, w)
            traj.append(w)
        return traj

    def to_rg_flow(self, eta: float) -> NeuralRGFlow:
        """Convert to a NeuralRGFlow."""
        def step(w: np.ndarray) -> np.ndarray:
            return w - eta * (self.a * w - self.b)
        return NeuralRGFlow(step, eta)


class QuadraticLossND:
    """N-dimensional quadratic loss L(θ) = (1/2)θᵀAθ - bᵀθ."""

    def __init__(self, hessian: np.ndarray, lin_coeff: np.ndarray):
        self.hessian = hessian
        self.lin_coeff = lin_coeff
        self.dim = len(lin_coeff)

    def gradient(self, theta: np.ndarray) -> np.ndarray:
        """∇L(θ) = Aθ - b."""
        return self.hessian @ theta - self.lin_coeff

    def sgd_step(self, eta: float, theta: np.ndarray) -> np.ndarray:
        """θ ↦ θ - η∇L(θ)."""
        return theta - eta * self.gradient(theta)

    def trajectory(self, eta: float, theta0: np.ndarray, n_steps: int) -> List[np.ndarray]:
        """Run SGD for n_steps."""
        traj = [theta0.copy()]
        theta = theta0.copy()
        for _ in range(n_steps):
            theta = self.sgd_step(eta, theta)
            traj.append(theta.copy())
        return traj


class MomentumSGDState:
    """State for momentum SGD: (parameters, velocity)."""

    def __init__(self, params: np.ndarray, velocity: np.ndarray):
        self.params = params.copy()
        self.velocity = velocity.copy()


def momentum_sgd_step(
    grad: Callable[[np.ndarray], np.ndarray],
    eta: float,
    mu: float,
    state: MomentumSGDState
) -> MomentumSGDState:
    """One step of momentum SGD.

    v_{t+1} = μv_t + ∇L(θ_t)
    θ_{t+1} = θ_t - η·v_{t+1}
    """
    g = grad(state.params)
    new_velocity = mu * state.velocity + g
    new_params = state.params - eta * new_velocity
    return MomentumSGDState(new_params, new_velocity)


# ═══════════════════════════════════════════════════════════════════════════════
# Universality Class Detection
# ═══════════════════════════════════════════════════════════════════════════════

def same_universality_class(
    L1: QuadraticLoss1D,
    L2: QuadraticLoss1D,
    tol: float = 1e-10
) -> bool:
    """Check if two 1D quadratic losses are in the same universality class."""
    return abs(L1.a - L2.a) < tol and abs(L1.b - L2.b) < tol


def classify_universality(
    losses: List[QuadraticLoss1D],
    tol: float = 1e-10
) -> List[List[int]]:
    """Partition a list of losses into universality classes."""
    n = len(losses)
    visited = [False] * n
    classes: List[List[int]] = []

    for i in range(n):
        if visited[i]:
            continue
        current_class = [i]
        visited[i] = True
        for j in range(i + 1, n):
            if not visited[j] and same_universality_class(losses[i], losses[j], tol):
                current_class.append(j)
                visited[j] = True
        classes.append(current_class)

    return classes


# ═══════════════════════════════════════════════════════════════════════════════
# k-fold RG
# ═══════════════════════════════════════════════════════════════════════════════

def kfold_rg(flow: NeuralRGFlow, k: int) -> NeuralRGFlow:
    """Compose k steps of an RG flow into a single coarse-grained step."""
    assert k > 0, "k must be positive"

    def kstep(theta: np.ndarray) -> np.ndarray:
        result = theta
        for _ in range(k):
            result = flow.step(result)
        return result

    return NeuralRGFlow(kstep, k * flow.scale)


# ═══════════════════════════════════════════════════════════════════════════════
# Two-Layer Linear Network
# ═══════════════════════════════════════════════════════════════════════════════

class TwoLayerLinear:
    """Two-layer linear network f(x) = vᵀ(Wx)."""

    def __init__(self, W: np.ndarray, v: np.ndarray):
        self.W = W.copy()
        self.v = v.copy()
        self.m, self.d = W.shape

    def effective_weight(self) -> np.ndarray:
        """Compute effective weight w_eff = vᵀW."""
        return self.v @ self.W

    def forward(self, x: np.ndarray) -> float:
        """Compute f(x) = vᵀ(Wx)."""
        return float(self.v @ (self.W @ x))

    def gauge_transform(self, c: float) -> 'TwoLayerLinear':
        """Apply gauge transformation: W → cW, v → v/c."""
        assert c != 0
        return TwoLayerLinear(c * self.W, self.v / c)


# ═══════════════════════════════════════════════════════════════════════════════
# Wilson-Fisher Exponent
# ═══════════════════════════════════════════════════════════════════════════════

def wilson_fisher_exponent(d: int) -> float:
    """Compute the mean-field Wilson-Fisher exponent ν = 1/(d-2)."""
    if d <= 2:
        return float('inf')  # Diverges at or below d=2
    return 1.0 / (d - 2)


def sgd_critical_exponent(sigma_sq: float, eta: float) -> float:
    """Compute the SGD critical exponent for 1D linear regression.

    ν_SGD = -1/log|1 - η·σ²|
    """
    gap = abs(1 - eta * sigma_sq)
    if gap <= 0 or gap >= 1:
        return float('inf')
    return -1.0 / np.log(gap)


# ═══════════════════════════════════════════════════════════════════════════════
# RG Scaling Relation
# ═══════════════════════════════════════════════════════════════════════════════

def verify_rg_scaling(
    L: QuadraticLoss1D,
    eta: float,
    s: float,
    w: float,
    tol: float = 1e-12
) -> bool:
    """Verify the RG scaling relation: β(s·η, w) = s·β(η, w)."""
    beta_scaled = L.sgd_step(s * eta, w) - w
    beta_original = s * (L.sgd_step(eta, w) - w)
    return abs(beta_scaled - beta_original) < tol


if __name__ == "__main__":
    # Quick test
    L = QuadraticLoss1D(2.0, 3.0)
    print(f"Fixed point: {L.fixed_point}")
    print(f"Optimal lr: {L.optimal_learning_rate()}")
    print(f"One step at optimal lr: {L.sgd_step(L.optimal_learning_rate(), 100.0)}")

    traj = L.trajectory(0.3, 10.0, 10)
    print(f"Trajectory: {[f'{w:.4f}' for w in traj]}")

    print(f"RG scaling verified: {verify_rg_scaling(L, 0.3, 2.5, 5.0)}")
