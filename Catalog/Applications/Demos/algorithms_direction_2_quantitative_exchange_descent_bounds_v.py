"""
Depth-Sensitive Exchange Descent Algorithms
============================================

Implements the core algorithms from the depth-sensitive exchange descent theory:
1. Exchange descent with depth-aware potential tracking
2. Certificate depth estimation
3. Theoretical bound computation

The key idea: deeper structural certificates force faster descent.
At depth k in dimension d, descent terminates in O(d^{d-k} * D) steps
where D is the exchange diameter.
"""

import numpy as np
from typing import Callable, List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class ExchangeState:
    """State of an exchange descent process."""
    point: np.ndarray  # Current point in Z^d
    objective: int      # Current objective value
    potential: float    # Current depth-aware potential
    step: int           # Step number


@dataclass 
class DescentResult:
    """Result of running exchange descent."""
    trajectory: List[ExchangeState]
    final_point: np.ndarray
    final_objective: int
    num_steps: int
    theoretical_bound: float
    certificate_depth: int
    dimension: int
    diameter: float


def exchange_move(x: np.ndarray, i: int, j: int) -> np.ndarray:
    """
    Perform exchange move: increment coordinate i, decrement coordinate j.
    
    Args:
        x: Current integer vector
        i: Coordinate to increase by 1
        j: Coordinate to decrease by 1
    
    Returns:
        New integer vector after the exchange
    """
    y = x.copy()
    y[i] += 1
    y[j] -= 1
    return y


def is_in_set(x: np.ndarray, S: np.ndarray) -> bool:
    """Check if x is in the feasible set S (array of row vectors)."""
    return any(np.array_equal(x, s) for s in S)


def l1_distance(x: np.ndarray, y: np.ndarray) -> int:
    """L1 distance between integer vectors."""
    return int(np.sum(np.abs(x - y)))


def exchange_diameter(S: np.ndarray) -> int:
    """
    Compute the exchange diameter of a finite set S.
    
    The exchange diameter is the maximum L1 distance between
    any two points in S.
    
    Args:
        S: Array of shape (n, d) representing feasible points
    
    Returns:
        Maximum L1 distance between any pair of points
    """
    n = len(S)
    max_dist = 0
    for i in range(n):
        for j in range(i + 1, n):
            d = l1_distance(S[i], S[j])
            max_dist = max(max_dist, d)
    return max_dist


def depth_decrement(d: int, k: int, c: float = 1.0) -> float:
    """
    Compute the depth-aware decrement δ_k = c / d^{d-k}.
    
    At depth k in dimension d, each improving exchange step
    decreases the potential by at least this amount.
    
    Args:
        d: Dimension
        k: Certificate depth
        c: Universal constant (default 1.0)
    
    Returns:
        Minimum potential decrease per step
    """
    if d == 0:
        return c
    return c / (d ** (d - k))


def theoretical_bound(d: int, k: int, D: int, c: float = 1.0, C0: float = 1.0) -> float:
    """
    Compute the theoretical descent bound: C0 * D * d^{d-k} / c.
    
    Args:
        d: Dimension
        k: Certificate depth  
        D: Exchange diameter
        c: Decrement constant
        C0: Potential range constant
    
    Returns:
        Upper bound on number of descent steps
    """
    if d == 0:
        return C0 * D / c
    return C0 * D * (d ** (d - k)) / c


def generate_exchange_family(d: int, radius: int = 3) -> np.ndarray:
    """
    Generate a random exchange family in Z^d.
    
    Creates a set of integer vectors satisfying the exchange axiom
    (all vectors with the same coordinate sum within a box).
    This models matroid bases / polymatroid intersections.
    
    Args:
        d: Dimension
        radius: Half-width of the bounding box
    
    Returns:
        Array of feasible integer vectors
    """
    # Generate all integer vectors in [-radius, radius]^d with a fixed coordinate sum
    target_sum = 0  # Fix the sum to 0 for a symmetric family
    
    points = []
    # Generate random subset of integer vectors with fixed sum
    for _ in range(min(500, (2 * radius + 1) ** d)):
        x = np.random.randint(-radius, radius + 1, size=d)
        # Project to fixed-sum hyperplane
        x[-1] = target_sum - np.sum(x[:-1])
        if abs(x[-1]) <= radius:
            points.append(x.copy())
    
    if not points:
        points = [np.zeros(d, dtype=int)]
    
    # Remove duplicates
    unique_points = []
    for p in points:
        if not any(np.array_equal(p, u) for u in unique_points):
            unique_points.append(p)
    
    return np.array(unique_points)


def separable_objective(x: np.ndarray, weights: List[Callable]) -> int:
    """
    Evaluate a separable objective f(x) = sum_i w_i(x_i).
    
    Args:
        x: Integer vector
        weights: List of weight functions, one per coordinate
    
    Returns:
        Objective value (rounded to integer)
    """
    return int(sum(w(int(x[i])) for i, w in enumerate(weights)))


def log_concave_weight(v: int, alpha: float = 1.0, center: float = 0.0) -> float:
    """
    A log-concave weight function: w(v) = exp(-alpha * (v - center)^2).
    
    This is the prototypical k-fold log-concave sequence for all k.
    Gaussian weights are infinitely log-concave.
    
    Args:
        v: Integer coordinate value
        alpha: Concentration parameter (larger = more peaked)
        center: Center of the weight function
    
    Returns:
        Weight value (always positive)
    """
    return np.exp(-alpha * (v - center) ** 2)


def quadratic_weight(v: int, a: float = 1.0, b: float = 0.0) -> float:
    """
    A quadratic weight (low log-concavity depth).
    w(v) = exp(a * v^2 + b * v) with a > 0 for convex perturbation.
    
    Args:
        v: Integer coordinate value
        a: Quadratic coefficient
        b: Linear coefficient
    
    Returns:
        Weight value
    """
    return np.exp(-a * v ** 2 + b * v)


def make_high_depth_objective(d: int, alpha: float = 0.5) -> List[Callable]:
    """
    Create weight functions for a high-depth (k ≈ d) objective.
    Uses Gaussian weights which are k-fold log-concave for all k.
    
    Args:
        d: Dimension
        alpha: Concentration parameter
    
    Returns:
        List of weight functions
    """
    centers = np.random.uniform(-2, 2, size=d)
    return [lambda v, c=c, a=alpha: log_concave_weight(v, a, c) for c in centers]


def make_low_depth_objective(d: int, perturbation: float = 0.3) -> List[Callable]:
    """
    Create weight functions for a low-depth (k ≈ 1) objective.
    Uses perturbed quadratics with minimal log-concavity structure.
    
    Args:
        d: Dimension
        perturbation: Noise amplitude
    
    Returns:
        List of weight functions
    """
    return [lambda v, p=perturbation: quadratic_weight(v, 0.1, p * np.random.randn())
            for _ in range(d)]


def exchange_descent(
    S: np.ndarray,
    f: Callable,
    x0: np.ndarray,
    potential: Optional[Callable] = None,
    max_steps: int = 10000
) -> DescentResult:
    """
    Run exchange descent from initial point x0.
    
    At each step, try all exchange moves (increment coord i, decrement coord j)
    and take the one that most improves the objective.
    
    Args:
        S: Feasible set (array of row vectors)
        f: Objective function to minimize
        x0: Starting point
        potential: Optional depth-aware potential function
        max_steps: Maximum number of steps
    
    Returns:
        DescentResult with trajectory and statistics
    """
    d = len(x0)
    x = x0.copy()
    fx = f(x)
    phi = potential(x) if potential else float(fx)
    
    trajectory = [ExchangeState(x.copy(), fx, phi, 0)]
    
    for step in range(1, max_steps + 1):
        best_y = None
        best_fy = fx
        best_phi = phi
        
        # Try all exchange moves
        for i in range(d):
            for j in range(d):
                if i == j:
                    continue
                y = exchange_move(x, i, j)
                if is_in_set(y, S):
                    fy = f(y)
                    if fy < best_fy:
                        best_y = y.copy()
                        best_fy = fy
                        best_phi = potential(y) if potential else float(fy)
        
        if best_y is None:
            break  # Local minimum reached
        
        x = best_y
        fx = best_fy
        phi = best_phi
        trajectory.append(ExchangeState(x.copy(), fx, phi, step))
    
    D = exchange_diameter(S)
    
    return DescentResult(
        trajectory=trajectory,
        final_point=x,
        final_objective=fx,
        num_steps=len(trajectory) - 1,
        theoretical_bound=float('inf'),
        certificate_depth=0,
        dimension=d,
        diameter=D
    )


def estimate_certificate_depth(
    S: np.ndarray,
    weights: List[Callable],
    max_depth: int = 20
) -> int:
    """
    Estimate the certificate depth of a separable objective.
    
    Tests k-fold log-concavity of each component weight function
    by checking ratio sequence monotonicity at increasing depths.
    
    Args:
        S: Feasible set
        weights: Component weight functions
        max_depth: Maximum depth to test
    
    Returns:
        Estimated certificate depth
    """
    d = len(weights)
    
    # Get the range of coordinate values
    if len(S) == 0:
        return 0
    
    min_val = int(S.min())
    max_val = int(S.max())
    
    def check_log_concave(seq: List[float]) -> bool:
        """Check if a positive sequence is log-concave."""
        for i in range(1, len(seq) - 1):
            if seq[i] <= 0:
                return False
            if seq[i] ** 2 < seq[i-1] * seq[i+1] - 1e-10:
                return False
        return True
    
    def ratio_sequence(seq: List[float]) -> List[float]:
        """Compute ratio sequence r(n) = a(n+1)/a(n)."""
        ratios = []
        for i in range(len(seq) - 1):
            if seq[i] <= 0:
                return []
            ratios.append(seq[i+1] / seq[i])
        return ratios
    
    min_depth = max_depth
    
    for coord in range(d):
        # Evaluate weight function
        vals = [weights[coord](v) for v in range(min_val, max_val + 1)]
        if not all(v > 0 for v in vals):
            return 0
        
        # Check k-fold log-concavity by iterating ratio sequences
        current = vals
        depth = 0
        for k in range(max_depth):
            if len(current) < 3:
                depth = k
                break
            if not check_log_concave(current):
                depth = k
                break
            current = ratio_sequence(current)
            if not current or not all(r > 0 for r in current):
                depth = k + 1
                break
            depth = k + 1
        
        min_depth = min(min_depth, depth)
    
    return min_depth


def run_descent_experiment(
    d: int,
    radius: int = 3,
    high_depth: bool = True,
    num_trials: int = 5
) -> Dict:
    """
    Run a descent experiment for given dimension.
    
    Args:
        d: Dimension
        radius: Box radius for exchange family
        high_depth: Whether to use high-depth (log-concave) or low-depth objective
        num_trials: Number of random trials
    
    Returns:
        Dictionary with experimental results
    """
    results = {
        'dimension': d,
        'high_depth': high_depth,
        'step_counts': [],
        'diameters': [],
        'depths': [],
        'bounds': [],
    }
    
    for _ in range(num_trials):
        S = generate_exchange_family(d, radius)
        if len(S) < 2:
            continue
        
        if high_depth:
            weights = make_high_depth_objective(d)
        else:
            weights = make_low_depth_objective(d)
        
        f = lambda x, w=weights: -int(sum(w[i](int(x[i])) * 1000 for i in range(d)))
        
        # Pick random starting point
        idx = np.random.randint(len(S))
        x0 = S[idx]
        
        result = exchange_descent(S, f, x0)
        depth = estimate_certificate_depth(S, weights)
        D = result.diameter
        
        bound = theoretical_bound(d, min(depth, d), max(D, 1))
        
        results['step_counts'].append(result.num_steps)
        results['diameters'].append(D)
        results['depths'].append(depth)
        results['bounds'].append(bound)
    
    return results


if __name__ == '__main__':
    np.random.seed(42)
    
    print("=" * 60)
    print("Depth-Sensitive Exchange Descent Algorithm")
    print("=" * 60)
    
    # Example: dimension 5
    d = 5
    print(f"\nDimension d = {d}")
    
    S = generate_exchange_family(d, radius=2)
    print(f"Exchange family size: {len(S)}")
    print(f"Exchange diameter: {exchange_diameter(S)}")
    
    # High-depth objective (Gaussian weights)
    weights_high = make_high_depth_objective(d)
    f_high = lambda x: -int(sum(weights_high[i](int(x[i])) * 1000 for i in range(d)))
    
    depth_high = estimate_certificate_depth(S, weights_high)
    print(f"\nHigh-depth objective: estimated depth = {depth_high}")
    
    x0 = S[0]
    result_high = exchange_descent(S, f_high, x0)
    print(f"  Steps to converge: {result_high.num_steps}")
    print(f"  Theoretical bound: {theoretical_bound(d, min(depth_high, d), max(result_high.diameter, 1)):.1f}")
    
    # Low-depth objective
    weights_low = make_low_depth_objective(d)
    f_low = lambda x: -int(sum(weights_low[i](int(x[i])) * 1000 for i in range(d)))
    
    depth_low = estimate_certificate_depth(S, weights_low)
    print(f"\nLow-depth objective: estimated depth = {depth_low}")
    
    result_low = exchange_descent(S, f_low, x0)
    print(f"  Steps to converge: {result_low.num_steps}")
    print(f"  Theoretical bound: {theoretical_bound(d, min(depth_low, d), max(result_low.diameter, 1)):.1f}")
    
    print(f"\n  Ratio (low/high steps): {result_low.num_steps / max(result_high.num_steps, 1):.2f}")
    print(f"  Predicted ratio from theory: {theoretical_bound(d, min(depth_low, d), 1) / max(theoretical_bound(d, min(depth_high, d), 1), 0.01):.2f}")
