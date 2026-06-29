#!/usr/bin/env python3
"""
Symmetry-Rigidity Diagnostic Algorithm
=======================================

Implements the verified symmetry-rigidity diagnostic from the converse
discrete Noether theorem. This algorithm determines whether a variational
integrator possesses an exact symmetry by analyzing momentum conservation
along trajectory data.

Mathematical Foundation:
    By the converse Noether theorem, exact conservation of momentum on all
    DEL trajectories implies infinitesimal invariance of the discrete Lagrangian.
    Nonzero drift witnesses genuine symmetry breaking.

Algorithm:
    Input: trajectory segments, momentum observable
    Output: symmetry classification with quantitative defect score
"""

import numpy as np
from typing import Callable, List, Tuple, Dict, Optional


def compute_momentum_series(
    trajectory: np.ndarray,
    momentum_fn: Callable[[np.ndarray, np.ndarray], float],
) -> np.ndarray:
    """
    Compute the momentum observable along a trajectory.

    Parameters
    ----------
    trajectory : np.ndarray, shape (N, d)
        Sequence of configuration points q_0, q_1, ..., q_{N-1}.
    momentum_fn : Callable
        Momentum observable p(q_k, q_{k+1}) → ℝ.

    Returns
    -------
    np.ndarray, shape (N-1,)
        Momentum values p(q_k, q_{k+1}) for k = 0, ..., N-2.
    """
    n = len(trajectory)
    return np.array([
        momentum_fn(trajectory[k], trajectory[k + 1])
        for k in range(n - 1)
    ])


def compute_drift_series(momenta: np.ndarray) -> np.ndarray:
    """
    Compute momentum drift (symmetry defect) along trajectory.

    Parameters
    ----------
    momenta : np.ndarray, shape (M,)
        Momentum values along trajectory segments.

    Returns
    -------
    np.ndarray, shape (M-1,)
        Drift values |p(q_{k+1}, q_{k+2}) - p(q_k, q_{k+1})|.
    """
    return np.abs(np.diff(momenta))


def symmetry_rigidity_diagnostic(
    trajectory: np.ndarray,
    momentum_fn: Callable[[np.ndarray, np.ndarray], float],
    tolerance: float = 1e-10,
) -> Dict:
    """
    Symmetry-rigidity diagnostic algorithm.

    Determines whether a discrete Lagrangian system possesses an exact symmetry
    by analyzing momentum conservation along trajectory data. By the converse
    Noether theorem:
    - Zero drift on all trajectory segments → exact symmetry
    - Nonzero drift → genuine symmetry breaking

    Parameters
    ----------
    trajectory : np.ndarray, shape (N, d)
        Trajectory of configuration points.
    momentum_fn : Callable
        Discrete momentum observable p(q_k, q_{k+1}) → ℝ.
    tolerance : float
        Threshold for classifying drift as "zero" (accounts for floating-point).

    Returns
    -------
    Dict with keys:
        - 'symmetric': bool — True if system passes symmetry test
        - 'max_drift': float — Maximum absolute momentum drift
        - 'mean_drift': float — Mean absolute drift
        - 'defect_score': float — Normalized defect (drift / |mean momentum|)
        - 'momenta': np.ndarray — Full momentum series
        - 'drifts': np.ndarray — Full drift series
        - 'n_segments': int — Number of trajectory segments analyzed

    Complexity
    ----------
    Time: O(N) where N = len(trajectory)
    Space: O(N)
    """
    momenta = compute_momentum_series(trajectory, momentum_fn)
    drifts = compute_drift_series(momenta)

    max_drift = float(np.max(drifts)) if len(drifts) > 0 else 0.0
    mean_drift = float(np.mean(drifts)) if len(drifts) > 0 else 0.0
    mean_p = float(np.mean(np.abs(momenta))) if len(momenta) > 0 else 1.0
    defect_score = max_drift / max(mean_p, 1e-15)

    return {
        'symmetric': max_drift < tolerance,
        'max_drift': max_drift,
        'mean_drift': mean_drift,
        'defect_score': defect_score,
        'momenta': momenta,
        'drifts': drifts,
        'n_segments': len(drifts),
    }


def perturbation_scaling_analysis(
    base_trajectory_fn: Callable[[float], np.ndarray],
    momentum_fn: Callable[[np.ndarray, np.ndarray], float],
    epsilons: List[float],
) -> Dict:
    """
    Analyze how momentum drift scales with perturbation strength ε.

    By the perturbative drift bound theorem:
        |Δp_k| ≤ |ε| · C

    This function fits the empirical scaling exponent.

    Parameters
    ----------
    base_trajectory_fn : Callable
        Function ε → trajectory for the perturbed system.
    momentum_fn : Callable
        Momentum observable.
    epsilons : list of float
        Perturbation strengths to test.

    Returns
    -------
    Dict with keys:
        - 'epsilons': list — perturbation strengths
        - 'max_drifts': list — max drifts for each ε
        - 'slope': float — log-log slope (should be ≈ 1.0)
        - 'linear_constant': float — estimated C in |Δp| ≤ |ε|·C
    """
    max_drifts = []
    for eps in epsilons:
        traj = base_trajectory_fn(eps)
        result = symmetry_rigidity_diagnostic(traj, momentum_fn)
        max_drifts.append(result['max_drift'])

    log_eps = np.log10(np.abs(epsilons))
    log_drift = np.log10(np.array(max_drifts) + 1e-20)
    valid = np.isfinite(log_drift) & np.isfinite(log_eps)

    slope = 0.0
    C = 0.0
    if np.sum(valid) >= 2:
        coeffs = np.polyfit(log_eps[valid], log_drift[valid], 1)
        slope = coeffs[0]
        # Estimate C from median of drift/|ε|
        ratios = np.array(max_drifts) / np.abs(epsilons)
        C = float(np.median(ratios))

    return {
        'epsilons': epsilons,
        'max_drifts': max_drifts,
        'slope': slope,
        'linear_constant': C,
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Symmetry-Rigidity Diagnostic Algorithm")
    print("=" * 50)
    print()

    # 2D harmonic oscillator with rotational symmetry
    def Ld_sym(q0, q1, h=0.1):
        dq = q1 - q0
        return 0.5 * np.dot(dq, dq) / h - 0.5 * h * np.dot(q0, q0)

    def angular_momentum(q0, q1, h=0.1):
        dq = (q1 - q0) / h
        return dq[0] * q1[1] - dq[1] * q1[0]

    # Simple Störmer-Verlet trajectory
    h = 0.1
    N = 50
    traj = np.zeros((N, 2))
    traj[0] = [1.0, 0.0]
    traj[1] = [1.0 - 0.005, 0.05]

    for k in range(1, N - 1):
        # DEL step: q_{k+1} = 2q_k - q_{k-1} - h^2 * grad V(q_k)
        grad_V = traj[k]  # V = |q|^2/2
        traj[k + 1] = 2 * traj[k] - traj[k - 1] - h**2 * grad_V

    # Run diagnostic
    result = symmetry_rigidity_diagnostic(
        traj, angular_momentum, tolerance=1e-7
    )

    print(f"  System: 2D harmonic oscillator")
    print(f"  Segments analyzed: {result['n_segments']}")
    print(f"  Max drift: {result['max_drift']:.2e}")
    print(f"  Mean drift: {result['mean_drift']:.2e}")
    print(f"  Defect score: {result['defect_score']:.2e}")
    print(f"  Symmetric: {result['symmetric']}")
    print()

    if result['symmetric']:
        print("  ✓ Converse Noether: zero drift → exact rotational symmetry")
    else:
        print("  ✗ Drift detected → symmetry may be broken")
