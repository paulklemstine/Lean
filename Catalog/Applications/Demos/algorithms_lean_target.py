"""
Algorithms derived from the Gibbs Variational Principle.

Implements:
1. Numerically stable log-sum-exp
2. Softmax with temperature
3. Entropy-regularized optimization via the variational formula
4. Free energy computation and KL divergence
5. Temperature annealing for smooth-to-tropical transition
"""

import numpy as np
from typing import Tuple, Optional


def log_sum_exp(x: np.ndarray, tau: float = 1.0) -> float:
    """Numerically stable log-sum-exp: τ * log(∑ exp(xᵢ/τ)).

    Uses the max-shift trick: τ * (m/τ + log(∑ exp((xᵢ-m)/τ))) where m = max(x).

    Complexity: O(n) time, O(1) extra space.

    Args:
        x: Score vector of length n.
        tau: Temperature parameter (must be > 0).

    Returns:
        τ * log(∑ᵢ exp(xᵢ/τ))

    Example:
        >>> log_sum_exp(np.array([1.0, 2.0, 3.0]), tau=1.0)
        3.4076...
    """
    assert tau > 0, "Temperature must be positive"
    m = np.max(x)
    return tau * (m / tau + np.log(np.sum(np.exp((x - m) / tau))))


def softmax(x: np.ndarray, tau: float = 1.0) -> np.ndarray:
    """Softmax / Gibbs distribution: qᵢ = exp(xᵢ/τ) / Z.

    This is the unique optimizer of the entropy-regularized linear objective:
        q = argmax_{p ∈ Δₙ} { ⟨x, p⟩ + τ H(p) }

    Complexity: O(n) time, O(n) space.

    Args:
        x: Score vector of length n.
        tau: Temperature (> 0). Small τ → concentrated; large τ → uniform.

    Returns:
        Probability vector of length n.

    Example:
        >>> softmax(np.array([1.0, 2.0, 3.0]), tau=1.0)
        array([0.0900, 0.2447, 0.6652])
    """
    assert tau > 0, "Temperature must be positive"
    m = np.max(x)
    e = np.exp((x - m) / tau)
    return e / np.sum(e)


def shannon_entropy(p: np.ndarray) -> float:
    """Shannon entropy: H(p) = -∑ pᵢ log pᵢ with 0 log 0 = 0.

    Complexity: O(n) time, O(1) extra space.

    Args:
        p: Probability vector (nonneg, sums to 1).

    Returns:
        Entropy in nats.

    Example:
        >>> shannon_entropy(np.array([0.25, 0.25, 0.25, 0.25]))
        1.3862...  # = log(4)
    """
    mask = p > 0
    return -np.sum(p[mask] * np.log(p[mask]))


def free_energy_objective(
    x: np.ndarray, p: np.ndarray, tau: float = 1.0
) -> float:
    """Free energy objective: F_τ(x, p) = ⟨x, p⟩ + τ H(p).

    By the Gibbs variational principle:
        F_τ(x, p) ≤ τ log Z  for all p ∈ Δₙ
        F_τ(x, q) = τ log Z  for q = softmax(x/τ)

    Complexity: O(n) time.

    Args:
        x: Score vector.
        p: Probability vector.
        tau: Temperature.

    Returns:
        Free energy value.
    """
    return np.dot(x, p) + tau * shannon_entropy(p)


def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """KL divergence: KL(p ∥ q) = ∑ pᵢ log(pᵢ/qᵢ) with 0 log 0 = 0.

    By Gibbs inequality: KL(p ∥ q) ≥ 0 with equality iff p = q.

    Complexity: O(n) time.

    Args:
        p: First probability vector.
        q: Second probability vector (must be strictly positive on support of p).

    Returns:
        KL divergence in nats.
    """
    mask = p > 0
    assert np.all(q[mask] > 0), "q must be positive on support of p"
    return np.sum(p[mask] * np.log(p[mask] / q[mask]))


def entropy_regularized_optimize(
    x: np.ndarray,
    tau: float = 1.0,
) -> Tuple[np.ndarray, float]:
    """Solve the entropy-regularized optimization:
        max_{p ∈ Δₙ} { ⟨x, p⟩ + τ H(p) }

    By the Gibbs variational principle, the solution is:
        p* = softmax(x/τ)
        optimal value = τ log(∑ exp(xᵢ/τ))

    This is exact and requires no iterative optimization.

    Complexity: O(n) time.

    Args:
        x: Linear objective coefficients.
        tau: Entropy regularization strength.

    Returns:
        (optimal_p, optimal_value) tuple.
    """
    p_star = softmax(x, tau)
    value = log_sum_exp(x, tau)
    return p_star, value


def temperature_anneal(
    x: np.ndarray,
    tau_start: float = 10.0,
    tau_end: float = 0.01,
    n_steps: int = 100,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Demonstrate the tropical limit via temperature annealing.

    As τ → 0⁺:
        τ log(∑ exp(xᵢ/τ)) → max(x)
        softmax(x/τ) → argmax indicator

    Complexity: O(n * n_steps) time.

    Args:
        x: Score vector.
        tau_start: Initial (high) temperature.
        tau_end: Final (low) temperature.
        n_steps: Number of annealing steps.

    Returns:
        (taus, lse_values, softmax_distributions) arrays.
    """
    taus = np.geomspace(tau_start, tau_end, n_steps)
    lse_values = np.array([log_sum_exp(x, t) for t in taus])
    softmax_dists = np.array([softmax(x, t) for t in taus])
    return taus, lse_values, softmax_dists


def verify_variational_principle(
    x: np.ndarray, tau: float, n_random: int = 1000, seed: int = 42
) -> dict:
    """Numerically verify all components of the Gibbs variational principle.

    Checks:
    1. Attainment: F(x, q) = τ log Z
    2. Upper bound: F(x, p) ≤ τ log Z for random p
    3. KL decomposition: F(x, p) = τ log Z - τ KL(p ∥ q)
    4. KL nonnegativity

    Args:
        x: Score vector.
        tau: Temperature.
        n_random: Number of random probability vectors to test.
        seed: Random seed.

    Returns:
        Dictionary of verification results.
    """
    np.random.seed(seed)
    n = len(x)

    lse = log_sum_exp(x, tau)
    q = softmax(x, tau)
    fe_q = free_energy_objective(x, q, tau)

    results = {
        "lse": lse,
        "softmax": q,
        "attainment_gap": abs(lse - fe_q),
        "upper_bound_violations": 0,
        "kl_negative_count": 0,
        "decomposition_max_error": 0.0,
        "n_tests": n_random,
    }

    for _ in range(n_random):
        alpha = np.random.exponential(1.0, n)
        p = alpha / alpha.sum()

        fe_p = free_energy_objective(x, p, tau)
        kl_val = kl_divergence(p, q)

        if fe_p > lse + 1e-10:
            results["upper_bound_violations"] += 1
        if kl_val < -1e-10:
            results["kl_negative_count"] += 1

        decomp_error = abs(fe_p - (lse - tau * kl_val))
        results["decomposition_max_error"] = max(
            results["decomposition_max_error"], decomp_error
        )

    results["all_passed"] = (
        results["attainment_gap"] < 1e-10
        and results["upper_bound_violations"] == 0
        and results["kl_negative_count"] == 0
        and results["decomposition_max_error"] < 1e-8
    )

    return results


if __name__ == "__main__":
    # Quick algorithm demonstrations
    x = np.array([1.0, 3.0, 2.0, 0.5])

    print("=== Entropy-Regularized Optimization ===")
    for tau in [0.1, 1.0, 5.0]:
        p_star, value = entropy_regularized_optimize(x, tau)
        print(f"τ={tau:.1f}: p*={np.round(p_star, 4)}, value={value:.4f}")

    print("\n=== Verification ===")
    results = verify_variational_principle(x, tau=1.0)
    for k, v in results.items():
        print(f"  {k}: {v}")

    print("\n=== Temperature Annealing ===")
    taus, lse_vals, _ = temperature_anneal(x, tau_start=5, tau_end=0.01, n_steps=10)
    print(f"max(x) = {np.max(x)}")
    for t, l in zip(taus, lse_vals):
        print(f"  τ={t:.4f}: τ log Z = {l:.6f}")
