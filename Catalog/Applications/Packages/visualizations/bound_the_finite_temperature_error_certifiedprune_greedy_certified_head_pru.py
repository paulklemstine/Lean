"""
Algorithms for Certified Pruning via Log-Sum-Exp Stability
============================================================

Implements the pruning certification algorithms derived from the
finite-temperature pruning law. Given head scores and a temperature,
these algorithms identify which heads can be safely removed and
provide guaranteed upper bounds on the resulting approximation error.

Keywords: certified pruning, attention head redundancy, log-sum-exp stability,
softmax robustness, entropy-compression tradeoff
"""

import numpy as np
from typing import List, Tuple, Optional


def log_sum_exp(x: np.ndarray, tau: float) -> float:
    """
    Numerically stable log-sum-exp at temperature tau.

    LSE_tau(x) = tau * log(sum_i exp(x_i / tau))

    Args:
        x: Array of real scores.
        tau: Temperature parameter (must be > 0).

    Returns:
        The log-sum-exp value.

    Complexity: O(n) time, O(1) space.
    """
    if tau <= 0:
        raise ValueError("Temperature tau must be positive")
    shifted = x / tau
    m = shifted.max()
    return tau * (m + np.log(np.sum(np.exp(shifted - m))))


def compute_pruning_gap(
    x: np.ndarray,
    keep_indices: np.ndarray,
    tau: float
) -> float:
    """
    Compute the exact pruning gap: LSE_tau(x) - LSE_tau(x[keep]).

    Args:
        x: Full score array.
        keep_indices: Indices of heads to keep.
        tau: Temperature.

    Returns:
        The exact gap (non-negative if removed heads are dominated).

    Complexity: O(n) time, O(1) space.
    """
    return log_sum_exp(x, tau) - log_sum_exp(x[keep_indices], tau)


def compute_pruning_bound(
    x: np.ndarray,
    keep_indices: np.ndarray,
    remove_indices: np.ndarray,
    tau: float,
    method: str = "refined"
) -> float:
    """
    Compute an upper bound on the pruning gap.

    Three methods available:
    - "cardinality": tau * log(|R| + 1)  — simplest, uses only count
    - "refined": tau * log(1 + sum_{j in R} exp((x_j - s)/tau))  — tightest
    - "margin": tau * log(1 + |R| * exp(-delta/tau))  — uses uniform gap

    Args:
        x: Full score array.
        keep_indices: Indices of heads to keep.
        remove_indices: Indices of heads to remove.
        tau: Temperature.
        method: One of "cardinality", "refined", "margin".

    Returns:
        Upper bound on the pruning gap.

    Complexity: O(n) time, O(1) space for all methods.
    """
    s = x[keep_indices].max()

    if method == "cardinality":
        return tau * np.log(len(remove_indices) + 1)

    elif method == "refined":
        diffs = (x[remove_indices] - s) / tau
        # Numerically stable
        m = max(diffs.max(), 0.0) if len(diffs) > 0 else 0.0
        inner = np.exp(-m) + np.sum(np.exp(diffs - m))
        return tau * (m + np.log(inner))

    elif method == "margin":
        delta = s - x[remove_indices].max() if len(remove_indices) > 0 else 0.0
        delta = max(delta, 0.0)
        return tau * np.log(1 + len(remove_indices) * np.exp(-delta / tau))

    else:
        raise ValueError(f"Unknown method: {method}")


def certify_prunable_heads(
    x: np.ndarray,
    tau: float,
    max_error: float,
    strategy: str = "greedy"
) -> Tuple[np.ndarray, np.ndarray, float]:
    """
    Identify the largest set of heads that can be pruned within error budget.

    Algorithm (greedy strategy):
    1. Find the maximum score s = max(x).
    2. Sort non-maximal heads by their gap (s - x_j) in decreasing order.
    3. Greedily add heads to the removal set while the certified bound
       remains within max_error.

    Args:
        x: Score array of shape (n,).
        tau: Temperature parameter.
        max_error: Maximum allowable pruning gap.
        strategy: "greedy" — greedy by largest gap first.

    Returns:
        Tuple of (keep_indices, remove_indices, certified_bound).

    Complexity: O(n log n) time (dominated by sorting), O(n) space.
    """
    n = len(x)
    s = x.max()

    # Find all indices achieving the max (must keep at least one)
    max_indices = np.where(np.abs(x - s) < 1e-12)[0]

    # Candidate removal: all non-maximal indices, sorted by gap (largest first)
    candidates = [(i, s - x[i]) for i in range(n) if i not in max_indices]
    candidates.sort(key=lambda t: -t[1])  # largest gap first = cheapest to prune

    keep = list(max_indices)
    remove = []

    for idx, gap in candidates:
        # Test if adding this head to removal set stays within budget
        test_remove = remove + [idx]
        # Use refined bound
        bound = compute_pruning_bound(
            x,
            np.array(keep),
            np.array(test_remove),
            tau,
            method="refined"
        )
        if bound <= max_error:
            remove.append(idx)
        else:
            keep.append(idx)

    keep_arr = np.array(sorted(keep))
    remove_arr = np.array(sorted(remove)) if remove else np.array([], dtype=int)
    final_bound = compute_pruning_bound(
        x, keep_arr, remove_arr, tau, method="refined"
    ) if len(remove_arr) > 0 else 0.0

    return keep_arr, remove_arr, final_bound


def multi_layer_pruning_certificate(
    scores: List[np.ndarray],
    tau: float,
    per_layer_budget: Optional[float] = None,
    total_budget: Optional[float] = None
) -> List[Tuple[np.ndarray, np.ndarray, float]]:
    """
    Certify pruning across multiple layers/attention heads.

    By sub-additivity of the pruning bound across independent layers,
    the total error is at most the sum of per-layer errors.

    Args:
        scores: List of score arrays, one per layer.
        tau: Temperature (same across layers).
        per_layer_budget: Max error per layer (if specified).
        total_budget: Total error budget (split equally if per_layer not given).

    Returns:
        List of (keep, remove, bound) tuples per layer.

    Complexity: O(L * n log n) where L = number of layers, n = heads per layer.
    """
    L = len(scores)
    if per_layer_budget is None:
        if total_budget is None:
            raise ValueError("Must specify per_layer_budget or total_budget")
        per_layer_budget = total_budget / L

    results = []
    for layer_scores in scores:
        keep, remove, bound = certify_prunable_heads(
            layer_scores, tau, per_layer_budget
        )
        results.append((keep, remove, bound))

    return results


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Certified Pruning Algorithm Demo")
    print("=" * 50)

    # Simulate attention head scores
    np.random.seed(42)
    n_heads = 12
    scores = np.array([8.0, 7.5, 3.0, 2.0, 7.8, 1.0, 4.0, 3.5, 7.9, 2.5, 5.0, 1.5])
    tau = 1.0

    print(f"\nHead scores: {scores}")
    print(f"Temperature: τ = {tau}")

    for budget in [0.5, 1.0, 2.0, 3.0]:
        keep, remove, bound = certify_prunable_heads(scores, tau, budget)
        print(f"\n  Budget = {budget:.1f}:")
        print(f"    Keep {len(keep)} heads: {keep}")
        print(f"    Remove {len(remove)} heads: {remove}")
        print(f"    Certified bound: {bound:.6f}")
        print(f"    Compression ratio: {len(remove)/n_heads*100:.0f}%")

    # Multi-layer example
    print("\n\nMulti-Layer Pruning Certificate")
    print("=" * 50)
    layer_scores = [
        np.random.randn(8) * 2 + 5 for _ in range(4)
    ]
    results = multi_layer_pruning_certificate(
        layer_scores, tau=1.0, total_budget=2.0
    )
    total_removed = 0
    total_kept = 0
    for i, (keep, remove, bound) in enumerate(results):
        total_removed += len(remove)
        total_kept += len(keep)
        print(f"  Layer {i}: keep {len(keep)}, remove {len(remove)}, bound = {bound:.4f}")
    print(f"  Total: {total_removed}/{total_removed + total_kept} heads removed "
          f"({total_removed/(total_removed + total_kept)*100:.0f}%)")
