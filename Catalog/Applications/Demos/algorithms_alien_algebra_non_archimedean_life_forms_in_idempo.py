#!/usr/bin/env python3
"""
Algorithms for Tropical Self-Replication Dynamics

Implements the core algorithms from the research paper:
1. FindAttractor: Find the fixed-point attractor of a monotone inflationary map
2. TropicalMinCA: Simulate the tropical min-CA on a ring
3. MutationAnalysis: Analyze mutation stability of idempotent maps
4. ReplicatorComposition: Test and compose tropical replicators
5. AttractorLandscape: Enumerate attractor structure of finite maps
"""

import numpy as np
from typing import Callable, List, Tuple, Optional, Set, Dict
from dataclasses import dataclass
from itertools import product


@dataclass
class AttractorResult:
    """Result of attractor finding."""
    fixed_point: np.ndarray
    steps: int
    orbit: List[np.ndarray]


def find_attractor(
    F: Callable[[np.ndarray], np.ndarray],
    seed: np.ndarray,
    max_steps: int = 10000
) -> AttractorResult:
    """
    Find the fixed-point attractor of a monotone inflationary map.

    Algorithm 1 from the paper. Iterates F starting from seed until
    stabilization or max_steps is reached.

    Args:
        F: The dynamics function (should be monotone and inflationary)
        seed: Initial state vector
        max_steps: Maximum iterations before giving up

    Returns:
        AttractorResult with fixed point, number of steps, and orbit

    Complexity: O(max_steps * n) where n is the dimension of seed
    """
    orbit = [seed.copy()]
    state = seed.copy()

    for step in range(1, max_steps + 1):
        new_state = F(state)
        orbit.append(new_state.copy())

        if np.array_equal(new_state, state):
            return AttractorResult(
                fixed_point=state,
                steps=step - 1,
                orbit=orbit
            )
        state = new_state

    return AttractorResult(
        fixed_point=state,
        steps=max_steps,
        orbit=orbit
    )


class TropicalMinCA:
    """
    Tropical min-CA simulator on a ring of N cells.

    Each cell updates to the minimum of itself and its two neighbors.
    Provably converges to the constant function equal to the global minimum.
    """

    def __init__(self, N: int):
        """Initialize with ring size N."""
        self.N = N

    def step(self, x: np.ndarray) -> np.ndarray:
        """
        One step of the tropical min-CA.

        Args:
            x: Current state, array of length N

        Returns:
            New state after one CA step

        Complexity: O(N)
        """
        result = np.zeros_like(x)
        for i in range(self.N):
            result[i] = min(x[i], x[(i + 1) % self.N], x[(i - 1) % self.N])
        return result

    def simulate(
        self,
        initial: np.ndarray,
        max_steps: Optional[int] = None
    ) -> List[np.ndarray]:
        """
        Simulate until stabilization.

        Args:
            initial: Initial state
            max_steps: Maximum steps (default: N + 1)

        Returns:
            List of states from initial to fixed point

        Complexity: O(N * convergence_time), convergence_time ≤ ⌊N/2⌋
        """
        if max_steps is None:
            max_steps = self.N + 1

        states = [initial.copy()]
        x = initial.copy()

        for _ in range(max_steps):
            x_next = self.step(x)
            states.append(x_next.copy())
            if np.array_equal(x_next, x):
                break
            x = x_next

        return states

    def convergence_time(self, initial: np.ndarray) -> int:
        """Return the number of steps to reach a fixed point."""
        states = self.simulate(initial)
        return len(states) - 2  # subtract initial state and final duplicate


def analyze_mutation_stability(
    F: Callable[[np.ndarray], np.ndarray],
    dim: int,
    value_range: int = 20,
    epsilon_values: List[int] = None,
    num_trials: int = 1000,
    seed: int = 42
) -> Dict[int, Dict[str, float]]:
    """
    Analyze mutation stability of a function F.

    For each epsilon value, generates random pairs (x, y) with
    d_inf(x, y) <= epsilon and checks whether d_inf(F(x), F(y)) <= epsilon.

    Args:
        F: The function to analyze
        dim: Dimension of input vectors
        value_range: Range of random values [0, value_range)
        epsilon_values: List of epsilon values to test
        num_trials: Number of random trials per epsilon
        seed: Random seed

    Returns:
        Dictionary mapping epsilon -> {max_amplification, mean_amplification, violations}
    """
    if epsilon_values is None:
        epsilon_values = [1, 2, 3, 5, 10]

    rng = np.random.RandomState(seed)
    results = {}

    for eps in epsilon_values:
        max_amp = 0
        total_amp = 0
        violations = 0

        for _ in range(num_trials):
            x = rng.randint(0, value_range, size=dim)
            delta = rng.randint(-eps, eps + 1, size=dim)
            y = np.maximum(x + delta, 0)

            d_in = np.max(np.abs(x.astype(int) - y.astype(int)))
            d_out = np.max(np.abs(F(x).astype(int) - F(y).astype(int)))

            amp = d_out - d_in if d_out > d_in else 0
            max_amp = max(max_amp, amp)
            total_amp += amp
            if d_out > d_in:
                violations += 1

        results[eps] = {
            "max_amplification": max_amp,
            "mean_amplification": total_amp / num_trials,
            "violations": violations,
            "violation_rate": violations / num_trials,
            "stable": violations == 0
        }

    return results


def enumerate_idempotent_maps(n: int) -> List[Callable]:
    """
    Enumerate all idempotent maps on {0, ..., n-1}.

    A map f: {0,...,n-1} -> {0,...,n-1} is idempotent iff f(f(x)) = f(x) for all x,
    equivalently iff f fixes every element in its image.

    Args:
        n: Size of the domain

    Returns:
        List of idempotent maps (as numpy arrays)

    Note: The number of idempotent maps on {0,...,n-1} grows rapidly.
    """
    idempotent_maps = []

    # An idempotent map is determined by:
    # 1. Choosing a subset S of {0,...,n-1} (the image = fixed point set)
    # 2. For each element not in S, mapping it to some element of S
    for mask in range(1, 2**n):
        S = [i for i in range(n) if mask & (1 << i)]

        # Generate all maps from {0,...,n-1}\S to S
        non_S = [i for i in range(n) if i not in S]
        if not non_S:
            # S = {0,...,n-1}, only the identity
            f = np.arange(n)
            idempotent_maps.append(f)
            continue

        for assignment in product(S, repeat=len(non_S)):
            f = np.zeros(n, dtype=int)
            for i in S:
                f[i] = i  # fixed points
            for idx, i in enumerate(non_S):
                f[i] = assignment[idx]
            idempotent_maps.append(f)

    return idempotent_maps


def attractor_landscape(n: int) -> Dict[str, any]:
    """
    Compute the attractor landscape for idempotent maps on {0,...,n-1}.

    Returns statistics about the distribution of fixed-point set sizes.

    Args:
        n: Size of the domain

    Returns:
        Dictionary with statistics
    """
    maps = enumerate_idempotent_maps(n)
    fp_counts = [sum(1 for i in range(n) if f[i] == i) for f in maps]

    stats = {
        "domain_size": n,
        "num_idempotent_maps": len(maps),
        "fp_count_distribution": {},
        "mean_fp_count": np.mean(fp_counts),
        "min_fp_count": min(fp_counts),
        "max_fp_count": max(fp_counts),
    }

    for k in range(1, n + 1):
        count = sum(1 for c in fp_counts if c == k)
        if count > 0:
            stats["fp_count_distribution"][k] = count

    return stats


@dataclass
class TropicalReplicator:
    """
    A tropical replicator: monotone, idempotent, inflationary endomorphism.

    This is the formal algebraic model of a "tropical organism."
    """
    name: str
    step: Callable[[np.ndarray], np.ndarray]
    dim: int

    def is_idempotent(self, num_tests: int = 1000, value_range: int = 20) -> bool:
        """Test idempotency on random inputs."""
        rng = np.random.RandomState(42)
        for _ in range(num_tests):
            x = rng.randint(0, value_range, size=self.dim)
            if not np.array_equal(self.step(self.step(x)), self.step(x)):
                return False
        return True

    def is_monotone(self, num_tests: int = 1000, value_range: int = 20) -> bool:
        """Test monotonicity on random inputs."""
        rng = np.random.RandomState(42)
        for _ in range(num_tests):
            x = rng.randint(0, value_range, size=self.dim)
            y = x + rng.randint(0, 5, size=self.dim)
            fx, fy = self.step(x), self.step(y)
            if not np.all(fx <= fy):
                return False
        return True

    def is_inflationary(self, num_tests: int = 1000, value_range: int = 20) -> bool:
        """Test inflationarity on random inputs."""
        rng = np.random.RandomState(42)
        for _ in range(num_tests):
            x = rng.randint(0, value_range, size=self.dim)
            if not np.all(x <= self.step(x)):
                return False
        return True

    def commutes_with(self, other: 'TropicalReplicator',
                      num_tests: int = 1000, value_range: int = 20) -> bool:
        """Test if this replicator commutes with another."""
        rng = np.random.RandomState(42)
        for _ in range(num_tests):
            x = rng.randint(0, value_range, size=self.dim)
            if not np.array_equal(
                self.step(other.step(x)),
                other.step(self.step(x))
            ):
                return False
        return True

    def compose(self, other: 'TropicalReplicator') -> 'TropicalReplicator':
        """Compose two replicators (self ∘ other)."""
        f, g = self.step, other.step
        return TropicalReplicator(
            name=f"{self.name} ∘ {other.name}",
            step=lambda x, f=f, g=g: f(g(x)),
            dim=self.dim
        )


# Example usage and verification
if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # 1. FindAttractor
    print("\n--- FindAttractor ---")
    def F_inflate(x):
        return np.minimum(x + 1, 10)

    result = find_attractor(F_inflate, np.array([3, 1, 7, 5]))
    print(f"Seed: [3, 1, 7, 5]")
    print(f"Fixed point: {result.fixed_point}")
    print(f"Steps: {result.steps}")

    # 2. TropicalMinCA
    print("\n--- TropicalMinCA ---")
    ca = TropicalMinCA(8)
    x0 = np.array([5, 3, 8, 1, 9, 2, 7, 4])
    states = ca.simulate(x0)
    print(f"Initial: {x0}")
    for i, s in enumerate(states[1:], 1):
        print(f"Step {i}: {s}")

    # 3. Attractor Landscape
    print("\n--- Attractor Landscape ---")
    for n in [2, 3, 4]:
        stats = attractor_landscape(n)
        print(f"n={n}: {stats['num_idempotent_maps']} idempotent maps, "
              f"mean {stats['mean_fp_count']:.1f} fixed points")
        print(f"  Distribution: {stats['fp_count_distribution']}")

    # 4. TropicalReplicator composition
    print("\n--- Replicator Composition ---")
    R1 = TropicalReplicator("clamp≥2", lambda x: np.maximum(x, 2), dim=4)
    R2 = TropicalReplicator("clamp≤8", lambda x: np.minimum(x, 8), dim=4)

    print(f"R1 idempotent: {R1.is_idempotent()}")
    print(f"R2 idempotent: {R2.is_idempotent()}")
    print(f"R1, R2 commute: {R1.commutes_with(R2)}")

    R12 = R1.compose(R2)
    print(f"R1∘R2 idempotent: {R12.is_idempotent()}")

    x = np.array([0, 5, 10, 3])
    print(f"\nR1∘R2({x}) = {R12.step(x)}")
    print(f"(R1∘R2)²({x}) = {R12.step(R12.step(x))}")
