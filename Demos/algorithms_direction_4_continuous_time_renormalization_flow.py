#!/usr/bin/env python3
"""
Algorithms for Continuous Renormalization Flow

Implements the core computational methods for the discrete-to-continuous
renormalization theory, including cascade evaluation, flow computation,
error estimation, and convergence diagnostics.
"""

import math
from typing import Callable, List, Tuple, Optional


# ──────────────────────────────────────────────────────
# Type aliases
# ──────────────────────────────────────────────────────
DampingProfile = Callable[[float], float]


# ──────────────────────────────────────────────────────
# Algorithm 1: Cumulative Damping Functional
# ──────────────────────────────────────────────────────

def cumulative_damping(alpha: DampingProfile, t: float,
                       num_points: int = 10000) -> float:
    """
    Compute the cumulative damping functional:
        Λ(t) = ∫₀ᵗ (1/α(s)) ds

    Uses the composite midpoint rule for numerical integration.

    Args:
        alpha: Damping profile function α: ℝ → ℝ₊
        t: Upper integration limit
        num_points: Number of quadrature points

    Returns:
        Numerical approximation of ∫₀ᵗ (1/α(s)) ds

    Time complexity: O(num_points)
    Space complexity: O(1)

    Example:
        >>> cumulative_damping(lambda s: 1.0, 2.0)  # ∫₀² 1 ds = 2
        2.0
        >>> cumulative_damping(lambda s: 1.0 + s, 1.0)  # ∫₀¹ 1/(1+s) ds = ln(2)
        0.6931...
    """
    if t <= 0:
        return 0.0
    ds = t / num_points
    total = 0.0
    for i in range(num_points):
        s = (i + 0.5) * ds
        a = alpha(s)
        if a <= 0:
            raise ValueError(f"Damping profile must be positive, got α({s}) = {a}")
        total += ds / a
    return total


# ──────────────────────────────────────────────────────
# Algorithm 2: Continuous Renormalization Flow
# ──────────────────────────────────────────────────────

def renorm_flow(alpha: DampingProfile, V0: float, t: float,
                num_quad: int = 10000) -> float:
    """
    Compute the continuous renormalization flow:
        V(t) = V₀ · exp(-Λ(t))

    where Λ(t) = ∫₀ᵗ (1/α(s)) ds.

    Args:
        alpha: Damping profile function
        V0: Initial value
        t: Time parameter
        num_quad: Quadrature points for integration

    Returns:
        V(t) = V₀ · exp(-∫₀ᵗ 1/α(s) ds)

    Time complexity: O(num_quad)
    Space complexity: O(1)

    Example:
        >>> renorm_flow(lambda s: 1.0, 1.0, 1.0)  # e^{-1}
        0.3678...
    """
    damping = cumulative_damping(alpha, t, num_quad)
    return V0 * math.exp(-damping)


# ──────────────────────────────────────────────────────
# Algorithm 3: Discrete Renormalization Cascade
# ──────────────────────────────────────────────────────

def renorm_cascade(alpha: DampingProfile, V0: float, n: int, t: float) -> float:
    """
    Compute the discrete renormalization cascade:
        V_n(t) = V₀ · ∏_{k=0}^{⌊(n+1)t⌋-1} (1 - 1/((n+1)·α(k/(n+1))))

    Args:
        alpha: Damping profile function
        V0: Initial value
        n: Discretization parameter (uses n+1 internally for safety)
        t: Time parameter

    Returns:
        Discrete cascade value at time t

    Time complexity: O(n·t)
    Space complexity: O(1)

    Example:
        >>> renorm_cascade(lambda s: 1.0, 1.0, 1000, 1.0)  # ≈ e^{-1}
        0.3679...
    """
    m = n + 1  # avoid division by zero
    num_steps = int(math.floor(m * t))
    product = V0
    for k in range(num_steps):
        s = k / m
        a = alpha(s)
        if a <= 0:
            raise ValueError(f"Damping profile must be positive, got α({s}) = {a}")
        factor = 1.0 - 1.0 / (m * a)
        product *= factor
    return product


# ──────────────────────────────────────────────────────
# Algorithm 4: Constant-α Cascade (Optimized)
# ──────────────────────────────────────────────────────

def renorm_cascade_const(alpha_val: int, t: float) -> float:
    """
    Optimized cascade for constant damping α:
        (1 - 1/(α+1))^⌊(α+1)·t⌋

    Uses fast exponentiation instead of iterative multiplication.

    Args:
        alpha_val: Constant damping parameter (natural number)
        t: Time parameter ≥ 0

    Returns:
        (1 - 1/(α+1))^⌊(α+1)·t⌋

    Time complexity: O(log(α·t)) via fast exponentiation
    Space complexity: O(1)
    """
    n = alpha_val + 1
    k = int(math.floor(n * t))
    base = 1.0 - 1.0 / n
    return base ** k


# ──────────────────────────────────────────────────────
# Algorithm 5: Sup-norm Error Estimator
# ──────────────────────────────────────────────────────

def sup_error_on_compact(alpha: DampingProfile, V0: float, n: int,
                         T: float, num_samples: int = 500) -> Tuple[float, float]:
    """
    Estimate the supremum error between discrete cascade and continuous flow
    on the interval [0, T]:
        sup_{0 ≤ t ≤ T} |V_n(t) - V(t)|

    Args:
        alpha: Damping profile function
        V0: Initial value
        n: Discretization parameter
        T: Right endpoint of compact interval
        num_samples: Number of sample points in [0, T]

    Returns:
        Tuple (sup_error, argmax_t) where sup_error is the estimated supremum
        and argmax_t is the time at which it is achieved.

    Time complexity: O(num_samples · n · T)
    Space complexity: O(1)
    """
    max_err = 0.0
    argmax_t = 0.0
    dt = T / max(num_samples, 1)

    for i in range(num_samples + 1):
        t = i * dt
        cascade_val = renorm_cascade(alpha, V0, n, t)
        flow_val = renorm_flow(alpha, V0, t)
        err = abs(cascade_val - flow_val)
        if err > max_err:
            max_err = err
            argmax_t = t

    return max_err, argmax_t


# ──────────────────────────────────────────────────────
# Algorithm 6: Convergence Rate Estimator
# ──────────────────────────────────────────────────────

def estimate_convergence_rate(alpha: DampingProfile, V0: float, T: float,
                              n_values: Optional[List[int]] = None) -> List[dict]:
    """
    Estimate the convergence rate of the discrete cascade to the continuous flow.

    For each discretization level n, computes n · sup_error to test whether
    the convergence is first-order (O(1/n)).

    Args:
        alpha: Damping profile function
        V0: Initial value
        T: Compact interval [0, T]
        n_values: List of discretization parameters to test

    Returns:
        List of dicts with keys 'n', 'sup_error', 'scaled_error' (= n * sup_error)

    Example:
        >>> results = estimate_convergence_rate(lambda s: 1.0, 1.0, 3.0)
        >>> all(r['scaled_error'] < 1.0 for r in results)
        True
    """
    if n_values is None:
        n_values = [50, 100, 200, 500, 1000, 2000, 5000]

    results = []
    for n in n_values:
        sup_err, _ = sup_error_on_compact(alpha, V0, n, T)
        results.append({
            'n': n,
            'sup_error': sup_err,
            'scaled_error': n * sup_err,
        })
    return results


# ──────────────────────────────────────────────────────
# Algorithm 7: ODE Verification (Numerical)
# ──────────────────────────────────────────────────────

def verify_ode(alpha: DampingProfile, V0: float, t: float,
               dt: float = 1e-6) -> Tuple[float, float, float]:
    """
    Numerically verify that the continuous flow satisfies
        V'(t) = -V(t)/α(t)

    by comparing the numerical derivative (V(t+dt) - V(t-dt))/(2dt) with -V(t)/α(t).

    Args:
        alpha: Damping profile function
        V0: Initial value
        t: Time point (should be > 0)
        dt: Step size for numerical differentiation

    Returns:
        Tuple (numerical_deriv, expected_deriv, relative_error)
    """
    V_plus = renorm_flow(alpha, V0, t + dt)
    V_minus = renorm_flow(alpha, V0, t - dt)
    numerical_deriv = (V_plus - V_minus) / (2 * dt)

    V_t = renorm_flow(alpha, V0, t)
    expected_deriv = -V_t / alpha(t)

    rel_error = abs(numerical_deriv - expected_deriv) / (abs(expected_deriv) + 1e-15)
    return numerical_deriv, expected_deriv, rel_error


# ──────────────────────────────────────────────────────
# Main: Example usage
# ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Continuous Renormalization Flow")
    print("=" * 50)

    # Example 1: Constant profile
    alpha_const = lambda s: 1.0
    print(f"\nConstant profile α(t) = 1:")
    print(f"  Cumulative damping at t=2: {cumulative_damping(alpha_const, 2.0):.6f} (exact: 2.0)")
    print(f"  Flow value at t=1: {renorm_flow(alpha_const, 1.0, 1.0):.6f} (exact: {math.exp(-1):.6f})")
    print(f"  Cascade(n=1000) at t=1: {renorm_cascade(alpha_const, 1.0, 1000, 1.0):.6f}")

    # Example 2: Convergence rate
    print(f"\nConvergence rate analysis (α=1, T=3):")
    results = estimate_convergence_rate(alpha_const, 1.0, 3.0)
    for r in results:
        print(f"  n={r['n']:5d}: sup_err={r['sup_error']:.2e}, n*err={r['scaled_error']:.4f}")

    # Example 3: ODE verification
    alpha_var = lambda s: 2.0 + math.sin(s)
    print(f"\nODE verification for α(t) = 2 + sin(t):")
    for t in [0.5, 1.0, 2.0, 3.0]:
        num_d, exp_d, rel_e = verify_ode(alpha_var, 1.0, t)
        print(f"  t={t:.1f}: V'={num_d:.6f}, -V/α={exp_d:.6f}, rel_err={rel_e:.2e}")
