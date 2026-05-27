"""
algorithms.py — Depth-Sensitive Exchange Descent Algorithms

Implements the core algorithmic framework for exchange descent on finite
integer lattice subsets, with depth-aware potential tracking and certificate
depth estimation.

Mathematical background:
    An exchange step modifies exactly two coordinates by ±1 (one up, one down).
    A depth-k exchange certificate (DLC_k) guarantees that whenever f(y) < f(x),
    an improving exchange move exists from x. The depth k controls the minimum
    potential decrease per step: δ_k = c / d^{d-k}, yielding a descent bound
    of O(d^{d-k} · D) steps, where D is the exchange diameter.

Author: Harmonic Research
"""

from __future__ import annotations
import numpy as np
from typing import Callable, Optional
from dataclasses import dataclass, field


@dataclass
class ExchangeFamily:
    """A finite exchange family S ⊆ ℤ^d with an objective function.

    Attributes:
        d: Dimension of the ambient lattice.
        points: Array of shape (n, d) with integer coordinates.
        objective: Function mapping d-dimensional integer vectors to values.
    """
    d: int
    points: np.ndarray  # shape (n, d), dtype int
    objective: Callable[[np.ndarray], float]

    @property
    def n_points(self) -> int:
        return self.points.shape[0]

    def exchange_diameter(self) -> int:
        """Compute the exchange diameter: max L1 distance between any two points."""
        max_dist = 0
        for i in range(self.n_points):
            for j in range(i + 1, self.n_points):
                dist = int(np.sum(np.abs(self.points[i] - self.points[j])))
                max_dist = max(max_dist, dist)
        return max_dist

    def point_set(self) -> set:
        """Return the set of points as tuples for fast membership testing."""
        return {tuple(p) for p in self.points}


@dataclass
class DescentResult:
    """Result of running exchange descent.

    Attributes:
        trajectory: List of points visited during descent.
        potentials: List of potential values along the trajectory.
        steps: Number of descent steps taken.
        final_point: The terminal point of the descent.
        final_value: The objective value at the terminal point.
        depth_estimate: Estimated certificate depth.
        theoretical_bound: Theoretical upper bound on step count.
    """
    trajectory: list
    potentials: list
    steps: int
    final_point: np.ndarray
    final_value: float
    depth_estimate: int = 0
    theoretical_bound: float = 0.0


def depth_decrement(d: int, k: int, c: float = 1.0) -> float:
    """Compute the depth-aware decrement δ_k = c / d^{d-k}.

    At depth k, the minimum potential decrease per improving exchange step
    is c / d^{d-k}. At maximal depth k=d, this simplifies to c.

    Args:
        d: Dimension.
        k: Certificate depth (1 ≤ k ≤ d).
        c: Positive constant (default 1.0).

    Returns:
        The depth decrement δ_k.
    """
    if d == 0:
        return c
    exponent = d - k
    return c / (d ** exponent)


def compute_potential(x: np.ndarray, f_val: float, opt_val: float,
                      lam: float = 1.0) -> float:
    """Compute the depth-aware potential Φ(x) = (f(x) - f_opt) + λ·‖x‖₁.

    This is a simplified certificate potential that combines the objective
    gap with a norm-based distance surrogate.

    Args:
        x: Current point.
        f_val: Objective value f(x).
        opt_val: Optimal objective value.
        lam: Scaling parameter for the distance term.

    Returns:
        The potential value Φ(x).
    """
    obj_gap = f_val - opt_val
    return obj_gap + lam * np.sum(np.abs(x))


def find_improving_exchange(x: np.ndarray, f: Callable, S_set: set,
                            d: int) -> Optional[np.ndarray]:
    """Find an improving exchange step from x, if one exists.

    An exchange step modifies coordinates i and j: x_i += 1, x_j -= 1.
    An improving step additionally requires f(x') < f(x) and x' ∈ S.

    Args:
        x: Current point (d-dimensional integer vector).
        f: Objective function.
        S_set: Set of feasible points (as tuples).
        d: Dimension.

    Returns:
        The improving neighbor, or None if x is a local minimum.
    """
    current_val = f(x)
    best_neighbor = None
    best_val = current_val

    for i in range(d):
        for j in range(d):
            if i == j:
                continue
            y = x.copy()
            y[i] += 1
            y[j] -= 1
            if tuple(y) in S_set and f(y) < best_val:
                best_val = f(y)
                best_neighbor = y.copy()

    return best_neighbor


def exchange_descent(family: ExchangeFamily, x0: np.ndarray,
                     k: int = 1, c: float = 1.0,
                     max_steps: int = 100000,
                     track_potential: bool = True) -> DescentResult:
    """Run depth-sensitive exchange descent from x0.

    At each step, find the best improving exchange move and take it.
    Track the depth-aware potential to verify the theoretical bound.

    Args:
        family: The exchange family (S, f).
        x0: Initial point in S.
        k: Certificate depth parameter.
        c: Constant for depth decrement.
        max_steps: Maximum number of steps to prevent infinite loops.
        track_potential: Whether to track potential values.

    Returns:
        DescentResult with trajectory, potentials, and step count.
    """
    d = family.d
    f = family.objective
    S_set = family.point_set()

    # Find optimal value for potential computation
    opt_val = min(f(p) for p in family.points)

    x = x0.copy()
    trajectory = [x.copy()]
    f_val = f(x)
    potentials = [compute_potential(x, f_val, opt_val)] if track_potential else []

    steps = 0
    for _ in range(max_steps):
        y = find_improving_exchange(x, f, S_set, d)
        if y is None:
            break  # Local (and under DLC, global) minimum reached

        x = y
        f_val = f(x)
        steps += 1
        trajectory.append(x.copy())
        if track_potential:
            potentials.append(compute_potential(x, f_val, opt_val))

    # Compute theoretical bound
    D = family.exchange_diameter()
    delta_k = depth_decrement(d, k, c)
    if delta_k > 0 and D > 0:
        # Theoretical bound: C0 * D * d^{d-k} / c
        C0 = 2.0  # Conservative constant
        theoretical_bound = C0 * D * d ** (d - k) / c
    else:
        theoretical_bound = float('inf')

    return DescentResult(
        trajectory=trajectory,
        potentials=potentials,
        steps=steps,
        final_point=x,
        final_value=f_val,
        depth_estimate=k,
        theoretical_bound=theoretical_bound
    )


def estimate_certificate_depth(family: ExchangeFamily,
                               n_samples: int = 50) -> int:
    """Estimate the certificate depth of an exchange family.

    Uses a heuristic: run descent from multiple starting points and
    analyze the convergence pattern. Faster convergence (relative to D)
    suggests higher certificate depth.

    Args:
        family: The exchange family.
        n_samples: Number of random starting points.

    Returns:
        Estimated certificate depth k.
    """
    d = family.d
    D = family.exchange_diameter()
    if D == 0:
        return d

    # Run descent from random starting points
    step_counts = []
    indices = np.random.choice(family.n_points, min(n_samples, family.n_points), replace=False)

    for idx in indices:
        result = exchange_descent(family, family.points[idx], track_potential=False)
        step_counts.append(result.steps)

    if not step_counts:
        return 1

    max_steps = max(step_counts)
    if max_steps == 0:
        return d

    # Estimate exponent: steps ~ d^{d-k} * D
    # log(steps / D) ~ (d-k) * log(d)
    ratio = max_steps / max(D, 1)
    if ratio <= 1:
        return d  # Linear regime -> maximal depth
    elif d <= 1:
        return 1

    log_ratio = np.log(ratio)
    log_d = np.log(d)
    if log_d <= 0:
        return 1

    estimated_exponent = log_ratio / log_d
    k_estimate = max(1, min(d, int(d - estimated_exponent + 0.5)))
    return k_estimate


def generate_separable_exchange_family(
    d: int, box_size: int = 5,
    weight_type: str = "log_concave",
    depth: int = 1
) -> ExchangeFamily:
    """Generate a random exchange family with separable objective.

    The objective f(x) = Σᵢ wᵢ(xᵢ) decomposes as a sum of local
    weight functions. Higher-order log-concave weights generate
    deeper certificates.

    Args:
        d: Dimension.
        box_size: Range of each coordinate: [-box_size, box_size].
        weight_type: "log_concave" for log-concave weights,
                     "quadratic" for simple quadratic objectives.
        depth: Depth parameter controlling log-concavity order.

    Returns:
        An ExchangeFamily with separable objective.
    """
    # Generate all integer points in the box with fixed coordinate sum
    # (to ensure exchange steps stay within S)
    from itertools import product as iterproduct

    # Generate points on a hyperplane sum(x) = 0 within the box
    ranges = [range(-box_size, box_size + 1) for _ in range(d)]
    all_points = []
    for pt in iterproduct(*ranges):
        if sum(pt) == 0:  # Constraint for exchange closure
            all_points.append(list(pt))

    if not all_points:
        # Fallback: just use the origin
        all_points = [[0] * d]

    points = np.array(all_points, dtype=int)

    # Build separable objective
    if weight_type == "log_concave":
        # k-fold log-concave weights: Gaussian-like with depth control
        centers = np.random.uniform(-2, 2, size=d)
        scales = np.random.uniform(0.5, 2.0, size=d)

        def objective(x):
            val = 0.0
            for i in range(d):
                # Gaussian weight: always log-concave
                # Higher depth -> tighter Gaussian (more curvature)
                sigma = scales[i] / (1 + 0.3 * depth)
                val += (x[i] - centers[i]) ** 2 / (2 * sigma ** 2)
            return val

    elif weight_type == "quadratic":
        # Simple quadratic: minimal depth
        coeffs = np.random.uniform(0.1, 2.0, size=d)
        offsets = np.random.uniform(-2, 2, size=d)

        def objective(x):
            return sum(coeffs[i] * (x[i] - offsets[i]) ** 2 for i in range(d))

    else:
        # Perturbed quadratic with random noise (low depth)
        coeffs = np.random.uniform(0.1, 2.0, size=d)

        def objective(x):
            base = sum(coeffs[i] * x[i] ** 2 for i in range(d))
            # Add perturbation that reduces structure
            noise = 0.1 * sum(np.sin(x[i] * np.pi / 3) for i in range(d))
            return base + noise

    return ExchangeFamily(d=d, points=points, objective=objective)


def runtime_exponent_experiment(
    d_range: range = range(4, 10),
    box_size: int = 3,
    n_trials: int = 5,
    high_depth: bool = True
) -> dict:
    """Run experiment measuring descent steps vs theoretical predictions.

    For each dimension d, generate exchange families and measure:
    - Actual descent step counts
    - Exchange diameter D
    - Estimated certificate depth k
    - Fitted exponent in steps ~ d^{d-k} * D

    Args:
        d_range: Range of dimensions to test.
        box_size: Box size for point generation.
        n_trials: Number of random trials per dimension.
        high_depth: If True, use high-depth log-concave objectives.

    Returns:
        Dictionary with experimental results.
    """
    results = {
        'dimensions': [],
        'diameters': [],
        'step_counts': [],
        'depth_estimates': [],
        'theoretical_bounds': [],
        'actual_exponents': []
    }

    for d in d_range:
        for _ in range(n_trials):
            depth = d if high_depth else 1
            family = generate_separable_exchange_family(
                d, box_size=box_size,
                weight_type="log_concave",
                depth=depth
            )

            if family.n_points < 2:
                continue

            D = family.exchange_diameter()
            if D == 0:
                continue

            # Run descent from worst point
            worst_idx = max(range(family.n_points),
                           key=lambda i: family.objective(family.points[i]))
            result = exchange_descent(family, family.points[worst_idx], k=depth)

            k_est = estimate_certificate_depth(family)

            results['dimensions'].append(d)
            results['diameters'].append(D)
            results['step_counts'].append(result.steps)
            results['depth_estimates'].append(k_est)
            results['theoretical_bounds'].append(result.theoretical_bound)

            # Compute actual exponent: steps / D ~ d^exponent
            if D > 0 and result.steps > 0 and d > 1:
                actual_exp = np.log(result.steps / D) / np.log(d)
            else:
                actual_exp = 0.0
            results['actual_exponents'].append(actual_exp)

    return results


if __name__ == "__main__":
    np.random.seed(42)
    print("=" * 60)
    print("Depth-Sensitive Exchange Descent — Algorithm Demo")
    print("=" * 60)

    # Example 1: Small exchange family
    d = 4
    family = generate_separable_exchange_family(d, box_size=2, depth=d)
    print(f"\nDimension d={d}, |S|={family.n_points}, diameter D={family.exchange_diameter()}")

    # Run descent from a random point
    idx = np.random.randint(family.n_points)
    result = exchange_descent(family, family.points[idx], k=d)
    print(f"Descent steps: {result.steps}")
    print(f"Theoretical bound (k=d={d}): {result.theoretical_bound:.1f}")
    print(f"Final objective value: {result.final_value:.4f}")

    # Example 2: Compare depths
    print("\n" + "=" * 60)
    print("Depth comparison experiment")
    print("=" * 60)

    for d in [4, 5, 6]:
        family = generate_separable_exchange_family(d, box_size=2, depth=d)
        D = family.exchange_diameter()
        worst_idx = max(range(family.n_points),
                       key=lambda i: family.objective(family.points[i]))

        for k in range(1, d + 1):
            delta_k = depth_decrement(d, k)
            bound = 2.0 * D / delta_k if delta_k > 0 else float('inf')
            result = exchange_descent(family, family.points[worst_idx], k=k)
            print(f"  d={d}, k={k}: steps={result.steps:4d}, "
                  f"δ_k={delta_k:.6f}, bound={bound:.0f}, D={D}")
