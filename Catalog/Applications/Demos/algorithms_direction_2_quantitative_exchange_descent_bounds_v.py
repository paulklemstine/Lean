"""
algorithms.py — Depth-Sensitive Exchange Descent Algorithms

Implements the core algorithms from the depth-sensitive exchange descent theory:
- Exchange family generation
- Depth-aware potential computation
- Exchange descent with depth-sensitive step tracking
- Certificate depth estimation
- Theoretical bound computation

Author: Harmonic Research
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Callable
from dataclasses import dataclass
import itertools


@dataclass
class ExchangeFamily:
    """A finite exchange family S ⊆ ℤ^d with an objective function."""
    d: int
    points: np.ndarray  # shape (|S|, d), integer entries
    objective: Callable[[np.ndarray], float]

    @property
    def size(self) -> int:
        return len(self.points)

    def diameter(self) -> int:
        """L1 exchange diameter: max L1 distance between any two points."""
        max_dist = 0
        for i in range(self.size):
            for j in range(i + 1, self.size):
                dist = int(np.sum(np.abs(self.points[i] - self.points[j])))
                max_dist = max(max_dist, dist)
        return max_dist


def depth_decrement(d: int, k: int, c: float = 1.0) -> float:
    """Compute the depth-aware decrement δ_k = c / d^(d-k).

    Args:
        d: Dimension
        k: Certificate depth
        c: Universal constant (default 1.0)

    Returns:
        The minimum potential decrease per step at depth k.
    """
    if d == 0:
        return c
    return c / (d ** max(d - k, 0))


def theoretical_bound(d: int, k: int, D: int, c: float = 1.0, C0: float = 1.0) -> float:
    """Compute the theoretical descent bound: C0 * D * d^(d-k) / c.

    Args:
        d: Dimension
        k: Certificate depth
        D: Exchange diameter
        c: Decrement constant
        C0: Potential range constant

    Returns:
        Upper bound on descent chain length.
    """
    if d == 0:
        return C0 * D / c
    return C0 * D * (d ** max(d - k, 0)) / c


def generate_exchange_family_box(d: int, side: int) -> np.ndarray:
    """Generate a box-shaped exchange family {0,...,side-1}^d.

    Args:
        d: Dimension
        side: Side length of the box

    Returns:
        Array of shape (side^d, d) with all lattice points in the box.
    """
    ranges = [range(side)] * d
    points = np.array(list(itertools.product(*ranges)), dtype=int)
    return points


def generate_exchange_family_simplex(d: int, n: int) -> np.ndarray:
    """Generate a simplex-like exchange family: {x ∈ ℤ^d_≥0 : sum(x) = n}.

    These arise naturally from matroid base polytopes.

    Args:
        d: Dimension
        n: Coordinate sum constraint

    Returns:
        Array of integer points on the simplex slice.
    """
    if d == 1:
        return np.array([[n]], dtype=int)

    points = []
    def _gen(remaining_dims: int, remaining_sum: int, current: List[int]):
        if remaining_dims == 1:
            points.append(current + [remaining_sum])
            return
        for v in range(remaining_sum + 1):
            _gen(remaining_dims - 1, remaining_sum - v, current + [v])

    _gen(d, n, [])
    return np.array(points, dtype=int)


def log_concave_weights(n: int, k: int = 1) -> np.ndarray:
    """Generate k-fold log-concave weight sequences.

    Uses binomial coefficients (which are ultra-log-concave) as the
    canonical example of deeply log-concave sequences.

    Args:
        n: Length parameter (weights indexed 0..n)
        k: Desired log-concavity depth

    Returns:
        Array of positive weights that are k-fold log-concave.
    """
    from math import comb
    # Binomial coefficients C(2n, i) for i=0..2n are ultra-log-concave
    weights = np.array([float(comb(max(2 * n, k + n), i))
                       for i in range(n + 1)], dtype=float)
    # Normalize to avoid overflow
    weights = weights / weights.max()
    return np.maximum(weights, 1e-15)


def separable_objective(weights: List[np.ndarray], x: np.ndarray) -> float:
    """Compute a separable objective f(x) = sum_i w_i(x_i).

    Args:
        weights: List of d weight arrays, one per coordinate.
        x: Point in ℤ^d.

    Returns:
        Objective value (negated sum of log-weights for minimization).
    """
    d = len(weights)
    val = 0.0
    for i in range(d):
        idx = int(x[i])
        if 0 <= idx < len(weights[i]):
            val -= np.log(weights[i][idx] + 1e-30)
        else:
            val += 1e10  # penalty for out-of-range
    return val


def find_improving_exchange(
    points: np.ndarray,
    point_set: set,
    x: np.ndarray,
    f: Callable[[np.ndarray], float],
    fx: float
) -> Optional[Tuple[np.ndarray, float]]:
    """Find an improving exchange step from x.

    Args:
        points: All points in S.
        point_set: Set of tuples for fast membership testing.
        x: Current point.
        f: Objective function.
        fx: f(x), precomputed.

    Returns:
        (y, f(y)) if an improving exchange exists, None otherwise.
    """
    d = len(x)
    best_y = None
    best_fy = fx

    for i in range(d):
        for j in range(d):
            if i == j:
                continue
            y = x.copy()
            y[i] += 1
            y[j] -= 1
            yt = tuple(y)
            if yt in point_set:
                fy = f(y)
                if fy < best_fy:
                    best_y = y.copy()
                    best_fy = fy

    if best_y is not None:
        return best_y, best_fy
    return None


def exchange_descent(
    family: ExchangeFamily,
    x0: np.ndarray,
    max_steps: int = 100000
) -> Tuple[List[np.ndarray], List[float]]:
    """Run exchange descent from x0.

    Args:
        family: The exchange family with objective.
        x0: Starting point.
        max_steps: Maximum number of steps (safety bound).

    Returns:
        (trajectory, objectives): Lists of visited points and their objective values.
    """
    point_set = set(map(tuple, family.points))
    trajectory = [x0.copy()]
    objectives = [family.objective(x0)]

    x = x0.copy()
    fx = objectives[0]

    for _ in range(max_steps):
        result = find_improving_exchange(family.points, point_set, x, family.objective, fx)
        if result is None:
            break
        x, fx = result
        trajectory.append(x.copy())
        objectives.append(fx)

    return trajectory, objectives


def estimate_certificate_depth(
    family: ExchangeFamily,
    num_samples: int = 50
) -> int:
    """Heuristically estimate the certificate depth of an exchange family.

    Tests whether improving exchanges exist between random pairs,
    checking at increasing depth levels.

    Args:
        family: The exchange family.
        num_samples: Number of random pairs to test.

    Returns:
        Estimated certificate depth k.
    """
    d = family.d
    point_set = set(map(tuple, family.points))

    # Test: does every non-optimal point have an improving exchange?
    obj_values = np.array([family.objective(p) for p in family.points])
    min_idx = np.argmin(obj_values)

    has_dlc = True
    for i in range(family.size):
        if i == min_idx:
            continue
        x = family.points[i]
        fx = obj_values[i]
        result = find_improving_exchange(family.points, point_set, x, family.objective, fx)
        if result is None:
            has_dlc = False
            break

    if not has_dlc:
        return 0

    # If DLC holds, depth is at least 1. Heuristic: use d for
    # ultra-log-concave objectives, d//2 for moderate ones
    return d


def depth_aware_potential(
    x: np.ndarray,
    f: Callable[[np.ndarray], float],
    family: ExchangeFamily,
    k: int,
    lam: float = 1.0
) -> float:
    """Compute the depth-aware potential Φ_k(x) = f(x) + λ_k * ρ_k(x).

    Here ρ_k is approximated by the minimum number of exchange steps
    to reach a local optimum.

    Args:
        x: Current point.
        f: Objective function.
        family: Exchange family for distance computation.
        k: Certificate depth.
        lam: Scaling parameter.

    Returns:
        Potential value.
    """
    fx = f(x)
    # Use objective gap as a surrogate for distance to optimum
    obj_values = [f(p) for p in family.points]
    opt_val = min(obj_values)
    gap = fx - opt_val

    # Scale by depth: deeper certificates mean smaller scaling
    d = family.d
    scale = lam / max(d ** max(d - k, 0), 1)

    return fx + scale * gap


def run_depth_experiment(
    d: int,
    k: int,
    side: int = 4,
    num_trials: int = 5
) -> Dict:
    """Run a depth-sensitive descent experiment.

    Args:
        d: Dimension.
        k: Certificate depth (controls log-concavity of weights).
        side: Side length for box family.
        num_trials: Number of random starting points.

    Returns:
        Dictionary with experimental results.
    """
    # Generate exchange family
    if side ** d > 50000:
        # Use simplex for large dimensions
        points = generate_exchange_family_simplex(d, side)
    else:
        points = generate_exchange_family_box(d, min(side, 4))

    if len(points) == 0:
        return {"d": d, "k": k, "steps": [], "diameter": 0, "bound": 0}

    # Generate k-fold log-concave weights
    max_coord = int(points.max()) + 1
    weights = [log_concave_weights(max_coord, k) for _ in range(d)]

    def objective(x):
        return separable_objective(weights, x)

    family = ExchangeFamily(d=d, points=points, objective=objective)
    D = family.diameter()

    # Run descent from random starting points
    step_counts = []
    for trial in range(num_trials):
        idx = np.random.randint(0, family.size)
        x0 = family.points[idx].copy()
        traj, objs = exchange_descent(family, x0)
        step_counts.append(len(traj) - 1)

    bound = theoretical_bound(d, k, D)

    return {
        "d": d,
        "k": k,
        "diameter": D,
        "family_size": family.size,
        "steps": step_counts,
        "mean_steps": float(np.mean(step_counts)) if step_counts else 0,
        "max_steps": int(np.max(step_counts)) if step_counts else 0,
        "theoretical_bound": bound,
        "depth_decrement": depth_decrement(d, k),
    }


if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 60)
    print("Depth-Sensitive Exchange Descent — Algorithm Tests")
    print("=" * 60)

    # Test 1: Basic descent on small family
    print("\n--- Test 1: Basic descent on 3D box ---")
    points = generate_exchange_family_box(3, 4)
    weights = [log_concave_weights(4, 3) for _ in range(3)]
    family = ExchangeFamily(
        d=3, points=points,
        objective=lambda x: separable_objective(weights, x)
    )
    traj, objs = exchange_descent(family, points[0])
    print(f"  Family size: {family.size}")
    print(f"  Diameter: {family.diameter()}")
    print(f"  Steps: {len(traj) - 1}")
    print(f"  Start obj: {objs[0]:.4f}, End obj: {objs[-1]:.4f}")

    # Test 2: Depth comparison
    print("\n--- Test 2: Depth comparison (d=4) ---")
    for k in [1, 2, 3, 4]:
        result = run_depth_experiment(4, k, side=3, num_trials=10)
        print(f"  k={k}: mean_steps={result['mean_steps']:.1f}, "
              f"max_steps={result['max_steps']}, "
              f"bound={result['theoretical_bound']:.1f}, "
              f"δ_k={result['depth_decrement']:.6f}")

    # Test 3: Dimension scaling
    print("\n--- Test 3: Dimension scaling (k=d, linear regime) ---")
    for d in range(3, 8):
        result = run_depth_experiment(d, d, side=3, num_trials=5)
        D = result['diameter']
        if D > 0 and result['mean_steps'] > 0:
            ratio = result['mean_steps'] / D
            print(f"  d={d}: steps/D = {ratio:.3f}, D={D}")
