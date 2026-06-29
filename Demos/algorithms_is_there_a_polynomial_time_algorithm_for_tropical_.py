#!/usr/bin/env python3
"""
Algorithms for Width-Bounded Tropical Φ Computation.

Implements the core algorithms from the research:
1. Bellman DP for layered tropical circuits
2. Tropical matrix multiplication (min-plus)
3. Brute-force enumeration baseline
4. Work-count comparison utilities

All algorithms include full type hints, docstrings, and complexity analysis.
"""

from __future__ import annotations
import numpy as np
from typing import List, Tuple, Optional


# ──────────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────────

class LayeredTropicalCircuit:
    """A layered tropical circuit with L layers and width w.

    Attributes:
        L: Number of layers (transitions).
        w: Width (number of states per layer).
        step_costs: List of L matrices, each w×w. step_costs[ℓ][s][t]
                    is the tropical cost of transitioning from state s
                    to state t at layer ℓ.
    """

    def __init__(self, step_costs: List[np.ndarray]):
        """Initialize from a list of cost matrices.

        Args:
            step_costs: List of w×w numpy arrays.

        Raises:
            ValueError: If matrices are not square or not consistently sized.
        """
        if not step_costs:
            self.L = 0
            self.w = 0
            self.step_costs = []
            return

        self.w = step_costs[0].shape[0]
        for i, M in enumerate(step_costs):
            if M.shape != (self.w, self.w):
                raise ValueError(
                    f"Layer {i}: expected ({self.w}, {self.w}), got {M.shape}")
        self.L = len(step_costs)
        self.step_costs = step_costs

    @classmethod
    def random(cls, L: int, w: int, seed: Optional[int] = None,
               cost_range: Tuple[float, float] = (0.0, 10.0)) -> 'LayeredTropicalCircuit':
        """Generate a random layered tropical circuit.

        Args:
            L: Number of layers.
            w: Width.
            seed: Random seed for reproducibility.
            cost_range: (min, max) range for random costs.
        """
        rng = np.random.default_rng(seed)
        lo, hi = cost_range
        step_costs = [rng.uniform(lo, hi, size=(w, w)) for _ in range(L)]
        return cls(step_costs)


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: Bellman Dynamic Programming
# ──────────────────────────────────────────────────────────────────

def bellman_dp(circuit: LayeredTropicalCircuit) -> Tuple[float, np.ndarray, int]:
    """Compute tropicalΦ via backward Bellman dynamic programming.

    Implements the Bellman recurrence:
        V[L, s] = 0                                      for all s
        V[ℓ, s] = min_t (step[ℓ][s][t] + V[ℓ+1, t])     for ℓ < L

    Then tropicalΦ = min_s V[0, s].

    Time complexity: O(L · w²) arithmetic operations.
    Space complexity: O(L · w) for the full table, O(w) if only the value is needed.

    Args:
        circuit: A LayeredTropicalCircuit instance.

    Returns:
        (phi, V, ops) where:
            phi: The tropical Φ value (minimum path cost).
            V: The full DP table, shape (L+1, w).
            ops: Number of arithmetic operations performed.
    """
    L, w = circuit.L, circuit.w
    V = np.full((L + 1, w), 0.0)
    ops = 0

    for ell in range(L - 1, -1, -1):
        M = circuit.step_costs[ell]
        for s in range(w):
            best = float('inf')
            for t in range(w):
                val = M[s, t] + V[ell + 1, t]
                if val < best:
                    best = val
                ops += 1
            V[ell, s] = best

    phi = np.min(V[0, :])
    ops += w
    return phi, V, ops


def bellman_dp_space_efficient(circuit: LayeredTropicalCircuit) -> Tuple[float, int]:
    """Space-efficient Bellman DP using only O(w) space.

    Only stores the current and next layer values.

    Args:
        circuit: A LayeredTropicalCircuit instance.

    Returns:
        (phi, ops): The tropical Φ value and operation count.
    """
    L, w = circuit.L, circuit.w
    if L == 0:
        return 0.0, 0

    V_next = np.zeros(w)
    ops = 0

    for ell in range(L - 1, -1, -1):
        M = circuit.step_costs[ell]
        V_curr = np.empty(w)
        for s in range(w):
            V_curr[s] = np.min(M[s, :] + V_next)
            ops += w
        V_next = V_curr

    phi = np.min(V_next)
    ops += w
    return phi, ops


def recover_optimal_trajectory(circuit: LayeredTropicalCircuit,
                                V: np.ndarray) -> Tuple[List[int], float]:
    """Recover the optimal trajectory from a computed DP table.

    Args:
        circuit: The layered tropical circuit.
        V: The DP table from bellman_dp, shape (L+1, w).

    Returns:
        (trajectory, cost): The optimal state sequence and its cost.
    """
    L, w = circuit.L, circuit.w
    trajectory = [int(np.argmin(V[0, :]))]

    for ell in range(L):
        s = trajectory[-1]
        costs = circuit.step_costs[ell][s, :] + V[ell + 1, :]
        trajectory.append(int(np.argmin(costs)))

    cost = sum(circuit.step_costs[ell][trajectory[ell], trajectory[ell + 1]]
               for ell in range(L))
    return trajectory, cost


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Tropical (Min-Plus) Matrix Multiplication
# ──────────────────────────────────────────────────────────────────

def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Compute the tropical (min-plus) product of two matrices.

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    Time complexity: O(w³) for w×w matrices.

    Args:
        A, B: Square matrices of the same dimension.

    Returns:
        The min-plus product matrix.
    """
    w = A.shape[0]
    C = np.full((w, w), float('inf'))
    for i in range(w):
        for j in range(w):
            for k in range(w):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_phi_matrix_method(circuit: LayeredTropicalCircuit) -> float:
    """Compute tropicalΦ via tropical matrix chain multiplication.

    Forms the tropical product M = M_0 ⊗ M_1 ⊗ ... ⊗ M_{L-1}
    and returns min_{i,j} M[i,j].

    Time complexity: O(L · w³).
    This is worse than Bellman DP by a factor of w, but connects
    to tropical linear algebra and transfer matrix methods.

    Args:
        circuit: A LayeredTropicalCircuit instance.

    Returns:
        The tropical Φ value.
    """
    L, w = circuit.L, circuit.w
    if L == 0:
        return 0.0

    result = circuit.step_costs[0].copy()
    for ell in range(1, L):
        result = tropical_matmul(result, circuit.step_costs[ell])

    return np.min(result)


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: Brute-Force Enumeration (Baseline)
# ──────────────────────────────────────────────────────────────────

def brute_force_enumeration(circuit: LayeredTropicalCircuit) -> Tuple[float, int]:
    """Compute tropicalΦ by enumerating all w^(L+1) trajectories.

    Time complexity: O(L · w^(L+1)) — exponential in L.
    This is the naive baseline that the DP algorithm improves upon.

    Args:
        circuit: A LayeredTropicalCircuit instance.

    Returns:
        (phi, trajectory_count): The minimum cost and number of trajectories examined.
    """
    from itertools import product as iter_product

    L, w = circuit.L, circuit.w
    best = float('inf')
    count = 0

    for traj in iter_product(range(w), repeat=L + 1):
        cost = sum(circuit.step_costs[ell][traj[ell], traj[ell + 1]]
                   for ell in range(L))
        best = min(best, cost)
        count += 1

    return best, count


# ──────────────────────────────────────────────────────────────────
# Complexity Analysis Utilities
# ──────────────────────────────────────────────────────────────────

def dp_work_bound(L: int, w: int) -> int:
    """Compute the DP work bound: L * w² + w.

    This is the exact number of min/add operations in Bellman DP.
    """
    return L * w * w + w


def enumeration_work(L: int, w: int) -> int:
    """Compute the brute-force enumeration work: L * w^(L+1)."""
    return L * (w ** (L + 1))


def crossover_point(w: int, max_L: int = 1000) -> Optional[int]:
    """Find the smallest L where DP work < 2^L.

    This is the crossover point from dp_beats_enumeration.

    Args:
        w: Width parameter.
        max_L: Maximum L to search.

    Returns:
        The crossover L, or None if not found within max_L.
    """
    for L in range(1, max_L + 1):
        if dp_work_bound(L, w) < 2 ** L:
            return L
    return None


# ──────────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Create a random circuit
    circuit = LayeredTropicalCircuit.random(L=8, w=3, seed=42)

    print("Layered Tropical Circuit:")
    print(f"  Layers (L) = {circuit.L}")
    print(f"  Width  (w) = {circuit.w}")

    # Bellman DP
    phi_dp, V, ops_dp = bellman_dp(circuit)
    print(f"\nBellman DP:")
    print(f"  tropicalΦ = {phi_dp:.6f}")
    print(f"  Operations: {ops_dp}")
    print(f"  Work bound: {dp_work_bound(circuit.L, circuit.w)}")

    # Tropical matrix method
    phi_mat = tropical_phi_matrix_method(circuit)
    print(f"\nTropical Matrix Method:")
    print(f"  tropicalΦ = {phi_mat:.6f}")

    # Brute force
    phi_bf, count = brute_force_enumeration(circuit)
    print(f"\nBrute Force:")
    print(f"  tropicalΦ = {phi_bf:.6f}")
    print(f"  Trajectories examined: {count}")

    # Verify agreement
    assert np.isclose(phi_dp, phi_bf), "DP ≠ Brute Force!"
    assert np.isclose(phi_dp, phi_mat), "DP ≠ Matrix Method!"
    print("\n✓ All three methods agree.")

    # Recover optimal trajectory
    traj, cost = recover_optimal_trajectory(circuit, V)
    print(f"\nOptimal trajectory: {traj}")
    print(f"Trajectory cost: {cost:.6f}")

    # Crossover analysis
    print("\nCrossover points (dp_beats_enumeration):")
    for w in [1, 2, 3, 5, 10, 50]:
        cp = crossover_point(w)
        print(f"  w={w:3d}: crossover at L = {cp}")
