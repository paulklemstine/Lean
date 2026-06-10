#!/usr/bin/env python3
"""
Algorithms for Probabilistic Lorentzian Stability
==================================================

Implements the certified stability checker and related algorithms
from the formal verification.

Key algorithms:
1. Certified signature survival checker
2. Spectral gap computation
3. Random-scale bound verification
4. Critical exponent estimator
"""

import numpy as np
from typing import Tuple, Optional


def compute_lorentzian_gap(A: np.ndarray) -> Tuple[float, bool]:
    """
    Compute the Lorentzian spectral gap of a symmetric matrix.

    For a matrix with Lorentzian signature (exactly one positive eigenvalue),
    the gap is min(λ_+, -λ_2) where λ_+ is the positive eigenvalue and
    λ_2 is the largest nonpositive eigenvalue.

    Parameters
    ----------
    A : np.ndarray
        Symmetric matrix (n x n).

    Returns
    -------
    gap : float
        The Lorentzian spectral gap. Returns 0 if not Lorentzian.
    is_lorentzian : bool
        Whether A has Lorentzian signature.

    Time complexity: O(n^3) for eigendecomposition.
    Space complexity: O(n^2).
    """
    n = A.shape[0]
    eigvals = np.sort(np.linalg.eigvalsh(A))

    # Count positive/negative eigenvalues (with tolerance)
    tol = 1e-10 * np.max(np.abs(eigvals)) if n > 0 else 1e-10
    n_positive = np.sum(eigvals > tol)

    if n_positive != 1:
        return 0.0, False

    # Positive eigenvalue is the largest
    lambda_plus = eigvals[-1]
    # Largest nonpositive eigenvalue
    lambda_2 = eigvals[-2]

    gap = min(lambda_plus, -lambda_2)
    return max(gap, 0.0), True


def check_random_stability(
    gap: float, C: float, delta: float, n: int
) -> Tuple[bool, float]:
    """
    Certified random stability checker.

    Checks whether C · √n · δ ≤ gap (the gap condition).
    This is the formal decision rule from the verified theorem
    `certified_random_stability_sound`.

    Parameters
    ----------
    gap : float
        The Lorentzian spectral gap ε.
    C : float
        Random scale constant.
    delta : float
        Entry-wise perturbation bound.
    n : int
        Matrix dimension.

    Returns
    -------
    is_stable : bool
        True if the perturbation is certified to preserve signature.
    margin : float
        gap - C·√n·δ (positive means safe).

    Time complexity: O(1).
    """
    perturbation_bound = C * np.sqrt(n) * delta
    margin = gap - perturbation_bound
    return margin >= 0, margin


def check_deterministic_stability(
    gap: float, delta: float, n: int
) -> Tuple[bool, float]:
    """
    Deterministic stability checker (worst-case bound).

    Checks whether n · δ ≤ gap.

    Parameters
    ----------
    gap : float
        The Lorentzian spectral gap ε.
    delta : float
        Entry-wise perturbation bound.
    n : int
        Matrix dimension.

    Returns
    -------
    is_stable : bool
        True if the perturbation is certified to preserve signature.
    margin : float
        gap - n·δ.
    """
    perturbation_bound = n * delta
    margin = gap - perturbation_bound
    return margin >= 0, margin


def estimate_random_scale_constant(
    n: int, delta: float = 1.0, n_trials: int = 500
) -> float:
    """
    Empirically estimate the random scale constant C such that
    ‖E‖_op ≤ C · √n · δ with high probability.

    Uses the 99th percentile of observed operator norms.

    Parameters
    ----------
    n : int
        Matrix dimension.
    delta : float
        Entry-wise perturbation bound.
    n_trials : int
        Number of random trials.

    Returns
    -------
    C : float
        Estimated random scale constant.

    Time complexity: O(n_trials · n^3).
    """
    norms = []
    for _ in range(n_trials):
        E = np.random.uniform(-delta, delta, size=(n, n))
        E = (E + E.T) / 2
        op_norm = np.max(np.abs(np.linalg.eigvalsh(E)))
        norms.append(op_norm)

    # Use 99th percentile as high-probability bound
    p99 = np.percentile(norms, 99)
    C = p99 / (np.sqrt(n) * delta)
    return C


def certified_stability_pipeline(
    A: np.ndarray, delta: float, C: Optional[float] = None,
    n_estimation_trials: int = 500
) -> dict:
    """
    Full certified stability pipeline.

    1. Compute the Lorentzian gap of A.
    2. Estimate or use provided C.
    3. Check both deterministic and random stability conditions.
    4. Report the certified tolerance.

    Parameters
    ----------
    A : np.ndarray
        Symmetric matrix with (presumed) Lorentzian signature.
    delta : float
        Entry-wise perturbation bound.
    C : float, optional
        Random scale constant. If None, estimated empirically.
    n_estimation_trials : int
        Trials for estimating C if not provided.

    Returns
    -------
    dict with keys:
        'is_lorentzian': bool
        'gap': float
        'C': float
        'deterministic_safe': bool
        'random_safe': bool
        'det_margin': float
        'rand_margin': float
        'max_det_delta': float
        'max_rand_delta': float
    """
    n = A.shape[0]
    gap, is_lor = compute_lorentzian_gap(A)

    if C is None:
        C = estimate_random_scale_constant(n, delta, n_estimation_trials)

    det_safe, det_margin = check_deterministic_stability(gap, delta, n)
    rand_safe, rand_margin = check_random_stability(gap, C, delta, n)

    max_det_delta = gap / n if n > 0 else float('inf')
    max_rand_delta = gap / (C * np.sqrt(n)) if C > 0 and n > 0 else float('inf')

    return {
        'is_lorentzian': is_lor,
        'gap': gap,
        'C': C,
        'n': n,
        'delta': delta,
        'deterministic_safe': det_safe,
        'random_safe': rand_safe,
        'det_margin': det_margin,
        'rand_margin': rand_margin,
        'max_det_delta': max_det_delta,
        'max_rand_delta': max_rand_delta,
        'improvement_factor': np.sqrt(n)
    }


def estimate_critical_exponent_bisection(
    n: int, gap: float = 1.0, n_trials: int = 500,
    threshold: float = 0.5, tol: float = 0.01
) -> float:
    """
    Estimate the critical exponent α* using bisection.

    Finds α* such that the survival probability at δ = gap/n^α
    crosses the threshold.

    Parameters
    ----------
    n : int
        Matrix dimension.
    gap : float
        Spectral gap.
    n_trials : int
        Trials per probability estimate.
    threshold : float
        Survival probability threshold.
    tol : float
        Tolerance for bisection.

    Returns
    -------
    alpha_star : float
        Estimated critical exponent.

    Time complexity: O(log(1/tol) · n_trials · n^3).
    """
    A = np.diag([-gap] * n)
    A[0, 0] = gap

    def survival_prob(alpha):
        delta = gap / (n ** alpha)
        count = 0
        for _ in range(n_trials):
            E = np.random.uniform(-delta, delta, size=(n, n))
            E = (E + E.T) / 2
            if np.sum(np.linalg.eigvalsh(A + E) > 1e-12) == 1:
                count += 1
        return count / n_trials

    lo, hi = 0.2, 1.5
    while hi - lo > tol:
        mid = (lo + hi) / 2
        p = survival_prob(mid)
        if p > threshold:
            hi = mid
        else:
            lo = mid

    return (lo + hi) / 2


# === Example usage ===
if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 60)
    print("  CERTIFIED STABILITY PIPELINE DEMO")
    print("=" * 60)

    for n in [10, 50, 100]:
        A = np.diag([-1.0] * n)
        A[0, 0] = 1.0

        result = certified_stability_pipeline(A, delta=0.01)

        print(f"\n--- n = {n} ---")
        print(f"  Lorentzian: {result['is_lorentzian']}")
        print(f"  Gap: {result['gap']:.4f}")
        print(f"  Estimated C: {result['C']:.4f}")
        print(f"  Deterministic safe (δ={result['delta']}): {result['deterministic_safe']}")
        print(f"  Random safe (δ={result['delta']}): {result['random_safe']}")
        print(f"  Max det δ: {result['max_det_delta']:.6f}")
        print(f"  Max rand δ: {result['max_rand_delta']:.6f}")
        print(f"  Improvement factor (√n): {result['improvement_factor']:.2f}")

    print("\n" + "=" * 60)
    print("  CRITICAL EXPONENT ESTIMATION")
    print("=" * 60)

    for n in [10, 50, 100]:
        alpha = estimate_critical_exponent_bisection(n, n_trials=200)
        print(f"  n={n:4d}: α* ≈ {alpha:.3f}")
