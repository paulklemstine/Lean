#!/usr/bin/env python3
"""
Tropical Causal Ordering — Core Algorithms
============================================
Implementations of the algorithms underlying tropical causal analysis.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


# ──────────────────────────────────────────────────────────────────────────────
# §1  Tropical Displacement Functionals
# ──────────────────────────────────────────────────────────────────────────────

def sup_norm_displacement(x: np.ndarray, y: np.ndarray) -> float:
    """
    Sup-norm (L∞) displacement: τ(x, y) = max_i |x_i - y_i|.

    Satisfies the triangle inequality:
        τ(x, z) ≤ τ(x, y) + τ(y, z)

    Time complexity: O(n) where n = len(x)
    Space complexity: O(1)

    >>> sup_norm_displacement(np.array([1.0, 2.0]), np.array([3.0, 1.0]))
    2.0
    """
    return float(np.max(np.abs(x - y)))


def one_sided_displacement(x: np.ndarray, y: np.ndarray) -> float:
    """
    One-sided displacement: τ(x, y) = max_i (y_i - x_i).

    Satisfies the triangle inequality. TropicalFuture under this displacement
    is equivalent to the coordinatewise partial order: y ≤ x component-wise.

    Time complexity: O(n)
    Space complexity: O(1)

    >>> one_sided_displacement(np.array([5.0, 3.0]), np.array([4.0, 2.0]))
    -1.0
    """
    return float(np.max(y - x))


# ──────────────────────────────────────────────────────────────────────────────
# §2  Floyd-Warshall: Causal Closure
# ──────────────────────────────────────────────────────────────────────────────

def floyd_warshall(A: np.ndarray) -> np.ndarray:
    """
    Floyd-Warshall all-pairs shortest paths (= tropical causal closure).

    Given a weight matrix A (with A[i][i] = 0), computes the matrix D where
    D[i][j] = minimum cost path from i to j.

    D[i][j] = min budget T such that MatrixCausal(A, T, i, j).

    Time complexity:  O(n³)
    Space complexity: O(n²)

    Args:
        A: n×n weight matrix with non-negative entries and zero diagonal.

    Returns:
        D: n×n matrix of shortest-path distances.

    >>> A = np.array([[0, 3, np.inf], [np.inf, 0, 1], [2, np.inf, 0]])
    >>> D = floyd_warshall(A)
    >>> D[0, 2]  # 0 → 1 → 2: cost 3 + 1 = 4
    4.0
    """
    n = A.shape[0]
    D = A.copy().astype(float)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]
    return D


def floyd_warshall_with_paths(A: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Floyd-Warshall with path reconstruction.

    Returns both the distance matrix and a predecessor matrix for
    reconstructing optimal causal paths.

    Time complexity:  O(n³)
    Space complexity: O(n²)

    Returns:
        (D, pred): D[i][j] = shortest path cost; pred[i][j] = predecessor of j
                   on the shortest path from i.
    """
    n = A.shape[0]
    D = A.copy().astype(float)
    pred = np.full((n, n), -1, dtype=int)
    for i in range(n):
        for j in range(n):
            if i != j and A[i][j] < np.inf:
                pred[i][j] = i
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]
                    pred[i][j] = pred[k][j]
    return D, pred


def reconstruct_path(pred: np.ndarray, i: int, j: int) -> List[int]:
    """Reconstruct the shortest path from i to j using the predecessor matrix."""
    if pred[i][j] == -1:
        return []
    path = [j]
    while path[-1] != i:
        path.append(pred[i][path[-1]])
        if len(path) > pred.shape[0] + 1:
            return []  # no path
    path.reverse()
    return path


# ──────────────────────────────────────────────────────────────────────────────
# §3  Tropical Matrix Powers (k-hop Reachability)
# ──────────────────────────────────────────────────────────────────────────────

def tropical_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).

    Time complexity:  O(n³)
    Space complexity: O(n²)
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = min(C[i][j], A[i][k] + B[k][j])
    return C


def tropical_mat_pow(A: np.ndarray, k: int) -> np.ndarray:
    """
    k-th tropical power: A^{⊗k} = A ⊗ A ⊗ ... ⊗ A (k times).

    Entry (i,j) gives the minimum cost of a k-hop path from i to j.

    Time complexity:  O(n³ · k) (naive), O(n³ · log k) with squaring
    Space complexity: O(n²)
    """
    n = A.shape[0]
    if k == 0:
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result
    result = A.copy()
    for _ in range(k - 1):
        result = tropical_mat_mul(result, A)
    return result


def tropical_kleene_star(A: np.ndarray) -> np.ndarray:
    """
    Tropical Kleene star: A* = ⊕_{k=0}^{n-1} A^{⊗k}.

    Computes the minimum-cost path of any length, equivalent to
    Floyd-Warshall. Entry (i,j) = minimum cost causal path from i to j.

    Time complexity:  O(n⁴) via iterated powers, O(n³) via Floyd-Warshall
    Space complexity: O(n²)
    """
    return floyd_warshall(A)  # Equivalent but O(n³)


# ──────────────────────────────────────────────────────────────────────────────
# §4  Causal Cone Analysis
# ──────────────────────────────────────────────────────────────────────────────

@dataclass
class CausalCone:
    """Represents a tropical causal cone centered at a point."""
    center: np.ndarray
    budget: float
    displacement_type: str  # 'sup_norm' or 'one_sided'

    def contains(self, y: np.ndarray) -> bool:
        """Check if y is in the causal cone."""
        if self.displacement_type == 'sup_norm':
            return sup_norm_displacement(self.center, y) <= self.budget + 1e-12
        elif self.displacement_type == 'one_sided':
            return one_sided_displacement(self.center, y) <= self.budget + 1e-12
        else:
            raise ValueError(f"Unknown displacement type: {self.displacement_type}")

    def volume_estimate(self, dim: int) -> float:
        """Estimate the volume of the causal cone in R^dim."""
        T = self.budget
        if T < 0:
            return 0.0
        if self.displacement_type == 'sup_norm':
            return (2 * T) ** dim  # L∞ ball
        elif self.displacement_type == 'one_sided':
            return T ** dim  # One-sided cone
        return 0.0


def causal_cone_nesting(center: np.ndarray, T1: float, T2: float,
                         n_samples: int = 10000) -> bool:
    """
    Verify that CausalCone(center, T1) ⊆ CausalCone(center, T2) when T1 ≤ T2,
    by random sampling.
    """
    dim = len(center)
    cone_inner = CausalCone(center, T1, 'sup_norm')
    cone_outer = CausalCone(center, T2, 'sup_norm')
    for _ in range(n_samples):
        y = center + np.random.randn(dim) * T2 * 2
        if cone_inner.contains(y) and not cone_outer.contains(y):
            return False
    return True


# ──────────────────────────────────────────────────────────────────────────────
# §5  Security Propagation
# ──────────────────────────────────────────────────────────────────────────────

def security_propagation_bound(
    security_at_target: float,
    causal_budget: float
) -> float:
    """
    Compute the guaranteed security level after causal propagation.

    If the security at target is λ and the causal budget is T,
    then the security at source is at least λ - T.

    Args:
        security_at_target: Security level λ at the target point.
        causal_budget: Total causal budget T along the chain.

    Returns:
        Lower bound on security at the source point.
    """
    return security_at_target - causal_budget


def chain_security_analysis(
    budgets: List[float],
    initial_security: float
) -> List[float]:
    """
    Analyze security degradation along a causal chain.

    Returns the guaranteed security lower bound at each step.

    Time complexity:  O(n)
    Space complexity: O(n)
    """
    bounds = [initial_security]
    for T in budgets:
        bounds.append(bounds[-1] - T)
    return bounds


# ──────────────────────────────────────────────────────────────────────────────
# §6  Nonexpansive Map Verification
# ──────────────────────────────────────────────────────────────────────────────

def verify_nonexpansive(
    f,
    tau_source,
    tau_target,
    test_points: List[np.ndarray],
    tolerance: float = 1e-10
) -> Tuple[bool, Optional[Tuple[np.ndarray, np.ndarray]]]:
    """
    Empirically verify that f is nonexpansive: τ₂(f(x), f(y)) ≤ τ₁(x, y).

    Returns (True, None) if no violation found, or (False, (x, y)) with
    a counterexample.

    Time complexity:  O(n² · cost_of_f_and_tau) where n = len(test_points)
    """
    for i, x in enumerate(test_points):
        for j, y in enumerate(test_points):
            if i >= j:
                continue
            d_source = tau_source(x, y)
            d_target = tau_target(f(x), f(y))
            if d_target > d_source + tolerance:
                return False, (x, y)
    return True, None


# ──────────────────────────────────────────────────────────────────────────────
# Main: Run examples
# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Causal Ordering — Algorithms")
    print("=" * 50)

    # Example: Floyd-Warshall causal closure
    A = np.array([
        [0, 3, np.inf, 7],
        [np.inf, 0, 1, np.inf],
        [2, np.inf, 0, 4],
        [np.inf, np.inf, np.inf, 0]
    ])
    print("\nWeight matrix:")
    print(A)

    D, pred = floyd_warshall_with_paths(A)
    print("\nCausal closure (all-pairs shortest paths):")
    print(D)

    # Reconstruct a path
    path = reconstruct_path(pred, 0, 3)
    print(f"\nOptimal causal path 0 → 3: {path}")
    print(f"Cost: {D[0, 3]}")

    # Chain security
    budgets = [0.3, 0.5, 0.2, 0.4, 0.1]
    bounds = chain_security_analysis(budgets, 10.0)
    print(f"\nSecurity bounds along chain with budgets {budgets}:")
    for i, b in enumerate(bounds):
        print(f"  Step {i}: guaranteed security ≥ {b:.2f}")
