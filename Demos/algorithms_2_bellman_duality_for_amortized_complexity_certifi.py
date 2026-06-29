#!/usr/bin/env python3
"""
Algorithms for Bellman Duality in Amortized Complexity

Implements the core algorithms from the research paper:
1. OptimalAmortizedRate — O(n) computation of max prefix average
2. OptimalBellmanPotential — O(n) construction of canonical potential
3. VerifyBellmanCertificate — O(n) verification of dual feasibility
4. AmortizedAnalysisReport — complete analysis pipeline
"""

import numpy as np
from dataclasses import dataclass
from typing import Optional, Tuple


@dataclass
class AmortizedAnalysisResult:
    """Complete result of amortized analysis via Bellman duality."""
    costs: np.ndarray
    optimal_rate: float
    potential: np.ndarray
    prefix_sums: np.ndarray
    prefix_averages: np.ndarray
    critical_prefix: int
    bellman_values: np.ndarray
    is_primal_feasible: bool
    is_dual_feasible: bool


def optimal_amortized_rate(costs: np.ndarray) -> Tuple[float, int]:
    """
    Compute the optimal amortized rate r* = max_{1≤k≤n} S_k/k.

    This is the closed-form optimizer from optimal_rate_eq_maxPrefixAvg.

    Args:
        costs: Array of per-step costs, shape (n,).

    Returns:
        (r_star, k_star): optimal rate and the critical prefix index.

    Time complexity: O(n)
    Space complexity: O(1) additional
    """
    n = len(costs)
    if n == 0:
        return 0.0, 0

    running_sum = 0.0
    r_star = float('-inf')
    k_star = 1

    for k in range(1, n + 1):
        running_sum += costs[k - 1]
        avg = running_sum / k
        if avg > r_star:
            r_star = avg
            k_star = k

    return r_star, k_star


def optimal_bellman_potential(costs: np.ndarray, r: Optional[float] = None) -> np.ndarray:
    """
    Construct the canonical Bellman potential: φ_k = r·k - S_k.

    This is the constructive witness from feasibleRate_imp_bellmanFeasible.
    The potential satisfies:
        - φ_0 = 0
        - φ_k ≥ 0 for all k (when r is feasible)
        - cost_i + φ_{i+1} - φ_i = r for all i

    Args:
        costs: Array of per-step costs, shape (n,).
        r: Rate to use. If None, uses the optimal rate r*.

    Returns:
        phi: Array of potential values, shape (n+1,).

    Time complexity: O(n)
    Space complexity: O(n)
    """
    n = len(costs)
    if r is None:
        r, _ = optimal_amortized_rate(costs)

    phi = np.zeros(n + 1)
    running_sum = 0.0

    for k in range(1, n + 1):
        running_sum += costs[k - 1]
        phi[k] = r * k - running_sum

    return phi


def verify_bellman_certificate(
    costs: np.ndarray,
    r: float,
    phi: np.ndarray,
    tol: float = 1e-10
) -> dict:
    """
    Verify that (r, φ) is a valid Bellman certificate.

    Checks:
        1. φ_0 = 0
        2. φ_k ≥ 0 for all k
        3. cost_i + φ_{i+1} - φ_i ≤ r for all i

    Args:
        costs: Array of per-step costs, shape (n,).
        r: The amortized rate to verify.
        phi: Potential function values, shape (n+1,).
        tol: Numerical tolerance.

    Returns:
        Dictionary with verification results.

    Time complexity: O(n)
    """
    n = len(costs)
    assert len(phi) == n + 1, f"Expected phi of length {n+1}, got {len(phi)}"

    # Check φ_0 = 0
    init_ok = abs(phi[0]) < tol

    # Check φ_k ≥ 0
    min_phi = np.min(phi)
    nonneg_ok = min_phi >= -tol

    # Check Bellman inequality
    bellman_values = np.array([costs[i] + phi[i + 1] - phi[i] for i in range(n)])
    max_bellman = np.max(bellman_values) if n > 0 else 0
    bellman_ok = max_bellman <= r + tol

    return {
        'initial_condition': init_ok,
        'nonnegativity': nonneg_ok,
        'bellman_inequality': bellman_ok,
        'min_potential': float(min_phi),
        'max_bellman_value': float(max_bellman),
        'bellman_slack': float(r - max_bellman),
        'valid': init_ok and nonneg_ok and bellman_ok,
    }


def amortized_analysis(costs: np.ndarray) -> AmortizedAnalysisResult:
    """
    Complete amortized analysis via Bellman duality.

    Computes the optimal rate, constructs the canonical potential,
    and verifies both primal and dual feasibility.

    Args:
        costs: Array of per-step costs, shape (n,).

    Returns:
        AmortizedAnalysisResult with all computed quantities.
    """
    n = len(costs)

    # Compute optimal rate
    r_star, k_star = optimal_amortized_rate(costs)

    # Construct canonical potential
    phi = optimal_bellman_potential(costs, r_star)

    # Compute prefix sums and averages
    S = np.concatenate([[0], np.cumsum(costs)])
    avgs = np.zeros(n + 1)
    avgs[1:] = S[1:] / np.arange(1, n + 1)

    # Compute Bellman values
    bellman_values = np.array([
        costs[i] + phi[i + 1] - phi[i] for i in range(n)
    ]) if n > 0 else np.array([])

    # Verify primal feasibility
    primal_ok = all(S[k] <= r_star * k + 1e-10 for k in range(n + 1))

    # Verify dual feasibility
    dual_check = verify_bellman_certificate(costs, r_star, phi)

    return AmortizedAnalysisResult(
        costs=costs,
        optimal_rate=r_star,
        potential=phi,
        prefix_sums=S,
        prefix_averages=avgs,
        critical_prefix=k_star,
        bellman_values=bellman_values,
        is_primal_feasible=primal_ok,
        is_dual_feasible=dual_check['valid'],
    )


# ─────────────────────────────────────────────────────────────
# Specialized cost generators
# ─────────────────────────────────────────────────────────────

def dynamic_array_costs(n: int) -> np.ndarray:
    """Generate cost sequence for n insertions into a doubling dynamic array."""
    costs = np.ones(n)
    capacity = 1
    for i in range(n):
        if i + 1 > capacity:
            costs[i] = i + 1
            capacity *= 2
    return costs


def binary_counter_costs(n: int) -> np.ndarray:
    """Generate cost sequence for n binary counter increments."""
    costs = np.zeros(n)
    for i in range(n):
        v = i
        t = 0
        while v > 0 and v % 2 == 1:
            t += 1
            v //= 2
        costs[i] = t + 1
    return costs


def multipop_stack_costs(n: int, max_pop: int = 5) -> np.ndarray:
    """Generate cost sequence for a stack with occasional multipop operations."""
    rng = np.random.default_rng(42)
    costs = np.ones(n)
    stack_size = 0
    for i in range(n):
        if rng.random() < 0.3 and stack_size > 0:
            pop_count = min(rng.integers(1, max_pop + 1), stack_size)
            costs[i] = pop_count
            stack_size -= pop_count
        else:
            costs[i] = 1
            stack_size += 1
    return costs


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Bellman Duality Algorithms — Example Usage")
    print("=" * 50)

    # Dynamic array
    costs = dynamic_array_costs(100)
    result = amortized_analysis(costs)
    print(f"\nDynamic Array (n=100):")
    print(f"  Optimal rate: {result.optimal_rate:.4f}")
    print(f"  Critical prefix: k={result.critical_prefix}")
    print(f"  Primal feasible: {result.is_primal_feasible}")
    print(f"  Dual feasible: {result.is_dual_feasible}")
    print(f"  Max potential: {np.max(result.potential):.2f}")

    # Binary counter
    costs = binary_counter_costs(256)
    result = amortized_analysis(costs)
    print(f"\nBinary Counter (n=256):")
    print(f"  Optimal rate: {result.optimal_rate:.4f}")
    print(f"  Critical prefix: k={result.critical_prefix}")
    print(f"  Primal feasible: {result.is_primal_feasible}")
    print(f"  Dual feasible: {result.is_dual_feasible}")

    # Multipop stack
    costs = multipop_stack_costs(200)
    result = amortized_analysis(costs)
    print(f"\nMultipop Stack (n=200):")
    print(f"  Optimal rate: {result.optimal_rate:.4f}")
    print(f"  Critical prefix: k={result.critical_prefix}")
    print(f"  Primal feasible: {result.is_primal_feasible}")
    print(f"  Dual feasible: {result.is_dual_feasible}")
