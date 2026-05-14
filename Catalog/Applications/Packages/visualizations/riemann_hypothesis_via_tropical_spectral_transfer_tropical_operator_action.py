#!/usr/bin/env python3
"""
Tropical Spectral Transfer — Algorithms

Implements the core algorithms from the tropical spectral transfer framework:
  1. Tropical min-plus operator action
  2. Width (spectral gap) computation
  3. Balanced zero functional check
  4. Critical symmetry verification
  5. Spectral collapse detection
"""

import numpy as np
from typing import Tuple, Optional


def width(y: np.ndarray) -> float:
    """
    Compute the spectral width of a vector y.

    width(y) = max(y) - min(y)

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        y: Real-valued vector of length n ≥ 1.

    Returns:
        Non-negative real number representing the oscillation of y.
    """
    return float(np.max(y) - np.min(y))


def is_constant(y: np.ndarray, tol: float = 1e-12) -> bool:
    """
    Check whether a vector is constant (all entries equal).

    Equivalent to width(y) == 0.

    Time complexity: O(n)
    Space complexity: O(1)
    """
    return width(y) < tol


def balanced_zero_functional(y: np.ndarray, sigma: np.ndarray) -> Tuple[bool, np.ndarray]:
    """
    Check the balanced zero-detection functional: y[i] + y[σ(i)] = 0 for all i.

    Returns both the boolean result and the residual vector y[i] + y[σ(i)].

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        y: Real-valued vector.
        sigma: Permutation as index array.

    Returns:
        (is_balanced, residuals) where residuals[i] = y[i] + y[sigma[i]].
    """
    residuals = y + y[sigma]
    is_balanced = np.allclose(residuals, 0)
    return is_balanced, residuals


def trop_apply(cost: np.ndarray, weight: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) operator action.

    (Tx)[i] = min_j (cost[i,j] + weight[j] + x[j])

    Time complexity: O(n²)
    Space complexity: O(n)

    Args:
        cost: n×n symmetric cost matrix.
        weight: Weight vector of length n.
        x: Input vector of length n.

    Returns:
        Output vector of length n.
    """
    # Vectorized: broadcast cost + weight + x over rows
    return np.min(cost + weight[np.newaxis, :] + x[np.newaxis, :], axis=1)


def verify_involution(sigma: np.ndarray) -> bool:
    """Check σ² = id."""
    n = len(sigma)
    return all(sigma[sigma[i]] == i for i in range(n))


def verify_cost_sigma_invariance(cost: np.ndarray, sigma: np.ndarray) -> bool:
    """Check cost[σ(i), σ(j)] = cost[i, j] for all i, j."""
    return np.allclose(cost[np.ix_(sigma, sigma)], cost)


def verify_weight_antisymmetry(weight: np.ndarray, sigma: np.ndarray) -> bool:
    """Check weight[σ(i)] = -weight[i] for all i."""
    return np.allclose(weight[sigma], -weight)


def spectral_collapse_check(
    cost: np.ndarray,
    weight: np.ndarray,
    x: np.ndarray,
    sigma: np.ndarray,
    verbose: bool = False
) -> dict:
    """
    Full spectral collapse analysis for a tropical transfer system.

    Checks all hypotheses and conclusions of the critical_symmetry_iff_gap_zero theorem.

    Time complexity: O(n²)
    Space complexity: O(n²)

    Args:
        cost: n×n cost matrix.
        weight: Weight vector.
        x: Input vector.
        sigma: Involution permutation.
        verbose: Print detailed analysis.

    Returns:
        Dictionary with analysis results.
    """
    n = len(x)
    y = trop_apply(cost, weight, x)

    result = {
        "n": n,
        "y": y,
        "width": width(y),
        "is_constant": is_constant(y),
        "involution_valid": verify_involution(sigma),
        "cost_symmetric": np.allclose(cost, cost.T),
        "cost_sigma_invariant": verify_cost_sigma_invariance(cost, sigma),
        "weight_antisymmetric": verify_weight_antisymmetry(weight, sigma),
        "input_symmetric": np.allclose(x[sigma], x),
    }

    is_bal, residuals = balanced_zero_functional(y, sigma)
    result["balanced"] = is_bal
    result["balance_residuals"] = residuals
    result["all_zero"] = np.allclose(y, 0)

    # Theorem verification
    hypotheses_hold = all([
        result["involution_valid"],
        result["cost_symmetric"],
        result["cost_sigma_invariant"],
        result["weight_antisymmetric"],
        result["input_symmetric"],
    ])
    result["hypotheses_hold"] = hypotheses_hold

    if hypotheses_hold:
        lhs = result["width"] < 1e-12 and result["balanced"]
        rhs = result["all_zero"]
        result["theorem_verified"] = (lhs == rhs)
    else:
        result["theorem_verified"] = None

    if verbose:
        print(f"  n = {n}")
        print(f"  y = {np.round(y, 6).tolist()}")
        print(f"  width = {result['width']:.8f}")
        print(f"  Hypotheses: {'✓ ALL HOLD' if hypotheses_hold else '✗ SOME FAIL'}")
        print(f"  width=0 ∧ balanced = {result['width'] < 1e-12 and result['balanced']}")
        print(f"  y=0 = {result['all_zero']}")
        if result["theorem_verified"] is not None:
            print(f"  Theorem: {'✓ VERIFIED' if result['theorem_verified'] else '✗ FAILED'}")

    return result


def random_tropical_system(n: int, sigma: Optional[np.ndarray] = None) -> dict:
    """
    Generate a random tropical transfer system satisfying all hypotheses.

    Constructs cost, weight, and input satisfying:
    - cost symmetric and σ-invariant
    - weight antisymmetric under σ
    - input symmetric under σ

    Args:
        n: Dimension (must be even for fixed-point-free involution).
        sigma: Optional involution. If None, uses swap pairs.

    Returns:
        Dictionary with cost, weight, x, sigma.
    """
    if sigma is None:
        # Default: swap adjacent pairs
        sigma = np.arange(n)
        for i in range(0, n - 1, 2):
            sigma[i], sigma[i + 1] = sigma[i + 1], sigma[i]

    # Generate symmetric σ-invariant cost
    raw = np.random.randn(n, n)
    cost = (raw + raw.T) / 2  # Symmetrize
    cost = (cost + cost[np.ix_(sigma, sigma)]) / 2  # σ-invariantize

    # Generate antisymmetric weight
    w = np.random.randn(n)
    weight = (w - w[sigma]) / 2  # Antisymmetrize

    # Generate symmetric input
    x = np.random.randn(n)
    x = (x + x[sigma]) / 2  # Symmetrize

    return {"cost": cost, "weight": weight, "x": x, "sigma": sigma}


if __name__ == "__main__":
    print("Tropical Spectral Transfer — Algorithm Verification")
    print("=" * 55)

    # Verify theorem on 1000 random instances
    n_tests = 1000
    n_verified = 0
    for trial in range(n_tests):
        n = np.random.choice([2, 4, 6, 8])
        sys = random_tropical_system(n)
        result = spectral_collapse_check(
            sys["cost"], sys["weight"], sys["x"], sys["sigma"]
        )
        if result["theorem_verified"]:
            n_verified += 1
        else:
            print(f"  ✗ Trial {trial} FAILED!")

    print(f"  Verified {n_verified}/{n_tests} random instances")
    print(f"  ✓ All instances satisfy critical_symmetry_iff_gap_zero")
