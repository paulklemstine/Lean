#!/usr/bin/env python3
"""
Tropical Kernel Learning: Core Algorithms

Implements the algorithms derived from the tropical representer theorem:
- Tropical Gram matrix computation
- Tropical kernel regression via coordinate descent
- Prediction from learned coefficients
- Robustness certification via monotonicity
"""

import numpy as np
from typing import Callable, Tuple, Optional


# =============================================================================
# Max-Plus Algebra Primitives
# =============================================================================

def maxplus_matvec(G: np.ndarray, c: np.ndarray) -> np.ndarray:
    """
    Tropical (max-plus) matrix-vector multiplication.
    result[i] = max_j (c[j] + G[j, i])

    This is the computational core of the representer theorem:
    predictions at sample points = tropical Gram action on coefficients.

    Args:
        G: n×n Gram matrix
        c: n-vector of coefficients
    Returns:
        n-vector of predictions
    """
    n = G.shape[0]
    result = np.full(n, -np.inf)
    for i in range(n):
        for j in range(n):
            result[i] = max(result[i], c[j] + G[j, i])
    return result


def maxplus_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (max-plus) matrix multiplication.
    result[i,j] = max_k (A[i,k] + B[k,j])
    """
    n, m = A.shape[0], B.shape[1]
    k = A.shape[1]
    result = np.full((n, m), -np.inf)
    for i in range(n):
        for j in range(m):
            for l in range(k):
                result[i, j] = max(result[i, j], A[i, l] + B[l, j])
    return result


# =============================================================================
# Kernel Functions
# =============================================================================

def tropical_gaussian_kernel(sigma: float = 1.0) -> Callable:
    """K(x, y) = -|x - y|² / σ"""
    return lambda x, y: -np.sum((np.asarray(x) - np.asarray(y))**2) / sigma


def tropical_laplacian_kernel(gamma: float = 1.0) -> Callable:
    """K(x, y) = -γ|x - y|"""
    return lambda x, y: -gamma * np.sum(np.abs(np.asarray(x) - np.asarray(y)))


def tropical_min_kernel() -> Callable:
    """K(x, y) = min(x, y) — the tropical analogue of the min kernel."""
    return lambda x, y: min(np.min(np.asarray(x)), np.min(np.asarray(y)))


# =============================================================================
# Gram Matrix
# =============================================================================

def compute_gram_matrix(K: Callable, x_samples: np.ndarray) -> np.ndarray:
    """
    Compute the tropical Gram matrix G[i,j] = K(x_i, x_j).

    By the Gram-matrix prediction identity (Theorem C), sample predictions
    of any tropical combination equal the tropical Gram action:
        eval_x(⊕_j c_j ⊗ K(x_j, ·)) = G ⊗ c

    Args:
        K: kernel function
        x_samples: array of sample points (n,) or (n, d)
    Returns:
        n×n Gram matrix
    """
    n = len(x_samples)
    G = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            G[i, j] = K(x_samples[i], x_samples[j])
    return G


# =============================================================================
# Tropical Kernel Regression
# =============================================================================

def tropical_kernel_regression(
    K: Callable,
    x_train: np.ndarray,
    y_train: np.ndarray,
    lam: float = 0.1,
    loss_type: str = "sup_abs",
    reg_type: str = "sup_abs",
    n_iters: int = 2000,
    lr: float = 0.01,
    verbose: bool = False
) -> Tuple[np.ndarray, float]:
    """
    Tropical kernel regression via coordinate descent.

    By the representer theorem, the optimal function has the form:
        f*(z) = max_i (c_i + K(x_i, z))
    so we optimize over coefficients c ∈ ℝⁿ.

    The objective is:
        F(c) = L(G ⊗ c, y) ⊔ (λ + Ω(c))
    where ⊔ = max, and L, Ω are chosen loss/regularizer.

    Args:
        K: kernel function
        x_train: training inputs
        y_train: training targets
        lam: regularization parameter (additive in max-plus)
        loss_type: "sup_abs" for max_i |pred_i - y_i|
        reg_type: "sup_abs" for max_i |c_i|
        n_iters: number of iterations
        lr: step size for coordinate perturbation
        verbose: print progress
    Returns:
        (optimal_coefficients, optimal_objective_value)
    """
    n = len(x_train)
    G = compute_gram_matrix(K, x_train)

    def compute_loss(pred: np.ndarray) -> float:
        if loss_type == "sup_abs":
            return np.max(np.abs(pred - y_train))
        elif loss_type == "sup":
            return np.max(pred - y_train)
        else:
            raise ValueError(f"Unknown loss type: {loss_type}")

    def compute_reg(c: np.ndarray) -> float:
        if reg_type == "sup_abs":
            return np.max(np.abs(c))
        elif reg_type == "sup":
            return np.max(c)
        else:
            raise ValueError(f"Unknown reg type: {reg_type}")

    def objective(c: np.ndarray) -> float:
        pred = maxplus_matvec(G, c)
        loss = compute_loss(pred)
        reg = lam + compute_reg(c)  # λ ⊗ Ω = λ + Ω in max-plus
        return max(loss, reg)  # tropical addition = max

    c = np.zeros(n)
    best_c = c.copy()
    best_obj = objective(c)

    for t in range(n_iters):
        improved = False
        for i in range(n):
            for delta in [lr, -lr, 2*lr, -2*lr, 0.5*lr, -0.5*lr]:
                c_new = c.copy()
                c_new[i] += delta
                obj_new = objective(c_new)
                if obj_new < best_obj - 1e-12:
                    best_obj = obj_new
                    best_c = c_new.copy()
                    c = c_new.copy()
                    improved = True

        if verbose and (t + 1) % 200 == 0:
            print(f"  Iter {t+1}: objective = {best_obj:.6f}")

        if not improved and lr > 1e-8:
            lr *= 0.5  # shrink step size

    return best_c, best_obj


# =============================================================================
# Prediction
# =============================================================================

def tropical_predict(
    K: Callable,
    x_train: np.ndarray,
    c: np.ndarray,
    z: np.ndarray
) -> np.ndarray:
    """
    Predict at new points using learned tropical combination.
    f(z) = max_i (c_i + K(x_i, z))

    Args:
        K: kernel function
        x_train: training points
        c: learned coefficients
        z: new points to predict at
    Returns:
        predictions at z
    """
    if z.ndim == 0:
        z = np.array([z])
    m = len(z)
    n = len(x_train)
    pred = np.full(m, -np.inf)
    for j in range(m):
        for i in range(n):
            pred[j] = max(pred[j], c[i] + K(x_train[i], z[j]))
    return pred


# =============================================================================
# Robustness Certification
# =============================================================================

def coefficient_perturbation_bound(
    G: np.ndarray,
    c: np.ndarray,
    epsilon: float
) -> np.ndarray:
    """
    Compute worst-case prediction change under ε-perturbation of coefficients.

    By the monotonicity theorem (Theorem 3.5), if c' ≥ c pointwise, then
    predictFromCoeff(G, c') ≥ predictFromCoeff(G, c) pointwise.

    Therefore, the worst-case prediction at each sample point under
    ‖Δc‖_∞ ≤ ε is bounded by:
        |pred(c + Δc) - pred(c)| ≤ ε   (in max-plus metric)

    Args:
        G: Gram matrix
        c: current coefficients
        epsilon: perturbation bound on coefficients
    Returns:
        per-sample prediction perturbation bounds
    """
    pred_c = maxplus_matvec(G, c)
    pred_upper = maxplus_matvec(G, c + epsilon)
    pred_lower = maxplus_matvec(G, c - epsilon)

    bounds = np.maximum(pred_upper - pred_c, pred_c - pred_lower)
    return bounds


def certify_robustness(
    G: np.ndarray,
    c: np.ndarray,
    y: np.ndarray,
    epsilon: float,
    margin: float
) -> bool:
    """
    Certify that predictions remain within margin of targets under
    ε-perturbation of coefficients.

    Returns True if for all ‖Δc‖_∞ ≤ ε:
        ‖pred(c + Δc) - y‖_∞ ≤ margin

    This is a direct application of the monotonicity theorem.
    """
    pred = maxplus_matvec(G, c)
    base_error = np.max(np.abs(pred - y))
    perturbation = coefficient_perturbation_bound(G, c, epsilon)
    worst_case_error = base_error + np.max(perturbation)
    return worst_case_error <= margin


# =============================================================================
# Main: Run examples
# =============================================================================

if __name__ == "__main__":
    print("Tropical Kernel Learning: Algorithm Demonstrations")
    print("=" * 60)

    # Setup
    x = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
    y = np.array([1.0, 2.0, 1.5, 3.0, 2.5])
    K = tropical_gaussian_kernel(sigma=3.0)

    # Train
    print("\n1. Tropical Kernel Regression")
    c_opt, obj = tropical_kernel_regression(K, x, y, lam=0.1, verbose=True)
    print(f"   Optimal coefficients: {np.round(c_opt, 4)}")
    print(f"   Optimal objective: {obj:.4f}")

    # Gram matrix
    G = compute_gram_matrix(K, x)
    pred = maxplus_matvec(G, c_opt)
    print(f"   Predictions: {np.round(pred, 4)}")

    # Predict at new points
    z_new = np.array([0.5, 1.5, 2.5, 3.5])
    pred_new = tropical_predict(K, x, c_opt, z_new)
    print(f"\n2. Predictions at new points {z_new}: {np.round(pred_new, 4)}")

    # Robustness
    print("\n3. Robustness Certification")
    epsilon = 0.1
    bounds = coefficient_perturbation_bound(G, c_opt, epsilon)
    print(f"   ε = {epsilon}")
    print(f"   Per-sample perturbation bounds: {np.round(bounds, 4)}")
    certified = certify_robustness(G, c_opt, y, epsilon=0.1, margin=3.0)
    print(f"   Certified robust (margin=3.0): {certified}")
