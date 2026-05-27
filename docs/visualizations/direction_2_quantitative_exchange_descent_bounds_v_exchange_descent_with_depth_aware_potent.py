"""
Depth-Sensitive Exchange Descent: Core Algorithms

Implements the key algorithms from the depth-sensitive exchange descent theory:
- Exchange step generation
- Depth-aware potential computation
- Descent trajectory simulation
- Certificate depth estimation
- Runtime bound computation

Author: Harmonic Research
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Callable
from dataclasses import dataclass
import math


@dataclass
class ExchangeFamily:
    """A finite exchange family S ⊆ Z^d with objective function."""
    d: int  # dimension
    points: np.ndarray  # shape (n, d), integer lattice points
    objective: Callable[[np.ndarray], float]  # objective function f: Z^d -> R

    @property
    def size(self) -> int:
        return len(self.points)

    def diameter(self) -> int:
        """Compute the L1 exchange diameter of S."""
        n = len(self.points)
        max_dist = 0
        for i in range(n):
            for j in range(i + 1, n):
                dist = int(np.sum(np.abs(self.points[i] - self.points[j])))
                max_dist = max(max_dist, dist)
        return max_dist

    def objective_values(self) -> np.ndarray:
        """Compute f(x) for all x in S."""
        return np.array([self.objective(x) for x in self.points])


def is_exchange_step(x: np.ndarray, y: np.ndarray) -> bool:
    """Check if y is obtained from x by an exchange step (±1 on exactly 2 coords)."""
    diff = y - x
    nonzero = np.nonzero(diff)[0]
    if len(nonzero) != 2:
        return False
    i, j = nonzero
    return ((diff[i] == 1 and diff[j] == -1) or (diff[i] == -1 and diff[j] == 1))


def find_improving_exchanges(
    family: ExchangeFamily, x_idx: int
) -> List[int]:
    """Find all indices of points reachable by improving exchange steps from x."""
    x = family.points[x_idx]
    fx = family.objective(x)
    improving = []
    for j, y in enumerate(family.points):
        if j != x_idx and is_exchange_step(x, y) and family.objective(y) < fx:
            improving.append(j)
    return improving


def depth_decrement(d: int, k: int, c: float = 1.0) -> float:
    """Compute the depth-aware decrement δ_k = c / d^(d-k)."""
    if d == 0:
        return c
    exponent = d - k
    return c / (d ** exponent)


def certificate_potential(
    x: np.ndarray, f_val: float, d: int, k: int,
    opt_val: float, diameter: int, lam: float = 1.0
) -> float:
    """
    Compute the depth-aware certificate potential:
    Φ_k(x) = (f(x) - f*) + λ_k · ρ(x)

    where ρ is an estimate of the exchange distance to optimum,
    and λ_k scales with the depth parameter.
    """
    obj_gap = f_val - opt_val
    # Scale factor depends on depth
    lambda_k = lam * depth_decrement(d, k)
    return obj_gap + lambda_k * diameter


def run_exchange_descent(
    family: ExchangeFamily,
    start_idx: int,
    max_steps: int = 10000,
    strategy: str = "greedy"
) -> Tuple[List[int], List[float]]:
    """
    Run exchange descent from a starting point.

    Args:
        family: The exchange family
        start_idx: Index of starting point in family.points
        max_steps: Maximum number of steps
        strategy: "greedy" (best improving) or "first" (first improving)

    Returns:
        trajectory: List of point indices visited
        obj_values: List of objective values along trajectory
    """
    trajectory = [start_idx]
    obj_values = [family.objective(family.points[start_idx])]

    current = start_idx
    for _ in range(max_steps):
        improving = find_improving_exchanges(family, current)
        if not improving:
            break  # Local (and global under DLC) minimum reached

        if strategy == "greedy":
            # Pick the best improving exchange
            best = min(improving, key=lambda j: family.objective(family.points[j]))
        else:
            # Pick the first improving exchange
            best = improving[0]

        current = best
        trajectory.append(current)
        obj_values.append(family.objective(family.points[current]))

    return trajectory, obj_values


def theoretical_bound(d: int, k: int, D: int, c: float = 1.0, C0: float = 1.0) -> float:
    """
    Compute the theoretical descent bound: C0 * D * d^(d-k) / c.

    At k=d (maximal depth), this becomes C0 * D / c (linear in D).
    """
    if d == 0:
        return C0 * D / c
    return C0 * D * (d ** (d - k)) / c


def estimate_certificate_depth(
    family: ExchangeFamily,
    num_trials: int = 50
) -> int:
    """
    Estimate the certificate depth of an exchange family by running
    descent from random starting points and analyzing convergence.

    Higher depth corresponds to faster convergence (fewer steps relative
    to the theoretical bound at each depth level).
    """
    D = max(family.diameter(), 1)
    d = family.d
    if d == 0:
        return 0

    # Run descent from multiple starting points
    step_counts = []
    for _ in range(num_trials):
        start = np.random.randint(0, family.size)
        traj, _ = run_exchange_descent(family, start)
        step_counts.append(len(traj) - 1)

    if not step_counts:
        return 0

    avg_steps = np.mean(step_counts)

    # Find the depth k that best matches: avg_steps ≈ C * d^(d-k) * D
    # i.e., log(avg_steps / D) ≈ (d-k) * log(d) + log(C)
    best_k = 0
    best_fit = float('inf')
    for k in range(d + 1):
        bound = theoretical_bound(d, k, D)
        if bound > 0:
            ratio = avg_steps / bound
            fit = abs(np.log(max(ratio, 1e-10)))
            if fit < best_fit:
                best_fit = fit
                best_k = k

    return best_k


def generate_exchange_family_separable(
    d: int, range_per_coord: int = 3, log_concave_depth: int = 1
) -> ExchangeFamily:
    """
    Generate an exchange family with separable objective from log-concave weights.

    The objective is f(x) = Σ_i w_i(x_i), where each w_i is constructed
    to be k-fold log-concave (approximately).

    Args:
        d: dimension
        range_per_coord: range of each coordinate (0 to range_per_coord-1)
        log_concave_depth: target depth of log-concavity for weights
    """
    # Generate points: all integer vectors in [0, range_per_coord-1]^d
    # that have a fixed coordinate sum (exchange constraint)
    total = d * (range_per_coord - 1) // 2
    points = []
    _generate_constrained_points(d, range_per_coord, total, [], points)

    if not points:
        # Fallback: use all points with sum in a range
        for total_try in range(d * range_per_coord):
            _generate_constrained_points(d, range_per_coord, total_try, [], points)
            if len(points) >= 10:
                break

    if not points:
        points = [np.zeros(d, dtype=int)]

    points_array = np.array(points, dtype=int)

    # Generate log-concave weights
    weights = []
    for i in range(d):
        w = _make_log_concave_weight(range_per_coord, log_concave_depth, seed=i)
        weights.append(w)

    def objective(x):
        return sum(weights[i][int(x[i]) % len(weights[i])] for i in range(d))

    return ExchangeFamily(d=d, points=points_array, objective=objective)


def _generate_constrained_points(
    d: int, range_per: int, target_sum: int,
    current: list, result: list, max_points: int = 5000
):
    """Generate all d-dimensional integer vectors with fixed coordinate sum."""
    if len(result) >= max_points:
        return
    if len(current) == d:
        if target_sum == 0:
            result.append(np.array(current, dtype=int))
        return
    remaining = d - len(current) - 1
    for v in range(min(range_per, target_sum + 1)):
        if target_sum - v <= remaining * (range_per - 1):
            _generate_constrained_points(d, range_per, target_sum - v,
                                         current + [v], result, max_points)


def _make_log_concave_weight(
    size: int, depth: int, seed: int = 0
) -> List[float]:
    """
    Construct a weight function that is approximately k-fold log-concave.

    For depth 0: positive weights (random)
    For depth 1: log-concave weights (e.g., Gaussian-like)
    For depth k: k-fold log-concave (e.g., from Gaussian convolutions)
    """
    rng = np.random.RandomState(seed + 42)

    if depth == 0:
        # Just positive
        return list(rng.uniform(0.1, 2.0, size))

    # Base: Gaussian-like log-concave sequence
    center = size / 2.0
    sigma = max(size / (2 + depth), 0.5)
    weights = [math.exp(-(i - center) ** 2 / (2 * sigma ** 2)) for i in range(size)]

    # Higher depth: convolve with itself (convolution preserves log-concavity
    # and increases depth)
    for _ in range(depth - 1):
        new_weights = [0.0] * size
        for i in range(size):
            for j in range(size):
                if 0 <= i - j + size // 2 < size:
                    new_weights[i] += weights[j] * weights[i - j + size // 2] if 0 <= i - j + size // 2 < size else 0
        total = sum(new_weights)
        if total > 0:
            weights = [w / total * size for w in new_weights]

    # Ensure positivity
    min_w = min(weights)
    if min_w <= 0:
        weights = [w - min_w + 0.01 for w in weights]

    return weights


def generate_quadratic_family(
    d: int, range_per_coord: int = 5, perturbation: float = 0.1
) -> ExchangeFamily:
    """
    Generate an exchange family with perturbed quadratic objective.
    These typically have low certificate depth.
    """
    total = d * (range_per_coord - 1) // 2
    points = []
    _generate_constrained_points(d, range_per_coord, total, [], points)

    if not points:
        for total_try in range(d * range_per_coord):
            _generate_constrained_points(d, range_per_coord, total_try, [], points)
            if len(points) >= 10:
                break

    if not points:
        points = [np.zeros(d, dtype=int)]

    points_array = np.array(points, dtype=int)
    rng = np.random.RandomState(123)
    noise = rng.uniform(-perturbation, perturbation, d)

    def objective(x):
        return float(np.sum((x - range_per_coord / 2) ** 2) + np.dot(noise, x))

    return ExchangeFamily(d=d, points=points_array, objective=objective)


def depth_gap_ratio(d: int, k1: int, k2: int) -> float:
    """Compute the depth gap ratio d^(k2 - k1)."""
    return float(d ** (k2 - k1))


if __name__ == "__main__":
    # Example usage
    print("=== Depth-Sensitive Exchange Descent Algorithms ===\n")

    for d in [4, 6, 8]:
        print(f"\n--- Dimension d = {d} ---")

        # High depth (log-concave)
        family_high = generate_exchange_family_separable(d, range_per_coord=4, log_concave_depth=d)
        D = family_high.diameter()
        print(f"  High-depth family: |S| = {family_high.size}, D = {D}")

        if family_high.size > 1:
            traj, vals = run_exchange_descent(family_high, 0)
            steps = len(traj) - 1
            linear_bound = theoretical_bound(d, d, max(D, 1))
            print(f"  Steps taken: {steps}, Linear bound (k=d): {linear_bound:.1f}")

        # Low depth (quadratic)
        family_low = generate_quadratic_family(d, range_per_coord=4)
        D_low = family_low.diameter()
        print(f"  Low-depth family: |S| = {family_low.size}, D = {D_low}")

        if family_low.size > 1:
            traj, vals = run_exchange_descent(family_low, 0)
            steps = len(traj) - 1
            generic_bound = theoretical_bound(d, 1, max(D_low, 1))
            print(f"  Steps taken: {steps}, Generic bound (k=1): {generic_bound:.1f}")
