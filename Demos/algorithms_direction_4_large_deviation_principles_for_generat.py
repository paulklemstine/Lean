#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for subgroup pressure thermodynamics.

Implements the mathematical framework from the Lean formalization:
- Subgroup pressure computation (partition function)
- Log-pressure (free energy)
- Legendre–Fenchel transform (rate function)
- Chernoff bound certificates
- Product pressure recursion

All algorithms are verified correct in the sense that they implement
the exact formulas proved in the Lean theorems.
"""

import math
import numpy as np
from typing import List, Tuple, Optional, Callable


def subgroup_pressure(indices: List[int], t: float) -> float:
    """
    Compute the subgroup pressure Z_G(t) = ∑_{H proper} [G:H]^{-2t}.

    Args:
        indices: List of subgroup indices [G:H] for each proper subgroup H.
        t: Inverse temperature parameter.

    Returns:
        The pressure value Z_G(t).

    Complexity: O(|indices|) time, O(1) space.

    Correctness: Implements the definition `subgroupPressure` from the Lean file.
    Nonnegativity follows from `subgroupPressure_nonneg`.
    Antitonicity in t follows from `subgroupPressure_antitone`.
    """
    if not indices:
        return 0.0
    return sum(idx ** (-2 * t) for idx in indices if idx > 0)


def log_pressure(indices: List[int], t: float) -> float:
    """
    Compute the log-pressure (free energy) log Z_G(t).

    Args:
        indices: List of subgroup indices for proper subgroups.
        t: Inverse temperature parameter.

    Returns:
        log Z_G(t), or -inf if Z_G(t) = 0.

    Complexity: O(|indices|) time, O(1) space.
    """
    Z = subgroup_pressure(indices, t)
    return math.log(Z) if Z > 0 else float('-inf')


def pressure_curve(indices: List[int], t_values: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute pressure and log-pressure curves over temperature range.

    Args:
        indices: Subgroup indices.
        t_values: Array of temperature values.

    Returns:
        Tuple of (pressure_array, log_pressure_array).

    Complexity: O(|indices| × |t_values|).
    """
    pressures = np.array([subgroup_pressure(indices, t) for t in t_values])
    log_pressures = np.array([log_pressure(indices, t) for t in t_values])
    return pressures, log_pressures


def legendre_transform(log_mgf: Callable[[float], float],
                        t_range: np.ndarray,
                        alpha: float) -> float:
    """
    Compute the Legendre–Fenchel transform Λ*(α) = sup_t {tα - Λ(t)}.

    This is the candidate rate function from large deviation theory.

    Args:
        log_mgf: The log-moment generating function Λ(t).
        t_range: Grid of t values for numerical optimization.
        alpha: The point at which to evaluate the rate function.

    Returns:
        Λ*(α), the rate function value.

    Complexity: O(|t_range|) per evaluation.

    Correctness: Implements `candidateRateFunction` from the Lean file.
    Nonnegativity when Λ(0) ≤ 0 follows from `candidateRateFunction_nonneg`.
    """
    values = [t * alpha - log_mgf(t) for t in t_range]
    return max(values)


def rate_function_curve(indices: List[int],
                         alpha_values: np.ndarray,
                         t_range: np.ndarray) -> np.ndarray:
    """
    Compute the candidate rate function over a range of α values.

    Args:
        indices: Subgroup indices.
        alpha_values: Points at which to evaluate rate function.
        t_range: Temperature grid for Legendre transform.

    Returns:
        Array of rate function values.
    """
    def log_mgf(t):
        return log_pressure(indices, t)

    return np.array([legendre_transform(log_mgf, t_range, a) for a in alpha_values])


def chernoff_bound(indices: List[int], alpha: float, t: float) -> float:
    """
    Compute the Chernoff upper bound exp(-2tα) · Z_G(t).

    For t ≥ 0, this bounds the probability that a random pair has
    defect at least α. The bound follows from Markov's inequality
    applied to the moment generating function.

    Args:
        indices: Subgroup indices.
        alpha: Defect threshold.
        t: Inverse temperature (must be ≥ 0 for valid bound).

    Returns:
        The Chernoff bound value.

    Complexity: O(|indices|).
    """
    Z = subgroup_pressure(indices, t)
    return math.exp(-2 * t * alpha) * Z


def optimal_chernoff_bound(indices: List[int],
                            alpha: float,
                            t_range: Optional[np.ndarray] = None) -> float:
    """
    Find the tightest Chernoff bound by optimizing over t ≥ 0.

    Args:
        indices: Subgroup indices.
        alpha: Defect threshold.
        t_range: Grid of nonneg t values (default: linspace(0.01, 5, 500)).

    Returns:
        min_{t≥0} exp(-2tα) · Z_G(t).

    Complexity: O(|indices| × |t_range|).
    """
    if t_range is None:
        t_range = np.linspace(0.01, 5.0, 500)
    t_range = t_range[t_range >= 0]
    bounds = [chernoff_bound(indices, alpha, t) for t in t_range]
    return min(bounds) if bounds else float('inf')


def product_pressure(indices1: List[int], indices2: List[int], t: float) -> float:
    """
    Compute the pressure of product subgroups in G₁ × G₂.

    For product subgroups K₁ × K₂, the index [G₁×G₂ : K₁×K₂] = [G₁:K₁]·[G₂:K₂].
    The pressure over product subgroups factorizes as Z₁(t)·Z₂(t).

    Args:
        indices1: Subgroup indices for G₁.
        indices2: Subgroup indices for G₂.
        t: Inverse temperature.

    Returns:
        Product pressure Z₁(t) · Z₂(t).

    Correctness: This is the product-subgroup contribution. The full pressure
    of G₁ × G₂ also includes non-product (diagonal) subgroups, giving
    a submultiplicative bound.
    """
    return subgroup_pressure(indices1, t) * subgroup_pressure(indices2, t)


def verify_log_convexity(indices: List[int], t1: float, t2: float,
                          theta_values: np.ndarray) -> List[Tuple[float, float, float, bool]]:
    """
    Verify log-convexity (geometric convexity) of pressure at given parameters.

    For each θ, checks: Z(θt₁ + (1-θ)t₂) ≤ Z(t₁)^θ · Z(t₂)^{1-θ}.

    Args:
        indices: Subgroup indices.
        t1, t2: Two temperature values.
        theta_values: Array of θ values in [0,1].

    Returns:
        List of (theta, lhs, rhs, satisfied) tuples.

    Correctness: Verified by `subgroupPressure_geometric_convex`.
    """
    results = []
    for theta in theta_values:
        t_mix = theta * t1 + (1 - theta) * t2
        lhs = subgroup_pressure(indices, t_mix)
        rhs = subgroup_pressure(indices, t1) ** theta * subgroup_pressure(indices, t2) ** (1 - theta)
        results.append((theta, lhs, rhs, lhs <= rhs + 1e-12))
    return results


def verify_antitonicity(indices: List[int], t_values: np.ndarray) -> List[Tuple[float, float, bool]]:
    """
    Verify that pressure is antitone (decreasing) in t.

    Correctness: Verified by `subgroupPressure_antitone`.
    """
    pressures = [(t, subgroup_pressure(indices, t)) for t in sorted(t_values)]
    results = []
    for i, (t, p) in enumerate(pressures):
        ok = True if i == 0 else p <= pressures[i-1][1] + 1e-12
        results.append((t, p, ok))
    return results


# ============================================================
# Group family constructors
# ============================================================

def cyclic_group_indices(n: int) -> List[int]:
    """Proper subgroup indices for Z/nZ."""
    return [n // d for d in range(1, n) if n % d == 0]


def direct_power_indices(base_indices: List[int], m: int) -> List[int]:
    """
    Approximate product subgroup indices for G^m.

    For product subgroups, the indices are products of individual indices.
    This gives the product-obstruction model.
    """
    if m == 1:
        return list(base_indices)
    # For m copies, product subgroups have indices that are products
    # of m indices (one from each factor, at least one > 1)
    from itertools import product as iprod
    extended = list(base_indices) + [1]  # include trivial
    all_products = set()
    for combo in iprod(extended, repeat=m):
        idx = 1
        for c in combo:
            idx *= c
        if idx > 1:  # proper subgroup
            all_products.add(idx)
    return sorted(all_products)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithms Module: Subgroup Pressure Thermodynamics ===\n")

    # Example: Z/12Z
    indices = cyclic_group_indices(12)
    print(f"Z/12Z proper subgroup indices: {indices}")
    print(f"  Z(0) = {subgroup_pressure(indices, 0):.4f} (= number of proper subgroups)")
    print(f"  Z(1) = {subgroup_pressure(indices, 1):.6f}")
    print(f"  Z(2) = {subgroup_pressure(indices, 2):.6f}")

    # Verify antitonicity
    t_vals = np.linspace(0, 3, 7)
    print("\n  Antitonicity check:")
    for t, p, ok in verify_antitonicity(indices, t_vals):
        print(f"    t={t:.1f}: Z={p:.6f} {'✓' if ok else '✗'}")

    # Verify log-convexity
    print("\n  Log-convexity check (t1=0.5, t2=2.5):")
    for theta, lhs, rhs, ok in verify_log_convexity(indices, 0.5, 2.5, np.linspace(0, 1, 5)):
        print(f"    θ={theta:.2f}: {lhs:.6f} ≤ {rhs:.6f} {'✓' if ok else '✗'}")

    # Chernoff bound
    print("\n  Optimal Chernoff bounds:")
    for alpha in [0.5, 1.0, 2.0]:
        bound = optimal_chernoff_bound(indices, alpha)
        print(f"    α={alpha:.1f}: bound = {bound:.6f}")

    # Rate function
    print("\n  Rate function values:")
    alphas = np.linspace(0, 3, 10)
    t_grid = np.linspace(-2, 5, 300)
    rates = rate_function_curve(indices, alphas, t_grid)
    for a, r in zip(alphas, rates):
        print(f"    Λ*({a:.2f}) = {r:.6f}")
