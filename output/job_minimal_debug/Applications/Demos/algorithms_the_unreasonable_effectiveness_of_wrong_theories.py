#!/usr/bin/env python3
"""
Algorithms for Perturbation Theory on Theory Space.
Type-hinted implementations of the key algorithms from the research.
"""

from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple
import math


@dataclass
class PerturbationTheory:
    """A perturbation theory: base + Σ ε^(k+1) * c_k."""
    base: float
    corrections: List[float]
    coupling: float

    @property
    def max_correction(self) -> float:
        """Maximum absolute correction coefficient (M bound)."""
        return max(abs(c) for c in self.corrections) if self.corrections else 0.0

    def partial_sum(self, order: int) -> float:
        """Compute the partial sum T_n = base + Σ_{k<n} ε^(k+1) * c_k."""
        result = self.base
        for k in range(min(order, len(self.corrections))):
            result += self.coupling ** (k + 1) * self.corrections[k]
        return result

    def wrongness_at(self, k: int) -> float:
        """The wrongness at order k: ε^(k+1) * c_k."""
        if k >= len(self.corrections):
            return 0.0
        return self.coupling ** (k + 1) * self.corrections[k]

    def truth_value(self) -> float:
        """The truth value (full series sum)."""
        return self.partial_sum(len(self.corrections))

    def truncation_error(self, order: int) -> float:
        """Absolute error of the order-n truncation."""
        return abs(self.truth_value() - self.partial_sum(order))


def truncation_error_bound(M: float, coupling: float, order: int) -> float:
    """
    Compute the theoretical truncation error bound.

    For a theory with GeomBounded corrections (|c_k| ≤ M) and |ε| < 1:
        error ≤ M * |ε|^(n+1) / (1 - |ε|)

    Args:
        M: Upper bound on correction coefficients
        coupling: Perturbation parameter ε
        order: Truncation order n

    Returns:
        Upper bound on the truncation error
    """
    eps = abs(coupling)
    if eps >= 1.0:
        return float('inf')
    return M * eps ** (order + 1) / (1.0 - eps)


def optimal_truncation(theory: PerturbationTheory,
                        tolerance: float = 1e-10) -> Tuple[int, float]:
    """
    Find the optimal truncation order minimizing prediction error.

    Implements the Optimal Truncation Algorithm:
    1. Compute truth value (full series)
    2. Evaluate error at each truncation order
    3. Return the order with minimum error

    Args:
        theory: The perturbation theory to truncate
        tolerance: Numerical tolerance for comparison

    Returns:
        (optimal_order, minimum_error) tuple
    """
    true_val = theory.truth_value()
    best_order = 0
    best_error = abs(true_val - theory.base)

    for n in range(1, len(theory.corrections) + 1):
        pred = theory.partial_sum(n)
        error = abs(true_val - pred)
        if error < best_error - tolerance:
            best_error = error
            best_order = n

    return best_order, best_error


def adaptive_truncation(theory: PerturbationTheory,
                         target_precision: float) -> Tuple[int, float]:
    """
    Find the minimum truncation order achieving target precision.

    Uses the theoretical error bound as a stopping criterion:
    Stop at order n when M * |ε|^(n+1) / (1 - |ε|) < target_precision.

    Args:
        theory: The perturbation theory
        target_precision: Desired precision δ > 0

    Returns:
        (truncation_order, achieved_precision) tuple
    """
    M = theory.max_correction
    eps = abs(theory.coupling)

    if eps >= 1.0:
        raise ValueError("Coupling parameter |ε| must be < 1 for convergence")

    n = 0
    while truncation_error_bound(M, theory.coupling, n) > target_precision:
        n += 1
        if n > len(theory.corrections):
            break

    actual_error = theory.truncation_error(n)
    return n, actual_error


def overshoot_check(c1: float, c2: float) -> dict:
    """
    Check whether the Approximation Overshoot Theorem applies.

    Conditions for base theory to outperform first-order correction:
    1. c1 * c2 ≤ 0 (opposite signs)
    2. |c1| ≤ 2 * |c2| (overshoot condition)

    Args:
        c1: First-order correction
        c2: Second-order correction

    Returns:
        Dictionary with analysis results
    """
    opposite_signs = c1 * c2 <= 0
    overshoot_condition = abs(c1) <= 2 * abs(c2)
    theorem_applies = opposite_signs and overshoot_condition

    base_error = abs(c1 + c2)
    corrected_error = abs(c2)
    base_wins = base_error <= corrected_error

    return {
        "c1": c1,
        "c2": c2,
        "opposite_signs": opposite_signs,
        "overshoot_condition": overshoot_condition,
        "theorem_applies": theorem_applies,
        "base_error": base_error,
        "corrected_error": corrected_error,
        "base_wins": base_wins,
        "theorem_verified": not theorem_applies or base_wins,
    }


def theory_distance(predict1: float, predict2: float) -> float:
    """Compute the theory distance between two predictions."""
    return abs(predict1 - predict2)


def wrongness_series(theory: PerturbationTheory) -> List[float]:
    """
    Compute the wrongness series: cumulative sum of wrongness terms.

    Returns the sequence S_n = Σ_{k<n} w_k where w_k = ε^(k+1) * c_k.
    By the Wrongness Convergence Theorem, this converges to truth - base.
    """
    partial_sums = []
    running_sum = 0.0
    for k in range(len(theory.corrections)):
        running_sum += theory.wrongness_at(k)
        partial_sums.append(running_sum)
    return partial_sums


def phenomenon_selection(theories: List[PerturbationTheory],
                          truncation_order: int) -> Tuple[int, float]:
    """
    Find the phenomenon best-predicted by the truncated theory.

    By the Phenomenon Selection Theorem, the best phenomenon has error
    at most the average error across all phenomena.

    Args:
        theories: List of perturbation theories (one per phenomenon)
        truncation_order: Order at which to truncate

    Returns:
        (best_index, best_error) tuple
    """
    errors = [t.truncation_error(truncation_order) for t in theories]
    best_idx = min(range(len(errors)), key=lambda i: errors[i])
    avg_error = sum(errors) / len(errors)

    assert errors[best_idx] <= avg_error + 1e-15, \
        "Phenomenon Selection Theorem violated!"

    return best_idx, errors[best_idx]


def test_asymptotic_wrongness_conjecture(
    theory: PerturbationTheory
) -> Tuple[bool, float]:
    """
    Test the Asymptotic Wrongness Conjecture for a specific theory.

    For alternating-sign corrections, tests whether:
    |truth - base| ≤ 2 * min_n |truth - T_n|

    Returns:
        (conjecture_holds, ratio) tuple
    """
    true_val = theory.truth_value()
    base_error = abs(true_val - theory.base)

    _, opt_error = optimal_truncation(theory)

    if opt_error < 1e-15:
        return True, 0.0

    ratio = base_error / opt_error
    return ratio <= 2.0, ratio


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    import random
    random.seed(42)

    # Create a sample perturbation theory
    corrections = [random.uniform(-5, 5) for _ in range(30)]
    theory = PerturbationTheory(
        base=1.0,
        corrections=corrections,
        coupling=0.3,
    )

    print("Theory Analysis")
    print(f"  Base: {theory.base}")
    print(f"  Coupling: {theory.coupling}")
    print(f"  Max correction: {theory.max_correction:.4f}")
    print(f"  Truth value: {theory.truth_value():.6f}")

    # Optimal truncation
    opt_n, opt_err = optimal_truncation(theory)
    print(f"\nOptimal truncation: order {opt_n}, error {opt_err:.2e}")

    # Adaptive truncation
    adapt_n, adapt_err = adaptive_truncation(theory, 1e-6)
    print(f"Adaptive truncation (δ=1e-6): order {adapt_n}, error {adapt_err:.2e}")

    # Wrongness series
    ws = wrongness_series(theory)
    print(f"\nWrongness series limit: {ws[-1]:.6f}")
    print(f"Truth - base: {theory.truth_value() - theory.base:.6f}")
    print(f"Match: {abs(ws[-1] - (theory.truth_value() - theory.base)) < 1e-10}")
