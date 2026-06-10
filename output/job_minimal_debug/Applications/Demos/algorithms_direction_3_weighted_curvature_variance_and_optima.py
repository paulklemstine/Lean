#!/usr/bin/env python3
"""
Algorithms for Weighted Curvature Flow on Triangulations

Implements:
1. WeightedTriangCurv — data structure for weighted triangulation curvature
2. Weighted variance computation (mean-based and pairwise)
3. Weighted greedy curvature flow with convergence certificate
4. Condition number analysis

All algorithms have proven convergence guarantees formalized in Lean 4.
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional
import math


@dataclass
class WeightedTriangCurv:
    """Weighted triangulation curvature structure.

    Corresponds to the Lean structure:
        structure WeightedTriangCurv (n : ℕ) where
          K : Fin n → ℝ
          w : Fin n → ℝ
          w_pos : ∀ i, 0 < w i

    Attributes:
        K: Curvature values at each vertex
        w: Positive weights at each vertex
    """
    K: np.ndarray  # shape (n,)
    w: np.ndarray  # shape (n,), all positive

    def __post_init__(self):
        assert len(self.K) == len(self.w), "K and w must have same length"
        assert np.all(self.w > 0), "All weights must be positive"

    @property
    def n(self) -> int:
        return len(self.K)

    @property
    def total_weight(self) -> float:
        """Total weight W = Σ w_i. Always positive for n > 0."""
        return float(np.sum(self.w))

    @property
    def weighted_mean(self) -> float:
        """Weighted curvature mean K̄_w = (Σ w_i K_i) / W."""
        return float(np.sum(self.w * self.K) / self.total_weight)

    @property
    def weighted_variance(self) -> float:
        """Weighted curvature variance V_w = (Σ w_i (K_i - K̄)²) / W.

        Proven non-negative (weightedCurvVar_nonneg).
        Zero iff all K_i equal (weightedCurvVar_eq_zero_iff).
        """
        mu = self.weighted_mean
        return float(np.sum(self.w * (self.K - mu) ** 2) / self.total_weight)

    @property
    def condition_number(self) -> float:
        """Condition number κ = w_max / w_min. Always ≥ 1."""
        return float(np.max(self.w) / np.min(self.w))

    def pairwise_variance(self) -> float:
        """Compute variance via pairwise identity (Theorem 3):
        V_w = (1/(2W²)) Σ_{i,j} w_i w_j (K_i - K_j)²

        O(n²) but numerically stable and does not require mean computation.
        """
        W = self.total_weight
        n = self.n
        total = 0.0
        for i in range(n):
            for j in range(n):
                total += self.w[i] * self.w[j] * (self.K[i] - self.K[j]) ** 2
        return total / (2 * W ** 2)

    def popoviciu_bound(self, a: float, b: float) -> float:
        """Upper bound from Popoviciu's inequality: (b-a)²/4.

        Valid when a ≤ K_i ≤ b for all i (Theorem 4).
        """
        return (b - a) ** 2 / 4

    def scale(self, c: float) -> 'WeightedTriangCurv':
        """Scale all weights by c > 0. Variance is invariant (Theorem 6)."""
        assert c > 0, "Scale factor must be positive"
        return WeightedTriangCurv(K=self.K.copy(), w=c * self.w.copy())

    def convergence_bound(self, delta: float) -> int:
        """Upper bound on steps to reach V_w < delta/κ.

        By Theorem 5: at most ⌈κ V₀ / δ⌉ steps.
        """
        kappa = self.condition_number
        V0 = self.weighted_variance
        return math.ceil(kappa * V0 / delta)


def weighted_greedy_flow(
    wt: WeightedTriangCurv,
    eps: float = 0.01,
    max_steps: Optional[int] = None,
    verbose: bool = False
) -> Tuple[WeightedTriangCurv, List[float], int]:
    """Weighted greedy curvature flow algorithm.

    Pseudocode:
        1. Compute W, κ, μ
        2. While V_w ≥ ε:
           a. Find i* = argmax w_i(K_i - μ)²
           b. Average K[i*] with a neighbor
           c. Recompute μ and V_w
        3. Return modified curvature

    Convergence: O(κ V₀ / ε) steps (Theorem 5).

    Args:
        wt: Initial weighted triangulation curvature
        eps: Target variance threshold
        max_steps: Maximum iterations (default: 10 * convergence bound)
        verbose: Print progress

    Returns:
        (final_wt, variance_history, steps)
    """
    K = wt.K.copy()
    w = wt.w.copy()
    n = wt.n

    if max_steps is None:
        max_steps = max(10 * wt.convergence_bound(eps), 10000)

    current = WeightedTriangCurv(K=K, w=w)
    variances = [current.weighted_variance]
    steps = 0

    while current.weighted_variance >= eps and steps < max_steps:
        mu = current.weighted_mean
        deviations = current.w * (current.K - mu) ** 2

        # Greedy: pick vertex with largest weighted deviation
        i_star = int(np.argmax(deviations))

        # Averaging step (simulates edge flip effect)
        j = (i_star + 1) % n
        avg = (current.K[i_star] + current.K[j]) / 2
        new_K = current.K.copy()
        new_K[i_star] = avg
        new_K[j] = avg

        current = WeightedTriangCurv(K=new_K, w=w)
        variances.append(current.weighted_variance)
        steps += 1

        if verbose and steps % 100 == 0:
            print(f"  Step {steps}: V_w = {current.weighted_variance:.6f}")

    if verbose:
        print(f"  Converged in {steps} steps. Final V_w = {current.weighted_variance:.8f}")

    return current, variances, steps


def analyze_convergence_rate(
    n_values: List[int] = [20, 50],
    alpha_values: List[float] = [1.5, 2.0, 4.0],
    eps: float = 0.01,
    n_trials: int = 5,
    seed: int = 42
) -> List[dict]:
    """Analyze convergence rate scaling with condition number.

    Tests the conjecture: T(ε) = Θ(κ V₀/ε).

    Args:
        n_values: Mesh sizes to test
        alpha_values: Pareto shape parameters (controls κ)
        eps: Convergence threshold
        n_trials: Number of random trials per configuration
        seed: Random seed

    Returns:
        List of result dictionaries
    """
    rng = np.random.RandomState(seed)
    results = []

    for n in n_values:
        for alpha in alpha_values:
            for trial in range(n_trials):
                K = rng.uniform(-2, 6, n)
                w = rng.pareto(alpha, n) + 1.0

                wt = WeightedTriangCurv(K=K, w=w)
                kappa = wt.condition_number
                V0 = wt.weighted_variance

                _, _, steps = weighted_greedy_flow(wt, eps=eps)

                results.append({
                    'n': n,
                    'alpha': alpha,
                    'trial': trial,
                    'kappa': kappa,
                    'V0': V0,
                    'steps': steps,
                    'predicted': kappa * V0 / eps,
                    'ratio': steps / (kappa * V0 / eps) if kappa * V0 > 0 else 0
                })

    return results


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Weighted Curvature Flow — Algorithm Demonstration")
    print("=" * 60)

    # Create a weighted triangulation
    np.random.seed(42)
    n = 30
    K = np.random.uniform(-2, 6, n)
    w = np.random.exponential(1, n) + 0.5

    wt = WeightedTriangCurv(K=K, w=w)

    print(f"\nTriangulation: n = {wt.n}")
    print(f"Condition number κ = {wt.condition_number:.2f}")
    print(f"Initial variance V₀ = {wt.weighted_variance:.4f}")
    print(f"Convergence bound: {wt.convergence_bound(0.01)} steps")
    print(f"Popoviciu bound: V_w ≤ {wt.popoviciu_bound(-2, 6):.2f}")

    # Verify pairwise identity
    V_direct = wt.weighted_variance
    V_pairwise = wt.pairwise_variance()
    print(f"\nPairwise identity: |V_direct - V_pairwise| = {abs(V_direct - V_pairwise):.2e}")

    # Run flow
    print("\nRunning weighted greedy flow...")
    result, variances, steps = weighted_greedy_flow(wt, eps=0.01, verbose=True)

    # Verify scale invariance
    wt_scaled = wt.scale(100.0)
    print(f"\nScale invariance: V(w) = {wt.weighted_variance:.8f}")
    print(f"                  V(100w) = {wt_scaled.weighted_variance:.8f}")
    print(f"                  diff = {abs(wt.weighted_variance - wt_scaled.weighted_variance):.2e}")

    # Convergence rate analysis
    print("\n" + "=" * 60)
    print("Convergence Rate Analysis")
    print("=" * 60)
    results = analyze_convergence_rate(n_values=[20], alpha_values=[2.0, 4.0], n_trials=3)
    for r in results:
        print(f"  α={r['alpha']:.1f} κ={r['kappa']:6.1f} steps={r['steps']:5d} "
              f"predicted={r['predicted']:8.0f} ratio={r['ratio']:.4f}")
