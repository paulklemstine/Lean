#!/usr/bin/env python3
"""
Algorithms for Continuous-Time Tropical Comparison and Barrier Computation.

Implements:
1. Tropical barrier computation for finite-dimensional systems.
2. Forward Euler integration of tropical differential inequalities.
3. Certified decay bound verification.
4. Tropical operator composition and barrier propagation.
"""

import numpy as np
from typing import Callable, Tuple, Optional
from dataclasses import dataclass


@dataclass
class TropicalBarrierResult:
    """Result of a tropical barrier decay computation."""
    times: np.ndarray           # Time grid
    trajectory: np.ndarray      # ω(t) values, shape (num_steps, dim)
    excess: np.ndarray          # ω(t) - K values
    barrier: np.ndarray         # max_i(ω(t)(i) - K(i))
    bound: np.ndarray           # exp(-t) * barrier(0)
    is_certified: bool          # Whether bound holds everywhere
    max_violation: float        # max(barrier - bound), should be ≤ 0


def tropical_barrier_functional(x: np.ndarray, K: np.ndarray) -> float:
    """
    Compute the tropical barrier functional: fmax(x) = max_i(x_i - K_i).
    
    Args:
        x: State vector of shape (n,).
        K: Barrier vector of shape (n,).
        
    Returns:
        Maximum excess over the barrier.
        
    Examples:
        >>> tropical_barrier_functional(np.array([3.0, 2.0]), np.array([1.0, 1.0]))
        2.0
        >>> tropical_barrier_functional(np.array([0.5, 0.5]), np.array([1.0, 1.0]))
        -0.5
    """
    return float(np.max(x - K))


def simulate_tropical_ode(
    T: Callable[[np.ndarray], np.ndarray],
    K: np.ndarray,
    omega0: np.ndarray,
    c: Callable[[float], float],
    t_final: float = 5.0,
    dt: float = 0.001,
) -> TropicalBarrierResult:
    """
    Simulate the tropical ODE system:
        ω'_i(t) = T(ω(t))_i - ω_i(t) + c(t)
    
    and compute the barrier functional trajectory.
    
    Args:
        T: Tropical operator (ι → ℝ) → (ι → ℝ). Must satisfy T(x)_i ≤ K_i.
        K: Barrier vector. T(x)_i ≤ K_i must hold for all x, i.
        omega0: Initial condition.
        c: Perturbation function. Must satisfy c(t) ≤ 0 for all t ≥ 0.
        t_final: Final simulation time.
        dt: Time step for Euler integration.
        
    Returns:
        TropicalBarrierResult with trajectory, barrier values, and certification.
        
    Algorithm:
        Forward Euler: ω(t + dt) = ω(t) + dt · (T(ω(t)) - ω(t) + c(t))
        
    Time complexity: O(t_final / dt · dim)
    Space complexity: O(t_final / dt · dim)
    """
    n = len(omega0)
    times = np.arange(0, t_final, dt)
    num_steps = len(times)
    
    trajectory = np.zeros((num_steps, n))
    trajectory[0] = omega0.copy()
    
    for k in range(num_steps - 1):
        Tx = T(trajectory[k])
        # Verify barrier condition (optional runtime check)
        assert np.all(Tx <= K + 1e-10), f"Barrier violated at step {k}: T(x) > K"
        ct = c(times[k])
        assert ct <= 1e-10, f"c(t) > 0 at step {k}"
        trajectory[k+1] = trajectory[k] + dt * (Tx - trajectory[k] + ct)
    
    excess = trajectory - K[np.newaxis, :]
    barrier = np.max(excess, axis=1)
    fmax0 = barrier[0]
    bound = np.exp(-times) * fmax0
    
    max_violation = float(np.max(barrier - bound))
    
    return TropicalBarrierResult(
        times=times,
        trajectory=trajectory,
        excess=excess,
        barrier=barrier,
        bound=bound,
        is_certified=(max_violation <= 1e-6),  # numerical tolerance
        max_violation=max_violation,
    )


def scalar_gronwall_bound(phi0: float, t: np.ndarray) -> np.ndarray:
    """
    Compute the scalar Grönwall bound: exp(-t) · φ(0).
    
    If φ'(t) ≤ -φ(t), then φ(t) ≤ exp(-t) · φ(0) for t ≥ 0.
    
    Args:
        phi0: Initial value φ(0).
        t: Array of time points.
        
    Returns:
        Array of bound values exp(-t) · φ(0).
    """
    return np.exp(-t) * phi0


def find_active_barrier_index(x: np.ndarray, K: np.ndarray) -> int:
    """
    Find the active (maximizing) index of the barrier functional.
    
    The active index i* satisfies x_{i*} - K_{i*} = max_i(x_i - K_i).
    This is the "supporting hyperplane" in the tropical barrier argument.
    
    Args:
        x: Current state vector.
        K: Barrier vector.
        
    Returns:
        Index achieving the maximum excess.
    """
    return int(np.argmax(x - K))


def verify_barrier_condition(
    T: Callable[[np.ndarray], np.ndarray],
    K: np.ndarray,
    test_points: np.ndarray,
) -> bool:
    """
    Numerically verify T(x)_i ≤ K_i for a set of test points.
    
    Args:
        T: Tropical operator.
        K: Barrier vector.
        test_points: Array of shape (num_tests, dim).
        
    Returns:
        True if T(x)_i ≤ K_i for all test points and all i.
    """
    for x in test_points:
        Tx = T(x)
        if not np.all(Tx <= K + 1e-12):
            return False
    return True


def tropical_euler_discrete_bound(
    fmax0: float,
    n_steps: int,
    h: float,
) -> float:
    """
    Compute the discrete Euler approximation to the barrier bound.
    
    The discrete barrier contracts by factor (1-h) per step:
        fmax(ω_{k+1}) ≤ (1-h) · fmax(ω_k)
    
    After n_steps: fmax(ω_n) ≤ (1-h)^n · fmax(ω_0).
    
    As h → 0 and n → ∞ with n·h = t, this converges to exp(-t) · fmax(ω_0).
    
    Args:
        fmax0: Initial barrier value.
        n_steps: Number of discrete steps.
        h: Step size (must be in (0, 1)).
        
    Returns:
        Discrete barrier bound.
    """
    assert 0 < h < 1, "Step size must be in (0, 1)"
    return fmax0 * (1 - h) ** n_steps


def compare_discrete_continuous_bounds(
    fmax0: float,
    t_final: float,
    step_sizes: list[float],
) -> dict:
    """
    Compare discrete (1-h)^{t/h} and continuous exp(-t) bounds.
    
    This demonstrates the convergence of Euler discretization:
    (1 - t/n)^n → exp(-t) as n → ∞.
    
    Args:
        fmax0: Initial barrier value.
        t_final: Final time.
        step_sizes: List of step sizes h to compare.
        
    Returns:
        Dictionary with comparison data.
    """
    continuous_bound = fmax0 * np.exp(-t_final)
    results = {"continuous": continuous_bound}
    
    for h in step_sizes:
        n = int(t_final / h)
        discrete = tropical_euler_discrete_bound(fmax0, n, h)
        results[f"h={h}"] = discrete
        results[f"error_h={h}"] = abs(discrete - continuous_bound)
    
    return results


if __name__ == "__main__":
    print("Tropical Barrier Algorithm Demo")
    print("=" * 50)
    
    # Setup
    K = np.array([2.0, 1.0, 3.0])
    omega0 = np.array([5.0, 4.0, 6.0])
    T = lambda x: np.minimum(x, K)  # Projection operator, T(x)_i ≤ K_i
    c = lambda t: 0.0  # No perturbation
    
    # Simulate
    result = simulate_tropical_ode(T, K, omega0, c, t_final=5.0)
    
    print(f"Initial barrier: fmax(ω(0)) = {result.barrier[0]:.4f}")
    print(f"Final barrier:   fmax(ω(T)) = {result.barrier[-1]:.6f}")
    print(f"Exp bound:       exp(-T)·fmax(0) = {result.bound[-1]:.6f}")
    print(f"Certified: {result.is_certified}")
    print(f"Max violation: {result.max_violation:.2e}")
    
    # Compare discrete vs continuous
    print("\nDiscrete vs Continuous Bounds at t=3:")
    comp = compare_discrete_continuous_bounds(3.0, 3.0, [0.5, 0.1, 0.01, 0.001])
    for key, val in comp.items():
        print(f"  {key}: {val:.8f}")
