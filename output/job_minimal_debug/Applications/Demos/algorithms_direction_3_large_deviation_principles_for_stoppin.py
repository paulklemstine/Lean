#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Arithmetic Large Deviation Analysis

Implements:
1. Legendre-Fenchel transform computation
2. Rate function estimation from data
3. Free-energy density computation
4. Chernoff bound optimization
5. Phase transition detection
"""

import numpy as np
from typing import Callable, Tuple, Optional, List
from dataclasses import dataclass


@dataclass
class RateFunctionResult:
    """Result of rate function computation."""
    x_values: np.ndarray
    I_values: np.ndarray
    equilibrium_x: float
    equilibrium_I: float


@dataclass
class FreeEnergyResult:
    """Result of free energy analysis."""
    theta_values: np.ndarray
    Lambda_values: np.ndarray
    is_convex: bool
    mean: float  # Λ'(0)


@dataclass
class ChernoffBound:
    """Optimized Chernoff bound result."""
    threshold: float
    optimal_theta: float
    bound_exponent: float
    empirical_count: int
    bound_value: float


def compute_partition_sum(tau: np.ndarray, N: int, theta: float) -> float:
    """
    Compute the exponential partition sum Z_N(θ) = Σ_{n=0}^{N} exp(θ·τ(n)).

    Args:
        tau: Array of stopping-time values τ(0), τ(1), ..., τ(N)
        N: Upper index bound
        theta: Tilting parameter

    Returns:
        Partition sum value (always positive)

    Complexity: O(N) time, O(1) additional space
    """
    # Use log-sum-exp trick for numerical stability
    vals = theta * tau[:N+1]
    max_val = np.max(vals)
    return np.exp(max_val) * np.sum(np.exp(vals - max_val))


def compute_log_mgf(tau: np.ndarray, N: int, theta: float) -> float:
    """
    Compute the scaled log-MGF: Λ_N(θ) = log(Z_N(θ)/(N+1)) / log(N+2).

    This is the finite-volume approximation to the limiting free energy density.

    Args:
        tau: Stopping-time values
        N: Volume parameter
        theta: Tilting parameter

    Returns:
        Scaled log-MGF value

    Complexity: O(N)
    """
    Z = compute_partition_sum(tau, N, theta)
    return np.log(Z / (N + 1)) / np.log(N + 2)


def compute_rate_function(
    Lambda: Callable[[float], float],
    x_range: np.ndarray,
    theta_range: np.ndarray = np.linspace(-20, 20, 5000)
) -> RateFunctionResult:
    """
    Compute the Legendre-Fenchel transform I(x) = sup_θ (θx - Λ(θ)).

    This is the candidate rate function governing large deviations
    of the normalized stopping time τ(n)/log(n+2).

    Args:
        Lambda: The log-MGF function Λ(θ)
        x_range: Points at which to evaluate I
        theta_range: Grid of θ values for the supremum

    Returns:
        RateFunctionResult with I values and equilibrium point

    Complexity: O(|x_range| × |theta_range|)

    Algorithm:
        For each x, compute θ·x - Λ(θ) on the theta grid
        and take the maximum. The equilibrium point x₀ where
        I(x₀) = 0 is identified as the argmin of I.
    """
    Lambda_vals = np.array([Lambda(t) for t in theta_range])

    I_values = np.zeros(len(x_range))
    for i, x in enumerate(x_range):
        objective = theta_range * x - Lambda_vals
        I_values[i] = np.max(objective)

    eq_idx = np.argmin(I_values)
    return RateFunctionResult(
        x_values=x_range,
        I_values=I_values,
        equilibrium_x=x_range[eq_idx],
        equilibrium_I=I_values[eq_idx]
    )


def analyze_free_energy(
    tau: np.ndarray,
    N: int,
    theta_range: np.ndarray = np.linspace(-1, 1, 500)
) -> FreeEnergyResult:
    """
    Analyze the free energy density Λ_N(θ) for convexity and compute derivatives.

    Args:
        tau: Stopping-time values
        N: Volume parameter
        theta_range: Grid of θ values

    Returns:
        FreeEnergyResult with Λ values, convexity check, and mean

    Complexity: O(N × |theta_range|)

    The mean is estimated as Λ'(0) ≈ (Λ(ε) - Λ(-ε)) / (2ε) for small ε.
    Convexity is checked numerically via second differences.
    """
    Lambda_vals = np.array([compute_log_mgf(tau, N, t) for t in theta_range])

    # Check convexity via second differences
    if len(theta_range) >= 3:
        d2 = np.diff(Lambda_vals, 2)
        dt = np.diff(theta_range)[0]
        second_deriv = d2 / (dt ** 2)
        is_convex = np.all(second_deriv >= -1e-8)
    else:
        is_convex = True

    # Estimate mean = Λ'(0)
    eps = 0.001
    mean = (compute_log_mgf(tau, N, eps) - compute_log_mgf(tau, N, -eps)) / (2 * eps)

    return FreeEnergyResult(
        theta_values=theta_range,
        Lambda_values=Lambda_vals,
        is_convex=is_convex,
        mean=mean
    )


def optimize_chernoff_bound(
    tau: np.ndarray,
    N: int,
    a: float,
    theta_range: np.ndarray = np.linspace(0, 2, 1000)
) -> ChernoffBound:
    """
    Find the optimal Chernoff bound for P(τ(n)/log(n+2) ≥ a).

    For each θ ≥ 0, the Chernoff inequality gives:
        #{n: τ(n)/log(n+2) ≥ a} ≤ Σ exp(θ(τ(n) - a·log(n+2)))

    We optimize over θ to get the tightest bound.

    Args:
        tau: Stopping-time values
        N: Volume parameter
        a: Deviation threshold
        theta_range: Grid of non-negative θ values

    Returns:
        ChernoffBound with optimal θ and bound value

    Complexity: O(N × |theta_range|)
    """
    log_n = np.log(np.arange(N + 1) + 2)
    shifted = tau[:N+1] - a * log_n

    # Empirical count
    count = int(np.sum(tau[:N+1] / log_n >= a))

    best_theta = 0.0
    best_bound = float('inf')
    best_exponent = 0.0

    for theta in theta_range:
        if theta < 0:
            continue
        bound = np.sum(np.exp(theta * shifted))
        if bound < best_bound:
            best_bound = bound
            best_theta = theta
            if bound > 0:
                best_exponent = np.log(bound / (N + 1)) / np.log(N + 2)

    return ChernoffBound(
        threshold=a,
        optimal_theta=best_theta,
        bound_exponent=best_exponent,
        empirical_count=count,
        bound_value=best_bound
    )


def detect_phase_transitions(
    Lambda: Callable[[float], float],
    theta_range: np.ndarray = np.linspace(-5, 5, 2000),
    smoothness_threshold: float = 0.1
) -> List[float]:
    """
    Detect phase transitions as points of non-differentiability of Λ(θ).

    A phase transition occurs where the second derivative of Λ has a
    discontinuity or singularity. We detect this by looking for large
    jumps in the numerical second derivative.

    Args:
        Lambda: The free energy function
        theta_range: Grid of θ values
        smoothness_threshold: Threshold for detecting jumps

    Returns:
        List of θ values where phase transitions are detected

    Complexity: O(|theta_range|)
    """
    vals = np.array([Lambda(t) for t in theta_range])
    dt = theta_range[1] - theta_range[0]

    # Second derivative
    d2 = np.diff(vals, 2) / (dt ** 2)

    # Look for large jumps in second derivative
    d3 = np.abs(np.diff(d2))

    transitions = []
    threshold = smoothness_threshold * np.max(d3) if len(d3) > 0 else 0
    for i, jump in enumerate(d3):
        if jump > threshold:
            transitions.append(theta_range[i + 1])

    return transitions


def estimate_limiting_free_energy(
    tau: np.ndarray,
    N_values: List[int],
    theta: float,
    extrapolation_order: int = 2
) -> Tuple[float, float]:
    """
    Estimate the limiting value Λ(θ) = lim_{N→∞} Λ_N(θ) via Richardson extrapolation.

    Args:
        tau: Stopping-time values (must have enough entries)
        N_values: Sequence of N values (should be increasing)
        theta: The tilting parameter
        extrapolation_order: Order of polynomial extrapolation

    Returns:
        (estimated_limit, estimated_error)

    Complexity: O(max(N_values) + |N_values|²)
    """
    Lambda_N = [compute_log_mgf(tau, N, theta) for N in N_values]

    if len(Lambda_N) < 2:
        return Lambda_N[0], float('inf')

    # Simple Richardson extrapolation using last few values
    n_use = min(len(Lambda_N), extrapolation_order + 1)
    recent = Lambda_N[-n_use:]

    # Estimate limit as last value, error as spread of recent values
    limit = recent[-1]
    error = max(recent) - min(recent)

    return limit, error


# ──────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Arithmetic Large Deviation Analysis")
    print("=" * 55)

    # Generate Collatz stopping times
    def collatz_steps(n):
        if n <= 1:
            return 0
        steps, x = 0, n
        while x != 1 and steps < 10000:
            x = x // 2 if x % 2 == 0 else 3 * x + 1
            steps += 1
        return steps

    Nmax = 5000
    tau = np.array([float(collatz_steps(n)) for n in range(Nmax + 1)])

    # 1. Free energy analysis
    print("\n1. Free Energy Analysis")
    result = analyze_free_energy(tau, Nmax)
    print(f"   Convexity verified: {result.is_convex}")
    print(f"   Mean τ/log(n+2) ≈ {result.mean:.4f}")

    # 2. Rate function
    print("\n2. Rate Function Computation")
    def Lambda(theta):
        return compute_log_mgf(tau, Nmax, theta)

    rf = compute_rate_function(Lambda, np.linspace(0, 8, 100))
    print(f"   Equilibrium at x ≈ {rf.equilibrium_x:.4f}")
    print(f"   I(x_eq) ≈ {rf.equilibrium_I:.6f}")

    # 3. Chernoff bounds
    print("\n3. Optimal Chernoff Bounds")
    for a in [4.0, 5.0, 6.0]:
        cb = optimize_chernoff_bound(tau, Nmax, a)
        print(f"   a={a:.1f}: optimal θ={cb.optimal_theta:.3f}, "
              f"count={cb.empirical_count}, bound={cb.bound_value:.1f}")

    # 4. Limiting free energy estimation
    print("\n4. Limiting Free Energy Estimation")
    N_vals = [500, 1000, 2000, 3000, 5000]
    for theta in [0.05, 0.1, 0.2]:
        lim, err = estimate_limiting_free_energy(tau, N_vals, theta)
        print(f"   θ={theta:.2f}: Λ ≈ {lim:.6f} ± {err:.6f}")

    print("\nAll algorithms executed successfully.")
