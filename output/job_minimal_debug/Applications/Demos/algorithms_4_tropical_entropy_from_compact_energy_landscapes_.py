#!/usr/bin/env python3
"""
Algorithms for Compact Tropical Entropy computation.

Implements the tropical partition function and structural law verification
with full type hints and docstrings.
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class TropicalResult:
    """Result of computing the tropical partition function."""
    z_trop: float           # The tropical partition function value
    minimizer: np.ndarray   # The point achieving the minimum
    energy_at_min: float    # E(minimizer) — should equal z_trop


def compute_tropical_partition(
    E: Callable[[np.ndarray], float],
    grid: np.ndarray,
) -> TropicalResult:
    """
    Compute the tropical partition function Z_trop = inf E(x) on a discretized grid.

    Args:
        E: Energy function mapping points to real values.
        grid: Array of grid points (shape [N] or [N, d]).

    Returns:
        TropicalResult with z_trop, minimizer, and energy at minimizer.

    Complexity: O(N) evaluations of E, O(N) memory.
    """
    if grid.ndim == 1:
        values = np.array([E(np.array([x])) for x in grid])
    else:
        values = np.array([E(x) for x in grid])

    idx = int(np.argmin(values))
    minimizer = grid[idx] if grid.ndim > 1 else np.array([grid[idx]])

    return TropicalResult(
        z_trop=float(values[idx]),
        minimizer=minimizer,
        energy_at_min=float(values[idx]),
    )


def verify_translation_invariance(
    E: Callable[[np.ndarray], float],
    grid: np.ndarray,
    c: float,
    tol: float = 1e-10,
) -> Tuple[bool, float]:
    """
    Verify Z_trop(E + c) = Z_trop(E) + c.

    Args:
        E: Energy function.
        grid: Grid points.
        c: Translation constant.
        tol: Tolerance for equality check.

    Returns:
        (is_valid, error) where error = |Z_trop(E+c) - (Z_trop(E) + c)|.
    """
    E_shifted = lambda x: E(x) + c
    result_base = compute_tropical_partition(E, grid)
    result_shifted = compute_tropical_partition(E_shifted, grid)

    expected = result_base.z_trop + c
    error = abs(result_shifted.z_trop - expected)

    return error < tol, error


def verify_monotonicity(
    E: Callable[[np.ndarray], float],
    F: Callable[[np.ndarray], float],
    grid: np.ndarray,
    tol: float = 1e-10,
) -> Tuple[bool, bool, float]:
    """
    Verify: if E(x) <= F(x) for all x, then Z_trop(E) <= Z_trop(F).

    Returns:
        (pointwise_holds, monotonicity_holds, gap) where
        gap = Z_trop(F) - Z_trop(E).
    """
    if grid.ndim == 1:
        E_vals = np.array([E(np.array([x])) for x in grid])
        F_vals = np.array([F(np.array([x])) for x in grid])
    else:
        E_vals = np.array([E(x) for x in grid])
        F_vals = np.array([F(x) for x in grid])

    pointwise = bool(np.all(E_vals <= F_vals + tol))

    z_E = float(np.min(E_vals))
    z_F = float(np.min(F_vals))
    gap = z_F - z_E

    return pointwise, z_E <= z_F + tol, gap


def verify_data_processing(
    E: Callable[[np.ndarray], float],
    F: Callable[[np.ndarray], float],
    f: Callable[[np.ndarray], np.ndarray],
    grid_X: np.ndarray,
    grid_Y: np.ndarray,
    tol: float = 1e-10,
) -> Tuple[bool, bool, float]:
    """
    Verify tropical data processing inequality:
    F(f(x)) <= E(x) for all x  ==>  Z_trop(F) <= Z_trop(E).

    Returns:
        (channel_condition_holds, inequality_holds, gap)
    """
    # Check channel condition
    if grid_X.ndim == 1:
        grid_X_2d = grid_X.reshape(-1, 1)
    else:
        grid_X_2d = grid_X

    channel_ok = True
    for x in grid_X_2d:
        fx = f(x)
        if F(fx) > E(x) + tol:
            channel_ok = False
            break

    result_E = compute_tropical_partition(E, grid_X)
    result_F = compute_tropical_partition(F, grid_Y)

    gap = result_E.z_trop - result_F.z_trop
    inequality = result_F.z_trop <= result_E.z_trop + tol

    return channel_ok, inequality, gap


def classical_free_energy(
    E_values: np.ndarray, beta: float
) -> float:
    """
    Compute the classical free energy F_β = -(1/β) log Σ exp(-β E(x)).

    Uses log-sum-exp trick for numerical stability.

    Args:
        E_values: Array of energy values.
        beta: Inverse temperature.

    Returns:
        Classical free energy at inverse temperature beta.
    """
    shifted = -beta * E_values
    max_val = np.max(shifted)
    log_Z = max_val + np.log(np.sum(np.exp(shifted - max_val)))
    return -log_Z / beta


def tropical_convergence_rate(
    E_values: np.ndarray,
    betas: List[float],
) -> List[Tuple[float, float, float]]:
    """
    Compute convergence of classical free energy to tropical partition function.

    Args:
        E_values: Array of energy values.
        betas: List of inverse temperatures.

    Returns:
        List of (beta, F_beta, |F_beta - Z_trop|) tuples.
    """
    z_trop = float(np.min(E_values))
    results = []
    for beta in betas:
        F_beta = classical_free_energy(E_values, beta)
        error = abs(F_beta - z_trop)
        results.append((beta, F_beta, error))
    return results


# Example usage
if __name__ == "__main__":
    print("=== Tropical Partition Function Algorithms ===\n")

    # 1D example
    grid = np.linspace(0, 1, 10001)
    E = lambda x: (x[0] - 0.3) ** 2

    result = compute_tropical_partition(E, grid)
    print(f"E(x) = (x - 0.3)^2 on [0, 1]")
    print(f"  Z_trop = {result.z_trop:.8f}")
    print(f"  Minimizer = {result.minimizer[0]:.4f}")

    # Translation invariance
    ok, err = verify_translation_invariance(E, grid, c=5.0)
    print(f"\nTranslation invariance (c=5): {'PASS' if ok else 'FAIL'} (error={err:.2e})")

    # Monotonicity
    F = lambda x: (x[0] - 0.3) ** 2 + 0.1
    pw, mono, gap = verify_monotonicity(E, F, grid)
    print(f"Monotonicity: pointwise={pw}, mono={mono}, gap={gap:.6f}")

    # Classical convergence
    E_vals = np.array([E(np.array([x])) for x in grid])
    print("\nClassical → Tropical convergence:")
    for beta, F_beta, error in tropical_convergence_rate(
        E_vals, [1, 10, 100, 1000, 10000]
    ):
        print(f"  β={beta:6.0f}: F_β = {F_beta:.8f}, error = {error:.2e}")
