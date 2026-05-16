#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Prime-Power Tropical PRG Error Bounds.

Implements the mathematical machinery behind arithmetic sparsification:
- Geometric error bound computation
- Prime-power orbit simulation
- Fiber decorrelation analysis
- Dense vs sparse orbit comparison
"""

import numpy as np
from typing import Callable, Tuple, List


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Geometric Error Bound Computation
# ═══════════════════════════════════════════════════════════════

def compute_geometric_error_bound(
    eps0: float,
    r: float,
    T: int
) -> Tuple[np.ndarray, float, float]:
    """
    Compute stagewise errors and bounds for the prime-power geometric decay.

    Given:
      err(0) ≤ ε₀
      err(j+1) ≤ r · err(j)
      0 ≤ r < 1

    Returns:
      errors: array of err(j) = ε₀ · r^j for j=0..T
      cumulative: Σ err(j)
      bound: ε₀ / (1 - r)

    Time complexity: O(T)
    Space complexity: O(T)
    """
    assert 0 <= r < 1, f"Contraction rate r={r} must satisfy 0 ≤ r < 1"
    assert eps0 >= 0, f"Initial error ε₀={eps0} must be non-negative"

    errors = eps0 * r ** np.arange(T + 1)
    cumulative = np.sum(errors)
    bound = eps0 / (1.0 - r)

    return errors, cumulative, bound


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Hash Power Orbit Simulation
# ═══════════════════════════════════════════════════════════════

def tropical_max_plus_iterate(
    state: np.ndarray,
    matrix: np.ndarray
) -> np.ndarray:
    """
    Apply one step of max-plus matrix multiplication (tropical semiring).

    (A ⊗ x)_i = max_j (A_ij + x_j)

    Time complexity: O(n²) for n-dimensional state
    """
    n = len(state)
    result = np.full(n, -np.inf)
    for i in range(n):
        for j in range(n):
            result[i] = max(result[i], matrix[i, j] + state[j])
    return result


def prime_power_orbit(
    initial_state: np.ndarray,
    matrix: np.ndarray,
    p: int,
    T: int
) -> List[np.ndarray]:
    """
    Compute the prime-power orbit: G^1, G^p, G^(p²), ..., G^(p^T)
    where G is tropical (max-plus) matrix multiplication.

    Returns states at times 1, p, p², ..., p^T.

    Time complexity: O(n² · p^T) where n is state dimension
    Space complexity: O(T · n)
    """
    states = []
    current = initial_state.copy()

    # First compute G^1
    current = tropical_max_plus_iterate(current, matrix)
    states.append(current.copy())

    # Then for each power level, iterate p^(k+1) - p^k more times
    power = 1
    for k in range(1, T + 1):
        additional = p ** k - power
        for _ in range(additional):
            current = tropical_max_plus_iterate(current, matrix)
        power = p ** k
        states.append(current.copy())

    return states


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Fiber Decorrelation Analysis
# ═══════════════════════════════════════════════════════════════

def compute_fiber_collision_matrix(
    C0: float,
    rho: float,
    N: int
) -> np.ndarray:
    """
    Compute the fiber collision statistic matrix C(p^i, p^j) ≤ C₀ · ρ^|i-j|.

    Returns an N×N matrix of upper bounds on collision statistics.

    Time complexity: O(N²)
    """
    C = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            C[i, j] = C0 * rho ** abs(i - j)
    return C


def verify_row_sum_bound(
    C0: float,
    rho: float,
    N: int
) -> Tuple[np.ndarray, float]:
    """
    Verify the per-row sum bound: Σ_j C(p^i, p^j) ≤ C₀ · (2/(1-ρ) - 1).

    Returns:
      row_sums: array of row sums
      bound: C₀ · (2/(1-ρ) - 1)
    """
    C = compute_fiber_collision_matrix(C0, rho, N)
    row_sums = np.sum(C, axis=1)
    bound = C0 * (2.0 / (1 - rho) - 1)
    return row_sums, bound


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Dense vs Sparse Orbit Comparison
# ═══════════════════════════════════════════════════════════════

def crossover_point(eps0: float, r: float) -> int:
    """
    Find the smallest T where prime-power bound beats dense orbit bound.

    Dense bound: (T+1) · ε₀
    PP bound: ε₀ / (1-r)

    Crossover when (T+1) · ε₀ > ε₀ / (1-r), i.e., T+1 > 1/(1-r).

    Time complexity: O(1)
    """
    return int(np.ceil(1.0 / (1.0 - r)))


def efficiency_ratio(eps0: float, r: float, T: int) -> float:
    """
    Compute the ratio of dense-orbit bound to prime-power bound.

    Ratio = (T+1)(1-r) — measures how many times better PP is.

    Time complexity: O(1)
    """
    return (T + 1) * (1.0 - r)


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Optimal Contraction Rate Selection
# ═══════════════════════════════════════════════════════════════

def optimal_contraction_rate(
    target_bound: float,
    eps0: float
) -> float:
    """
    Find the contraction rate r that achieves a target uniform bound.

    Given bound = ε₀ / (1-r), solve for r = 1 - ε₀/bound.

    Time complexity: O(1)
    """
    if target_bound <= eps0:
        raise ValueError(
            f"Target bound {target_bound} must exceed ε₀={eps0}"
        )
    return 1.0 - eps0 / target_bound


# ═══════════════════════════════════════════════════════════════
# Algorithm 6: Multi-Prime Comparison
# ═══════════════════════════════════════════════════════════════

def multi_prime_analysis(
    eps0: float,
    r: float,
    primes: List[int],
    T: int
) -> dict:
    """
    Compare error bounds across different prime bases.

    The uniform bound ε₀/(1-r) is independent of p, but the
    actual orbit lengths p^T differ dramatically.

    Returns a dictionary mapping each prime to its analysis.
    """
    results = {}
    bound = eps0 / (1.0 - r)

    for p in primes:
        orbit_length = p ** T
        errors = eps0 * r ** np.arange(T + 1)
        cumulative = np.sum(errors)

        results[p] = {
            'prime': p,
            'orbit_length': orbit_length,
            'num_samples': T + 1,
            'cumulative_error': cumulative,
            'uniform_bound': bound,
            'compression_ratio': orbit_length / (T + 1),
            'error_per_sample': cumulative / (T + 1),
        }

    return results


if __name__ == "__main__":
    # Quick validation
    errors, cum, bound = compute_geometric_error_bound(0.1, 0.5, 100)
    print(f"Geometric bound: cumulative={cum:.6f}, bound={bound:.6f}")
    assert cum <= bound + 1e-10, "Bound violated!"

    row_sums, rb = verify_row_sum_bound(1.0, 0.4, 50)
    print(f"Row sum bound: max_row={np.max(row_sums):.4f}, bound={rb:.4f}")
    assert np.all(row_sums <= rb + 1e-10), "Row bound violated!"

    cp = crossover_point(0.1, 0.5)
    print(f"Crossover point: T = {cp}")

    results = multi_prime_analysis(0.1, 0.5, [2, 3, 5, 7], 10)
    for p, info in results.items():
        print(f"  p={p}: orbit={info['orbit_length']}, "
              f"compression={info['compression_ratio']:.0f}×")

    print("\nAll algorithms validated successfully.")
