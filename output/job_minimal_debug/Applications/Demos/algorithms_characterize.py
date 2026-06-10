#!/usr/bin/env python3
"""
Algorithms for Arithmetic Thermodynamics

Implements the core computational primitives for evaluating partition functions,
free energies, and phase-transition diagnostics for arithmetic stopping-time systems.
"""

import numpy as np
from typing import Callable, Optional, Tuple, List


def partition_function_eval(
    w: np.ndarray, tau: np.ndarray, theta: float
) -> float:
    """
    Evaluate the partition function Z(θ) = Σ_i w_i exp(-θ τ_i).

    Uses log-sum-exp stabilization for numerical stability.

    Args:
        w: Weight array (nonneg), shape (n,)
        tau: Observable array, shape (n,)
        theta: Inverse temperature parameter

    Returns:
        Z(θ) value

    Complexity: O(n) time, O(1) extra space
    """
    log_terms = np.log(w + 1e-300) - theta * tau
    max_log = np.max(log_terms)
    return np.exp(max_log) * np.sum(np.exp(log_terms - max_log))


def free_energy_and_derivatives(
    w: np.ndarray, tau: np.ndarray, theta: float
) -> Tuple[float, float, float]:
    """
    Compute F(θ), F'(θ), F''(θ) simultaneously.

    Returns:
        (F, F', F'') where:
        - F = log Z(θ)
        - F' = -⟨τ⟩_θ  (negative Gibbs mean)
        - F'' = Var_θ(τ) (Gibbs variance, always ≥ 0)

    Complexity: O(n) time, O(n) space
    """
    exps = w * np.exp(-theta * tau)
    Z = np.sum(exps)
    # Gibbs probabilities
    p = exps / Z
    mean_tau = np.sum(p * tau)
    mean_tau2 = np.sum(p * tau**2)

    F = np.log(Z)
    F_prime = -mean_tau
    F_double_prime = mean_tau2 - mean_tau**2

    return F, F_prime, F_double_prime


def detect_phase_transition(
    a_func: Callable[[float], float],
    b_func: Callable[[float], float],
    theta_range: Tuple[float, float],
    tol: float = 1e-10,
    max_iter: int = 100
) -> Optional[float]:
    """
    Find the phase transition point θ* where a(θ*) = b(θ*).

    Uses bisection on Δ(θ) = a(θ) - b(θ).

    Args:
        a_func: First free energy density function
        b_func: Second free energy density function
        theta_range: (θ_min, θ_max) search interval
        tol: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        θ* if found, None otherwise

    Complexity: O(max_iter) evaluations of a, b
    """
    lo, hi = theta_range
    delta_lo = a_func(lo) - b_func(lo)
    delta_hi = a_func(hi) - b_func(hi)

    if delta_lo * delta_hi > 0:
        return None  # No sign change → no crossing

    for _ in range(max_iter):
        mid = (lo + hi) / 2
        delta_mid = a_func(mid) - b_func(mid)

        if abs(delta_mid) < tol or (hi - lo) / 2 < tol:
            return mid

        if delta_mid * delta_lo < 0:
            hi = mid
        else:
            lo = mid
            delta_lo = delta_mid

    return (lo + hi) / 2


def two_level_zeros(
    a: complex, b: complex, alpha: complex, beta: complex,
    k_range: Tuple[int, int] = (-10, 10)
) -> List[complex]:
    """
    Compute zeros of Z(z) = a exp(-α z) + b exp(-β z).

    By the classification theorem:
    exp((β - α)z) = -b/a
    z_k = (log|-b/a| + i(arg(-b/a) + 2πk)) / (β - α)

    Args:
        a, b: Coefficients (a ≠ 0)
        alpha, beta: Exponent parameters (α ≠ β)
        k_range: Range of integer indices for zeros

    Returns:
        List of complex zeros

    Complexity: O(|k_range|) time
    """
    ratio = -b / a
    delta = beta - alpha
    log_ratio = np.log(np.abs(ratio)) + 1j * np.angle(ratio)

    zeros = []
    for k in range(k_range[0], k_range[1] + 1):
        z_k = (log_ratio + 2j * np.pi * k) / delta
        zeros.append(z_k)

    return zeros


def finite_volume_gibbs_measure(
    w: np.ndarray, tau: np.ndarray, theta: float
) -> np.ndarray:
    """
    Compute the Gibbs probability measure at inverse temperature θ.

    p_i(θ) = w_i exp(-θ τ_i) / Z(θ)

    Args:
        w: Weights
        tau: Observable values
        theta: Inverse temperature

    Returns:
        Probability vector p

    Complexity: O(n)
    """
    log_p = np.log(w + 1e-300) - theta * tau
    log_p -= np.max(log_p)  # Stabilize
    p = np.exp(log_p)
    return p / np.sum(p)


def gibbs_entropy(w: np.ndarray, tau: np.ndarray, theta: float) -> float:
    """
    Compute the Gibbs entropy S(θ) = -Σ p_i log p_i.

    Related to free energy by the Legendre transform:
    S = θ ⟨τ⟩ + F(θ)

    Complexity: O(n)
    """
    p = finite_volume_gibbs_measure(w, tau, theta)
    p_safe = p[p > 0]
    return -np.sum(p_safe * np.log(p_safe))


def two_phase_free_energy_limit(
    a_func: Callable[[float], float],
    b_func: Callable[[float], float],
    theta: float,
    N: int
) -> float:
    """
    Compute the finite-volume approximation to the two-phase free energy limit.

    (1/N) log(exp(N a(θ)) + exp(N b(θ))) → max(a(θ), b(θ))

    Complexity: O(1)
    """
    a_val = a_func(theta)
    b_val = b_func(theta)
    m = max(a_val, b_val)
    # log-sum-exp trick
    return m + np.log(np.exp(N * (a_val - m)) + np.exp(N * (b_val - m))) / N


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Collatz stopping times
    def collatz_steps(n: int) -> int:
        count = 0
        while n != 1 and count < 200:
            n = n // 2 if n % 2 == 0 else 3 * n + 1
            count += 1
        return count

    N = 100
    tau = np.array([collatz_steps(n) for n in range(1, N + 1)], dtype=float)
    w = np.ones(N)

    # Free energy and derivatives
    theta = 0.1
    F, Fp, Fpp = free_energy_and_derivatives(w, tau, theta)
    print(f"At θ = {theta}:")
    print(f"  F(θ)  = {F:.6f}")
    print(f"  F'(θ) = {Fp:.6f}  (negative mean stopping time)")
    print(f"  F''(θ) = {Fpp:.6f}  (variance, ≥ 0: {'✓' if Fpp >= 0 else '✗'})")

    # Phase transition detection
    a = lambda th: -th + 1
    b = lambda th: -2 * th + 3
    theta_star = detect_phase_transition(a, b, (0, 5))
    print(f"\nPhase transition at θ* = {theta_star:.6f} (expected: 2.0)")

    # Complex zeros
    zeros = two_level_zeros(1+0j, 2+0j, 0.5+0j, 1.5+0j, (-3, 3))
    print(f"\nTwo-level partition zeros:")
    for z in zeros:
        print(f"  z = {z.real:.4f} + {z.imag:.4f}i")

    # Gibbs entropy
    S = gibbs_entropy(w, tau, theta)
    print(f"\nGibbs entropy at θ = {theta}: S = {S:.6f}")
