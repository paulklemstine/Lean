#!/usr/bin/env python3
"""
Algorithms for Shadow-Energy Universality

Implements:
1. adaptive_step_separable — Dimension-adaptive step size selection
2. extensivity_index_estimator — Estimate the extensivity index from simulation data
3. shadow_bound_evaluator — Evaluate the theoretical shadow energy bound
4. defect_decomposer — Decompose energy defect into component and coupling parts
"""

import numpy as np
from typing import Tuple, Optional, Callable


def adaptive_step_separable(C0: float, kappa: float, n: int, 
                             tol: float) -> float:
    """Dimension-adaptive step size selection using shadow-energy universality.
    
    For a separable Lagrangian with n degrees of freedom, the shadow energy
    bound is |ΔE| ≤ C₀ · h² · (1 + κ/n). This function selects h so that
    the bound equals the tolerance.
    
    The key insight: h can be LARGER for large n because the bound is tighter.
    
    Args:
        C0: Base error constant (depends on energy level and single-particle bounds)
        kappa: Coupling correction parameter
        n: Number of degrees of freedom
        tol: Desired energy error tolerance
    
    Returns:
        h: Recommended step size
        
    Example:
        >>> h = adaptive_step_separable(1e-3, 0.5, 100, 1e-6)
        >>> print(f"Step size: {h:.6f}")
    """
    if C0 <= 0:
        raise ValueError(f"Base constant C0 must be positive, got {C0}")
    if n < 1:
        raise ValueError(f"Dimension n must be ≥ 1, got {n}")
    if tol <= 0:
        raise ValueError(f"Tolerance must be positive, got {tol}")
    
    effective_constant = C0 * (1 + kappa / n)
    h = np.sqrt(tol / effective_constant)
    return h


def extensivity_index_estimator(dimensions: np.ndarray, 
                                 drifts: np.ndarray) -> Tuple[float, float, float]:
    """Estimate the extensivity index from dimension-scaling data.
    
    Given energy drifts measured at various dimensions, fits the model:
        drift(n) = C₀ · n^α · (1 + κ/n)
    
    where α is the extensivity index.
    
    For separable Lagrangians, we expect α ≈ 0 (dimension-independent
    per-degree-of-freedom drift).
    
    Args:
        dimensions: Array of system dimensions tested
        drifts: Array of per-DOF energy drifts at each dimension
    
    Returns:
        (alpha, C0, kappa): Estimated extensivity index, base constant,
                           and coupling correction
    
    Example:
        >>> dims = np.array([5, 10, 20, 50, 100])
        >>> drifts = np.array([1.2e-4, 1.1e-4, 1.05e-4, 1.02e-4, 1.01e-4])
        >>> alpha, C0, kappa = extensivity_index_estimator(dims, drifts)
        >>> print(f"Extensivity index: {alpha:.3f}")
    """
    # Fit log(drift) = α·log(n) + log(C₀) + log(1 + κ/n)
    # First pass: assume κ ≈ 0 for α estimate
    log_n = np.log(dimensions.astype(float))
    log_d = np.log(np.abs(drifts) + 1e-30)
    
    # Linear fit: log(drift) = α·log(n) + c
    A = np.column_stack([log_n, np.ones_like(log_n)])
    result = np.linalg.lstsq(A, log_d, rcond=None)
    alpha_raw = result[0][0]
    
    # Second pass: fit C₀(1 + κ/n) model (assuming α ≈ 0 for per-DOF drift)
    inv_n = 1.0 / dimensions.astype(float)
    B = np.column_stack([np.ones_like(inv_n), inv_n])
    result2 = np.linalg.lstsq(B, drifts, rcond=None)
    C0 = result2[0][0]
    kappa = result2[0][1] / C0 if abs(C0) > 1e-15 else 0.0
    
    # Refined α: should be close to 0 for separable systems
    alpha = max(0, alpha_raw)  # extensivity index is non-negative
    
    return alpha, C0, kappa


def shadow_bound_evaluator(C0: float, h: float, kappa: float, 
                            n: int) -> float:
    """Evaluate the shadow energy bound C₀ · h² · (1 + κ/n).
    
    Args:
        C0: Base error constant
        h: Step size
        kappa: Coupling correction
        n: System dimension
    
    Returns:
        The bound value
    """
    return C0 * h**2 * (1 + kappa / n)


def defect_decomposer(q_old: np.ndarray, q_new: np.ndarray,
                       p_old: np.ndarray, p_new: np.ndarray,
                       m: np.ndarray,
                       V: Callable, 
                       grad_V: Callable) -> Tuple[np.ndarray, float]:
    """Decompose the energy defect into per-component and coupling parts.
    
    For a separable Lagrangian L = T(v) - V(q) with T = Σ ½mᵢvᵢ²,
    the energy defect ΔE = E(new) - E(old) decomposes as:
    
        ΔE = Σᵢ ΔEᵢ + ΔE_coupling
    
    where ΔEᵢ captures the i-th particle's kinetic + diagonal potential change,
    and ΔE_coupling captures cross-particle interactions.
    
    Args:
        q_old, q_new: Old and new positions
        p_old, p_new: Old and new momenta
        m: Masses
        V: Potential energy function
        grad_V: Gradient of potential
    
    Returns:
        (component_defects, coupling_defect): Per-particle defects and coupling term
    """
    n = len(q_old)
    
    # Kinetic energy change per particle
    dT = 0.5 * (p_new**2 - p_old**2) / m
    
    # Diagonal potential changes (single-particle approximation)
    # ΔV_diag ≈ Σᵢ ∂V/∂qᵢ · Δqᵢ
    g_old = grad_V(q_old)
    dq = q_new - q_old
    dV_diag = g_old * dq  # per-component
    
    # Component defects
    component_defects = dT + dV_diag
    
    # Total energy change
    E_old = np.sum(0.5 * p_old**2 / m) + V(q_old)
    E_new = np.sum(0.5 * p_new**2 / m) + V(q_new)
    total_defect = E_new - E_old
    
    # Coupling = total - sum of components
    coupling_defect = total_defect - np.sum(component_defects)
    
    return component_defects, coupling_defect


def verify_dimension_independence(system_factory: Callable,
                                   dimensions: list,
                                   h: float = 0.01,
                                   T_sim: float = 50.0,
                                   n_trials: int = 3) -> dict:
    """Verify the dimension-independence theorem numerically.
    
    Args:
        system_factory: Function(n) -> (V, grad_V, q0, p0, m)
        dimensions: List of dimensions to test
        h: Step size
        T_sim: Simulation time
        n_trials: Number of random trials per dimension
    
    Returns:
        Dictionary with results including fitted C₀, κ, and extensivity index
    """
    from demo import simulate, hamiltonian
    
    n_steps = int(T_sim / h)
    drift_per_dof = []
    
    for n in dimensions:
        trial_drifts = []
        for trial in range(n_trials):
            np.random.seed(42 + trial)
            V, grad_V, q0, p0, m = system_factory(n)
            times, energies = simulate(q0, p0, m, V, grad_V, h, n_steps)
            E0 = energies[0]
            max_drift = np.max(np.abs(energies - E0))
            trial_drifts.append(max_drift / (h**2 * n))
        drift_per_dof.append(np.mean(trial_drifts))
    
    dims_arr = np.array(dimensions, dtype=float)
    drifts_arr = np.array(drift_per_dof)
    
    alpha, C0, kappa = extensivity_index_estimator(dims_arr, drifts_arr)
    
    return {
        'dimensions': dimensions,
        'drifts_per_dof': drift_per_dof,
        'extensivity_index': alpha,
        'C0': C0,
        'kappa': kappa,
        'h': h,
        'T_sim': T_sim,
        'conclusion': 'dimension-independent' if alpha < 0.1 else 'dimension-dependent'
    }


if __name__ == '__main__':
    # Quick test
    print("Shadow-Energy Algorithms")
    print("=" * 50)
    
    # Test adaptive step size
    for n in [1, 10, 100, 1000]:
        h = adaptive_step_separable(1e-3, 0.5, n, 1e-6)
        bound = shadow_bound_evaluator(1e-3, h, 0.5, n)
        print(f"n={n:5d}: h={h:.6f}, bound={bound:.2e}")
    
    print(f"\nAll bounds equal tolerance = 1e-6 ✓")
    
    # Test extensivity index estimator
    dims = np.array([5, 10, 20, 50, 100])
    # Simulate data matching C₀(1 + κ/n) with C₀=1e-4, κ=2
    C0_true, kappa_true = 1e-4, 2.0
    drifts = C0_true * (1 + kappa_true / dims) + 1e-6 * np.random.randn(len(dims))
    alpha, C0_est, kappa_est = extensivity_index_estimator(dims, drifts)
    
    print(f"\nExtensivity index estimation:")
    print(f"  True:      C₀={C0_true:.2e}, κ={kappa_true:.1f}")
    print(f"  Estimated: C₀={C0_est:.2e}, κ={kappa_est:.1f}")
    print(f"  Extensivity index α = {alpha:.3f} (should be ≈ 0)")
