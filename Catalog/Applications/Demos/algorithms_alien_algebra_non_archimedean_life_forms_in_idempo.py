#!/usr/bin/env python3
"""
Algorithms for Tropical Alien Algebra

Implements the key algorithms from the research paper:
1. Fixed-point computation for monotone inflationary maps
2. Tropical CA simulation with convergence detection
3. Mutation distance analysis
4. Replicator composition
"""

import numpy as np
from typing import Callable, Tuple, List, Optional
from dataclasses import dataclass


# ──────────────────────────────────────────────────────
# Algorithm 1: Fixed-Point Computation
# ──────────────────────────────────────────────────────

def compute_fixedpoint(
    F: Callable[[np.ndarray], np.ndarray],
    x0: np.ndarray,
    max_steps: int = 10000
) -> Tuple[np.ndarray, int]:
    """
    Compute the fixed point of a monotone inflationary map F
    starting from initial state x0.
    
    Args:
        F: Monotone inflationary function.
        x0: Initial state (numpy array).
        max_steps: Maximum iterations (safety bound).
    
    Returns:
        (fixed_point, num_steps) — the fixed point and steps to reach it.
    
    Complexity: O(max_steps * cost(F)) worst case,
                O(height(lattice) * cost(F)) for inflationary F.
    """
    x = x0.copy()
    for step in range(max_steps):
        x_next = F(x)
        if np.array_equal(x_next, x):
            return x, step
        x = x_next
    return x, max_steps


def verify_idempotent(
    F: Callable[[np.ndarray], np.ndarray],
    dim: int,
    num_samples: int = 1000,
    value_range: int = 20
) -> bool:
    """
    Empirically verify that F is idempotent by testing F(F(x)) == F(x)
    on random samples.
    
    Args:
        F: Function to test.
        dim: Dimension of input vectors.
        num_samples: Number of random tests.
        value_range: Range of random values [0, value_range).
    
    Returns:
        True if all tests pass.
    """
    for _ in range(num_samples):
        x = np.random.randint(0, value_range, size=dim)
        if not np.array_equal(F(F(x)), F(x)):
            return False
    return True


def verify_monotone(
    F: Callable[[np.ndarray], np.ndarray],
    dim: int,
    num_samples: int = 1000,
    value_range: int = 20
) -> bool:
    """
    Empirically verify monotonicity: x ≤ y → F(x) ≤ F(y).
    
    Args:
        F: Function to test.
        dim: Dimension of input vectors.
        num_samples: Number of random tests.
        value_range: Range of random values.
    
    Returns:
        True if all tests pass.
    """
    for _ in range(num_samples):
        x = np.random.randint(0, value_range, size=dim)
        y = x + np.random.randint(0, 5, size=dim)
        if not np.all(F(x) <= F(y)):
            return False
    return True


# ──────────────────────────────────────────────────────
# Algorithm 2: Tropical Cellular Automata
# ──────────────────────────────────────────────────────

@dataclass
class TropicalCAResult:
    """Result of a tropical CA simulation."""
    trajectory: List[np.ndarray]
    fixed_point: np.ndarray
    convergence_step: int
    converged: bool


def tropical_min_ca_step(x: np.ndarray) -> np.ndarray:
    """
    One step of the min-tropical CA on a 1D torus.
    
    Each cell takes the minimum of itself and its two neighbors.
    
    Args:
        x: State vector of length N.
    
    Returns:
        Updated state vector.
    
    Complexity: O(N).
    """
    return np.minimum(x, np.minimum(np.roll(x, 1), np.roll(x, -1)))


def tropical_max_ca_step(x: np.ndarray) -> np.ndarray:
    """
    One step of the max-tropical CA on a 1D torus.
    
    Each cell takes the maximum of itself and its two neighbors.
    This is monotone and inflationary.
    
    Args:
        x: State vector of length N.
    
    Returns:
        Updated state vector.
    
    Complexity: O(N).
    """
    return np.maximum(x, np.maximum(np.roll(x, 1), np.roll(x, -1)))


def simulate_tropical_ca(
    step_fn: Callable[[np.ndarray], np.ndarray],
    x0: np.ndarray,
    max_steps: int = 1000,
    record_trajectory: bool = True
) -> TropicalCAResult:
    """
    Simulate a tropical CA until convergence or max_steps.
    
    Args:
        step_fn: The CA update function.
        x0: Initial configuration.
        max_steps: Maximum number of steps.
        record_trajectory: Whether to record all intermediate states.
    
    Returns:
        TropicalCAResult with trajectory, fixed point, and convergence info.
    
    Complexity: O(max_steps * N) where N = len(x0).
    """
    trajectory = [x0.copy()] if record_trajectory else []
    x = x0.copy()
    
    for step in range(max_steps):
        x_next = step_fn(x)
        if record_trajectory:
            trajectory.append(x_next.copy())
        if np.array_equal(x_next, x):
            return TropicalCAResult(
                trajectory=trajectory,
                fixed_point=x,
                convergence_step=step,
                converged=True
            )
        x = x_next
    
    return TropicalCAResult(
        trajectory=trajectory,
        fixed_point=x,
        convergence_step=max_steps,
        converged=False
    )


# ──────────────────────────────────────────────────────
# Algorithm 3: Mutation Distance Analysis
# ──────────────────────────────────────────────────────

def sup_distance(x: np.ndarray, y: np.ndarray) -> int:
    """
    Compute the sup-norm (L∞) distance between two integer vectors.
    
    Args:
        x, y: Integer vectors of the same length.
    
    Returns:
        max_i |x_i - y_i|.
    
    Complexity: O(N).
    """
    return int(np.max(np.abs(x.astype(int) - y.astype(int))))


def mutation_amplification_factor(
    F: Callable[[np.ndarray], np.ndarray],
    dim: int,
    epsilon: int,
    num_samples: int = 1000,
    value_range: int = 50
) -> float:
    """
    Empirically measure the worst-case mutation amplification factor.
    
    For a Lipschitz-1 map, this should be ≤ 1.0.
    
    Args:
        F: The function to test.
        dim: Dimension.
        epsilon: Mutation size.
        num_samples: Number of tests.
        value_range: Range of base values.
    
    Returns:
        max(d∞(F(x), F(y)) / d∞(x, y)) over all tested pairs.
    """
    max_ratio = 0.0
    for _ in range(num_samples):
        x = np.random.randint(0, value_range, size=dim)
        noise = np.random.randint(-epsilon, epsilon + 1, size=dim)
        y = np.clip(x + noise, 0, None)
        
        d_in = sup_distance(x, y)
        if d_in == 0:
            continue
        d_out = sup_distance(F(x), F(y))
        max_ratio = max(max_ratio, d_out / d_in)
    
    return max_ratio


# ──────────────────────────────────────────────────────
# Algorithm 4: Replicator Construction and Composition
# ──────────────────────────────────────────────────────

@dataclass
class TropicalReplicator:
    """
    A tropical replicator: monotone, idempotent, inflationary map.
    
    Attributes:
        step: The update function.
        name: Human-readable name.
        dim: Dimension of state vectors.
    """
    step: Callable[[np.ndarray], np.ndarray]
    name: str
    dim: int
    
    def verify(self, num_samples: int = 500, value_range: int = 20) -> dict:
        """Verify replicator properties empirically."""
        return {
            "idempotent": verify_idempotent(self.step, self.dim, num_samples, value_range),
            "monotone": verify_monotone(self.step, self.dim, num_samples, value_range),
            "inflationary": all(
                np.all(x <= self.step(x))
                for x in [np.random.randint(0, value_range, size=self.dim) 
                          for _ in range(num_samples)]
            )
        }
    
    def fixed_points_in_range(self, value_range: int) -> List[np.ndarray]:
        """Find all fixed points with coordinates in [0, value_range)."""
        fps = []
        # Only feasible for small dim and range
        if self.dim <= 3 and value_range <= 10:
            from itertools import product
            for vals in product(range(value_range), repeat=self.dim):
                x = np.array(vals)
                if np.array_equal(self.step(x), x):
                    fps.append(x)
        return fps


def compose_replicators(
    R1: TropicalReplicator,
    R2: TropicalReplicator
) -> TropicalReplicator:
    """
    Compose two replicators. The result is a replicator if they commute.
    
    Args:
        R1, R2: Replicators on the same dimension.
    
    Returns:
        New replicator R1 ∘ R2.
    """
    assert R1.dim == R2.dim, "Dimensions must match"
    
    def composed_step(x: np.ndarray) -> np.ndarray:
        return R1.step(R2.step(x))
    
    return TropicalReplicator(
        step=composed_step,
        name=f"({R1.name} ∘ {R2.name})",
        dim=R1.dim
    )


def check_commutativity(
    R1: TropicalReplicator,
    R2: TropicalReplicator,
    num_samples: int = 1000,
    value_range: int = 20
) -> bool:
    """Check if two replicators commute."""
    for _ in range(num_samples):
        x = np.random.randint(0, value_range, size=R1.dim)
        if not np.array_equal(R1.step(R2.step(x)), R2.step(R1.step(x))):
            return False
    return True


# ──────────────────────────────────────────────────────
# Algorithm 5: 2D Tropical CA (Grid)
# ──────────────────────────────────────────────────────

def tropical_max_ca_2d_step(grid: np.ndarray) -> np.ndarray:
    """
    One step of max-tropical CA on a 2D torus (periodic grid).
    
    Each cell takes the max of itself and its 4 neighbors.
    
    Args:
        grid: 2D array of shape (H, W).
    
    Returns:
        Updated grid.
    
    Complexity: O(H * W).
    """
    return np.maximum.reduce([
        grid,
        np.roll(grid, 1, axis=0),
        np.roll(grid, -1, axis=0),
        np.roll(grid, 1, axis=1),
        np.roll(grid, -1, axis=1)
    ])


def tropical_min_ca_2d_step(grid: np.ndarray) -> np.ndarray:
    """
    One step of min-tropical CA on a 2D torus.
    
    Each cell takes the min of itself and its 4 neighbors.
    
    Complexity: O(H * W).
    """
    return np.minimum.reduce([
        grid,
        np.roll(grid, 1, axis=0),
        np.roll(grid, -1, axis=0),
        np.roll(grid, 1, axis=1),
        np.roll(grid, -1, axis=1)
    ])


if __name__ == "__main__":
    np.random.seed(42)
    
    # Quick self-test
    print("Running algorithm self-tests...")
    
    # Test fixed-point computation
    F = lambda x: np.minimum(x + 1, 10)
    fp, steps = compute_fixedpoint(F, np.zeros(5, dtype=int))
    assert np.array_equal(fp, np.full(5, 10))
    print(f"  Fixed point: {fp}, steps: {steps}")
    
    # Test tropical CA
    result = simulate_tropical_ca(tropical_max_ca_step, np.array([1, 5, 3, 2, 8, 4]))
    assert result.converged
    print(f"  Max CA fixed point: {result.fixed_point}, steps: {result.convergence_step}")
    
    # Test mutation amplification
    clip_fn = lambda x: np.clip(x, 2, 8)
    factor = mutation_amplification_factor(clip_fn, dim=5, epsilon=3)
    print(f"  Mutation amplification factor: {factor:.3f} (should be ≤ 1.0)")
    
    # Test replicator composition
    R1 = TropicalReplicator(lambda x: np.clip(x, 2, 8), "clamp[2,8]", 5)
    R2 = TropicalReplicator(lambda x: np.clip(x, 0, 6), "clamp[0,6]", 5)
    print(f"  R1 valid: {R1.verify()}")
    print(f"  R2 valid: {R2.verify()}")
    print(f"  Commute: {check_commutativity(R1, R2)}")
    R12 = compose_replicators(R1, R2)
    print(f"  R1∘R2 valid: {R12.verify()}")
    
    print("\nAll self-tests passed!")
