#!/usr/bin/env python3
"""
Discrete Curvature Flow: Algorithm Implementations

Implements the core algorithms from the research paper with
complete docstrings, type hints, and complexity analysis.
"""

import math
from typing import List, Tuple, Optional, Callable


# ============================================================
# Algorithm 1: Curvature Variance Computation
# ============================================================

def compute_variance(curvatures: List[float]) -> float:
    """Compute curvature variance V = (1/n) ∑ᵢ (Kᵢ - K̄)².

    This is the Lyapunov function for discrete curvature flow.

    Args:
        curvatures: List of curvature values at each vertex.

    Returns:
        The curvature variance (non-negative by cVar_nonneg).

    Complexity: O(n) time, O(1) space.

    Example:
        >>> compute_variance([1.0, 2.0, 3.0])
        0.6666666666666666
        >>> compute_variance([2.0, 2.0, 2.0])
        0.0
    """
    n = len(curvatures)
    if n == 0:
        return 0.0
    mean = sum(curvatures) / n
    return sum((k - mean) ** 2 for k in curvatures) / n


def compute_variance_pairwise(curvatures: List[float]) -> float:
    """Compute variance using the pairwise decomposition identity.

    By pairwise_sq_diff_eq:
        ∑ᵢⱼ (Kᵢ - Kⱼ)² = 2n · ∑ᵢ (Kᵢ - K̄)²

    So V = (1/(2n²)) ∑ᵢⱼ (Kᵢ - Kⱼ)²

    This form is useful for local analysis: when an edge flip
    changes curvatures at 4 vertices, only O(n) of the O(n²)
    pairwise terms change.

    Args:
        curvatures: List of curvature values.

    Returns:
        The curvature variance (same as compute_variance).

    Complexity: O(n²) time, O(1) space.
    """
    n = len(curvatures)
    if n == 0:
        return 0.0
    total = sum((curvatures[i] - curvatures[j]) ** 2
                for i in range(n) for j in range(n))
    return total / (2 * n * n)


# ============================================================
# Algorithm 2: Lyapunov Descent System
# ============================================================

class LyapunovDescentSystem:
    """Abstract Lyapunov descent system with convergence guarantee.

    Corresponds to the formal FlowSystem structure. Tracks a
    non-negative, monotone-decreasing Lyapunov function V with
    a guaranteed progress rate δ.

    By FlowSystem.convergence, V reaches V < δ within ⌈V₀/δ⌉ steps.

    Attributes:
        V_history: List of V values at each step.
        delta: Progress rate (minimum decrease per step when V ≥ δ).
    """

    def __init__(self, V0: float, delta: float):
        """Initialize with initial value and progress rate.

        Args:
            V0: Initial Lyapunov function value (must be ≥ 0).
            delta: Progress rate (must be > 0).
        """
        assert V0 >= 0, "V0 must be non-negative (cVar_nonneg)"
        assert delta > 0, "delta must be positive"
        self.V_history: List[float] = [V0]
        self.delta = delta

    @property
    def current_V(self) -> float:
        return self.V_history[-1]

    @property
    def convergence_bound(self) -> int:
        """Upper bound on steps to reach V < δ.

        By FlowSystem.convergence: k ≤ ⌈V₀/δ⌉
        """
        return math.ceil(self.V_history[0] / self.delta)

    def step(self, new_V: float) -> bool:
        """Record a new V value and check properties.

        Returns True if the step satisfies monotonicity.
        """
        assert new_V >= 0, "V must be non-negative"
        monotone = new_V <= self.current_V
        self.V_history.append(new_V)
        return monotone

    def has_converged(self) -> bool:
        """Check if V < δ (approximate equilibrium reached)."""
        return self.current_V < self.delta

    def verify_convergence_theorem(self) -> bool:
        """Verify that convergence happened within the theoretical bound.

        By FlowSystem.convergence: ∃ k ≤ ⌈V₀/δ⌉, V(k) < δ
        """
        bound = self.convergence_bound
        for k, v in enumerate(self.V_history):
            if k <= bound and v < self.delta:
                return True
        return False


# ============================================================
# Algorithm 3: Greedy Curvature Flow
# ============================================================

def greedy_curvature_flow(
    curvatures: List[float],
    step_fn: Callable[[List[float]], List[float]],
    max_steps: int = 10000,
    epsilon: float = 1e-8,
) -> Tuple[List[float], List[float]]:
    """Run greedy curvature flow with convergence tracking.

    Implements the curvatureFlow iteration from the formal development.
    At each step, applies the step function (greedy edge flip) and
    tracks the variance as a Lyapunov function.

    Args:
        curvatures: Initial curvature distribution.
        step_fn: Function that takes curvatures and returns new curvatures
                 after one greedy step.
        max_steps: Maximum number of steps.
        epsilon: Convergence threshold.

    Returns:
        Tuple of (final curvatures, variance history).

    Convergence guarantee (FlowSystem.convergence):
        The flow reaches variance < ε within ⌈V₀/ε⌉ steps.
    """
    var_history = [compute_variance(curvatures)]
    current = curvatures[:]

    for step in range(max_steps):
        if var_history[-1] < epsilon:
            break

        new_curvatures = step_fn(current)
        new_var = compute_variance(new_curvatures)

        # Verify monotonicity (FlowSystem.V_mono)
        assert new_var <= var_history[-1] + 1e-12, \
            f"Monotonicity violated at step {step}"

        var_history.append(new_var)
        current = new_curvatures

    return current, var_history


# ============================================================
# Algorithm 4: Discrete Laplacian Diffusion
# ============================================================

def laplacian_diffusion_step(
    curvatures: List[float],
    adjacency: List[List[int]],
    tau: float = 0.1,
) -> List[float]:
    """One step of discrete Laplacian diffusion.

    Updates curvatures by:
        K'(i) = K(i) + τ · ∑ⱼ~ᵢ (K(j) - K(i))

    where j ~ i means j is adjacent to i.

    By laplacian_preserves_sum, this preserves total curvature
    (discrete Gauss-Bonnet theorem).

    Args:
        curvatures: Current curvature values.
        adjacency: Adjacency list (adjacency[i] = list of neighbors of i).
        tau: Diffusion rate (must be small enough for stability).

    Returns:
        Updated curvature values.

    Complexity: O(n + m) where m is the number of edges.
    """
    n = len(curvatures)
    new_curvatures = curvatures[:]

    for i in range(n):
        laplacian_i = sum(curvatures[j] - curvatures[i]
                         for j in adjacency[i])
        new_curvatures[i] = curvatures[i] + tau * laplacian_i

    return new_curvatures


def verify_sum_preservation(
    old_curvatures: List[float],
    new_curvatures: List[float],
    tolerance: float = 1e-10,
) -> bool:
    """Verify that total curvature is preserved (Gauss-Bonnet).

    By laplacian_preserves_sum:
        ∑ᵢ K'(i) = ∑ᵢ K(i)
    """
    old_sum = sum(old_curvatures)
    new_sum = sum(new_curvatures)
    return abs(old_sum - new_sum) < tolerance


# ============================================================
# Algorithm 5: Convergence Rate Estimation
# ============================================================

def estimate_convergence_rate(
    var_history: List[float],
    n: int,
) -> Optional[float]:
    """Estimate the convergence constant C from the conjecture.

    Conjecture: V(k) ≤ V(0) · (1 - C/n²)^k

    This implies V(k+1)/V(k) ≈ 1 - C/n², so C ≈ n² · (1 - V(k+1)/V(k)).

    Args:
        var_history: List of variance values.
        n: Number of vertices.

    Returns:
        Estimated constant C, or None if estimation fails.
    """
    ratios = []
    for i in range(1, len(var_history)):
        if var_history[i] > 1e-15 and var_history[i-1] > 1e-15:
            ratio = var_history[i] / var_history[i-1]
            if 0 < ratio < 1:
                C_est = (1 - ratio) * n * n
                ratios.append(C_est)

    return sum(ratios) / len(ratios) if ratios else None


# ============================================================
# Example Usage
# ============================================================

def example_laplacian_diffusion():
    """Demonstrate Laplacian diffusion on a cycle graph."""
    print("=" * 50)
    print("Example: Laplacian Diffusion on Cycle Graph")
    print("=" * 50)

    # 6-vertex cycle graph with non-uniform curvatures
    n = 6
    curvatures = [3.0, -1.0, 2.0, -2.0, 1.0, -3.0]
    adjacency = [[5, 1], [0, 2], [1, 3], [2, 4], [3, 5], [4, 0]]

    print(f"Initial curvatures: {curvatures}")
    print(f"Initial total: {sum(curvatures):.4f}")
    print(f"Initial variance: {compute_variance(curvatures):.6f}")

    # Run diffusion
    var_history = [compute_variance(curvatures)]
    current = curvatures[:]
    for step in range(20):
        new = laplacian_diffusion_step(current, adjacency, tau=0.1)
        preserved = verify_sum_preservation(current, new)
        var_history.append(compute_variance(new))
        current = new

        if step < 5 or step % 5 == 4:
            print(f"  Step {step+1}: var={var_history[-1]:.8f}, "
                  f"sum_preserved={preserved}")

    print(f"\nFinal curvatures: {[f'{x:.4f}' for x in current]}")
    print(f"Final total: {sum(current):.4f}")
    print(f"Variance ratio: {var_history[-1]/var_history[0]:.6f}")


def example_lyapunov_system():
    """Demonstrate the Lyapunov descent system."""
    print("\n" + "=" * 50)
    print("Example: Lyapunov Descent System")
    print("=" * 50)

    # Simulate a descent with progress rate δ = 0.5
    system = LyapunovDescentSystem(V0=10.0, delta=0.5)
    print(f"Initial V: {system.current_V}")
    print(f"Convergence bound: {system.convergence_bound} steps")

    # Simulate steps
    V = 10.0
    for i in range(25):
        if V >= system.delta:
            V -= system.delta  # Progress guarantee
        system.step(V)
        if i < 5 or i >= 18:
            print(f"  Step {i+1}: V = {system.current_V:.4f}")

    print(f"\nConverged: {system.has_converged()}")
    print(f"Convergence theorem verified: {system.verify_convergence_theorem()}")


if __name__ == "__main__":
    example_laplacian_diffusion()
    example_lyapunov_system()
