"""
Perturbation-Theoretic Framework: Core Algorithms

Implements the key mathematical constructs from the formal framework:
- Perturbation series truncation and error computation
- Overshoot detection and effectiveness ratio
- Geometric tail bounds
- Optimal truncation order computation
- Approximation landscape analysis
"""

from typing import Callable, List, Tuple, Optional
import math


class PerturbationTheory:
    """A perturbation theory: base value + sequence of corrections."""

    def __init__(self, base: float, corrections: Callable[[int], float]):
        self.base = base
        self.corrections = corrections

    def approx(self, N: int) -> float:
        """N-th order approximation: base + sum of first N corrections."""
        return self.base + sum(self.corrections(k) for k in range(N))

    def trunc_error(self, truth: float, N: int) -> float:
        """Absolute truncation error at order N."""
        return abs(truth - self.approx(N))

    def error_sequence(self, truth: float, max_N: int) -> List[float]:
        """Compute truncation errors for orders 0 through max_N."""
        return [self.trunc_error(truth, N) for N in range(max_N + 1)]


def effectiveness_ratio(current_error: float, correction: float) -> float:
    """
    Compute the effectiveness ratio |correction| / |current_error|.

    Returns:
        0.0 if current_error is 0
        ratio ≥ 0 otherwise

    Interpretation:
        < 1: correction undershoots (always improves)
        = 1: exact correction
        1-2: mild overshoot (may or may not improve)
        ≥ 2: severe overshoot (provably worsens, by Overshoot Theorem)
    """
    if current_error == 0:
        return 0.0
    return abs(correction) / abs(current_error)


def overshoot_check(current_error: float, correction: float) -> Tuple[bool, float]:
    """
    Check if a correction triggers the Overshoot Theorem.

    Returns:
        (is_overshoot, ratio) where is_overshoot is True iff the
        Overshoot Theorem guarantees the correction makes things worse.
    """
    ratio = effectiveness_ratio(current_error, correction)
    same_sign = current_error * correction > 0
    return (same_sign and ratio >= 2.0, ratio)


def geometric_tail_bound(M: float, r: float, N: int) -> float:
    """
    Upper bound on the tail sum |c_N| + |c_{N+1}| + ... for
    geometrically bounded corrections |c_k| ≤ M * r^k.

    Returns M * r^N / (1 - r).
    """
    if r >= 1.0 or r < 0.0:
        raise ValueError(f"Requires 0 ≤ r < 1, got r={r}")
    if M < 0:
        raise ValueError(f"Requires M ≥ 0, got M={M}")
    return M * r ** N / (1 - r)


def optimal_truncation_order(
    M: float, r: float, alpha: float, max_search: int = 100
) -> Tuple[int, float]:
    """
    Find the optimal truncation order N* minimizing
    C(N) = M * r^N / (1-r) + alpha * N.

    Args:
        M: bound on first correction
        r: geometric decay ratio (0 < r < 1)
        alpha: complexity cost per term
        max_search: maximum order to consider

    Returns:
        (N_star, C_star) = (optimal order, minimum cost)
    """
    if r <= 0 or r >= 1:
        raise ValueError(f"Requires 0 < r < 1, got r={r}")

    def cost(N: int) -> float:
        return M * r ** N / (1 - r) + alpha * N

    best_N = 0
    best_cost = cost(0)
    for N in range(1, max_search + 1):
        c = cost(N)
        if c < best_cost:
            best_cost = c
            best_N = N
        # Once cost is increasing, we've passed the minimum
        if c > best_cost and N > best_N + 5:
            break

    return best_N, best_cost


def analytical_optimal_order(M: float, r: float, alpha: float) -> float:
    """
    Analytical formula for the optimal truncation order (continuous relaxation).

    N* = -ln(alpha * (1-r) / (M * ln(1/r))) / ln(1/r)

    This is the continuous minimizer of C(N) = M*r^N/(1-r) + alpha*N.
    The actual optimum is one of floor(N*) or ceil(N*).
    """
    if r <= 0 or r >= 1 or M <= 0 or alpha <= 0:
        raise ValueError("Invalid parameters")
    ln_r_inv = math.log(1 / r)
    arg = alpha * (1 - r) / (M * ln_r_inv)
    if arg <= 0:
        return 0.0
    return -math.log(arg) / ln_r_inv


class ApproxLandscape:
    """
    Approximation landscape: M models × P phenomena.

    Stores errors E[m][p] and complexity κ[m] for each model.
    """

    def __init__(
        self,
        errors: List[List[float]],
        complexity: Optional[List[float]] = None,
    ):
        self.num_models = len(errors)
        self.num_phenomena = len(errors[0]) if errors else 0
        self.errors = errors
        self.complexity = complexity or [0.0] * self.num_models

        # Validate
        for m in range(self.num_models):
            assert len(errors[m]) == self.num_phenomena
            for p in range(self.num_phenomena):
                assert errors[m][p] >= 0, f"Negative error at ({m},{p})"

    def avg_error(self, m: int) -> float:
        """Average error of model m across all phenomena."""
        return sum(self.errors[m]) / self.num_phenomena

    def best_error(self, m: int) -> float:
        """Best-case (minimum) error of model m."""
        return min(self.errors[m])

    def best_phenomenon(self, m: int) -> int:
        """Index of the best phenomenon for model m."""
        return self.errors[m].index(min(self.errors[m]))

    def global_avg_error(self) -> float:
        """Global average error across all models and phenomena."""
        return sum(self.avg_error(m) for m in range(self.num_models)) / self.num_models

    def phenomenon_selection(self, m: int) -> List[int]:
        """Find all phenomena where model m achieves ≤ average error."""
        avg = self.avg_error(m)
        return [p for p in range(self.num_phenomena) if self.errors[m][p] <= avg]

    def cross_model_selection(self) -> List[int]:
        """Find models with average error ≤ global average."""
        global_avg = self.global_avg_error()
        return [m for m in range(self.num_models) if self.avg_error(m) <= global_avg]
