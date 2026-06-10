#!/usr/bin/env python3
"""
Information Geometry: Core Algorithms
======================================

Implements the computational backbone of information geometry for finite
exponential families:

- Fisher information matrix computation
- Natural gradient computation
- Cramér–Rao lower bounds
- Log-partition function and its derivatives
- Alpha-connection Christoffel symbols
- Amari–Chentsov tensor
"""

import numpy as np
from numpy.linalg import inv, eigvalsh, det
from typing import Tuple, Optional


class FiniteExponentialFamily:
    """
    An exponential family on a finite sample space.

    p_θ(ω) = exp(⟨θ, T(ω)⟩ + k(ω) − ψ(θ))

    Parameters
    ----------
    sufficient_stat : np.ndarray, shape (|Ω|, n)
        Matrix of sufficient statistics T(ω) for each outcome.
    base_measure : np.ndarray, shape (|Ω|,)
        Log base measure k(ω) for each outcome.

    Example
    -------
    >>> # Bernoulli family
    >>> T = np.array([[0.0], [1.0]])
    >>> k = np.array([0.0, 0.0])
    >>> model = FiniteExponentialFamily(T, k)
    >>> model.pmf(np.array([1.0]))
    array([0.26894142, 0.73105858])
    """

    def __init__(self, sufficient_stat: np.ndarray, base_measure: np.ndarray):
        self.T = np.asarray(sufficient_stat, dtype=float)
        self.k = np.asarray(base_measure, dtype=float)
        self.num_outcomes = self.T.shape[0]
        self.dim = self.T.shape[1] if self.T.ndim > 1 else 1
        if self.T.ndim == 1:
            self.T = self.T.reshape(-1, 1)

    def _exponents(self, theta: np.ndarray) -> np.ndarray:
        """Raw exponents: ⟨θ, T(ω)⟩ + k(ω)"""
        return self.T @ theta + self.k

    def log_partition(self, theta: np.ndarray) -> float:
        """
        Log-partition function ψ(θ) = log Σ_ω exp(⟨θ, T(ω)⟩ + k(ω)).

        Uses log-sum-exp trick for numerical stability.

        Time complexity: O(|Ω| · n)
        """
        exponents = self._exponents(theta)
        max_exp = exponents.max()
        return float(np.log(np.sum(np.exp(exponents - max_exp))) + max_exp)

    def pmf(self, theta: np.ndarray) -> np.ndarray:
        """
        Probability mass function p_θ(ω).

        Time complexity: O(|Ω| · n)
        """
        exponents = self._exponents(theta)
        max_exp = exponents.max()
        unnormalized = np.exp(exponents - max_exp)
        return unnormalized / unnormalized.sum()

    def expectation_parameter(self, theta: np.ndarray) -> np.ndarray:
        """
        Expectation parameter η(θ) = E_θ[T] = ∇ψ(θ).

        This is the gradient of the log-partition function,
        connecting statistics to convex geometry via Legendre duality.

        Time complexity: O(|Ω| · n)
        """
        p = self.pmf(theta)
        return self.T.T @ p

    def fisher_matrix(self, theta: np.ndarray) -> np.ndarray:
        """
        Fisher information matrix I(θ) = Cov_θ(T).

        Computed as I_{ij} = E[T_i T_j] − E[T_i]E[T_j],
        which equals the Hessian ∇²ψ(θ) of the log-partition function.

        Properties (proven in Lean):
        - Symmetric: I(θ) = I(θ)ᵀ
        - Positive semidefinite: vᵀI(θ)v ≥ 0 for all v

        Time complexity: O(|Ω| · n²)
        Space complexity: O(n²)
        """
        p = self.pmf(theta)
        eta = self.T.T @ p
        centered = self.T - eta[np.newaxis, :]
        return (centered.T * p) @ centered

    def score(self, theta: np.ndarray) -> np.ndarray:
        """
        Score matrix: s_i(θ, ω) = T_i(ω) − η_i(θ) for each ω.

        Returns shape (|Ω|, n). The score has mean zero: E_θ[s(θ,·)] = 0.

        Time complexity: O(|Ω| · n)
        """
        eta = self.expectation_parameter(theta)
        return self.T - eta[np.newaxis, :]

    def cramer_rao_bound(self, theta: np.ndarray,
                         grad_g: np.ndarray) -> float:
        """
        Cramér–Rao lower bound for an unbiased estimator of g(θ).

        CR bound = ∇g(θ)ᵀ I(θ)⁻¹ ∇g(θ)

        The directional version (proven in Lean): for any direction v,
        (Dg[v])² ≤ Var(T) · vᵀI(θ)v.

        Parameters
        ----------
        theta : parameter value
        grad_g : gradient ∇g(θ) of the estimand

        Returns
        -------
        float : lower bound on variance of any unbiased estimator of g

        Time complexity: O(n³) for matrix inversion
        """
        I = self.fisher_matrix(theta)
        return float(grad_g @ inv(I) @ grad_g)

    def natural_gradient(self, theta: np.ndarray,
                         euclidean_grad: np.ndarray) -> np.ndarray:
        """
        Natural gradient: ĝ = I(θ)⁻¹ ∇f(θ).

        The natural gradient accounts for the Riemannian geometry of the
        statistical model, giving parameterization-invariant descent.

        Time complexity: O(n³) for matrix inversion
        """
        I = self.fisher_matrix(theta)
        return inv(I) @ euclidean_grad

    def amari_chentsov_tensor(self, theta: np.ndarray) -> np.ndarray:
        """
        Amari–Chentsov cubic tensor C_{ijk}(θ) = E_θ[s_i s_j s_k].

        This is the third central moment of the sufficient statistic.

        Returns shape (n, n, n).

        Time complexity: O(|Ω| · n³)
        """
        p = self.pmf(theta)
        s = self.score(theta)  # (|Ω|, n)
        n = self.dim
        C = np.zeros((n, n, n))
        for omega_idx in range(self.num_outcomes):
            s_om = s[omega_idx]
            C += p[omega_idx] * np.einsum('i,j,k', s_om, s_om, s_om)
        return C

    def alpha_christoffel(self, theta: np.ndarray, alpha: float,
                          levi_civita: Optional[np.ndarray] = None) -> np.ndarray:
        """
        Alpha-Christoffel symbols Γ^(α)_{ijk} = Γ^(0)_{ijk} + (α/2)C_{ijk}.

        For exponential families in natural coordinates, the Levi-Civita
        symbols Γ^(0) = -(1/2)C, so:
        - α = +1: Γ^(+1) = 0 (e-flat)
        - α = -1: Γ^(-1) = -C (m-connection)
        - α = 0:  Γ^(0) = -(1/2)C (Levi-Civita)

        Time complexity: O(|Ω| · n³)
        """
        C = self.amari_chentsov_tensor(theta)
        if levi_civita is None:
            levi_civita = -0.5 * C
        return levi_civita + (alpha / 2) * C

    def hessian_log_partition(self, theta: np.ndarray,
                              eps: float = 1e-5) -> np.ndarray:
        """
        Numerical Hessian of the log-partition function ∇²ψ(θ).

        Should equal the Fisher matrix (proven in Lean for exponential families).

        Time complexity: O(n² · |Ω| · n) with numerical differentiation
        """
        n = len(theta)
        H = np.zeros((n, n))
        for i in range(n):
            for j in range(i, n):
                ei = np.zeros(n); ei[i] = eps
                ej = np.zeros(n); ej[j] = eps
                H[i, j] = (self.log_partition(theta + ei + ej)
                           - self.log_partition(theta + ei - ej)
                           - self.log_partition(theta - ei + ej)
                           + self.log_partition(theta - ei - ej)) / (4*eps**2)
                H[j, i] = H[i, j]
        return H

    def is_psd(self, theta: np.ndarray) -> bool:
        """Check if Fisher matrix is positive semidefinite."""
        return bool(np.all(eigvalsh(self.fisher_matrix(theta)) >= -1e-12))


def natural_gradient_descent(model: FiniteExponentialFamily,
                             theta_init: np.ndarray,
                             loss_fn,
                             loss_grad_fn,
                             lr: float = 0.1,
                             n_steps: int = 100) -> Tuple[np.ndarray, list]:
    """
    Natural gradient descent on a finite exponential family.

    Pseudocode:
        θ ← θ_init
        for t = 1 to n_steps:
            g ← ∇loss(θ)
            ĝ ← I(θ)⁻¹ g           # natural gradient
            θ ← θ − lr · ĝ

    Parameters
    ----------
    model : FiniteExponentialFamily
    theta_init : initial parameter
    loss_fn : callable θ → ℝ
    loss_grad_fn : callable θ → ℝⁿ (Euclidean gradient)
    lr : learning rate
    n_steps : number of iterations

    Returns
    -------
    theta_final, loss_history

    Convergence: Under regularity, natural gradient descent achieves
    asymptotically optimal convergence rate (Fisher-efficient).

    Time complexity per step: O(n³ + |Ω|·n²)
    Space complexity: O(n² + |Ω|·n)
    """
    theta = theta_init.copy()
    losses = [loss_fn(theta)]
    for _ in range(n_steps):
        g = loss_grad_fn(theta)
        ng = model.natural_gradient(theta, g)
        theta = theta - lr * ng
        losses.append(loss_fn(theta))
    return theta, losses


# ── Example usage ────────────────────────────────────────────

if __name__ == "__main__":
    # Trinomial exponential family
    T = np.array([[0, 0], [1, 0], [0, 1]], dtype=float)
    k = np.zeros(3)
    model = FiniteExponentialFamily(T, k)

    theta = np.array([0.5, -0.3])

    print("Exponential Family Model")
    print(f"  |Ω| = {model.num_outcomes}, dim = {model.dim}")
    print(f"  θ = {theta}")
    print(f"  pmf = {model.pmf(theta)}")
    print(f"  ψ(θ) = {model.log_partition(theta):.6f}")
    print(f"  η(θ) = {model.expectation_parameter(theta)}")
    print()

    I = model.fisher_matrix(theta)
    print(f"Fisher matrix:\n{I}")
    print(f"  Symmetric: {np.allclose(I, I.T)}")
    print(f"  PSD: {model.is_psd(theta)}")
    print(f"  det(I) = {det(I):.6f}")
    print()

    # Cramér–Rao bound
    grad_g = np.array([1.0, 0.0])  # estimating η₁
    cr = model.cramer_rao_bound(theta, grad_g)
    print(f"CR bound for η₁: {cr:.6f}")
    print()

    # Amari–Chentsov tensor
    C = model.amari_chentsov_tensor(theta)
    print(f"Amari–Chentsov tensor C shape: {C.shape}")
    print(f"  C[0,0,0] = {C[0,0,0]:.6f}")
    print(f"  C[0,0,1] = {C[0,0,1]:.6f}")
    print()

    # Alpha-Christoffel symbols
    Gamma_plus = model.alpha_christoffel(theta, 1.0)
    Gamma_minus = model.alpha_christoffel(theta, -1.0)
    print(f"+1 Christoffel (should be ≈ 0): max |Γ⁺| = {np.max(np.abs(Gamma_plus)):.2e}")
    print(f"−1 Christoffel: max |Γ⁻| = {np.max(np.abs(Gamma_minus)):.6f}")

    # Fisher = Hessian of log-partition
    H = model.hessian_log_partition(theta)
    print(f"\nFisher vs Hessian(ψ) max diff: {np.max(np.abs(I - H)):.2e}")
